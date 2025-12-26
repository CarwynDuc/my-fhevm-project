import { ethers } from "hardhat";

async function main() {
  const [deployer] = await ethers.getSigners();
  console.log("Deployer:", deployer.address);
  const FHEBlindNFT = await ethers.getContractFactory("FHEBlindNFT");
  const nft = await FHEBlindNFT.deploy("FHE Blind NFT", "FHENFT", deployer.address);
  await nft.waitForDeployment();
  console.log("FHEBlindNFT:", await nft.getAddress());

  // Activate minting with sane defaults
  const tx = await nft.setMintConfig(true, 5000, 1, 0);
  await tx.wait();
  console.log("Mint config set: active=true, maxSupply=5000, maxPerWallet=1, mintPrice=0");
}

main().catch((e) => { console.error(e); process.exit(1); });
