# Quick Setup Guide - ZamaFull

## Bước 1: Download GitHub Desktop (Dễ nhất!)

### Download ngay:
👉 **[Download GitHub Desktop](https://desktop.github.com/)**

Hoặc link trực tiếp:
- Windows: https://central.github.com/deployments/desktop/desktop/latest/win32

### Cài đặt:
1. Chạy file vừa download
2. Click "Install"
3. Đợi 1-2 phút

---

## Bước 2: Sign in GitHub Desktop

1. Mở GitHub Desktop
2. Click "Sign in to GitHub.com"
3. Đăng nhập với account: **CarwynDuc**
4. Click "Authorize desktop"

---

## Bước 3: Add Repository

1. Trong GitHub Desktop, click "File" → "Add local repository"
2. Click "Choose..." và chọn folder:
   ```
   D:\zama2\VeilMint
   ```
3. Click "Add repository"

---

## Bước 4: Publish to GitHub

1. Click nút "Publish repository" (to lớn, màu xanh)
2. Repository name: `my-fhevm-project`
3. ✅ Bỏ check "Keep this code private" (để public)
4. Click "Publish repository"
5. Đợi 30s - DONE! ✅

GitHub link của bạn sẽ là:
👉 **https://github.com/CarwynDuc/my-fhevm-project**

---

## Bước 5: Deploy lên Vercel (Web hosting miễn phí)

### Setup Vercel:

1. **Vào Vercel:**
   👉 https://vercel.com/signup

2. **Click "Continue with GitHub"**
   - Đăng nhập bằng GitHub (CarwynDuc)
   - Click "Authorize Vercel"

3. **Import Project:**
   - Click "Add New..." → "Project"
   - Tìm và chọn: `my-fhevm-project`
   - Click "Import"

4. **Configure:**
   - Framework Preset: **Vite**
   - Root Directory: Click "Edit" → Gõ: `frontend`
   - Build Command: `npm run build`
   - Output Directory: `dist`

5. **Environment Variables:**
   Click "Environment Variables" và thêm 2 dòng này:

   ```
   Name: VITE_NFT_ADDRESS
   Value: 0x0000000000000000000000000000000000000000
   ```

   ```
   Name: VITE_SEPOLIA_RPC
   Value: https://ethereum-sepolia-rpc.publicnode.com
   ```

6. **Deploy:**
   - Click "Deploy"
   - Đợi 2-3 phút build
   - DONE! ✅

Website của bạn đã LIVE tại:
👉 **https://frontend-7ei8gdz3s-carwynducs-projects.vercel.app** (Production)
👉 **https://frontend-lac-zeta-73.vercel.app** (Alias)

---

## Bước 6 (Optional): Deploy Smart Contracts lên Sepolia

Nếu muốn deploy contracts thật:

### A. Get Sepolia ETH (Test ETH - miễn phí)

👉 https://www.alchemy.com/faucets/ethereum-sepolia
- Connect wallet MetaMask
- Click "Send Me ETH"
- Đợi 30s nhận 0.5 Sepolia ETH

### B. Add Private Key

1. Mở MetaMask → Click 3 chấm → Account details
2. Click "Show private key"
3. Copy private key
4. Mở file: `D:\zama2\VeilMint\.env`
5. Thay dòng này:
   ```
   DEPLOYER_PRIVATE_KEY=YOUR_PRIVATE_KEY_HERE
   ```
   Thành:
   ```
   DEPLOYER_PRIVATE_KEY=paste_private_key_vao_day
   ```

### C. Deploy Contracts

Mở terminal trong folder `D:\zama2\VeilMint` và chạy:

```bash
npm run deploy:all
```

Đợi 2-3 phút, sẽ có output như này:

```
VeilMintSimple deployed to: 0xABC...
FHEBlindNFT deployed to: 0xDEF...
VeilMintBlindNFT deployed to: 0xGHI...
VeilMintGalleryCoordinator deployed to: 0xJKL...
```

### D. Update Frontend với Contract Address

1. Copy địa chỉ **FHEBlindNFT** (dòng thứ 2)
2. Vào Vercel → Project Settings → Environment Variables
3. Edit `VITE_NFT_ADDRESS` → Paste địa chỉ contract
4. Click "Save"
5. Vào tab "Deployments" → Click "..." → "Redeploy"

---

## Checklist Hoàn Thành

- [ ] Download và cài GitHub Desktop
- [ ] Sign in GitHub Desktop với account CarwynDuc
- [ ] Add repository từ `D:\zama2\VeilMint`
- [ ] Publish repository lên GitHub
- [ ] Sign up Vercel bằng GitHub
- [ ] Import project từ GitHub vào Vercel
- [ ] Configure: Root Directory = `frontend`
- [ ] Add environment variables
- [ ] Deploy trên Vercel
- [ ] (Optional) Get Sepolia ETH
- [ ] (Optional) Deploy contracts
- [ ] (Optional) Update contract address trên Vercel

---

## Download Links Summary

1. **GitHub Desktop**: https://desktop.github.com/
2. **Vercel**: https://vercel.com/signup
3. **Sepolia Faucet**: https://www.alchemy.com/faucets/ethereum-sepolia

---

## Sau khi hoàn thành, bạn sẽ có:

✅ Code trên GitHub: https://github.com/CarwynDuc/my-fhevm-project
✅ Website LIVE: https://frontend-lac-zeta-73.vercel.app
✅ Smart contracts deployed trên Sepolia (nếu làm bước 6)

---

**Có vấn đề gì cứ hỏi nhé!** 🚀
