# CheckMan UI 设计规范

> 参考来源：Stitch 项目 "User Management (Web)" — 设计系统 "Verdant Logic"
> 创意方向：**The Botanical Ledger（植物学账簿）**

---

## 1. 设计理念

### 1.1 创意北极星：The Botanical Ledger

摆脱传统企业软件的冰冷刻板，采用**编辑式驱动体验**——将考勤工具的数据精度与高端生活杂志的有机呼吸感相结合。

核心原则：
- **有意的不对称与氛围纵深**——不将用户困在网格中，而是通过开阔的留白和高对比度排版比例引导视线
- 界面应感觉像一系列物理卡片，安放在柔软的苔藓表面——简洁、高效、令人平静
- 字体配对（Plus Jakarta Sans × Manrope）创造编辑级节奏层次

### 1.2 双端设计策略

| 端 | 风格定位 | 受众 |
|---|---|---|
| **Web 管理端** | Sage & Stone 光色调，编辑式布局，数据密集但呼吸感充足 | 管理员 |
| **Flutter 员工端** | 同一设计系统的移动适配，3 Tab 极简导航，触控优先 | 全体员工 |

---

## 2. 色彩系统：Sage & Stone

色彩不是装饰，而是**定义建筑结构**的工具。

### 2.1 核心色板

#### 主色（Primary）

| Token | 色值 | 用途 |
|-------|------|------|
| `primary` | `#556257` | 主要操作按钮、活跃状态、品牌标识 |
| `primary-dim` | `#49564B` | 按钮 hover/active 状态，模拟"按入"表面 |
| `primary-container` | `#D7E6D8` | 成功状态、进度条填充、高亮背景 |
| `primary-container-light` | `#E8F0E8` | 渐变辅助、页面氛围光 |
| `on-primary` | `#EEFDEE` | 主色上的文字 |
| `on-primary-container` | `#47554A` | 容器上的文字 |

#### 表面层级（Surface Hierarchy）

**关键规则：** 像对待层叠的精磨纸张一样对待 UI。

| Token | 色值 | 层级 | 说明 |
|-------|------|------|------|
| `surface` | `#F8FAF8` | 基础层 | 页面底色 |
| `surface-container-low` | `#F1F4F2` | 区块层 | 区域划分背景 |
| `surface-container` | `#EAEFEC` | 分区层 | 侧边栏、头部区域 |
| `surface-container-high` | `#E4E9E7` | 强调层 | 活跃标签、下拉菜单 |
| `surface-container-highest` | `#DDE4E1` | 最深层 | 次要按钮背景 |
| `surface-container-lowest` | `#FFFFFF` | 最亮层 | 交互卡片、输入框聚焦态 |

> **层叠原理：** 要创造"抬起"的卡片效果，在 `surface-container-low`（#F1F4F2）背景上放置 `surface-container-lowest`（#FFFFFF）元素。颜色偏移本身即提供清晰、现代的提升感。

#### 文字色

| Token | 色值 | 用途 |
|-------|------|------|
| `on-surface` | `#2D3432` | 主文字（**禁止使用纯黑 #000**） |
| `on-surface-variant` | `#59615F` | 标签、次要文字 |
| `on-surface-muted` | `#8A918E` | 占位符、禁用态 |

#### 语义色

| 语义 | 背景色 | 文字色 | 用途 |
|------|--------|--------|------|
| 成功 | `#D7E6D8` (primary-container) | `#47554A` | 打卡成功、审核通过 |
| 警告 | `#FFEEA0` | `#6A5400` | 待审核、异常提醒 |
| 错误 | `#FFDAD6` | `#93000A` | 审核拒绝、验证失败 |
| 信息 | `#D7E6D8` | `#3A4A3C` | 通用信息提示 |

### 2.2 "无边线"规则

> **强制要求：** 禁止使用 1px solid border 来分割 UI。边界必须**仅通过背景色偏移**来定义。

- 卡片不加边框，通过 `surface-container-lowest`（#FFF）在 `surface`（#F8FAF8）上的色差创造层次
- 表格行之间不使用分割线，使用行间距或交替背景色
- 卡片内部不使用分割线，使用垂直留白（Spacing `6` = 2rem）分隔内容

