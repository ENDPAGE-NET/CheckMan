# CheckMan Flutter 员工端 App — 设计文档

> 日期：2026-03-29
> 状态：待实施

---

## 1. 概述

为 CheckMan 考勤管理系统创建 Flutter 移动端 App，仅面向员工用户。管理员功能由 Web 管理端承担。

App 的 UI 设计系统直接复用 `flutter_check/flutter_app` 项目的 **Botanical Ledger** 设计（主题、颜色、字体、共享组件），业务逻辑和 API 层全部针对 CheckMan 后端重写。

### 1.1 目标

- 员工可通过 App 完成打卡（签到/签退），支持人脸验证和位置验证
- 支持员工自注册（含人脸拍照）和管理员创建账号的首次激活
- iOS + Android 双平台
- 解决 flutter_check 项目在 iOS 真机上无法安装的问题

### 1.2 非目标

- 不包含管理员功能（仪表盘、员工管理、策略管理等走 Web 端）
- 不支持相册选图打卡（仅前置相机直拍）
- 不支持离线打卡

---

## 2. 后端 API 对接

CheckMan 后端为 FastAPI，所有端点前缀 `/api`。认证方式为 JWT Bearer Token（access_token，24h 有效，无 refresh token）。

### 2.1 端点映射

| 功能 | 方法 | 端点 | 请求格式 | 备注 |
|------|------|------|----------|------|
| 员工登录 | POST | `/api/auth/login` | JSON `{username, password}` | 返回 `{access_token, status, must_change_password, face_registered}` |
| 员工注册 | POST | `/api/auth/register` | multipart `{name, username, password, face_image}` | 注册后状态为 `pending` |
| 修改密码 | POST | `/api/auth/change-password` | JSON `{old_password, new_password}` | 需认证 |
| 补录人脸 | POST | `/api/auth/register-face` | multipart `{face_image}` | 需认证 |
| 个人信息 | GET | `/api/me` | — | 返回含 `require_face`, `require_location`, `location_lat/lng/radius` |
| 打卡 | POST | `/api/check` | multipart `{check_type, face_image?, location_lat?, location_lng?}` | `check_type`: `clock_in` 或 `clock_out` |
| 今日记录 | GET | `/api/check/today` | — | 返回今日所有打卡记录列表 |
| 历史记录 | GET | `/api/check/history` | query `?start_date=&end_date=` | 返回按时间倒序的记录列表 |

### 2.2 认证机制

- 登录成功后保存 `access_token` 到 `flutter_secure_storage`
- Dio 拦截器自动附加 `Authorization: Bearer <token>` 到所有请求
- 收到 401 响应时清除 token 并跳转登录页（无 refresh token 机制）

### 2.3 关键差异（vs flutter_check）

| 项目 | flutter_check | CheckMan |
|------|---------------|----------|
| 人脸图片传输 | base64 编码 JSON 字段 | multipart/form-data UploadFile |
| 认证 | access_token + refresh_token | 仅 access_token（24h） |
| 打卡端点 | `/check-in` + `/check-in/out` 分开 | `/api/check` 统一端点，`check_type` 区分 |
| 用户信息 | `/auth/me` | `/api/me`（含打卡策略要求） |
| 注册 | 不含人脸 | 注册时必须上传人脸图片 |

---

## 3. 屏幕架构

### 3.1 认证 & 入职流程（无 Tab Bar）

| # | 屏幕 | 触发条件 | 说明 |
|---|------|----------|------|
| 1 | **登录** | 未认证 | 用户名 + 密码，底部有「注册」入口 |
| 2 | **注册** | 用户点击注册 | 姓名 + 用户名 + 密码 + 前置相机拍人脸 → 提交后状态 pending |
| 3 | **待审核** | `status == pending` | 全屏状态页，提示等待管理员审核 |
| 4 | **已拒绝** | `status == rejected` | 全屏状态页，提供重新注册入口 |
| 5 | **强制改密码** | `must_change_password == true` | 旧密码 + 新密码 |
| 6 | **人脸录入** | `face_registered == false` | 管理员创建的账号，补录人脸数据 |

### 3.2 状态路由逻辑

登录成功后，根据响应字段自动路由：

```
login response
  ├─ must_change_password == true  →  强制改密码页
  ├─ status == "pending"           →  待审核页
  ├─ status == "rejected"          →  已拒绝页
  ├─ face_registered == false      →  人脸录入页
  └─ status == "active" & ready    →  主页（Tab 1）
```

### 3.3 主应用（3 Tab 底部导航）

| Tab | 图标 | 标签 | 屏幕 | 核心功能 |
|-----|------|------|------|----------|
| 1 | 时钟 | 打卡 | CheckInScreen | 问候语、Hero 时钟卡片、签到/签退按钮、今日状态 |
| 2 | 日历 | 记录 | HistoryScreen | 周选择器、统计卡片、每日签到/签退记录 |
| 3 | 用户 | 个人 | ProfileScreen | 个人信息、本月统计、修改密码、人脸重录、退出 |

