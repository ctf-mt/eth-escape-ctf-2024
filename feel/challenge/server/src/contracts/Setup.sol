pragma solidity ^0.8.25;

import {Feel} from "./Feel.sol";
import {FeelToken} from "./FeelToken.sol";
contract Setup {

    Feel public feel;
    FeelToken public token;
    constructor() {
        token = new FeelToken();
        feel = new Feel(token);
        token.transfer(address(feel), token.MAX_SUPPLY());
    }
    function isSolved() public returns (bool) {
        if(token.balanceOf(address(this)) == token.MAX_SUPPLY()) {
            return true;
        }
        return false;
    }
}
