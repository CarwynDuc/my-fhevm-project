import { ethers } from "ethers";
import { createInstance as createRelayerInstance } from "@zama-fhe/relayer-sdk";
import * as dotenv from "dotenv";
dotenv.config();

// 环境变量：
// SEPOLIA_RPC_URL, DEPLOYER_PRIVATE_KEY, NFT_ADDRESS

async function main() {
  const rpc = process.env.SEPOLIA_RPC_URL || "";
  const pk = process.env.DEPLOYER_PRIVATE_KEY || "";
  const nftAddress = process.env.NFT_ADDRESS || "";
  if (!rpc || !pk || !nftAddress) {
    throw new Error("Missing SEPOLIA_RPC_URL or DEPLOYER_PRIVATE_KEY or NFT_ADDRESS");
  }

  const provider = new ethers.JsonRpcProvider(rpc);
  const wallet = new ethers.Wallet(pk, provider);
  const network = await provider.getNetwork();
  console.log("ChainId:", network.chainId.toString());
  console.log("Deployer:", wallet.address);

  // 初始化 Relayer SDK（使用默认测试网配置，如需自定义从环境变量覆盖）
  const instance = await createRelayerInstance({
    // Host（Sepolia）
    aclContractAddress: process.env.FHE_ACL_ADDRESS || '0x687820221192C5B662b25367F70076A37bc79b6c',
    kmsContractAddress: process.env.FHE_KMS_ADDRESS || '0x1364cBBf2cDF5032C47d8226a6f6FBD2AFCDacAC',
    inputVerifierContractAddress: process.env.FHE_INPUT_VERIFIER_ADDRESS || '0xbc91f3daD1A5F19F8390c400196e58073B6a0BC4',
    chainId: Number(network.chainId),
    // Gateway
    verifyingContractAddressDecryption: process.env.FHE_VERIFY_DECRYPTION || '0xb6E160B1ff80D67Bfe90A85eE06Ce0A2613607D1',
    verifyingContractAddressInputVerification: process.env.FHE_VERIFY_INPUT || '0x7048C39f048125eDa9d678AEbaDfB22F7900a29F',
    gatewayChainId: Number(process.env.FHE_GATEWAY_CHAIN_ID || 55815),
    // Relayer
    relayerUrl: process.env.FHE_RELAYER_URL || 'https://relayer.testnet.zama.cloud',
    network: rpc,
  });

  // 生成加密输入（uint32 trait）
  const traitValue = 42;
  const builder = instance.createEncryptedInput(nftAddress, wallet.address);
  builder.add32(traitValue);
  const { handles, inputProof } = await builder.encrypt();
  const handle = ethers.hexlify(handles[0] as Uint8Array);
  const proof = ethers.hexlify(inputProof as Uint8Array);

  // 连接合约
  const abi = (await import("../artifacts/src/FHEBlindNFT.sol/FHEBlindNFT.json", { assert: { type: "json" } }) as any)
    .default.abi;
  const nft = new ethers.Contract(nftAddress, abi, wallet);

  // 开启铸造
  const txCfg = await nft.setMintConfig(true, 1_000_000, 10, 0);
  await txCfg.wait();

  // 铸造
  const tx = await nft.mintBlind(wallet.address, handle, proof, { value: 0 });
  const receipt = await tx.wait();
  console.log("Mint tx:", receipt?.hash);
}

main().catch((e) => { console.error(e); process.exit(1); });
