// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

import "@openzeppelin/contracts/access/AccessControl.sol";

/**
 * @title NodeManager
 * @notice Governance‑controlled registry for NAi Protocol nodes on Polygon Mainnet (chainId = 137).
 *         – DAO at 0x09c1785AFc9Bfbb7F4866c69B2CAC636936C151D holds ADMIN_ROLE
 *         – Supports temporary/permanent bans, hard delete, soft remove, violation logging
 */
contract NodeManager is AccessControl {
    uint256 private constant _DAY = 24 hours;
    address public constant DAO_ADDRESS =
        0x1D1075C94b87091601229343b7dcB245856fB012;
    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");

    struct NodeInfo {
        bool active;            // Added + not soft‑removed
        uint256 banUntil;       // 0 ⇒ not banned, max uint256 ⇒ permanent, else timestamp
        string reason;          // Last ban/violation reason
        uint256 lastViolation;  // Timestamp of last violation
    }

    // Storage
    mapping(address => NodeInfo) private nodes;
    address[] private allNodes;
    mapping(address => uint256) private idxPlusOne; // swap‑and‑pop helper

    // Events
    event NodeAdded(address indexed node);
    event NodeRemoved(address indexed node);
    event NodeBanned(address indexed node, string reason, uint256 banUntil);
    event NodeUnbanned(address indexed node);
    event NodeViolation(address indexed node, string reason, uint256 timestamp);

    constructor() {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender); // deployer for emergencies
        _grantRole(ADMIN_ROLE, DAO_ADDRESS);        // DAO controls NodeManager
    }

    // ───────────────────────────── node lifecycle ─────────────────────────────

    function addNode(address node) external onlyRole(ADMIN_ROLE) {
        require(node != address(0), "invalid addr");
        require(!nodes[node].active, "already added");

        nodes[node] = NodeInfo(true, 0, "", 0);
        allNodes.push(node);
        idxPlusOne[node] = allNodes.length;

        emit NodeAdded(node);
    }

    function removeNode(address node) external onlyRole(ADMIN_ROLE) {
        require(nodes[node].active, "not active");
        nodes[node].active = false;
        emit NodeRemoved(node);
    }

    function deleteNode(address node) external onlyRole(ADMIN_ROLE) {
        require(nodes[node].active || nodes[node].banUntil != 0, "not found");
        uint256 i = idxPlusOne[node];
        if (i != 0) {
            uint256 last = allNodes.length - 1;
            uint256 idx = i - 1;
            if (idx != last) {
                address lastAddr = allNodes[last];
                allNodes[idx] = lastAddr;
                idxPlusOne[lastAddr] = i;
            }
            allNodes.pop();
            delete idxPlusOne[node];
        }
        delete nodes[node];
        emit NodeRemoved(node);
    }

    // ───────────────────────────── ban management ─────────────────────────────

    /** Ban durations shortcuts (seconds):
     *  • 24h → 1 *_DAY
     *  • 48h → 2 *_DAY
     *  • 7d  → 7 *_DAY
     *  • 30d → 30 *_DAY
     *  Pass 0 for permanent ban.
     */
    function banNode(address node, string calldata reason, uint256 durationSeconds)
        external onlyRole(ADMIN_ROLE)
    {
        require(nodes[node].active, "not active");
        uint256 until = durationSeconds == 0 ? type(uint256).max : block.timestamp + durationSeconds;
        nodes[node].banUntil = until;
        nodes[node].reason = reason;
        emit NodeBanned(node, reason, until);
    }

    function unbanNode(address node) external onlyRole(ADMIN_ROLE) {
        require(nodes[node].banUntil != 0, "not banned");
        nodes[node].banUntil = 0;
        nodes[node].reason = "";
        emit NodeUnbanned(node);
    }

    // ───────────────────────────── violations logging ─────────────────────────────

    function reportViolation(address node, string calldata reason) external onlyRole(ADMIN_ROLE) {
        require(nodes[node].active, "not active");
        nodes[node].lastViolation = block.timestamp;
        nodes[node].reason = reason;
        emit NodeViolation(node, reason, block.timestamp);
    }

    // ───────────────────────────── view helpers ─────────────────────────────

    function getAllNodes() external view returns (address[] memory) {
        return allNodes;
    }

    function getNodeInfo(address node) external view returns (NodeInfo memory info, uint256 remainingBan) {
        info = nodes[node];
        remainingBan = _remainingBan(node);
    }

    function isNodeValid(address node) external view returns (bool) {
        NodeInfo storage n = nodes[node];
        return n.active && _remainingBan(node) == 0;
    }

    function getNodeCount() external view returns (uint256) {
        return allNodes.length;
    }

    // ───────────────────────────── internals ─────────────────────────────

    function _remainingBan(address node) internal view returns (uint256) {
        uint256 until = nodes[node].banUntil;
        if (until == 0) return 0;
        if (until == type(uint256).max) return type(uint256).max;
        return until > block.timestamp ? until - block.timestamp : 0;
    }
}
