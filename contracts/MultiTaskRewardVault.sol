// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IERC20 {
    function transfer(address to, uint256 amount) external returns (bool);
}

contract MultiTaskRewardVault {
    address public owner;
    IERC20 public naiToken;

    struct Task {
        uint256 rewardAmount;
        bool active;
    }

    mapping(uint8 => Task) public tasks;
    mapping(uint8 => mapping(address => bool)) public hasClaimed;

    event TaskConfigured(uint8 indexed taskId, uint256 rewardAmount, bool active);
    event Claimed(uint8 indexed taskId, address indexed user, uint256 amount);

    modifier onlyOwner() {
        require(msg.sender == owner, "Not authorized");
        _;
    }

    constructor(address _naiToken) {
        require(_naiToken != address(0), "Invalid token");
        owner = msg.sender;
        naiToken = IERC20(_naiToken);
    }

    function configureTask(uint8 taskId, uint256 rewardAmount, bool active) external onlyOwner {
        tasks[taskId] = Task(rewardAmount, active);
        emit TaskConfigured(taskId, rewardAmount, active);
    }

    function claimReward(uint8 taskId) external {
        Task memory task = tasks[taskId];
        require(task.active, "Task not active");
        require(!hasClaimed[taskId][msg.sender], "Already claimed");

        hasClaimed[taskId][msg.sender] = true;

        require(naiToken.transfer(msg.sender, task.rewardAmount), "Transfer failed");

        emit Claimed(taskId, msg.sender, task.rewardAmount);
    }

    function hasUserClaimed(uint8 taskId, address user) external view returns (bool) {
        return hasClaimed[taskId][user];
    }

    function withdrawRemaining(address to, uint256 amount) external onlyOwner {
        naiToken.transfer(to, amount);
    }
}
