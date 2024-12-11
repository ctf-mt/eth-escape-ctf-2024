pragma solidity ^0.8.25;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract FeelToken is ERC20 {

    uint256 constant public MAX_SUPPLY = 20 * 10 ** 18;
    constructor() ERC20("FeelToken", "FEL") {
        _mint(msg.sender, MAX_SUPPLY);
    }
}
