pragma solidity ^0.8.25;

contract Setup {
    bool private solved;
    string public s3cr3t_s3cr3t = "sup3r_s3cr3t_s3cr3t";
    uint256[] public passwords = [0x1111, 0x1338, 0xdeed, 0xb357, 0xcafe];

    function level1() public pure returns (string memory) {
        // Level 1: Introduction
        return "Level 1: Welcome! To proceed, call the level2 function with the password 0x1337. (function level2(uint256 password))";
    }

    function level2(uint256 password) public pure returns (string memory) {
        // Level 2: Password check
        if (password == 0x1337) {
            return "Level 2: Correct! Now, send exactly 0.02 Ether when calling level3(). (function level3())";
        } else {
            return "Wrong!";
        }
    }

    function level3() public payable returns (string memory) {
        // Level 3: Ether transfer check
        if (msg.value == 0.02 ether) {
            return "Level 3: Well done! For Level 4, in this contract, there is a string storage variable named s3cr3t_s3cr3t. Call the level4 function with the value of s3cr3t_s3cr3t. (function level4(string memory secret))";
        } else {
            return "Wrong!";
        }
    }

    function level4(string memory secret) public view returns (string memory) {
        // Level 4: Secret word check
        if (keccak256(abi.encodePacked(secret)) == keccak256(abi.encodePacked(s3cr3t_s3cr3t))) {
            return "Level 4: Great job! For the final Level 5, in this contract, there is a uint256 storage array named passwords. Call the level5 function with the value of passwords[4]. level5 function will change the `solved` storage variable (function level5(uint256 password))";
        } else {
            return "Wrong!";
        }
    }

    function level5(uint256 password) public returns (string memory) {
        if (password == passwords[4]) {
            solved = true;
            return "Congratulations! You have completed the challenge! Now isSolved() function will return true.";
        } else {
            revert("Wrong!");
        }
    }

    function isSolved() public view returns (bool) {
        return solved;
    }
}
