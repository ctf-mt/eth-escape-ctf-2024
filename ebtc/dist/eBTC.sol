// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;

contract eBTC {
    string public constant name = "eBTC";
    string public constant symbol = "eBTC";
    uint8 public constant decimals = 8;
    
    address public owner;
    address public minter;
    
    uint256 private _totalSupply;
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event MinterChanged(address indexed previousMinter, address indexed newMinter);
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    
    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }
    
    modifier onlyMinter() {
        require(msg.sender == minter || msg.sender == owner, "Not minter");
        _;
    }
    
    constructor() {
        owner = msg.sender;
    }
    
    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }
    
    function balanceOf(address account) public view returns (uint256) {
        return _balances[account];
    }
    
    function transfer(address to, uint256 amount) public returns (bool) {
        _transfer(msg.sender, to, amount);
        return true;
    }
    
    function allowance(address owner_, address spender) public view returns (uint256) {
        return _allowances[owner_][spender];
    }
    
    function approve(address spender, uint256 amount) public returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }
    
    function transferFrom(address from, address to, uint256 amount) public returns (bool) {
        _spendAllowance(from, msg.sender, amount);
        _transfer(from, to, amount);
        return true;
    }
    
    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
        _approve(msg.sender, spender, _allowances[msg.sender][spender] + addedValue);
        return true;
    }
    
    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
        uint256 currentAllowance = _allowances[msg.sender][spender];
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(msg.sender, spender, currentAllowance - subtractedValue);
        }
        return true;
    }
    
    function mint(address to, uint256 amount) public onlyMinter {
        _mint(to, amount);
    }
    
    function burn(uint256 amount) public onlyMinter {
        _burn(msg.sender, amount);
    }
    
    function burnFrom(address account, uint256 amount) public onlyMinter {
        _spendAllowance(account, msg.sender, amount);
        _burn(account, amount);
    }
    
    function setMinter(address newMinter) public onlyOwner {
        emit MinterChanged(minter, newMinter);
        minter = newMinter;
    }
    
    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0), "New owner is zero address");
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }
    
    function _transfer(address from, address to, uint256 amount) internal {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        
        uint256 fromBalance = _balances[from];
        require(fromBalance >= amount, "ERC20: transfer amount exceeds balance");
        
        unchecked {
            _balances[from] = fromBalance - amount;
            _balances[to] += amount;
        }
        
        emit Transfer(from, to, amount);
    }
    
    function _mint(address account, uint256 amount) internal {
        require(account != address(0), "ERC20: mint to the zero address");
        
        _totalSupply += amount;
        unchecked {
            _balances[account] += amount;
        }
        
        emit Transfer(address(0), account, amount);
    }
    
    function _burn(address account, uint256 amount) internal {
        require(account != address(0), "ERC20: burn from the zero address");
        
        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        
        unchecked {
            _balances[account] = accountBalance - amount;
            _totalSupply -= amount;
        }
        
        emit Transfer(account, address(0), amount);
    }
    
    function _approve(address owner_, address spender, uint256 amount) internal {
        require(owner_ != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        
        _allowances[owner_][spender] = amount;
        emit Approval(owner_, spender, amount);
    }
    
    function _spendAllowance(address owner_, address spender, uint256 amount) internal {
        uint256 currentAllowance = allowance(owner_, spender);
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= amount, "ERC20: insufficient allowance");
            unchecked {
                _approve(owner_, spender, currentAllowance - amount);
            }
        }
    }
}