**Ghost Border 降级方案：** 如果出于无障碍需要必须有边框，使用 `outline-variant`（#ACB3B1）在 **15% 不透明度**。100% 不透明度的边框是设计意图的失败。

```css
/* Ghost Border */
border: 1px solid rgba(172, 179, 177, 0.15);
```

---

## 3. 排版系统：Editorial Authority

### 3.1 字体配对

| 角色 | 字体 | 特征 | 适用场景 |
|------|------|------|----------|
| **Display & Headline** | Plus Jakarta Sans | 宽开口、现代几何感，权威且清新 | 大数据点、区域标题、品牌文字 |
| **Body & Label** | Manrope | 功能性、半紧凑，密集数据仍可读 | 正文、表单标签、元数据 |

### 3.2 排版层级

| 级别 | 字体 | 字号 | 字重 | 字间距 | 用途 |
|------|------|------|------|--------|------|
| `display-lg` | Plus Jakarta Sans | 3.5rem (56px) | 800 | -0.04em | 英雄数字——当前时间、日工时总计 |
| `display-md` | Plus Jakarta Sans | 2.5rem (40px) | 800 | -0.03em | 统计卡片大数字 |
| `headline-lg` | Plus Jakarta Sans | 1.8rem (28.8px) | 800 | -0.02em | 页面主标题、问候语 |
| `headline-sm` | Plus Jakarta Sans | 1.5rem (24px) | 800 | -0.01em | 卡片标题 |
| `title-md` | Plus Jakarta Sans | 1rem (16px) | 700 | 0 | 列表项标题、导航项 |
| `body-md` | Manrope | 0.95rem (15.2px) | 400 | 0 | 正文内容 |
| `body-sm` | Manrope | 0.85rem (13.6px) | 400 | 0 | 次要正文 |
| `label-md` | Manrope | 0.75rem (12px) | 700 | 0 | 表单标签 |
| `label-sm` | Manrope | 0.6875rem (11px) | 700 | 0.04em | 元数据（末次同步、加班时长等） |
| `label-xs` | Manrope | 0.62rem (10px) | 700 | 0.08em | 分区标题（大写） |

> **标签规则：** `label-sm` 及以下始终使用 `on-surface-variant`（#59615F）以保持柔和对比。

---

## 4. 间距系统

基础单位 = **8px**，间距倍数遵循 Stitch spacingScale = 3。

| Token | 值 | 用途 |
|-------|-----|------|
| `space-1` | 4px | 紧凑间距、图标与文字间隙 |
| `space-2` | 8px | 元素内紧凑间距 |
| `space-3` | 12px | 列表项间距、小组件间距 |
| `space-4` | 16px | 卡片内边距（紧凑）、表单字段间距 |
| `space-5` | 20px | 卡片标准内边距 |
| `space-6` | 24px | 区域间距、页面边距（移动端） |
| `space-7` | 28px | 英雄卡片内边距 |
| `space-8` | 32px | 区域间大间距、页面边距（Web） |
| `space-10` | 40px | 大区块分隔 |
| `space-12` | 48px | 页面顶部间距 |
| `space-16` | 64px | 最大间距 |

> **呼吸空间原则：** 如果布局感觉拥挤，增加间距等级（如从 `4` 提升到 `6`）。宁可留白过多，不可留白不足。

---

## 5. 圆角系统

| Token | 值 | 用途 |
|-------|-----|------|
| `radius-sm` | 0.5rem (8px) | 最小圆角——进度条段、提示框、表格行 |
| `radius-md` | 1rem (16px) | 中等——返回按钮、图标容器、输入框 |
| `radius-lg` | 1.5rem (24px) | 大——标准卡片 |
| `radius-xl` | 2rem (32px) | 超大——英雄卡片、对话框 |
| `radius-2xl` | 3rem (48px) | 巨大——主面板卡片 |
| `radius-full` | 9999px | 圆形——按钮、标签、头像、进度条端帽 |

> **强制规则：** 每个元素（包括进度条段和提示框）必须至少有 `radius-sm`（0.5rem）。**禁止直角。**

---

## 6. 深度与阴影：色调分层

传统阴影往往是布局不佳的拐杖。本系统中，深度通过**色调分层**获得。

