// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract ACLToken {
    string public constant name = "Access Control Token";
    string public constant symbol = "ACL";
    uint8 public constant decimals = 18;
    uint256 public totalSupply;

    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;
    mapping(address => bool) public registeredUsers;
    mapping(address => uint256) public hasClaimedTokens;
    
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    
    constructor() payable {
        totalSupply = 1000 * 10**decimals;
        balanceOf[address(this)] = totalSupply;
    }
    
    function register() external {
        require(!registeredUsers[msg.sender], "Already registered");
        
        // The registration check - contract must have no code
        uint256 size;
        address addr = msg.sender;
        assembly {
            size := extcodesize(addr)
        }
        require(size == 0, "Only EOAs can register");
        
        registeredUsers[msg.sender] = true;
        hasClaimedTokens[msg.sender] = block.number + 1;
    }
    
    function claimInitialTokens() external {
        require(registeredUsers[msg.sender], "Must register first");
        require(block.number >= hasClaimedTokens[msg.sender], "Tokens are not available yet");
        
        // Now we check again to make sure that the caller is not a contract
        uint256 size;
        address addr = msg.sender;
        assembly {
            size := extcodesize(addr)
        }
        require(size == 0, "EOA verification failed");
        
        hasClaimedTokens[msg.sender] = type(uint256).max;
        _transfer(address(this), msg.sender, 1 * 10**decimals);
    }

    function transfer(address to, uint256 amount) external returns (bool) {
        require(registeredUsers[msg.sender], "Not registered");
        _transfer(msg.sender, to, amount);
        return true;
    }

    function approve(address spender, uint256 amount) external returns (bool) {
        require(registeredUsers[msg.sender], "Not registered");
        allowance[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function transferFrom(address from, address to, uint256 amount) external returns (bool) {
        require(registeredUsers[msg.sender], "Not registered");
        require(allowance[from][msg.sender] >= amount, "Insufficient allowance");
        allowance[from][msg.sender] -= amount;
        _transfer(from, to, amount);
        return true;
    }
    
    function withdraw(uint256 amount) external {
        require(registeredUsers[msg.sender], "Not registered");
        require(balanceOf[msg.sender] >= amount, "Insufficient balance");
        require(address(this).balance >= amount, "Insufficient ETH in contract");

        uint256 balance = balanceOf[msg.sender];
        
        (bool success,) = msg.sender.call{value: amount}("");
        require(success, "Transfer failed");
        
        balanceOf[msg.sender] = balance - amount;
        emit Transfer(msg.sender, address(0), amount);
    }
    
    function _transfer(address from, address to, uint256 amount) internal {
        require(balanceOf[from] >= amount, "Insufficient balance");
        balanceOf[from] -= amount;
        balanceOf[to] += amount;
        emit Transfer(from, to, amount);
    }
}