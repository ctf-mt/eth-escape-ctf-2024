pragma solidity ^0.8.25;

import {FeelToken} from "./FeelToken.sol";
import {StorageSlot} from "@openzeppelin/contracts/utils/StorageSlot.sol";
contract Feel {

    enum Status {
        Locked,
        Unlocked
    }

    struct Milestone {
        uint256 id;
        uint256 amount;
        uint256 unlockTime;
        address recipient;
        string note;
        Status status;
    }

    uint256 constant MILESTONES_SLOT_KEY = 1;

    FeelToken public token;
    mapping(uint256 => Milestone) public milestones;
    uint256 milestoneCount;
    
    constructor(FeelToken _token) {
        token = _token;
    }

    function addMilestone(uint256 id, string calldata note) public {
        require(milestones[id].id == 0, "Feel: milestone id already exists");
        require(id > 0, "Feel: milestone id must be greater than 0");
        require(milestoneCount < 10, "Feel: maximum 10 milestones allowed");

        milestones[id] = Milestone(id, 1 ether, block.timestamp + 5 minutes, msg.sender, note, Status.Locked);
        milestoneCount++;

    }

    function unlockMilestone(uint256 id) public {
        Milestone storage milestone = milestones[id];
        require(milestone.status == Status.Locked, "Feel: milestone is already unlocked");
        require(block.timestamp >= milestone.unlockTime, "Feel: milestone is not unlocked yet");
        milestone.status = Status.Unlocked;
    }

    function editNote(uint256 id, string calldata note) public {
        Milestone storage milestone = milestones[id];
        require(milestone.status == Status.Locked, "Feel: milestone is already unlocked");
        require(milestone.recipient == msg.sender, "Feel: only recipient can edit note");
        milestone.note = note;
    }

    function editRecipient(uint256 id, address recipient) public {
        Milestone storage milestone = milestones[id];
        require(milestone.status == Status.Locked, "Feel: milestone is already unlocked");
        require(milestone.recipient == msg.sender, "Feel: only recipient can edit recipient");
        milestone.recipient = recipient;
    }

    function claimMilestone(uint256 id) public {
        Milestone storage milestone = milestones[id];
        require(milestone.status == Status.Unlocked, "Feel: milestone is locked");
        uint256 milestones_slot_key = uint256(keccak256(abi.encode(id, MILESTONES_SLOT_KEY)));
        bytes32 note_key = bytes32(milestones_slot_key + 4);
        uint256 string_length = StorageSlot.getUint256Slot(note_key).value;
        bytes memory note_bytes;
        if (string_length & 0x1 == 0) {
            uint256 length = (string_length&0xff) >> 1;
            bytes32 note_bytes32 = StorageSlot.getBytes32Slot(note_key).value;
            note_bytes = abi.encodePacked(note_bytes32);
        } else {
            uint256 length = (string_length >> 1) -1;
            uint256 extra_slots = (length + 31) >> 5;
            uint256 extra_slots_start = uint256(keccak256(abi.encode(note_key)));
            note_bytes;
            for (uint256 i = 0; i < extra_slots; i++) {
                note_bytes = abi.encodePacked(note_bytes, StorageSlot.getBytes32Slot(bytes32(extra_slots_start + i)).value);
            }
        }
        require(findClaimString(note_bytes) == false, "Feel: milestone is already claimed");
        milestone.note = string(abi.encodePacked(milestone.note, " [CLAIMED]"));
        token.transfer(milestone.recipient, milestone.amount);
        milestoneCount -= 1;
    }

    function findClaimString(bytes memory note_bytes) pure public returns (bool) {
        bytes memory claim_bytes = bytes(" [CLAIMED]");
        uint256 note_length = note_bytes.length;
        uint256 claim_length = claim_bytes.length;
        if (note_length < claim_length) {
            return false;
        }
        for (uint256 i = 0; i < note_length - claim_length + 1; i++) {
            bool found = true;
            for (uint256 j = 0; j < claim_length; j++) {
                if (note_bytes[i + j] != claim_bytes[j]) {
                    found = false;
                    break;
                }
            }
            if (found) {
                return true;
            }
        }
        return false;
    }

    function getTime() view public returns (uint256) {
        return block.timestamp;
    }
}
