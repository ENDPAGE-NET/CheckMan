import { useEffect } from 'react'
import { Modal, Form, Input, Switch, InputNumber, message } from 'antd'
import { createPolicy, updatePolicy } from '../../api/policies'
import type { Policy } from '../../api/types'
import LocationPickerMap from '../../components/LocationPickerMap'
import { useBreakpoint, isMobile } from '../../hooks/useBreakpoint'

interface Props {
  open: boolean
  policy: Policy | null
  onClose: () => void
  onSaved: () => void
}

export default function PolicyModal({ open, policy, onClose, onSaved }: Props) {
  const [form] = Form.useForm()
  const requireLocation = Form.useWatch('require_location', form)
  const radiusValue = Form.useWatch('location_radius', form) ?? 200
  const isEdit = !!policy
  const bp = useBreakpoint()
  const mobile = isMobile(bp)

  useEffect(() => {
    if (open && policy) {
      form.setFieldsValue({
        name: policy.name, require_face: policy.require_face,
        require_location: policy.require_location, location_lat: policy.location_lat,
        location_lng: policy.location_lng, location_radius: policy.location_radius,
      })
    } else if (open) {
      form.resetFields()
    }
  }, [open, policy, form])

  const handleSubmit = async () => {
    try {
      const values = await form.validateFields()
      if (!values.require_location) {
        values.location_lat = null; values.location_lng = null; values.location_radius = null
      } else if (values.location_lat == null || values.location_lng == null) {
        message.warning('请在地图上选择打卡位置')
        return
      }
      if (isEdit) { await updatePolicy(policy!.id, values); message.success('策略已更新') }
      else { await createPolicy(values); message.success('策略已创建') }
      onSaved()
    } catch (err: unknown) { if (err instanceof Error) message.error(err.message) }
  }

  return (
    <Modal title={isEdit ? '编辑策略' : '新建策略'} open={open} onCancel={onClose}
      onOk={handleSubmit} okText={isEdit ? '保存' : '创建'} destroyOnClose
      width={requireLocation ? (mobile ? 'calc(100vw - 32px)' : 640) : undefined}>
      <Form form={form} layout="vertical" initialValues={{ require_face: false, require_location: false, location_radius: 200 }}>
        <Form.Item name="name" label="策略名称" rules={[{ required: true, message: '请输入策略名称' }]}>
          <Input placeholder="例如：办公室考勤" />
        </Form.Item>
        <Form.Item name="require_face" label="要求人脸验证" valuePropName="checked">
          <Switch />
        </Form.Item>
        <Form.Item name="require_location" label="要求地点验证" valuePropName="checked">
          <Switch />
        </Form.Item>
        {requireLocation && (
          <>
            <Form.Item label="选择位置">
              <LocationPickerMap
                initialPosition={
                  policy?.location_lat != null && policy?.location_lng != null
                    ? { lat: policy.location_lat, lng: policy.location_lng }
                    : null
                }
                radiusMeters={radiusValue}
                onPositionChanged={(lat, lng) => {
                  form.setFieldsValue({ location_lat: lat, location_lng: lng })
                }}
              />
            </Form.Item>
            <Form.Item name="location_radius" label="半径（米）" rules={[{ required: true }]}>
              <InputNumber style={{ width: '100%' }} min={1} />
            </Form.Item>
            <Form.Item name="location_lat" hidden><InputNumber /></Form.Item>
            <Form.Item name="location_lng" hidden><InputNumber /></Form.Item>
          </>
        )}
      </Form>
    </Modal>
  )
}
