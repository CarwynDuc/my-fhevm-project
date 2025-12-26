import React from 'react';
import { Layout, Button, Space, Typography, Badge, Switch, theme } from 'antd';
import { SunOutlined, MoonOutlined, MenuOutlined } from '@ant-design/icons';
import { ConnectButton } from '@rainbow-me/rainbowkit';
import { motion } from 'framer-motion';

const { Header } = Layout;
const { Text } = Typography;

interface AppHeaderProps {
  isDarkMode: boolean;
  onThemeToggle: () => void;
  onMenuClick?: () => void;
  isMobile?: boolean;
}

export const AppHeader: React.FC<AppHeaderProps> = ({
  isDarkMode,
  onThemeToggle,
  onMenuClick,
  isMobile = false
}) => {
  const { token } = theme.useToken();

  // 断开连接交给 ConnectButton 的菜单处理

  return (
    <Header
      style={{
        background: token.colorBgContainer,
        borderBottom: `1px solid ${token.colorBorder}`,
        padding: '0 24px',
        display: 'flex',
        alignItems: 'center',
        justifyContent: 'space-between',
        position: 'sticky',
        top: 0,
        zIndex: 1000,
        boxShadow: token.boxShadow
      }}
    >
      <Space size="large">
        {isMobile && (
          <Button
            type="text"
            icon={<MenuOutlined />}
            onClick={onMenuClick}
            style={{ marginLeft: -12 }}
          />
        )}
        <motion.div
          initial={{ opacity: 0, x: -20 }}
          animate={{ opacity: 1, x: 0 }}
          transition={{ duration: 0.3 }}
        >
          <Space align="center">
            <img
              src={isDarkMode ? '/branding/veilmint-icon-dark.svg' : '/branding/veilmint-icon-light.svg'}
              alt="SOVEREIGN"
              style={{ width: 32, height: 32, borderRadius: 8 }}
            />
            {!isMobile && (
              <div>
                <Text strong style={{ fontSize: 18, margin: 0, fontFamily: "'Playfair Display', serif", fontWeight: 700 }}>
                  SOVEREIGN
                </Text>
                <Badge
                  count="TESTNET"
                  style={{
                    backgroundColor: token.colorWarning,
                    color: token.colorTextBase,
                    fontSize: 10,
                    height: 16,
                    lineHeight: '16px',
                    marginLeft: 8
                  }}
                />
              </div>
            )}
          </Space>
        </motion.div>
      </Space>

      <Space size="middle">
        {!isMobile && (
          <Switch
            checked={isDarkMode}
            onChange={onThemeToggle}
            checkedChildren={<MoonOutlined />}
            unCheckedChildren={<SunOutlined />}
          />
        )}
        <ConnectButton chainStatus="icon" accountStatus={{ smallScreen: 'avatar', largeScreen: 'full' }} />
      </Space>
    </Header>
  );
};
