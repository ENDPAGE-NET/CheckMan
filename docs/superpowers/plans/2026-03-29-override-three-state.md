# 考勤覆盖三态修复 实现计划

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 将员工编辑弹窗中的覆盖 Switch 改为三态 Radio（跟随策略/需要/不需要），修复策略不生效 bug。

**Architecture:** 纯前端改动——将 `EditModal.tsx` 中的两个 `Switch` 替换为 `Radio.Group`，在表单初始化时将 `boolean | null` 映射为 `"follow" | "yes" | "no"`，提交时反向映射回去。后端逻辑不变。附带一个数据修复 SQL 清理历史脏数据。

**Tech Stack:** React 19, Ant Design 6, TypeScript, SQLite

---

## 文件映射

| 文件 | 操作 | 职责 |
|------|------|------|
| `frontend/web/src/pages/Employees/EditModal.tsx` | 修改 | Switch → Radio.Group，值映射转换 |
| `backend/checkman.db` | 数据修复 | 清理历史 override 脏数据 |

不改的文件：
- `backend/app/services/check_service.py` — `resolve_requirements` 逻辑正确
- `backend/app/schemas/employee.py` — 已支持 `null` 值
- `backend/app/api/employees.py` — `exclude_unset=True` 行为正确
- `frontend/web/src/api/types.ts` — 类型定义已支持 `boolean | null`
- `frontend/web/src/pages/Employees/CreateModal.tsx` — 新建不设 override，默认 NULL

---

### Task 1: 将 EditModal 中的 Switch 替换为 Radio.Group

**Files:**
- Modify: `frontend/web/src/pages/Employees/EditModal.tsx`

- [ ] **Step 1: 定义值映射辅助函数**

在 `EditModal.tsx` 文件顶部（`interface Props` 之前）添加两个辅助函数，负责 `boolean | null` 和 `"follow" | "yes" | "no"` 之间的双向转换：

```tsx
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
```

- [ ] **Step 2: 修改 import 语句**

将 `Switch` 从 antd 导入中移除，加入 `Radio`：

```tsx
import { Modal, Form, Select, Radio, InputNumber, Descriptions, message } from 'antd'
```

（删掉 `Switch`，加上 `Radio`）

- [ ] **Step 3: 修改 Form.useWatch**

当前代码（第 17 行）：

```tsx
const overrideLocation = Form.useWatch('override_location', form)
```

改为：

```tsx
const overrideLocationRadio = Form.useWatch('override_location_radio', form)
```

因为表单字段名改为 `override_face_radio` 和 `override_location_radio`，避免和提交时的实际字段名冲突。

- [ ] **Step 4: 修改 useEffect 表单初始化**

当前代码（第 22-33 行）：

```tsx
useEffect(() => {
  if (employee) {
    form.setFieldsValue({
      policy_id: employee.policy_id,
      override_face: employee.override_face,
      override_location: employee.override_location,
      override_lat: employee.override_lat,
      override_lng: employee.override_lng,
      override_radius: employee.override_radius,
    })
  }
}, [employee, form])
```

替换为：

```tsx
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
```

- [ ] **Step 5: 修改 handleSubmit 提交转换**

当前代码（第 35-49 行）：

```tsx
const handleSubmit = async () => {
  if (!employee) return
  try {
    const values = await form.validateFields()
    if (values.override_location && (values.override_lat == null || values.override_lng == null)) {
      message.warning('请在地图上选择打卡位置')
      return
    }
    await updateEmployee(employee.id, values)
    message.success('员工信息已更新')
    onSaved()
  } catch (err: unknown) {
    if (err instanceof Error) message.error(err.message)
  }
}
```

替换为：

```tsx
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

    const payload: Record<string, unknown> = {
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
```

- [ ] **Step 6: 替换 JSX 中的 Switch 为 Radio.Group**

当前的两个 Switch Form.Item（第 66-71 行）：

```tsx
<Form.Item name="override_face" label="覆盖人脸要求" valuePropName="checked">
  <Switch />
</Form.Item>
<Form.Item name="override_location" label="覆盖地点要求" valuePropName="checked">
  <Switch />
</Form.Item>
```

替换为：

```tsx
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
```

- [ ] **Step 7: 修改地图展开条件**

当前代码（第 72 行）：

```tsx
{overrideLocation && (
```

替换为：

```tsx
{overrideLocationRadio === 'yes' && (
```

- [ ] **Step 8: 修改 Modal 宽度条件**

当前代码（第 54 行）：

```tsx
width={overrideLocation ? (mobile ? 'calc(100vw - 32px)' : 640) : undefined}
```

替换为：

```tsx
width={overrideLocationRadio === 'yes' ? (mobile ? 'calc(100vw - 32px)' : 640) : undefined}
```

- [ ] **Step 9: 修改 initialValues**

当前代码（第 61 行）：

```tsx
<Form form={form} layout="vertical" initialValues={{ override_radius: 200 }}>
```

替换为：

```tsx
<Form form={form} layout="vertical" initialValues={{ override_face_radio: 'follow', override_location_radio: 'follow', override_radius: 200 }}>
```

- [ ] **Step 10: 验证编译通过**

Run: `cd frontend/web && npx tsc --noEmit`
Expected: 无类型错误

- [ ] **Step 11: 提交**

```bash
git add frontend/web/src/pages/Employees/EditModal.tsx
git commit -m "fix: 将覆盖控件从 Switch 改为三态 Radio，修复策略不生效 bug"
```

---

### Task 2: 清理历史脏数据

**Files:**
- Modify: `backend/checkman.db`（数据修复）

- [ ] **Step 1: 先查看当前脏数据**

```bash
cd backend && sqlite3 checkman.db "SELECT id, name, override_face, override_location FROM employees WHERE override_face IS NOT NULL OR override_location IS NOT NULL;"
```

Expected: 列出所有有 override 值的员工，确认哪些是脏数据

- [ ] **Step 2: 执行清理**

```bash
cd backend && sqlite3 checkman.db "UPDATE employees SET override_face = NULL, override_location = NULL, override_lat = NULL, override_lng = NULL, override_radius = NULL WHERE override_face = 0 AND override_location = 0;"
```

Expected: 受影响的行数 > 0（取决于实际数据量，也可能为 0 如果没有脏数据）

- [ ] **Step 3: 验证清理结果**

```bash
cd backend && sqlite3 checkman.db "SELECT id, name, override_face, override_location FROM employees WHERE override_face IS NOT NULL OR override_location IS NOT NULL;"
```

Expected: 只剩下管理员有意设置了覆盖的员工（可能为空）

- [ ] **Step 4: 提交（如果数据库在版本控制中）**

如果 `checkman.db` 在 `.gitignore` 中（大概率），则跳过此步。数据修复不进入版本控制。
