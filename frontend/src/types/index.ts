export interface NFTCollection {
  id: string;
  name: string;
  symbol: string;
  description: string;
  image: string;
  contractAddress: string;
  totalSupply: number;
  maxSupply: number;
  mintPrice: string;
  fheEnabled: boolean;
  features: string[];
  category: 'art' | 'gaming' | 'membership' | 'utility';
}

export interface NFTToken {
  tokenId: string;
  owner: string;
  collection: NFTCollection;
  metadata?: {
    name: string;
    description: string;
    image: string;
    attributes?: Array<{
      trait_type: string;
      value: string | number;
    }>;
  };
  mintedAt: number;
  encryptedTrait?: string;
}

export interface MintingState {
  isLoading: boolean;
  error: string | null;
  txHash: string | null;
  tokenId: string | null;
}

export interface UserProfile {
  address: string;
  ens?: string;
  avatar?: string;
  nfts: NFTToken[];
  totalMinted: number;
}