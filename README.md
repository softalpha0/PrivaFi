# PrivaFi

**The first confidential DeFi suite where your financial data stays encrypted — on-chain, always.**

---

## The Story

DeFi promised to democratize finance. Open, permissionless, and accessible to anyone. But it came with a trade-off nobody talks about enough: everything is public.

Your wallet balance. Your transaction history. Your salary. Your portfolio size. Anyone with a browser and a blockchain explorer can see it all — in real time, forever.

This is not a bug. It is how blockchains work. Transparency is the foundation of trustlessness. But it creates a real problem: financial privacy is impossible.

Traditional finance solved privacy by being closed. Banks hold your data, control access, and act as gatekeepers. DeFi solved trust by being open. But open means exposed.

There has been no middle ground — until now.

PrivaFi is built on a simple idea: **you should be able to prove financial facts without revealing financial data.**

Prove you qualify for a loan — without showing your balance.
Receive your salary — without your colleagues knowing what you earn.
Demonstrate your portfolio meets a threshold — without disclosing a single number.

That is what PrivaFi does. And it does it entirely on-chain.

---

## The Technology

PrivaFi is powered by **Fully Homomorphic Encryption (FHE)** via the **Zama FHEVM protocol**.

FHE is a form of encryption that allows computation to happen directly on encrypted data — without ever decrypting it. The result of the computation is also encrypted, and only the authorized party can read it.

In simple terms: the blockchain can do math on your private numbers without seeing them.

This is not a workaround. It is not a layer-2 trick or a trusted intermediary. The computation happens inside the smart contract, on ciphertext, using cryptographic operations that are mathematically proven to preserve privacy.

### How Zama FHEVM Makes This Possible

Zama's FHEVM library brings FHE natively to Solidity. Smart contracts can work with encrypted integer types — `euint64`, `euint32`, `ebool` — the same way they work with regular integers, but the values are never plaintext on-chain.

PrivaFi uses the following FHE operations across its three contracts:

| Operation | What It Does |
|---|---|
| `FHE.asEuint64(value)` | Takes a value and stores it as an encrypted integer on-chain |
| `FHE.gt(a, b)` | Compares two encrypted integers — returns an encrypted boolean |
| `FHE.and(a, b)` | Combines two encrypted booleans with AND logic |
| `FHE.add(a, b)` | Adds two encrypted integers together |
| `FHE.allowThis(value)` | Grants the contract the right to use an encrypted value |
| `FHE.allow(value, address)` | Grants a specific wallet the right to decrypt a value |

The result: financial logic runs on-chain, but the underlying numbers stay private. Only the people who are supposed to see a result can decrypt it.

---

## The Three Modules

### Private Credit Score

**The problem:** DeFi lending protocols require overcollateralization because they cannot verify creditworthiness without seeing your wallet history. If they could see your history, everyone else could too.

**What PrivaFi does:** You submit your wallet balance and transaction count. The contract encrypts both values on-chain using `FHE.asEuint64()`. It then runs a comparison against qualification thresholds using encrypted comparison operators. The output is a single pass/fail result — your actual figures are never stored in plaintext, never emitted in an event, never readable on-chain.

A lender gets the answer they need. You keep your data.

---

### Confidential Payroll

**The problem:** Paying contributors or employees on-chain means publishing salaries to the world. Every wallet, every amount, every payment — permanently public. This makes on-chain payroll impractical for real organizations.

**What PrivaFi does:** An employer registers employees and sets each salary as an encrypted `euint64` value. Using `FHE.allow()`, each salary is cryptographically gated so only the assigned employee can decrypt their own pay. The employer can verify the total payroll using encrypted addition. No one else — not other employees, not auditors, not block explorers — can read any individual figure.

---

### Hidden Portfolio Tracker

**The problem:** Institutional DeFi requires participants to prove they meet certain financial thresholds — minimum holdings, collateral requirements, accreditation standards. Today this means revealing your entire portfolio to a counterparty or a protocol.

