pragma solidity ^0.8.20;

contract SimpleToken {
    string  public name     = "Simple Token";
    string  public symbol   = "ST";
    uint8   public decimals = 18;
    address public owner;

    mapping (address => uint)                       public  balanceOf;
    mapping (address => mapping (address => uint))  public  allowance;

    uint256 constant SELL_PRICE = 1000;

    function buy() external payable {
        require(msg.value % SELL_PRICE == 0);
        uint amount = msg.value / SELL_PRICE;
        balanceOf[msg.sender] += amount;
    }

    function sell(uint amount) external {
        balanceOf[msg.sender] -= amount;
        // we gonna charge some fees 😈
        payable(msg.sender).transfer(amount);
    }

    function transfer(address dst, uint amount) public returns (bool) {
        return transferFrom(msg.sender, dst, amount);
    }

    function transferFrom(address src, address dst, uint amount) public returns (bool) {
        uint allowanceAmount = allowance[src][msg.sender];
        uint balanceSrc = balanceOf[src];
        uint balanceDst = balanceOf[dst];

        require(balanceSrc >= amount);
        require(allowanceAmount >= amount);

        balanceOf[src] = balanceSrc - amount;
        balanceOf[dst] = balanceDst + amount;
        allowance[src][msg.sender] = allowanceAmount - amount;

        return true;
    }

    function approve(address to, uint amount) public returns (bool) {
        allowance[msg.sender][to] = amount;
        return true;
    }

    function withdraw(uint amount) public {
        require(msg.sender == owner, "Only owner can withdraw");
        require(amount <= address(this).balance);
        payable(owner).transfer(amount);
    }

    // donate
    receive() external payable {}
}
