// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import {FHE, euint32, externalEuint32, ebool} from "@fhevm/solidity/lib/FHE.sol";
import {ZamaEthereumConfig} from "@fhevm/solidity/config/ZamaConfig.sol";

/// @title FHEBlindNFT - Minimal FHE-enabled blind NFT
/// @notice Stores a per-token encrypted attribute; owner can request reencryption to view privately
contract FHEBlindNFT is ERC721Enumerable, Ownable, ZamaEthereumConfig, ReentrancyGuard {
    using Strings for uint256;

    uint256 public nextId;
    mapping(uint256 => euint32) private _secretTrait; // tokenId -> encrypted trait/score
    mapping(uint256 => uint256) public mintedAt;

    // Minting controls
    uint256 public maxSupply = type(uint256).max; // default unlimited until set
    uint256 public maxPerWallet = 1; // default 1 per wallet
    uint256 public mintPrice = 0; // default free
    bool public mintActive = false; // owner must activate
    mapping(address => uint256) public mintedPerWallet;

    event MintBlind(address indexed to, uint256 indexed tokenId);
    event TraitSet(uint256 indexed tokenId);

    constructor(string memory name_, string memory symbol_, address owner_) ERC721(name_, symbol_) Ownable(owner_) {}

    // ----------------------
    // Owner configuration
    // ----------------------
    function setMintConfig(
        bool _active,
        uint256 _maxSupply,
        uint256 _maxPerWallet,
        uint256 _mintPrice
    ) external onlyOwner {
        mintActive = _active;
        if (_maxSupply > 0) {
            require(_maxSupply >= nextId, "supply < minted");
            maxSupply = _maxSupply;
        }
        require(_maxPerWallet > 0, "per wallet = 0");
        maxPerWallet = _maxPerWallet;
        mintPrice = _mintPrice;
    }

    /// @notice Mint a blind NFT with an encrypted trait (e.g., rarity 0..100)
    /// @param to receiver
    /// @param ctTrait Raw ciphertext bytes produced by client (chain public key)
    function mintBlind(address to, externalEuint32 ctTrait, bytes calldata inputProof)
        external
        payable
        nonReentrant
        returns (uint256 tokenId)
    {
        require(mintActive, "mint inactive");
        require(nextId < maxSupply, "sold out");
        require(to == msg.sender, "only self");
        require(mintedPerWallet[msg.sender] < maxPerWallet, "wallet limit");
        require(msg.value == mintPrice, "bad value");

        tokenId = nextId++;
        _safeMint(to, tokenId);

        // Store encrypted trait and grant permissions
        _secretTrait[tokenId] = FHE.fromExternal(ctTrait, inputProof);
        FHE.allowThis(_secretTrait[tokenId]);  // Contract can access
        FHE.allow(_secretTrait[tokenId], to);   // Owner can access

        mintedAt[tokenId] = block.timestamp;
        unchecked { mintedPerWallet[msg.sender] += 1; }
        emit MintBlind(to, tokenId);
    }

    /// @notice Update an encrypted trait (owner only)
    function setTrait(uint256 tokenId, externalEuint32 ctTrait, bytes calldata inputProof) external {
        address owner_ = _ownerOf(tokenId);
        require(owner_ != address(0) && _isAuthorized(owner_, msg.sender, tokenId), "not owner");

        // Update encrypted trait and grant permissions
        _secretTrait[tokenId] = FHE.fromExternal(ctTrait, inputProof);
        FHE.allowThis(_secretTrait[tokenId]);
        FHE.allow(_secretTrait[tokenId], owner_);

        emit TraitSet(tokenId);
    }

    /// @notice Get the encrypted trait handle for a token
    function getTrait(uint256 tokenId) external view returns (euint32) {
        require(_ownerOf(tokenId) != address(0), "no token");
        return _secretTrait[tokenId];
    }

    /// @notice Verify that trait is greater than or equal to threshold
    /// @dev Returns encrypted bool - contract cannot decrypt but user can
    function verifyTraitGte(uint256 tokenId, externalEuint32 ctThreshold, bytes calldata thresholdProof)
        external
        returns (ebool)
    {
        require(_ownerOf(tokenId) != address(0), "no token");
        euint32 thr = FHE.fromExternal(ctThreshold, thresholdProof);
        return FHE.ge(_secretTrait[tokenId], thr);
    }

    // ----------------------
    // ERC721Enumerable overrides for OZ v5
    // ----------------------
    function supportsInterface(bytes4 interfaceId) public view override(ERC721Enumerable) returns (bool) {
        return super.supportsInterface(interfaceId);
    }

    /// @notice Override _update to grant FHE permissions to new owner on transfer
    function _update(address to, uint256 tokenId, address auth)
        internal
        override
        returns (address)
    {
        address previousOwner = super._update(to, tokenId, auth);

        // Grant permission to new owner on transfer (not on mint/burn)
        if (previousOwner != address(0) && to != address(0)) {
            FHE.allow(_secretTrait[tokenId], to);
        }

        return previousOwner;
    }

    /// @notice Batch mint blind NFTs (gas optimization)
    /// @param to Receiver address
    /// @param ctTraits Array of encrypted traits
    /// @param inputProof Single input proof for all traits
    function mintBlindBatch(
        address to,
        externalEuint32[] calldata ctTraits,
        bytes calldata inputProof
    ) external payable nonReentrant returns (uint256[] memory tokenIds) {
        require(mintActive, "mint inactive");
        uint256 count = ctTraits.length;
        require(count > 0 && count <= 10, "1-10 batch size");
        require(nextId + count <= maxSupply, "sold out");
        require(to == msg.sender, "only self");
        require(mintedPerWallet[msg.sender] + count <= maxPerWallet, "wallet limit");
        require(msg.value == mintPrice * count, "bad value");

        tokenIds = new uint256[](count);

        for (uint256 i = 0; i < count; i++) {
            uint256 tokenId = nextId++;
            tokenIds[i] = tokenId;

            _safeMint(to, tokenId);

            // Store encrypted trait and grant permissions
            _secretTrait[tokenId] = FHE.fromExternal(ctTraits[i], inputProof);
            FHE.allowThis(_secretTrait[tokenId]);
            FHE.allow(_secretTrait[tokenId], to);

            mintedAt[tokenId] = block.timestamp;
            emit MintBlind(to, tokenId);
        }

        unchecked { mintedPerWallet[msg.sender] += count; }
    }
}
