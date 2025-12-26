const { ethers } = require("hardhat");

// FHEBlindNFT contract address (update after deployment)
const NFT_ADDRESS = "0xe1d83be7899f4e94FE80572671cFF55B0dC17DFA";

async function main() {
  console.log("Checking VeilMint NFT Contract Status...\n");

  const [deployer] = await ethers.getSigners();
  console.log("Using account:", deployer.address);

  const balance = await ethers.provider.getBalance(deployer.address);
  console.log("Account balance:", ethers.formatEther(balance), "ETH\n");

  // Connect to FHEBlindNFT contract
  const FHEBlindNFT = await ethers.getContractFactory("FHEBlindNFT");
  const nft = FHEBlindNFT.attach(NFT_ADDRESS);

  // Check current minting status using individual state variables
  const mintActive = await nft.mintActive();
  const maxSupply = await nft.maxSupply();
  const maxPerWallet = await nft.maxPerWallet();
  const mintPrice = await nft.mintPrice();
  const totalSupply = await nft.totalSupply();

  console.log("Current mint config:");
  console.log("  - Active:", mintActive);
  console.log("  - Max Supply:", maxSupply.toString());
  console.log("  - Max Per Wallet:", maxPerWallet.toString());
  console.log("  - Mint Price:", ethers.formatEther(mintPrice), "ETH");
  console.log("  - Current Supply:", totalSupply.toString());
  console.log();

  // If minting is not active, enable it
  if (!mintActive) {
    console.log("Activating minting...");
    const tx = await nft.setMintConfig(true, 10000, 10, 0);
    await tx.wait();
    console.log("Minting activated!");
  }

  console.log("\n✅ FHEBlindNFT contract is ready!");
  console.log("━".repeat(50));
  console.log("Contract Address:", NFT_ADDRESS);
  console.log("Explorer: https://sepolia.etherscan.io/address/" + NFT_ADDRESS);
  console.log("━".repeat(50));
  console.log("\nUsers can now mint NFTs through the frontend!");
  console.log("Each mint will create an NFT with encrypted traits.");
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error("Error:", error);
    process.exit(1);
  });
