import { useEffect } from 'react'
import { Modal, Form, Select, Radio, InputNumber, Descriptions, message } from 'antd'
import { updateEmployee } from '../../api/employees'
import type { Employee, EmployeeUpdateRequest, Policy } from '../../api/types'
import LocationPickerMap from '../../components/LocationPickerMap'
import { useBreakpoint, isMobile } from '../../hooks/useBreakpoint'

/** boolean | null → 表单 Radio 值 */
function toRadioValue(v: boolean | null | undefined): 'follow' | 'yes' | 'no' {
  if (v === true) return 'yes'
  if (v === false) return 'no'
  return 'follow'
}

/** 表单 Radio 值 → boolean | null */
function fromRadioValue(v: 'follow' | 'yes' | 'no'): boolean | null {
  if (v === 'yes') return true
  if (v === 'no') return false
  return null
}

interface Props {
  employee: Employee | null
  policies: Policy[]
  onClose: () => void
  onSaved: () => void
}

export default function EditModal({ employee, policies, onClose, onSaved }: Props) {
  const [form] = Form.useForm()
  const overrideLocationRadio = Form.useWatch('override_location_radio', form)
  const radiusValue = Form.useWatch('override_radius', form) ?? 200
  const bp = useBreakpoint()
  const mobile = isMobile(bp)

  useEffect(() => {
    if (employee) {
      form.setFieldsValue({
        policy_id: employee.policy_id,
        override_face_radio: toRadioValue(employee.override_face),
        override_location_radio: toRadioValue(employee.override_location),
        override_lat: employee.override_lat,
        override_lng: employee.override_lng,
        override_radius: employee.override_radius,
      })
    }
  }, [employee, form])

  const handleSubmit = async () => {
    if (!employee) return
    try {
      const values = await form.validateFields()
      const overrideFace = fromRadioValue(values.override_face_radio)
      const overrideLocation = fromRadioValue(values.override_location_radio)

      if (overrideLocation === true && (values.override_lat == null || values.override_lng == null)) {
        message.warning('请在地图上选择打卡位置')
        return
      }

      const payload: EmployeeUpdateRequest = {
        policy_id: values.policy_id,
        override_face: overrideFace,
        override_location: overrideLocation,
      }

      if (overrideLocation === true) {
        payload.override_lat = values.override_lat
        payload.override_lng = values.override_lng
        payload.override_radius = values.override_radius
      } else {
        payload.override_lat = null
        payload.override_lng = null
        payload.override_radius = null
      }

      await updateEmployee(employee.id, payload)
      message.success('员工信息已更新')
      onSaved()
    } catch (err: unknown) {
      if (err instanceof Error) message.error(err.message)
    }
  }

  return (
    <Modal title="编辑员工" open={!!employee} onCancel={onClose} onOk={handleSubmit}
      okText="保存" destroyOnClose
      width={overrideLocationRadio === 'yes' ? (mobile ? 'calc(100vw - 32px)' : 640) : undefined}>
      {employee && (
        <>
          <Descriptions column={1} size="small" style={{ marginBottom: 24 }}>
            <Descriptions.Item label="姓名">{employee.name}</Descriptions.Item>
            <Descriptions.Item label="用户名">{employee.username}</Descriptions.Item>
          </Descriptions>
          <Form form={form} layout="vertical" initialValues={{ override_face_radio: 'follow', override_location_radio: 'follow', override_radius: 200 }}>
            <Form.Item name="policy_id" label="考勤策略">
              <Select allowClear placeholder="未分配策略"
                options={policies.map((p) => ({ label: p.name, value: p.id }))} />
            </Form.Item>
            <Form.Item name="override_face_radio" label="人脸要求">
              <Radio.Group optionType="button" buttonStyle="solid">
                <Radio.Button value="follow">跟随策略</Radio.Button>
                <Radio.Button value="yes">需要</Radio.Button>
                <Radio.Button value="no">不需要</Radio.Button>
              </Radio.Group>
            </Form.Item>
            <Form.Item name="override_location_radio" label="地点要求">
              <Radio.Group optionType="button" buttonStyle="solid">
                <Radio.Button value="follow">跟随策略</Radio.Button>
                <Radio.Button value="yes">需要</Radio.Button>
                <Radio.Button value="no">不需要</Radio.Button>
              </Radio.Group>
            </Form.Item>
            {overrideLocationRadio === 'yes' && (
              <>
                <Form.Item label="选择位置">
                  <LocationPickerMap
                    initialPosition={
                      employee.override_lat != null && employee.override_lng != null
                        ? { lat: employee.override_lat, lng: employee.override_lng }
                        : null
                    }
                    radiusMeters={radiusValue}
                    onPositionChanged={(lat, lng) => {
                      form.setFieldsValue({ override_lat: lat, override_lng: lng })
                    }}
                  />
                </Form.Item>
                <Form.Item name="override_radius" label="半径（米）">
                  <InputNumber style={{ width: '100%' }} min={0} />
                </Form.Item>
                <Form.Item name="override_lat" hidden><InputNumber /></Form.Item>
                <Form.Item name="override_lng" hidden><InputNumber /></Form.Item>
              </>
            )}
          </Form>
        </>
      )}
    </Modal>
  )
}
