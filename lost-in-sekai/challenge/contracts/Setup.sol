pragma solidity ^0.8.20;

import "./Sekai.sol";

contract Setup {
    Sekai public sekai;

    constructor() {
        sekai = new Sekai();
    }

    function isSolved() public view returns (bool) {
        return sekai.isKeyFound();
    }
}