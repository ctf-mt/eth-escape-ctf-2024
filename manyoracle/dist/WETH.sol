// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

contract WETH {
    string public name = "Wrapped Ether";
    string public symbol;
    uint8 public decimals = 18;
    mapping(address => uint) public balanceOf;
    mapping(address => mapping(address => uint)) public allowance;
    
    event Transfer(address indexed from, address indexed to, uint value);
    event Approval(address indexed owner, address indexed spender, uint value);
    
    constructor(string memory _symbol) {
        symbol = _symbol;
    }
    
    receive() external payable {
        deposit();
    }
    
    function deposit() public payable {
        balanceOf[msg.sender] += msg.value;
        emit Transfer(address(0), msg.sender, msg.value);
    }
    
    function withdraw(uint amount) external {
        require(balanceOf[msg.sender] >= amount);
        balanceOf[msg.sender] -= amount;
        payable(msg.sender).transfer(amount);
        emit Transfer(msg.sender, address(0), amount);
    }
    
    function approve(address spender, uint amount) external returns (bool) {
        allowance[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }
    
    function transfer(address to, uint amount) external returns (bool) {
        return transferFrom(msg.sender, to, amount);
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