### 6.1 分层优先

通过表面色差创造深度，而非阴影：

```
surface (#F8FAF8)
  └─ surface-container-low (#F1F4F2)  ← 区域分隔
       └─ surface-container-lowest (#FFFFFF)  ← 交互卡片（最亮 = 最近）
```

### 6.2 氛围阴影（仅用于物理浮动元素）

阴影**仅限**用于确实"悬浮"的元素（模态框、浮动操作按钮、下拉菜单）：

```css
/* 标准氛围阴影 */
box-shadow: 0 8px 32px rgba(45, 52, 50, 0.06);

/* 强调浮动阴影（模态框） */
box-shadow: 0 16px 48px rgba(45, 52, 50, 0.12);
```

- 模糊半径 ≥ 32px，不透明度 ≤ 6%
- 使用 `on-surface`（#2D3432）着色而非纯黑——模拟森林冠层下的自然光

### 6.3 玻璃拟态（Glassmorphism）

用于浮动操作按钮、导航覆盖层、Tab Bar：

```css
background: rgba(248, 250, 248, 0.88);
backdrop-filter: blur(20px);
-webkit-backdrop-filter: blur(20px);
```

---

## 7. 图标系统

### 7.1 规范

| 属性 | 值 |
|------|-----|
| 风格 | 线性图标（Line icons） |
| 默认尺寸 | 22 x 22px |
| 描边宽度 | 1.5px |
| 线帽 | round（圆形） |
| 线接 | round（圆形） |
| viewBox | `0 0 24 24` |
| 填充 | `none`（纯描边，无填充） |

### 7.2 尺寸变体

| 类 | 尺寸 | 用途 |
|-----|------|------|
| `ico-sm` | 18px | 按钮内图标、标签图标 |
| `ico` | 22px | 标准图标（导航、列表项） |
| `ico-lg` | 28px | 品牌图标、强调图标 |

### 7.3 颜色规则

- 默认：`currentColor`（继承父元素文字色）
- 非活跃 Tab / 次要：`on-surface-muted`（#8A918E）
- 活跃 Tab：`primary`（#556257）
- 白底操作：`on-surface-variant`（#59615F）

> **禁止使用 Emoji 作为图标。** 全部采用 SVG 线性图标，保持一致的视觉语言。

---

## 8. 组件规范

### 8.1 按钮

#### Primary Button（主按钮）

```
背景: linear-gradient(135deg, #556257, #49564B)
文字色: #EEFDEE (on-primary)
圆角: radius-full (9999px)
内边距: 18px 28px
字体: Plus Jakarta Sans, 0.95rem, weight 700
阴影: 0 4px 20px rgba(85, 98, 87, 0.12)
```

- Hover：背景色过渡到 `primary-dim`（#49564B），模拟"按入"表面
- Active：`transform: scale(0.98)`
- 禁用：opacity 0.5，cursor not-allowed

#### Secondary Button（次要按钮）

```
背景: surface-container-highest (#DDE4E1)
文字色: on-surface (#2D3432)
圆角: radius-full
无边框、无阴影
```

#### Ghost Button（透明按钮）

```
背景: transparent
文字色: on-surface-variant
边框: 1px solid rgba(172, 179, 177, 0.15)  ← Ghost Border
```

### 8.2 卡片

#### 标准卡片

```
背景: surface-container-lowest (#FFFFFF)
圆角: radius-xl (2rem)
内边距: 20px
无边框（通过色差与底层区分）
```

#### 英雄卡片（Hero Card）

```
背景: primary (#556257)
圆角: radius-2xl (3rem)
内边距: 28px
文字色: on-primary (#EEFDEE)
装饰: 右上角径向渐变光晕（primary-container, 12% opacity）
```

#### 统计卡片

```
背景: surface-container-lowest (#FFFFFF)
圆角: radius-xl
内边距: 16px
标签: label-xs, on-surface-muted, uppercase
数字: display-md 或 headline-sm, on-surface, Plus Jakarta Sans weight 800
```

> **卡片内禁止使用分割线。** 使用垂直留白（Spacing `6` = 2rem）分隔信息块。

### 8.3 输入框

