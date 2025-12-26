const { ethers } = require("hardhat");
const fs = require("fs");

async function main() {
  console.log("Starting VeilMint v0.9.1 deployment to Sepolia...\n");

  // Get deployer account
  const [deployer] = await ethers.getSigners();
  console.log("Deploying with account:", deployer.address);

  // Check balance
  const balance = await ethers.provider.getBalance(deployer.address);
  console.log("Account balance:", ethers.formatEther(balance), "ETH\n");

  if (balance < ethers.parseEther("0.01")) {
    console.warn("Warning: Low balance, deployment may fail\n");
  }

  const deployedContracts = {};

  // 1. Deploy VeilMintSimple
  console.log("1/4 Deploying VeilMintSimple...");
  const VeilMintSimple = await ethers.getContractFactory("VeilMintSimple");
  const veilMintSimple = await VeilMintSimple.deploy();
  await veilMintSimple.waitForDeployment();
  const veilMintSimpleAddress = await veilMintSimple.getAddress();
  console.log("   VeilMintSimple deployed to:", veilMintSimpleAddress);
  deployedContracts.VeilMintSimple = veilMintSimpleAddress;

  // 2. Deploy FHEBlindNFT
  console.log("2/4 Deploying FHEBlindNFT...");
  const FHEBlindNFT = await ethers.getContractFactory("FHEBlindNFT");
  const fheBlindNFT = await FHEBlindNFT.deploy("VeilMint Blind NFT", "VMNFT", deployer.address);
  await fheBlindNFT.waitForDeployment();
  const fheBlindNFTAddress = await fheBlindNFT.getAddress();
  console.log("   FHEBlindNFT deployed to:", fheBlindNFTAddress);

  // Activate minting
  console.log("   Activating minting config...");
  const mintTx = await fheBlindNFT.setMintConfig(true, 10000, 10, 0);
  await mintTx.wait();
  console.log("   Mint config set: active=true, maxSupply=10000, maxPerWallet=10, mintPrice=0");
  deployedContracts.FHEBlindNFT = fheBlindNFTAddress;

  // 3. Deploy VeilMintBlindNFT
  console.log("3/4 Deploying VeilMintBlindNFT...");
  const VeilMintBlindNFT = await ethers.getContractFactory("VeilMintBlindNFT");
  const veilMintBlindNFT = await VeilMintBlindNFT.deploy();
  await veilMintBlindNFT.waitForDeployment();
  const veilMintBlindNFTAddress = await veilMintBlindNFT.getAddress();
  console.log("   VeilMintBlindNFT deployed to:", veilMintBlindNFTAddress);
  deployedContracts.VeilMintBlindNFT = veilMintBlindNFTAddress;

  // 4. Deploy VeilMintGalleryCoordinator
  console.log("4/4 Deploying VeilMintGalleryCoordinator...");
  const VeilMintGalleryCoordinator = await ethers.getContractFactory("VeilMintGalleryCoordinator");
  const galleryCoordinator = await VeilMintGalleryCoordinator.deploy(veilMintBlindNFTAddress);
  await galleryCoordinator.waitForDeployment();
  const galleryCoordinatorAddress = await galleryCoordinator.getAddress();
  console.log("   VeilMintGalleryCoordinator deployed to:", galleryCoordinatorAddress);
  deployedContracts.VeilMintGalleryCoordinator = galleryCoordinatorAddress;

  console.log("\nDeployment complete!");
  console.log("━".repeat(50));
  console.log("Deployed Contracts (v0.9.1):");
  console.log("━".repeat(50));
  for (const [name, address] of Object.entries(deployedContracts)) {
    console.log(`${name}: ${address}`);
    console.log(`  Explorer: https://sepolia.etherscan.io/address/${address}`);
  }
  console.log("━".repeat(50));

  // Save deployment info
  const deploymentInfo = {
    version: "0.9.1",
    network: "sepolia",
    deployer: deployer.address,
    timestamp: new Date().toISOString(),
    contracts: deployedContracts
  };

  fs.writeFileSync(
    "deployment-v0.9.1.json",
    JSON.stringify(deploymentInfo, null, 2)
  );
  console.log("\nDeployment info saved to deployment-v0.9.1.json");
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error("Deployment failed:", error);
    process.exit(1);
  });
