// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

interface IERC20 {
    function transfer(address to, uint256 amount) external returns (bool);
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
}

interface IFlashCallback {
    function flashCallback(uint256 amount0Out, uint256 amount1Out, bytes calldata data) external;
}

contract Pair {
    IERC20 public immutable token0;
    IERC20 public immutable token1;
    
    uint256 public reserve0;
    uint256 public reserve1;
    
    constructor(address _token0, address _token1) {
        token0 = IERC20(_token0);
        token1 = IERC20(_token1);
    }
    
    function mint(uint256 amount0, uint256 amount1) external {
        token0.transferFrom(msg.sender, address(this), amount0);
        token1.transferFrom(msg.sender, address(this), amount1);
        reserve0 = amount0;
        reserve1 = amount1;
    }
    
    function swap(uint256 amount0Out, uint256 amount1Out, address to, bytes calldata data) external {
        require(amount0Out > 0 || amount1Out > 0, "Invalid output amount");
        require(amount0Out < reserve0 && amount1Out < reserve1, "Insufficient liquidity");

        // Cache reserves and update them before the swap
        uint256 _reserve0 = reserve0;
        uint256 _reserve1 = reserve1;
        
        if(amount0Out > 0) {
            token0.transfer(to, amount0Out);
            reserve0 = _reserve0 - amount0Out;
        }
        if(amount1Out > 0) {
            token1.transfer(to, amount1Out);
            reserve1 = _reserve1 - amount1Out;
        }

        if(data.length > 0) {
            IFlashCallback(to).flashCallback(amount0Out, amount1Out, data);
        }

        // Verify k
        uint256 balance0 = token0.balanceOf(address(this));
        uint256 balance1 = token1.balanceOf(address(this));
        
        require(balance0 * balance1 >= _reserve0 * _reserve1, "K");
        
        reserve0 = balance0;
        reserve1 = balance1;
    }
    
    function getReserves() public view returns (uint256, uint256) {
        return (reserve0, reserve1);
    }
    
    function getCurrentPrice() public view returns (uint256) {
        return (reserve0 * 1e18) / reserve1;
    }
}