```
背景: surface-container-low (#F1F4F2)
圆角: radius-lg (1.5rem)
内边距: 16px 20px
字体: Manrope, 0.95rem
占位符色: on-surface-muted (#8A918E)
边框: 2px solid transparent

/* Focus 态 */
背景: surface-container-lowest (#FFFFFF)
边框: 2px solid rgba(85, 98, 87, 0.08)  ← Ghost Border
阴影: 0 0 0 4px rgba(85, 98, 87, 0.06)
```

### 8.4 标签（Chip）

```css
/* 通用 */
display: inline-flex;
padding: 5px 12px;
border-radius: radius-full;
font: label-sm (0.72rem, weight 700);

/* 成功 */  背景: #D7E6D8   文字: #47554A
/* 警告 */  背景: #FFEEA0   文字: #6A5400
/* 错误 */  背景: #FFDAD6   文字: #93000A
```

带状态指示点：
```css
.chip-dot {
  width: 6px; height: 6px;
  border-radius: 50%;
  background: currentColor;
}
/* 闪烁动画用于"进行中"状态 */
animation: blink 1.8s ease-in-out infinite;
```

### 8.5 数据表格（Web 端）

```
行背景: 交替使用 surface / surface-container-low
行高: 56px
字体: Manrope, body-sm
无横向分割线
hover: surface-container-high
圆角: 整体表格 radius-lg, 首尾行适配
```

### 8.6 进度条

```
轨道: surface-container-high (#E4E9E7)
填充: primary (#556257)
圆角: radius-full（两端）
高度: 5px（标准）/ 8px（强调）
```

- 图表使用 `primary`、`secondary`、`tertiary` 区分数据类别
- 柱状图必须有圆帽（radius-full）

---

## 9. 动效规范

### 9.1 缓动函数

| 名称 | 值 | 用途 |
|------|-----|------|
| `ease-out-expo` | `cubic-bezier(0.16, 1, 0.3, 1)` | 页面切换、元素进入 |
| `ease-spring` | `cubic-bezier(0.34, 1.56, 0.64, 1)` | 弹性反馈（成功打勾、按钮点击） |
| `ease-standard` | `ease` | 通用过渡 |

### 9.2 核心动画

#### 渐入上移（fadeUp）——卡片、列表项入场

```css
@keyframes fadeUp {
  from { opacity: 0; transform: translateY(16px); }
  to   { opacity: 1; transform: translateY(0); }
}
/* 交错延迟：每项 +40ms */
.au > *:nth-child(1) { animation-delay: 0.04s; }
.au > *:nth-child(2) { animation-delay: 0.08s; }
/* ... */
```

#### 弹入（pop）——成功状态图标

```css
@keyframes pop {
  0%   { transform: scale(0) rotate(-8deg); }
  60%  { transform: scale(1.12) rotate(2deg); }
  100% { transform: scale(1) rotate(0); }
}
```

#### 呼吸（breathe）——等待状态装饰环

```css
@keyframes breathe {
  0%, 100% { transform: scale(1); opacity: 0.3; }
  50%      { transform: scale(1.06); opacity: 0.6; }
}
```

#### 扫描线（sweep）——人脸识别扫描

```css
@keyframes sweep {
  0%   { top: 22%; opacity: 0; }
  15%  { opacity: 1; }
  85%  { opacity: 1; }
  100% { top: 76%; opacity: 0; }
}
```

### 9.3 过渡时长

| 场景 | 时长 |
|------|------|
| 颜色/背景过渡 | 150ms |
| 元素尺寸/位置 | 250ms |
| 页面切换 | 400ms |
| 复杂入场动画 | 450ms |

---

## 10. 移动端（Flutter）屏幕规范

### 10.1 导航结构

**3 Tab 底部导航栏**（玻璃拟态风格）：

| 位置 | 图标 | 标签 | 对应页面 |
|------|------|------|----------|
| 左 | 时钟 | 打卡 | 打卡主页（Home） |
| 中 | 日历 | 记录 | 打卡历史（History） |
| 右 | 用户 | 个人 | 个人中心（Profile） |

Tab Bar 样式：
```
高度: 84px
背景: rgba(248, 250, 248, 0.88) + backdrop-blur(20px)
活跃态: primary-container 背景胶囊 + primary 色图标/文字
非活跃: on-surface-muted 色图标/文字
```

