@echo off
echo ============================================
echo   ZamaFull - Auto Setup Helper
echo ============================================
echo.
echo Opening download pages in your browser...
echo.

echo [1/3] Opening GitHub Desktop download...
start https://desktop.github.com/

timeout /t 2 >nul

echo [2/3] Opening Vercel signup...
start https://vercel.com/signup

timeout /t 2 >nul

echo [3/3] Opening Sepolia Faucet (for ETH)...
start https://www.alchemy.com/faucets/ethereum-sepolia

echo.
echo ============================================
echo Downloads opened! Follow QUICK_SETUP.md
echo ============================================
echo.
echo Next steps:
echo 1. Install GitHub Desktop
echo 2. Sign in with GitHub account: CarwynDuc
echo 3. Add repository: D:\zama2\VeilMint
echo 4. Publish to GitHub
echo 5. Deploy to Vercel
echo.
pause
