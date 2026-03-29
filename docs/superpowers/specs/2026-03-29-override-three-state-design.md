# 考勤覆盖三态修复 设计文档

## 问题

员工编辑弹窗中"覆盖人脸要求"和"覆盖地点要求"使用 Ant Design `Switch` 组件，只有 `true`/`false` 两态。当 Switch 关闭时，前端发送 `false` 而非 `null`，导致后端 `resolve_requirements` 中 `if override_face is not None` 始终成立，策略配置被 `false` 覆盖，永远不生效。

## 目标

将覆盖控件从二态 Switch 改为三态 Radio，让管理员能明确选择「跟随策略 / 需要 / 不需要」，修复策略不生效的 bug。

## 涉及文件

| 文件 | 操作 |
|------|------|
| `frontend/web/src/pages/Employees/EditModal.tsx` | 修改 |
| `backend/app/api/employees.py` | 不改 |
| `backend/app/services/check_service.py` | 不改 |
| `backend/app/schemas/employee.py` | 微调（见下文） |

## 前端改动

### EditModal.tsx

**替换控件**：将两个 `Switch`（`override_face` 和 `override_location`）替换为 `Radio.Group`。

每组三个选项：

```
○ 跟随策略    ○ 需要    ○ 不需要
```

**值映射**：

| 选项 | 表单值 | 发送到后端的值 |
|------|--------|----------------|
| 跟随策略 | `"follow"` | `null` |
| 需要 | `"yes"` | `true` |
| 不需要 | `"no"` | `false` |

**提交前转换**：在 `handleSubmit` 中，将表单值 `"follow"` 转换为 `null`，`"yes"` 转换为 `true`，`"no"` 转换为 `false`，然后再发送请求。

**表单初始化**：在 `useEffect` 中加载员工数据时，根据后端返回的值做反向映射：

- `null/undefined` → `"follow"`
- `true` → `"yes"`
- `false` → `"no"`

**地点覆盖展开条件**：当 `override_location` 的 Radio 值为 `"yes"` 时，展示 `LocationPickerMap` 和半径输入框。当切换为 `"follow"` 或 `"no"` 时，隐藏地图并清空 `override_lat`、`override_lng`、`override_radius`。

**默认值**：所有 Radio 默认选中「跟随策略」。

### 样式

Radio.Group 使用 `optionType="button"` + `buttonStyle="solid"` 呈现为按钮组，视觉更紧凑。

## 后端改动

### employee.py (Schema)

`EmployeeUpdateRequest` 无需改动。当前定义已支持 `null` 值：

```python
override_face: bool | None = None
override_location: bool | None = None
```

`model_dump(exclude_unset=True)` 的行为：当前端显式传 `"override_face": null` 时，Pydantic 会将其标记为"已设置"，所以 `exclude_unset=True` 会包含这个字段，后端会将数据库中的值更新为 `NULL`。这是正确的行为。

## 数据修复

对已有的错误数据执行一次性 SQL 清理：

```sql
UPDATE employees
SET override_face = NULL,
    override_location = NULL,
    override_lat = NULL,
    override_lng = NULL,
    override_radius = NULL
WHERE override_face = false
  AND override_location = false;
```

此 SQL 只清理「两个覆盖都是 false」的员工，即从未被管理员有意配置过覆盖的员工。如果某个员工只有一个字段是 `false` 而另一个是 `true`，说明管理员可能有意为之，不做清理。

## 不改的部分

- `resolve_requirements`：逻辑正确，`if override is not None` 的判断本身没问题，问题出在前端发了 `false` 而非 `null`。
- `CreateModal.tsx`：新建员工时不设置 override 字段，默认就是 `NULL`（跟随策略），无需修改。
- 后端 API 路由：不新增、不修改路由。
