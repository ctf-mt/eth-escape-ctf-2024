pragma solidity ^0.8.25;

import {VestToken} from "./VestToken.sol";
import {Vest} from "./Vest.sol";
contract Setup {
    VestToken public token;
    Vest public vest;

    
    constructor() {
        token = new VestToken();
        vest = new Vest(token);
        token.transfer(address(vest), 50_000 * 10 ** 18);
    }
    function isSolved() public returns (bool) {
        if(token.balanceOf(address(this)) == 50_000 * 10 ** 18) {
            return true;
        }
        return false;
    }
}
