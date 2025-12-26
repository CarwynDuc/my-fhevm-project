import React, { useState } from 'react';
import { Typography, Row, Col, Space, Input, Select, Badge, Segmented, theme, Skeleton } from 'antd';
import {
  SearchOutlined,
  AppstoreOutlined,
  BarsOutlined,
  FilterOutlined,
  ThunderboltOutlined
} from '@ant-design/icons';
import { motion } from 'framer-motion';
import { NFTCollectionCard } from '@/components/NFTCollectionCard';
import { mockCollections } from '@/data/collections';
// import { NFTCollection } from '@/types';
import { useNFTContract } from '@/hooks/useContract';

const { Title, Text, Paragraph } = Typography;
const { Search } = Input;

export const HomePage: React.FC = () => {
  const { token } = theme.useToken();
  const [searchTerm, setSearchTerm] = useState('');
  const [selectedCategory, setSelectedCategory] = useState<string>('all');
  const [viewMode, setViewMode] = useState<'grid' | 'list'>('grid');
  const [isLoading] = useState(false);
  const { mintNFT } = useNFTContract();

  const handleMint = async (collectionId: string) => {
    // Mint NFT with encrypted traits using Zama's FHE SDK
    await mintNFT(collectionId);
  };

  const filteredCollections = mockCollections.filter((collection) => {
    const matchesSearch = collection.name.toLowerCase().includes(searchTerm.toLowerCase()) ||
                          collection.description.toLowerCase().includes(searchTerm.toLowerCase());
    const matchesCategory = selectedCategory === 'all' || collection.category === selectedCategory;
    return matchesSearch && matchesCategory;
  });

  const categories = [
    { label: 'All', value: 'all', count: mockCollections.length },
    { label: 'Art', value: 'art', count: mockCollections.filter(c => c.category === 'art').length },
    { label: 'Gaming', value: 'gaming', count: mockCollections.filter(c => c.category === 'gaming').length },
    { label: 'Membership', value: 'membership', count: mockCollections.filter(c => c.category === 'membership').length },
    { label: 'Utility', value: 'utility', count: mockCollections.filter(c => c.category === 'utility').length }
  ];

  const containerVariants = {
    hidden: { opacity: 0 },
    visible: {
      opacity: 1,
      transition: {
        staggerChildren: 0.1
      }
    }
  };

  const itemVariants = {
    hidden: { opacity: 0, y: 20 },
    visible: {
      opacity: 1,
      y: 0,
      transition: {
        duration: 0.5
      }
    }
  };

  return (
    <div style={{ padding: '24px 0' }}>
      {/* Hero Section */}
      <motion.div
        initial={{ opacity: 0, y: -20 }}
        animate={{ opacity: 1, y: 0 }}
        transition={{ duration: 0.5 }}
        style={{
          textAlign: 'center',
          marginBottom: 48,
          padding: '60px 24px',
          background: `linear-gradient(135deg, rgba(147, 51, 234, 0.1) 0%, rgba(236, 72, 153, 0.1) 100%)`,
          borderRadius: token.borderRadius * 2,
          position: 'relative',
          overflow: 'hidden',
          border: '1px solid rgba(147, 51, 234, 0.2)',
          backdropFilter: 'blur(10px)'
        }}
      >
        <div
          style={{
            position: 'absolute',
            top: -100,
            right: -100,
            width: 400,
            height: 400,
            background: 'radial-gradient(circle, #9333EA 0%, transparent 70%)',
            opacity: 0.3,
            borderRadius: '50%',
            filter: 'blur(80px)',
            animation: 'pulse 4s ease-in-out infinite'
          }}
        />
        <div
          style={{
            position: 'absolute',
            bottom: -100,
            left: -100,
            width: 350,
            height: 350,
            background: 'radial-gradient(circle, #EC4899 0%, transparent 70%)',
            opacity: 0.3,
            borderRadius: '50%',
            filter: 'blur(70px)',
            animation: 'pulse 4s ease-in-out infinite reverse'
          }}
        />
        <div
          style={{
            position: 'absolute',
            top: '50%',
            left: '50%',
            transform: 'translate(-50%, -50%)',
            width: 300,
            height: 300,
            background: 'radial-gradient(circle, #A855F7 0%, transparent 70%)',
            opacity: 0.2,
            borderRadius: '50%',
            filter: 'blur(60px)',
            animation: 'pulse 3s ease-in-out infinite'
          }}
        />
        
        <Space direction="vertical" size="large" style={{ position: 'relative' }}>
          <Badge
            count={
              <Space style={{ padding: '4px 12px' }}>
                <ThunderboltOutlined />
                <span>FHE Powered</span>
              </Space>
            }
            style={{
              backgroundColor: token.colorPrimary,
              fontSize: 12,
              height: 28,
              lineHeight: '28px',
              borderRadius: 14
            }}
          />
          
          <Title level={1} style={{ margin: 0, fontSize: 48, fontFamily: "'Playfair Display', serif", fontWeight: 700 }}>
            Sovereign Over Your Digital Assets
          </Title>

          <Paragraph
            style={{
              fontSize: 18,
              maxWidth: 600,
              margin: '0 auto',
              color: token.colorTextSecondary
            }}
          >
            The supreme NFT platform with Fully Homomorphic Encryption.
            Absolute control, complete privacy. Create NFTs with encrypted traits that stay yours, forever.
          </Paragraph>

          <div style={{ maxWidth: 500, margin: '0 auto' }}>
            <Search
              size="large"
              placeholder="Search private NFT collections..."
              prefix={<SearchOutlined />}
              value={searchTerm}
              onChange={(e) => setSearchTerm(e.target.value)}
              style={{
                borderRadius: token.borderRadius * 2
              }}
            />
          </div>
        </Space>
      </motion.div>

      {/* Filters Section */}
      <div style={{ marginBottom: 32 }}>
        <Row gutter={[16, 16]} align="middle">
          <Col xs={24} md={16}>
            <Segmented
              options={categories.map(cat => ({
                label: (
                  <Space>
                    {cat.label}
                    <Badge
                      count={cat.count}
                      style={{
                        backgroundColor: token.colorFillSecondary,
                        color: token.colorTextSecondary,
                        fontSize: 10
                      }}
                    />
                  </Space>
                ),
                value: cat.value
              }))}
              value={selectedCategory}
              onChange={setSelectedCategory}
              style={{ marginBottom: 16 }}
            />
          </Col>
          <Col xs={24} md={8} style={{ textAlign: 'right' }}>
            <Space>
              <Select
                defaultValue="newest"
                style={{ width: 120 }}
                options={[
                  { value: 'newest', label: 'Newest' },
                  { value: 'popular', label: 'Popular' },
                  { value: 'ending', label: 'Ending Soon' }
                ]}
                prefix={<FilterOutlined />}
              />
              <Segmented
                options={[
                  { label: <AppstoreOutlined />, value: 'grid' },
                  { label: <BarsOutlined />, value: 'list' }
                ]}
                value={viewMode}
                onChange={(value) => setViewMode(value as 'grid' | 'list')}
              />
            </Space>
          </Col>
        </Row>
      </div>

      {/* Collections Grid */}
      <motion.div
        variants={containerVariants}
        initial="hidden"
        animate="visible"
      >
        {isLoading ? (
          <Row gutter={[24, 24]}>
            {[1, 2, 3, 4, 5, 6].map((key) => (
              <Col key={key} xs={24} sm={12} lg={8}>
                <Skeleton active />
              </Col>
            ))}
          </Row>
        ) : filteredCollections.length > 0 ? (
          <Row gutter={[24, 24]}>
            {filteredCollections.map((collection) => (
              <Col key={collection.id} xs={24} sm={12} lg={8}>
                <motion.div variants={itemVariants}>
                  <NFTCollectionCard
                    collection={collection}
                    onMint={handleMint}
                  />
                </motion.div>
              </Col>
            ))}
          </Row>
        ) : (
          <div
            style={{
              textAlign: 'center',
              padding: '80px 24px',
              background: token.colorFillQuaternary,
              borderRadius: token.borderRadius * 2
            }}
          >
            <SearchOutlined style={{ fontSize: 48, color: token.colorTextTertiary }} />
            <Title level={4} style={{ marginTop: 16, color: token.colorTextSecondary }}>
              No collections found
            </Title>
            <Text type="secondary">
              Try adjusting your search or filter criteria
            </Text>
          </div>
        )}
      </motion.div>

      {/* Stats Section */}
      <motion.div
        initial={{ opacity: 0 }}
        animate={{ opacity: 1 }}
        transition={{ delay: 0.5 }}
        style={{
          marginTop: 64,
          padding: 32,
          background: token.colorFillQuaternary,
          borderRadius: token.borderRadius * 2,
          textAlign: 'center'
        }}
      >
        <Row gutter={[48, 24]}>
          <Col xs={24} sm={8}>
            <Title level={2} style={{ margin: 0, color: token.colorPrimary }}>
              {mockCollections.length}
            </Title>
            <Text type="secondary">Active Collections</Text>
          </Col>
          <Col xs={24} sm={8}>
            <Title level={2} style={{ margin: 0, color: token.colorSuccess }}>
              {mockCollections.reduce((sum, c) => sum + c.totalSupply, 0)}
            </Title>
            <Text type="secondary">NFTs Minted</Text>
          </Col>
          <Col xs={24} sm={8}>
            <Title level={2} style={{ margin: 0, color: token.colorInfo }}>
              100%
            </Title>
            <Text type="secondary">FHE Protected</Text>
          </Col>
        </Row>
      </motion.div>
    </div>
  );
};
