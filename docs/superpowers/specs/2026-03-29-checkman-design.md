# CheckMan - 企业内部弹性考勤管理系统设计文档

## 概述

CheckMan 是一个企业内部弹性工时考勤系统，包含 Web 管理端和 Flutter 移动端。员工自助注册后由管理员审核激活，打卡记录签到/签退时间，支持人脸识别和地点校验的灵活配置。

## 技术栈

| 层 | 技术 |
|---|---|
| 后端 | FastAPI + SQLAlchemy + SQLite + face_recognition |
| Web 前端 | React + TypeScript |
| 移动端 | Flutter（iOS + Android） |
| 部署 | Docker Compose（Nginx + FastAPI） |

## 项目结构

```
CheckMan/
├── backend/              # FastAPI 后端
│   ├── app/
│   │   ├── api/          # 路由（认证、员工管理、策略、打卡）
│   │   ├── models/       # SQLAlchemy 数据模型
│   │   ├── services/     # 业务逻辑（人脸比对、打卡校验）
│   │   ├── core/         # 配置、安全、依赖注入
│   │   └── main.py
│   ├── face_data/        # 人脸特征数据存储
│   ├── requirements.txt
│   └── Dockerfile
├── web/                  # React 管理前端
│   ├── src/
│   └── Dockerfile
├── flutter_app/          # Flutter 员工端
├── docker-compose.yml
└── README.md
```

## 数据模型

### Admin（管理员）

| 字段 | 类型 | 说明 |
|------|------|------|
| id | Integer PK | 主键 |
| username | String | 登录用户名 |
| password_hash | String | 密码哈希 |
| must_change_password | Boolean | 是否需改密码（初始管理员为 true） |
| created_at | DateTime | 创建时间 |

### Employee（员工）

| 字段 | 类型 | 说明 |
|------|------|------|
| id | Integer PK | 主键 |
| name | String | 姓名 |
| username | String Unique | 用户名 |
| password_hash | String | 密码哈希 |
| must_change_password | Boolean | 是否需改密码（默认 false，管理员重置密码后为 true） |
| status | Enum | pending（待审核）/ active（已激活）/ rejected（已拒绝） |
| face_registered | Boolean | 是否已录入人脸 |
| policy_id | Integer FK | 关联打卡策略（可为空） |
| override_face | Boolean | 个人覆盖：是否要求人脸（null = 跟随策略） |
| override_location | Boolean | 个人覆盖：是否要求地点（null = 跟随策略） |
| override_lat | Float | 个人覆盖：打卡纬度（null = 跟随策略） |
| override_lng | Float | 个人覆盖：打卡经度（null = 跟随策略） |
| override_radius | Float | 个人覆盖：允许半径/米（null = 跟随策略） |
| created_at | DateTime | 创建时间 |

### CheckPolicy（打卡策略）

| 字段 | 类型 | 说明 |
|------|------|------|
| id | Integer PK | 主键 |
| name | String | 策略名称（如"办公室考勤"） |
| require_face | Boolean | 是否要求人脸 |
| require_location | Boolean | 是否要求地点 |
| location_lat | Float | 打卡纬度 |
| location_lng | Float | 打卡经度 |
| location_radius | Float | 允许半径/米 |
| created_at | DateTime | 创建时间 |

### CheckRecord（打卡记录）

| 字段 | 类型 | 说明 |
|------|------|------|
| id | Integer PK | 主键 |
| employee_id | Integer FK | 关联员工 |
| check_time | DateTime | 打卡时间 |
| check_type | Enum | clock_in（签到）/ clock_out（签退） |
| face_passed | Boolean | 人脸是否通过（策略不要求则为 null） |
| location_lat | Float | 实际打卡纬度（策略不要求则为 null） |
| location_lng | Float | 实际打卡经度（策略不要求则为 null） |
| location_passed | Boolean | 地点是否在范围内（策略不要求则为 null） |
| created_at | DateTime | 记录创建时间 |

### 人脸特征存储

人脸特征数据以文件形式存储在 `face_data/` 目录，命名规则：`{employee_id}.pkl`。不存入数据库，避免 SQLite 存大二进制数据。

## 打卡配置生效逻辑

优先级：员工个人覆盖 > 策略设置 > 默认（不要求）

