<div align="center">
  <img src="assets/logo.png" alt="CheckMan Logo" width="120" />
  <h1>CheckMan</h1>
  <p>基于人脸识别的智能考勤管理系统</p>

  ![Python](https://img.shields.io/badge/Python-3.11-blue?logo=python&logoColor=white)
  ![FastAPI](https://img.shields.io/badge/FastAPI-0.115-009688?logo=fastapi&logoColor=white)
  ![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter&logoColor=white)
  ![React](https://img.shields.io/badge/React-19-61DAFB?logo=react&logoColor=black)
  ![Docker](https://img.shields.io/badge/Docker-Compose-2496ED?logo=docker&logoColor=white)
</div>

---

CheckMan 是一套完整的企业考勤解决方案，通过**人脸识别 + GPS 定位**双重验证实现安全打卡，包含员工移动端 App、管理员 Web 后台和后端 API 三个部分。

## Overview

CheckMan 由三个核心模块组成：

- **FastAPI Backend** — 提供 JWT 认证、人脸识别比对、考勤策略引擎，数据存储于 SQLite
- **Flutter App (员工端)** — 人脸录入、拍照打卡、GPS 定位验证、考勤历史查询
- **React Web (管理端)** — 数据仪表盘、员工/管理员管理、考勤策略配置、打卡记录查看
- **Nginx** — 反向代理 API 请求，托管 Web 前端 SPA 静态资源

| 层级 | 技术 |
|------|------|
| **后端** | Python 3.11, FastAPI, SQLAlchemy, face_recognition, JWT |
| **移动端** | Flutter, Riverpod, go_router, Camera, Geolocator |
| **Web 管理端** | React 19, Ant Design, Zustand, Leaflet, Vite |
| **部署** | Docker Compose, Nginx |

## Features

- **人脸识别打卡** — 员工通过摄像头采集人脸照片，后端进行实时比对验证
- **GPS 地理围栏** — 结合定位信息，确保员工在指定范围内打卡
- **考勤策略管理** — 管理员可配置打卡时间、地点、迟到/早退规则
- **管理员仪表盘** — 实时查看打卡统计、员工状态、考勤记录
- **员工自助** — 查看个人打卡历史、修改密码、人脸重新录入
- **多管理员** — 支持超级管理员创建和管理子管理员
- **Docker 一键部署** — 前后端容器化，开箱即用

## Getting Started

### Prerequisites

- [Docker](https://docs.docker.com/get-docker/) & Docker Compose
- (可选) Python 3.11+、Node.js 20+、Flutter 3.x（本地开发时需要）

### Quick Start with Docker

```bash
git clone https://github.com/<your-username>/CheckMan.git
cd CheckMan
docker compose up --build
```

服务启动后：
- **Web 管理后台** → http://localhost
- **API 文档** → http://localhost/api/docs

> [!TIP]
> 首次启动会自动创建默认管理员账号 `admin` / `admin`，请登录后立即修改密码。

### Local Development

<details>
<summary><strong>后端 (FastAPI)</strong></summary>

```bash
cd backend
python -m venv .venv
source .venv/bin/activate   # Windows: .venv\Scripts\activate
pip install -r requirements.txt
uvicorn app.main:app --reload
```

API 运行于 http://localhost:8000，交互式文档位于 `/docs`。

</details>

<details>
<summary><strong>Web 管理端 (React)</strong></summary>

```bash
cd frontend/web
npm install
npm run dev
```

开发服务器运行于 http://localhost:5173。

</details>

<details>
<summary><strong>移动端 App (Flutter)</strong></summary>

```bash
cd frontend/app
flutter pub get
flutter run
```

> [!NOTE]
> 需要在 `lib/core/config/app_config.dart` 中配置后端 API 地址，或通过编译参数传入：
> ```bash
> flutter run --dart-define=API_BASE_URL=http://your-server:8000
> ```

</details>

## Project Structure

```
CheckMan/
├── backend/                # FastAPI 后端
│   ├── app/
│   │   ├── api/            # 路由 (auth, employees, check, policies...)
│   │   ├── core/           # 配置, 数据库, 安全
│   │   ├── models/         # SQLAlchemy 数据模型
│   │   ├── schemas/        # Pydantic 请求/响应模型
│   │   └── services/       # 业务逻辑 (人脸识别, 打卡服务)
│   └── tests/              # pytest 测试套件
├── frontend/
│   ├── app/                # Flutter 员工端 App
│   │   └── lib/
│   │       ├── core/       # 配置, 路由, 主题, 网络
│   │       ├── features/   # 功能模块 (auth, check_in, history, profile)
│   │       └── shared/     # 共享组件, 模型, Provider
│   └── web/                # React 管理端
│       └── src/
│           ├── api/        # API 客户端
│           ├── components/ # 布局, 地图选择器, 路由守卫
│           └── pages/      # Dashboard, Employees, Policies, Records
├── nginx/                  # Nginx 配置 & 多阶段构建
├── design/                 # UI 设计规范 & 交互原型
├── docker-compose.yml
└── .gitignore
```

## Running Tests

```bash
cd backend
source .venv/bin/activate
pytest
```

## Design

CheckMan 采用 **"The Botanical Ledger"** 设计系统 — 将考勤工具的数据精度与高端杂志的有机呼吸感相结合，使用 Sage & Stone 色彩体系和 Plus Jakarta Sans × Manrope 字体配对。

详见 [`design/UI-DESIGN-SPEC.md`](design/UI-DESIGN-SPEC.md) 和交互原型：
- [管理端原型](design/prototype/admin-web.html)
- [员工端原型](design/prototype/employee-app.html)
