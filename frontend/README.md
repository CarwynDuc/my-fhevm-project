# FHE NFT Platform - Frontend

A modern NFT minting platform built with React, Ant Design 5.0, and Privy SDK, featuring fully homomorphic encrypted (FHE) NFTs for privacy-preserving digital ownership.

## Features

- **FHE-Enabled NFTs**: Mint NFTs with encrypted traits that only owners can decrypt
- **Modern UI**: Linear-style design with Ant Design 5.0 components
- **Web3 Integration**: Seamless wallet connection via Privy SDK
- **Responsive Design**: Works perfectly on desktop and mobile devices
- **Dark Mode**: Toggle between light and dark themes
- **User Dashboard**: View and manage your minted NFTs
- **Free Minting**: Zero-cost NFT minting on Sepolia testnet

## Tech Stack

- **React 18** with TypeScript
- **Ant Design 5.0** for UI components
- **Privy SDK** for wallet authentication
- **Vite** for fast development and building
- **ethers.js** for blockchain interactions
- **React Router** for navigation
- **React Query** for data fetching
- **Framer Motion** for animations

## Prerequisites

- Node.js 18+ and npm/yarn
- A Privy account (get one at https://privy.io)
- MetaMask or another Web3 wallet
- Some Sepolia ETH for gas fees

## Setup Instructions

1. **Install Dependencies**
   ```bash
   cd /Users/songsu/Desktop/zama/fhe-nft/frontend
   npm install
   ```

2. **Configure Environment Variables**
   
   Create a `.env` file based on `.env.example`:
   ```bash
   cp .env.example .env
   ```
   
   Then edit `.env` with your values:
   ```env
   VITE_PRIVY_APP_ID=your-privy-app-id
   VITE_NFT_ADDRESS=deployed-contract-address
   VITE_SEPOLIA_RPC=your-rpc-url
   ```

3. **Privy Configuration**
   
   - Go to [Privy Dashboard](https://dashboard.privy.io)
   - Create a new app or use existing one
   - Copy your App ID to `.env`
   - Configure allowed domains (add `http://localhost:5175` for development)

4. **Run Development Server**
   ```bash
   npm run dev
   ```
   
   The app will open at http://localhost:5175

5. **Build for Production**
   ```bash
   npm run build
   ```
   
   The production build will be in the `dist` folder.

## Project Structure

```
frontend/
├── src/
│   ├── abi/              # Contract ABIs
│   ├── components/       # React components
│   │   ├── AppHeader.tsx
│   │   └── NFTCollectionCard.tsx
│   ├── data/            # Mock data
│   │   └── collections.ts
│   ├── hooks/           # Custom React hooks
│   │   └── useContract.ts
│   ├── pages/           # Page components
│   │   ├── HomePage.tsx
│   │   └── DashboardPage.tsx
│   ├── theme/           # Ant Design theme config
│   │   └── index.ts
│   ├── types/           # TypeScript types
│   │   └── index.ts
│   ├── utils/           # Utility functions
│   ├── App.tsx          # Main app component
│   ├── config.ts        # App configuration
│   └── main.tsx         # Entry point
├── index.html
├── package.json
├── tsconfig.json
└── vite.config.ts
```

## Key Components

### AppHeader
- Wallet connection button with Privy integration
- Theme toggle (light/dark mode)
- User wallet display with copy functionality
- Responsive mobile menu

### NFTCollectionCard
- Display NFT collection information
- Show minting progress and availability
- FHE technology indicators
- One-click minting functionality

### HomePage
- Grid view of available NFT collections
- Search and filter functionality
- Category-based browsing
- Platform statistics

### DashboardPage
- View owned NFTs
- Reveal encrypted traits
- Collection analytics
- Recent activity tracking

## Smart Contract Integration

The platform integrates with the FHEBlindNFT contract which provides:
- `mintBlind()`: Mint NFTs with encrypted traits
- `reencryptTrait()`: Decrypt traits for viewing
- `verifyTraitGte()`: Zero-knowledge trait verification

## Customization

### Theme Colors
Edit `/src/theme/index.ts` to customize the color scheme:
```typescript
colorPrimary: '#2563EB',  // Primary blue
colorSuccess: '#10B981',  // Success green
colorWarning: '#F59E0B',  // Warning orange
colorError: '#EF4444',    // Error red
```

### Collections
Add or modify NFT collections in `/src/data/collections.ts`

### Contract Address
Update the contract address in your `.env` file when deploying to different networks.

## Deployment

1. Build the application:
   ```bash
   npm run build
   ```

2. Deploy the `dist` folder to your hosting service:
   - Vercel: `vercel --prod`
   - Netlify: Drag and drop the `dist` folder
   - AWS S3: Upload to S3 bucket with static hosting

3. Configure environment variables on your hosting platform

## Troubleshooting

### Wallet Connection Issues
- Ensure MetaMask is installed and unlocked
- Check that you're on the Sepolia network
- Verify Privy App ID is correct

### Minting Failures
- Ensure you have Sepolia ETH for gas
- Check contract address in `.env`
- Verify the contract is deployed on Sepolia

### Build Errors
- Clear node_modules and reinstall: `rm -rf node_modules && npm install`
- Check TypeScript errors: `npm run typecheck`

## License

MIT