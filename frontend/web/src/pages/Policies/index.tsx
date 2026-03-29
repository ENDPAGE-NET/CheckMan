import { useEffect, useState } from 'react'
import { Row, Col, Card, Button, Tag, Space, Popconfirm, message, Empty } from 'antd'
import { PlusOutlined, EditOutlined, DeleteOutlined } from '@ant-design/icons'
import { listPolicies, deletePolicy } from '../../api/policies'
import type { Policy } from '../../api/types'
import PolicyModal from './PolicyModal'
import styles from './Policies.module.css'

export default function Policies() {
  const [policies, setPolicies] = useState<Policy[]>([])
  const [loading, setLoading] = useState(true)
  const [editingPolicy, setEditingPolicy] = useState<Policy | null>(null)
  const [modalOpen, setModalOpen] = useState(false)

  const load = async () => {
    setLoading(true)
    try { setPolicies(await listPolicies()) }
    catch (err: any) { message.error(err.message) }
    finally { setLoading(false) }
  }

  useEffect(() => { load() }, [])

  const handleDelete = async (id: number) => {
    try { await deletePolicy(id); message.success('策略已删除'); load() }
    catch (err: any) { message.error(err.message) }
  }

  const openCreate = () => { setEditingPolicy(null); setModalOpen(true) }
  const openEdit = (policy: Policy) => { setEditingPolicy(policy); setModalOpen(true) }
  const handleModalClose = () => { setModalOpen(false); setEditingPolicy(null) }
  const handleModalSaved = () => { handleModalClose(); load() }

  return (
    <div>
      <div className={styles.header}>
        <h1 className="page-title">考勤策略</h1>
        <Button type="primary" icon={<PlusOutlined />} onClick={openCreate}>新建策略</Button>
      </div>
      {!loading && policies.length === 0 && <Empty description="暂无策略" style={{ marginTop: 64 }} />}
      <Row gutter={[24, 24]}>
        {policies.map((policy) => (
          <Col xs={24} sm={12} lg={8} key={policy.id}>
            <Card className={styles.policyCard}>
              <div className={styles.cardHeader}>
                <h3 className={styles.policyName}>{policy.name}</h3>
                <Space>
                  <Button type="text" size="small" icon={<EditOutlined />} onClick={() => openEdit(policy)} />
                  <Popconfirm title="确认删除该策略？" onConfirm={() => handleDelete(policy.id)}>
                    <Button type="text" size="small" icon={<DeleteOutlined />} danger />
                  </Popconfirm>
                </Space>
              </div>
              <div className={styles.tags}>
                <Tag color={policy.require_face ? 'success' : 'default'}>人脸：{policy.require_face ? '必需' : '否'}</Tag>
                <Tag color={policy.require_location ? 'success' : 'default'}>地点：{policy.require_location ? '必需' : '否'}</Tag>
              </div>
              {policy.require_location && policy.location_lat != null && (
                <div className={styles.locationInfo}>
                  ({policy.location_lat}, {policy.location_lng}) &middot; {policy.location_radius}m
                </div>
              )}
            </Card>
          </Col>
        ))}
      </Row>
      <PolicyModal open={modalOpen} policy={editingPolicy} onClose={handleModalClose} onSaved={handleModalSaved} />
    </div>
  )
}
