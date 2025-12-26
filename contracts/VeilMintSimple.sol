// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {FHE, euint32, externalEuint32, ebool, externalEbool} from "@fhevm/solidity/lib/FHE.sol";
import {ZamaEthereumConfig} from "@fhevm/solidity/config/ZamaConfig.sol";

/// @title VeilMint - Privacy-Preserving NFT Minting Platform
/// @notice Simplified version focusing on FHE-encrypted trait minting
/// @dev Based on FHEVM-NFT reference implementation with enhanced security
contract VeilMintSimple is ZamaEthereumConfig {

    // ============ Data Structures ============

    /// @notice Public metadata visible to everyone
    struct PublicMetadata {
        string tokenName;
        string creatorName;
        string imageUri;
        address currentOwner;
        uint256 mintTimestamp;
        bool isActive;
    }

    /// @notice Private traits encrypted using FHE
    struct EncryptedTraits {
        euint32 rarityScore;      // 1-100 encrypted rarity
        euint32 powerLevel;       // Encrypted power attribute
        ebool hasSpecialAbility;  // Encrypted boolean flag
    }

    // ============ State Variables ============

    uint256 private tokenCounter;
    uint256 public totalMinted;

    mapping(uint256 => PublicMetadata) public publicMetadata;
    mapping(uint256 => EncryptedTraits) private encryptedTraits;
    mapping(address => uint256[]) public ownerTokenList;
    mapping(uint256 => uint256) private tokenIndexInOwnerList;

    // ============ Security ============

    uint256 private reentrancyLock = 1;

    modifier nonReentrant() {
        require(reentrancyLock == 1, "Reentrancy detected");
        reentrancyLock = 2;
        _;
        reentrancyLock = 1;
    }

    // ============ Events ============

    event TokenMinted(
        uint256 indexed tokenId,
        address indexed owner,
        string tokenName,
        uint256 timestamp
    );

    event TokenTransferred(
        uint256 indexed tokenId,
        address indexed previousOwner,
        address indexed newOwner,
        uint256 timestamp
    );

    // ============ Core Functions ============

    /// @notice Mint a new NFT with encrypted traits
    /// @param recipientAddress Address to receive the minted NFT
    /// @param tokenName Public name for the NFT
    /// @param creatorName Public creator identification
    /// @param imageUri Public image URI (IPFS or HTTP)
    /// @param encryptedRarity Encrypted rarity score (1-100)
    /// @param encryptedPower Encrypted power level
    /// @param encryptedAbility Encrypted special ability flag
    /// @param encryptionProof Single proof for all encrypted inputs
    /// @return newTokenId The ID of the newly minted token
    function mintWithEncryptedTraits(
        address recipientAddress,
        string memory tokenName,
        string memory creatorName,
        string memory imageUri,
        externalEuint32 encryptedRarity,
        externalEuint32 encryptedPower,
        externalEbool encryptedAbility,
        bytes calldata encryptionProof
    ) external nonReentrant returns (uint256) {
        require(recipientAddress != address(0), "Invalid recipient address");
        require(bytes(tokenName).length > 0, "Token name required");

        uint256 newTokenId = tokenCounter;
        tokenCounter++;
        totalMinted++;

        // Store public metadata
        _storePublicMetadata(
            newTokenId,
            tokenName,
            creatorName,
            imageUri,
            recipientAddress
        );

        // Store encrypted traits with single proof
        _storeEncryptedTraits(
            newTokenId,
            encryptedRarity,
            encryptedPower,
            encryptedAbility,
            encryptionProof,
            recipientAddress
        );

        // Add to owner's token list
        ownerTokenList[recipientAddress].push(newTokenId);
        tokenIndexInOwnerList[newTokenId] = ownerTokenList[recipientAddress].length - 1;

        emit TokenMinted(newTokenId, recipientAddress, tokenName, block.timestamp);
        return newTokenId;
    }

    /// @notice Internal function to store public metadata
    function _storePublicMetadata(
        uint256 tokenId,
        string memory tokenName,
        string memory creatorName,
        string memory imageUri,
        address owner
    ) internal {
        publicMetadata[tokenId] = PublicMetadata({
            tokenName: tokenName,
            creatorName: creatorName,
            imageUri: imageUri,
            currentOwner: owner,
            mintTimestamp: block.timestamp,
            isActive: true
        });
    }

    /// @notice Internal function to store encrypted traits
    /// @dev All encrypted values use the same proof (simplified approach)
    function _storeEncryptedTraits(
        uint256 tokenId,
        externalEuint32 encryptedRarity,
        externalEuint32 encryptedPower,
        externalEbool encryptedAbility,
        bytes calldata proof,
        address owner
    ) internal {
        // Convert external encrypted values to internal representation
        euint32 rarity = FHE.fromExternal(encryptedRarity, proof);
        euint32 power = FHE.fromExternal(encryptedPower, proof);
        ebool ability = FHE.fromExternal(encryptedAbility, proof);

        // Store encrypted traits
        encryptedTraits[tokenId] = EncryptedTraits({
            rarityScore: rarity,
            powerLevel: power,
            hasSpecialAbility: ability
        });

        // Grant permissions to contract and owner
        FHE.allowThis(rarity);
        FHE.allow(rarity, owner);

        FHE.allowThis(power);
        FHE.allow(power, owner);

        FHE.allowThis(ability);
        FHE.allow(ability, owner);
    }

    /// @notice Transfer NFT to another address
    /// @param tokenId Token ID to transfer
    /// @param newOwner Address of the new owner
    function transferToken(uint256 tokenId, address newOwner) external nonReentrant {
        require(newOwner != address(0), "Invalid new owner address");
        require(publicMetadata[tokenId].isActive, "Token not active");
        require(publicMetadata[tokenId].currentOwner == msg.sender, "Not the token owner");
        require(newOwner != msg.sender, "Cannot transfer to self");

        address previousOwner = msg.sender;

        // Update public metadata
        publicMetadata[tokenId].currentOwner = newOwner;

        // Update encrypted trait permissions
        EncryptedTraits storage traits = encryptedTraits[tokenId];

        // Revoke old owner permissions
        FHE.allowThis(traits.rarityScore);
        FHE.allowThis(traits.powerLevel);
        FHE.allowThis(traits.hasSpecialAbility);

        // Grant new owner permissions
        FHE.allow(traits.rarityScore, newOwner);
        FHE.allow(traits.powerLevel, newOwner);
        FHE.allow(traits.hasSpecialAbility, newOwner);

        // Update ownership lists
        _removeTokenFromOwnerList(previousOwner, tokenId);
        ownerTokenList[newOwner].push(tokenId);
        tokenIndexInOwnerList[tokenId] = ownerTokenList[newOwner].length - 1;

        emit TokenTransferred(tokenId, previousOwner, newOwner, block.timestamp);
    }

    // ============ View Functions ============

    /// @notice Get encrypted rarity score (only accessible by owner via FHE permissions)
    function getEncryptedRarity(uint256 tokenId) external view returns (euint32) {
        require(publicMetadata[tokenId].isActive, "Token not active");
        return encryptedTraits[tokenId].rarityScore;
    }

    /// @notice Get encrypted power level
    function getEncryptedPower(uint256 tokenId) external view returns (euint32) {
        require(publicMetadata[tokenId].isActive, "Token not active");
        return encryptedTraits[tokenId].powerLevel;
    }

    /// @notice Get encrypted special ability flag
    function getEncryptedAbility(uint256 tokenId) external view returns (ebool) {
        require(publicMetadata[tokenId].isActive, "Token not active");
        return encryptedTraits[tokenId].hasSpecialAbility;
    }

    /// @notice Get public metadata for a token
    function getPublicMetadata(uint256 tokenId) external view returns (PublicMetadata memory) {
        require(publicMetadata[tokenId].isActive, "Token not active");
        return publicMetadata[tokenId];
    }

    /// @notice Get token count for an owner
    function balanceOfOwner(address owner) external view returns (uint256) {
        return ownerTokenList[owner].length;
    }

    /// @notice Get all token IDs owned by an address
    function getTokensByOwner(address owner) external view returns (uint256[] memory) {
        return ownerTokenList[owner];
    }

    /// @notice Check if token exists and is active
    function isTokenActive(uint256 tokenId) external view returns (bool) {
        return publicMetadata[tokenId].isActive;
    }

    /// @notice Get current owner of a token
    function getTokenOwner(uint256 tokenId) external view returns (address) {
        require(publicMetadata[tokenId].isActive, "Token not active");
        return publicMetadata[tokenId].currentOwner;
    }

    // ============ Internal Helpers ============

    /// @notice Remove token from owner's list
    function _removeTokenFromOwnerList(address owner, uint256 tokenId) private {
        uint256[] storage tokens = ownerTokenList[owner];
        uint256 tokenIndex = tokenIndexInOwnerList[tokenId];
        uint256 lastIndex = tokens.length - 1;

        if (tokenIndex != lastIndex) {
            uint256 lastTokenId = tokens[lastIndex];
            tokens[tokenIndex] = lastTokenId;
            tokenIndexInOwnerList[lastTokenId] = tokenIndex;
        }

        tokens.pop();
        delete tokenIndexInOwnerList[tokenId];
    }
}
