// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface ILeaseNFT {
    function leaseRecords(uint nftId) external view returns (address owner, uint lastRenewal, uint, address);
    function totalNFTs() external view returns (uint);
}

contract GovernanceToken {
    string public constant name = "Innovation Square Governance Token";
    string public constant symbol = "ISGT";
    uint public totalSupply;

    address public director;
    ILeaseNFT public leaseNFTContract;

    mapping(address => uint) public balanceOf;
    mapping(address => mapping(address => uint)) public allowance;

    struct Proposal {
        string description;
        uint voteCount;
        uint endTime;
        bool executed;
    }

    uint public proposalCount;
    mapping(uint => Proposal) public proposals;
    mapping(uint => mapping(address => bool)) public hasVoted;

    modifier onlyDirector() {
        require(msg.sender == director, "Not director");
        _;
    }

    constructor(address _leaseNFTContract) {
        director = msg.sender;
        leaseNFTContract = ILeaseNFT(_leaseNFTContract);
    }

    function mint(address to, uint amount) external onlyDirector {
        balanceOf[to] += amount;
        totalSupply += amount;
    }

    function transfer(address to, uint amount) external {
        require(balanceOf[msg.sender] >= amount, "Insufficient");
        balanceOf[msg.sender] -= amount;
        balanceOf[to] += amount;
    }

    function createProposal(string memory desc, uint duration) external onlyDirector returns (uint) {
        proposalCount++;
        proposals[proposalCount] = Proposal(desc, 0, block.number + duration, false);
        return proposalCount;
    }

    function isActiveHolder(address user) public view returns (bool) {
        uint total = leaseNFTContract.totalNFTs();
        for (uint i = 1; i <= total; i++) {
            (address owner, uint lastRenewal,,) = leaseNFTContract.leaseRecords(i);
            if (owner == user && block.timestamp <= lastRenewal + 31536000) {
                return true;
            }
        }
        return false;
    }

    function vote(uint proposalId) external {
        require(!hasVoted[proposalId][msg.sender], "Already voted");
        require(isActiveHolder(msg.sender), "Not eligible");
        Proposal storage p = proposals[proposalId];
        require(block.number < p.endTime, "Voting closed");
        p.voteCount += balanceOf[msg.sender];
        hasVoted[proposalId][msg.sender] = true;
    }

    function executeProposal(uint proposalId) external onlyDirector {
        Proposal storage p = proposals[proposalId];
        require(block.number >= p.endTime, "Too early");
        require(!p.executed, "Already done");
        p.executed = true;
    }
}
