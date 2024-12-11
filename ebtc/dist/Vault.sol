// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

interface IMintableContract is IERC20 {
    function mint(address account, uint256 amount) external;
    function burn(uint256 amount) external;
    function burnFrom(address account, uint256 amount) external;
}

interface ISupplyFeeder {
    function totalSupply(address token) external view returns(uint256);
}

contract Vault {
    address public owner;
    address public operator;
    address public eBTC;
    mapping(address => uint256) public caps;
    
    address public constant NATIVE_BTC = address(0xbeDFFfFfFFfFfFfFFfFfFFFFfFFfFFffffFFFFFF);
    uint8 public constant NATIVE_BTC_DECIMALS = 18;
    uint256 public constant EXCHANGE_RATE_BASE = 1e10;
    
    address public supplyTracker;
    
    // Events
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    event OperatorChanged(address indexed previousOperator, address indexed newOperator);
    event Minted(address token, uint256 amount);
    
    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }
    
    modifier onlyOperator() {
        require(msg.sender == operator, "Not operator");
        _;
    }
    
    receive() external payable {}
    
    constructor(address _owner, address _eBTC) {
        owner = _owner;
        eBTC = _eBTC;
    }
    
    function transferOwnership(address newOwner) external onlyOwner {
        require(newOwner != address(0), "New owner is zero address");
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }
    
    function setOperator(address newOperator) external onlyOwner {
        emit OperatorChanged(operator, newOperator);
        operator = newOperator;
    }
    
    // Safe ERC20 transfer function
    function safeTransfer(address token, address to, uint256 value) internal {
        (bool success, bytes memory data) = token.call(
            abi.encodeWithSelector(IERC20.transfer.selector, to, value)
        );
        require(success && (data.length == 0 || abi.decode(data, (bool))), 
            "SafeERC20: transfer failed"
        );
    }
    
    function safeTransferFrom(address token, address from, address to, uint256 value) internal {
        (bool success, bytes memory data) = token.call(
            abi.encodeWithSelector(IERC20.transferFrom.selector, from, to, value)
        );
        require(success && (data.length == 0 || abi.decode(data, (bool))), 
            "SafeERC20: transferFrom failed"
        );
    }
    
    // Main contract functions
    function mint() external payable {
        _mint(msg.sender, msg.value);
    }
    
    function mint(address _token, uint256 _amount) external {
        _mint(msg.sender, _token, _amount);
    }
    
    function setCap(address _token, uint256 _cap) external onlyOwner {
        require(_token != address(0x0), "SYS003");
        
        uint8 decs = NATIVE_BTC_DECIMALS;
        if (_token != NATIVE_BTC) {
            (bool success, bytes memory data) = _token.call(abi.encodeWithSelector(0x313ce567)); // decimals()
            require(success && data.length >= 32, "Failed to get decimals");
            decs = uint8(abi.decode(data, (uint256)));
        }
        
        require(decs == 8 || decs == 18, "SYS004");
        caps[_token] = _cap;
    }
    
    function setSupplyTracker(address _supplyTracker) external onlyOwner {
        supplyTracker = _supplyTracker;
    }

    function _mint(address _sender, uint256 _amount) internal {
        (, uint256 eBTCAmount) = _amounts(_amount);
        require(eBTCAmount > 0, "USR010");
        
        uint256 totalSupply = ISupplyFeeder(supplyTracker).totalSupply(NATIVE_BTC);
        require(totalSupply <= caps[NATIVE_BTC], "USR003");
        
        IMintableContract(eBTC).mint(_sender, eBTCAmount);
        emit Minted(NATIVE_BTC, _amount);
    }
    
    function _mint(address _sender, address _token, uint256 _amount) internal {
        (, uint256 eBTCAmount) = _amounts(_token, _amount);
        require(eBTCAmount > 0, "USR010");
        
        uint256 totalSupply = ISupplyFeeder(supplyTracker).totalSupply(_token);
        require(totalSupply + _amount <= caps[_token], "USR003");
        
        safeTransferFrom(_token, _sender, address(this), _amount);
        IMintableContract(eBTC).mint(_sender, eBTCAmount);
        
        emit Minted(_token, _amount);
    }
    
    function _amounts(uint256 _amount) internal pure returns (uint256, uint256) {
        uint256 eBTCAmt = _amount / EXCHANGE_RATE_BASE;
        return (eBTCAmt * EXCHANGE_RATE_BASE, eBTCAmt);
    }
    
    function _amounts(address _token, uint256 _amount) internal returns (uint256, uint256) {
        (bool success, bytes memory data) = _token.call(abi.encodeWithSignature("decimals()"));
        require(success && data.length >= 32, "Failed to get decimals");
        uint8 decs = uint8(abi.decode(data, (uint256)));
        
        if (decs == 8) return (_amount, _amount);
        if (decs == 18) {
            uint256 eBTCAmt = _amount / EXCHANGE_RATE_BASE;
            return (eBTCAmt * EXCHANGE_RATE_BASE, eBTCAmt);
        }
        return (0, 0);
    }
}