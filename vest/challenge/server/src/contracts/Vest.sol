// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract Vest {
    ERC20 public token;
    uint256 public constant TOTAL_DURATION = 5 * 5; 
    uint256 public constant CLAIM_INTERVAL = 5;
    uint256 public constant TOTAL_STEPS = TOTAL_DURATION / CLAIM_INTERVAL;
    uint256 public constant FIXED_AMOUNT = 1000 ether;

    struct Vesting {
        uint256 start;
        uint256 totalAmount;
        uint256 claimedAmount;
        address beneficiary;
        uint256 step;
    }

    mapping(uint256 => Vesting) public vestings;
    uint256 public vestingCount;

    event VestingCreated(uint256 indexed vestingId, address indexed beneficiary, uint256 totalAmount);
    event VestingTransferred(uint256 indexed vestingId, address indexed from, address indexed to);
    event Claimed(uint256 indexed vestingId, uint256 amount);

    constructor(ERC20 _token) {
        token = _token;
    }

    modifier onlyBeneficiary(uint256 vestingId) {
        require(vestings[vestingId].beneficiary == msg.sender, "Not the beneficiary");
        _;
    }

    function createVesting(address beneficiary) external {
        require(beneficiary != address(0), "Invalid beneficiary address");
        require(vestingCount < 10, "Maximum number of vestings reached");

        vestings[vestingCount] = Vesting({
            start: block.timestamp,
            totalAmount: FIXED_AMOUNT,
            claimedAmount: 0,
            beneficiary: beneficiary,
            step: 0
        });
        vestingCount++;

        emit VestingCreated(vestingCount, beneficiary, FIXED_AMOUNT);
    }

    function transferVesting(uint256 vestingId,address newBeneficiary, uint256 amount,uint256 newVestingId) external onlyBeneficiary(vestingId) {
        require(newBeneficiary != address(0), "New beneficiary is zero address");
        
        address previousBeneficiary = vestings[vestingId].beneficiary;

        vestings[vestingId].totalAmount -= amount;
        vestings[vestingId].step = 0;

        vestings[newVestingId] = Vesting({
            start: block.timestamp,
            totalAmount: amount,
            claimedAmount: 0,
            beneficiary: newBeneficiary,
            step: 0
        });

        emit VestingTransferred(vestingId, previousBeneficiary, newBeneficiary);
    }

    function claimVesting(uint256 vestingId) external onlyBeneficiary(vestingId) {
        Vesting storage vesting = vestings[vestingId];
        uint256 elapsed = block.timestamp - vesting.start;
        
        uint256 totalSteps = TOTAL_STEPS - vesting.step; 
        uint256 availableSteps = elapsed / CLAIM_INTERVAL;

        if (availableSteps > totalSteps) {
            availableSteps = totalSteps;
        }

        uint256 claimableAmount = (vesting.totalAmount * availableSteps) / totalSteps;

        uint256 claimableNow = claimableAmount - vesting.claimedAmount;
        require(claimableNow > 0, "No tokens available for claim at this time");

        vesting.claimedAmount += claimableNow;
        require(token.transfer(vesting.beneficiary, claimableNow), "Token transfer failed");

        emit Claimed(vestingId, claimableNow);
    }

    function vestedAmount(uint256 vestingId) public view returns (uint256) {
        Vesting storage vesting = vestings[vestingId];
        uint256 elapsed = block.timestamp - vesting.start;
        
        uint256 totalSteps = TOTAL_DURATION / CLAIM_INTERVAL;
        uint256 availableSteps = elapsed / CLAIM_INTERVAL;

        if (availableSteps > totalSteps) {
            availableSteps = totalSteps;
        }

        return (vesting.totalAmount * availableSteps) / totalSteps;
    }

    function unclaimedAmount(uint256 vestingId) public view returns (uint256) {
        Vesting storage vesting = vestings[vestingId];
        return vestedAmount(vestingId) - vesting.claimedAmount;
    }
}
