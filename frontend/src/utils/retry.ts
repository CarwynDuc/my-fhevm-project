/**
 * Retry utility with exponential backoff for transaction operations
 */

export interface RetryOptions {
  maxRetries?: number;
  initialDelay?: number;
  maxDelay?: number;
  backoffMultiplier?: number;
}

const DEFAULT_OPTIONS: Required<RetryOptions> = {
  maxRetries: 3,
  initialDelay: 1000, // 1 second
  maxDelay: 10000, // 10 seconds
  backoffMultiplier: 2,
};

/**
 * Execute a function with exponential backoff retry logic
 */
export async function retryWithBackoff<T>(
  fn: () => Promise<T>,
  options: RetryOptions = {}
): Promise<T> {
  const opts = { ...DEFAULT_OPTIONS, ...options };
  let lastError: Error;
  let delay = opts.initialDelay;

  for (let attempt = 0; attempt <= opts.maxRetries; attempt++) {
    try {
      return await fn();
    } catch (error) {
      lastError = error as Error;

      // Don't retry if it's the last attempt
      if (attempt === opts.maxRetries) {
        break;
      }

      // Check if error is retryable
      if (!isRetryableError(error)) {
        throw error;
      }

      console.warn(
        `Attempt ${attempt + 1}/${opts.maxRetries + 1} failed. Retrying in ${delay}ms...`,
        error
      );

      // Wait before retrying
      await sleep(delay);

      // Exponential backoff with max delay cap
      delay = Math.min(delay * opts.backoffMultiplier, opts.maxDelay);
    }
  }

  throw new Error(
    `Failed after ${opts.maxRetries + 1} attempts: ${lastError!.message}`
  );
}

/**
 * Determine if an error is retryable
 */
function isRetryableError(error: any): boolean {
  // Network errors are retryable
  if (error?.code === 'NETWORK_ERROR') return true;
  if (error?.code === 'TIMEOUT') return true;
  if (error?.message?.includes('network')) return true;
  if (error?.message?.includes('timeout')) return true;

  // RPC errors that are retryable
  if (error?.code === -32603) return true; // Internal error
  if (error?.code === -32000) return true; // Server error
  if (error?.code === 429) return true; // Rate limit

  // Transaction replacement errors (can retry with higher gas)
  if (error?.code === 'REPLACEMENT_UNDERPRICED') return true;
  if (error?.code === 'NONCE_EXPIRED') return true;

  // User rejection is NOT retryable
  if (error?.code === 4001) return false;
  if (error?.code === 'ACTION_REJECTED') return false;

  // Insufficient funds is NOT retryable
  if (error?.code === 'INSUFFICIENT_FUNDS') return false;

  // Default: retry on unknown errors
  return true;
}

/**
 * Sleep for specified milliseconds
 */
function sleep(ms: number): Promise<void> {
  return new Promise((resolve) => setTimeout(resolve, ms));
}
