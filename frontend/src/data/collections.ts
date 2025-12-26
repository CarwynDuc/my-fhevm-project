import { NFTCollection } from '@/types';
import { CONTRACT_ADDRESS } from '@/config';

export const mockCollections: NFTCollection[] = [
  {
    id: '1',
    name: 'FHE Genesis Collection',
    symbol: 'FHEGEN',
    description: 'The first-ever fully homomorphic encrypted NFT collection. Each token contains encrypted traits that only the owner can decrypt, ensuring true privacy on-chain.',
    image: 'https://images.unsplash.com/photo-1634986666676-ec8fd927c23d?w=800&h=800&fit=crop',
    contractAddress: CONTRACT_ADDRESS,
    totalSupply: 245,
    maxSupply: 1000,
    mintPrice: '0',
    fheEnabled: true,
    features: ['Encrypted Traits', 'Private Metadata', 'Zero-Knowledge Proofs'],
    category: 'art'
  },
  {
    id: '2',
    name: 'Encrypted Avatars',
    symbol: 'ENCAV',
    description: 'Unique avatars with hidden rarity scores. Use FHE technology to prove ownership of rare traits without revealing the actual values.',
    image: 'https://images.unsplash.com/photo-1620321023374-d1a68fbc720d?w=800&h=800&fit=crop',
    contractAddress: CONTRACT_ADDRESS,
    totalSupply: 512,
    maxSupply: 5000,
    mintPrice: '0',
    fheEnabled: true,
    features: ['Hidden Rarity', 'Trait Verification', 'Privacy-Preserving'],
    category: 'gaming'
  },
  {
    id: '3',
    name: 'Private Membership Pass',
    symbol: 'PMP',
    description: 'Exclusive membership NFTs with encrypted access levels. Verify your membership tier without exposing sensitive data.',
    image: 'https://images.unsplash.com/photo-1614064641938-3bbee52942c7?w=800&h=800&fit=crop',
    contractAddress: CONTRACT_ADDRESS,
    totalSupply: 89,
    maxSupply: 500,
    mintPrice: '0',
    fheEnabled: true,
    features: ['Access Control', 'Tier Verification', 'Anonymous Voting'],
    category: 'membership'
  },
  {
    id: '4',
    name: 'Quantum Art Series',
    symbol: 'QAS',
    description: 'Generative art collection with encrypted parameters. Each piece has unique encrypted properties that influence its visual representation.',
    image: 'https://images.unsplash.com/photo-1618005182384-a83a8bd57fbe?w=800&h=800&fit=crop',
    contractAddress: '0x4567890123456789012345678901234567890123',
    totalSupply: 333,
    maxSupply: 2500,
    mintPrice: '0',
    fheEnabled: true,
    features: ['Generative Art', 'Dynamic Visuals', 'Encrypted Seeds'],
    category: 'art'
  },
  {
    id: '5',
    name: 'Utility Keys',
    symbol: 'UKEY',
    description: 'Multi-purpose utility NFTs with encrypted capabilities. Unlock features across different dApps while maintaining privacy.',
    image: 'https://images.unsplash.com/photo-1639762681485-074b7f938ba0?w=800&h=800&fit=crop',
    contractAddress: '0x5678901234567890123456789012345678901234',
    totalSupply: 156,
    maxSupply: 10000,
    mintPrice: '0',
    fheEnabled: true,
    features: ['Cross-dApp Utility', 'Private Permissions', 'Composable Rights'],
    category: 'utility'
  }
];