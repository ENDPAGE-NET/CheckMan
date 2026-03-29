import { useEffect, useState, useCallback } from 'react'
import { Table, Tag, Button, Space, Input, message, Popconfirm, Modal, Segmented } from 'antd'
import { PlusOutlined, SearchOutlined } from '@ant-design/icons'
import type { ColumnsType } from 'antd/es/table'
import {
  listEmployees, approveEmployee, rejectEmployee, deleteEmployee,
  resetEmployeePassword, resetEmployeeFace,
} from '../../api/employees'
import { listPolicies } from '../../api/policies'
import type { Employee, EmployeeStatus, Policy } from '../../api/types'
import EditModal from './EditModal'
import CreateModal from './CreateModal'
import { useBreakpoint, isMobile } from '../../hooks/useBreakpoint'
import styles from './Employees.module.css'

const statusOptions = [
  { label: '全部', value: '' },
  { label: '待审核', value: 'pending' },
  { label: '已激活', value: 'active' },
  { label: '已拒绝', value: 'rejected' },
]

const statusColorMap: Record<EmployeeStatus, string> = {
  pending: 'warning', active: 'success', rejected: 'error',
}

const statusLabelMap: Record<EmployeeStatus, string> = {
  pending: '待审核', active: '已激活', rejected: '已拒绝',
}