> **人脸录入** 功能收纳在"个人 > 系统设置"内，不单独占用 Tab。

### 10.2 屏幕清单

| # | 屏幕 | 场景 | 导航方式 |
|---|------|------|----------|
| 1 | **登录** | 所有用户入口 | 独立页（无 Tab Bar） |
| 2 | **注册** | 新用户（含人脸拍摄、基本信息） | push 进入，返回登录 |
| 3 | **待审核** | 注册后等待管理员审核 | 全屏状态页 |
| 4 | **已拒绝** | 注册被拒，提供重新注册入口 | 全屏状态页 |
| 5 | **打卡主页** | 当日时间、打卡按钮、今日状态 | Tab 1（打卡） |
| 6 | **打卡拍摄** | 人脸识别 + GPS 定位确认 | push 全屏覆盖 |
| 7 | **打卡成功** | 成功反馈 + 时间确认 | push，自动/手动返回 |
| 8 | **打卡历史** | 周选择器 + 统计卡片 + 每日记录列表 | Tab 2（记录） |
| 9 | **个人中心** | 头像、统计、个人信息、系统设置（含人脸重录）、退出 | Tab 3（个人） |
| 10 | **修改密码** | 旧密码 + 新密码 + 强度指示 | push 进入，返回个人 |

### 10.3 关键屏幕布局

#### 登录页

```
布局: 垂直居中
背景: surface + 底部 primary-container 椭圆渐变氛围光
  radial-gradient(ellipse 65% 45% at 50% 100%, primary-container-light, transparent 70%)

组成:
  1. 品牌图标（primary-container 背景方块 + checkmark SVG）
  2. 标题 "CheckMan" (headline-lg, weight 800)
  3. 副标题 (body-sm, on-surface-variant)
  4. 表单：工号 + 密码输入框
  5. 主按钮 "登录"
  6. 底部链接 "没有账号？立即注册"
```

#### 打卡主页

```
布局: 垂直滚动
顶部: 品牌 Logo + 头像（点击进入个人）
问候: 日期(label-sm) + "下午好，张三"(headline-lg)

Hero 卡片（card-hero）:
  - 右上角状态标签（已签到/未签到）
  - 标签 "今日进度"
  - 巨型时间 display-lg（4rem, weight 800, 白色）
  - 底部：签到/签退按钮（surface-lowest 背景，on-surface 文字）

今日状态卡片:
  - 上班打卡时间 + 下班打卡时间
  - 验证通过标签（face / location chip）
```

#### 打卡历史

```
顶部统计: primary-container 背景卡片
  - 本周工时大数字 (display-lg)
  - 进度条（已工作/目标）

双列统计: 平均签到 + 出勤天数
周选择器: 7天横向按钮，当日 primary 背景
每日记录列表: 卡片式，显示签到/签退时间
```

#### 个人中心

```
头部: 头像（渐变圆形）+ 姓名 + 角色
统计药丸: 本月出勤 / 平均工时 / 准时率

个人信息区（surface-lowest 卡片）:
  - 工号 / 部门 / 入职日期 / 联系方式

系统设置区:
  - 修改密码（push 到修改密码页）
  - 人脸重录（push 到人脸拍摄页）
  - 通知设置
  - 关于

退出登录按钮（透明背景，error 文字色）
```

---

## 11. Web 管理端屏幕规范

### 11.1 布局结构

```
┌─────────────────────────────────────────┐
│  固定侧边栏 (260px)  │     主内容区      │
│                       │                   │
│  品牌 Logo            │  顶部区域:        │
│  导航菜单:            │    标题 + 操作    │
│    - 仪表盘           │                   │
│    - 员工管理         │  内容区:          │
│    - 考勤策略         │    卡片/表格/...  │
│    - 打卡记录         │                   │
│                       │                   │
│  底部: 管理员信息     │                   │
└─────────────────────────────────────────┘
```

侧边栏样式：
```
宽度: 260px
背景: surface-container-low
导航项: 全宽圆角按钮，活跃态 primary-container 背景
图标: SVG 线性图标，与文字配对
底部: 管理员头像 + 用户名 + 退出
```

