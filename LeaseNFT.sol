// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract LeaseNFT {
    uint public constant RENEWAL_PERIOD = 31536000; // 1 year in seconds

    struct LeaseRecord {
        address owner;
        uint lastRenewal;
        uint renewalFee;
        address delegatedTo;
    }

    uint public totalNFTs;
    uint public profitPool;
    mapping(uint => LeaseRecord) public leaseRecords;
    address public contractOwner;

    event NFTMinted(uint indexed nftId, address indexed owner);
    event NFTTransferred(uint indexed nftId, address indexed from, address indexed to);
    event LeaseRenewed(uint indexed nftId, uint newFee);
    event NFTReclaimed(uint indexed nftId);
    event ProfitClaimed(uint indexed nftId, address indexed owner, uint share);

    constructor() {
        contractOwner = msg.sender;
    }

    modifier onlyOwner(uint nftId) {
        require(leaseRecords[nftId].owner == msg.sender, "Not the NFT owner");
        _;
    }

    modifier onlyContractOwner() {
        require(msg.sender == contractOwner, "Not contract owner");
        _;
    }

    function mintLeaseNFT(address recipient, uint initialFee) external onlyContractOwner returns (uint) {
        uint nftId = totalNFTs + 1;
        leaseRecords[nftId] = LeaseRecord({
            owner: recipient,
            lastRenewal: block.timestamp,
            renewalFee: initialFee,
            delegatedTo: address(0)
        });
        totalNFTs = nftId;
        emit NFTMinted(nftId, recipient);
        return nftId;
    }

    function transferLeaseNFT(uint nftId, address newOwner) external onlyOwner(nftId) {
        leaseRecords[nftId].owner = newOwner;
        emit NFTTransferred(nftId, msg.sender, newOwner);
    }

    function renewLease(uint nftId, uint newFee) external payable onlyOwner(nftId) {
        LeaseRecord storage record = leaseRecords[nftId];
        uint deadline = record.lastRenewal + RENEWAL_PERIOD;
        require(block.timestamp <= deadline, "Renewal deadline passed");
        require(msg.value >= newFee, "Insufficient fee");
        record.lastRenewal = block.timestamp;
        record.renewalFee = newFee;
        emit LeaseRenewed(nftId, newFee);
    }

    function reclaimNFT(uint nftId) external onlyContractOwner {
        LeaseRecord storage record = leaseRecords[nftId];
        uint deadline = record.lastRenewal + RENEWAL_PERIOD;
        require(block.timestamp > deadline, "Too early to reclaim");
        record.owner = contractOwner;
        record.delegatedTo = address(0);
        record.lastRenewal = block.timestamp;
        emit NFTReclaimed(nftId);
    }

    function claimProfitShare(uint nftId) external {
        LeaseRecord storage record = leaseRecords[nftId];
        require(record.owner == msg.sender, "Not the owner");
        uint share = profitPool / totalNFTs;
        emit ProfitClaimed(nftId, msg.sender, share);
    }
}
