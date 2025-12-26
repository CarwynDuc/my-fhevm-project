import React, { useState, useEffect } from 'react';
import { BrowserRouter as Router, Routes, Route, Navigate } from 'react-router-dom';
import { ConfigProvider, Layout, Menu, theme, Drawer, Alert } from 'antd';
import { WagmiConfig, http, createConfig } from 'wagmi';
import { sepolia } from 'wagmi/chains';
import { RainbowKitProvider } from '@rainbow-me/rainbowkit';
import { injected } from '@wagmi/connectors';
import '@rainbow-me/rainbowkit/styles.css';
import { QueryClient, QueryClientProvider } from '@tanstack/react-query';
import {
  HomeOutlined,
  DashboardOutlined,
  AppstoreOutlined,
  WalletOutlined
} from '@ant-design/icons';
import { useNavigate, useLocation } from 'react-router-dom';

import { lightTheme, darkTheme } from '@/theme';
import { AppHeader } from '@/components/AppHeader';
import { HomePage } from '@/pages/HomePage';
import { DashboardPage } from '@/pages/DashboardPage';
import { RPC_URL, CHAIN_ID } from '@/config';
import { useAccount } from 'wagmi';

const { Content, Sider } = Layout;

// Create a query client
const queryClient = new QueryClient({
  defaultOptions: {
    queries: {
      staleTime: 60 * 1000,
      refetchOnWindowFocus: false
    }
  }
});

// Navigation component that uses router hooks
const AppLayout: React.FC = () => {
  const navigate = useNavigate();
  const location = useLocation();
  const { token } = theme.useToken();
  const [isDarkMode, setIsDarkMode] = useState(false);
  const [collapsed, setCollapsed] = useState(false);
  const [drawerVisible, setDrawerVisible] = useState(false);
  const [isMobile, setIsMobile] = useState(false);
  const { isConnected } = useAccount();

  useEffect(() => {
    const checkMobile = () => {
      setIsMobile(window.innerWidth < 768);
      if (window.innerWidth >= 768) {
        setDrawerVisible(false);
      }
    };
    
    checkMobile();
    window.addEventListener('resize', checkMobile);
    return () => window.removeEventListener('resize', checkMobile);
  }, []);

  const menuItems = [
    {
      key: '/',
      icon: <HomeOutlined />,
      label: 'Explore'
    },
    {
      key: '/dashboard',
      icon: <DashboardOutlined />,
      label: 'Dashboard'
    }
  ];

  const handleMenuClick = (key: string) => {
    navigate(key);
    if (isMobile) {
      setDrawerVisible(false);
    }
  };

  const SideMenu = () => (
    <Menu
      mode="inline"
      selectedKeys={[location.pathname]}
      items={menuItems}
      onClick={({ key }) => handleMenuClick(key)}
      style={{
        height: '100%',
        borderRight: 0,
        background: 'transparent'
      }}
    />
  );

  return (
    <Layout style={{ minHeight: '100vh', background: token.colorBgLayout }}>
      <AppHeader
        isDarkMode={isDarkMode}
        onThemeToggle={() => setIsDarkMode(!isDarkMode)}
        onMenuClick={() => setDrawerVisible(true)}
        isMobile={isMobile}
      />
      
      <Layout>
        {!isMobile && (
          <Sider
            width={240}
            collapsible
            collapsed={collapsed}
            onCollapse={setCollapsed}
            style={{
              background: token.colorBgContainer,
              borderRight: `1px solid ${token.colorBorder}`
            }}
          >
            <div style={{ padding: '24px 16px' }}>
              <div
                style={{
                  display: 'flex',
                  alignItems: 'center',
                  gap: 12,
                  marginBottom: 24
                }}
              >
                <AppstoreOutlined
                  style={{
                    fontSize: 24,
                    color: token.colorPrimary
                  }}
                />
                {!collapsed && (
                  <span style={{ fontSize: 16, fontWeight: 600 }}>
                    Collections
                  </span>
                )}
              </div>
            </div>
            <SideMenu />
          </Sider>
        )}

        {isMobile && (
          <Drawer
            placement="left"
            open={drawerVisible}
            onClose={() => setDrawerVisible(false)}
            width={280}
            styles={{
              body: { padding: 0 }
            }}
          >
            <div style={{ padding: '24px 16px' }}>
              <div
                style={{
                  display: 'flex',
                  alignItems: 'center',
                  gap: 12,
                  marginBottom: 24
                }}
              >
                <WalletOutlined
                  style={{
                    fontSize: 24,
                    color: token.colorPrimary
                  }}
                />
                <span style={{ fontSize: 16, fontWeight: 600 }}>
                  Navigation
                </span>
              </div>
            </div>
            <SideMenu />
          </Drawer>
        )}

        <Layout>
          <Content
            style={{
              margin: isMobile ? '0 16px' : '0 24px',
              maxWidth: 1280,
              width: '100%',
              marginLeft: 'auto',
              marginRight: 'auto'
            }}
          >
            {!isConnected && (
              <Alert
                type="info"
                showIcon
                message="Connect your wallet to mint and manage your NFTs"
                style={{ margin: '16px 0' }}
              />
            )}
            <Routes>
              <Route path="/" element={<HomePage />} />
              <Route path="/dashboard" element={<DashboardPage />} />
              <Route path="*" element={<Navigate to="/" replace />} />
            </Routes>
          </Content>
        </Layout>
      </Layout>
    </Layout>
  );
};

// Main App component
export default function App() {
  const [isDarkMode, _setIsDarkMode] = useState(() => {
    const saved = localStorage.getItem('theme');
    return saved === 'dark';
  });

  useEffect(() => {
    localStorage.setItem('theme', isDarkMode ? 'dark' : 'light');
  }, [isDarkMode]);

  // Configure Wagmi + RainbowKit
  const chain = { ...sepolia, id: CHAIN_ID };
  const transports: Record<number, ReturnType<typeof http>> = {
    [CHAIN_ID]: http(RPC_URL || sepolia.rpcUrls.default.http[0])
  };

  // Using injected connector (MetaMask/Browser wallets)
  // WalletConnect disabled for simplicity
  const config = createConfig({
    chains: [chain],
    transports,
    connectors: [injected()],
    ssr: false,
  });

  return (
    <WagmiConfig config={config}>
      <QueryClientProvider client={queryClient}>
        <RainbowKitProvider>
          <ConfigProvider theme={isDarkMode ? darkTheme : lightTheme}>
            <Router>
              <AppLayout />
            </Router>
          </ConfigProvider>
        </RainbowKitProvider>
      </QueryClientProvider>
    </WagmiConfig>
  );
}
