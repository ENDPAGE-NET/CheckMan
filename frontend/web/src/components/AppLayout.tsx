import { useState } from 'react'
import { Layout, Menu, Dropdown, Avatar, Tag } from 'antd'
import type { MenuProps } from 'antd'
import {
  DashboardOutlined,
  TeamOutlined,
  SafetyCertificateOutlined,
  ClockCircleOutlined,
  LockOutlined,
  LogoutOutlined,
  CrownOutlined,
  MenuOutlined,
  CloseOutlined,
} from '@ant-design/icons'
import { Outlet, useNavigate, useLocation } from 'react-router-dom'
import { useAuthStore } from '../stores/auth'
import { useBreakpoint, isMobile } from '../hooks/useBreakpoint'
import styles from './AppLayout.module.css'

const { Sider, Content, Header } = Layout

export default function AppLayout() {
  const navigate = useNavigate()
  const location = useLocation()
  const { username, isSuper, logout } = useAuthStore()
  const bp = useBreakpoint()
  const mobile = isMobile(bp)
  const [mobileMenuOpen, setMobileMenuOpen] = useState(false)

  const handleLogout = () => {
    logout()
    navigate('/login', { replace: true })
  }

  const handleMenuClick = (key: string) => {
    navigate(key)
    setMobileMenuOpen(false)
  }

  const menuItems = [
    { key: '/', icon: <DashboardOutlined />, label: '仪表盘' },
    { key: '/employees', icon: <TeamOutlined />, label: '员工管理' },
    { key: '/policies', icon: <SafetyCertificateOutlined />, label: '考勤策略' },
    { key: '/records', icon: <ClockCircleOutlined />, label: '打卡记录' },
    ...(isSuper
      ? [{ key: '/admins', icon: <CrownOutlined />, label: '管理员管理' }]
      : []),
  ]

  const dropdownItems: MenuProps['items'] = [
    {
      key: 'info',
      label: (
        <div className={styles.dropdownInfo}>
          <div className={styles.dropdownUsername}>{username}</div>
          <Tag color={isSuper ? 'gold' : 'default'} style={{ marginTop: 4 }}>
            {isSuper ? '超级管理员' : '管理员'}
          </Tag>
        </div>
      ),
      disabled: true,
    },
    { type: 'divider' },
    {
      key: 'change-password',
      icon: <LockOutlined />,
      label: '修改密码',
      onClick: () => navigate('/login'),
    },
    { type: 'divider' },
    {
      key: 'logout',
      icon: <LogoutOutlined />,
      label: '退出登录',
      danger: true,
      onClick: handleLogout,
    },
  ]

  const initial = (username || 'A')[0].toUpperCase()

  return (
    <Layout className={styles.layout}>
      {!mobile && (
        <Sider
          width={260}
          collapsedWidth={80}
          collapsed={bp === 'md'}
          className={styles.sider}
        >
          <div className={styles.logo}>
            {bp === 'md'
              ? <img src="/logo.png" alt="ENDPAGE" className={styles.logoImgSmall} />
              : <><img src="/logo.png" alt="ENDPAGE" className={styles.logoImg} /><span>ENDPAGE</span></>
            }
          </div>
          <Menu
            mode="inline"
            selectedKeys={[location.pathname]}
            items={menuItems}
            onClick={({ key }) => navigate(key)}
            className={styles.menu}
          />
        </Sider>
      )}
      <Layout>
        <Header className={styles.header}>
          {mobile ? (
            <div className={styles.headerLeft}>
              <button
                className={styles.hamburger}
                onClick={() => setMobileMenuOpen(!mobileMenuOpen)}
                aria-label="Toggle menu"
              >
                {mobileMenuOpen ? <CloseOutlined /> : <MenuOutlined />}
              </button>
              <img src="/logo.png" alt="ENDPAGE" className={styles.headerLogoImg} />
              <span className={styles.headerBrand}>ENDPAGE</span>
            </div>
          ) : (
            <div />
          )}
          <Dropdown menu={{ items: dropdownItems }} placement="bottomRight" trigger={['click']}>
            <div className={styles.userArea}>
              {!mobile && <span className={styles.userName}>{username}</span>}
              <Avatar className={styles.avatar} size={32}>
                {initial}
              </Avatar>
            </div>
          </Dropdown>
        </Header>
        {mobile && mobileMenuOpen && (
          <div className={styles.mobileNav}>
            <Menu
              mode="vertical"
              selectedKeys={[location.pathname]}
              items={menuItems}
              onClick={({ key }) => handleMenuClick(key)}
              className={styles.mobileMenu}
            />
          </div>
        )}
        <Content className={`${styles.content} ${mobile ? styles.contentMobile : bp === 'md' ? styles.contentTablet : ''}`}>
          <Outlet />
        </Content>
      </Layout>
    </Layout>
  )
}
