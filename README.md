# 🧠 NAi Protocol Demo — Decentralized AI Infrastructure

Welcome to the demo smart contracts of **NAi Protocol**, a decentralized infrastructure project combining blockchain governance with real-time AI-based trust scoring. This repository contains simplified and verified contracts used in our testnet deployment for grant applications, auditing, and integration testing.

---

## 🔍 Overview

NAi Protocol enables:
- ✅ **AI-powered reputation scoring** for nodes and users.
- ✅ **Community-governed DAO** via smart contract proposals.
- ✅ **Reward distribution** for social tasks and uptime-based work.
- ✅ **Vesting and funding logic** for contributors and backers.
- ✅ **Real-time node monitoring** with ban/violation logging.
- ✅ **On-chain logging of all activities and rewards.**

---

## 🧱 Contract Architecture

| Contract | Purpose |
|----------|---------|
| [`NAiToken.sol`](./contracts/NAiToken.sol) | ERC20 token with max cap & role-based minting |
| [`NAiGovernanceDAO.sol`](./contracts/NAiGovernanceDAO.sol) | Simplified Governor for proposal → vote → queue → execute |
| [`TimelockController.sol`](./contracts/TimelockController.sol) | Delay executor for DAO, ensuring safety in proposal execution |
| [`NAiRewardDistributor.sol`](./contracts/NAiRewardDistributor.sol) | Monthly reward claim system (set by DAO, claimed by user) |
| [`MultiTaskRewardVault.sol`](./contracts/MultiTaskRewardVault.sol) | Reward contract for task-based claiming (Twitter, Discord...) |
| [`NAiRewardLogger.sol`](./contracts/NAiRewardLogger.sol) | Emits reward log events (used by backend only, no transfer) |
| [`NAiVestingMulti.sol`](./contracts/NAiVestingMulti.sol) | Contributor vesting with cliff, duration, and claim function |
| [`NodeManager.sol`](./contracts/NodeManager.sol) | On-chain node registry with ban/violation/reporting logic |

> All contracts are written in Solidity ^0.8.x and use OpenZeppelin libraries.

---

##  Deployment (Testnet)

Contracts have been deployed and verified on **Polygon Mumbai** testnet.  
Example explorer: https://mumbai.polygonscan.com/address/0x...

> Note: All contracts were verified with matching compiler versions.

---

##  How to Test

You can fork this repo and deploy/test locally:

```bash
git clone https://github.com/naiprotocol-N/naiprotocol-demo.git
cd naiprotocol-demo

# Install dependencies (requires Node.js, Hardhat)
npm install

# Compile all contracts
npx hardhat compile

# Deploy on local or testnet
npx hardhat run scripts/deploy.ts --network mumbai
