// Configuration for FHE NFT Platform
export const CONTRACT_ADDRESS = import.meta.env.VITE_NFT_ADDRESS || import.meta.env.VITE_CONTRACT_ADDRESS || '0x0000000000000000000000000000000000000000';
export const CHAIN_ID = 11155111; // Sepolia
export const RPC_URL = import.meta.env.VITE_SEPOLIA_RPC || import.meta.env.VITE_RPC_URL || 'https://rpc.sepolia.org';

// Deployed Contracts on Sepolia (v0.9.1)
export const CONTRACTS = {
  VeilMintSimple: '0x3DA0E8F54D30c119522F0e96e23c36fD0dD4A900',
  FHEBlindNFT: '0x27D2aB8048A5b7f3d4b8416C231f33366d7c663c',
  VeilMintBlindNFT: '0x701499B8DcDc40bF66e0D1203a9776fD06B770ec',
  VeilMintGalleryCoordinator: '0xa5EE4D939f04F1BcbFe0F108496b983850143009'
} as const;

// Explorer URLs
export const getExplorerUrl = (address: string) =>
  `https://sepolia.etherscan.io/address/${address}`;
export const getTxUrl = (hash: string) =>
  `https://sepolia.etherscan.io/tx/${hash}`;