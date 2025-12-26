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

interface IVeilMintBlindNFT {
    function getTokenHandles(uint256 tokenId)
        external
        view
        returns (euint8 codeHandle, euint64 reserveHandle, euint128 vaultHandle);
}

contract VeilMintGalleryCoordinator is ZamaEthereumConfig {
    // ============ Enums ============

    enum GalleryState {
        Planning,        // 0: Initial planning phase
        Curating,        // 1: Curating artworks
        Reviewing,       // 2: Under review
        Approved,        // 3: Approved for exhibition
        Active,          // 4: Gallery is active
        Featured,        // 5: Featured exhibition
        Concluded,       // 6: Exhibition concluded
        Archiving,       // 7: Being archived
        Archived,        // 8: Archived
        Cancelled        // 9: Cancelled
    }

    enum TicketStatus {
        Pending,         // 0: Ticket pending
        Validated,       // 1: Validated
        Inspected,       // 2: Inspected
        Featured,        // 3: Featured in gallery
        Sold,            // 4: Artwork sold
        Expired          // 5: Ticket expired
    }

    enum CuratorTier {
        Junior,          // 0: 0-5 exhibitions
        Associate,       // 1: 6-15 exhibitions
        Senior,          // 2: 16-50 exhibitions
        Lead,            // 3: 51-100 exhibitions
        Director,        // 4: 101-300 exhibitions
        Chief            // 5: 300+ exhibitions
    }

    enum ExhibitionType {
        Solo,            // 0: Solo artist exhibition
        Group,           // 1: Group exhibition
        Thematic,        // 2: Thematic collection
        Charity,         // 3: Charity event
        Auction,         // 4: Auction event
        Virtual,         // 5: Virtual gallery
        Hybrid           // 6: Hybrid (physical + virtual)
    }

    enum VisitorCategory {
        General,         // 0: General public
        Student,         // 1: Student visitor
        Collector,       // 2: Art collector
        Critic,          // 3: Art critic
        Artist,          // 4: Fellow artist
        VIP,             // 5: VIP guest
        Sponsor          // 6: Sponsor/Patron
    }

    enum TicketPricing {
        Free,            // 0: Free entry
        Standard,        // 1: Standard pricing
        Premium,         // 2: Premium pricing
        Exclusive,       // 3: Exclusive access
        EarlyBird,       // 4: Early bird discount
        GroupDiscount,   // 5: Group discount
        MemberOnly       // 6: Member only
    }

    // ============ Structs ============

    struct GalleryTicket {
        bytes32 ticketId;
        uint256 tokenId;
        address curator;
        TicketStatus status;
        ExhibitionType exhibitionType;

        euint8 accessCipher;           // Access level (0-100)
        euint32 paletteCipher;         // Palette score from NFT
        euint32 qualityScoreCipher;    // Quality assessment (0-10000)
        euint32 curatorRatingCipher;   // Curator rating (0-10000)
        euint16 popularityScoreCipher; // Popularity (0-10000)
        euint16 visitorCountCipher;    // Number of visitors
        euint64 valuationCipher;       // Estimated valuation
        euint64 entryFeeCipher;        // Entry fee collected
        euint32 engagementScoreCipher; // Engagement level (0-10000)
        euint16 criticalAcclaimCipher; // Critical acclaim (0-10000)
        euint8 featuredScoreCipher;    // Featured score (0-100)

        uint256 createdAt;
        uint256 inspectedAt;
        uint256 featuredAt;
        uint256 expiresAt;
        bool inspected;
        bool isFeatured;
        bool isActive;
    }

    struct Gallery {
        uint256 galleryId;
        address owner;
        GalleryState state;
        ExhibitionType exhibitionType;
        string name;
        string description;
        string location;

        euint32 totalTicketsCipher;    // Total tickets issued
        euint32 activeTicketsCipher;   // Active tickets
        euint32 featuredTicketsCipher; // Featured artworks
        euint64 totalRevenueCipher;    // Total revenue
        euint64 avgValuationCipher;    // Average valuation
        euint32 visitorCountCipher;    // Total visitors
        euint32 reputationScoreCipher; // Gallery reputation (0-10000)
        euint16 satisfactionScoreCipher;// Visitor satisfaction (0-10000)
        euint16 criticalRatingCipher;  // Critical rating (0-10000)

        uint256 createdAt;
        uint256 openedAt;
        uint256 closedAt;
        uint256 duration;
        bool isActive;
        bool isCurated;
    }

    struct CuratorProfile {
        address curator;
        CuratorTier tier;

        euint32 totalExhibitionsCipher;     // Total exhibitions curated
        euint32 successfulExhibitionsCipher;// Successful exhibitions
        euint64 totalRevenueCuratedCipher;  // Total revenue from curated works
        euint32 reputationScoreCipher;      // Reputation (0-10000)
        euint16 qualityRatingCipher;        // Quality rating (0-10000)
        euint16 criticalAcclaimCipher;      // Critical acclaim (0-10000)
        euint8 expertiseLevelCipher;        // Expertise level (0-100)
        euint8 networkStrengthCipher;       // Network strength (0-100)

        uint256 createdAt;
        uint256 lastCuratedAt;
        uint256 followerCount;
        bool isVerified;
        bool isPremium;
    }

    struct Exhibition {
        uint256 exhibitionId;
        uint256 galleryId;
        address organizer;
        ExhibitionType exType;
        GalleryState state;

        euint32 artworkCountCipher;        // Number of artworks
        euint32 visitorCountCipher;        // Visitors attended
        euint64 ticketRevenueCipher;       // Ticket revenue
        euint64 artworkSalesCipher;        // Artwork sales
        euint32 engagementScoreCipher;     // Engagement (0-10000)
        euint16 satisfactionScoreCipher;   // Satisfaction (0-10000)
        euint16 criticalScoreCipher;       // Critical score (0-10000)
        euint8 successRatingCipher;        // Success rating (0-100)

        uint256 startDate;
        uint256 endDate;
        uint256 createdAt;
        bool isActive;
        bool isFinalized;
    }

    struct Visitor {
        address visitorAddress;
        VisitorCategory category;
        TicketPricing pricingTier;

        euint32 totalVisitsCipher;         // Total visits
        euint32 artworksViewedCipher;      // Artworks viewed
        euint64 totalSpentCipher;          // Total spent
        euint32 engagementScoreCipher;     // Engagement (0-10000)
        euint16 loyaltyScoreCipher;        // Loyalty (0-10000)
        euint16 influenceScoreCipher;      // Influence (0-10000)
        euint8 membershipLevelCipher;      // Membership level (0-100)

        uint256 firstVisit;
        uint256 lastVisit;
        bool isMember;
        bool isVIP;
    }

    struct TicketSale {
        uint256 saleId;
        bytes32 ticketId;
        address buyer;
        TicketPricing pricingType;

        euint64 salePriceCipher;           // Sale price
        euint64 commissionCipher;          // Commission taken
        euint32 satisfactionScoreCipher;   // Buyer satisfaction

        uint256 soldAt;
        bool isCompleted;
    }

    struct CriticalReview {
        uint256 reviewId;
        bytes32 ticketId;
        address critic;

        euint32 overallScoreCipher;        // Overall score (0-10000)
        euint16 technicalScoreCipher;      // Technical score (0-10000)
        euint16 creativityScoreCipher;     // Creativity score (0-10000)
        euint16 impactScoreCipher;         // Impact score (0-10000)
        euint8 recommendationCipher;       // Recommendation (0-100)

        uint256 reviewedAt;
        bool isPublished;
        bool isFeatured;
    }

    // ============ State Variables ============

    IVeilMintBlindNFT public immutable blindNFT;

    uint256 public nextGalleryId;
    uint256 public nextExhibitionId;
    uint256 public nextSaleId;
    uint256 public nextReviewId;

    mapping(bytes32 => GalleryTicket) public tickets;
    mapping(uint256 => Gallery) public galleries;
    mapping(address => CuratorProfile) public curatorProfiles;
    mapping(uint256 => Exhibition) public exhibitions;
    mapping(address => Visitor) public visitors;
    mapping(uint256 => TicketSale) public sales;
    mapping(uint256 => CriticalReview) public reviews;

    mapping(uint256 => bytes32[]) public ticketsByGallery;
    mapping(address => bytes32[]) public ticketsByCurator;
    mapping(uint256 => uint256[]) public exhibitionsByGallery;
    mapping(bytes32 => uint256[]) public reviewsByTicket;
    mapping(uint256 => bytes32[]) public ticketsByExhibition;

    // Aggregate statistics
    euint64 public totalGalleryRevenueCipher;
    euint32 public totalGalleriesCipher;
    euint32 public totalExhibitionsCipher;
    euint32 public totalVisitorsCipher;
    euint64 public totalArtworkSalesCipher;

    // Roles
    mapping(address => bool) public curatorRole;
    mapping(address => bool) public galleryManagerRole;
    mapping(address => bool) public reviewerRole;
    mapping(address => bool) public salesManagerRole;
    mapping(address => bool) public analyticsRole;

    address public admin;
    address public pendingAdmin;

    // ============ Events ============

    event AdminTransferInitiated(address indexed currentAdmin, address indexed pendingAdmin);
    event AdminTransferred(address indexed previousAdmin, address indexed newAdmin);
    event GalleryTicketIssued(bytes32 indexed ticketId, uint256 indexed tokenId, address indexed curator);
    event GalleryTicketStateChanged(bytes32 indexed ticketId, TicketStatus oldStatus, TicketStatus newStatus);
    event GalleryTicketInspected(bytes32 indexed ticketId, uint256 qualityScore);
    event GalleryTicketFeatured(bytes32 indexed ticketId, uint256 galleryId);
    event GalleryCreated(uint256 indexed galleryId, address indexed owner, ExhibitionType exhibitionType);
    event GalleryStateChanged(uint256 indexed galleryId, GalleryState oldState, GalleryState newState);
    event ExhibitionCreated(uint256 indexed exhibitionId, uint256 indexed galleryId, ExhibitionType exType);
    event ExhibitionConcluded(uint256 indexed exhibitionId, uint256 totalRevenue);
    event CuratorTierUpgraded(address indexed curator, CuratorTier newTier);
    event TicketSold(uint256 indexed saleId, bytes32 indexed ticketId, address indexed buyer);
    event ReviewPublished(uint256 indexed reviewId, bytes32 indexed ticketId, address indexed critic);
    event VisitorRegistered(address indexed visitor, VisitorCategory category);
    event RoleGranted(address indexed account, string role);
    event RoleRevoked(address indexed account, string role);

    // ============ Errors ============

    error TicketMissing();
    error TicketNotReady();
    error GalleryNotFound();
    error ExhibitionNotFound();
    error InvalidState();
    error Unauthorized();
    error AlreadyExists();
    error Expired();

    // ============ Modifiers ============

    modifier onlyAdmin() {
        if (msg.sender != admin) revert Unauthorized();
        _;
    }

    modifier onlyCurator() {
        if (!curatorRole[msg.sender] && msg.sender != admin) revert Unauthorized();
        _;
    }

    modifier onlyGalleryManager() {
        if (!galleryManagerRole[msg.sender] && msg.sender != admin) revert Unauthorized();
        _;
    }

    modifier onlyReviewer() {
        if (!reviewerRole[msg.sender] && msg.sender != admin) revert Unauthorized();
        _;
    }

    modifier onlySalesManager() {
        if (!salesManagerRole[msg.sender] && msg.sender != admin) revert Unauthorized();
        _;
    }

    modifier onlyAnalytics() {
        if (!analyticsRole[msg.sender] && msg.sender != admin) revert Unauthorized();
        _;
    }


    // ============ Constructor ============

    constructor(address blindNFTAddress) {
        admin = msg.sender;
        blindNFT = IVeilMintBlindNFT(blindNFTAddress);

        curatorRole[msg.sender] = true;
        galleryManagerRole[msg.sender] = true;
        reviewerRole[msg.sender] = true;
        salesManagerRole[msg.sender] = true;
        analyticsRole[msg.sender] = true;

        totalGalleryRevenueCipher = FHE.asEuint64(0);
        totalGalleriesCipher = FHE.asEuint32(0);
        totalExhibitionsCipher = FHE.asEuint32(0);
        totalVisitorsCipher = FHE.asEuint32(0);
        totalArtworkSalesCipher = FHE.asEuint64(0);
    }

    // ============ Admin Transfer ============

    function transferAdmin(address newAdmin) external onlyAdmin {
        require(newAdmin != address(0), "Invalid address");
        pendingAdmin = newAdmin;
        emit AdminTransferInitiated(admin, newAdmin);
    }

    function acceptAdmin() external {
        require(msg.sender == pendingAdmin, "Not pending admin");
        address previousAdmin = admin;
        admin = pendingAdmin;
        pendingAdmin = address(0);
        emit AdminTransferred(previousAdmin, admin);
    }

    // ============ Role Management ============

    function grantCuratorRole(address account) external onlyAdmin {
        curatorRole[account] = true;
        emit RoleGranted(account, "CURATOR");
    }

    function revokeCuratorRole(address account) external onlyAdmin {
        curatorRole[account] = false;
        emit RoleRevoked(account, "CURATOR");
    }

    function grantGalleryManagerRole(address account) external onlyAdmin {
        galleryManagerRole[account] = true;
        emit RoleGranted(account, "GALLERY_MANAGER");
    }

    function revokeGalleryManagerRole(address account) external onlyAdmin {
        galleryManagerRole[account] = false;
        emit RoleRevoked(account, "GALLERY_MANAGER");
    }

    function grantReviewerRole(address account) external onlyAdmin {
        reviewerRole[account] = true;
        emit RoleGranted(account, "REVIEWER");
    }

    function revokeReviewerRole(address account) external onlyAdmin {
        reviewerRole[account] = false;
        emit RoleRevoked(account, "REVIEWER");
    }

    function grantSalesManagerRole(address account) external onlyAdmin {
        salesManagerRole[account] = true;
        emit RoleGranted(account, "SALES_MANAGER");
    }

    function revokeSalesManagerRole(address account) external onlyAdmin {
        salesManagerRole[account] = false;
        emit RoleRevoked(account, "SALES_MANAGER");
    }

    function grantAnalyticsRole(address account) external onlyAdmin {
        analyticsRole[account] = true;
        emit RoleGranted(account, "ANALYTICS");
    }

    function revokeAnalyticsRole(address account) external onlyAdmin {
        analyticsRole[account] = false;
        emit RoleRevoked(account, "ANALYTICS");
    }

    // ============ Curator Profile Management ============

    function createCuratorProfile() external {
        if (curatorProfiles[msg.sender].curator != address(0)) revert AlreadyExists();

        CuratorProfile storage profile = curatorProfiles[msg.sender];
        profile.curator = msg.sender;
        profile.tier = CuratorTier.Junior;
        profile.totalExhibitionsCipher = FHE.asEuint32(0);
        profile.successfulExhibitionsCipher = FHE.asEuint32(0);
        profile.totalRevenueCuratedCipher = FHE.asEuint64(0);
        profile.reputationScoreCipher = FHE.asEuint32(5000);
        profile.qualityRatingCipher = FHE.asEuint16(5000);
        profile.criticalAcclaimCipher = FHE.asEuint16(5000);
        profile.expertiseLevelCipher = FHE.asEuint8(50);
        profile.networkStrengthCipher = FHE.asEuint8(50);
        profile.createdAt = block.timestamp;
        profile.lastCuratedAt = 0;
        profile.followerCount = 0;
        profile.isVerified = false;
        profile.isPremium = false;
    }

    function updateCuratorTier(address curator) internal {
        CuratorProfile storage profile = curatorProfiles[curator];
        if (profile.curator == address(0)) return;

        // Tier upgrade will be determined by decrypted totalExhibitions value
        // Thresholds: Junior(0-5), Associate(6-15), Senior(16-50), Lead(51-100), Director(101-300), Chief(300+)
    }

    // ============ Gallery Management ============

    function createGallery(
        ExhibitionType exhibitionType,
        string calldata name,
        string calldata description,
        string calldata location,
        uint256 duration
    ) external onlyGalleryManager returns (uint256 galleryId) {
        galleryId = nextGalleryId++;

        Gallery storage gallery = galleries[galleryId];
        gallery.galleryId = galleryId;
        gallery.owner = msg.sender;
        gallery.state = GalleryState.Planning;
        gallery.exhibitionType = exhibitionType;
        gallery.name = name;
        gallery.description = description;
        gallery.location = location;
        gallery.totalTicketsCipher = FHE.asEuint32(0);
        gallery.activeTicketsCipher = FHE.asEuint32(0);
        gallery.featuredTicketsCipher = FHE.asEuint32(0);
        gallery.totalRevenueCipher = FHE.asEuint64(0);
        gallery.avgValuationCipher = FHE.asEuint64(0);
        gallery.visitorCountCipher = FHE.asEuint32(0);
        gallery.reputationScoreCipher = FHE.asEuint32(5000);
        gallery.satisfactionScoreCipher = FHE.asEuint16(5000);
        gallery.criticalRatingCipher = FHE.asEuint16(5000);
        gallery.createdAt = block.timestamp;
        gallery.openedAt = 0;
        gallery.closedAt = 0;
        gallery.duration = duration;
        gallery.isActive = false;
        gallery.isCurated = false;

        totalGalleriesCipher = FHE.add(totalGalleriesCipher, FHE.asEuint32(1));

        emit GalleryCreated(galleryId, msg.sender, exhibitionType);
    }

    function updateGalleryState(uint256 galleryId, GalleryState newState) external onlyGalleryManager {
        Gallery storage gallery = galleries[galleryId];
        if (gallery.owner == address(0)) revert GalleryNotFound();

        GalleryState oldState = gallery.state;
        gallery.state = newState;

        if (newState == GalleryState.Active) {
            gallery.isActive = true;
            gallery.openedAt = block.timestamp;
        } else if (newState == GalleryState.Concluded || newState == GalleryState.Archived) {
            gallery.isActive = false;
            gallery.closedAt = block.timestamp;
        }

        emit GalleryStateChanged(galleryId, oldState, newState);
    }

    // ============ Gallery Ticket Functions ============

    function issueGalleryTicket(
        bytes32 ticketId,
        uint256 tokenId,
        uint256 galleryId,
        ExhibitionType exhibitionType,
        externalEuint8 accessInput,
        externalEuint32 paletteInput,
        externalEuint64 valuationInput,
        externalEuint64 entryFeeInput,
        uint256 validityDuration,
        bytes calldata inputProof
    ) external onlyCurator {
        if (tickets[ticketId].curator != address(0)) revert AlreadyExists();

        // Initialize curator profile if doesn't exist
        if (curatorProfiles[msg.sender].curator == address(0)) {
            this.createCuratorProfile();
        }

        euint8 access = FHE.fromExternal(accessInput, inputProof);
        euint32 palette = FHE.fromExternal(paletteInput, inputProof);
        euint64 valuation = FHE.fromExternal(valuationInput, inputProof);
        euint64 entryFee = FHE.fromExternal(entryFeeInput, inputProof);

        FHE.allowThis(access);
        FHE.allowThis(palette);
        FHE.allowThis(valuation);
        FHE.allowThis(entryFee);

        GalleryTicket storage ticket = tickets[ticketId];
        ticket.ticketId = ticketId;
        ticket.tokenId = tokenId;
        ticket.curator = msg.sender;
        ticket.status = TicketStatus.Pending;
        ticket.exhibitionType = exhibitionType;
        ticket.accessCipher = access;
        ticket.paletteCipher = palette;
        ticket.qualityScoreCipher = FHE.asEuint32(0);
        ticket.curatorRatingCipher = FHE.asEuint32(5000);
        ticket.popularityScoreCipher = FHE.asEuint16(0);
        ticket.visitorCountCipher = FHE.asEuint16(0);
        ticket.valuationCipher = valuation;
        ticket.entryFeeCipher = entryFee;
        ticket.engagementScoreCipher = FHE.asEuint32(0);
        ticket.criticalAcclaimCipher = FHE.asEuint16(0);
        ticket.featuredScoreCipher = FHE.asEuint8(0);
        ticket.createdAt = block.timestamp;
        ticket.inspectedAt = 0;
        ticket.featuredAt = 0;
        ticket.expiresAt = block.timestamp + validityDuration;
        ticket.inspected = false;
        ticket.isFeatured = false;
        ticket.isActive = true;

        if (galleryId > 0) {
            ticketsByGallery[galleryId].push(ticketId);
            Gallery storage gallery = galleries[galleryId];
            gallery.totalTicketsCipher = FHE.add(gallery.totalTicketsCipher, FHE.asEuint32(1));
            gallery.activeTicketsCipher = FHE.add(gallery.activeTicketsCipher, FHE.asEuint32(1));
        }

        ticketsByCurator[msg.sender].push(ticketId);

        emit GalleryTicketIssued(ticketId, tokenId, msg.sender);
    }

    function validateTicket(bytes32 ticketId) external onlyCurator {
        GalleryTicket storage ticket = tickets[ticketId];
        if (ticket.curator == address(0)) revert TicketMissing();
        if (ticket.status != TicketStatus.Pending) revert InvalidState();
        if (block.timestamp > ticket.expiresAt) revert Expired();

        TicketStatus oldStatus = ticket.status;
        ticket.status = TicketStatus.Validated;

        emit GalleryTicketStateChanged(ticketId, oldStatus, TicketStatus.Validated);
    }

    function inspectTicket(
        bytes32 ticketId,
        externalEuint32 qualityInput,
        externalEuint32 curatorRatingInput,
        externalEuint16 popularityInput,
        bytes calldata inputProof
    ) external onlyCurator {
        GalleryTicket storage ticket = tickets[ticketId];
        if (ticket.curator == address(0)) revert TicketMissing();
        if (ticket.status != TicketStatus.Validated) revert InvalidState();

        euint32 quality = FHE.fromExternal(qualityInput, inputProof);
        euint32 curatorRating = FHE.fromExternal(curatorRatingInput, inputProof);
        euint16 popularity = FHE.fromExternal(popularityInput, inputProof);

        FHE.allowThis(quality);
        FHE.allowThis(curatorRating);
        FHE.allowThis(popularity);

        ticket.qualityScoreCipher = quality;
        ticket.curatorRatingCipher = curatorRating;
        ticket.popularityScoreCipher = popularity;

        // Calculate engagement score (0-10000):
        // quality×40% + curatorRating×30% + popularity×20% + access×100×10%

        euint32 qualityComponent = FHE.div(
            FHE.mul(quality, uint32(40)),
            uint32(100)
        );

        euint32 ratingComponent = FHE.div(
            FHE.mul(curatorRating, uint32(30)),
            uint32(100)
        );

        euint32 popularityComponent = FHE.div(
            FHE.mul(FHE.asEuint32(popularity), uint32(20)),
            uint32(100)
        );

        euint32 accessComponent = FHE.div(
            FHE.mul(FHE.asEuint32(FHE.mul(ticket.accessCipher, uint8(100))), uint32(10)),
            uint32(100)
        );

        euint32 engagementScore = FHE.add(qualityComponent,
            FHE.add(ratingComponent,
                FHE.add(popularityComponent, accessComponent)));

        ticket.engagementScoreCipher = engagementScore;

        ticket.status = TicketStatus.Inspected;
        ticket.inspected = true;
        ticket.inspectedAt = block.timestamp;

        // Make values publicly decryptable for self-relaying (v0.9 pattern)
        FHE.makePubliclyDecryptable(engagementScore);
        FHE.makePubliclyDecryptable(quality);
        FHE.makePubliclyDecryptable(curatorRating);
        FHE.makePubliclyDecryptable(FHE.asEuint32(popularity));
        FHE.makePubliclyDecryptable(ticket.valuationCipher);
        FHE.makePubliclyDecryptable(ticket.entryFeeCipher);

        emit GalleryTicketInspected(ticketId, 0);
    }

    /// @notice Complete inspection with decrypted values (called by frontend after self-relay decryption)
    /// @dev In v0.9, decryption is performed client-side using @zama-fhe/relayer-sdk
    function completeInspection(
        bytes32 ticketId,
        uint32 engagementScore,
        uint32 qualityScore,
        bytes calldata decryptionProof
    ) external onlyCurator {
        GalleryTicket storage ticket = tickets[ticketId];
        if (ticket.curator == address(0)) revert TicketMissing();
        if (ticket.status != TicketStatus.Inspected) revert InvalidState();

        // Auto-feature high-quality tickets
        if (engagementScore >= 7000 && qualityScore >= 7000) {
            ticket.status = TicketStatus.Featured;
            ticket.isFeatured = true;
            ticket.featuredAt = block.timestamp;
            ticket.featuredScoreCipher = FHE.asEuint8(85);
        }
    }

    function featureTicket(bytes32 ticketId, uint256 galleryId) external onlyGalleryManager {
        GalleryTicket storage ticket = tickets[ticketId];
        if (ticket.curator == address(0)) revert TicketMissing();
        if (ticket.status != TicketStatus.Inspected) revert InvalidState();

        Gallery storage gallery = galleries[galleryId];
        if (gallery.owner == address(0)) revert GalleryNotFound();

        ticket.status = TicketStatus.Featured;
        ticket.isFeatured = true;
        ticket.featuredAt = block.timestamp;
        ticket.featuredScoreCipher = FHE.asEuint8(85);

        gallery.featuredTicketsCipher = FHE.add(gallery.featuredTicketsCipher, FHE.asEuint32(1));

        // Update curator profile
        CuratorProfile storage profile = curatorProfiles[ticket.curator];
        profile.successfulExhibitionsCipher = FHE.add(profile.successfulExhibitionsCipher, FHE.asEuint32(1));
        profile.lastCuratedAt = block.timestamp;

        emit GalleryTicketFeatured(ticketId, galleryId);

        updateCuratorTier(ticket.curator);
    }

    // ============ Exhibition Management ============

    function createExhibition(
        uint256 galleryId,
        ExhibitionType exType,
        uint256 startDate,
        uint256 endDate
    ) external onlyGalleryManager returns (uint256 exhibitionId) {
        Gallery storage gallery = galleries[galleryId];
        if (gallery.owner == address(0)) revert GalleryNotFound();

        exhibitionId = nextExhibitionId++;

        Exhibition storage exhibition = exhibitions[exhibitionId];
        exhibition.exhibitionId = exhibitionId;
        exhibition.galleryId = galleryId;
        exhibition.organizer = msg.sender;
        exhibition.exType = exType;
        exhibition.state = GalleryState.Planning;
        exhibition.artworkCountCipher = FHE.asEuint32(0);
        exhibition.visitorCountCipher = FHE.asEuint32(0);
        exhibition.ticketRevenueCipher = FHE.asEuint64(0);
        exhibition.artworkSalesCipher = FHE.asEuint64(0);
        exhibition.engagementScoreCipher = FHE.asEuint32(0);
        exhibition.satisfactionScoreCipher = FHE.asEuint16(0);
        exhibition.criticalScoreCipher = FHE.asEuint16(0);
        exhibition.successRatingCipher = FHE.asEuint8(0);
        exhibition.startDate = startDate;
        exhibition.endDate = endDate;
        exhibition.createdAt = block.timestamp;
        exhibition.isActive = false;
        exhibition.isFinalized = false;

        exhibitionsByGallery[galleryId].push(exhibitionId);
        totalExhibitionsCipher = FHE.add(totalExhibitionsCipher, FHE.asEuint32(1));

        emit ExhibitionCreated(exhibitionId, galleryId, exType);
    }

    function concludeExhibition(uint256 exhibitionId) external onlyGalleryManager {
        Exhibition storage exhibition = exhibitions[exhibitionId];
        if (exhibition.organizer == address(0)) revert ExhibitionNotFound();
        if (exhibition.isFinalized) revert InvalidState();

        exhibition.state = GalleryState.Concluded;
        exhibition.isActive = false;
        exhibition.isFinalized = true;

        Gallery storage gallery = galleries[exhibition.galleryId];
        gallery.totalRevenueCipher = FHE.add(gallery.totalRevenueCipher, exhibition.ticketRevenueCipher);

        totalGalleryRevenueCipher = FHE.add(totalGalleryRevenueCipher, exhibition.ticketRevenueCipher);
        totalArtworkSalesCipher = FHE.add(totalArtworkSalesCipher, exhibition.artworkSalesCipher);

        emit ExhibitionConcluded(exhibitionId, 0);
    }

    // ============ Visitor Management ============

    function registerVisitor(
        VisitorCategory category,
        TicketPricing pricingTier
    ) external {
        if (visitors[msg.sender].visitorAddress != address(0)) revert AlreadyExists();

        Visitor storage visitor = visitors[msg.sender];
        visitor.visitorAddress = msg.sender;
        visitor.category = category;
        visitor.pricingTier = pricingTier;
        visitor.totalVisitsCipher = FHE.asEuint32(0);
        visitor.artworksViewedCipher = FHE.asEuint32(0);
        visitor.totalSpentCipher = FHE.asEuint64(0);
        visitor.engagementScoreCipher = FHE.asEuint32(5000);
        visitor.loyaltyScoreCipher = FHE.asEuint16(5000);
        visitor.influenceScoreCipher = FHE.asEuint16(5000);
        visitor.membershipLevelCipher = FHE.asEuint8(0);
        visitor.firstVisit = block.timestamp;
        visitor.lastVisit = block.timestamp;
        visitor.isMember = false;
        visitor.isVIP = false;

        totalVisitorsCipher = FHE.add(totalVisitorsCipher, FHE.asEuint32(1));

        emit VisitorRegistered(msg.sender, category);
    }

    function recordVisit(
        uint256 galleryId,
        bytes32 ticketId,
        externalEuint64 amountSpentInput,
        bytes calldata inputProof
    ) external {
        Gallery storage gallery = galleries[galleryId];
        if (gallery.owner == address(0)) revert GalleryNotFound();

        GalleryTicket storage ticket = tickets[ticketId];
        if (ticket.curator == address(0)) revert TicketMissing();

        Visitor storage visitor = visitors[msg.sender];
        if (visitor.visitorAddress == address(0)) revert Unauthorized();

        euint64 amountSpent = FHE.fromExternal(amountSpentInput, inputProof);
        FHE.allowThis(amountSpent);

        visitor.totalVisitsCipher = FHE.add(visitor.totalVisitsCipher, FHE.asEuint32(1));
        visitor.artworksViewedCipher = FHE.add(visitor.artworksViewedCipher, FHE.asEuint32(1));
        visitor.totalSpentCipher = FHE.add(visitor.totalSpentCipher, amountSpent);
        visitor.lastVisit = block.timestamp;

        ticket.visitorCountCipher = FHE.add(ticket.visitorCountCipher, FHE.asEuint16(1));
        gallery.visitorCountCipher = FHE.add(gallery.visitorCountCipher, FHE.asEuint32(1));
        gallery.totalRevenueCipher = FHE.add(gallery.totalRevenueCipher, amountSpent);
    }

    // ============ Sales Management ============

    function recordTicketSale(
        bytes32 ticketId,
        address buyer,
        TicketPricing pricingType,
        externalEuint64 salePriceInput,
        externalEuint64 commissionInput,
        bytes calldata inputProof
    ) external onlySalesManager returns (uint256 saleId) {
        GalleryTicket storage ticket = tickets[ticketId];
        if (ticket.curator == address(0)) revert TicketMissing();

        euint64 salePrice = FHE.fromExternal(salePriceInput, inputProof);
        euint64 commission = FHE.fromExternal(commissionInput, inputProof);

        FHE.allowThis(salePrice);
        FHE.allowThis(commission);

        saleId = nextSaleId++;

        TicketSale storage sale = sales[saleId];
        sale.saleId = saleId;
        sale.ticketId = ticketId;
        sale.buyer = buyer;
        sale.pricingType = pricingType;
        sale.salePriceCipher = salePrice;
        sale.commissionCipher = commission;
        sale.satisfactionScoreCipher = FHE.asEuint32(5000);
        sale.soldAt = block.timestamp;
        sale.isCompleted = true;

        ticket.status = TicketStatus.Sold;

        // Update curator revenue
        CuratorProfile storage profile = curatorProfiles[ticket.curator];
        profile.totalRevenueCuratedCipher = FHE.add(profile.totalRevenueCuratedCipher, salePrice);

        emit TicketSold(saleId, ticketId, buyer);
    }

    // ============ Review Management ============

    function submitReview(
        bytes32 ticketId,
        externalEuint32 overallScoreInput,
        externalEuint16 technicalInput,
        externalEuint16 creativityInput,
        externalEuint16 impactInput,
        externalEuint8 recommendationInput,
        bytes calldata inputProof
    ) external onlyReviewer returns (uint256 reviewId) {
        GalleryTicket storage ticket = tickets[ticketId];
        if (ticket.curator == address(0)) revert TicketMissing();

        euint32 overallScore = FHE.fromExternal(overallScoreInput, inputProof);
        euint16 technical = FHE.fromExternal(technicalInput, inputProof);
        euint16 creativity = FHE.fromExternal(creativityInput, inputProof);
        euint16 impact = FHE.fromExternal(impactInput, inputProof);
        euint8 recommendation = FHE.fromExternal(recommendationInput, inputProof);

        FHE.allowThis(overallScore);
        FHE.allowThis(technical);
        FHE.allowThis(creativity);
        FHE.allowThis(impact);
        FHE.allowThis(recommendation);

        reviewId = nextReviewId++;

        CriticalReview storage review = reviews[reviewId];
        review.reviewId = reviewId;
        review.ticketId = ticketId;
        review.critic = msg.sender;
        review.overallScoreCipher = overallScore;
        review.technicalScoreCipher = technical;
        review.creativityScoreCipher = creativity;
        review.impactScoreCipher = impact;
        review.recommendationCipher = recommendation;
        review.reviewedAt = block.timestamp;
        review.isPublished = false;
        review.isFeatured = false;

        reviewsByTicket[ticketId].push(reviewId);

        // Update ticket critical acclaim
        ticket.criticalAcclaimCipher = FHE.asEuint16(overallScore);
    }

    function publishReview(uint256 reviewId) external onlyReviewer {
        CriticalReview storage review = reviews[reviewId];
        if (review.critic != msg.sender) revert Unauthorized();
        if (review.isPublished) revert InvalidState();

        review.isPublished = true;

        emit ReviewPublished(reviewId, review.ticketId, msg.sender);
    }

    // ============ Analytics Functions ============

    function calculateGalleryPerformance(uint256 galleryId) external onlyAnalytics {
        Gallery storage gallery = galleries[galleryId];
        if (gallery.owner == address(0)) revert GalleryNotFound();

        // Calculate average valuation across all tickets
        // Calculate reputation score based on visitor count, revenue, critical ratings

        // Calculate reputation score (0-10000):
        // (visitorCount/100)×30% + (totalRevenue/1ether)×100×25% + satisfactionScore×25% + criticalRating×20%

        euint32 visitorComponent = FHE.div(
            FHE.mul(FHE.div(gallery.visitorCountCipher, uint32(100)), uint32(30)),
            uint32(100)
        );

        euint32 revenueInEther = FHE.asEuint32(FHE.div(gallery.totalRevenueCipher, uint64(1 ether)));
        euint32 revenueComponent = FHE.div(
            FHE.mul(FHE.mul(revenueInEther, uint32(100)), uint32(25)),
            uint32(100)
        );

        euint32 satisfactionComponent = FHE.div(
            FHE.mul(FHE.asEuint32(gallery.satisfactionScoreCipher), uint32(25)),
            uint32(100)
        );

        euint32 criticalComponent = FHE.div(
            FHE.mul(FHE.asEuint32(gallery.criticalRatingCipher), uint32(20)),
            uint32(100)
        );

        euint32 reputationScore = FHE.add(visitorComponent,
            FHE.add(revenueComponent,
                FHE.add(satisfactionComponent, criticalComponent)));

        gallery.reputationScoreCipher = reputationScore;
    }

    // ============ View Functions ============

    function isInspected(bytes32 ticketId) external view returns (bool) {
        return tickets[ticketId].inspected;
    }

    function getTicketStatus(bytes32 ticketId) external view returns (TicketStatus) {
        return tickets[ticketId].status;
    }

    function getGalleryState(uint256 galleryId) external view returns (GalleryState) {
        return galleries[galleryId].state;
    }

    function getCuratorTier(address curator) external view returns (CuratorTier) {
        return curatorProfiles[curator].tier;
    }

    function getTicketsByGallery(uint256 galleryId) external view returns (bytes32[] memory) {
        return ticketsByGallery[galleryId];
    }

    function getTicketsByCurator(address curator) external view returns (bytes32[] memory) {
        return ticketsByCurator[curator];
    }

    function getExhibitionsByGallery(uint256 galleryId) external view returns (uint256[] memory) {
        return exhibitionsByGallery[galleryId];
    }

    function getReviewsByTicket(bytes32 ticketId) external view returns (uint256[] memory) {
        return reviewsByTicket[ticketId];
    }

    function markInspected(bytes32 ticketId) external onlyCurator {
        GalleryTicket storage ticket = tickets[ticketId];
        if (ticket.curator == address(0)) revert TicketMissing();
        ticket.inspected = true;
    }
}
