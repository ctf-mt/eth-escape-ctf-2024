// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;

contract SupplyTracker {
    mapping(address => uint256) public totalSupply;

    function updateSupply(address token, uint256 amount) public {
        totalSupply[token] = amount;
    }
}