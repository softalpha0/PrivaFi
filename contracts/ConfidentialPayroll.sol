// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {FHE, euint64} from "@fhevm/solidity/lib/FHE.sol";
import {ZamaEthereumConfig} from "@fhevm/solidity/config/ZamaConfig.sol";

contract ConfidentialPayroll is ZamaEthereumConfig {
    struct EmployeeRecord {
        euint64 encryptedSalary;   // FHE encrypted — no one can read this
        uint64 salaryAmount;        // readable only by the employee via getMySalary
        uint256 depositedWei;       // ETH deposited by employer for this employee
        bool exists;
        bool claimed;
    }

    struct PayrollGroup {
        mapping(address => EmployeeRecord) records;
        mapping(address => bool) isEmployee;
        address[] employees;
    }

    mapping(address => PayrollGroup) private payrolls;

    event EmployeeAdded(address indexed employer, address indexed employee);
    event SalarySet(address indexed employer, address indexed employee, uint256 depositedWei);
    event SalaryClaimed(address indexed employer, address indexed employee, uint256 amount);

    // Employer adds employee and sets salary, depositing ETH for them to claim
    function setSalary(address employee, uint64 salary) external payable {
        PayrollGroup storage group = payrolls[msg.sender];

        if (!group.isEmployee[employee]) {
            group.isEmployee[employee] = true;
            group.employees.push(employee);
            emit EmployeeAdded(msg.sender, employee);
        }

        // Store FHE encrypted salary
        euint64 encSalary = FHE.asEuint64(salary);
        FHE.allowThis(encSalary);
        FHE.allow(encSalary, employee);
        FHE.allow(encSalary, msg.sender);

        group.records[employee].encryptedSalary = encSalary;
        group.records[employee].salaryAmount = salary;
        group.records[employee].depositedWei += msg.value;
        group.records[employee].exists = true;
        group.records[employee].claimed = false;

        emit SalarySet(msg.sender, employee, msg.value);
    }

    // Employee views their own salary amount
    function getMySalary(address employer) external view returns (uint64) {
        require(payrolls[employer].records[msg.sender].exists, "No salary record found");
        return payrolls[employer].records[msg.sender].salaryAmount;
    }

    // Employee claims their deposited ETH salary
    function claimSalary(address employer) external {
        EmployeeRecord storage record = payrolls[employer].records[msg.sender];
        require(record.exists, "No salary record found");
        require(record.depositedWei > 0, "No funds deposited by employer");
        require(!record.claimed, "Already claimed");

        uint256 amount = record.depositedWei;
        record.claimed = true;
        record.depositedWei = 0;

        (bool success, ) = payable(msg.sender).call{value: amount}("");
        require(success, "Transfer failed");

        emit SalaryClaimed(employer, msg.sender, amount);
    }

    // Check claimable balance
    function getClaimableAmount(address employer, address employee) external view returns (uint256) {
        return payrolls[employer].records[employee].depositedWei;
    }

    function getSalary(address employer, address employee) external view returns (euint64) {
        return payrolls[employer].records[employee].encryptedSalary;
    }

    function isEmployee(address employer, address employee) external view returns (bool) {
        return payrolls[employer].isEmployee[employee];
    }

    function getEmployeeCount(address employer) external view returns (uint256) {
        return payrolls[employer].employees.length;
    }
}
