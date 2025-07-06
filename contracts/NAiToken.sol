// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Votes.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";

/// @title NAiToken - Governance token with cap and role-based minting
contract NAiToken is ERC20Votes, AccessControl {
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    uint256 private _cap;

    event CapUpdated(uint256 oldCap, uint256 newCap);

    constructor(uint256 cap_) ERC20("NAi Token", "NAI") ERC20Permit("NAi Token") {
        require(cap_ > 0, "Cap must be > 0");
        _cap = cap_;
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);

        // Mint initial supply
        uint256 initSupply = 100_000_000 * 10 ** decimals();
        require(initSupply <= _cap, "Exceeds cap");
        _mint(msg.sender, initSupply);
    }

    function cap() public view returns (uint256) {
        return _cap;
    }

    function setCap(uint256 newCap) external onlyRole(DEFAULT_ADMIN_ROLE) {
        require(newCap >= totalSupply(), "New cap < supply");
        emit CapUpdated(_cap, newCap);
        _cap = newCap;
    }

    function mint(address to, uint256 amount) external onlyRole(MINTER_ROLE) {
        require(totalSupply() + amount <= _cap, "Cap exceeded");
        _mint(to, amount);
    }

    function burn(address from, uint256 amount) external onlyRole(MINTER_ROLE) {
        _burn(from, amount);
    }

    function grantMinterRole(address account) external onlyRole(DEFAULT_ADMIN_ROLE) {
        grantRole(MINTER_ROLE, account);
    }

    function revokeMinterRole(address account) external onlyRole(DEFAULT_ADMIN_ROLE) {
        revokeRole(MINTER_ROLE, account);
    }

    function _afterTokenTransfer(address from, address to, uint256 amount) internal override(ERC20Votes) {
        super._afterTokenTransfer(from, to, amount);
    }

    function _mint(address to, uint256 amount) internal override(ERC20Votes) {
        super._mint(to, amount);
    }

    function _burn(address account, uint256 amount) internal override(ERC20Votes) {
        super._burn(account, amount);
    }
}