**What PrivaFi does:** You register an encrypted portfolio balance on-chain. When you need to prove you meet a threshold, the contract runs a comparison inside FHE and returns only a boolean — yes or no. The threshold itself can also be encrypted. Your actual balance is never revealed. The proof is verifiable on-chain by anyone, but the underlying data remains yours.

---

## Architecture

```
privafi/                          # Smart contracts
├── contracts/
│   ├── PrivateCreditScore.sol    # Credit eligibility via FHE comparison
│   ├── ConfidentialPayroll.sol   # Per-employee encrypted salary management
│   └── HiddenPortfolio.sol      # Encrypted balance with threshold proof
├── deploy/
│   └── deploy.ts                 # Hardhat deployment script
└── hardhat.config.ts

privafi-frontend/                 # React frontend
├── src/
│   ├── components/
│   │   ├── Landing.tsx           # Project landing page
│   │   ├── CreditScore.tsx       # Credit score module UI
│   │   ├── Payroll.tsx           # Payroll module UI
│   │   └── Portfolio.tsx         # Portfolio module UI
│   └── contracts/
│       ├── addresses.ts          # Deployed contract addresses and ABIs
│       └── wallet.ts             # MetaMask connection handler
```

---

## Deployed Contracts (Sepolia Testnet)

All contracts are verified and publicly readable on Etherscan.

| Contract | Address | Verified Source |
|---|---|---|
| PrivateCreditScore | `0xaa7D007ede04C1c52D7cc95A8357813c394f3af6` | [Etherscan](https://sepolia.etherscan.io/address/0xaa7D007ede04C1c52D7cc95A8357813c394f3af6#code) |
| ConfidentialPayroll | `0xEcf5cD342AcEb87203022F8b3B83ea5CEA7CD659` | [Etherscan](https://sepolia.etherscan.io/address/0xEcf5cD342AcEb87203022F8b3B83ea5CEA7CD659#code) |
| HiddenPortfolio | `0x4708F4c5Afc818B9cF42c1652666aC67034866ae` | [Etherscan](https://sepolia.etherscan.io/address/0x4708F4c5Afc818B9cF42c1652666aC67034866ae#code) |

---

## Running Locally

### Requirements
- Node.js 20+
- MetaMask browser extension
- Sepolia testnet configured in MetaMask
- Free Sepolia ETH — https://cloud.google.com/application/web3/faucet/ethereum/sepolia

### Smart Contracts

```bash
git clone https://github.com/softalpha0/PrivaFi.git
cd PrivaFi
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

Open http://localhost:5173 and connect MetaMask on Sepolia.

---

## How to Use

1. Open the app and click **Launch App**
2. Connect your MetaMask wallet — the app will prompt you to switch to Sepolia if needed
3. Choose a module from the navigation

**Credit Score**
Enter a wallet balance and transaction count. Click Check Eligibility. Confirm the MetaMask transaction. The contract evaluates your data using FHE and returns a result.

**Payroll**
In Employer View, paste an employee wallet address and enter a salary. The contract encrypts the salary on-chain and gates it to that address only.
In Employee View, enter the employer address to retrieve your encrypted salary record.

**Portfolio**
Register your portfolio balance — it is stored encrypted on-chain. Then enter any threshold and generate a proof. The result tells you whether you qualify, without revealing your balance.

---

## Stack

- **Solidity 0.8.27** — smart contract language
- **Zama FHEVM** (`@fhevm/solidity`) — on-chain FHE operations
- **Hardhat** — compilation, testing, deployment
- **React 19 + TypeScript** — frontend
- **Vite** — frontend build tool
- **ethers.js v6** — blockchain interaction
- **Sepolia testnet** — deployment network

---

## Resources

- [Zama FHEVM Documentation](https://docs.zama.ai/fhevm)
- [fhevm-hardhat-template](https://github.com/zama-ai/fhevm-hardhat-template)
- [FHEVM Contract Examples](https://github.com/zama-ai/fhevm/tree/main/examples)
- [Zama Developer Program](https://www.zama.ai/developer-program)
