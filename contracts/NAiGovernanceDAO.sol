// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/governance/TimelockController.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Votes.sol";

contract NAiGovernanceDAO is AccessControl, ReentrancyGuard {
    enum ProposalState { Active, Queued, Executed, Cancelled }

    struct Proposal {
        string description;
        uint256 voteFor;
        uint256 voteAgainst;
        uint256 deadline;
        address target;
        bytes callData;
        bool executed;
        address proposer;
    }

    ERC20Votes public governanceToken;
    TimelockController public timelock;
    uint256 public proposalCount;
    uint256 public minimumVotesNeeded;

    mapping(uint256 => Proposal) public proposals;
    mapping(uint256 => mapping(address => bool)) public hasVoted;
    mapping(uint256 => ProposalState) public proposalStates;

    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");

    constructor(address _token, address _timelock, uint256 _minVotes) {
        governanceToken = ERC20Votes(_token);
        timelock = TimelockController(payable(_timelock));
        minimumVotesNeeded = _minVotes;

        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(ADMIN_ROLE, msg.sender);
    }

    function createProposal(string calldata desc, uint256 duration, address target, bytes calldata callData) external {
        require(governanceToken.getVotes(msg.sender) > 0, "Not enough votes");

        proposalCount++;
        proposals[proposalCount] = Proposal({
            description: desc,
            voteFor: 0,
            voteAgainst: 0,
            deadline: block.timestamp + duration,
            target: target,
            callData: callData,
            executed: false,
            proposer: msg.sender
        });

        proposalStates[proposalCount] = ProposalState.Active;
    }

    function vote(uint256 id, bool support) external {
        Proposal storage p = proposals[id];
        require(block.timestamp <= p.deadline, "Voting ended");
        require(!hasVoted[id][msg.sender], "Already voted");

        uint256 weight = governanceToken.getVotes(msg.sender);
        require(weight > 0, "No weight");

        hasVoted[id][msg.sender] = true;
        if (support) p.voteFor += weight;
        else p.voteAgainst += weight;
    }

    function queueProposal(uint256 id) external onlyRole(ADMIN_ROLE) {
        Proposal storage p = proposals[id];
        require(p.voteFor > p.voteAgainst && p.voteFor >= minimumVotesNeeded, "Not enough support");
        bytes32 salt = bytes32(id);
        timelock.schedule(p.target, 0, p.callData, bytes32(0), salt, 1 days);
        proposalStates[id] = ProposalState.Queued;
    }

    function executeProposal(uint256 id) external {
        Proposal storage p = proposals[id];
        bytes32 salt = bytes32(id);
        bytes32 opId = timelock.hashOperation(p.target, 0, p.callData, bytes32(0), salt);
        require(timelock.isOperationReady(opId), "Not ready");
        timelock.execute(p.target, 0, p.callData, bytes32(0), salt);
        p.executed = true;
        proposalStates[id] = ProposalState.Executed;
    }

    function getProposal(uint256 id) external view returns (Proposal memory, ProposalState) {
        return (proposals[id], proposalStates[id]);
    }
}
