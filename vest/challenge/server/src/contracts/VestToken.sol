pragma solidity ^0.8.25;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract VestToken is ERC20 {
    constructor() ERC20("VestToken", "VTK") {
        _mint(msg.sender, 50_000 * 10 ** 18);
    }
}