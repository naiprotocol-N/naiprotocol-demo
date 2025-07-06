// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

/**
 * @title NAiRewardDistributor
 * @notice Distributes NAI rewards on a monthly (epoch-based) basis (e.g. 202507 = July 2025).
 *         Only the DAO (via TimelockController) can set rewards.
 *         Users must call `claim(epoch)` themselves to receive their NAI.
 *         Each wallet can only claim once per epoch.
 */
contract NAiRewardDistributor is Ownable, ReentrancyGuard {
    using SafeERC20 for IERC20;

    IERC20 public immutable nai;

    // Mapping: epoch (YYYYMM) => wallet => reward amount
    mapping(uint256 => mapping(address => uint256)) public rewards;

    // Mapping: epoch => wallet => has claimed?
    mapping(uint256 => mapping(address => bool)) public claimed;

    event RewardSet(uint256 indexed epoch, address indexed wallet, uint256 amount);
    event RewardsBatchSet(uint256 indexed epoch, uint256 count);
    event Claimed(uint256 indexed epoch, address indexed wallet, uint256 amount);

    /**
     * @param _nai Address of the NAI token
     * @param _owner Timelock/DAO address with permission to set rewards
     */
    constructor(address _nai, address _owner) {
        require(_nai != address(0), "Invalid NAI token address");
        nai = IERC20(_nai);
        transferOwnership(_owner);
    }

    /**
     * @notice DAO sets rewards for a batch of wallets for a given epoch (e.g. 202507)
     * @param epoch The reward epoch
     * @param wallets List of recipient addresses
     * @param amounts List of reward amounts (in NAI)
     */
    function setRewards(
        uint256 epoch,
        address[] calldata wallets,
        uint256[] calldata amounts
    ) external onlyOwner {
        require(wallets.length == amounts.length, "Length mismatch");

        for (uint256 i = 0; i < wallets.length; ++i) {
            rewards[epoch][wallets[i]] = amounts[i];
            emit RewardSet(epoch, wallets[i], amounts[i]);
        }

        emit RewardsBatchSet(epoch, wallets.length);
    }

    /**
     * @notice Users claim their reward for a specific epoch
     * @param epoch The reward epoch to claim from
     */
    function claim(uint256 epoch) external nonReentrant {
        address user = msg.sender;

        require(!claimed[epoch][user], "Already claimed");
        uint256 amount = rewards[epoch][user];
        require(amount > 0, "No reward available");

        claimed[epoch][user] = true;
        nai.safeTransfer(user, amount);

        emit Claimed(epoch, user, amount);
    }

    /**
     * @notice Get user's reward for a given epoch if not yet claimed
     * @param epoch Epoch to check
     * @param user Wallet address
     */
    function getUnclaimedReward(uint256 epoch, address user) external view returns (uint256) {
        if (claimed[epoch][user]) return 0;
        return rewards[epoch][user];
    }

    /**
     * @notice DAO deposits NAI into the distributor contract
     * @param amount Amount of NAI to fund
     */
    function fund(uint256 amount) external onlyOwner {
        nai.safeTransferFrom(msg.sender, address(this), amount);
    }

    /**
     * @notice DAO rescues unused NAI from the contract
     * @param amount Amount to withdraw
     * @param to Address to receive the withdrawn tokens
     */
    function rescue(uint256 amount, address to) external onlyOwner {
        nai.safeTransfer(to, amount);
    }
}
