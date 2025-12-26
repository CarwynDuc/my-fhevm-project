import { useState, useEffect, useRef } from 'react';
import { BrowserProvider } from 'ethers';

// CDN URL for FHE SDK 0.3.0-8
const FHE_SDK_CDN = 'https://cdn.zama.org/relayer-sdk-js/0.3.0-8/relayer-sdk-js.umd.cjs';

export type FhevmStatus = 'idle' | 'loading' | 'success' | 'error';

export interface UseFhevmParams {
  provider: BrowserProvider | undefined;
  chainId: number | undefined;
  enabled?: boolean;
}

export interface UseFhevmReturn {
  instance: any | undefined;
  status: FhevmStatus;
  error: Error | undefined;
  refresh: () => void;
}

/**
 * React Hook for initializing FHEVM with proper AbortController cleanup
 * Follows best practices from FHE knowledge base
 */
export function useFhevm(params: UseFhevmParams): UseFhevmReturn {
  const { provider, chainId, enabled = true } = params;

  const [instance, setInstance] = useState<any | undefined>(undefined);
  const [status, setStatus] = useState<FhevmStatus>('idle');
  const [error, setError] = useState<Error | undefined>(undefined);
  const [refreshKey, setRefreshKey] = useState(0);

  const abortControllerRef = useRef<AbortController | null>(null);

  useEffect(() => {
    if (!enabled || !provider || !chainId) {
      setStatus('idle');
      setInstance(undefined);
      return;
    }

    // Create new AbortController for this effect
    const controller = new AbortController();
    abortControllerRef.current = controller;

    const initializeFhevm = async () => {
      try {
        setStatus('loading');
        setError(undefined);

        // Check if aborted
        if (controller.signal.aborted) return;

        await provider.getNetwork();

        // Check if aborted
        if (controller.signal.aborted) return;

        // Load FHE SDK from CDN 0.3.0-8
        const sdk: any = await import(/* @vite-ignore */ FHE_SDK_CDN);

        // Check if aborted
        if (controller.signal.aborted) return;

        const { initSDK, createInstance, SepoliaConfig } = sdk;
        if (!initSDK || !createInstance || !SepoliaConfig) {
          throw new Error('Failed to load FHE SDK from CDN');
        }

        // Initialize SDK
        await initSDK();

        // Check if aborted
        if (controller.signal.aborted) return;

        // Use SepoliaConfig with provider
        const config = {
          ...SepoliaConfig,
          network: window.ethereum || provider.provider,
        };

        const fhevmInstance = await createInstance(config);

        // Check if aborted before setting state
        if (controller.signal.aborted) return;

        setInstance(fhevmInstance);
        setStatus('success');
        console.log('FHEVM initialized successfully');
      } catch (err) {
        // Only set error if not aborted
        if (!controller.signal.aborted) {
          const error = err instanceof Error ? err : new Error('Failed to initialize FHEVM');
          setError(error);
          setStatus('error');
          console.error('FHEVM initialization failed:', error);
        }
      }
    };

    initializeFhevm();

    // Cleanup: abort on unmount or when dependencies change
    return () => {
      controller.abort();
      abortControllerRef.current = null;
    };
  }, [provider, chainId, enabled, refreshKey]);

  const refresh = () => {
    setRefreshKey((prev) => prev + 1);
  };

  return {
    instance,
    status,
    error,
    refresh,
  };
}