底部导航栏使用玻璃拟态风格（GlassBottomNav）。

### 3.4 打卡子流程（全屏覆盖）

```
打卡主页 → 点击签到/签退按钮
  ↓
  GET /api/me → 获取 require_face, require_location
  ↓
  ├─ require_face == true  →  打开前置相机全屏（扫描线动画）
  │                            拍照后自动提交
  ├─ require_location == true  →  后台自动获取 GPS（与相机同时进行）
  └─ 都不需要  →  直接提交打卡
  ↓
  POST /api/check (multipart)
  ↓
  ├─ 成功  →  打卡成功页（时间确认 + 验证结果）→ 自动返回主页
  └─ 失败  →  打卡失败提示（人脸不匹配/位置超范围）→ 可重试
```

### 3.5 辅助页面

| 屏幕 | 入口 | 说明 |
|------|------|------|
| 修改密码 | 个人中心 → 修改密码 | 旧密码 + 新密码（非强制场景） |
| 人脸重录 | 个人中心 → 人脸重录 | 前置相机拍摄，调用 `/api/auth/register-face` |

---

## 4. 技术架构

### 4.1 技术栈

| 类别 | 方案 | 版本/说明 |
|------|------|-----------|
| 框架 | Flutter | 3.41+ |
| 状态管理 | flutter_riverpod | ^2.6 |
| 路由 | go_router | ^14.8，StatefulShellRoute 支持 3 Tab |
| 网络 | dio | ^5.7，拦截器自动附加 token |
| 安全存储 | flutter_secure_storage | ^9.2 |
| 相机 | camera | ^0.11，自定义全屏取景界面 |
| 定位 | geolocator | ^13.0 |
| 字体 | google_fonts | ^6.2，Plus Jakarta Sans + Manrope |
| 数据模型 | freezed + json_serializable | 类型安全不可变模型 |
| 日期格式 | intl | ^0.19 |

### 4.2 项目结构

```
CheckMan/frontend/app/
├── lib/
│   ├── main.dart
│   ├── core/
│   │   ├── config/
│   │   │   └── app_config.dart          # API 地址等配置
│   │   ├── network/
│   │   │   └── api_client.dart          # Dio 单例 + token 拦截器 + 401 处理
│   │   ├── router/
│   │   │   └── app_router.dart          # GoRouter + 状态路由守卫
│   │   └── theme/
│   │       └── app_theme.dart           # Botanical Ledger 主题（从 flutter_check 移植）
│   ├── features/
│   │   ├── auth/
│   │   │   ├── data/
│   │   │   │   └── auth_repository.dart # 登录/注册/改密码/补录人脸 API
│   │   │   ├── providers/
│   │   │   │   └── auth_provider.dart   # AuthNotifier（认证状态 + 路由联动）
│   │   │   └── presentation/
│   │   │       ├── login_screen.dart
│   │   │       ├── register_screen.dart
│   │   │       └── change_password_screen.dart
│   │   ├── onboarding/
│   │   │   └── presentation/
│   │   │       ├── pending_screen.dart
│   │   │       ├── rejected_screen.dart
│   │   │       └── face_enrollment_screen.dart
│   │   ├── check_in/
│   │   │   ├── data/
│   │   │   │   └── check_repository.dart  # 打卡/今日记录 API
│   │   │   ├── providers/
│   │   │   │   └── check_provider.dart    # 打卡状态管理
│   │   │   └── presentation/
│   │   │       ├── check_in_screen.dart   # 打卡主页（Hero 卡片 + 按钮）
│   │   │       ├── camera_screen.dart     # 全屏前置相机（扫描线动画）
│   │   │       └── check_result_screen.dart # 打卡成功/失败
│   │   ├── history/
│   │   │   ├── data/
│   │   │   │   └── history_repository.dart
│   │   │   └── presentation/
│   │   │       └── history_screen.dart    # 历史记录 + 统计
│   │   └── profile/
│   │       ├── data/
│   │       │   └── profile_repository.dart
│   │       └── presentation/
│   │           └── profile_screen.dart    # 个人中心
│   └── shared/
│       ├── models/                        # Freezed 数据模型
│       │   ├── employee.dart
│       │   └── check_record.dart
│       └── widgets/                       # 从 flutter_check 移植的共享组件
│           ├── botanical_card.dart
│           ├── botanical_input.dart
│           ├── botanical_button.dart
│           ├── status_badge.dart
│           ├── stat_card.dart
│           ├── section_header.dart
│           └── glass_bottom_nav.dart
├── ios/
│   ├── Podfile                            # platform :ios, '16.0'
│   └── Runner/
│       └── Info.plist                     # 相机 + 位置权限声明
├── android/
│   └── app/src/main/AndroidManifest.xml   # 相机 + 位置权限
└── pubspec.yaml
```

### 4.3 状态管理设计