export default function Employees() {
  const [employees, setEmployees] = useState<Employee[]>([])
  const [policies, setPolicies] = useState<Policy[]>([])
  const [loading, setLoading] = useState(true)
  const [statusFilter, setStatusFilter] = useState<string>('')
  const [nameFilter, setNameFilter] = useState('')
  const [editingEmployee, setEditingEmployee] = useState<Employee | null>(null)
  const [createModalOpen, setCreateModalOpen] = useState(false)
  const bp = useBreakpoint()
  const mobile = isMobile(bp)

  const load = useCallback(async () => {
    setLoading(true)
    try {
      const params: { status?: EmployeeStatus; name?: string } = {}
      if (statusFilter) params.status = statusFilter as EmployeeStatus
      if (nameFilter) params.name = nameFilter
      const [emps, pols] = await Promise.all([listEmployees(params), listPolicies()])
      setEmployees(emps)
      setPolicies(pols)
    } catch (err: any) {
      message.error(err.message)
    } finally {
      setLoading(false)
    }
  }, [statusFilter, nameFilter])

  useEffect(() => { load() }, [load])

  const handleApprove = async (id: number) => {
    try { await approveEmployee(id); message.success('员工已通过'); load() }
    catch (err: any) { message.error(err.message) }
  }

  const handleReject = async (id: number) => {
    try { await rejectEmployee(id); message.success('员工已拒绝'); load() }
    catch (err: any) { message.error(err.message) }
  }

  const handleDelete = async (id: number) => {
    try { await deleteEmployee(id); message.success('员工已删除'); load() }
    catch (err: any) { message.error(err.message) }
  }

  const handleResetPassword = async (id: number) => {
    try {
      const res = await resetEmployeePassword(id)
      Modal.info({
        title: '密码已重置',
        content: (
          <div>
            <p>临时密码：</p>
            <p style={{ fontSize: '1.2rem', fontWeight: 700, fontFamily: 'monospace' }}>{res.temp_password}</p>
            <p style={{ color: '#8A918E', marginTop: 8 }}>请将此密码告知员工，员工登录后需要修改密码。</p>
          </div>
        ),
      })
      load()
    } catch (err: any) { message.error(err.message) }
  }

  const handleResetFace = async (id: number) => {
    try { await resetEmployeeFace(id); message.success('人脸数据已重置'); load() }
    catch (err: any) { message.error(err.message) }
  }

  const handleCreated = (password: string) => {
    setCreateModalOpen(false)
    Modal.info({
      title: '员工创建成功',
      content: (
        <div>
          <p>初始密码：</p>
          <p style={{ fontSize: '1.2rem', fontWeight: 700, fontFamily: 'monospace' }}>{password}</p>
          <p style={{ color: '#8A918E', marginTop: 8 }}>请将此密码告知员工，员工通过 App 登录后需要修改密码并录入人脸。</p>
        </div>
      ),
    })
    load()
  }

  const getPolicyName = (policyId: number | null) => {
    if (!policyId) return '-'
    return policies.find((p) => p.id === policyId)?.name ?? '-'
  }

  const allColumns: ColumnsType<Employee> = [
    { title: '姓名', dataIndex: 'name', key: 'name' },
    { title: '用户名', dataIndex: 'username', key: 'username' },
    { title: '状态', dataIndex: 'status', key: 'status',
      render: (status: EmployeeStatus) => <Tag color={statusColorMap[status]}>{statusLabelMap[status]}</Tag> },
    { title: '策略', key: 'policy', render: (_: unknown, r: Employee) => getPolicyName(r.policy_id) },
    { title: '人脸', dataIndex: 'face_registered', key: 'face',
      render: (v: boolean) => <Tag color={v ? 'success' : 'default'}>{v ? '已录入' : '未录入'}</Tag> },
    { title: '注册时间', dataIndex: 'created_at', key: 'created_at',
      render: (v: string) => new Date(v).toLocaleDateString() },
    { title: '操作', key: 'actions', render: (_: unknown, record: Employee) => (
      <Space size="small">
        {record.status === 'pending' && (
          <>
            <Button type="link" size="small" onClick={() => handleApprove(record.id)}>通过</Button>
            <Popconfirm title="确认拒绝该员工？" onConfirm={() => handleReject(record.id)}>
              <Button type="link" size="small" danger>拒绝</Button>
            </Popconfirm>
          </>
        )}
        {record.status === 'active' && (
          <>
            <Button type="link" size="small" onClick={() => setEditingEmployee(record)}>编辑</Button>
            <Popconfirm title="确认重置密码？" onConfirm={() => handleResetPassword(record.id)}>
              <Button type="link" size="small">重置密码</Button>
            </Popconfirm>
            <Popconfirm title="确认重置人脸数据？" onConfirm={() => handleResetFace(record.id)}>
              <Button type="link" size="small">重置人脸</Button>
            </Popconfirm>
          </>
        )}
        <Popconfirm title="确认删除该员工？" onConfirm={() => handleDelete(record.id)}>
          <Button type="link" size="small" danger>删除</Button>
        </Popconfirm>
      </Space>
    )},
  ]

  const hiddenOnMobile = ['username', 'policy', 'face', 'created_at']
  const hiddenOnTablet = ['created_at']

  const columns = allColumns.filter((col) => {
    const key = col.key as string
    if (mobile) return !hiddenOnMobile.includes(key)
    if (bp === 'md') return !hiddenOnTablet.includes(key)
    return true
  })

  return (
    <div>
      <h1 className="page-title" style={{ marginBottom: 24 }}>员工管理</h1>
      {mobile ? (
        <div className={styles.toolbar} style={{ flexDirection: 'column', alignItems: 'stretch' }}>
          <Input placeholder="搜索姓名..." prefix={<SearchOutlined />} value={nameFilter}
            onChange={(e) => setNameFilter(e.target.value)} allowClear />
          <div style={{ display: 'flex', gap: 8, justifyContent: 'space-between', marginTop: 8 }}>
            <Segmented options={statusOptions} value={statusFilter}
              onChange={(v) => setStatusFilter(v as string)} size="small" />
            <Button type="primary" icon={<PlusOutlined />} onClick={() => setCreateModalOpen(true)}>
              添加
            </Button>
          </div>
        </div>
      ) : (
        <div className={styles.toolbar}>
          <div style={{ display: 'flex', gap: 12, alignItems: 'center' }}>
            <Input placeholder="搜索姓名..." prefix={<SearchOutlined />} value={nameFilter}
              onChange={(e) => setNameFilter(e.target.value)} style={{ width: 240 }} allowClear />
            <Segmented options={statusOptions} value={statusFilter}
              onChange={(v) => setStatusFilter(v as string)} />
          </div>
          <Button type="primary" icon={<PlusOutlined />} onClick={() => setCreateModalOpen(true)}>
            添加员工
          </Button>
        </div>
      )}
      <Table columns={columns} dataSource={employees} rowKey="id" loading={loading}
        pagination={{ pageSize: 20 }} scroll={mobile ? { x: 500 } : undefined} />
      <EditModal employee={editingEmployee} policies={policies}
        onClose={() => setEditingEmployee(null)} onSaved={() => { setEditingEmployee(null); load() }} />
      <CreateModal
        open={createModalOpen}
        policies={policies}
        onClose={() => setCreateModalOpen(false)}
        onCreated={handleCreated}
      />
    </div>
  )
}
