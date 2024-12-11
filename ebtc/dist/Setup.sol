// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;

import "./eBTC.sol";
import "./Vault.sol";
import "./SupplyTracker.sol";

interface IUniswapV2Factory {
    event PairCreated(address indexed token0, address indexed token1, address pair, uint);

    function feeTo() external view returns (address);
    function feeToSetter() external view returns (address);

    function getPair(address tokenA, address tokenB) external view returns (address pair);
    function allPairs(uint) external view returns (address pair);
    function allPairsLength() external view returns (uint);

    function createPair(address tokenA, address tokenB) external returns (address pair);

    function setFeeTo(address) external;
    function setFeeToSetter(address) external;
}


interface IUniswapV2Pair {
    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function name() external pure returns (string memory);
    function symbol() external pure returns (string memory);
    function decimals() external pure returns (uint8);
    function totalSupply() external view returns (uint);
    function balanceOf(address owner) external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint value) external returns (bool);
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);

    function DOMAIN_SEPARATOR() external view returns (bytes32);
    function PERMIT_TYPEHASH() external pure returns (bytes32);
    function nonces(address owner) external view returns (uint);

    function permit(address owner, address spender, uint value, uint deadline, uint8 v, bytes32 r, bytes32 s) external;

    event Mint(address indexed sender, uint amount0, uint amount1);
    event Burn(address indexed sender, uint amount0, uint amount1, address indexed to);
    event Swap(
        address indexed sender,
        uint amount0In,
        uint amount1In,
        uint amount0Out,
        uint amount1Out,
        address indexed to
    );
    event Sync(uint112 reserve0, uint112 reserve1);

    function MINIMUM_LIQUIDITY() external pure returns (uint);
    function factory() external view returns (address);
    function token0() external view returns (address);
    function token1() external view returns (address);
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
    function price0CumulativeLast() external view returns (uint);
    function price1CumulativeLast() external view returns (uint);
    function kLast() external view returns (uint);

    function mint(address to) external returns (uint liquidity);
    function burn(address to) external returns (uint amount0, uint amount1);
    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;
    function skim(address to) external;
    function sync() external;

    function initialize(address, address) external;
}

interface IWETH9 is IERC20 {
    /// @notice Deposit ether to get wrapped ether
    function deposit() external payable;

    /// @notice Withdraw wrapped ether to get ether
    function withdraw(uint256) external;
}

contract Setup {
    eBTC public ebtc;
    IWETH9 public weth;
    Vault public vault;
    IUniswapV2Factory public factory;
    IUniswapV2Pair public pair;

    constructor() payable {
        require(msg.value == 565 ether);
        ebtc = new eBTC();
        vault = new Vault(address(this), address(ebtc));
        SupplyTracker supplyTracker = new SupplyTracker();
        vault.setSupplyTracker(address(supplyTracker));

        ebtc.setMinter(address(vault));
        weth = IWETH9(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2);

        factory = IUniswapV2Factory(0x5C69bEe701ef814a2B6a3EDD4B1652CB9cc5aA6f);

        pair = IUniswapV2Pair(factory.createPair(address(ebtc), address(weth)));

        // currently price is 1 BTC == 28.25 ETH
        ebtc.mint(address(this), 20 ether * 10 ** 8);
        weth.deposit{value: 565 ether}();

        ebtc.transfer(address(pair), 20 * 10 ** 8);
        weth.transfer(address(pair), 565 ether);

        pair.mint(address(this));        
    }

    function isSolved() external view returns (bool) {
        return address(this).balance >= 300 ether;
    }

    receive() external payable {}
}