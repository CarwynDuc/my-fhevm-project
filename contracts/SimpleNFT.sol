// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

contract SimpleNFT is ERC721Enumerable, Ownable, ReentrancyGuard {
    uint256 public nextId;
    uint256 public maxSupply = 5000;
    uint256 public maxPerWallet = 10;
    uint256 public mintPrice = 0;
    bool public mintActive = true;
    
    mapping(uint256 => uint256) public mintedAt;
    mapping(address => uint256) public mintedPerWallet;
    mapping(uint256 => bytes32) public encryptedTrait; // Store mock encrypted trait
    
    event MintBlind(address indexed to, uint256 indexed tokenId);
    event TraitSet(uint256 indexed tokenId);
    
    constructor() ERC721("SimpleNFT", "SNFT") Ownable(msg.sender) {}
    
    function mintBlind(
        address to,
        bytes32 ctTrait,  // Simplified: just bytes32 instead of externalEuint32
        bytes calldata /* inputProof */
    ) external payable nonReentrant returns (uint256 tokenId) {
        require(mintActive, "mint inactive");
        require(nextId < maxSupply, "sold out");
        require(to == msg.sender, "only self");
        require(mintedPerWallet[msg.sender] < maxPerWallet, "wallet limit");
        require(msg.value == mintPrice, "bad value");
        
        tokenId = nextId++;
        _safeMint(to, tokenId);
        encryptedTrait[tokenId] = ctTrait; // Store the mock encrypted trait
        mintedAt[tokenId] = block.timestamp;
        unchecked { mintedPerWallet[msg.sender] += 1; }
        emit MintBlind(to, tokenId);
    }
    
    function setMintConfig(
        bool _active,
        uint256 _maxSupply,
        uint256 _maxPerWallet,
        uint256 _mintPrice
    ) external onlyOwner {
        mintActive = _active;
        if (_maxSupply > 0) {
            maxSupply = _maxSupply;
        }
        maxPerWallet = _maxPerWallet;
        mintPrice = _mintPrice;
    }
    
    function tokenURI(uint256 tokenId) public view override returns (string memory) {
        require(ownerOf(tokenId) != address(0), "Token does not exist");
        return string(abi.encodePacked(
            "data:application/json;base64,",
            "eyJuYW1lIjoiU2ltcGxlTkZUICMiLCAiZGVzY3JpcHRpb24iOiAiQSBzaW1wbGUgTkZUIGZvciB0ZXN0aW5nIn0="
        ));
    }
}