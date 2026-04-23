# PrivaFi — Confidential DeFi Suite

> Built for the Zama Developer Program Mainnet Season 2 - Builder Track

PrivaFi is a three-module confidential DeFi application built on the Zama FHEVM protocol. It enables users to interact with financial data on-chain without ever revealing the underlying values. All sensitive computations happen directly on encrypted integers using Fully Homomorphic Encryption.

---

## The Problem

DeFi is fully transparent. Every balance, salary, and credit check is visible to anyone reading the blockchain. Users are forced to choose between privacy and on-chain finance — there has been no middle ground.

PrivaFi changes that.

---

## What It Does

### Module 1 — Private Credit Score
Users submit their wallet balance and transaction count. The smart contract encrypts these values using `FHE.asEuint64()` and evaluates eligibility against on-chain thresholds using FHE comparison operators. The result is a pass/fail — no raw financial data is ever exposed.

### Module 2 — Confidential Payroll
Employers register employees and set salaries as encrypted `euint64` values on-chain. Each salary is access-controlled using `FHE.allow()` so only the intended employee can decrypt their own pay. No colleague, auditor, or block explorer can read what anyone else earns.

### Module 3 — Hidden Portfolio Tracker
Users register an encrypted portfolio balance on-chain. They can then generate cryptographic proofs that their balance exceeds any given threshold — without disclosing the actual figure. The comparison runs entirely inside FHE, returning only a boolean result.

---

## How FHE Is Used

All three contracts use the Zama FHEVM library (`@fhevm/solidity`) for on-chain encrypted computation:

- `FHE.asEuint64(value)` — converts plain values to encrypted integers
- `FHE.gt(a, b)` — encrypted greater-than comparison
- `FHE.and(a, b)` — encrypted boolean AND
- `FHE.add(a, b)` — encrypted addition
- `FHE.allowThis()` — grants the contract access to encrypted values
- `FHE.allow(value, address)` — grants specific addresses decryption rights

No plaintext financial data is stored or emitted on-chain at any point.

---

## Deployed Contracts (Sepolia Testnet)

| Contract | Address | Etherscan |
|---|---|---|
| PrivateCreditScore | `0xaa7D007ede04C1c52D7cc95A8357813c394f3af6` | [View](https://sepolia.etherscan.io/address/0xaa7D007ede04C1c52D7cc95A8357813c394f3af6#code) |
| ConfidentialPayroll | `0x832E4087cf2a7115adc74137644AdcFb76B3A0Fd` | [View](https://sepolia.etherscan.io/address/0x832E4087cf2a7115adc74137644AdcFb76B3A0Fd#code) |
| HiddenPortfolio | `0x4708F4c5Afc818B9cF42c1652666aC67034866ae` | [View](https://sepolia.etherscan.io/address/0x4708F4c5Afc818B9cF42c1652666aC67034866ae#code) |

---

## Tech Stack

- **Smart Contracts:** Solidity 0.8.27 with Zama FHEVM (`@fhevm/solidity`)
- **Development:** Hardhat + hardhat-deploy + TypeScript
- **Frontend:** React + TypeScript + Vite
- **Wallet:** MetaMask via ethers.js v6
- **Network:** Sepolia testnet
- **Verification:** Etherscan API v2

---

## Project Structure

```
privafi/                        # Smart contracts (Hardhat)
├── contracts/
│   ├── PrivateCreditScore.sol
│   ├── ConfidentialPayroll.sol
│   └── HiddenPortfolio.sol
├── deploy/
│   └── deploy.ts
├── hardhat.config.ts
└── package.json

privafi-frontend/               # React frontend
├── src/
│   ├── components/
│   │   ├── Landing.tsx
│   │   ├── CreditScore.tsx
│   │   ├── Payroll.tsx
│   │   └── Portfolio.tsx
│   ├── contracts/
│   │   ├── addresses.ts
│   │   └── wallet.ts
│   └── App.tsx
└── package.json
```

---

## Local Setup

### Prerequisites
- Node.js 20+
- MetaMask with Sepolia network
- Sepolia ETH (free from https://cloud.google.com/application/web3/faucet/ethereum/sepolia)

### Smart Contracts

```bash
git clone <repo-url>
cd privafi
npm install
npx hardhat vars set MNEMONIC
npx hardhat vars set INFURA_API_KEY
npx hardhat vars set ETHERSCAN_API_KEY
npm run compile
npm run deploy:sepolia
```

### Frontend

```bash
cd privafi-frontend
npm install
npm run dev
```

Open http://localhost:5173, connect MetaMask on Sepolia, and use the app.

---

## How to Test

1. Connect MetaMask wallet on Sepolia testnet
2. **Credit Score** — enter balance `5000` and tx count `25`, click Check Eligibility
3. **Payroll** — enter an employee wallet address and salary amount, click Set Encrypted Salary
4. **Portfolio** — register a balance of `10000`, then prove it is above `5000`

All transactions are confirmed on Sepolia and verifiable on Etherscan.

---

## Real-World Use Cases

- **DeFi lending** — verify borrower creditworthiness without exposing wallet history
- **DAO payroll** — distribute contributor compensation without public salary disclosure
- **Institutional DeFi** — prove portfolio size to counterparties without revealing holdings
- **Compliant privacy** — satisfy regulatory requirements while maintaining on-chain confidentiality

---

## Resources Used

- [Zama FHEVM Documentation](https://docs.zama.ai/fhevm)
- [fhevm-hardhat-template](https://github.com/zama-ai/fhevm-hardhat-template)
- [FHEVM Examples](https://github.com/zama-ai/fhevm/tree/main/examples)
- [Zama Developer Program](https://www.zama.ai/developer-program)
