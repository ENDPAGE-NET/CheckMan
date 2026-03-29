import { useState } from 'react'
import { Modal, Form, Input, Select, message } from 'antd'
import { createEmployee } from '../../api/employees'
import type { Policy } from '../../api/types'

interface Props {
  open: boolean
  policies: Policy[]
  onClose: () => void
  onCreated: (password: string) => void
}

export default function CreateModal({ open, policies, onClose, onCreated }: Props) {
  const [form] = Form.useForm()
  const [loading, setLoading] = useState(false)

  const handleSubmit = async () => {
    try {
      const values = await form.validateFields()
      setLoading(true)
      await createEmployee(values)
      message.success('员工创建成功')
      onCreated(values.password)
      form.resetFields()
    } catch (err: any) {
      if (err.message) message.error(err.message)
    } finally {
      setLoading(false)
    }
  }

  return (
    <Modal title="添加员工" open={open} onCancel={onClose} onOk={handleSubmit}
      okText="创建" confirmLoading={loading} destroyOnClose>
      <Form form={form} layout="vertical" style={{ marginTop: 16 }}>
        <Form.Item name="name" label="姓名" rules={[{ required: true, message: '请输入姓名' }]}>
          <Input placeholder="员工姓名" />
        </Form.Item>
        <Form.Item name="username" label="用户名" rules={[{ required: true, message: '请输入用户名' }]}>
          <Input placeholder="登录用户名" />
        </Form.Item>
        <Form.Item name="password" label="初始密码"
          rules={[{ required: true, message: '请输入初始密码' }, { min: 6, message: '至少 6 个字符' }]}>
          <Input.Password placeholder="员工首次登录后需修改" />
        </Form.Item>
        <Form.Item name="policy_id" label="考勤策略">
          <Select allowClear placeholder="暂不分配"
            options={policies.map((p) => ({ label: p.name, value: p.id }))} />
        </Form.Item>
      </Form>
    </Modal>
  )
}