### 11.2 屏幕清单

| # | 屏幕 | 功能描述 |
|---|------|----------|
| 1 | **登录** | 独立全屏，居中卡片布局 |
| 2 | **仪表盘** | 统计概览——今日出勤率、待审核数、活跃员工数、近期动态 |
| 3 | **员工管理** | 员工列表表格 + 状态筛选（全部/待审核/已激活/已拒绝）+ 操作（审核/编辑/重置密码/重置人脸/删除） |
| 4 | **考勤策略** | 策略卡片列表 + 创建/编辑策略表单（策略名、是否要求人脸、是否要求地点、坐标、半径） |
| 5 | **打卡记录** | 记录表格 + 筛选条件（员工、日期范围）+ 导出 |

### 11.3 关键屏幕布局

#### 仪表盘

```
参考 Stitch 屏幕: "管理仪表盘 (中文版)"

顶部统计卡片行（4列）:
  - 今日出勤率
  - 待审核员工
  - 活跃员工总数
  - 本月异常

近期动态列表 + 快速操作入口
图表区域: 本周出勤趋势
```

#### 员工管理

```
参考 Stitch 屏幕: "用户管理 (中文版)" / "User Management (Web)"

顶部: 页面标题 + 搜索框 + 筛选 Chip（按状态）
表格:
  列: 姓名 / 工号 / 状态(Chip) / 策略 / 人脸状态 / 注册时间 / 操作
  行高: 56px
  hover: surface-container-high
  操作: 图标按钮组（审核通过/拒绝/编辑/重置/删除）

员工编辑模态框:
  - 基本信息（只读：姓名、工号）
  - 策略分配（下拉选择）
  - 个人打卡覆盖配置（开关 + 条件输入）
```

#### 考勤策略

```
参考 Stitch 屏幕: "考勤规则 (中文版)" / "Clock-in Rules (Web)"

卡片式列表:
  每张卡片:
    - 策略名称 (headline-sm)
    - 配置概览: 人脸要求(开关) + 地点要求(开关)
    - 地点信息: 坐标 + 半径
    - 操作: 编辑 / 删除

创建/编辑模态框:
  - 策略名称输入
  - 人脸验证开关
  - 地点验证开关
  - 条件显示: 纬度 / 经度 / 半径（仅开启地点时显示）
```

---

## 12. 签名渐变与氛围效果

### 12.1 主操作渐变

打卡按钮等核心触控点使用签名渐变，赋予"触觉灵魂"：

```css
background: linear-gradient(135deg, #556257, #49564B);
```

### 12.2 页面氛围光

状态页面使用径向渐变创造情绪氛围：

```css
/* 待审核 */
background: radial-gradient(
  ellipse 80% 45% at 50% 75%,
  rgba(255, 238, 160, 0.18),
  transparent
), #F8FAF8;

/* 已拒绝 */
background: radial-gradient(
  ellipse 80% 45% at 50% 75%,
  rgba(255, 218, 214, 0.2),
  transparent
), #F8FAF8;

/* 成功 */
background: radial-gradient(
  ellipse 65% 40% at 50% 65%,
  #E8F0E8,
  transparent
), #F8FAF8;

/* 登录页 */
background: radial-gradient(
  ellipse 65% 45% at 50% 100%,
  #E8F0E8,
  transparent 70%
), #F8FAF8;
```

---

## 13. Do's and Don'ts

### Do

- **Do** 使用 `radius-lg`（2rem）和 `radius-xl`（3rem）圆角保持"柔软极简"感
- **Do** 贯彻"呼吸空间"——布局拥挤时增加间距等级
- **Do** 使用 `primary-container`（#D7E6D8）表示"成功/积极"状态，而非通用亮绿色
- **Do** 所有图标使用 SVG 线性风格（1.5px 描边、round 线帽）
- **Do** 通过交错 `animation-delay` 创造精心编排的入场动画
- **Do** 表面层级嵌套创造自然深度

### Don't

