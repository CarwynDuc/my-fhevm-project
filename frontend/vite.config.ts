import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'
import { nodePolyfills } from 'vite-plugin-node-polyfills'
import { resolve } from 'path'

export default defineConfig({
  plugins: [
    react(),
    nodePolyfills({
      globals: {
        process: true,
        Buffer: true,
        global: true
      },
      polyfills: {
        util: true,
        stream: true,
        crypto: true
      },
      protocolImports: true
    })
  ],
  resolve: {
    alias: {
      '@': resolve(__dirname, './src'),
      util: 'util'
    }
  },
  server: {
    port: 5175,
    open: true,
    proxy: {
      '/relayer': {
        target: 'https://relayer.testnet.zama.cloud',
        changeOrigin: true,
        rewrite: (path) => path.replace(/^\/relayer/, '')
      }
    }
  },
  define: {
    'process.env': {},
    global: 'globalThis'
  },
  optimizeDeps: {
    include: ['@zama-fhe/relayer-sdk/web', 'keccak'],
    exclude: ['@zama-fhe/relayer-sdk'],
    esbuildOptions: {
      define: {
        global: 'globalThis'
      },
      target: 'es2020'
    }
  },
  worker: {
    format: 'es'
  },
  build: {
    commonjsOptions: {
      transformMixedEsModules: true,
      requireReturnsDefault: 'preferred'
    },
    target: 'es2020'
  }
})
