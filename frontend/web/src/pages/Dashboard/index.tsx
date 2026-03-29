import { useEffect, useState } from 'react'
import { Row, Col, Card, Spin, message } from 'antd'
import {
  TeamOutlined,
  ClockCircleOutlined,
  UserSwitchOutlined,
  CheckCircleOutlined,
} from '@ant-design/icons'
import { listEmployees } from '../../api/employees'
import { listRecords } from '../../api/records'
import type { Employee, CheckRecord } from '../../api/types'
import styles from './Dashboard.module.css'

interface Stats {
  todayAttendance: number
  activeTotal: number
  pendingCount: number
  todayRecords: number
}

export default function Dashboard() {
  const [stats, setStats] = useState<Stats | null>(null)
  const [loading, setLoading] = useState(true)

  useEffect(() => {
    loadStats()
  }, [])

  const loadStats = async () => {
    try {
      const today = new Date().toISOString().split('T')[0]
      const [employees, records] = await Promise.all([
        listEmployees(),
        listRecords({ start_date: today, end_date: today }),
      ])

      const activeTotal = employees.filter((e: Employee) => e.status === 'active').length
      const pendingCount = employees.filter((e: Employee) => e.status === 'pending').length
      const todayEmployeeIds = new Set(records.map((r: CheckRecord) => r.employee_id))
      const todayAttendance = todayEmployeeIds.size

      setStats({ todayAttendance, activeTotal, pendingCount, todayRecords: records.length })
    } catch (err: any) {
      message.error('加载仪表盘数据失败')
    } finally {
      setLoading(false)
    }
  }

  if (loading) {
    return <div className={styles.loading}><Spin size="large" /></div>
  }

  const cards = [
    { title: '今日出勤', value: stats ? `${stats.todayAttendance}/${stats.activeTotal}` : '-', icon: <CheckCircleOutlined />, color: '#556257' },
    { title: '待审核', value: stats?.pendingCount ?? '-', icon: <UserSwitchOutlined />, color: '#8B6E00' },
    { title: '活跃员工', value: stats?.activeTotal ?? '-', icon: <TeamOutlined />, color: '#556257' },
    { title: '今日打卡', value: stats?.todayRecords ?? '-', icon: <ClockCircleOutlined />, color: '#556257' },
  ]

  return (
    <div>
      <h1 className="page-title" style={{ marginBottom: 32 }}>仪表盘</h1>
      <Row gutter={[24, 24]}>
        {cards.map((card) => (
          <Col xs={24} sm={12} lg={6} key={card.title}>
            <Card className={styles.statCard}>
              <div className={styles.statIcon} style={{ color: card.color }}>{card.icon}</div>
              <div className={styles.statLabel}>{card.title}</div>
              <div className="stat-number">{card.value}</div>
            </Card>
          </Col>
        ))}
      </Row>
    </div>
  )
}
