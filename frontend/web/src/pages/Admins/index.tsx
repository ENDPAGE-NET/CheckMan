import { useEffect, useState } from 'react'
import { Table, Tag, Button, Space, Popconfirm, Modal, message } from 'antd'
import { PlusOutlined } from '@ant-design/icons'
import type { ColumnsType } from 'antd/es/table'
import { listAdmins, deleteAdmin, resetAdminPassword } from '../../api/admins'
import type { AdminUser } from '../../api/types'
import { useAuthStore } from '../../stores/auth'
import { useBreakpoint, isMobile } from '../../hooks/useBreakpoint'
import CreateAdminModal from './CreateAdminModal'
import styles from './Admins.module.css'

export default function Admins() {
  const [admins, setAdmins] = useState<AdminUser[]>([])
  const [loading, setLoading] = useState(true)
  const [createOpen, setCreateOpen] = useState(false)
  const currentUsername = useAuthStore((s) => s.username)
  const bp = useBreakpoint()
  const mobile = isMobile(bp)

  const load = async () => {
    setLoading(true)
    try {
      setAdmins(await listAdmins())
    } catch (err: any) {
      message.error(err.message)
    } finally {
      setLoading(false)
    }
  }

  useEffect(() => { load() }, [])

  const handleDelete = async (id: number) => {
    try {
      await deleteAdmin(id)
      message.success('管理员已删除')
      load()
    } catch (err: any) {
      message.error(err.message)
    }
  }

  const handleResetPassword = async (id: number) => {
    try {
      const res = await resetAdminPassword(id)
      Modal.info({
        title: '密码已重置',
        content: (
          <div>
            <p>临时密码：</p>
            <p style={{ fontSize: '1.2rem', fontWeight: 700, fontFamily: 'monospace' }}>{res.temp_password}</p>
            <p style={{ color: '#8A918E', marginTop: 8 }}>请将此密码告知该管理员，登录后需要修改密码。</p>
          </div>
        ),
      })
      load()
    } catch (err: any) {
      message.error(err.message)
    }
  }

  const allColumns: ColumnsType<AdminUser> = [
    { title: '用户名', dataIndex: 'username', key: 'username' },
    {
      title: '角色', dataIndex: 'is_super', key: 'role',
      render: (isSuper: boolean) => (
        <Tag color={isSuper ? 'gold' : 'default'}>{isSuper ? '超级管理员' : '管理员'}</Tag>
      ),
    },
    {
      title: '创建时间', dataIndex: 'created_at', key: 'created_at',
      render: (v: string) => new Date(v).toLocaleDateString(),
    },
    {
      title: '操作', key: 'actions',
      render: (_: unknown, record: AdminUser) => {
        const isSelf = record.username === currentUsername
        return (
          <Space size="small">
            <Popconfirm title="确认重置密码？" onConfirm={() => handleResetPassword(record.id)}>
              <Button type="link" size="small">重置密码</Button>
            </Popconfirm>
            {!isSelf && (
              <Popconfirm title="确认删除该管理员？" onConfirm={() => handleDelete(record.id)}>
                <Button type="link" size="small" danger>删除</Button>
              </Popconfirm>
            )}
          </Space>
        )
      },
    },
  ]

  const columns = allColumns.filter((col) => {
    const key = col.key as string
    if (mobile) return key !== 'created_at'
    return true
  })

  return (
    <div>
      <div className={styles.header}>
        <h1 className="page-title">管理员管理</h1>
        <Button type="primary" icon={<PlusOutlined />} onClick={() => setCreateOpen(true)}>
          {mobile ? '添加' : '添加管理员'}
        </Button>
      </div>
      <Table columns={columns} dataSource={admins} rowKey="id" loading={loading} pagination={false} />
      <CreateAdminModal
        open={createOpen}
        onClose={() => setCreateOpen(false)}
        onCreated={() => { setCreateOpen(false); load() }}
      />
    </div>
  )
}