- **Don't** 使用纯黑（#000000）作为文字色——始终用 `on-surface`（#2D3432）
- **Don't** 使用 1px 分割线——通过背景色偏移或 1rem 间距分隔
- **Don't** 使用标准 Material 阴影——使用氛围阴影规范（高模糊、低不透明度）
- **Don't** 使用直角——所有元素至少 `radius-sm`（0.5rem）
- **Don't** 使用 Emoji 作为图标
- **Don't** 使用 Inter、Roboto、Arial 等通用字体
- **Don't** 使用紫色渐变白底等 AI 生成风格的配色

---

## 14. 完整色彩 Token 参考表

以下为 Stitch "Verdant Logic" 设计系统导出的完整色彩 Token：

| Token | 色值 |
|-------|------|
| `background` | `#F8FAF8` |
| `surface` | `#F8FAF8` |
| `surface-bright` | `#F8FAF8` |
| `surface-dim` | `#D4DCD9` |
| `surface-variant` | `#DDE4E1` |
| `surface-tint` | `#556257` |
| `surface-container-lowest` | `#FFFFFF` |
| `surface-container-low` | `#F1F4F2` |
| `surface-container` | `#EAEFEC` |
| `surface-container-high` | `#E4E9E7` |
| `surface-container-highest` | `#DDE4E1` |
| `primary` | `#556257` |
| `primary-dim` | `#49564B` |
| `primary-container` | `#D7E6D8` |
| `primary-fixed` | `#D7E6D8` |
| `primary-fixed-dim` | `#C9D8CA` |
| `on-primary` | `#EEFDEE` |
| `on-primary-container` | `#47554A` |
| `on-primary-fixed` | `#354238` |
| `on-primary-fixed-variant` | `#515F54` |
| `secondary` | `#4B664B` |
| `secondary-dim` | `#3F593F` |
| `secondary-container` | `#CCEBC8` |
| `secondary-fixed` | `#CCEBC8` |
| `secondary-fixed-dim` | `#BEDDBB` |
| `on-secondary` | `#E9FFE5` |
| `on-secondary-container` | `#3E583E` |
| `tertiary` | `#526352` |
| `tertiary-dim` | `#465747` |
| `tertiary-container` | `#EBFFE8` |
| `tertiary-fixed` | `#EBFFE8` |
| `tertiary-fixed-dim` | `#DDF0DA` |
| `on-tertiary` | `#EBFEE8` |
| `on-tertiary-container` | `#526352` |
| `error` | `#A73B21` |
| `error-dim` | `#791903` |
| `error-container` | `#FD795A` |
| `on-error` | `#FFF7F6` |
| `on-error-container` | `#6E1400` |
| `on-surface` | `#2D3432` |
| `on-surface-variant` | `#59615F` |
| `on-background` | `#2D3432` |
| `outline` | `#757C7A` |
| `outline-variant` | `#ACB3B1` |
| `inverse-surface` | `#0B0F0E` |
| `inverse-on-surface` | `#9B9D9C` |
| `inverse-primary` | `#EBFBEC` |

---

## 15. 原型文件索引

| 文件 | 说明 |
|------|------|
| `design/prototype/admin-web.html` | Web 管理端交互原型 |
| `design/prototype/employee-app.html` | Flutter 员工端交互原型 |

### Stitch 参考屏幕

| 屏幕 | 类型 | Stitch ID |
|------|------|-----------|
| User Management (Web) | Desktop | `6f6c43cc` |
| 管理仪表盘 (中文版) | Desktop | `993e4cba` |
| 用户管理 (中文版) | Desktop | `cd6324c4` |
| 考勤规则 (中文版) | Desktop | `3e77e2aa` |
| Clock-in Rules (Web) | Desktop | `fde302c3` |
| Admin Dashboard (Web) | Desktop | `7c09ee0e` |
| Main Dashboard (Mobile) | Mobile | `d2cdf3ad` |
| APP 主面板 (中文版) | Mobile | `288c5f53` |
| 个人中心 (中文版) | Mobile | `974c42e2` |
| 打卡记录 (中文版) | Mobile | `b3b32d9f` |
| Face Enrollment (Mobile) | Mobile | `a5d1b52d` |
| 人脸录入 (中文版) | Mobile | `bd024058` |
| Account Activation (Mobile) | Mobile | `c8d1a5f1` |
| 账户激活 (中文版) | Mobile | `dad74c64` |
