import React from 'react';
import { notification, Typography, Space } from 'antd';
import {
  LoadingOutlined,
  CheckCircleOutlined,
  CloseCircleOutlined,
  ExportOutlined
} from '@ant-design/icons';

const { Text, Link } = Typography;

const SEPOLIA_EXPLORER = 'https://sepolia.etherscan.io/tx';

/**
 * Get explorer URL for a transaction hash
 */
export const getExplorerUrl = (hash: string): string => {
  return `${SEPOLIA_EXPLORER}/${hash}`;
};

/**
 * Render a clickable transaction hash link
 */
const TxHashLink: React.FC<{ hash: string }> = ({ hash }) => (
  <Link
    href={getExplorerUrl(hash)}
    target="_blank"
    rel="noopener noreferrer"
    style={{ display: 'inline-flex', alignItems: 'center', gap: 4 }}
  >
    View on Etherscan
    <ExportOutlined style={{ fontSize: 12 }} />
  </Link>
);

/**
 * Show transaction pending notification
 */
export const notifyTxPending = (hash: string, description?: string) => {
  notification.open({
    key: hash,
    message: (
      <Space>
        <LoadingOutlined spin style={{ color: '#1890ff' }} />
        <Text strong>Transaction Submitted</Text>
      </Space>
    ),
    description: (
      <Space direction="vertical" size="small">
        <Text type="secondary">{description || 'Waiting for confirmation...'}</Text>
        <TxHashLink hash={hash} />
      </Space>
    ),
    duration: 0, // Don't auto-close
    placement: 'topRight',
  });
};

/**
 * Show transaction success notification
 */
export const notifyTxSuccess = (hash: string, message?: string) => {
  notification.success({
    key: hash,
    message: (
      <Space>
        <CheckCircleOutlined style={{ color: '#52c41a' }} />
        <Text strong>Transaction Confirmed</Text>
      </Space>
    ),
    description: (
      <Space direction="vertical" size="small">
        <Text>{message || 'Transaction completed successfully!'}</Text>
        <TxHashLink hash={hash} />
      </Space>
    ),
    duration: 6,
    placement: 'topRight',
  });
};

/**
 * Show transaction error notification
 */
export const notifyTxError = (hash: string | undefined, errorMessage: string) => {
  const key = hash || `error-${Date.now()}`;

  notification.error({
    key,
    message: (
      <Space>
        <CloseCircleOutlined style={{ color: '#ff4d4f' }} />
        <Text strong>Transaction Failed</Text>
      </Space>
    ),
    description: (
      <Space direction="vertical" size="small">
        <Text type="secondary">{errorMessage}</Text>
        {hash && <TxHashLink hash={hash} />}
      </Space>
    ),
    duration: 8,
    placement: 'topRight',
  });
};

/**
 * Show user rejected notification
 */
export const notifyUserRejected = () => {
  notification.warning({
    message: 'Transaction Rejected',
    description: 'You rejected the transaction in your wallet.',
    duration: 4,
    placement: 'topRight',
  });
};

/**
 * Show general info notification
 */
export const notifyInfo = (message: string, description?: string) => {
  notification.info({
    message,
    description,
    duration: 4,
    placement: 'topRight',
  });
};

/**
 * Show general warning notification
 */
export const notifyWarning = (message: string, description?: string) => {
  notification.warning({
    message,
    description,
    duration: 4,
    placement: 'topRight',
  });
};

/**
 * Close a specific notification
 */
export const closeTxNotification = (hash: string) => {
  notification.destroy(hash);
};

/**
 * Check if error is user rejection
 */
export const isUserRejection = (error: any): boolean => {
  const message = error?.message?.toLowerCase() || '';
  const code = error?.code;

  return (
    code === 4001 || // MetaMask user rejection
    code === 'ACTION_REJECTED' ||
    message.includes('user rejected') ||
    message.includes('user denied') ||
    message.includes('rejected by user')
  );
};
