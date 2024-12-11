// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

interface IPair {
    function getCurrentPrice() external view returns (uint256);
}

contract Minter {
    string public constant name = "Minter Token";
    string public constant symbol = "MTK";
    uint8 public constant decimals = 18;
    
    mapping(address => uint) public balanceOf;
    mapping(address => mapping(address => uint)) public allowance;
    
    IPair public pair1;
    IPair public pair2;
    address public owner;
    
    event Transfer(address indexed from, address indexed to, uint value);
    event Approval(address indexed owner, address indexed spender, uint value);
    
    constructor() {
        owner = msg.sender;
    }

    function setPairs(address _pair1, address _pair2) external {
        require(msg.sender == owner);
        pair1 = IPair(_pair1);
        pair2 = IPair(_pair2);
    }
    
    function ownerMint(uint256 amount) external {
        require(msg.sender == owner);
        _mint(msg.sender, amount);
    }

    function mint() external payable {
        require(msg.value > 0, "Must send ETH");
        
        uint256 price1 = pair1.getCurrentPrice();
        uint256 price2 = pair2.getCurrentPrice();
        
        uint256 mintAmount = (price1 * price2 * msg.value) / (1e36);
        
        _mint(msg.sender, mintAmount);
    }
    
    function _mint(address to, uint256 amount) internal {
        balanceOf[to] += amount;
        emit Transfer(address(0), to, amount);
    }
    
    function transfer(address to, uint amount) external returns (bool) {
        return transferFrom(msg.sender, to, amount);
    }
    
    function approve(address spender, uint amount) external returns (bool) {
        allowance[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }
    
    function transferFrom(address from, address to, uint amount) public returns (bool) {
        require(balanceOf[from] >= amount);
        
        if(from != msg.sender && allowance[from][msg.sender] != type(uint).max) {
            require(allowance[from][msg.sender] >= amount);
            allowance[from][msg.sender] -= amount;
        }
        
        balanceOf[from] -= amount;
        balanceOf[to] += amount;
        
        emit Transfer(from, to, amount);
        return true;
    }
}