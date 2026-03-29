import { useEffect, useState } from 'react'
import { Table, Tag, Select, DatePicker, Button, Space, message } from 'antd'
import { SearchOutlined } from '@ant-design/icons'
import type { ColumnsType } from 'antd/es/table'
import dayjs from 'dayjs'
import { listRecords } from '../../api/records'
import { listEmployees } from '../../api/employees'
import type { CheckRecord, Employee } from '../../api/types'
import { useBreakpoint, isMobile } from '../../hooks/useBreakpoint'
import styles from './Records.module.css'

const { RangePicker } = DatePicker

export default function Records() {
  const [records, setRecords] = useState<CheckRecord[]>([])
  const [employees, setEmployees] = useState<Employee[]>([])
  const [loading, setLoading] = useState(false)
  const [employeeId, setEmployeeId] = useState<number | undefined>()
  const [dateRange, setDateRange] = useState<[dayjs.Dayjs, dayjs.Dayjs] | null>(null)
  const bp = useBreakpoint()
  const mobile = isMobile(bp)

  useEffect(() => { listEmployees().then(setEmployees).catch(() => {}) }, [])

  const load = async () => {
    setLoading(true)
    try {
      const params: { employee_id?: number; start_date?: string; end_date?: string } = {}
      if (employeeId) params.employee_id = employeeId
      if (dateRange) {
        params.start_date = dateRange[0].format('YYYY-MM-DD')
        params.end_date = dateRange[1].format('YYYY-MM-DD')
      }
      setRecords(await listRecords(params))
    } catch (err: any) { message.error(err.message) }
    finally { setLoading(false) }
  }

  useEffect(() => { load() }, [])

  const getEmployeeName = (empId: number) => employees.find((e) => e.id === empId)?.name ?? `#${empId}`

  const renderPassTag = (value: boolean | null) => {
    if (value === null) return <Tag color="default">不要求</Tag>
    return value ? <Tag color="success">通过</Tag> : <Tag color="error">未通过</Tag>
  }

  const allColumns: ColumnsType<CheckRecord> = [
    { title: '员工', dataIndex: 'employee_id', key: 'employee', render: (id: number) => getEmployeeName(id) },
    { title: '类型', dataIndex: 'check_type', key: 'type',
      render: (type: string) => <Tag color={type === 'clock_in' ? 'success' : 'processing'}>{type === 'clock_in' ? '签到' : '签退'}</Tag> },
    { title: '时间', dataIndex: 'check_time', key: 'time', render: (v: string) => dayjs(v).format(mobile ? 'MM-DD HH:mm' : 'YYYY-MM-DD HH:mm:ss') },
    { title: '人脸', dataIndex: 'face_passed', key: 'face', render: renderPassTag },
    { title: '地点', dataIndex: 'location_passed', key: 'location', render: renderPassTag },
  ]

  const hiddenOnMobile = ['face', 'location']

  const columns = allColumns.filter((col) => {
    const key = col.key as string
    if (mobile) return !hiddenOnMobile.includes(key)
    return true
  })

  return (
    <div>
      <h1 className="page-title" style={{ marginBottom: 24 }}>打卡记录</h1>
      <div className={styles.toolbar}>
        <Space wrap size={mobile ? 'small' : 'middle'} direction={mobile ? 'vertical' : 'horizontal'} style={mobile ? { width: '100%' } : undefined}>
          <Select placeholder="全部员工" allowClear showSearch optionFilterProp="label"
            style={{ width: mobile ? '100%' : 200 }} value={employeeId} onChange={setEmployeeId}
            options={employees.map((e) => ({ label: e.name, value: e.id }))} />
          <RangePicker value={dateRange} placeholder={['开始日期', '结束日期']}
            style={mobile ? { width: '100%' } : undefined}
            onChange={(dates) => setDateRange(dates as [dayjs.Dayjs, dayjs.Dayjs] | null)} />
          <Button type="primary" icon={<SearchOutlined />} onClick={load} block={mobile}>查询</Button>
        </Space>
      </div>
      <Table columns={columns} dataSource={records} rowKey="id" loading={loading}
        pagination={{ pageSize: 20 }} scroll={mobile ? { x: 400 } : undefined} />
    </div>
  )
}
