# ZamaFull - Deployment Guide

## Step 1: Push to GitHub

Your code is ready to push! Choose one of these methods:

### Option A: Using GitHub Desktop (Easiest)
1. Download and install [GitHub Desktop](https://desktop.github.com/)
2. Sign in with your GitHub account (CarwynDuc)
3. Click "Add Existing Repository" and select `D:\zama2\VeilMint`
4. Click "Publish repository" to push to GitHub

### Option B: Using Personal Access Token
1. Go to GitHub Settings → Developer settings → Personal access tokens → Tokens (classic)
2. Click "Generate new token (classic)"
3. Select scopes: `repo` (all)
4. Copy the token
5. Run these commands:

```bash
cd "D:\zama2\VeilMint"
git push https://YOUR_TOKEN@github.com/CarwynDuc/my-fhevm-project.git main
```

Replace `YOUR_TOKEN` with your actual token.

### Option C: Using SSH (Recommended)
1. Generate SSH key:
```bash
ssh-keygen -t ed25519 -C "your_email@example.com"
```

2. Add SSH key to GitHub:
   - Go to GitHub Settings → SSH and GPG keys → New SSH key
   - Copy contents of `~/.ssh/id_ed25519.pub`
   - Paste and save

3. Update remote and push:
```bash
cd "D:\zama2\VeilMint"
git remote set-url origin git@github.com:CarwynDuc/my-fhevm-project.git
git push -u origin main
```

---

## Step 2: Deploy Contracts to Sepolia (Optional)

If you want to deploy the smart contracts:

1. **Get Sepolia ETH**:
   - Visit https://www.alchemy.com/faucets/ethereum-sepolia
   - Or https://sepolia-faucet.pk910.de/

2. **Add your private key** to `.env`:
```bash
DEPLOYER_PRIVATE_KEY=your_64_character_private_key_here
```

3. **Deploy all contracts**:
```bash
cd "D:\zama2\VeilMint"
npm run deploy:all
```

4. **Update frontend** with deployed contract address:
   - Open `deployment-v0.9.1.json` to see deployed addresses
   - Copy the `FHEBlindNFT` address
   - Update `frontend/.env`:
```
VITE_NFT_ADDRESS=0xYourDeployedContractAddress
```

---

## Step 3: Deploy Frontend to Vercel

### Using Vercel Dashboard (Easiest)

1. **Push to GitHub first** (complete Step 1 above)

2. **Go to Vercel**:
   - Visit https://vercel.com
   - Sign in with your GitHub account
   - Click "Add New Project"

3. **Import your repository**:
   - Select `my-fhevm-project`
   - Click "Import"

4. **Configure the project**:
   - Framework Preset: **Vite**
   - Root Directory: **frontend**
   - Build Command: `npm run build`
   - Output Directory: `dist`

5. **Add Environment Variables**:
   Click "Environment Variables" and add:
   ```
   VITE_NFT_ADDRESS=0xYourContractAddress
   VITE_SEPOLIA_RPC=https://ethereum-sepolia-rpc.publicnode.com
   ```

6. **Deploy**:
   - Click "Deploy"
   - Wait 2-3 minutes for build to complete
   - Your app will be live at: `https://my-fhevm-project.vercel.app`

### Using Vercel CLI (Advanced)

1. **Install Vercel CLI**:
```bash
npm install -g vercel
```

2. **Login to Vercel**:
```bash
vercel login
```

3. **Deploy**:
```bash
cd "D:\zama2\VeilMint\frontend"
vercel --prod
```

4. **Set environment variables**:
```bash
vercel env add VITE_NFT_ADDRESS production
vercel env add VITE_SEPOLIA_RPC production
```

---

## Step 4: Update README with Live Links

After deployment, update the README with your live links:

1. Open `README.md`
2. Update the "Resources" section:
```markdown
## Resources

- **Live Demo**: https://my-fhevm-project.vercel.app
- **GitHub**: https://github.com/CarwynDuc/my-fhevm-project
```

3. If you deployed contracts, update the "Deployed Contracts" section with addresses from `deployment-v0.9.1.json`

---

## Troubleshooting

### Git Push Fails
- Make sure you're authenticated (see Step 1 options)
- Check repository exists: https://github.com/CarwynDuc/my-fhevm-project

### Vercel Build Fails
- Check that Root Directory is set to `frontend`
- Verify environment variables are set
- Check build logs for specific errors

### Frontend Can't Connect to Contracts
- Verify `VITE_NFT_ADDRESS` in Vercel environment variables
- Make sure contracts are deployed to Sepolia
- Check MetaMask is connected to Sepolia network

### Contract Deployment Fails
- Ensure you have Sepolia ETH in your wallet
- Verify private key is correct (64 characters, no 0x prefix)
- Check RPC URL is working

---

## Summary Checklist

- [ ] Push code to GitHub
- [ ] Deploy contracts to Sepolia (optional)
- [ ] Deploy frontend to Vercel
- [ ] Update README with live links
- [ ] Test the dapp in production
- [ ] Share your project!

---

## Your Project URLs

- **GitHub**: https://github.com/CarwynDuc/my-fhevm-project
- **Vercel**: (will be generated after deployment)
- **Contracts**: (will be on Sepolia Etherscan after deployment)

Good luck with your ZamaFull deployment!
