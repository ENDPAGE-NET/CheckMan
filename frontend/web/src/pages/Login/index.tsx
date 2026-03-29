import { useState } from 'react'
import { Form, Input, Button, Modal, message } from 'antd'
import { LockOutlined, UserOutlined } from '@ant-design/icons'
import { useNavigate } from 'react-router-dom'
import { useAuthStore } from '../../stores/auth'
import { adminLogin, adminChangePassword } from '../../api/auth'
import styles from './Login.module.css'

export default function Login() {
  const navigate = useNavigate()
  const login = useAuthStore((s) => s.login)
  const [loading, setLoading] = useState(false)
  const [changePwVisible, setChangePwVisible] = useState(false)
  const [changePwLoading, setChangePwLoading] = useState(false)
  const [changePwForm] = Form.useForm()

  const handleLogin = async (values: { username: string; password: string }) => {
    setLoading(true)
    try {
      const res = await adminLogin(values)
      login(res.access_token, res.username, res.is_super)
      if (res.must_change_password) {
        setChangePwVisible(true)
      } else {
        navigate('/', { replace: true })
      }
    } catch (err: unknown) {
      message.error(err instanceof Error ? err.message : '登录失败')
    } finally {
      setLoading(false)
    }
  }

  const handleChangePassword = async (values: { old_password: string; new_password: string }) => {
    setChangePwLoading(true)
    try {
      await adminChangePassword(values)
      message.success('密码修改成功')
      setChangePwVisible(false)
      navigate('/', { replace: true })
    } catch (err: unknown) {
      message.error(err instanceof Error ? err.message : '修改密码失败')
    } finally {
      setChangePwLoading(false)
    }
  }

  return (
    <div className={styles.page}>
      <div className={styles.container}>
        <div className={styles.brand}>
          <div className={styles.logo}>
            <img src="/logo.png" alt="ENDPAGE" />
          </div>
          <h1 className={styles.title}>ENDPAGE</h1>
          <p className={styles.subtitle}>智能打卡管理</p>
        </div>

        <Form onFinish={handleLogin} layout="vertical" size="large">
          <Form.Item name="username" rules={[{ required: true, message: '请输入用户名' }]}>
            <Input prefix={<UserOutlined />} placeholder="用户名" />
          </Form.Item>
          <Form.Item name="password" rules={[{ required: true, message: '请输入密码' }]}>
            <Input.Password prefix={<LockOutlined />} placeholder="密码" />
          </Form.Item>
          <Form.Item>
            <Button type="primary" htmlType="submit" loading={loading} block>
              登录
            </Button>
          </Form.Item>
        </Form>
      </div>

      <Modal title="修改密码" open={changePwVisible} closable={false} footer={null}>
        <p style={{ marginBottom: 16, color: '#59615F' }}>
          首次登录需要修改密码
        </p>
        <Form form={changePwForm} onFinish={handleChangePassword} layout="vertical">
          <Form.Item name="old_password" label="当前密码" rules={[{ required: true }]}>
            <Input.Password />
          </Form.Item>
          <Form.Item name="new_password" label="新密码" rules={[{ required: true, min: 6, message: '至少 6 个字符' }]}>
            <Input.Password />
          </Form.Item>
          <Form.Item>
            <Button type="primary" htmlType="submit" loading={changePwLoading} block>
              确认
            </Button>
          </Form.Item>
        </Form>
      </Modal>
    </div>
  )
}
