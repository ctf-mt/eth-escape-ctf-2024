pragma solidity ^0.8.20;

contract Sekai {
    uint constant isekai = 0xdead;

    bool public isKeyFound;
    mapping (uint => bytes32) keys;

    constructor() {
        keys[isekai] = keccak256(
            abi.encodePacked(block.number, msg.sender)
        );
    }

    function unlockSekai(uint slot) external {
        bytes32 key;
        assembly {
            key := sload(slot)
        }
        require(key == keys[isekai]);
        isKeyFound = true;
    }
}