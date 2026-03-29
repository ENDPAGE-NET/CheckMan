import type { ThemeConfig } from 'antd'

const theme: ThemeConfig = {
  token: {
    colorPrimary: '#556257',
    colorBgContainer: '#FFFFFF',
    colorBgLayout: '#F8FAF8',
    colorBgElevated: '#FFFFFF',
    colorText: '#2D3432',
    colorTextSecondary: '#59615F',
    colorTextTertiary: '#8A918E',
    colorBorder: 'rgba(172, 179, 177, 0.15)',
    colorBorderSecondary: 'rgba(172, 179, 177, 0.1)',
    borderRadius: 8,
    borderRadiusLG: 16,
    fontFamily: "'Manrope', -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif",
    colorSuccess: '#556257',
    colorWarning: '#8B6E00',
    colorError: '#A73B21',
  },
  components: {
    Table: {
      headerBg: '#F1F4F2',
      rowHoverBg: '#E4E9E7',
      borderColor: 'transparent',
    },
    Card: {
      borderRadiusLG: 24,
    },
    Button: {
      borderRadius: 9999,
      primaryShadow: '0 4px 20px rgba(85, 98, 87, 0.12)',
    },
    Layout: {
      siderBg: '#F1F4F2',
    },
    Input: {
      activeBorderColor: 'rgba(85, 98, 87, 0.15)',
      hoverBorderColor: 'rgba(172, 179, 177, 0.25)',
    },
    Modal: {
      borderRadiusLG: 24,
    },
    Tag: {
      borderRadiusSM: 9999,
    },
  },
}

export default theme
