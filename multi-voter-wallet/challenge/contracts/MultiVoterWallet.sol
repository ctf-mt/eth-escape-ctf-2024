pragma solidity 0.8.28;

import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";

interface IVoter {
    function acceptVotes(uint256 amount) external returns (bool);
}

contract MultiVoterWallet is Ownable {
    struct Voter {
        address delegatee;
        address owner;
        bool registered;
        uint256 voteCount;  // The number of votes originally held by the voter
        uint256 validVotes; // The number of votes a voter can cast
    }

    struct Proposal {
        bool finished;
        address proposer;
        uint256 voteStart;
        uint256 votes;
        address target;
        bytes data;
    }

    error ReentracyDetected(address voter);

    uint256 constant DURATION = 2 hours;

    uint256 public totalVotes;
    mapping(address => Voter) public voters;

    Proposal[] public proposals;
    mapping(uint256 => mapping(address => bool)) public voted;

    constructor() Ownable(msg.sender) {}

    function propose(
        address target,
        bytes calldata data
    ) isVoterRegistered(msg.sender) external returns (uint256 proposalId) {
        uint256 length = proposals.length;
        require(length == 0 || proposals[length - 1].finished);
        proposals.push(Proposal({
            finished: false,
            proposer: msg.sender,
            voteStart: block.timestamp,
            votes: 0,
            target: target,
            data: data
        }));

        return proposals.length - 1;
    }

    function vote() isVoterRegistered(msg.sender) external {
        require(proposals.length > 0, "no proposal");
        uint256 proposalId = proposals.length - 1;
        Proposal storage proposal = proposals[proposalId];
        require(!proposal.finished && block.timestamp < proposal.voteStart + DURATION, "proposal is not active");
        require(!voted[proposalId][msg.sender], "already voted");

        voted[proposalId][msg.sender] = true;
        Voter storage voter = getVoter(msg.sender);
        proposal.votes += voter.validVotes;
    }

    function execute() external {
        require(proposals.length > 0, "no proposal");
        uint256 proposalId = proposals.length - 1;
        Proposal storage proposal = proposals[proposalId];
        require(!proposal.finished);
        if (proposal.votes * 2 > totalVotes) {
            (bool success, ) = proposal.target.call(proposal.data);
            require(success);
        } else {
            require(block.timestamp >= proposal.voteStart + DURATION);
        }
        proposal.finished = true;
    }

    function mint(address voter, uint256 amount) external onlyOwner {
        _mint(voter, amount);
    }
    
    function burn(address voter, uint256 amount) external {
        require(msg.sender == voter || msg.sender == owner());
        _burn(voter, amount);
    }

    function delegate(address delegatee) external {
        Voter storage voter = getVoter(msg.sender);
        address oldDelegatee = voter.delegatee == address(0) ? msg.sender : voter.delegatee;
        voter.delegatee = delegatee;
        moveDelegateVotes(
            oldDelegatee,
            delegatee == address(0) ? msg.sender : delegatee,
            voter.voteCount
        );
    }

    modifier isVoterRegistered(address voter) {
        if (!voters[voter].registered) {
            return;
        }
        _;
    }

    modifier notPending() {
        require(!isProposalPending(), "a proposal is pending");
        _;
    }

    modifier perVoterReentrancy(Voter storage voterInfo) {
        beforeNonReentrant(voterInfo);
        _;
        afterNonReentrant(voterInfo);
    }

    function beforeNonReentrant(Voter storage voterInfo) private {
        address voter = voterInfo.owner;
        if (tload(keccak256(abi.encode(voter))) == 1) {
            revert ReentracyDetected(voter);
        }
        tstore(keccak256(abi.encode(voter)), 1);
    }

    function afterNonReentrant(Voter storage voterInfo) private {
        tstore(keccak256(abi.encode(voterInfo.owner)), 0);
    }

    function isProposalPending() internal view returns (bool) {
        uint256 length = proposals.length;
        if (length == 0) {
            return false;
        }
        Proposal storage proposal = proposals[length - 1];
        return !proposal.finished;
    }

    function _mint(address voter, uint256 amount)
        notPending
        perVoterReentrancy(getVoter(voter))
        internal
    {
        Voter storage voterInfo = voters[voter];
        voterInfo.voteCount += amount;
        if (voterInfo.delegatee != address(0)) {
            Voter storage delegatee = getVoter(voterInfo.delegatee);
            delegatee.validVotes += amount;
        } else {
            voterInfo.validVotes += amount;
        }
        totalVotes += amount;
        if (!voterInfo.registered) {
            voterInfo.registered = true;
            voterInfo.owner = voter;
        }

        IVoter voterCallback = IVoter(voter);
        if (voter.code.length > 0) {
            require(voterCallback.acceptVotes(amount));
        }
    }

    function _burn(address voter, uint256 amount)
        notPending
        isVoterRegistered(voter)
        perVoterReentrancy(getVoter(voter))
        internal
    {
        Voter storage voterInfo = getVoter(voter);
        voterInfo.voteCount -= amount;
        if (voterInfo.delegatee != address(0)) {
            Voter storage delegatee = getVoter(voterInfo.delegatee);
            delegatee.validVotes -= amount;
        } else {
            voterInfo.validVotes -= amount;
        }
        totalVotes -= amount;
        if (voterInfo.voteCount == 0) {
            delete voters[voter];
        }
    }

    function moveDelegateVotes(address from, address to, uint256 amount)
        notPending
        isVoterRegistered(from)
        isVoterRegistered(to)
        perVoterReentrancy(getVoter(from))
        perVoterReentrancy(getVoter(to))
        internal
    {
        Voter storage fromVoter = getVoter(from);
        Voter storage toVoter = getVoter(to);
        fromVoter.validVotes -= amount;
        toVoter.validVotes += amount;
    }

    function getVoter(address v)
        perVoterReentrancy(voter=voter)
        isVoterRegistered(v)
        internal
        returns (Voter storage voter)
    {
        voter = voters[v];
    }

    function tstore(bytes32 key, uint256 value) internal {
        assembly {
            tstore(key, value)
        }
    }

    function tload(bytes32 key) internal view returns (uint256 value) {
        assembly {
            value := tload(key)
        }
    }
}