# Innovation Square MKE

## Summary 
Innovation Square MKE is a transformative technology residency program and innovation hub designed to revitalize an underutilized property in Milwaukee. The project combines modern digital asset tokenization with physical infrastructure to create a cutting-edge ecosystem for emerging technologies.

## Key Elements
1. Property & Infrastructure
Existing Building Renovation:

A 2,000–3,000 sq ft facility will be transformed into a communal co-working space, tech labs (AI, AR/VR, IoT, Robotics), event areas, and a Bitcoin café.

Modular Live-Work Units:

5 Shipping Containers will be converted into modular live-work units. These units serve as both residences and workspaces for residents, providing a compact, flexible solution that complements the co-working environment.

2. Residency Program
3-Month Cohort Model:

Each cohort consists of 5 specialists covering five verticals: AI, AR/VR, Bitcoin, IoT, and Robotics.

Residents receive a $10K equity-free grant (paid in Bitcoin) as a stipend and funding support, allowing them to focus on developing early-stage projects.

The program includes structured mentorship, technical and business training, and culminates in a capstone project that contributes to Innovation Square’s open-source knowledge base.

Residents benefit from 12 months of ongoing access to the Innovation Square facilities, ensuring continuity and long-term support.

3. Tokenized Lease & Governance
Lease NFT Contract:

Digital Lease Deeds: Lease rights are tokenized as NFTs that grant holders profit-sharing rights from Bitcoin-based revenues.

Annual Renewal & Reclaim Mechanism: NFT owners must renew their lease annually by paying a fee (adjusted based on property appreciation). If the renewal fee is not paid by the deadline, the contract owner can reclaim and resell the NFT.

Transferability & Delegation: Lease NFTs can be delegated, transferred, or sold, ensuring flexibility in lease management.

Governance Token Contract:

Voting Rights: A separate governance token is issued to enable community decision-making regarding facility operations and strategic upgrades.

Non-Equity Role: Holding governance tokens does not confer profit-sharing or ownership rights—it solely provides a voice in operational matters.

4. Financial & Operational Model
Circular Bitcoin Economy:

All transactions (payments, renewals, stipends) are conducted exclusively in Bitcoin, reinforcing the project’s commitment to the digital economy.

Revenue Streams & Funding:

Corporate Sponsorships & Partnerships: Collaboration with local giants like Rockwell Automation, Milwaukee Tool, Marquette University, and proximity to the Milwaukee Bucks arena.

Co-Working Memberships & Event Fees: Additional revenue from day passes, workshops, and tech bootcamps.

Grants & Government Funding: Support through local, state, and federal programs focused on innovation and workforce development.

Cost Estimates:

The overall project budget is estimated at $1.03M – $1.52M, which covers building renovation, container conversion, site prep, smart contract development, and operational costs.

A recommended initial deposit of $10K–$15K (20–30% of the development cost) is suggested to kick off smart contract development.

5. Long-Term Vision
Pre-Accelerator Model:

Innovation Square MKE is designed as a pre-accelerator that not only incubates early-stage tech projects but also democratizes access to real estate and digital economy opportunities through tokenization.

Sustainable Growth:

With an annual renewal mechanism, profit-sharing for lease NFT holders, and a separate governance system, Innovation Square is structured for long-term viability, community engagement, and continuous innovation.

This repository contains the complete smart contract system for **Innovation Square MKE**, written in Solidity and Clarity.

- **LeaseNFT Contract**: A tokenized lease management system
- **GovernanceToken Contract**: A non-equity governance token with a proposal and voting system

## 📦 Contracts Overview

### 🔐 LeaseNFT.sol
- Implements a tokenized lease model using NFTs
- Lease holders must renew their NFT once per year
- Failure to renew allows the contract owner to reclaim and resell the lease
- Includes a basic profit-sharing mechanism for lease NFT holders

### 📊 GovernanceToken.sol
- A fungible ERC-20 style governance token (`ISGT`)
- Only the designated `director` can mint tokens or create proposals
- Only active Lease NFT holders can vote
- Proposal creation and voting include checks for time limits and double voting prevention

### 🔐 lease-nft.clar
- Clarity version of the Lease NFT contract
- Tracks lease ownership, renewal deadlines, and reclaim logic

### 📊 gov-token.clar
- Clarity version of the Governance Token contract
- Connects with `lease-nft.clar` to ensure only active lease holders can vote
- `director` is authorized to mint, create, and execute proposals

---

## 🚀 Deployment Instructions

### Solidity (Base or Ethereum)
1. Compile using Remix or Hardhat
2. Deploy `LeaseNFT.sol` and record the contract address
3. Deploy `GovernanceToken.sol` using the LeaseNFT contract address as a constructor argument

### Clarity (Stacks)
1. Deploy `lease-nft.clar` via Clarinet or directly on the Stacks Explorer
2. Deploy `gov-token.clar`, ensuring it imports or interfaces with the lease record map from `lease-nft.clar`

---

## 🔁 System Roles

| Role         | Permission                             |
|--------------|-----------------------------------------|
| `director`   | Mint tokens, create & execute proposals |
| Lease NFT holders | Receive revenue, renew leases        |
| Active NFT holders | Vote in governance proposals        |


## Usage
Renew NFTs annually. Proposal voting is tied to active NFT holders.

## License 
MIT 
