// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./ACLToken.sol";

contract Setup {
    ACLToken public immutable TOKEN;
    uint256 public constant INITIAL_ETH_BALANCE = 5 ether;

    constructor() payable {
        require(msg.value == INITIAL_ETH_BALANCE, "Must send 5 ETH");
        
        TOKEN = new ACLToken{value: INITIAL_ETH_BALANCE}();
    }

    function isSolved() public view returns (bool) {
        return address(TOKEN).balance == 0;
    }
}