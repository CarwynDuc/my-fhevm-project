import { ThemeConfig, theme } from 'antd';

export const lightTheme: ThemeConfig = {
  token: {
    colorPrimary: '#6B2E8F',
    colorInfo: '#8B5FBF',
    colorSuccess: '#10B981',
    colorWarning: '#FFD700',
    colorError: '#EF4444',
    colorBgLayout: '#F5F3FF',
    colorBgContainer: '#FFFFFF',
    colorTextBase: '#1F2937',
    colorBorder: '#E5E4E2',
    fontFamily: "'Playfair Display', 'Space Grotesk', 'Inter', -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, serif",
    borderRadius: 16,
    fontSize: 14,
    boxShadow: '0 10px 40px rgba(107,46,143,0.15)',
    boxShadowSecondary: '0 15px 45px rgba(139,95,191,0.2)'
  },
  components: {
    Button: {
      primaryShadow: '0 4px 20px rgba(107, 46, 143, 0.35)',
      defaultBorderColor: '#E5E4E2',
      fontWeight: 600
    },
    Card: {
      boxShadowTertiary: '0 8px 30px rgba(107, 46, 143, 0.1)',
      paddingLG: 24
    },
    Layout: {
      headerBg: '#FFFFFF',
      headerHeight: 70,
      siderBg: '#FFFFFF'
    },
    Menu: {
      itemBg: 'transparent',
      itemSelectedBg: '#F3E8FF',
      itemHoverBg: '#FAF5FF'
    },
    Table: {
      headerBg: '#FAF5FF',
      rowHoverBg: '#F3E8FF'
    },
    Tag: {
      defaultBg: '#F3E8FF',
      defaultColor: '#6B21A8'
    }
  }
};

export const darkTheme: ThemeConfig = {
  algorithm: theme.darkAlgorithm,
  token: {
    colorPrimary: '#8B5FBF',
    colorInfo: '#9B6FD0',
    colorSuccess: '#10B981',
    colorWarning: '#FFD700',
    colorError: '#F87171',
    colorBgBase: '#0A0212',
    colorBgContainer: '#2A1A3D',
    colorBgLayout: '#0A0212',
    colorTextBase: '#F3E8FF',
    colorBorder: '#4A2E6F',
    fontFamily: "'Playfair Display', 'Space Grotesk', 'Inter', -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, serif",
    borderRadius: 16,
    fontSize: 14
  },
  components: {
    Button: {
      primaryShadow: '0 6px 25px rgba(139, 95, 191, 0.4)',
      fontWeight: 600
    },
    Card: {
      colorBgContainer: '#2A1A3D',
      boxShadowTertiary: '0 10px 40px rgba(139, 95, 191, 0.15)'
    },
    Layout: {
      headerBg: '#2A1A3D',
      headerHeight: 70,
      siderBg: '#2A1A3D'
    },
    Menu: {
      itemBg: 'transparent',
      itemSelectedBg: '#2E1065',
      itemHoverBg: '#1E0836'
    },
    Table: {
      headerBg: '#2E1065',
      rowHoverBg: '#1E0836'
    },
    Tag: {
      defaultBg: '#2E1065',
      defaultColor: '#E9D5FF'
    }
  }
};
