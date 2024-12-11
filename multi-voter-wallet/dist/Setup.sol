pragma solidity 0.8.28;

import { MultiVoterWallet } from "./MultiVoterWallet.sol";

contract Setup {
    bool public isSolved;

    MultiVoterWallet public wallet;

    constructor(address player) {
        wallet = new MultiVoterWallet();
        wallet.mint(address(this), 1e4);
        wallet.mint(player, 100);
    }

    function solve() external {
        require(msg.sender == address(wallet));
        isSolved = true;
    }
}