#  NAi Protocol Demo — Decentralized AI Infrastructure

Welcome to the demo smart contracts of **NAi Protocol**, a decentralized infrastructure project combining blockchain governance with real-time AI-based trust scoring. This repository contains simplified and verified contracts used in our testnet deployment for grant applications, auditing, and integration testing.

---

##  Overview

NAi Protocol enables:
- ✅ **AI-powered reputation scoring** for nodes and users.
- ✅ **Community-governed DAO** via smart contract proposals.
- ✅ **Reward distribution** for social tasks and uptime-based work.
- ✅ **Vesting and funding logic** for contributors and backers.
- ✅ **Real-time node monitoring** with ban/violation logging.
- ✅ **On-chain logging of all activities and rewards.**

---

##  Contract Architecture

| Contract                            | Purpose |
|-------------------------------------|---------|
| [`NAiToken.sol`](./contracts/NAiToken.sol)               | ERC20 token with capped supply & minting roles |
| [`NAiGovernanceDAO.sol`](./contracts/NAiGovernanceDAO.sol) | Proposal → vote → queue → execute flow |
| [`TimelockController.sol`](./contracts/TimelockController.sol) | Delay mechanism to secure DAO execution |
| [`NAiRewardDistributor.sol`](./contracts/NAiRewardDistributor.sol) | Monthly rewards claimable by users |
| [`MultiTaskRewardVault.sol`](./contracts/MultiTaskRewardVault.sol) | Reward contract for Twitter/Discord tasks |
| [`NAiRewardLogger.sol`](./contracts/NAiRewardLogger.sol)         | On-chain log of distributed rewards (no transfer) |
| [`NAiVestingMulti.sol`](./contracts/NAiVestingMulti.sol)         | Linear vesting with cliff + claimable tracking |
| [`NodeManager.sol`](./contracts/NodeManager.sol)         | Registry of nodes, violations, bans, and removals |

All contracts are written in **Solidity ^0.8.x** and rely on [OpenZeppelin Contracts](https://github.com/OpenZeppelin/openzeppelin-contracts).

---

##  Deployment (Polygon Mainnet)

All contracts below are verified on [PolygonScan](https://polygonscan.com):

| Contract                   | Address |
|----------------------------|---------|
| `NAiToken`                 | [`0x300ee3A9bED8Dc60eaa1e5CdC48334B2842bDC8d`](https://polygonscan.com/address/0x300ee3A9bED8Dc60eaa1e5CdC48334B2842bDC8d) |
| `NAiGovernanceDAO`         | [`0x1D1075C94b87091601229343b7dcB245856fB012`](https://polygonscan.com/address/0x1D1075C94b87091601229343b7dcB245856fB012) |
| `TimelockController`       | [`0x54480088C8055F401298687673eDE10b969163Cb`](https://polygonscan.com/address/0x54480088C8055F401298687673eDE10b969163Cb) |
| `NAiRewardDistributor`     | [`0xBD7378aaC70d41514b3DF00980E7b0392da6B4c1`](https://polygonscan.com/address/0xBD7378aaC70d41514b3DF00980E7b0392da6B4c1) |
| `MultiTaskRewardVault`     | [`0xE2385a8b24F5e76D1BcB59624e68C1F0D782De86`](https://polygonscan.com/address/0xE2385a8b24F5e76D1BcB59624e68C1F0D782De86) |
| `NAiVestingMulti`          | [`0x38B0536dBA4a2d57e04351a6372eeba908B081CF`](https://polygonscan.com/address/0x38B0536dBA4a2d57e04351a6372eeba908B081CF) |
| `NodeManager`              | [`0xc2d9BbDd36e731AFbA18bdF4FbF4621EA92Ed358`](https://polygonscan.com/address/0xc2d9BbDd36e731AFbA18bdF4FbF4621EA92Ed358) |

---

##  How to Test

```bash
git clone https://github.com/naiprotocol-N/naiprotocol-demo.git
cd naiprotocol-demo

# Install dependencies
npm install

# Compile contracts
npx hardhat compile

# Deploy to local or testnet
npx hardhat run scripts/deploy.ts --network mumbai

 Use Cases
🗳️DAO governance for protocol upgrades

 Reward distribution based on:

Social task completion (e.g. Twitter tasks)

Node uptime and performance scoring

Contributor vesting schedules

🛡 Tamper-proof logging of bans, violations, and rewards

 Grant Funding Use
This repo is part of a testnet/mainnet deployment in support of non-dilutive grant funding (~$10k–$20k) to cover:

Node infrastructure and uptime scoring

Frontend for DAO + monitoring dashboard

Community onboarding + education tools

 License
MIT License — open source and free to use.

🔗 Links
 Website: naiprotocol.com

 DAO App: dao.naiprotocol.com

 Twitter: @InfoNaiprotocol
