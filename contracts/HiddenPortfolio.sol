// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {FHE, euint64, ebool} from "@fhevm/solidity/lib/FHE.sol";
import {ZamaEthereumConfig} from "@fhevm/solidity/config/ZamaConfig.sol";

contract HiddenPortfolio is ZamaEthereumConfig {
    mapping(address => euint64) private portfolios;
    mapping(address => bool) public hasPortfolio;

    event PortfolioRegistered(address indexed user);
    event PortfolioUpdated(address indexed user);
    event ThresholdProofGenerated(address indexed user);

    function registerPortfolio(uint64 balance) external {
        require(!hasPortfolio[msg.sender], "Already registered");
        euint64 encBalance = FHE.asEuint64(balance);
        FHE.allowThis(encBalance);
        FHE.allow(encBalance, msg.sender);
        portfolios[msg.sender] = encBalance;
        hasPortfolio[msg.sender] = true;
        emit PortfolioRegistered(msg.sender);
    }

    function updatePortfolio(uint64 balance) external {
        require(hasPortfolio[msg.sender], "No portfolio found");
        euint64 encBalance = FHE.asEuint64(balance);
        FHE.allowThis(encBalance);
        FHE.allow(encBalance, msg.sender);
        portfolios[msg.sender] = encBalance;
        emit PortfolioUpdated(msg.sender);
    }

    function proveAboveThreshold(uint64 threshold) external returns (ebool) {
        require(hasPortfolio[msg.sender], "No portfolio found");
        euint64 encThreshold = FHE.asEuint64(threshold);
        ebool result = FHE.gt(portfolios[msg.sender], encThreshold);
        FHE.allow(result, msg.sender);
        emit ThresholdProofGenerated(msg.sender);
        return result;
    }

    function getMyPortfolio() external view returns (euint64) {
        require(hasPortfolio[msg.sender], "No portfolio found");
        return portfolios[msg.sender];
    }
}
