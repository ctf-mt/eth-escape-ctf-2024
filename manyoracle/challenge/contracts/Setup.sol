// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import "./WETH.sol";
import "./Pair.sol";
import "./Minter.sol";

contract Setup {
    WETH public immutable weth1;
    WETH public immutable weth2;
    WETH public immutable weth3;
    Pair public immutable pair1;
    Pair public immutable pair2;
    Pair public immutable pair3;
    Minter public immutable minter;
    
    constructor() payable {
        require(msg.value == 300 ether, "Need 300 ETH for setup");
        
        // Deploy WETHs with different symbols
        weth1 = new WETH("WETH1");
        weth2 = new WETH("WETH2");
        
        // Wrap ETH
        weth1.deposit{value: 100 ether}();
        weth2.deposit{value: 100 ether}();
        
        minter = new Minter();

        pair1 = new Pair(address(minter), address(weth1));
        pair2 = new Pair(address(minter), address(weth2));
        
        minter.setPairs(address(pair1), address(pair2));
        
        // Add initial liquidity
        uint256 minterAmount = 1000 ether;
        uint256 wethAmount = 100 ether;

        minter.ownerMint(minterAmount * 2);
        
        // Approve tokens
        weth1.approve(address(pair1), wethAmount);
        weth2.approve(address(pair2), wethAmount);

        minter.approve(address(pair1), minterAmount);
        minter.approve(address(pair2), minterAmount);
        
        // Add liquidity
        pair1.mint(minterAmount, wethAmount);
        pair2.mint(minterAmount, wethAmount);
    }
    
    function isSolved() public view returns (bool) {
        return minter.balanceOf(address(this)) >= 10000 ether;
    }
}