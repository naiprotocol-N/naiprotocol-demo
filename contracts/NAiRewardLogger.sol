// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @title NAiRewardLogger
 * @notice Logs daily/monthly rewards using epoch IDs (e.g. 202507 or 20250705). Only the owner (backend) can log.
 */
contract NAiRewardLogger is Ownable {
    event RewardLogged(address indexed wallet, uint256 amount, uint256 indexed epoch);

    constructor() {}

    function log(address wallet, uint256 amount, uint256 epoch) external onlyOwner {
        require(wallet != address(0), "Invalid wallet");
        emit RewardLogged(wallet, amount, epoch);
    }

    function logBatch(address[] calldata wallets, uint256[] calldata amounts, uint256 epoch) external onlyOwner {
        require(wallets.length == amounts.length, "Length mismatch");
        for (uint256 i = 0; i < wallets.length; i++) {
            require(wallets[i] != address(0), "Invalid wallet");
            emit RewardLogged(wallets[i], amounts[i], epoch);
        }
    }

    function updateBackend(address newBackend) external onlyOwner {
        transferOwnership(newBackend);
    }
}
