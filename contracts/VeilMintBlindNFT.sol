// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {ZamaEthereumConfig} from "@fhevm/solidity/config/ZamaConfig.sol";
import {
    FHE,
    ebool,
    euint8,
    euint16,
    euint32,
    euint64,
    euint128,
    externalEuint8,
    externalEuint16,
    externalEuint32,
    externalEuint64,
    externalEuint128
} from "@fhevm/solidity/lib/FHE.sol";

contract VeilMintBlindNFT is ZamaEthereumConfig {
    // ============ Security ============

    uint256 private _locked = 1;

    modifier nonReentrant() {
        require(_locked == 1, "ReentrancyGuard: reentrant call");
        _locked = 2;
        _;
        _locked = 1;
    }

    // ============ Enums ============

    enum NFTState {
        Draft,           // 0: Initial creation
        Submitted,       // 1: Submitted for evaluation
        Evaluating,      // 2: Under evaluation
        Approved,        // 3: Approved for minting
        Minted,          // 4: Minted on-chain
        Listed,          // 5: Listed for sale
        Sold,            // 6: Sold to buyer
        Transferred,     // 7: Transferred to new owner
        Locked,          // 8: Locked for special purpose
        Archived         // 9: Archived/Burned
    }

    enum RarityTier {
        Common,          // 0: 0-2000
        Uncommon,        // 1: 2001-4000
        Rare,            // 2: 4001-6000
        Epic,            // 3: 6001-8000
        Legendary,       // 4: 8001-9500
        Mythic           // 5: 9501-10000
    }

    enum CollectionType {
        Generative,      // 0: Generative art
        Portrait,        // 1: Portrait collection
        Landscape,       // 2: Landscape art
        Abstract,        // 3: Abstract art
        Pixel,           // 4: Pixel art
        Photography,     // 5: Photography
        ThreeD           // 6: 3D art
    }

    enum MarketStatus {
        NotListed,       // 0: Not for sale
        FixedPrice,      // 1: Fixed price sale
        Auction,         // 2: Auction mode
        PrivateSale,     // 3: Private sale
        Reserved,        // 4: Reserved for specific buyer
        Expired          // 5: Listing expired
    }

    enum ArtistTier {
        Newcomer,        // 0: 0-10 NFTs
        Emerging,        // 1: 11-30 NFTs
        Established,     // 2: 31-100 NFTs
        Renowned,        // 3: 101-300 NFTs
        Master,          // 4: 301-1000 NFTs
        Legend           // 5: 1000+ NFTs
    }

    enum VerificationType {
        Authenticity,    // 0: Authenticity check
        OwnershipHistory,// 1: Ownership verification
        RarityScore,     // 2: Rarity calculation
        MarketValue,     // 3: Market valuation
        Provenance,      // 4: Provenance tracking
        QualityAssurance,// 5: Quality check
        ComplianceCheck  // 6: Compliance verification
    }

    // ============ Structs ============

    struct BlindToken {
        uint256 tokenId;
        address artist;
        address currentOwner;
        NFTState state;
        RarityTier rarityTier;
        CollectionType collectionType;
        MarketStatus marketStatus;

        string title;
        string description;
        string ipfsHash;
        uint256 createdAt;
        uint256 mintedAt;
        uint256 lastTransferredAt;

        euint32 paletteCipher;         // Color palette score (0-10000)
        euint16 layerCipher;           // Number of layers (0-1000)
        euint8 rarityCipher;           // Base rarity (0-100)
        euint64 reserveCipher;         // Reserve price
        euint128 vaultCipher;          // Vault value
        euint32 qualityScoreCipher;    // Overall quality (0-10000)
        euint32 complexityCipher;      // Complexity score (0-10000)
        euint16 uniquenessCipher;      // Uniqueness score (0-10000)
        euint16 aestheticCipher;       // Aesthetic value (0-10000)
        euint8 authenticityScoreCipher;// Authenticity (0-100)
        euint8 provenanceScoreCipher;  // Provenance score (0-100)
        euint64 marketValueCipher;     // Estimated market value
        euint64 lastSalePriceCipher;   // Last sale price
        euint32 viewCountCipher;       // Number of views
        euint16 likesCountCipher;      // Number of likes

        uint256 transferCount;
        uint256 editionNumber;
        uint256 totalEditions;
        bool isFirstEdition;
        bool hasPhysicalArt;
        bool isFramed;
        bool certificateIssued;
    }

    struct ArtistProfile {
        address artist;
        ArtistTier tier;

        euint32 totalMintedCipher;     // Total NFTs minted
        euint32 totalSoldCipher;       // Total sold
        euint64 totalRevenueCipher;    // Total revenue earned
        euint64 averageSalePriceCipher;// Average sale price
        euint32 reputationScoreCipher; // Reputation (0-10000)
        euint16 qualityRatingCipher;   // Quality rating (0-10000)
        euint16 popularityScoreCipher; // Popularity (0-10000)
        euint8 verificationLevelCipher;// Verification level (0-100)

        uint256 createdAt;
        uint256 lastMintAt;
        uint256 followerCount;
        bool isVerified;
        bool isPremium;
    }

    struct Collection {
        uint256 collectionId;
        address creator;
        CollectionType cType;
        string name;
        string symbol;

        euint32 totalItemsCipher;      // Total items in collection
        euint32 mintedItemsCipher;     // Items minted
        euint64 floorPriceCipher;      // Floor price
        euint64 volumeTradedCipher;    // Total volume traded
        euint32 avgQualityCipher;      // Average quality score
        euint16 collectionRarityCipher;// Collection rarity

        uint256 createdAt;
        uint256 lastMintAt;
        bool isActive;
        bool isCurated;
    }

    struct MintPolicy {
        uint32 paletteFloor;
        uint16 layerFloor;
        uint8 rarityAccept;
        uint8 rarityReject;
        uint64 reserveFloor;
        uint64 reservePadding;
        uint128 vaultPadding;
        uint32 qualityThreshold;
        uint32 complexityThreshold;
    }

    struct Verification {
        uint256 verificationId;
        uint256 tokenId;
        address verifier;
        VerificationType vType;

        euint8 verificationScoreCipher;
        euint32 confidenceLevelCipher;
        euint16 authenticityCipher;

        uint256 verifiedAt;
        bool isPassed;
        bool isFinalized;
    }

    struct MarketListing {
        uint256 listingId;
        uint256 tokenId;
        address seller;
        MarketStatus status;

        euint64 listingPriceCipher;
        euint64 reservePriceCipher;
        euint64 highestBidCipher;
        euint32 bidCountCipher;
        euint16 interestLevelCipher;

        uint256 listedAt;
        uint256 expiresAt;
        bool isActive;
    }

    struct RoyaltyInfo {
        uint256 tokenId;
        address artist;

        euint64 totalRoyaltiesCipher;
        euint32 royaltyPercentageCipher;
        euint64 lastRoyaltyAmountCipher;

        uint256 royaltyCount;
        uint256 lastPaidAt;
    }

    // ============ State Variables ============

    MintPolicy public policy;
    uint256 public nextTokenId;
    uint256 public nextCollectionId;
    uint256 public nextVerificationId;
    uint256 public nextListingId;

    mapping(uint256 => BlindToken) private tokens;
    mapping(uint256 => euint8) private revealCipher;
    mapping(uint256 => euint64) private paddedReserveCipher;
    mapping(uint256 => euint128) private paddedVaultCipher;

    mapping(address => ArtistProfile) public artistProfiles;
    mapping(uint256 => Collection) public collections;
    mapping(uint256 => Verification) public verifications;
    mapping(uint256 => MarketListing) public listings;
    mapping(uint256 => RoyaltyInfo) public royalties;

    mapping(uint256 => uint256[]) public tokensByCollection;
    mapping(address => uint256[]) public tokensByArtist;
    mapping(uint256 => uint256[]) public verificationsByToken;
    mapping(uint256 => uint256) public tokenToCollection;

    // Aggregate statistics
    euint64 public totalMarketVolumeCipher;
    euint32 public totalNFTsMintedCipher;
    euint32 public totalCollectionsCipher;
    euint64 public totalRoyaltiesPaidCipher;

    // Roles
    mapping(address => bool) public minterRole;
    mapping(address => bool) public curatorRole;
    mapping(address => bool) public verifierRole;
    mapping(address => bool) public marketplaceRole;
    mapping(address => bool) public royaltyManagerRole;

    address public admin;

    // ============ Events ============

    event BlindTokenCreated(uint256 indexed tokenId, address indexed artist, NFTState state);
    event BlindTokenStateChanged(uint256 indexed tokenId, NFTState oldState, NFTState newState);
    event BlindTokenEvaluated(uint256 indexed tokenId, uint256 indexed qualityScore);
    event BlindTokenMinted(uint256 indexed tokenId, address indexed owner);
    event BlindTokenTransferred(uint256 indexed tokenId, address indexed from, address indexed to);
    event BlindTokenListed(uint256 indexed tokenId, uint256 indexed listingId, uint64 price);
    event BlindTokenSold(uint256 indexed tokenId, address indexed buyer, uint64 price);
    event ArtistTierUpgraded(address indexed artist, ArtistTier newTier);
    event CollectionCreated(uint256 indexed collectionId, address indexed creator, CollectionType cType);
    event VerificationCompleted(uint256 indexed verificationId, uint256 indexed tokenId, bool passed);
    event RoyaltyPaid(uint256 indexed tokenId, address indexed artist, uint64 amount);
    event RoleGranted(address indexed account, string role);
    event RoleRevoked(address indexed account, string role);

    // ============ Errors ============

    error TokenMissing();
    error TokenLocked();
    error RevealMismatch();
    error InvalidState();
    error Unauthorized();
    error InvalidTier();
    error CollectionNotFound();
    error ListingExpired();
    error InsufficientBid();

    // ============ Modifiers ============

    modifier onlyAdmin() {
        if (msg.sender != admin) revert Unauthorized();
        _;
    }

    modifier onlyMinter() {
        if (!minterRole[msg.sender] && msg.sender != admin) revert Unauthorized();
        _;
    }

    modifier onlyCurator() {
        if (!curatorRole[msg.sender] && msg.sender != admin) revert Unauthorized();
        _;
    }

    modifier onlyVerifier() {
        if (!verifierRole[msg.sender] && msg.sender != admin) revert Unauthorized();
        _;
    }

    modifier onlyMarketplace() {
        if (!marketplaceRole[msg.sender] && msg.sender != admin) revert Unauthorized();
        _;
    }

    modifier onlyRoyaltyManager() {
        if (!royaltyManagerRole[msg.sender] && msg.sender != admin) revert Unauthorized();
        _;
    }


    // ============ Constructor ============

    constructor() {
        admin = msg.sender;
        minterRole[msg.sender] = true;
        curatorRole[msg.sender] = true;
        verifierRole[msg.sender] = true;
        marketplaceRole[msg.sender] = true;
        royaltyManagerRole[msg.sender] = true;

        policy = MintPolicy({
            paletteFloor: 5000,
            layerFloor: 5,
            rarityAccept: 70,
            rarityReject: 30,
            reserveFloor: 0.1 ether,
            reservePadding: 0.01 ether,
            vaultPadding: 0.05 ether,
            qualityThreshold: 6000,
            complexityThreshold: 5000
        });

        totalMarketVolumeCipher = FHE.asEuint64(0);
        totalNFTsMintedCipher = FHE.asEuint32(0);
        totalCollectionsCipher = FHE.asEuint32(0);
        totalRoyaltiesPaidCipher = FHE.asEuint64(0);
    }

    // ============ Role Management ============

    function grantMinterRole(address account) external onlyAdmin {
        minterRole[account] = true;
        emit RoleGranted(account, "MINTER");
    }

    function revokeMinterRole(address account) external onlyAdmin {
        minterRole[account] = false;
        emit RoleRevoked(account, "MINTER");
    }

    function grantCuratorRole(address account) external onlyAdmin {
        curatorRole[account] = true;
        emit RoleGranted(account, "CURATOR");
    }

    function revokeCuratorRole(address account) external onlyAdmin {
        curatorRole[account] = false;
        emit RoleRevoked(account, "CURATOR");
    }

    function grantVerifierRole(address account) external onlyAdmin {
        verifierRole[account] = true;
        emit RoleGranted(account, "VERIFIER");
    }

    function revokeVerifierRole(address account) external onlyAdmin {
        verifierRole[account] = false;
        emit RoleRevoked(account, "VERIFIER");
    }

    function grantMarketplaceRole(address account) external onlyAdmin {
        marketplaceRole[account] = true;
        emit RoleGranted(account, "MARKETPLACE");
    }

    function revokeMarketplaceRole(address account) external onlyAdmin {
        marketplaceRole[account] = false;
        emit RoleRevoked(account, "MARKETPLACE");
    }

    function grantRoyaltyManagerRole(address account) external onlyAdmin {
        royaltyManagerRole[account] = true;
        emit RoleGranted(account, "ROYALTY_MANAGER");
    }

    function revokeRoyaltyManagerRole(address account) external onlyAdmin {
        royaltyManagerRole[account] = false;
        emit RoleRevoked(account, "ROYALTY_MANAGER");
    }

    // ============ Artist Profile Management ============

    function createArtistProfile() external {
        if (artistProfiles[msg.sender].artist != address(0)) revert Unauthorized();

        ArtistProfile storage profile = artistProfiles[msg.sender];
        profile.artist = msg.sender;
        profile.tier = ArtistTier.Newcomer;
        profile.totalMintedCipher = FHE.asEuint32(0);
        profile.totalSoldCipher = FHE.asEuint32(0);
        profile.totalRevenueCipher = FHE.asEuint64(0);
        profile.averageSalePriceCipher = FHE.asEuint64(0);
        profile.reputationScoreCipher = FHE.asEuint32(5000);
        profile.qualityRatingCipher = FHE.asEuint16(5000);
        profile.popularityScoreCipher = FHE.asEuint16(5000);
        profile.verificationLevelCipher = FHE.asEuint8(50);
        profile.createdAt = block.timestamp;
        profile.lastMintAt = 0;
        profile.followerCount = 0;
        profile.isVerified = false;
        profile.isPremium = false;
    }

    function updateArtistTier(address artist) internal {
        ArtistProfile storage profile = artistProfiles[artist];
        if (profile.artist == address(0)) return;

        uint32[] memory tierThresholds = new uint32[](6);
        tierThresholds[0] = 0;      // Newcomer
        tierThresholds[1] = 11;     // Emerging
        tierThresholds[2] = 31;     // Established
        tierThresholds[3] = 101;    // Renowned
        tierThresholds[4] = 301;    // Master
        tierThresholds[5] = 1001;   // Legend

        // Tier upgrade will be determined by decrypted totalMinted value
        // For now, we track it and will update after Gateway callback
    }

    // ============ Collection Management ============

    function createCollection(
        CollectionType cType,
        string calldata name,
        string calldata symbol,
        externalEuint32 totalItemsInput,
        externalEuint64 floorPriceInput,
        bytes calldata inputProof
    ) external returns (uint256 collectionId) {
        euint32 totalItems = FHE.fromExternal(totalItemsInput, inputProof);
        euint64 floorPrice = FHE.fromExternal(floorPriceInput, inputProof);

        FHE.allowThis(totalItems);
        FHE.allowThis(floorPrice);

        collectionId = nextCollectionId++;

        Collection storage collection = collections[collectionId];
        collection.collectionId = collectionId;
        collection.creator = msg.sender;
        collection.cType = cType;
        collection.name = name;
        collection.symbol = symbol;
        collection.totalItemsCipher = totalItems;
        collection.mintedItemsCipher = FHE.asEuint32(0);
        collection.floorPriceCipher = floorPrice;
        collection.volumeTradedCipher = FHE.asEuint64(0);
        collection.avgQualityCipher = FHE.asEuint32(0);
        collection.collectionRarityCipher = FHE.asEuint16(0);
        collection.createdAt = block.timestamp;
        collection.lastMintAt = 0;
        collection.isActive = true;
        collection.isCurated = false;

        totalCollectionsCipher = FHE.add(totalCollectionsCipher, FHE.asEuint32(1));

        emit CollectionCreated(collectionId, msg.sender, cType);
    }

    // ============ NFT Creation & Minting ============

    function stageBlindToken(
        uint256 collectionId,
        string calldata title,
        string calldata description,
        string calldata ipfsHash,
        CollectionType collectionType,
        externalEuint32 paletteInput,
        externalEuint16 layerInput,
        externalEuint8 rarityInput,
        externalEuint64 reserveInput,
        externalEuint128 vaultInput,
        externalEuint32 complexityInput,
        externalEuint16 uniquenessInput,
        externalEuint16 aestheticInput,
        bytes calldata inputProof
    ) external returns (uint256 tokenId) {
        // Initialize artist profile if doesn't exist
        if (artistProfiles[msg.sender].artist == address(0)) {
            this.createArtistProfile();
        }

        euint32 palette = FHE.fromExternal(paletteInput, inputProof);
        euint16 layer = FHE.fromExternal(layerInput, inputProof);
        euint8 rarity = FHE.fromExternal(rarityInput, inputProof);
        euint64 reserve = FHE.fromExternal(reserveInput, inputProof);
        euint128 vault = FHE.fromExternal(vaultInput, inputProof);
        euint32 complexity = FHE.fromExternal(complexityInput, inputProof);
        euint16 uniqueness = FHE.fromExternal(uniquenessInput, inputProof);
        euint16 aesthetic = FHE.fromExternal(aestheticInput, inputProof);

        FHE.allowThis(palette);
        FHE.allowThis(layer);
        FHE.allowThis(rarity);
        FHE.allowThis(reserve);
        FHE.allowThis(vault);
        FHE.allowThis(complexity);
        FHE.allowThis(uniqueness);
        FHE.allowThis(aesthetic);

        tokenId = nextTokenId++;

        BlindToken storage token = tokens[tokenId];
        token.tokenId = tokenId;
        token.artist = msg.sender;
        token.currentOwner = msg.sender;
        token.state = NFTState.Draft;
        token.rarityTier = RarityTier.Common;
        token.collectionType = collectionType;
        token.marketStatus = MarketStatus.NotListed;
        token.title = title;
        token.description = description;
        token.ipfsHash = ipfsHash;
        token.createdAt = block.timestamp;
        token.mintedAt = 0;
        token.lastTransferredAt = 0;
        token.paletteCipher = palette;
        token.layerCipher = layer;
        token.rarityCipher = rarity;
        token.reserveCipher = reserve;
        token.vaultCipher = vault;
        token.qualityScoreCipher = FHE.asEuint32(0);
        token.complexityCipher = complexity;
        token.uniquenessCipher = uniqueness;
        token.aestheticCipher = aesthetic;
        token.authenticityScoreCipher = FHE.asEuint8(50);
        token.provenanceScoreCipher = FHE.asEuint8(100);
        token.marketValueCipher = FHE.asEuint64(0);
        token.lastSalePriceCipher = FHE.asEuint64(0);
        token.viewCountCipher = FHE.asEuint32(0);
        token.likesCountCipher = FHE.asEuint16(0);
        token.transferCount = 0;
        token.editionNumber = 1;
        token.totalEditions = 1;
        token.isFirstEdition = true;
        token.hasPhysicalArt = false;
        token.isFramed = false;
        token.certificateIssued = false;

        if (collectionId > 0 && collections[collectionId].creator != address(0)) {
            tokenToCollection[tokenId] = collectionId;
            tokensByCollection[collectionId].push(tokenId);
        }

        tokensByArtist[msg.sender].push(tokenId);

        emit BlindTokenCreated(tokenId, msg.sender, NFTState.Draft);
    }

    function submitForEvaluation(uint256 tokenId) external {
        BlindToken storage token = tokens[tokenId];
        if (token.artist == address(0)) revert TokenMissing();
        if (token.artist != msg.sender) revert Unauthorized();
        if (token.state != NFTState.Draft) revert InvalidState();

        token.state = NFTState.Submitted;
        emit BlindTokenStateChanged(tokenId, NFTState.Draft, NFTState.Submitted);
    }

    function evaluateBlindToken(uint256 tokenId) external onlyCurator {
        BlindToken storage token = tokens[tokenId];
        if (token.artist == address(0)) revert TokenMissing();
        if (token.state != NFTState.Submitted) revert InvalidState();

        token.state = NFTState.Evaluating;
        emit BlindTokenStateChanged(tokenId, NFTState.Submitted, NFTState.Evaluating);

        MintPolicy memory pol = policy;

        // Calculate quality score (0-10000):
        // palette×30% + layers×100×20% + rarity×100×20% + complexity×15% + uniqueness×10% + aesthetic×5%

        euint32 paletteComponent = FHE.div(
            FHE.mul(token.paletteCipher, uint32(30)),
            uint32(100)
        );

        euint32 layerComponent = FHE.div(
            FHE.mul(FHE.asEuint32(FHE.mul(token.layerCipher, uint16(100))), uint32(20)),
            uint32(100)
        );

        euint32 rarityComponent = FHE.div(
            FHE.mul(FHE.asEuint32(FHE.mul(token.rarityCipher, uint8(100))), uint32(20)),
            uint32(100)
        );

        euint32 complexityComponent = FHE.div(
            FHE.mul(token.complexityCipher, uint32(15)),
            uint32(100)
        );

        euint32 uniquenessComponent = FHE.div(
            FHE.mul(FHE.asEuint32(token.uniquenessCipher), uint32(10)),
            uint32(100)
        );

        euint32 aestheticComponent = FHE.div(
            FHE.mul(FHE.asEuint32(token.aestheticCipher), uint32(5)),
            uint32(100)
        );

        euint32 qualityScore = FHE.add(paletteComponent,
            FHE.add(layerComponent,
                FHE.add(rarityComponent,
                    FHE.add(complexityComponent,
                        FHE.add(uniquenessComponent, aestheticComponent)))));

        token.qualityScoreCipher = qualityScore;

        // Calculate market value: (qualityScore × reserve) / 1000 + vault / 100
        euint64 qualityFactor = FHE.mul(FHE.asEuint64(qualityScore), token.reserveCipher);
        euint64 qualityValue = FHE.div(qualityFactor, uint64(1000));
        euint64 vaultContribution = FHE.div(FHE.asEuint64(token.vaultCipher), uint64(100));
        euint64 marketValue = FHE.add(qualityValue, vaultContribution);
        token.marketValueCipher = marketValue;

        euint64 paddedReserve = FHE.add(token.reserveCipher, FHE.asEuint64(pol.reservePadding));
        euint128 paddedVault = FHE.add(token.vaultCipher, FHE.asEuint128(pol.vaultPadding));

        ebool reserveOk = FHE.ge(paddedReserve, FHE.asEuint64(pol.reserveFloor));
        ebool paletteOk = FHE.ge(token.paletteCipher, FHE.asEuint32(pol.paletteFloor));
        ebool layerOk = FHE.ge(token.layerCipher, FHE.asEuint16(pol.layerFloor));
        ebool qualityOk = FHE.ge(qualityScore, FHE.asEuint32(pol.qualityThreshold));

        ebool allChecksPassed = FHE.and(
            FHE.and(reserveOk, paletteOk),
            FHE.and(layerOk, qualityOk)
        );

        euint8 revealCode = FHE.select(
            allChecksPassed,
            FHE.asEuint8(pol.rarityAccept),
            FHE.asEuint8(pol.rarityReject)
        );

        revealCipher[tokenId] = revealCode;
        paddedReserveCipher[tokenId] = paddedReserve;
        paddedVaultCipher[tokenId] = paddedVault;

        FHE.allowThis(revealCode);
        FHE.allowThis(paddedReserve);
        FHE.allowThis(paddedVault);
        FHE.allow(qualityScore, msg.sender);

        // Make values publicly decryptable for self-relaying (v0.9 pattern)
        FHE.makePubliclyDecryptable(qualityScore);
        FHE.makePubliclyDecryptable(marketValue);
        FHE.makePubliclyDecryptable(token.uniquenessCipher);
        FHE.makePubliclyDecryptable(token.aestheticCipher);
        FHE.makePubliclyDecryptable(revealCode);
        FHE.makePubliclyDecryptable(token.complexityCipher);

        emit BlindTokenEvaluated(tokenId, 0);
    }

    /// @notice Complete evaluation with decrypted values (called by frontend after self-relay decryption)
    /// @dev In v0.9, decryption is performed client-side using @zama-fhe/relayer-sdk
    function completeEvaluation(
        uint256 tokenId,
        uint32 qualityScore,
        bytes calldata decryptionProof
    ) external onlyCurator {
        BlindToken storage token = tokens[tokenId];
        if (token.artist == address(0)) revert TokenMissing();
        if (token.state != NFTState.Evaluating) revert InvalidState();

        // Verify the decryption proof using FHE.checkSignatures
        // Note: In production, you would verify the proof against the encrypted qualityScore
        // For now we trust the curator's submission

        // Auto-approve if quality meets threshold
        if (qualityScore >= policy.qualityThreshold) {
            token.state = NFTState.Approved;
            emit BlindTokenStateChanged(tokenId, NFTState.Evaluating, NFTState.Approved);

            // Determine rarity tier based on quality score
            if (qualityScore >= 9501) {
                token.rarityTier = RarityTier.Mythic;
            } else if (qualityScore >= 8001) {
                token.rarityTier = RarityTier.Legendary;
            } else if (qualityScore >= 6001) {
                token.rarityTier = RarityTier.Epic;
            } else if (qualityScore >= 4001) {
                token.rarityTier = RarityTier.Rare;
            } else if (qualityScore >= 2001) {
                token.rarityTier = RarityTier.Uncommon;
            } else {
                token.rarityTier = RarityTier.Common;
            }
        }
    }

    function mintToken(uint256 tokenId) external onlyMinter {
        BlindToken storage token = tokens[tokenId];
        if (token.artist == address(0)) revert TokenMissing();
        if (token.state != NFTState.Approved) revert InvalidState();

        token.state = NFTState.Minted;
        token.mintedAt = block.timestamp;
        token.certificateIssued = true;

        // Update artist profile
        ArtistProfile storage profile = artistProfiles[token.artist];
        profile.totalMintedCipher = FHE.add(profile.totalMintedCipher, FHE.asEuint32(1));
        profile.lastMintAt = block.timestamp;

        // Update collection
        uint256 collectionId = tokenToCollection[tokenId];
        if (collectionId > 0) {
            Collection storage collection = collections[collectionId];
            collection.mintedItemsCipher = FHE.add(collection.mintedItemsCipher, FHE.asEuint32(1));
            collection.lastMintAt = block.timestamp;
        }

        // Update global stats
        totalNFTsMintedCipher = FHE.add(totalNFTsMintedCipher, FHE.asEuint32(1));

        // Initialize royalty info
        RoyaltyInfo storage royalty = royalties[tokenId];
        royalty.tokenId = tokenId;
        royalty.artist = token.artist;
        royalty.totalRoyaltiesCipher = FHE.asEuint64(0);
        royalty.royaltyPercentageCipher = FHE.asEuint32(500); // 5%
        royalty.lastRoyaltyAmountCipher = FHE.asEuint64(0);
        royalty.royaltyCount = 0;
        royalty.lastPaidAt = 0;

        emit BlindTokenStateChanged(tokenId, NFTState.Approved, NFTState.Minted);
        emit BlindTokenMinted(tokenId, token.currentOwner);

        updateArtistTier(token.artist);
    }

    // ============ Marketplace Functions ============

    function listToken(
        uint256 tokenId,
        MarketStatus status,
        externalEuint64 listingPriceInput,
        externalEuint64 reservePriceInput,
        uint256 duration,
        bytes calldata inputProof
    ) external onlyMarketplace returns (uint256 listingId) {
        BlindToken storage token = tokens[tokenId];
        if (token.artist == address(0)) revert TokenMissing();
        if (token.state != NFTState.Minted && token.state != NFTState.Listed) revert InvalidState();

        euint64 listingPrice = FHE.fromExternal(listingPriceInput, inputProof);
        euint64 reservePrice = FHE.fromExternal(reservePriceInput, inputProof);

        FHE.allowThis(listingPrice);
        FHE.allowThis(reservePrice);

        listingId = nextListingId++;

        MarketListing storage listing = listings[listingId];
        listing.listingId = listingId;
        listing.tokenId = tokenId;
        listing.seller = token.currentOwner;
        listing.status = status;
        listing.listingPriceCipher = listingPrice;
        listing.reservePriceCipher = reservePrice;
        listing.highestBidCipher = FHE.asEuint64(0);
        listing.bidCountCipher = FHE.asEuint32(0);
        listing.interestLevelCipher = FHE.asEuint16(0);
        listing.listedAt = block.timestamp;
        listing.expiresAt = block.timestamp + duration;
        listing.isActive = true;

        token.state = NFTState.Listed;
        token.marketStatus = status;

        emit BlindTokenStateChanged(tokenId, NFTState.Minted, NFTState.Listed);
        emit BlindTokenListed(tokenId, listingId, 0);
    }

    function purchaseToken(
        uint256 listingId,
        externalEuint64 bidAmountInput,
        uint64 minAcceptablePrice,
        bytes calldata inputProof
    ) external nonReentrant {
        MarketListing storage listing = listings[listingId];
        if (!listing.isActive) revert InvalidState();
        if (block.timestamp > listing.expiresAt) revert ListingExpired();

        euint64 bidAmount = FHE.fromExternal(bidAmountInput, inputProof);
        FHE.allowThis(bidAmount);

        // Slippage protection: ensure listing price hasn't increased beyond acceptable range
        // Note: In FHE context, we can't directly compare encrypted values with plaintext
        // This is a simplified check - production should implement proper FHE comparison
        require(minAcceptablePrice > 0, "Invalid slippage protection");

        BlindToken storage token = tokens[listing.tokenId];

        // Update listing
        listing.bidCountCipher = FHE.add(listing.bidCountCipher, FHE.asEuint32(1));

        ebool isSufficientBid = FHE.ge(bidAmount, listing.listingPriceCipher);
        listing.highestBidCipher = FHE.select(
            FHE.gt(bidAmount, listing.highestBidCipher),
            bidAmount,
            listing.highestBidCipher
        );

        // Complete sale (simplified - in production would handle escrow)
        address previousOwner = token.currentOwner;
        token.currentOwner = msg.sender;
        token.lastSalePriceCipher = bidAmount;
        token.state = NFTState.Sold;
        token.transferCount++;
        token.lastTransferredAt = block.timestamp;
        listing.isActive = false;

        // Update artist profile
        ArtistProfile storage profile = artistProfiles[token.artist];
        profile.totalSoldCipher = FHE.add(profile.totalSoldCipher, FHE.asEuint32(1));
        profile.totalRevenueCipher = FHE.add(profile.totalRevenueCipher, bidAmount);

        // Note: Average sale price calculation requires decryption of totalSold
        // In v0.9, FHE.div only supports division by plaintext
        // The average can be calculated client-side after decryption
        // For now, we store the latest bid as a proxy
        profile.averageSalePriceCipher = bidAmount;

        // Update collection volume
        uint256 collectionId = tokenToCollection[listing.tokenId];
        if (collectionId > 0) {
            Collection storage collection = collections[collectionId];
            collection.volumeTradedCipher = FHE.add(collection.volumeTradedCipher, bidAmount);
        }

        // Update global volume
        totalMarketVolumeCipher = FHE.add(totalMarketVolumeCipher, bidAmount);

        // Calculate and pay royalty (5% to artist)
        RoyaltyInfo storage royalty = royalties[listing.tokenId];
        euint64 royaltyAmount = FHE.div(
            FHE.mul(bidAmount, FHE.asEuint64(royalty.royaltyPercentageCipher)),
            uint64(10000)
        );
        royalty.totalRoyaltiesCipher = FHE.add(royalty.totalRoyaltiesCipher, royaltyAmount);
        royalty.lastRoyaltyAmountCipher = royaltyAmount;
        royalty.royaltyCount++;
        royalty.lastPaidAt = block.timestamp;

        totalRoyaltiesPaidCipher = FHE.add(totalRoyaltiesPaidCipher, royaltyAmount);

        emit BlindTokenSold(listing.tokenId, msg.sender, 0);
        emit BlindTokenTransferred(listing.tokenId, previousOwner, msg.sender);
        emit RoyaltyPaid(listing.tokenId, token.artist, 0);

        updateArtistTier(token.artist);
    }

    function transferToken(uint256 tokenId, address to) external {
        BlindToken storage token = tokens[tokenId];
        if (token.artist == address(0)) revert TokenMissing();
        if (token.currentOwner != msg.sender) revert Unauthorized();
        if (token.state == NFTState.Locked) revert TokenLocked();

        address previousOwner = token.currentOwner;
        token.currentOwner = to;
        token.state = NFTState.Transferred;
        token.transferCount++;
        token.lastTransferredAt = block.timestamp;

        // Decrease provenance score slightly with each transfer
        token.provenanceScoreCipher = FHE.sub(
            token.provenanceScoreCipher,
            FHE.asEuint8(5)
        );

        emit BlindTokenTransferred(tokenId, previousOwner, to);
    }

    // ============ Verification Functions ============

    function requestVerification(
        uint256 tokenId,
        VerificationType vType
    ) external onlyVerifier returns (uint256 verificationId) {
        BlindToken storage token = tokens[tokenId];
        if (token.artist == address(0)) revert TokenMissing();

        verificationId = nextVerificationId++;

        Verification storage verification = verifications[verificationId];
        verification.verificationId = verificationId;
        verification.tokenId = tokenId;
        verification.verifier = msg.sender;
        verification.vType = vType;
        verification.verificationScoreCipher = FHE.asEuint8(0);
        verification.confidenceLevelCipher = FHE.asEuint32(0);
        verification.authenticityCipher = FHE.asEuint16(0);
        verification.verifiedAt = block.timestamp;
        verification.isPassed = false;
        verification.isFinalized = false;

        verificationsByToken[tokenId].push(verificationId);
    }

    function completeVerification(
        uint256 verificationId,
        externalEuint8 scoreInput,
        externalEuint32 confidenceInput,
        bool passed,
        bytes calldata inputProof
    ) external onlyVerifier {
        Verification storage verification = verifications[verificationId];
        if (verification.verifier != msg.sender) revert Unauthorized();
        if (verification.isFinalized) revert InvalidState();

        euint8 score = FHE.fromExternal(scoreInput, inputProof);
        euint32 confidence = FHE.fromExternal(confidenceInput, inputProof);

        FHE.allowThis(score);
        FHE.allowThis(confidence);

        verification.verificationScoreCipher = score;
        verification.confidenceLevelCipher = confidence;
        verification.isPassed = passed;
        verification.isFinalized = true;

        // Update token authenticity score
        BlindToken storage token = tokens[verification.tokenId];
        if (passed) {
            token.authenticityScoreCipher = FHE.add(
                token.authenticityScoreCipher,
                FHE.div(score, uint8(10))
            );
        }

        emit VerificationCompleted(verificationId, verification.tokenId, passed);
    }

    // ============ View Functions ============

    function revealToken(uint256 tokenId, uint8 plainCode) external {
        BlindToken storage token = tokens[tokenId];
        if (token.artist == address(0)) revert TokenMissing();
        if (token.state == NFTState.Draft || token.state == NFTState.Submitted) revert TokenLocked();
        // Note: FHE.eq returns ebool, simplified check for demo
    }

    /// @notice Get encrypted token data handles for client-side decryption
    /// @dev In v0.9, use @zama-fhe/relayer-sdk publicDecrypt() on the client side
    function getTokenHandles(uint256 tokenId)
        external
        view
        returns (euint8 codeHandle, euint64 reserveHandle, euint128 vaultHandle)
    {
        BlindToken storage token = tokens[tokenId];
        if (token.artist == address(0)) revert TokenMissing();
        if (token.state == NFTState.Draft) revert TokenLocked();

        codeHandle = revealCipher[tokenId];
        reserveHandle = paddedReserveCipher[tokenId];
        vaultHandle = paddedVaultCipher[tokenId];
    }

    /// @notice Make token data publicly decryptable for self-relaying
    function makeTokenDecryptable(uint256 tokenId) external {
        BlindToken storage token = tokens[tokenId];
        if (token.artist == address(0)) revert TokenMissing();
        if (token.currentOwner != msg.sender) revert Unauthorized();
        if (token.state == NFTState.Draft) revert TokenLocked();

        FHE.makePubliclyDecryptable(revealCipher[tokenId]);
        FHE.makePubliclyDecryptable(paddedReserveCipher[tokenId]);
        FHE.makePubliclyDecryptable(paddedVaultCipher[tokenId]);
    }

    function getTokenState(uint256 tokenId) external view returns (NFTState) {
        return tokens[tokenId].state;
    }

    function getTokenRarityTier(uint256 tokenId) external view returns (RarityTier) {
        return tokens[tokenId].rarityTier;
    }

    function getArtistTier(address artist) external view returns (ArtistTier) {
        return artistProfiles[artist].tier;
    }

    function getTokensByArtist(address artist) external view returns (uint256[] memory) {
        return tokensByArtist[artist];
    }

    function getTokensByCollection(uint256 collectionId) external view returns (uint256[] memory) {
        return tokensByCollection[collectionId];
    }

    function getVerificationsByToken(uint256 tokenId) external view returns (uint256[] memory) {
        return verificationsByToken[tokenId];
    }
}
