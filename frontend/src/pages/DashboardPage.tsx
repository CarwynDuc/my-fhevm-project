import React, { useState, useEffect } from 'react';
import {
  Typography, Row, Col, Card, Space, Tag, Empty, Button, Statistic,
  Avatar, Table, Badge, theme, Tabs, Progress, Tooltip
} from 'antd';
import {
  WalletOutlined, TrophyOutlined, ClockCircleOutlined,
  LockOutlined, EyeOutlined, EyeInvisibleOutlined,
  ReloadOutlined, RocketOutlined
} from '@ant-design/icons';
import { motion } from 'framer-motion';
import { useAccount } from 'wagmi';
import type { TabsProps } from 'antd';
import dayjs from 'dayjs';
import relativeTime from 'dayjs/plugin/relativeTime';

dayjs.extend(relativeTime);

const { Title, Text, Paragraph } = Typography;

interface NFTItem {
  id: string;
  tokenId: string;
  name: string;
  collection: string;
  image: string;
  mintedAt: number;
  rarity: 'common' | 'rare' | 'epic' | 'legendary';
  encryptedTrait?: string;
  revealed: boolean;
}

export const DashboardPage: React.FC = () => {
  const { token } = theme.useToken();
  const { isConnected } = useAccount();
  const [userNFTs, setUserNFTs] = useState<NFTItem[]>([]);
  const [loading, setLoading] = useState(false);
  const [activeTab, setActiveTab] = useState('owned');

  // Load user NFTs
  useEffect(() => {
    if (isConnected) {
      setLoading(true);
      // Fetch user's NFT data
      setTimeout(() => {
        setUserNFTs([
          {
            id: '1',
            tokenId: '#0042',
            name: 'Genesis Avatar #42',
            collection: 'FHE Genesis Collection',
            image: 'https://images.unsplash.com/photo-1634986666676-ec8fd927c23d?w=400&h=400&fit=crop',
            mintedAt: Date.now() - 86400000,
            rarity: 'legendary',
            encryptedTrait: '0x1234...abcd',
            revealed: false
          },
          {
            id: '2',
            tokenId: '#0156',
            name: 'Encrypted Avatar #156',
            collection: 'Encrypted Avatars',
            image: 'https://images.unsplash.com/photo-1620321023374-d1a68fbc720d?w=400&h=400&fit=crop',
            mintedAt: Date.now() - 172800000,
            rarity: 'epic',
            encryptedTrait: '0x5678...efgh',
            revealed: true
          },
          {
            id: '3',
            tokenId: '#0023',
            name: 'Membership Pass #23',
            collection: 'Private Membership Pass',
            image: 'https://images.unsplash.com/photo-1614064641938-3bbee52942c7?w=400&h=400&fit=crop',
            mintedAt: Date.now() - 259200000,
            rarity: 'rare',
            revealed: false
          }
        ]);
        setLoading(false);
      }, 1000);
    }
  }, [isConnected]);

  const handleRevealTrait = (nftId: string) => {
    setUserNFTs(prev =>
      prev.map(nft =>
        nft.id === nftId ? { ...nft, revealed: true } : nft
      )
    );
  };

  const rarityColors = {
    common: token.colorTextSecondary,
    rare: token.colorInfo,
    epic: token.colorWarning,
    legendary: token.colorError
  };

  const statsCards = [
    {
      title: 'Total NFTs',
      value: userNFTs.length,
      icon: <WalletOutlined />,
      color: token.colorPrimary
    },
    {
      title: 'Collections',
      value: new Set(userNFTs.map(nft => nft.collection)).size,
      icon: <TrophyOutlined />,
      color: token.colorSuccess
    },
    {
      title: 'Encrypted Traits',
      value: userNFTs.filter(nft => nft.encryptedTrait).length,
      icon: <LockOutlined />,
      color: token.colorWarning
    },
    {
      title: 'Last Minted',
      value: userNFTs.length > 0 ? dayjs(Math.max(...userNFTs.map(n => n.mintedAt))).fromNow() : 'Never',
      icon: <ClockCircleOutlined />,
      color: token.colorInfo,
      isTime: true
    }
  ];

  const columns = [
    {
      title: 'NFT',
      key: 'nft',
      render: (record: NFTItem) => (
        <Space>
          <Avatar src={record.image} size={48} shape="square" />
          <div>
            <Text strong>{record.name}</Text>
            <br />
            <Text type="secondary" style={{ fontSize: 12 }}>
              {record.collection}
            </Text>
          </div>
        </Space>
      )
    },
    {
      title: 'Token ID',
      dataIndex: 'tokenId',
      key: 'tokenId',
      render: (id: string) => <Tag>{id}</Tag>
    },
    {
      title: 'Rarity',
      dataIndex: 'rarity',
      key: 'rarity',
      render: (rarity: string) => (
        <Tag color={rarityColors[rarity as keyof typeof rarityColors]}>
          {rarity.toUpperCase()}
        </Tag>
      )
    },
    {
      title: 'Encrypted Trait',
      key: 'trait',
      render: (record: NFTItem) => {
        if (!record.encryptedTrait) return <Text type="secondary">-</Text>;
        return (
          <Space>
            {record.revealed ? (
              <Tooltip title="Trait revealed">
                <Tag icon={<EyeOutlined />} color="success">
                  Revealed
                </Tag>
              </Tooltip>
            ) : (
              <Button
                size="small"
                icon={<EyeInvisibleOutlined />}
                onClick={() => handleRevealTrait(record.id)}
              >
                Reveal
              </Button>
            )}
          </Space>
        );
      }
    },
    {
      title: 'Minted',
      dataIndex: 'mintedAt',
      key: 'mintedAt',
      render: (timestamp: number) => dayjs(timestamp).fromNow()
    }
  ];

  const tabItems: TabsProps['items'] = [
    {
      key: 'owned',
      label: (
        <Space>
          <WalletOutlined />
          <span>Owned NFTs</span>
          <Badge count={userNFTs.length} />
        </Space>
      ),
      children: (
        <Table
          dataSource={userNFTs}
          columns={columns}
          rowKey="id"
          loading={loading}
          pagination={{ pageSize: 5 }}
        />
      )
    },
    {
      key: 'activity',
      label: (
        <Space>
          <ClockCircleOutlined />
          <span>Recent Activity</span>
        </Space>
      ),
      children: (
        <Empty
          description="No recent activity"
          image={Empty.PRESENTED_IMAGE_SIMPLE}
        />
      )
    },
    {
      key: 'analytics',
      label: (
        <Space>
          <TrophyOutlined />
          <span>Analytics</span>
        </Space>
      ),
      children: (
        <Row gutter={[16, 16]}>
          <Col span={12}>
            <Card>
              <Statistic
                title="Collection Distribution"
                value={75}
                suffix="%"
                prefix={<Progress type="circle" percent={75} size={60} />}
              />
            </Card>
          </Col>
          <Col span={12}>
            <Card>
              <Statistic
                title="Trait Reveal Rate"
                value={33}
                suffix="%"
                prefix={<Progress type="circle" percent={33} size={60} strokeColor={token.colorWarning} />}
              />
            </Card>
          </Col>
        </Row>
      )
    }
  ];

  if (!isConnected) {
    return (
      <div style={{ textAlign: 'center', padding: '100px 24px' }}>
        <motion.div
          initial={{ scale: 0.9, opacity: 0 }}
          animate={{ scale: 1, opacity: 1 }}
          transition={{ duration: 0.3 }}
        >
          <LockOutlined style={{ fontSize: 64, color: token.colorTextTertiary }} />
          <Title level={3} style={{ marginTop: 24 }}>
            Connect Your Wallet
          </Title>
          <Paragraph type="secondary">
            Please connect your wallet to view your NFT dashboard
          </Paragraph>
        </motion.div>
      </div>
    );
  }

  return (
    <div style={{ padding: '24px 0' }}>
      <motion.div
        initial={{ opacity: 0, y: -20 }}
        animate={{ opacity: 1, y: 0 }}
        transition={{ duration: 0.5 }}
      >
        {/* Header */}
        <div style={{ marginBottom: 32 }}>
          <Title level={2} style={{ marginBottom: 8 }}>
            My NFT Dashboard
          </Title>
          <Text type="secondary">
            Manage your FHE-encrypted NFT collection
          </Text>
        </div>

        {/* Stats Cards */}
        <Row gutter={[16, 16]} style={{ marginBottom: 32 }}>
          {statsCards.map((stat, index) => (
            <Col xs={24} sm={12} lg={6} key={index}>
              <motion.div
                initial={{ opacity: 0, y: 20 }}
                animate={{ opacity: 1, y: 0 }}
                transition={{ delay: index * 0.1 }}
              >
                <Card
                  style={{
                    borderRadius: token.borderRadius * 2,
                    background: token.colorBgContainer
                  }}
                >
                  <Space direction="vertical" style={{ width: '100%' }}>
                    <div
                      style={{
                        width: 48,
                        height: 48,
                        borderRadius: token.borderRadius,
                        background: `${stat.color}20`,
                        display: 'flex',
                        alignItems: 'center',
                        justifyContent: 'center',
                        fontSize: 24,
                        color: stat.color
                      }}
                    >
                      {stat.icon}
                    </div>
                    <div>
                      <Text type="secondary" style={{ fontSize: 12 }}>
                        {stat.title}
                      </Text>
                      <div>
                        {stat.isTime ? (
                          <Text strong style={{ fontSize: 20 }}>
                            {stat.value}
                          </Text>
                        ) : (
                          <Title level={3} style={{ margin: 0 }}>
                            {stat.value}
                          </Title>
                        )}
                      </div>
                    </div>
                  </Space>
                </Card>
              </motion.div>
            </Col>
          ))}
        </Row>

        {/* NFT Gallery */}
        <Card
          style={{
            borderRadius: token.borderRadius * 2,
            marginBottom: 32
          }}
          styles={{ body: { padding: 0 } }}
        >
          <div style={{ padding: 24, borderBottom: `1px solid ${token.colorBorder}` }}>
            <Row align="middle" justify="space-between">
              <Col>
                <Title level={4} style={{ margin: 0 }}>
                  Your Collection
                </Title>
              </Col>
              <Col>
                <Button icon={<ReloadOutlined />} onClick={() => setLoading(true)}>
                  Refresh
                </Button>
              </Col>
            </Row>
          </div>
          
          {userNFTs.length > 0 ? (
            <Row gutter={[16, 16]} style={{ padding: 24 }}>
              {userNFTs.slice(0, 4).map((nft, index) => (
                <Col xs={24} sm={12} md={6} key={nft.id}>
                  <motion.div
                    whileHover={{ y: -4 }}
                    initial={{ opacity: 0, scale: 0.9 }}
                    animate={{ opacity: 1, scale: 1 }}
                    transition={{ delay: index * 0.1 }}
                  >
                    <Card
                      hoverable
                      cover={
                        <div style={{ position: 'relative' }}>
                          <img
                            src={nft.image}
                            alt={nft.name}
                            style={{
                              width: '100%',
                              height: 200,
                              objectFit: 'cover'
                            }}
                          />
                          {nft.encryptedTrait && (
                            <Badge
                              count={
                                <LockOutlined style={{ fontSize: 12 }} />
                              }
                              style={{
                                position: 'absolute',
                                top: 8,
                                right: 8,
                                backgroundColor: 'rgba(0,0,0,0.6)'
                              }}
                            />
                          )}
                        </div>
                      }
                    >
                      <Space direction="vertical" size="small" style={{ width: '100%' }}>
                        <Text strong>{nft.name}</Text>
                        <Tag color={rarityColors[nft.rarity]}>
                          {nft.rarity.toUpperCase()}
                        </Tag>
                      </Space>
                    </Card>
                  </motion.div>
                </Col>
              ))}
            </Row>
          ) : (
            <Empty
              style={{ padding: '60px 24px' }}
              description="No NFTs found"
              image={Empty.PRESENTED_IMAGE_SIMPLE}
            >
              <Button type="primary" icon={<RocketOutlined />}>
                Mint Your First NFT
              </Button>
            </Empty>
          )}
        </Card>

        {/* Tabs Section */}
        <Card style={{ borderRadius: token.borderRadius * 2 }}>
          <Tabs
            activeKey={activeTab}
            onChange={setActiveTab}
            items={tabItems}
          />
        </Card>
      </motion.div>
    </div>
  );
};
