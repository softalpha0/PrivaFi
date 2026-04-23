// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {FHE, euint64, euint32, ebool} from "@fhevm/solidity/lib/FHE.sol";
import {ZamaEthereumConfig} from "@fhevm/solidity/config/ZamaConfig.sol";

contract PrivateCreditScore is ZamaEthereumConfig {
    uint64 public constant MIN_BALANCE = 1000;
    uint32 public constant MIN_TX_COUNT = 10;

    struct CreditProfile {
        euint64 encryptedBalance;
        euint32 encryptedTxCount;
        ebool eligible;
        bool exists;
    }

    mapping(address => CreditProfile) private profiles;
    event ProfileSubmitted(address indexed user);

    function submitCreditData(uint64 balance, uint32 txCount) external {
        euint64 encBalance = FHE.asEuint64(balance);
        euint32 encTxCount = FHE.asEuint32(txCount);

        ebool balanceOk = FHE.gt(encBalance, FHE.asEuint64(MIN_BALANCE));
        ebool txOk = FHE.gt(encTxCount, FHE.asEuint32(MIN_TX_COUNT));
        ebool eligible = FHE.and(balanceOk, txOk);

        FHE.allowThis(encBalance);
        FHE.allowThis(encTxCount);
        FHE.allowThis(eligible);
        FHE.allow(encBalance, msg.sender);
        FHE.allow(encTxCount, msg.sender);
        FHE.allow(eligible, msg.sender);

        profiles[msg.sender] = CreditProfile(encBalance, encTxCount, eligible, true);
        emit ProfileSubmitted(msg.sender);
    }

    function getMyEligibility() external view returns (ebool) {
        require(profiles[msg.sender].exists, "No profile found");
        return profiles[msg.sender].eligible;
    }

    function hasProfile(address user) external view returns (bool) {
        return profiles[user].exists;
    }
}
