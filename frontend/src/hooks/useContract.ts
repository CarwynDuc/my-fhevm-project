import { useState, useCallback, useMemo } from 'react';
import { ethers, BrowserProvider } from 'ethers';
import { useAccount } from 'wagmi';
import { CONTRACT_ADDRESS } from '@/config';
import FHEBlindNFTABI from '@/abi/FHEBlindNFT.json';
import { createFHEClient } from '@/utils/fhe';
import {
  notifyTxPending,
  notifyTxSuccess,
  notifyTxError,
  notifyUserRejected,
  isUserRejection
} from '@/utils/txNotification';

export interface MintResult {
  tokenId: string;
  txHash: string;
}

export const useNFTContract = () => {
  const { isConnected, address } = useAccount();
  const [isLoading, setIsLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);

  const getProvider = useCallback(async (): Promise<BrowserProvider> => {
    if (!isConnected) throw new Error('Please connect your wallet');
    const anyWin = window as any;
    if (!anyWin?.ethereum) {
      throw new Error('MetaMask or compatible wallet not detected. Please install MetaMask from https://metamask.io and refresh the page.');
    }
    return new BrowserProvider(anyWin.ethereum);
  }, [isConnected]);

  const fhe = useMemo(() => createFHEClient(getProvider), [getProvider]);

  const getContract = useCallback(async () => {
    if (!isConnected) throw new Error('Please connect your wallet');
    const provider = await getProvider();
    const signer = await provider.getSigner();
    // Merge custom ABI with minimal ERC721 ABI we need in the frontend
    const ERC721_ABI = [
      'function balanceOf(address) view returns (uint256)',
      'function ownerOf(uint256) view returns (address)',
      'function nextId() view returns (uint256)'
    ];
    const mergedAbi = [...(FHEBlindNFTABI as any).abi, ...ERC721_ABI];
    return new ethers.Contract(CONTRACT_ADDRESS, mergedAbi, signer as any);
  }, [isConnected, getProvider]);

  const mintNFT = useCallback(async (
    collectionAddress: string,
    encryptedTrait?: string,
    traitValue?: number
  ): Promise<MintResult> => {
    void collectionAddress; // reserved for multi-collection routing
    setIsLoading(true);
    setError(null);

    let txHash: string | undefined;

    try {
      if (!CONTRACT_ADDRESS) {
        throw new Error('NFT contract address is not configured. Please set VITE_NFT_ADDRESS');
      }
      const contract = await getContract();
      const provider = await getProvider();
      const signer = await provider.getSigner();
      const userAddr = await signer.getAddress();
      const net = await provider.getNetwork();
      if (Number(net.chainId) !== 11155111) {
        throw new Error('Please switch your wallet to Sepolia (chainId 11155111)');
      }
      // Encrypt trait with chain public key via FHE SDK (32-bit)
      let enc: { handle: string; proof: string };

      if (encryptedTrait) {
        enc = { handle: encryptedTrait, proof: '0x' };
      } else {
        try {
          // Use FHE SDK to encrypt the trait value
          await fhe.ready();
          enc = await fhe.encryptTrait32(traitValue || 42, CONTRACT_ADDRESS, userAddr);
          console.log('Successfully encrypted trait with FHE SDK');
        } catch (fheError) {
          console.error('FHE encryption error:', fheError);
          throw new Error('Failed to encrypt trait data. Please try again.');
        }
      }

      // Guard: prevent calling contract with empty/zero handle or proof
      if (!enc.handle || /^0x0+$/i.test(enc.handle)) {
        throw new Error('Invalid FHE handle (all zeros). Check Relayer URL and env addresses.');
      }
      if (!enc.proof || enc.proof.toLowerCase() === '0x' || /^0x0+$/i.test(enc.proof)) {
        throw new Error('Invalid FHE input proof (empty/zeros). Check Relayer URL and env addresses.');
      }

      console.log('Minting with encrypted handle:', enc.handle.substring(0, 10) + '...');
      console.log('Minting with proof:', enc.proof.substring(0, 10) + '...');

      const tx = await contract.mintBlind(userAddr, enc.handle, enc.proof, { value: 0 });
      txHash = tx.hash as string;

      // Show pending notification with tx hash
      notifyTxPending(txHash, 'Minting your NFT...');

      // Wait for transaction confirmation
      const receipt = await tx.wait();

      // Extract tokenId from events
      const mintEvent = receipt.logs.find(
        (log: any) => log.eventName === 'MintBlind'
      );

      const tokenId = mintEvent?.args?.tokenId?.toString() || '0';

      // Show success notification
      notifyTxSuccess(txHash!, `NFT #${tokenId} minted successfully!`);

      return {
        tokenId,
        txHash: receipt.hash
      };
    } catch (err: any) {
      // Check if user rejected the transaction
      if (isUserRejection(err)) {
        notifyUserRejected();
        throw new Error('Transaction rejected by user');
      }

      // Extract error message
      const reason = err?.shortMessage || err?.reason || err?.info?.error?.message || err?.message || 'Failed to mint NFT. Please try again.';
      setError(reason);

      // Show error notification with tx hash if available
      notifyTxError(txHash, reason);

      throw new Error(reason);
    } finally {
      setIsLoading(false);
    }
  }, [getContract, address, getProvider, fhe]);

  const getUserNFTs = useCallback(async (userAddress: string) => {
    try {
      const contract = await getContract();
      const nextId: bigint = await contract.nextId();
      const nfts: any[] = [];
      for (let i = 0n; i < nextId; i++) {
        try {
          const owner = await contract.ownerOf(i);
          if (owner.toLowerCase() === userAddress.toLowerCase()) {
            nfts.push({ tokenId: i.toString(), owner: userAddress });
          }
        } catch {}
      }
      return nfts;
    } catch (err: any) {
      console.error('Failed to fetch user NFTs:', err);
      return [];
    }
  }, [getContract]);

  const reencryptTrait = useCallback(async (tokenId: string) => {
    try {
      const contract = await getContract();
      const handle: string = await contract.getTrait(tokenId);
      return handle;
    } catch (err: any) {
      console.error('Failed to reencrypt trait:', err);
      throw err;
    }
  }, [getContract]);

  return {
    mintNFT,
    getUserNFTs,
    reencryptTrait,
    isLoading,
    error
  };
};
