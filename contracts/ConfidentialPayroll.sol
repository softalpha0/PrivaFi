// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {FHE, euint64} from "@fhevm/solidity/lib/FHE.sol";
import {ZamaEthereumConfig} from "@fhevm/solidity/config/ZamaConfig.sol";

contract ConfidentialPayroll is ZamaEthereumConfig {
    struct PayrollGroup {
        mapping(address => euint64) salaries;
        mapping(address => bool) isEmployee;
        address[] employees;
    }

    mapping(address => PayrollGroup) private payrolls;

    event EmployeeAdded(address indexed employer, address indexed employee);
    event SalarySet(address indexed employer, address indexed employee);

    function addEmployee(address employee) external {
        require(!payrolls[msg.sender].isEmployee[employee], "Already employee");
        payrolls[msg.sender].isEmployee[employee] = true;
        payrolls[msg.sender].employees.push(employee);
        emit EmployeeAdded(msg.sender, employee);
    }

    function setSalary(address employee, uint64 salary) external {
        require(payrolls[msg.sender].isEmployee[employee], "Not an employee");
        euint64 encSalary = FHE.asEuint64(salary);
        FHE.allowThis(encSalary);
        FHE.allow(encSalary, employee);
        FHE.allow(encSalary, msg.sender);
        payrolls[msg.sender].salaries[employee] = encSalary;
        emit SalarySet(msg.sender, employee);
    }

    function getSalary(address employer, address employee) external view returns (euint64) {
        return payrolls[employer].salaries[employee];
    }

    function isEmployee(address employer, address employee) external view returns (bool) {
        return payrolls[employer].isEmployee[employee];
    }

    function getEmployeeCount(address employer) external view returns (uint256) {
        return payrolls[employer].employees.length;
    }
}
