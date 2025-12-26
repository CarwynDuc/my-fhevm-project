import { BrowserProvider } from 'ethers';

// Contract address for FHE operations
const NFT_CONTRACT_ADDRESS = import.meta.env.VITE_NFT_ADDRESS || '0xe1d83be7899f4e94FE80572671cFF55B0dC17DFA';

declare global {
  interface Window {
    RelayerSDK?: any;
    relayerSDK?: any;
    ethereum?: any;
    okxwallet?: any;
  }
}

export type FHEClient = {
  ready: () => Promise<void>;
  encryptTrait32: (value: number, contract: string, user: string) => Promise<{ handle: string; proof: string }>;
  encryptBatch32: (values: number[], contract: string, user: string) => Promise<{ handles: string[]; proof: string }>;
  getViewerAuth: (publicKey: string, contract: string, user: string) => Promise<{ typedData: any; signature: string }>;
  getPublicKey: () => string | null;
  getOrCreateViewerKeypair: () => Promise<{ publicKey: string; privateKey: string }>;
};

let fheInstance: any = null;

/**
 * Get the Relayer SDK from window (loaded via CDN)
 */
const getSDK = () => {
  if (typeof window === 'undefined') {
    throw new Error('FHE SDK requires a browser environment');
  }
  const sdk = window.RelayerSDK || window.relayerSDK;
  if (!sdk) {
    throw new Error('Relayer SDK not loaded. Ensure the CDN script tag is present in index.html.');
  }
  return sdk;
};

/**
 * Initialize FHE SDK with provider
 */
export const initializeFHE = async (provider?: any): Promise<any> => {
  if (fheInstance) return fheInstance;
  if (typeof window === 'undefined') {
    throw new Error('FHE SDK requires a browser environment');
  }

  const ethereumProvider =
    provider || window.ethereum || window.okxwallet?.provider || window.okxwallet;
  if (!ethereumProvider) {
    throw new Error('No wallet provider detected. Connect a wallet first.');
  }

  const sdk = getSDK();
  const { initSDK, createInstance, SepoliaConfig } = sdk;
  await initSDK();
  const config = { ...SepoliaConfig, network: ethereumProvider };
  fheInstance = await createInstance(config);
  console.log('[FHE] SDK initialized successfully with CDN v0.3.0-5');
  return fheInstance;
};

/**
 * Get FHE instance (initialize if needed)
 */
const getInstance = async (provider?: any): Promise<any> => {
  if (fheInstance) return fheInstance;
  return initializeFHE(provider);
};

/**
 * Check if FHE SDK is loaded and ready
 */
export const isFHEReady = (): boolean => {
  if (typeof window === 'undefined') return false;
  return !!(window.RelayerSDK || window.relayerSDK);
};

/**
 * Check if FHE instance is initialized
 */
export const isFheInstanceReady = (): boolean => {
  return fheInstance !== null;
};

/**
 * Wait for FHE SDK to be loaded (with timeout)
 */
export const waitForFHE = async (timeoutMs: number = 10000): Promise<boolean> => {
  const startTime = Date.now();

  while (Date.now() - startTime < timeoutMs) {
    if (isFHEReady()) {
      return true;
    }
    await new Promise(resolve => setTimeout(resolve, 100));
  }

  return false;
};

/**
 * Get FHE status for debugging
 */
export const getFHEStatus = (): {
  sdkLoaded: boolean;
  instanceReady: boolean;
} => {
  return {
    sdkLoaded: isFHEReady(),
    instanceReady: fheInstance !== null,
  };
};

/**
 * Convert Uint8Array to hex string
 */
const bytesToHex = (bytes: Uint8Array): string => {
  return '0x' + Array.from(bytes).map(b => b.toString(16).padStart(2, '0')).join('');
};

/**
 * Create FHE client with provider getter
 */
