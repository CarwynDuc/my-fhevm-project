const { ethers } = require("hardhat");

async function main() {
  console.log("🚀 Starting VeilMintSimple deployment to Sepolia...\n");

  // Get deployer account
  const [deployer] = await ethers.getSigners();
  console.log("📝 Deploying with account:", deployer.address);

  // Check balance
  const balance = await ethers.provider.getBalance(deployer.address);
  console.log("💰 Account balance:", ethers.formatEther(balance), "ETH\n");

  if (balance < ethers.parseEther("0.01")) {
    console.warn("⚠️  Warning: Low balance, deployment may fail\n");
  }

  // Deploy contract
  console.log("📦 Deploying VeilMintSimple contract...");
  const VeilMintSimple = await ethers.getContractFactory("VeilMintSimple");

  const contract = await VeilMintSimple.deploy();
  await contract.waitForDeployment();

  const contractAddress = await contract.getAddress();
  console.log("✅ VeilMintSimple deployed to:", contractAddress);

  // Get transaction details
  const deployTx = contract.deploymentTransaction();
  console.log("📋 Deployment transaction:", deployTx.hash);

  // Wait for confirmations
  console.log("⏳ Waiting for 3 confirmations...");
  await deployTx.wait(3);
  console.log("✅ Confirmed!\n");

  // Verify contract state
  const totalMinted = await contract.totalMinted();
  console.log("📊 Initial totalMinted:", totalMinted.toString());

  console.log("\n🎉 Deployment complete!");
  console.log("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");
  console.log("Contract Address:", contractAddress);
  console.log("Network: Sepolia");
  console.log("Explorer: https://sepolia.etherscan.io/address/" + contractAddress);
  console.log("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n");

  // Save deployment info
  const fs = require("fs");
  const deploymentInfo = {
    contractName: "VeilMintSimple",
    contractAddress: contractAddress,
    deployerAddress: deployer.address,
    network: "sepolia",
    deploymentTxHash: deployTx.hash,
    timestamp: new Date().toISOString(),
    explorerUrl: `https://sepolia.etherscan.io/address/${contractAddress}`
  };

  fs.writeFileSync(
    "deployment-simple.json",
    JSON.stringify(deploymentInfo, null, 2)
  );
  console.log("💾 Deployment info saved to deployment-simple.json");
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error("❌ Deployment failed:", error);
    process.exit(1);
  });