```
AuthProvider (StateNotifier)
  ├── status: initial | loading | authenticated | unauthenticated
  ├── user: EmployeeMeResponse?   (来自 /api/me)
  ├── token: String?
  ├── error: String?
  ├── init()      → 检查 secure storage 中是否有 token，有则获取 /api/me
  ├── login()     → POST /api/auth/login → 保存 token → 获取 /api/me
  ├── register()  → POST /api/auth/register (multipart)
  ├── logout()    → 清除 token + 状态
  └── refresh()   → 重新获取 /api/me（改密码/人脸录入后刷新状态）

CheckProvider (StateNotifier)
  ├── todayRecords: List<CheckRecord>
  ├── checkStatus: loading | notCheckedIn | checkedIn
  ├── fetchToday()    → GET /api/check/today
  └── performCheck()  → POST /api/check (multipart)

HistoryProvider (StateNotifier)
  ├── records: List<CheckRecord>
  ├── fetchHistory()  → GET /api/check/history?start_date=&end_date=
  └── 统计计算（工时、出勤天数等在客户端计算）
```

---

## 5. iOS 真机安装问题修复

### 5.1 flutter_check 项目的问题

| 问题 | 原因 | 影响 |
|------|------|------|
| 安装卡住 | `DEVELOPMENT_TEAM = 97T556D4FF` 硬编码，与本机证书团队 ID 不匹配 | provisioning profile 验证失败，安装挂起 |
| Podfile 平台未声明 | `platform :ios, '13.0'` 被注释 | pod 依赖可能编译出不兼容二进制 |
| 部署目标过低 | `IPHONEOS_DEPLOYMENT_TARGET = 13.0` | 部分插件功能在 iOS 13 上不可用 |

### 5.2 新项目的应对措施

| 措施 | 做法 |
|------|------|
| 签名配置 | 不在 `project.pbxproj` 中硬编码 `DEVELOPMENT_TEAM`；使用 Xcode 自动签名；`ios/` 目录下的开发者特定配置加入 `.gitignore` |
| Podfile | 明确声明 `platform :ios, '16.0'` |
| 部署目标 | 所有 build configuration 的 `IPHONEOS_DEPLOYMENT_TARGET` 设为 `16.0` |
| Bundle ID | 使用 `com.checkman.app` |
| Info.plist 权限 | `NSCameraUsageDescription`、`NSLocationWhenInUseUsageDescription` 必须声明 |
| 场景生命周期 | 使用 Flutter 3.41+ 的 `FlutterSceneDelegate` 模式 |

---

## 6. UI 设计系统

直接复用 flutter_check 的 **Botanical Ledger** 设计系统，不做修改。

### 6.1 复用清单

| 来源文件 | 内容 |
|----------|------|
| `core/theme/app_theme.dart` | `AppTheme`（ColorScheme + TextTheme + 组件主题）、`BotanicalColors`、`AppRadius`、`AppSpacing`、`AppShadows` |
| `shared/widgets/botanical_card.dart` | `BotanicalCard`、`GradientHeroCard` |
| `shared/widgets/botanical_input.dart` | `BotanicalInput`（带标签的输入框） |
| `shared/widgets/botanical_button.dart` | 按钮变体 |
| `shared/widgets/status_badge.dart` | 状态标签（成功/警告/错误） |
| `shared/widgets/stat_card.dart` | 统计卡片 |
| `shared/widgets/section_header.dart` | 区域标题 |
| `shared/widgets/glass_bottom_nav.dart` | 玻璃拟态底部导航栏 |

### 6.2 设计规范参考

完整设计规范见 `design/UI-DESIGN-SPEC.md`，包括：
- 色彩系统（Sage & Stone）
- 排版层级（Plus Jakarta Sans + Manrope）
- 间距系统（8px 基础单位）
- 圆角系统（禁止直角）
- 无边线规则（通过背景色偏移创造层次）
- 动效规范（fadeUp、pop、breathe、sweep）

---

## 7. 数据模型

### 7.1 Employee（来自 /api/me）

```dart
class EmployeeMe {
  final int id;
  final String name;
  final String username;
  final String status;       // "pending" | "active" | "rejected"
  final bool faceRegistered;
  final bool mustChangePassword;
  final bool requireFace;
  final bool requireLocation;
  final double? locationLat;
  final double? locationLng;
  final double? locationRadius;
}
```

### 7.2 CheckRecord（来自 /api/check/today 和 /api/check/history）

```dart
class CheckRecord {
  final int id;
  final DateTime checkTime;
  final String checkType;      // "clock_in" | "clock_out"
  final bool? facePassed;
  final double? locationLat;
  final double? locationLng;
  final bool? locationPassed;
}
```

### 7.3 LoginResponse（来自 /api/auth/login）

```dart
class LoginResponse {
  final String accessToken;
  final String tokenType;
  final String status;
  final bool mustChangePassword;
  final bool faceRegistered;
}
```