export function createFHEClient(getProvider: () => Promise<BrowserProvider>): FHEClient {
  let publicKey: string | null = null;
  let cachedKeypair: { publicKey: string; privateKey: string } | null = null;

  async function ready() {
    if (fheInstance) return;

    try {
      const provider = await getProvider();
      await provider.getNetwork();

      const ethereumProvider = window.ethereum || (provider as any).provider;
      await initializeFHE(ethereumProvider);

      const pk = fheInstance.getPublicKey()?.publicKey as Uint8Array | undefined;
      publicKey = pk ? bytesToHex(pk) : null;

      console.log('[FHE] Client ready, public key:', publicKey ? 'available' : 'not available');
    } catch (error) {
      console.error('[FHE] Failed to initialize SDK:', error);
      throw new Error('FHE SDK failed to load. Check network and CORS settings.');
    }
  }

  async function encryptTrait32(
    value: number,
    contract: string,
    user: string
  ): Promise<{ handle: string; proof: string }> {
    await ready();
    if (!fheInstance) throw new Error('FHE not initialized');

    try {
      console.log('[FHE] Encrypting trait value:', value);
      const input = fheInstance.createEncryptedInput(contract, user);
      input.add32(value);

      console.log('[FHE] Encrypting input...');
      const { handles, inputProof } = await input.encrypt();
      console.log('[FHE] Encryption complete, handles:', handles.length);

      if (handles.length < 1) {
        throw new Error('FHE SDK returned insufficient handles');
      }

      const handleHex = bytesToHex(handles[0]);
      const proofHex = bytesToHex(inputProof);

      console.log('[FHE] Encrypted value:', value, 'handle length:', handleHex.length);
      return { handle: handleHex, proof: proofHex };
    } catch (error) {
      console.error('[FHE] Encryption failed:', error);
      throw new Error('FHE encryption failed. Ensure network connection is stable.');
    }
  }

  async function encryptBatch32(
    values: number[],
    contract: string,
    user: string
  ): Promise<{ handles: string[]; proof: string }> {
    await ready();
    if (!fheInstance) throw new Error('FHE not initialized');

    try {
      console.log(`[FHE] Encrypting ${values.length} values...`);
      const input = fheInstance.createEncryptedInput(contract, user);

      // Add all values
      for (const value of values) {
        input.add32(value);
      }

      const { handles, inputProof } = await input.encrypt();

      // Extract handles
      const handleHexes: string[] = handles.map((h: Uint8Array) => bytesToHex(h));
      const proofHex = bytesToHex(inputProof);

      console.log(`[FHE] Batch encryption complete, ${handleHexes.length} handles`);
      return { handles: handleHexes, proof: proofHex };
    } catch (error) {
      console.error('[FHE] Batch encryption failed:', error);
      throw new Error('FHE batch encryption failed. Ensure network connection is stable.');
    }
  }

  async function getViewerAuth(viewerPublicKey: string, contract: string, user: string) {
    await ready();
    const provider = await getProvider();
    const eip1193 = (provider.provider as unknown) as any;
    const signer = await provider.getSigner();
    const address = await signer.getAddress();
    if (address.toLowerCase() !== user.toLowerCase()) throw new Error('Signer/user mismatch');

    const mk = fheInstance.createEIP712;
    const typedData = mk(viewerPublicKey, contract, user);

    const signTypedData = eip1193?.request
      ? (params: any) => eip1193.request({ method: 'eth_signTypedData_v4', params })
      : null;
    let signature: string;
    if (signTypedData) {
      signature = await signTypedData([user, JSON.stringify(typedData)]);
    } else {
      signature = await (signer as any)._signTypedData(
        typedData.domain,
        typedData.types,
        typedData.message
      );
    }
    return { typedData, signature };
  }

  async function getOrCreateViewerKeypair(): Promise<{ publicKey: string; privateKey: string }> {
    if (cachedKeypair) return cachedKeypair;
    try {
      const pub = localStorage.getItem('fhe:keypair:pub');
      const priv = localStorage.getItem('fhe:keypair:priv');
      if (pub && priv) {
        cachedKeypair = { publicKey: pub, privateKey: priv };
        return cachedKeypair;
      }
    } catch {}
    await ready();
    if (!fheInstance) throw new Error('FHE not initialized');
    const kp = await fheInstance.generateKeypair();
    try {
      localStorage.setItem('fhe:keypair:pub', kp.publicKey);
      localStorage.setItem('fhe:keypair:priv', kp.privateKey);
    } catch {}
    cachedKeypair = kp;
    return kp;
  }

  return {
    ready,
    encryptTrait32,
    encryptBatch32,
    getViewerAuth,
    getPublicKey: () => publicKey,
    getOrCreateViewerKeypair
  };
}

/**
 * Encrypt a single trait value (standalone function)
 */
export const encryptTrait = async (
  value: number,
  userAddress: string,
  provider?: any
): Promise<{
  handle: `0x${string}`;
  proof: `0x${string}`;
}> => {
  console.log('[FHE] Encrypting trait:', value);
  const instance = await getInstance(provider);
  const contractAddr = NFT_CONTRACT_ADDRESS;

  console.log('[FHE] Creating encrypted input for:', {
    contract: contractAddr,
    user: userAddress,
  });

  const input = instance.createEncryptedInput(contractAddr, userAddress);
  input.add32(value);

  console.log('[FHE] Encrypting input...');
  const { handles, inputProof } = await input.encrypt();
  console.log('[FHE] Encryption complete, handles:', handles.length);

  if (handles.length < 1) {
    throw new Error('FHE SDK returned insufficient handles');
  }

  return {
    handle: bytesToHex(handles[0]) as `0x${string}`,
    proof: bytesToHex(inputProof) as `0x${string}`,
  };
};
