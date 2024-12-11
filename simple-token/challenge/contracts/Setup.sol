pragma solidity ^0.8.20;

import "./SimpleToken.sol";

contract Setup {
    SimpleToken public token;

    constructor() payable {
        token = new SimpleToken();

        require(msg.value == 1000);
        (bool success,) = address(token).call{value: 1000}("");
        require(success);
    }

    function isSolved() external view returns (bool) {
        return address(token).balance == 0;
    }
}