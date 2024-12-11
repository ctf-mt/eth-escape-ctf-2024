// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

interface Setup {
    function s3cr3t_s3cr3t() external view returns (string memory);
    function passwords(uint256 index) external view returns (uint256);
    function level1() external pure returns (string memory);
    function level2(uint256 password) external pure returns (string memory);
    function level3() external payable returns (string memory);
    function level4(string memory secret) external view returns (string memory);
    function level5(uint256 password) external returns (string memory);
    function isSolved() external view returns (bool);
}