示例：
- 员工 A 分配了"办公室考勤"策略（要求人脸+地点），但 override_face = false → A 只校验地点
- 员工 B 没分配策略，override_location = true 并设了坐标 → B 只校验地点
- 员工 C 没策略也没个人设置 → 无任何限制，纯记录时间

## API 设计

### 管理员端

| 方法 | 路径 | 说明 |
|------|------|------|
| POST | /api/admin/login | 管理员登录 |
| GET | /api/employees | 员工列表（支持按状态、姓名筛选） |
| POST | /api/employees/{id}/approve | 审核通过 |
| POST | /api/employees/{id}/reject | 审核拒绝 |
| PUT | /api/employees/{id} | 编辑员工信息（含个人打卡覆盖配置） |
| DELETE | /api/employees/{id} | 删除员工 |
| POST | /api/employees/{id}/reset-password | 重置密码 |
| POST | /api/employees/{id}/reset-face | 重置人脸 |
| GET | /api/policies | 策略列表 |
| POST | /api/policies | 创建策略 |
| PUT | /api/policies/{id} | 编辑策略 |
| DELETE | /api/policies/{id} | 删除策略 |
| GET | /api/records | 打卡记录（筛选：员工、日期） |

### 员工端

| 方法 | 路径 | 说明 |
|------|------|------|
| POST | /api/auth/register | 注册（姓名、用户名、密码、人脸照片） |
| POST | /api/auth/login | 登录，返回 token + 完整状态信息 |
| POST | /api/auth/change-password | 修改密码 |
| POST | /api/auth/register-face | 重新录入人脸（被管理员重置后） |
| GET | /api/me | 个人信息 + 打卡要求 + 账户状态 |
| POST | /api/check | 打卡（type + 人脸照片 + GPS） |
| GET | /api/check/today | 今日打卡状态 |
| GET | /api/check/history | 打卡历史（支持日期范围筛选） |

### 认证方式

JWT Token。登录后返回 token，后续请求在 Header 中携带 `Authorization: Bearer <token>`。管理员和员工使用不同的 token 标识角色，后端中间件区分权限。

## 核心业务流程

### 流程 1：员工自助注册

1. Flutter 端注册页：填写姓名、设置用户名和密码
2. 录入人脸（拍照上传，后端提取特征存储）
3. 注册完成，状态为 `pending`（待审核）
4. 等待管理员审核

### 流程 2：管理员审核

1. Web 端看到待审核员工列表
2. 审核通过 → 状态改为 `active`，员工可以开始打卡
3. 审核拒绝 → 状态改为 `rejected`

### 流程 3：被拒绝员工重新注册

被拒绝的员工可以用同一用户名重新调用注册接口，覆盖旧记录重新提交审核。

### 流程 4：员工打卡

1. 员工在 App 点"签到"或"签退"
2. App 获取 GPS 坐标 + 拍摄人脸照片
3. 上传后端，后端根据生效配置（个人覆盖 > 策略 > 默认）校验
4. 返回打卡结果（成功/失败及原因）
5. 记录写入 CheckRecord
6. 只有 `status = active` 的员工可以打卡

### 流程 5：员工登录状态处理

登录接口返回完整状态，Flutter 端据此跳转：
- `pending` → 显示"等待审核"
- `rejected` → 显示"注册被拒绝，可重新提交"
- `active` + `face_registered = false` → 跳转人脸录入页
- `active` + `must_change_password = true` → 跳转改密码页
- `active` + 一切正常 → 进入主页

### 流程 6：管理员重置操作

- **重置密码**：生成新临时密码，`must_change_password = true`，员工下次登录强制改密码
- **重置人脸**：删除人脸特征文件，`face_registered = false`，员工下次登录提示重新录入

## 部署架构

```
docker-compose.yml
├── nginx (端口 80)
│   ├── 托管 React 编译后的静态文件（/）
│   └── 反向代理 API 请求（/api → backend:8000）
├── backend (端口 8000)
│   ├── SQLite 文件挂载到 volume 持久化
│   └── face_data/ 挂载到 volume 持久化
```

### 初始化

后端首次启动时检测 Admin 表为空 → 自动创建默认管理员账户（admin/admin）→ `must_change_password = true` → 日志输出提示修改密码。
