import React, { useState } from 'react';
import { Card, Typography, Space, Button, Progress, Tag, Badge, Tooltip, theme } from 'antd';
import {
  LockOutlined,
  ThunderboltOutlined,
  SafetyOutlined,
  RocketOutlined,
  LoadingOutlined
} from '@ant-design/icons';
import { motion } from 'framer-motion';
import { NFTCollection } from '@/types';
import { useAccount } from 'wagmi';
import { useConnectModal } from '@rainbow-me/rainbowkit';
import { notifyWarning } from '@/utils/txNotification';

const { Title, Text, Paragraph } = Typography;

interface NFTCollectionCardProps {
  collection: NFTCollection;
  onMint: (collectionId: string) => Promise<void>;
}

export const NFTCollectionCard: React.FC<NFTCollectionCardProps> = ({ collection, onMint }) => {
  const { token } = theme.useToken();
  const { isConnected } = useAccount();
  const { openConnectModal } = useConnectModal();
  const [isMinting, setIsMinting] = useState(false);

  const mintProgress = (collection.totalSupply / collection.maxSupply) * 100;
  const remainingSupply = collection.maxSupply - collection.totalSupply;
  const isSoldOut = remainingSupply === 0;

  const handleMint = async () => {
    if (!isConnected) {
      // 直接调起 RainbowKit 连接弹窗
      openConnectModal?.();
      return;
    }

    if (isSoldOut) {
      notifyWarning('Collection Sold Out', 'This collection is sold out!');
      return;
    }

    setIsMinting(true);
    try {
      await onMint(collection.id);
      // Success notification is handled in useContract hook
    } catch (error) {
      // Error notification is handled in useContract hook
      console.error('Minting error:', error);
    } finally {
      setIsMinting(false);
    }
  };

  const categoryColors = {
    art: token.colorPrimary,
    gaming: token.colorSuccess,
    membership: token.colorInfo,
    utility: '#8B5CF6'
  };

  return (
    <motion.div
      whileHover={{ y: -4 }}
      transition={{ duration: 0.2 }}
    >
      <Card
        hoverable
        style={{
          borderRadius: token.borderRadius * 2,
          overflow: 'hidden',
          border: `1px solid ${token.colorBorder}`,
          background: token.colorBgContainer,
          height: '100%',
          display: 'flex',
          flexDirection: 'column'
        }}
        styles={{ body: { padding: 0, flex: 1, display: 'flex', flexDirection: 'column' } }}
      >
        <div style={{ position: 'relative' }}>
          <div
            style={{
              height: 280,
              background: `url(${collection.image})`,
              backgroundSize: 'cover',
              backgroundPosition: 'center',
              position: 'relative'
            }}
          >
            <div
              style={{
                position: 'absolute',
                inset: 0,
                background: 'linear-gradient(to bottom, transparent 60%, rgba(0,0,0,0.6) 100%)'
              }}
            />
            
            <div style={{ position: 'absolute', top: 16, left: 16, right: 16 }}>
              <Space>
                <Badge
                  count={
                    <Space style={{ padding: '4px 8px' }}>
                      <LockOutlined style={{ fontSize: 12 }} />
                      <Text style={{ fontSize: 11, color: 'white' }}>FHE</Text>
                    </Space>
                  }
                  style={{
                    backgroundColor: 'rgba(0, 0, 0, 0.6)',
                    backdropFilter: 'blur(8px)',
                    borderRadius: token.borderRadius
                  }}
                />
                <Tag
                  color={categoryColors[collection.category]}
                  style={{
                    borderRadius: token.borderRadius,
                    textTransform: 'capitalize',
                    border: 'none'
                  }}
                >
                  {collection.category}
                </Tag>
              </Space>
            </div>

            {isSoldOut && (
              <div
                style={{
                  position: 'absolute',
                  inset: 0,
                  backgroundColor: 'rgba(0, 0, 0, 0.7)',
                  display: 'flex',
                  alignItems: 'center',
                  justifyContent: 'center'
                }}
              >
                <Badge
                  count="SOLD OUT"
                  style={{
                    backgroundColor: token.colorError,
                    fontSize: 24,
                    height: 'auto',
                    lineHeight: 1.5,
                    padding: '8px 24px',
                    borderRadius: token.borderRadius
                  }}
                />
              </div>
            )}
          </div>
        </div>

        <div style={{ padding: 24, flex: 1, display: 'flex', flexDirection: 'column' }}>
          <Space direction="vertical" size="middle" style={{ width: '100%', flex: 1 }}>
            <div>
              <Title level={4} style={{ margin: 0 }}>
                {collection.name}
              </Title>
              <Text type="secondary" style={{ fontSize: 12 }}>
                {collection.symbol}
              </Text>
            </div>

            <Paragraph
              type="secondary"
              ellipsis={{ rows: 2 }}
              style={{ marginBottom: 0 }}
            >
              {collection.description}
            </Paragraph>

            <Space wrap size="small">
              {collection.features.map((feature, index) => (
                <Tag
                  key={index}
                  icon={
                    feature.includes('Encrypt') ? <LockOutlined /> :
                    feature.includes('Zero') ? <SafetyOutlined /> :
                    <ThunderboltOutlined />
                  }
                  style={{
                    borderRadius: token.borderRadius,
                    backgroundColor: token.colorFillTertiary,
                    border: 'none'
                  }}
                >
                  {feature}
                </Tag>
              ))}
            </Space>

            <div>
              <Space style={{ width: '100%', justifyContent: 'space-between', marginBottom: 8 }}>
                <Text type="secondary">Minted</Text>
                <Text strong>
                  {collection.totalSupply} / {collection.maxSupply}
                </Text>
              </Space>
              <Progress
                percent={mintProgress}
                showInfo={false}
                strokeColor={{
                  '0%': '#9333EA',
                  '50%': '#A855F7',
                  '100%': '#EC4899'
                }}
                trailColor={token.colorFillSecondary}
                strokeWidth={8}
                style={{ marginBottom: 0 }}
              />
            </div>

            <div
              style={{
                padding: 16,
                borderRadius: token.borderRadius,
                background: token.colorFillQuaternary,
                border: `1px solid ${token.colorBorder}`
              }}
            >
              <Space style={{ width: '100%', justifyContent: 'space-between' }}>
                <div>
                  <Text type="secondary" style={{ fontSize: 12 }}>
                    Mint Price
                  </Text>
                  <div>
                    <Text strong style={{ fontSize: 20 }}>
                      FREE
                    </Text>
                    <Badge
                      count="0 ETH"
                      style={{
                        backgroundColor: token.colorSuccess,
                        marginLeft: 8,
                        fontSize: 10
                      }}
                    />
                  </div>
                </div>
                <Tooltip title={remainingSupply > 0 ? `${remainingSupply} remaining` : 'Sold out'}>
                  <Badge count={remainingSupply} overflowCount={9999} showZero>
                    <div style={{ width: 1, height: 1 }} />
                  </Badge>
                </Tooltip>
              </Space>
            </div>
          </Space>

          <Button
            type="primary"
            size="large"
            icon={isMinting ? <LoadingOutlined /> : <RocketOutlined />}
            onClick={handleMint}
            disabled={isSoldOut || isMinting}
            style={{
              width: '100%',
              marginTop: 16,
              height: 48,
              fontSize: 16,
              fontWeight: 600,
              borderRadius: token.borderRadius,
              background: !isSoldOut && !isMinting
                ? `linear-gradient(135deg, ${token.colorPrimary} 0%, ${token.colorInfo} 100%)`
                : undefined,
              boxShadow: !isSoldOut && !isMinting
                ? '0 8px 30px rgba(147, 51, 234, 0.35)'
                : undefined
            }}
          >
            {isMinting ? 'Minting...' : isSoldOut ? 'Sold Out' : 'Mint Now'}
          </Button>
        </div>
      </Card>
    </motion.div>
  );
};
