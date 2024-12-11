pragma solidity ^0.8.20;

contract Setup {
    bool public isSolved;
    
    bytes32 public secret_hash;

    constructor(uint256 secret) {
        secret_hash = keccak256(abi.encodePacked(block.number, secret, msg.sender));
    }

    function authenticate(uint bn, uint secret, address owner) external {
        bytes32 h = keccak256(abi.encodePacked(bn, secret, owner));
        require(h == secret_hash, "Invalid");
        isSolved = true;
    }
}