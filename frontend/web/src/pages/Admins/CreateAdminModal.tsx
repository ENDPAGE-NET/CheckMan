import { useState } from 'react'
import { Modal, Form, Input, Switch, message } from 'antd'
import { createAdmin } from '../../api/admins'

interface Props {
  open: boolean
  onClose: () => void
  onCreated: () => void
}

export default function CreateAdminModal({ open, onClose, onCreated }: Props) {
  const [form] = Form.useForm()
  const [loading, setLoading] = useState(false)

  const handleSubmit = async () => {
    try {
      const values = await form.validateFields()
      setLoading(true)
      await createAdmin(values)
      message.success('管理员创建成功')
      form.resetFields()
      onCreated()
    } catch (err: any) {
      if (err.message) message.error(err.message)
    } finally {
      setLoading(false)
    }
  }

  return (
    <Modal title="添加管理员" open={open} onCancel={onClose} onOk={handleSubmit}
      okText="创建" confirmLoading={loading} destroyOnClose>
      <Form form={form} layout="vertical" initialValues={{ is_super: false }} style={{ marginTop: 16 }}>
        <Form.Item name="username" label="用户名" rules={[{ required: true, message: '请输入用户名' }]}>
          <Input placeholder="登录用户名" />
        </Form.Item>
        <Form.Item name="password" label="初始密码"
          rules={[{ required: true, message: '请输入初始密码' }, { min: 6, message: '至少 6 个字符' }]}>
          <Input.Password placeholder="管理员首次登录后需修改" />
        </Form.Item>
        <Form.Item name="is_super" label="超级管理员" valuePropName="checked">
          <Switch />
        </Form.Item>
      </Form>
    </Modal>
  )
}
