# SOVEREIGN

**Supreme Privacy NFT Platform with Fully Homomorphic Encryption**

SOVEREIGN is the ultimate NFT platform that leverages Zama's Fully Homomorphic Encryption (fhEVM) to give you absolute control over your digital assets. Unlike traditional NFTs where all metadata is public, SOVEREIGN stores trait values as encrypted ciphertexts directly on-chain, ensuring that sensitive attributes remain confidential while still being verifiable.

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Solidity](https://img.shields.io/badge/Solidity-0.8.28-blue)](https://soliditylang.org/)
[![fhEVM](https://img.shields.io/badge/fhEVM-0.9.1-purple)](https://docs.zama.ai/fhevm)
[![Hardhat](https://img.shields.io/badge/Hardhat-2.22-yellow)](https://hardhat.org/)

## 🎥 Demo Video

[![SOVEREIGN Demo](https://img.youtube.com/vi/nYGNUf2RdEI/maxresdefault.jpg)](https://www.youtube.com/watch?v=nYGNUf2RdEI)

**Watch the full demo**: [https://www.youtube.com/watch?v=nYGNUf2RdEI](https://www.youtube.com/watch?v=nYGNUf2RdEI)

See SOVEREIGN in action - from wallet connection to minting encrypted NFTs on Sepolia testnet with full FHE privacy guarantees.

---

## Overview

### The Problem

Traditional NFTs expose all attributes publicly on-chain. This creates issues for:
- **Gaming NFTs**: Opponents can see your character's stats before battle
- **Membership NFTs**: Tier levels and benefits are visible to everyone
- **Collectibles**: Rarity scores are known, eliminating discovery mechanics
- **Identity NFTs**: Sensitive credentials are permanently public

### The Solution

SOVEREIGN uses Fully Homomorphic Encryption to encrypt NFT attributes at the point of minting. The encrypted values (`euint32`) are stored on-chain and can only be decrypted by authorized parties (token owners). Crucially, computations can be performed on encrypted data without decryption, enabling:

- **Private comparisons**: Verify if a trait exceeds a threshold without revealing the actual value
- **Encrypted arithmetic**: Combine traits, calculate bonuses, or evolve attributes while encrypted
- **Selective disclosure**: Owners can prove properties about their NFT without revealing exact values

## Architecture

### System Components

```
┌─────────────────────────────────────────────────────────────────┐
│                         Frontend (React)                        │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────────────┐  │
│  │ Wallet       │  │ FHE SDK      │  │ Contract             │  │
│  │ Connection   │  │ (Relayer)    │  │ Interactions         │  │
│  └──────────────┘  └──────────────┘  └──────────────────────┘  │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│                    Ethereum Sepolia Network                      │
│  ┌──────────────────────────────────────────────────────────┐   │
│  │                  FHEBlindNFT Contract                    │   │
│  │  ┌────────────┐  ┌────────────┐  ┌────────────────────┐  │   │
│  │  │ ERC721     │  │ Encrypted  │  │ Permission         │  │   │
│  │  │ Standard   │  │ Trait      │  │ Management         │  │   │
│  │  │            │  │ Storage    │  │ (ACL)              │  │   │
│  │  └────────────┘  └────────────┘  └────────────────────┘  │   │
│  └──────────────────────────────────────────────────────────┘   │
│                              │                                   │
│  ┌──────────────────────────────────────────────────────────┐   │
│  │                   Zama fhEVM Coprocessor                 │   │
│  │  ┌────────────┐  ┌────────────┐  ┌────────────────────┐  │   │
│  │  │ ACL        │  │ KMS        │  │ Input Verifier     │  │   │
│  │  │ Contract   │  │ Contract   │  │ Contract           │  │   │
│  │  └────────────┘  └────────────┘  └────────────────────┘  │   │
│  └──────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────┘
```

### Smart Contracts

| Contract | Description |
|----------|-------------|
| `FHEBlindNFT.sol` | Core NFT contract with encrypted trait storage and basic minting |
| `VeilMintSimple.sol` | Simplified minting interface for quick integrations |
| `VeilMintBlindNFT.sol` | Advanced contract with marketplace features and encrypted bidding |
| `VeilMintGalleryCoordinator.sol` | Multi-collection gallery management with curator permissions |

### FHE Data Flow

```
User Input (plaintext: 42)
        │
        ▼
┌───────────────────┐
│  FHE SDK Client   │  ← Encrypts with network public key
│  (Browser)        │  ← Generates ZK input proof
└───────────────────┘
        │
        ▼
┌───────────────────┐
│  Smart Contract   │  ← Verifies input proof
│  mintBlind()      │  ← Stores euint32 ciphertext
└───────────────────┘
        │
        ▼
┌───────────────────┐
│  ACL Permission   │  ← FHE.allowThis() for contract access
│  Grant            │  ← FHE.allow(owner) for owner decryption
└───────────────────┘
```

## Technical Implementation

### Encrypted Trait Storage

Each NFT stores an encrypted 32-bit unsigned integer representing its trait value:

```solidity
mapping(uint256 => euint32) private _secretTrait;
```

The `euint32` type is a ciphertext that can only be decrypted by parties with ACL permissions. On-chain, the value appears as a 256-bit handle pointing to the encrypted data managed by the fhEVM coprocessor.

### Permission Model

VeilMint implements a comprehensive permission system for encrypted data access:

```solidity
// During minting - grant permissions
function mintBlind(address to, externalEuint32 ctTrait, bytes calldata inputProof)
    external payable returns (uint256 tokenId)
{
    // Convert external ciphertext to internal handle
    euint32 trait = FHE.asEuint32(ctTrait, inputProof);

    // Store encrypted trait
    _secretTrait[tokenId] = trait;

    // Grant contract permission to operate on ciphertext
    FHE.allowThis(trait);

    // Grant owner permission to request decryption
    FHE.allow(trait, to);
}

// During transfer - update permissions
function _update(address to, uint256 tokenId, address auth)
    internal override returns (address)
{
    address from = super._update(to, tokenId, auth);

    if (to != address(0)) {
        // Grant new owner permission to decrypt
        FHE.allow(_secretTrait[tokenId], to);
    }

    return from;
}
```

### Encrypted Operations

The contract can perform computations on encrypted values without decryption:

```solidity
// Compare encrypted trait against encrypted threshold
function verifyTraitGte(
    uint256 tokenId,
    externalEuint32 ctThreshold,
    bytes calldata proof
) external returns (ebool) {
    euint32 threshold = FHE.asEuint32(ctThreshold, proof);
    euint32 trait = _secretTrait[tokenId];

    // Returns encrypted boolean - true if trait >= threshold
    ebool result = FHE.ge(trait, threshold);

    // Grant caller permission to decrypt result
    FHE.allow(result, msg.sender);

    return result;
}
```

## Getting Started

### Prerequisites

- Node.js >= 18.0.0
- MetaMask or compatible Web3 wallet
- Sepolia testnet ETH ([Faucet](https://sepoliafaucet.com/))

### Installation

```bash
# Clone repository
git clone https://github.com/CarwynDuc/my-fhevm-project.git
cd my-fhevm-project

# Install contract dependencies
npm install

# Install frontend dependencies
cd frontend && npm install
```

### Configuration

**Root `.env`**:
```env
SEPOLIA_RPC_URL=https://ethereum-sepolia-rpc.publicnode.com
DEPLOYER_PRIVATE_KEY=0x_your_private_key
```

**Frontend `.env`**:
```env
VITE_CHAIN_ID=11155111
VITE_SEPOLIA_RPC=https://ethereum-sepolia-rpc.publicnode.com
VITE_NFT_ADDRESS=0x27D2aB8048A5b7f3d4b8416C231f33366d7c663c

# Zama fhEVM Addresses (Sepolia)
VITE_FHE_ACL_ADDRESS=0x687820221192C5B662b25367F70076A37bc79b6c
VITE_FHE_KMS_ADDRESS=0x1364cBBf2cDF5032C47d8226a6f6FBD2AFCDacAC
VITE_FHE_INPUT_VERIFIER_ADDRESS=0xbc91f3daD1A5F19F8390c400196e58073B6a0BC4
```

### Deployment

```bash
# Compile contracts
npx hardhat compile

# Deploy to Sepolia
npx hardhat run scripts/deploy-all.js --network sepolia
```

### Run Frontend

```bash
cd frontend
npm run dev
```

## API Reference

### Core Functions

#### `mintBlind`
Mints a new NFT with an encrypted trait value.

```solidity
function mintBlind(
    address to,
    externalEuint32 ctTrait,
    bytes calldata inputProof
) external payable returns (uint256 tokenId)
```

| Parameter | Type | Description |
|-----------|------|-------------|
| `to` | `address` | Recipient of the minted NFT |
| `ctTrait` | `externalEuint32` | Encrypted trait value (client-encrypted) |
| `inputProof` | `bytes` | ZK proof of valid encryption |

#### `mintBlindBatch`
Batch mints multiple NFTs with encrypted traits in a single transaction.

```solidity
function mintBlindBatch(
    address to,
    externalEuint32[] calldata ctTraits,
    bytes calldata inputProof
) external payable returns (uint256[] memory tokenIds)
```

#### `getTrait`
Returns the encrypted trait handle for a token. Only accessible to parties with ACL permissions.

```solidity
function getTrait(uint256 tokenId) external view returns (euint32)
```

#### `setTrait`
Updates the encrypted trait for a token. Only callable by token owner.

```solidity
function setTrait(
    uint256 tokenId,
    externalEuint32 ctTrait,
    bytes calldata inputProof
) external
```

### Admin Functions

#### `setMintConfig`
Configures minting parameters.

```solidity
function setMintConfig(
    bool _active,
    uint256 _maxSupply,
    uint256 _maxPerWallet,
    uint256 _mintPrice
) external onlyOwner
```

## Frontend Integration

### FHE SDK Initialization

The frontend loads the Zama Relayer SDK via CDN:

```html
<script
  src="https://cdn.zama.org/relayer-sdk-js/0.3.0-8/relayer-sdk-js.umd.cjs"
  defer
  crossorigin="anonymous"
></script>
```

### Encrypting Values

```typescript
import { initializeFHE } from '@/utils/fhe';

// Initialize SDK with wallet provider
const instance = await initializeFHE(window.ethereum);

// Create encrypted input
const input = instance.createEncryptedInput(contractAddress, userAddress);
input.add32(traitValue); // Add 32-bit value to encrypt

// Generate ciphertext and proof
const { handles, inputProof } = await input.encrypt();

// Submit to contract
await contract.mintBlind(userAddress, handles[0], inputProof);
```

### Transaction Notifications

SOVEREIGN includes comprehensive transaction status notifications:

```typescript
// Automatic notifications for:
// - Transaction submitted (with Etherscan link)
// - Transaction confirmed (with token ID and Etherscan link)
// - Transaction failed (with error details and Etherscan link)
// - User rejection handling
```

## Project Structure

```
SOVEREIGN/
├── contracts/                    # Solidity smart contracts
│   ├── FHEBlindNFT.sol          # Core encrypted NFT
│   ├── VeilMintSimple.sol       # Simple minting
│   ├── VeilMintBlindNFT.sol     # Advanced features
│   └── VeilMintGalleryCoordinator.sol
│
├── scripts/                      # Deployment scripts
│   ├── deploy-all.js            # Full deployment
│   ├── deploy.ts                # Basic deployment
│   └── create-initial-nfts.js   # Initialize contract
│
├── frontend/                     # React application
│   ├── src/
│   │   ├── components/          # UI components
│   │   ├── hooks/               # React hooks
│   │   │   └── useContract.ts   # Contract interactions
│   │   ├── utils/
│   │   │   ├── fhe.ts           # FHE SDK wrapper
│   │   │   └── txNotification.tsx
│   │   └── abi/                 # Contract ABIs
│   └── index.html               # Entry point (CDN scripts)
│
├── hardhat.config.ts            # Hardhat configuration
├── package.json
└── tsconfig.json
```

## Security Considerations

### Implemented Safeguards

- **ReentrancyGuard**: All state-changing functions protected against reentrancy
- **Access Control**: Owner-only admin functions with OpenZeppelin's Ownable
- **Input Validation**: All external inputs validated before processing
- **Permission Isolation**: Each token's encrypted data has independent ACL permissions

### FHE-Specific Security

- **Ciphertext Integrity**: Input proofs verify encryption was performed correctly
- **Permission Propagation**: ACL permissions automatically updated on transfers
- **Handle Validation**: Guards against zero/invalid FHE handles

### Limitations

- Contracts are **unaudited** - use at your own risk
- fhEVM is in active development - APIs may change
- Decryption requires off-chain relayer infrastructure

## Deployed Contracts (Sepolia)

**Deployment Date**: December 26, 2025
**Deployer**: `0x9c4A63768d7808935D4Ca9961158a6a1dc79C89d`
**Network**: Sepolia Testnet (Chain ID: 11155111)

| Contract | Address | Etherscan |
|----------|---------|-----------|
| **VeilMintSimple** | `0x3DA0E8F54D30c119522F0e96e23c36fD0dD4A900` | [View Contract →](https://sepolia.etherscan.io/address/0x3DA0E8F54D30c119522F0e96e23c36fD0dD4A900) |
| **FHEBlindNFT** | `0x27D2aB8048A5b7f3d4b8416C231f33366d7c663c` | [View Contract →](https://sepolia.etherscan.io/address/0x27D2aB8048A5b7f3d4b8416C231f33366d7c663c) |
| **VeilMintBlindNFT** | `0x701499B8DcDc40bF66e0D1203a9776fD06B770ec` | [View Contract →](https://sepolia.etherscan.io/address/0x701499B8DcDc40bF66e0D1203a9776fD06B770ec) |
| **VeilMintGalleryCoordinator** | `0xa5EE4D939f04F1BcbFe0F108496b983850143009` | [View Contract →](https://sepolia.etherscan.io/address/0xa5EE4D939f04F1BcbFe0F108496b983850143009) |

### Configuration

The FHEBlindNFT contract has been configured with:
- ✅ Minting: **Active**
- ✅ Max Supply: **10,000 NFTs**
- ✅ Max Per Wallet: **10 NFTs**
- ✅ Mint Price: **Free (0 ETH)**

## Resources

- **Live Demo**: [https://sovereign-nft.vercel.app](https://sovereign-nft.vercel.app)
- **Video Demo**: [https://www.youtube.com/watch?v=nYGNUf2RdEI](https://www.youtube.com/watch?v=nYGNUf2RdEI)
- **GitHub Repository**: [https://github.com/CarwynDuc/my-fhevm-project](https://github.com/CarwynDuc/my-fhevm-project)
- **Zama fhEVM Docs**: [https://docs.zama.ai/fhevm](https://docs.zama.ai/fhevm)
- **fhEVM Solidity Library**: [https://github.com/zama-ai/fhevm](https://github.com/zama-ai/fhevm)

## License

MIT License - see [LICENSE](LICENSE) for details.

---

**Built with Zama's fhEVM technology**
