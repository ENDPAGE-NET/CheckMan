# CheckMan 后端实施计划

> **自动化执行说明：** 使用 superpowers:subagent-driven-development（推荐）或 superpowers:executing-plans 逐任务执行此计划。步骤使用 checkbox（`- [ ]`）语法追踪进度。

**目标：** 构建 CheckMan 的完整 FastAPI 后端 —— 一个支持人脸识别和灵活打卡策略的企业考勤系统。

**架构：** FastAPI + SQLAlchemy ORM + SQLite。JWT 认证，管理员和员工使用不同角色的 token。人脸识别使用 `face_recognition` 库，特征向量以 `.pkl` 文件存储。业务逻辑隔离在 service 层，路由层保持精简。

**技术栈：** Python 3.11+, FastAPI, SQLAlchemy 2.0, SQLite, face_recognition, python-jose (JWT), passlib (bcrypt), python-multipart (文件上传), pytest, httpx (测试客户端)

---

## 文件结构

```
backend/
├── app/
│   ├── __init__.py
│   ├── main.py                  # FastAPI 应用、生命周期、CORS、路由注册
│   ├── core/
│   │   ├── __init__.py
│   │   ├── config.py            # 配置（SECRET_KEY、数据库路径、人脸数据路径）
│   │   ├── database.py          # SQLAlchemy 引擎、SessionLocal、Base
│   │   ├── security.py          # JWT 编码/解码、密码哈希/验证
│   │   └── deps.py              # get_db、get_current_employee、get_current_admin
│   ├── models/
│   │   ├── __init__.py          # 导出所有模型
│   │   ├── admin.py             # Admin 表
│   │   ├── employee.py          # Employee 表 + EmployeeStatus 枚举
│   │   ├── check_policy.py      # CheckPolicy 表
│   │   └── check_record.py      # CheckRecord 表 + CheckType 枚举
│   ├── schemas/
│   │   ├── __init__.py
│   │   ├── admin.py             # Admin 请求/响应结构
│   │   ├── employee.py          # Employee 请求/响应结构
│   │   ├── check_policy.py      # Policy 请求/响应结构
│   │   ├── check_record.py      # Record 请求/响应结构
│   │   └── auth.py              # 登录/注册/Token 结构
│   ├── services/
│   │   ├── __init__.py
│   │   ├── face_service.py      # 人脸编码、比对、删除
│   │   └── check_service.py     # 策略解析、打卡校验
│   └── api/
│       ├── __init__.py
│       ├── admin_auth.py        # POST /api/admin/login
│       ├── employees.py         # 管理员对员工的 CRUD 操作
│       ├── policies.py          # 管理员对策略的 CRUD 操作
│       ├── records.py           # GET /api/records（管理员查看）
│       ├── auth.py              # 员工注册/登录/改密码/录入人脸
│       ├── check.py             # POST /api/check、GET 今日/历史
│       └── me.py                # GET /api/me
├── face_data/                   # .pkl 文件（gitignore）
├── requirements.txt
├── Dockerfile
└── tests/
    ├── __init__.py
    ├── conftest.py              # 测试夹具（测试数据库、测试客户端、种子数据）
    ├── test_admin_auth.py
    ├── test_employees.py
    ├── test_policies.py
    ├── test_auth.py
    ├── test_check.py
    ├── test_check_service.py
    └── test_face_service.py
```

---

### 任务 1：项目初始化与依赖

**文件：**
- 创建：`backend/requirements.txt`
- 创建：`backend/app/__init__.py`
- 创建：`backend/app/core/__init__.py`
- 创建：`backend/app/models/__init__.py`
- 创建：`backend/app/schemas/__init__.py`
- 创建：`backend/app/services/__init__.py`
- 创建：`backend/app/api/__init__.py`
- 创建：`backend/tests/__init__.py`
- 创建：`backend/.gitignore`

- [ ] **步骤 1：创建 requirements.txt**

```txt
fastapi==0.115.0
uvicorn[standard]==0.30.0
sqlalchemy==2.0.35
python-jose[cryptography]==3.3.0
passlib[bcrypt]==1.7.4
python-multipart==0.0.12
face-recognition==1.3.0
numpy==1.26.4
Pillow==10.4.0
httpx==0.27.0
pytest==8.3.0
pytest-asyncio==0.24.0
```

- [ ] **步骤 2：创建所有包的 __init__.py 文件**

所有 `__init__.py` 文件为空。

- [ ] **步骤 3：创建 .gitignore**

```gitignore
__pycache__/
*.pyc
*.pyo
face_data/*.pkl
*.db
.env
```

- [ ] **步骤 4：安装依赖**

运行：`cd backend && pip install -r requirements.txt`
预期：所有包安装成功。

- [ ] **步骤 5：提交**

```bash
git add backend/requirements.txt backend/app/ backend/tests/__init__.py backend/.gitignore
git commit -m "chore: initialize backend project structure and dependencies"
```

---

### 任务 2：核心配置与数据库

**文件：**
- 创建：`backend/app/core/config.py`
- 创建：`backend/app/core/database.py`

- [ ] **步骤 1：编写 config.py**

```python
from pathlib import Path

BASE_DIR = Path(__file__).resolve().parent.parent.parent

class Settings:
    SECRET_KEY: str = "checkman-dev-secret-key-change-in-production"
    ALGORITHM: str = "HS256"
    ACCESS_TOKEN_EXPIRE_MINUTES: int = 60 * 24  # 24 hours
    DATABASE_URL: str = f"sqlite:///{BASE_DIR / 'checkman.db'}"
    FACE_DATA_DIR: Path = BASE_DIR / "face_data"

settings = Settings()
settings.FACE_DATA_DIR.mkdir(parents=True, exist_ok=True)
```

- [ ] **步骤 2：编写 database.py**

```python
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker, DeclarativeBase

from app.core.config import settings

engine = create_engine(settings.DATABASE_URL, connect_args={"check_same_thread": False})
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)


class Base(DeclarativeBase):
    pass
```

- [ ] **步骤 3：验证导入正常**

运行：`cd backend && python -c "from app.core.database import Base, SessionLocal; print('OK')"`
预期：`OK`

- [ ] **步骤 4：提交**

```bash
git add backend/app/core/config.py backend/app/core/database.py
git commit -m "feat: add core config and database setup"
```

---

### 任务 3：安全工具

**文件：**
- 创建：`backend/app/core/security.py`
- 创建：`backend/tests/test_security.py`

- [ ] **步骤 1：编写失败测试**

```python
# backend/tests/test_security.py
from app.core.security import hash_password, verify_password, create_access_token, decode_access_token


def test_password_hash_and_verify():
    password = "testpass123"
    hashed = hash_password(password)
    assert hashed != password
    assert verify_password(password, hashed) is True
    assert verify_password("wrong", hashed) is False


def test_create_and_decode_token():
    token = create_access_token(subject_id=1, role="employee")
    payload = decode_access_token(token)
    assert payload["sub"] == "1"
    assert payload["role"] == "employee"


def test_decode_invalid_token():
    payload = decode_access_token("invalid.token.here")
    assert payload is None
```

- [ ] **步骤 2：运行测试验证失败**

运行：`cd backend && python -m pytest tests/test_security.py -v`
预期：FAIL，ImportError

- [ ] **步骤 3：编写 security.py**

```python
from datetime import datetime, timedelta, timezone

from jose import JWTError, jwt
from passlib.context import CryptContext

from app.core.config import settings

pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")


def hash_password(password: str) -> str:
    return pwd_context.hash(password)


def verify_password(plain_password: str, hashed_password: str) -> bool:
    return pwd_context.verify(plain_password, hashed_password)


def create_access_token(subject_id: int, role: str) -> str:
    expire = datetime.now(timezone.utc) + timedelta(minutes=settings.ACCESS_TOKEN_EXPIRE_MINUTES)
    to_encode = {"sub": str(subject_id), "role": role, "exp": expire}
    return jwt.encode(to_encode, settings.SECRET_KEY, algorithm=settings.ALGORITHM)


def decode_access_token(token: str) -> dict | None:
    try:
        payload = jwt.decode(token, settings.SECRET_KEY, algorithms=[settings.ALGORITHM])
        return payload
    except JWTError:
        return None
```

- [ ] **步骤 4：运行测试验证通过**

运行：`cd backend && python -m pytest tests/test_security.py -v`
预期：3 passed

- [ ] **步骤 5：提交**

```bash
git add backend/app/core/security.py backend/tests/test_security.py
git commit -m "feat: add password hashing and JWT token utilities"
```

---

### 任务 4：数据库模型

**文件：**
- 创建：`backend/app/models/admin.py`
- 创建：`backend/app/models/employee.py`
- 创建：`backend/app/models/check_policy.py`
- 创建：`backend/app/models/check_record.py`
- 修改：`backend/app/models/__init__.py`

- [ ] **步骤 1：编写 admin.py 模型**

```python
from datetime import datetime, timezone

from sqlalchemy import Boolean, DateTime, Integer, String
from sqlalchemy.orm import Mapped, mapped_column

from app.core.database import Base


class Admin(Base):
    __tablename__ = "admins"

    id: Mapped[int] = mapped_column(Integer, primary_key=True, autoincrement=True)
    username: Mapped[str] = mapped_column(String(50), unique=True, nullable=False)
    password_hash: Mapped[str] = mapped_column(String(128), nullable=False)
    must_change_password: Mapped[bool] = mapped_column(Boolean, default=True)
    created_at: Mapped[datetime] = mapped_column(
        DateTime, default=lambda: datetime.now(timezone.utc)
    )
```

- [ ] **步骤 2：编写 check_policy.py 模型**

```python
from datetime import datetime, timezone

from sqlalchemy import Boolean, DateTime, Float, Integer, String
from sqlalchemy.orm import Mapped, mapped_column

from app.core.database import Base


class CheckPolicy(Base):
    __tablename__ = "check_policies"

    id: Mapped[int] = mapped_column(Integer, primary_key=True, autoincrement=True)
    name: Mapped[str] = mapped_column(String(100), unique=True, nullable=False)
    require_face: Mapped[bool] = mapped_column(Boolean, default=False)
    require_location: Mapped[bool] = mapped_column(Boolean, default=False)
    location_lat: Mapped[float | None] = mapped_column(Float, nullable=True)
    location_lng: Mapped[float | None] = mapped_column(Float, nullable=True)
    location_radius: Mapped[float | None] = mapped_column(Float, nullable=True)
    created_at: Mapped[datetime] = mapped_column(
        DateTime, default=lambda: datetime.now(timezone.utc)
    )
```

- [ ] **步骤 3：编写 employee.py 模型**

```python
import enum
from datetime import datetime, timezone

from sqlalchemy import Boolean, DateTime, Enum, Float, ForeignKey, Integer, String
from sqlalchemy.orm import Mapped, mapped_column, relationship

from app.core.database import Base


class EmployeeStatus(str, enum.Enum):
    pending = "pending"
    active = "active"
    rejected = "rejected"


class Employee(Base):
    __tablename__ = "employees"

    id: Mapped[int] = mapped_column(Integer, primary_key=True, autoincrement=True)
    name: Mapped[str] = mapped_column(String(100), nullable=False)
    username: Mapped[str] = mapped_column(String(50), unique=True, nullable=False)
    password_hash: Mapped[str] = mapped_column(String(128), nullable=False)
    must_change_password: Mapped[bool] = mapped_column(Boolean, default=False)
    status: Mapped[EmployeeStatus] = mapped_column(
        Enum(EmployeeStatus), default=EmployeeStatus.pending
    )
    face_registered: Mapped[bool] = mapped_column(Boolean, default=False)
    policy_id: Mapped[int | None] = mapped_column(
        Integer, ForeignKey("check_policies.id", ondelete="SET NULL"), nullable=True
    )
    override_face: Mapped[bool | None] = mapped_column(Boolean, nullable=True)
    override_location: Mapped[bool | None] = mapped_column(Boolean, nullable=True)
    override_lat: Mapped[float | None] = mapped_column(Float, nullable=True)
    override_lng: Mapped[float | None] = mapped_column(Float, nullable=True)
    override_radius: Mapped[float | None] = mapped_column(Float, nullable=True)
    created_at: Mapped[datetime] = mapped_column(
        DateTime, default=lambda: datetime.now(timezone.utc)
    )

    policy = relationship("CheckPolicy", lazy="joined")
```

- [ ] **步骤 4：编写 check_record.py 模型**

```python
import enum
from datetime import datetime, timezone

from sqlalchemy import Boolean, DateTime, Enum, Float, ForeignKey, Integer
from sqlalchemy.orm import Mapped, mapped_column

from app.core.database import Base


class CheckType(str, enum.Enum):
    clock_in = "clock_in"
    clock_out = "clock_out"


class CheckRecord(Base):
    __tablename__ = "check_records"

    id: Mapped[int] = mapped_column(Integer, primary_key=True, autoincrement=True)
    employee_id: Mapped[int] = mapped_column(
        Integer, ForeignKey("employees.id", ondelete="CASCADE"), nullable=False
    )
    check_time: Mapped[datetime] = mapped_column(DateTime, nullable=False)
    check_type: Mapped[CheckType] = mapped_column(Enum(CheckType), nullable=False)
    face_passed: Mapped[bool | None] = mapped_column(Boolean, nullable=True)
    location_lat: Mapped[float | None] = mapped_column(Float, nullable=True)
    location_lng: Mapped[float | None] = mapped_column(Float, nullable=True)
    location_passed: Mapped[bool | None] = mapped_column(Boolean, nullable=True)
    created_at: Mapped[datetime] = mapped_column(
        DateTime, default=lambda: datetime.now(timezone.utc)
    )
```

- [ ] **步骤 5：更新 models/__init__.py**

```python
from app.models.admin import Admin
from app.models.employee import Employee, EmployeeStatus
from app.models.check_policy import CheckPolicy
from app.models.check_record import CheckRecord, CheckType

__all__ = ["Admin", "Employee", "EmployeeStatus", "CheckPolicy", "CheckRecord", "CheckType"]
```

- [ ] **步骤 6：验证模型可以创建表**

运行：`cd backend && python -c "from app.core.database import Base, engine; from app.models import *; Base.metadata.create_all(bind=engine); print('Tables created OK')"`
预期：`Tables created OK`

- [ ] **步骤 7：清理测试数据库并提交**

```bash
rm -f backend/checkman.db
git add backend/app/models/
git commit -m "feat: add all database models (Admin, Employee, CheckPolicy, CheckRecord)"
```

---

### 任务 5：Pydantic 数据结构

**文件：**
- 创建：`backend/app/schemas/auth.py`
- 创建：`backend/app/schemas/admin.py`
- 创建：`backend/app/schemas/employee.py`
- 创建：`backend/app/schemas/check_policy.py`
- 创建：`backend/app/schemas/check_record.py`

- [ ] **步骤 1：编写 auth.py 数据结构**

```python
from pydantic import BaseModel


class LoginRequest(BaseModel):
    username: str
    password: str


class TokenResponse(BaseModel):
    access_token: str
    token_type: str = "bearer"


class RegisterRequest(BaseModel):
    name: str
    username: str
    password: str
    # face_image is uploaded as a file via multipart form, not in JSON body


class ChangePasswordRequest(BaseModel):
    old_password: str
    new_password: str


class EmployeeLoginResponse(BaseModel):
    access_token: str
    token_type: str = "bearer"
    status: str
    must_change_password: bool
    face_registered: bool
```

- [ ] **步骤 2：编写 admin.py 数据结构**

```python
from datetime import datetime

from pydantic import BaseModel


class AdminResponse(BaseModel):
    id: int
    username: str
    must_change_password: bool
    created_at: datetime

    model_config = {"from_attributes": True}
```

- [ ] **步骤 3：编写 employee.py 数据结构**

```python
from datetime import datetime

from pydantic import BaseModel


class EmployeeResponse(BaseModel):
    id: int
    name: str
    username: str
    status: str
    face_registered: bool
    must_change_password: bool
    policy_id: int | None
    override_face: bool | None
    override_location: bool | None
    override_lat: float | None
    override_lng: float | None
    override_radius: float | None
    created_at: datetime

    model_config = {"from_attributes": True}


class EmployeeUpdateRequest(BaseModel):
    name: str | None = None
    policy_id: int | None = None
    override_face: bool | None = None
    override_location: bool | None = None
    override_lat: float | None = None
    override_lng: float | None = None
    override_radius: float | None = None


class EmployeeMeResponse(BaseModel):
    id: int
    name: str
    username: str
    status: str
    face_registered: bool
    must_change_password: bool
    # Resolved effective check requirements
    require_face: bool
    require_location: bool
    location_lat: float | None
    location_lng: float | None
    location_radius: float | None
```

- [ ] **步骤 4：编写 check_policy.py 数据结构**

```python
from datetime import datetime

from pydantic import BaseModel


class PolicyCreateRequest(BaseModel):
    name: str
    require_face: bool = False
    require_location: bool = False
    location_lat: float | None = None
    location_lng: float | None = None
    location_radius: float | None = None


class PolicyUpdateRequest(BaseModel):
    name: str | None = None
    require_face: bool | None = None
    require_location: bool | None = None
    location_lat: float | None = None
    location_lng: float | None = None
    location_radius: float | None = None


class PolicyResponse(BaseModel):
    id: int
    name: str
    require_face: bool
    require_location: bool
    location_lat: float | None
    location_lng: float | None
    location_radius: float | None
    created_at: datetime

    model_config = {"from_attributes": True}
```

- [ ] **步骤 5：编写 check_record.py 数据结构**

```python
from datetime import datetime

from pydantic import BaseModel


class CheckRequest(BaseModel):
    check_type: str  # "clock_in" or "clock_out"
    location_lat: float | None = None
    location_lng: float | None = None
    # face_image is uploaded as a file via multipart form


class CheckResponse(BaseModel):
    id: int
    check_time: datetime
    check_type: str
    face_passed: bool | None
    location_lat: float | None
    location_lng: float | None
    location_passed: bool | None

    model_config = {"from_attributes": True}


class CheckRecordResponse(BaseModel):
    id: int
    employee_id: int
    check_time: datetime
    check_type: str
    face_passed: bool | None
    location_lat: float | None
    location_lng: float | None
    location_passed: bool | None
    created_at: datetime

    model_config = {"from_attributes": True}
```

- [ ] **步骤 6：验证数据结构可导入**

运行：`cd backend && python -c "from app.schemas.auth import *; from app.schemas.employee import *; from app.schemas.check_policy import *; from app.schemas.check_record import *; print('OK')"`
预期：`OK`

- [ ] **步骤 7：提交**

```bash
git add backend/app/schemas/
git commit -m "feat: add all Pydantic request/response schemas"
```

---

### 任务 6：依赖注入与测试夹具

**文件：**
- 创建：`backend/app/core/deps.py`
- 创建：`backend/tests/conftest.py`

- [ ] **步骤 1：编写 deps.py**

```python
from typing import Generator

from fastapi import Depends, HTTPException, status
from fastapi.security import HTTPAuthorizationCredentials, HTTPBearer
from sqlalchemy.orm import Session

from app.core.database import SessionLocal
from app.core.security import decode_access_token
from app.models.admin import Admin
from app.models.employee import Employee

security_scheme = HTTPBearer()


def get_db() -> Generator[Session, None, None]:
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()


def get_current_admin(
    credentials: HTTPAuthorizationCredentials = Depends(security_scheme),
    db: Session = Depends(get_db),
) -> Admin:
    payload = decode_access_token(credentials.credentials)
    if payload is None or payload.get("role") != "admin":
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Invalid admin token")
    admin = db.get(Admin, int(payload["sub"]))
    if admin is None:
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Admin not found")
    return admin


def get_current_employee(
    credentials: HTTPAuthorizationCredentials = Depends(security_scheme),
    db: Session = Depends(get_db),
) -> Employee:
    payload = decode_access_token(credentials.credentials)
    if payload is None or payload.get("role") != "employee":
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Invalid employee token")
    employee = db.get(Employee, int(payload["sub"]))
    if employee is None:
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Employee not found")
    return employee
```

- [ ] **步骤 2：编写 conftest.py**

```python
import pytest
from fastapi.testclient import TestClient
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker

from app.core.database import Base
from app.core.deps import get_db
from app.core.security import hash_password, create_access_token
from app.main import app
from app.models.admin import Admin
from app.models.employee import Employee, EmployeeStatus

TEST_DATABASE_URL = "sqlite:///./test.db"
test_engine = create_engine(TEST_DATABASE_URL, connect_args={"check_same_thread": False})
TestSession = sessionmaker(autocommit=False, autoflush=False, bind=test_engine)


def override_get_db():
    db = TestSession()
    try:
        yield db
    finally:
        db.close()


app.dependency_overrides[get_db] = override_get_db


@pytest.fixture(autouse=True)
def setup_db():
    Base.metadata.create_all(bind=test_engine)
    yield
    Base.metadata.drop_all(bind=test_engine)


@pytest.fixture
def db():
    db = TestSession()
    try:
        yield db
    finally:
        db.close()


@pytest.fixture
def client():
    return TestClient(app)


@pytest.fixture
def seed_admin(db):
    admin = Admin(username="admin", password_hash=hash_password("admin123"))
    db.add(admin)
    db.commit()
    db.refresh(admin)
    return admin


@pytest.fixture
def admin_token(seed_admin):
    return create_access_token(subject_id=seed_admin.id, role="admin")


@pytest.fixture
def admin_headers(admin_token):
    return {"Authorization": f"Bearer {admin_token}"}


@pytest.fixture
def seed_active_employee(db):
    emp = Employee(
        name="Test Employee",
        username="employee1",
        password_hash=hash_password("emp123"),
        status=EmployeeStatus.active,
        face_registered=True,
    )
    db.add(emp)
    db.commit()
    db.refresh(emp)
    return emp


@pytest.fixture
def employee_token(seed_active_employee):
    return create_access_token(subject_id=seed_active_employee.id, role="employee")


@pytest.fixture
def employee_headers(employee_token):
    return {"Authorization": f"Bearer {employee_token}"}
```

- [ ] **步骤 3：创建 main.py 占位（供测试导入）**

```python
# backend/app/main.py
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from app.core.database import Base, engine

app = FastAPI(title="CheckMan API")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


@app.on_event("startup")
def on_startup():
    Base.metadata.create_all(bind=engine)
```

- [ ] **步骤 4：验证测试基础设施可用**

运行：`cd backend && python -m pytest tests/ -v --co`
预期：显示已收集的测试项（来自 test_security.py）

- [ ] **步骤 5：提交**

```bash
git add backend/app/core/deps.py backend/app/main.py backend/tests/conftest.py
git commit -m "feat: add dependency injection, test fixtures, and FastAPI app skeleton"
```

---

### 任务 7：管理员登录 API

**文件：**
- 创建：`backend/app/api/admin_auth.py`
- 创建：`backend/tests/test_admin_auth.py`
- 修改：`backend/app/main.py`

- [ ] **步骤 1：编写失败测试**

```python
# backend/tests/test_admin_auth.py


def test_admin_login_success(client, seed_admin):
    resp = client.post("/api/admin/login", json={"username": "admin", "password": "admin123"})
    assert resp.status_code == 200
    data = resp.json()
    assert "access_token" in data
    assert data["token_type"] == "bearer"


def test_admin_login_wrong_password(client, seed_admin):
    resp = client.post("/api/admin/login", json={"username": "admin", "password": "wrong"})
    assert resp.status_code == 401


def test_admin_login_nonexistent_user(client):
    resp = client.post("/api/admin/login", json={"username": "nobody", "password": "pass"})
    assert resp.status_code == 401
```

- [ ] **步骤 2：运行测试验证失败**

运行：`cd backend && python -m pytest tests/test_admin_auth.py -v`
预期：FAIL（404，路由未找到）

- [ ] **步骤 3：编写 admin_auth.py**

```python
from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session

from app.core.deps import get_db
from app.core.security import verify_password, create_access_token
from app.models.admin import Admin
from app.schemas.auth import LoginRequest, TokenResponse

router = APIRouter(prefix="/api/admin", tags=["admin-auth"])


@router.post("/login", response_model=TokenResponse)
def admin_login(body: LoginRequest, db: Session = Depends(get_db)):
    admin = db.query(Admin).filter(Admin.username == body.username).first()
    if admin is None or not verify_password(body.password, admin.password_hash):
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Invalid credentials")
    token = create_access_token(subject_id=admin.id, role="admin")
    return TokenResponse(access_token=token)
```

- [ ] **步骤 4：在 main.py 注册路由**

在 `backend/app/main.py` 中间件之后添加：

```python
from app.api import admin_auth

app.include_router(admin_auth.router)
```

- [ ] **步骤 5：运行测试验证通过**

运行：`cd backend && python -m pytest tests/test_admin_auth.py -v`
预期：3 passed

- [ ] **步骤 6：提交**

```bash
git add backend/app/api/admin_auth.py backend/tests/test_admin_auth.py backend/app/main.py
git commit -m "feat: add admin login API endpoint"
```

---

### 任务 8：打卡策略 CRUD API（管理员）

**文件：**
- 创建：`backend/app/api/policies.py`
- 创建：`backend/tests/test_policies.py`
- 修改：`backend/app/main.py`

- [ ] **步骤 1：编写失败测试**

```python
# backend/tests/test_policies.py


def test_create_policy(client, admin_headers):
    resp = client.post(
        "/api/policies",
        json={"name": "Office", "require_face": True, "require_location": True,
              "location_lat": 31.23, "location_lng": 121.47, "location_radius": 200},
        headers=admin_headers,
    )
    assert resp.status_code == 201
    data = resp.json()
    assert data["name"] == "Office"
    assert data["require_face"] is True
    assert data["location_radius"] == 200


def test_list_policies(client, admin_headers):
    client.post("/api/policies", json={"name": "P1"}, headers=admin_headers)
    client.post("/api/policies", json={"name": "P2"}, headers=admin_headers)
    resp = client.get("/api/policies", headers=admin_headers)
    assert resp.status_code == 200
    assert len(resp.json()) == 2


def test_update_policy(client, admin_headers):
    create_resp = client.post("/api/policies", json={"name": "Old"}, headers=admin_headers)
    pid = create_resp.json()["id"]
    resp = client.put(f"/api/policies/{pid}", json={"name": "New"}, headers=admin_headers)
    assert resp.status_code == 200
    assert resp.json()["name"] == "New"


def test_delete_policy(client, admin_headers):
    create_resp = client.post("/api/policies", json={"name": "ToDelete"}, headers=admin_headers)
    pid = create_resp.json()["id"]
    resp = client.delete(f"/api/policies/{pid}", headers=admin_headers)
    assert resp.status_code == 204


def test_policy_requires_admin(client):
    resp = client.get("/api/policies")
    assert resp.status_code == 403
```

- [ ] **步骤 2：运行测试验证失败**

运行：`cd backend && python -m pytest tests/test_policies.py -v`
预期：FAIL

- [ ] **步骤 3：编写 policies.py**

```python
from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session

from app.core.deps import get_db, get_current_admin
from app.models.admin import Admin
from app.models.check_policy import CheckPolicy
from app.schemas.check_policy import PolicyCreateRequest, PolicyUpdateRequest, PolicyResponse

router = APIRouter(prefix="/api/policies", tags=["policies"])


@router.get("", response_model=list[PolicyResponse])
def list_policies(db: Session = Depends(get_db), _admin: Admin = Depends(get_current_admin)):
    return db.query(CheckPolicy).all()


@router.post("", response_model=PolicyResponse, status_code=status.HTTP_201_CREATED)
def create_policy(
    body: PolicyCreateRequest,
    db: Session = Depends(get_db),
    _admin: Admin = Depends(get_current_admin),
):
    policy = CheckPolicy(**body.model_dump())
    db.add(policy)
    db.commit()
    db.refresh(policy)
    return policy


@router.put("/{policy_id}", response_model=PolicyResponse)
def update_policy(
    policy_id: int,
    body: PolicyUpdateRequest,
    db: Session = Depends(get_db),
    _admin: Admin = Depends(get_current_admin),
):
    policy = db.get(CheckPolicy, policy_id)
    if policy is None:
        raise HTTPException(status_code=404, detail="Policy not found")
    for key, value in body.model_dump(exclude_unset=True).items():
        setattr(policy, key, value)
    db.commit()
    db.refresh(policy)
    return policy


@router.delete("/{policy_id}", status_code=status.HTTP_204_NO_CONTENT)
def delete_policy(
    policy_id: int,
    db: Session = Depends(get_db),
    _admin: Admin = Depends(get_current_admin),
):
    policy = db.get(CheckPolicy, policy_id)
    if policy is None:
        raise HTTPException(status_code=404, detail="Policy not found")
    db.delete(policy)
    db.commit()
```

- [ ] **步骤 4：在 main.py 注册路由**

```python
from app.api import admin_auth, policies

app.include_router(policies.router)
```

- [ ] **步骤 5：运行测试验证通过**

运行：`cd backend && python -m pytest tests/test_policies.py -v`
预期：5 passed

- [ ] **步骤 6：提交**

```bash
git add backend/app/api/policies.py backend/tests/test_policies.py backend/app/main.py
git commit -m "feat: add check policy CRUD API endpoints"
```

---

### 任务 9：员工认证 API（注册与登录）

**文件：**
- 创建：`backend/app/api/auth.py`
- 创建：`backend/tests/test_auth.py`
- 修改：`backend/app/main.py`

- [ ] **步骤 1：编写失败测试**

```python
# backend/tests/test_auth.py
import io


def test_register_employee(client):
    fake_image = io.BytesIO(b"fake image data")
    resp = client.post(
        "/api/auth/register",
        data={"name": "Zhang San", "username": "zhangsan", "password": "pass123"},
        files={"face_image": ("face.jpg", fake_image, "image/jpeg")},
    )
    assert resp.status_code == 201
    data = resp.json()
    assert data["username"] == "zhangsan"
    assert data["status"] == "pending"


def test_register_duplicate_username(client):
    fake_image = io.BytesIO(b"fake image data")
    client.post(
        "/api/auth/register",
        data={"name": "A", "username": "dup", "password": "pass"},
        files={"face_image": ("face.jpg", fake_image, "image/jpeg")},
    )
    fake_image2 = io.BytesIO(b"fake image data")
    resp = client.post(
        "/api/auth/register",
        data={"name": "B", "username": "dup", "password": "pass"},
        files={"face_image": ("face.jpg", fake_image2, "image/jpeg")},
    )
    # 被拒绝的用户可以用同一用户名重新注册，但 pending 状态不行
    assert resp.status_code == 409


def test_login_employee(client, seed_active_employee):
    resp = client.post("/api/auth/login", json={"username": "employee1", "password": "emp123"})
    assert resp.status_code == 200
    data = resp.json()
    assert data["status"] == "active"
    assert "access_token" in data


def test_login_wrong_password(client, seed_active_employee):
    resp = client.post("/api/auth/login", json={"username": "employee1", "password": "wrong"})
    assert resp.status_code == 401


def test_change_password(client, employee_headers, seed_active_employee):
    resp = client.post(
        "/api/auth/change-password",
        json={"old_password": "emp123", "new_password": "newpass456"},
        headers=employee_headers,
    )
    assert resp.status_code == 200
    # 验证新密码可用
    login_resp = client.post(
        "/api/auth/login", json={"username": "employee1", "password": "newpass456"}
    )
    assert login_resp.status_code == 200


def test_change_password_wrong_old(client, employee_headers):
    resp = client.post(
        "/api/auth/change-password",
        json={"old_password": "wrong", "new_password": "new"},
        headers=employee_headers,
    )
    assert resp.status_code == 400
```

- [ ] **步骤 2：运行测试验证失败**

运行：`cd backend && python -m pytest tests/test_auth.py -v`
预期：FAIL

- [ ] **步骤 3：编写 auth.py**

```python
from fastapi import APIRouter, Depends, File, Form, HTTPException, UploadFile, status
from sqlalchemy.orm import Session

from app.core.deps import get_db, get_current_employee
from app.core.security import hash_password, verify_password, create_access_token
from app.models.employee import Employee, EmployeeStatus
from app.schemas.auth import ChangePasswordRequest, EmployeeLoginResponse, LoginRequest
from app.schemas.employee import EmployeeResponse
from app.services.face_service import encode_and_save_face

router = APIRouter(prefix="/api/auth", tags=["employee-auth"])


@router.post("/register", response_model=EmployeeResponse, status_code=status.HTTP_201_CREATED)
def register(
    name: str = Form(...),
    username: str = Form(...),
    password: str = Form(...),
    face_image: UploadFile = File(...),
    db: Session = Depends(get_db),
):
    existing = db.query(Employee).filter(Employee.username == username).first()
    if existing is not None:
        if existing.status == EmployeeStatus.rejected:
            # 允许重新注册：删除旧记录
            db.delete(existing)
            db.flush()
        else:
            raise HTTPException(status_code=409, detail="Username already taken")

    employee = Employee(
        name=name,
        username=username,
        password_hash=hash_password(password),
        status=EmployeeStatus.pending,
        face_registered=False,
    )
    db.add(employee)
    db.commit()
    db.refresh(employee)

    # 保存人脸编码
    image_bytes = face_image.file.read()
    success = encode_and_save_face(employee.id, image_bytes)
    if success:
        employee.face_registered = True
        db.commit()
        db.refresh(employee)

    return employee


@router.post("/login", response_model=EmployeeLoginResponse)
def login(body: LoginRequest, db: Session = Depends(get_db)):
    employee = db.query(Employee).filter(Employee.username == body.username).first()
    if employee is None or not verify_password(body.password, employee.password_hash):
        raise HTTPException(status_code=401, detail="Invalid credentials")
    token = create_access_token(subject_id=employee.id, role="employee")
    return EmployeeLoginResponse(
        access_token=token,
        status=employee.status.value,
        must_change_password=employee.must_change_password,
        face_registered=employee.face_registered,
    )


@router.post("/change-password")
def change_password(
    body: ChangePasswordRequest,
    db: Session = Depends(get_db),
    employee: Employee = Depends(get_current_employee),
):
    if not verify_password(body.old_password, employee.password_hash):
        raise HTTPException(status_code=400, detail="Old password incorrect")
    employee.password_hash = hash_password(body.new_password)
    employee.must_change_password = False
    db.commit()
    return {"message": "Password changed"}


@router.post("/register-face")
def register_face(
    face_image: UploadFile = File(...),
    db: Session = Depends(get_db),
    employee: Employee = Depends(get_current_employee),
):
    image_bytes = face_image.file.read()
    success = encode_and_save_face(employee.id, image_bytes)
    if not success:
        raise HTTPException(status_code=400, detail="No face detected in image")
    employee.face_registered = True
    db.commit()
    return {"message": "Face registered"}
```

- [ ] **步骤 4：创建 face_service.py 桩实现（让测试通过）**

注册端点调用 `encode_and_save_face`。先创建一个桩实现，接受任何字节并返回 True（真实实现在任务 11）。

```python
# backend/app/services/face_service.py
import pickle
from pathlib import Path

from app.core.config import settings


def encode_and_save_face(employee_id: int, image_bytes: bytes) -> bool:
    """Extract face encoding from image bytes and save to .pkl file.
    Returns True if a face was detected and saved, False otherwise.
    Stub implementation: always saves and returns True.
    """
    face_path = settings.FACE_DATA_DIR / f"{employee_id}.pkl"
    with open(face_path, "wb") as f:
        pickle.dump(image_bytes, f)
    return True


def load_face_encoding(employee_id: int):
    """Load face encoding from .pkl file. Returns encoding or None."""
    face_path = settings.FACE_DATA_DIR / f"{employee_id}.pkl"
    if not face_path.exists():
        return None
    with open(face_path, "rb") as f:
        return pickle.load(f)


def compare_faces(known_encoding, image_bytes: bytes) -> bool:
    """Compare uploaded face image against known encoding.
    Stub implementation: always returns True.
    """
    return True


def delete_face(employee_id: int) -> None:
    """Delete face encoding file."""
    face_path = settings.FACE_DATA_DIR / f"{employee_id}.pkl"
    if face_path.exists():
        face_path.unlink()
```

- [ ] **步骤 5：在 main.py 注册路由**

```python
from app.api import admin_auth, policies, auth

app.include_router(auth.router)
```

- [ ] **步骤 6：运行测试验证通过**

运行：`cd backend && python -m pytest tests/test_auth.py -v`
预期：6 passed

- [ ] **步骤 7：提交**

```bash
git add backend/app/api/auth.py backend/app/services/face_service.py backend/tests/test_auth.py backend/app/main.py
git commit -m "feat: add employee register, login, change-password, register-face APIs"
```

---

### 任务 10：员工管理 API（管理员）

**文件：**
- 创建：`backend/app/api/employees.py`
- 创建：`backend/tests/test_employees.py`
- 修改：`backend/app/main.py`

- [ ] **步骤 1：编写失败测试**

```python
# backend/tests/test_employees.py
from app.core.security import hash_password
from app.models.employee import Employee, EmployeeStatus


def _create_pending_employee(db):
    emp = Employee(
        name="Pending", username="pending1",
        password_hash=hash_password("pass"), status=EmployeeStatus.pending,
    )
    db.add(emp)
    db.commit()
    db.refresh(emp)
    return emp


def test_list_employees(client, admin_headers, seed_active_employee):
    resp = client.get("/api/employees", headers=admin_headers)
    assert resp.status_code == 200
    assert len(resp.json()) >= 1


def test_list_employees_filter_status(client, admin_headers, db, seed_active_employee):
    _create_pending_employee(db)
    resp = client.get("/api/employees?status=pending", headers=admin_headers)
    assert resp.status_code == 200
    data = resp.json()
    assert all(e["status"] == "pending" for e in data)


def test_approve_employee(client, admin_headers, db):
    emp = _create_pending_employee(db)
    resp = client.post(f"/api/employees/{emp.id}/approve", headers=admin_headers)
    assert resp.status_code == 200
    assert resp.json()["status"] == "active"


def test_reject_employee(client, admin_headers, db):
    emp = _create_pending_employee(db)
    resp = client.post(f"/api/employees/{emp.id}/reject", headers=admin_headers)
    assert resp.status_code == 200
    assert resp.json()["status"] == "rejected"


def test_update_employee(client, admin_headers, seed_active_employee):
    resp = client.put(
        f"/api/employees/{seed_active_employee.id}",
        json={"override_face": True},
        headers=admin_headers,
    )
    assert resp.status_code == 200
    assert resp.json()["override_face"] is True


def test_delete_employee(client, admin_headers, seed_active_employee):
    resp = client.delete(f"/api/employees/{seed_active_employee.id}", headers=admin_headers)
    assert resp.status_code == 204


def test_reset_password(client, admin_headers, seed_active_employee):
    resp = client.post(
        f"/api/employees/{seed_active_employee.id}/reset-password", headers=admin_headers
    )
    assert resp.status_code == 200
    data = resp.json()
    assert "temp_password" in data


def test_reset_face(client, admin_headers, seed_active_employee):
    resp = client.post(
        f"/api/employees/{seed_active_employee.id}/reset-face", headers=admin_headers
    )
    assert resp.status_code == 200
```

- [ ] **步骤 2：运行测试验证失败**

运行：`cd backend && python -m pytest tests/test_employees.py -v`
预期：FAIL

- [ ] **步骤 3：编写 employees.py**

```python
import secrets
import string

from fastapi import APIRouter, Depends, HTTPException, Query, status
from sqlalchemy.orm import Session

from app.core.deps import get_db, get_current_admin
from app.core.security import hash_password
from app.models.admin import Admin
from app.models.employee import Employee, EmployeeStatus
from app.schemas.employee import EmployeeResponse, EmployeeUpdateRequest
from app.services.face_service import delete_face

router = APIRouter(prefix="/api/employees", tags=["employees"])


def _generate_temp_password(length: int = 8) -> str:
    chars = string.ascii_letters + string.digits
    return "".join(secrets.choice(chars) for _ in range(length))


@router.get("", response_model=list[EmployeeResponse])
def list_employees(
    status_filter: EmployeeStatus | None = Query(None, alias="status"),
    name: str | None = Query(None),
    db: Session = Depends(get_db),
    _admin: Admin = Depends(get_current_admin),
):
    query = db.query(Employee)
    if status_filter is not None:
        query = query.filter(Employee.status == status_filter)
    if name is not None:
        query = query.filter(Employee.name.contains(name))
    return query.all()


@router.post("/{employee_id}/approve", response_model=EmployeeResponse)
def approve_employee(
    employee_id: int,
    db: Session = Depends(get_db),
    _admin: Admin = Depends(get_current_admin),
):
    emp = db.get(Employee, employee_id)
    if emp is None:
        raise HTTPException(status_code=404, detail="Employee not found")
    if emp.status != EmployeeStatus.pending:
        raise HTTPException(status_code=400, detail="Can only approve pending employees")
    emp.status = EmployeeStatus.active
    db.commit()
    db.refresh(emp)
    return emp


@router.post("/{employee_id}/reject", response_model=EmployeeResponse)
def reject_employee(
    employee_id: int,
    db: Session = Depends(get_db),
    _admin: Admin = Depends(get_current_admin),
):
    emp = db.get(Employee, employee_id)
    if emp is None:
        raise HTTPException(status_code=404, detail="Employee not found")
    if emp.status != EmployeeStatus.pending:
        raise HTTPException(status_code=400, detail="Can only reject pending employees")
    emp.status = EmployeeStatus.rejected
    db.commit()
    db.refresh(emp)
    return emp


@router.put("/{employee_id}", response_model=EmployeeResponse)
def update_employee(
    employee_id: int,
    body: EmployeeUpdateRequest,
    db: Session = Depends(get_db),
    _admin: Admin = Depends(get_current_admin),
):
    emp = db.get(Employee, employee_id)
    if emp is None:
        raise HTTPException(status_code=404, detail="Employee not found")
    for key, value in body.model_dump(exclude_unset=True).items():
        setattr(emp, key, value)
    db.commit()
    db.refresh(emp)
    return emp


@router.delete("/{employee_id}", status_code=status.HTTP_204_NO_CONTENT)
def delete_employee(
    employee_id: int,
    db: Session = Depends(get_db),
    _admin: Admin = Depends(get_current_admin),
):
    emp = db.get(Employee, employee_id)
    if emp is None:
        raise HTTPException(status_code=404, detail="Employee not found")
    delete_face(emp.id)
    db.delete(emp)
    db.commit()


@router.post("/{employee_id}/reset-password")
def reset_password(
    employee_id: int,
    db: Session = Depends(get_db),
    _admin: Admin = Depends(get_current_admin),
):
    emp = db.get(Employee, employee_id)
    if emp is None:
        raise HTTPException(status_code=404, detail="Employee not found")
    temp_password = _generate_temp_password()
    emp.password_hash = hash_password(temp_password)
    emp.must_change_password = True
    db.commit()
    return {"message": "Password reset", "temp_password": temp_password}


@router.post("/{employee_id}/reset-face")
def reset_face(
    employee_id: int,
    db: Session = Depends(get_db),
    _admin: Admin = Depends(get_current_admin),
):
    emp = db.get(Employee, employee_id)
    if emp is None:
        raise HTTPException(status_code=404, detail="Employee not found")
    delete_face(emp.id)
    emp.face_registered = False
    db.commit()
    return {"message": "Face data reset"}
```

- [ ] **步骤 4：在 main.py 注册路由**

```python
from app.api import admin_auth, policies, auth, employees

app.include_router(employees.router)
```

- [ ] **步骤 5：运行测试验证通过**

运行：`cd backend && python -m pytest tests/test_employees.py -v`
预期：8 passed

- [ ] **步骤 6：提交**

```bash
git add backend/app/api/employees.py backend/tests/test_employees.py backend/app/main.py
git commit -m "feat: add employee management API (list, approve, reject, update, delete, reset)"
```

---

### 任务 11：人脸识别服务（真实实现）

**文件：**
- 修改：`backend/app/services/face_service.py`
- 创建：`backend/tests/test_face_service.py`

- [ ] **步骤 1：编写失败测试**

```python
# backend/tests/test_face_service.py
import pickle
from pathlib import Path
from unittest.mock import patch, MagicMock

import numpy as np

from app.core.config import settings
from app.services.face_service import encode_and_save_face, load_face_encoding, compare_faces, delete_face


@patch("app.services.face_service.face_recognition")
def test_encode_and_save_face_success(mock_fr):
    fake_encoding = np.array([0.1, 0.2, 0.3])
    mock_fr.load_image_file.return_value = MagicMock()
    mock_fr.face_encodings.return_value = [fake_encoding]

    result = encode_and_save_face(9999, b"fake image bytes")
    assert result is True

    face_path = settings.FACE_DATA_DIR / "9999.pkl"
    assert face_path.exists()
    # 清理
    face_path.unlink()


@patch("app.services.face_service.face_recognition")
def test_encode_and_save_face_no_face(mock_fr):
    mock_fr.load_image_file.return_value = MagicMock()
    mock_fr.face_encodings.return_value = []

    result = encode_and_save_face(9998, b"no face bytes")
    assert result is False


def test_load_face_encoding_not_found():
    result = load_face_encoding(99999)
    assert result is None


@patch("app.services.face_service.face_recognition")
def test_compare_faces_match(mock_fr):
    known = np.array([0.1, 0.2, 0.3])
    mock_fr.load_image_file.return_value = MagicMock()
    mock_fr.face_encodings.return_value = [np.array([0.1, 0.2, 0.3])]
    mock_fr.compare_faces.return_value = [True]

    result = compare_faces(known, b"face bytes")
    assert result is True


@patch("app.services.face_service.face_recognition")
def test_compare_faces_no_match(mock_fr):
    known = np.array([0.1, 0.2, 0.3])
    mock_fr.load_image_file.return_value = MagicMock()
    mock_fr.face_encodings.return_value = [np.array([0.9, 0.9, 0.9])]
    mock_fr.compare_faces.return_value = [False]

    result = compare_faces(known, b"face bytes")
    assert result is False


def test_delete_face_nonexistent():
    # 不应抛异常
    delete_face(99999)
```

- [ ] **步骤 2：运行测试验证失败**

运行：`cd backend && python -m pytest tests/test_face_service.py -v`
预期：FAIL（桩实现不使用 face_recognition）

- [ ] **步骤 3：替换 face_service.py 为真实实现**

```python
# backend/app/services/face_service.py
import io
import pickle

import face_recognition
import numpy as np
from PIL import Image

from app.core.config import settings


def encode_and_save_face(employee_id: int, image_bytes: bytes) -> bool:
    """Extract face encoding from image bytes and save to .pkl file.
    Returns True if a face was detected and saved, False otherwise.
    """
    try:
        image = Image.open(io.BytesIO(image_bytes)).convert("RGB")
        image_array = np.array(image)
        encodings = face_recognition.face_encodings(image_array)
        if len(encodings) == 0:
            return False
        face_path = settings.FACE_DATA_DIR / f"{employee_id}.pkl"
        with open(face_path, "wb") as f:
            pickle.dump(encodings[0], f)
        return True
    except Exception:
        return False


def load_face_encoding(employee_id: int) -> np.ndarray | None:
    """Load face encoding from .pkl file. Returns encoding or None."""
    face_path = settings.FACE_DATA_DIR / f"{employee_id}.pkl"
    if not face_path.exists():
        return None
    with open(face_path, "rb") as f:
        return pickle.load(f)


def compare_faces(known_encoding: np.ndarray, image_bytes: bytes) -> bool:
    """Compare uploaded face image against known encoding.
    Returns True if faces match, False otherwise.
    """
    try:
        image = Image.open(io.BytesIO(image_bytes)).convert("RGB")
        image_array = np.array(image)
        encodings = face_recognition.face_encodings(image_array)
        if len(encodings) == 0:
            return False
        results = face_recognition.compare_faces([known_encoding], encodings[0])
        return results[0]
    except Exception:
        return False


def delete_face(employee_id: int) -> None:
    """Delete face encoding file."""
    face_path = settings.FACE_DATA_DIR / f"{employee_id}.pkl"
    if face_path.exists():
        face_path.unlink()
```

- [ ] **步骤 4：运行测试验证通过**

运行：`cd backend && python -m pytest tests/test_face_service.py -v`
预期：6 passed

- [ ] **步骤 5：提交**

```bash
git add backend/app/services/face_service.py backend/tests/test_face_service.py
git commit -m "feat: implement face recognition service with encode, compare, and delete"
```

---

### 任务 12：打卡服务（策略解析与校验）

**文件：**
- 创建：`backend/app/services/check_service.py`
- 创建：`backend/tests/test_check_service.py`

- [ ] **步骤 1：编写失败测试**

```python
# backend/tests/test_check_service.py
from app.services.check_service import resolve_requirements, is_within_radius


def test_resolve_no_policy_no_override():
    result = resolve_requirements(policy=None, override_face=None, override_location=None,
                                   override_lat=None, override_lng=None, override_radius=None)
    assert result["require_face"] is False
    assert result["require_location"] is False


def test_resolve_policy_only():
    class FakePolicy:
        require_face = True
        require_location = True
        location_lat = 31.23
        location_lng = 121.47
        location_radius = 200.0

    result = resolve_requirements(policy=FakePolicy(), override_face=None, override_location=None,
                                   override_lat=None, override_lng=None, override_radius=None)
    assert result["require_face"] is True
    assert result["require_location"] is True
    assert result["location_lat"] == 31.23


def test_resolve_override_disables_policy():
    class FakePolicy:
        require_face = True
        require_location = True
        location_lat = 31.23
        location_lng = 121.47
        location_radius = 200.0

    result = resolve_requirements(policy=FakePolicy(), override_face=False, override_location=None,
                                   override_lat=None, override_lng=None, override_radius=None)
    assert result["require_face"] is False
    assert result["require_location"] is True


def test_resolve_override_without_policy():
    result = resolve_requirements(policy=None, override_face=None, override_location=True,
                                   override_lat=30.0, override_lng=120.0, override_radius=100.0)
    assert result["require_location"] is True
    assert result["location_lat"] == 30.0


def test_is_within_radius_inside():
    # 约 111 米（纬度差 0.001 度）
    assert is_within_radius(31.230, 121.470, 31.231, 121.470, 200) is True


def test_is_within_radius_outside():
    # 约 111 公里（纬度差 1 度）
    assert is_within_radius(31.0, 121.0, 32.0, 121.0, 200) is False
```

- [ ] **步骤 2：运行测试验证失败**

运行：`cd backend && python -m pytest tests/test_check_service.py -v`
预期：FAIL

- [ ] **步骤 3：编写 check_service.py**

```python
# backend/app/services/check_service.py
import math


def resolve_requirements(
    policy,
    override_face: bool | None,
    override_location: bool | None,
    override_lat: float | None,
    override_lng: float | None,
    override_radius: float | None,
) -> dict:
    """Resolve effective check requirements. Priority: override > policy > default (False)."""
    require_face = False
    require_location = False
    location_lat = None
    location_lng = None
    location_radius = None

    # 应用策略
    if policy is not None:
        require_face = policy.require_face
        require_location = policy.require_location
        location_lat = policy.location_lat
        location_lng = policy.location_lng
        location_radius = policy.location_radius

    # 应用个人覆盖
    if override_face is not None:
        require_face = override_face
    if override_location is not None:
        require_location = override_location
    if override_lat is not None:
        location_lat = override_lat
    if override_lng is not None:
        location_lng = override_lng
    if override_radius is not None:
        location_radius = override_radius

    return {
        "require_face": require_face,
        "require_location": require_location,
        "location_lat": location_lat,
        "location_lng": location_lng,
        "location_radius": location_radius,
    }


def is_within_radius(
    target_lat: float, target_lng: float,
    actual_lat: float, actual_lng: float,
    radius_meters: float,
) -> bool:
    """Check if actual coordinates are within radius of target using Haversine formula."""
    R = 6371000  # 地球半径（米）
    lat1 = math.radians(target_lat)
    lat2 = math.radians(actual_lat)
    dlat = math.radians(actual_lat - target_lat)
    dlng = math.radians(actual_lng - target_lng)

    a = math.sin(dlat / 2) ** 2 + math.cos(lat1) * math.cos(lat2) * math.sin(dlng / 2) ** 2
    c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a))
    distance = R * c

    return distance <= radius_meters
```

- [ ] **步骤 4：运行测试验证通过**

运行：`cd backend && python -m pytest tests/test_check_service.py -v`
预期：6 passed

- [ ] **步骤 5：提交**

```bash
git add backend/app/services/check_service.py backend/tests/test_check_service.py
git commit -m "feat: add check service with policy resolution and radius validation"
```

---

### 任务 13：打卡 API 与员工个人信息

**文件：**
- 创建：`backend/app/api/check.py`
- 创建：`backend/app/api/me.py`
- 创建：`backend/tests/test_check.py`
- 修改：`backend/app/main.py`

- [ ] **步骤 1：编写失败测试**

```python
# backend/tests/test_check.py
import io
from unittest.mock import patch


def test_clock_in(client, employee_headers, seed_active_employee):
    fake_image = io.BytesIO(b"fake face")
    with patch("app.api.check.compare_faces", return_value=True), \
         patch("app.api.check.load_face_encoding", return_value="fake_encoding"):
        resp = client.post(
            "/api/check",
            data={"check_type": "clock_in"},
            files={"face_image": ("face.jpg", fake_image, "image/jpeg")},
            headers=employee_headers,
        )
    assert resp.status_code == 201
    data = resp.json()
    assert data["check_type"] == "clock_in"


def test_clock_in_inactive_employee(client, db):
    from app.core.security import hash_password, create_access_token
    from app.models.employee import Employee, EmployeeStatus

    emp = Employee(name="Pending", username="pend", password_hash=hash_password("p"),
                   status=EmployeeStatus.pending)
    db.add(emp)
    db.commit()
    db.refresh(emp)
    token = create_access_token(subject_id=emp.id, role="employee")
    headers = {"Authorization": f"Bearer {token}"}

    fake_image = io.BytesIO(b"fake face")
    resp = client.post(
        "/api/check",
        data={"check_type": "clock_in"},
        files={"face_image": ("face.jpg", fake_image, "image/jpeg")},
        headers=headers,
    )
    assert resp.status_code == 403


def test_get_today(client, employee_headers):
    resp = client.get("/api/check/today", headers=employee_headers)
    assert resp.status_code == 200
    assert isinstance(resp.json(), list)


def test_get_history(client, employee_headers):
    resp = client.get("/api/check/history", headers=employee_headers)
    assert resp.status_code == 200
    assert isinstance(resp.json(), list)


def test_get_me(client, employee_headers):
    resp = client.get("/api/me", headers=employee_headers)
    assert resp.status_code == 200
    data = resp.json()
    assert "require_face" in data
    assert "require_location" in data
```

- [ ] **步骤 2：运行测试验证失败**

运行：`cd backend && python -m pytest tests/test_check.py -v`
预期：FAIL

- [ ] **步骤 3：编写 check.py**

```python
# backend/app/api/check.py
from datetime import datetime, timezone, date

from fastapi import APIRouter, Depends, File, Form, HTTPException, Query, UploadFile, status
from sqlalchemy.orm import Session

from app.core.deps import get_db, get_current_employee
from app.models.employee import Employee, EmployeeStatus
from app.models.check_record import CheckRecord, CheckType
from app.schemas.check_record import CheckResponse
from app.services.check_service import resolve_requirements, is_within_radius
from app.services.face_service import load_face_encoding, compare_faces

router = APIRouter(prefix="/api/check", tags=["check"])


@router.post("", response_model=CheckResponse, status_code=status.HTTP_201_CREATED)
def check_in(
    check_type: str = Form(...),
    location_lat: float | None = Form(None),
    location_lng: float | None = Form(None),
    face_image: UploadFile = File(None),
    db: Session = Depends(get_db),
    employee: Employee = Depends(get_current_employee),
):
    if employee.status != EmployeeStatus.active:
        raise HTTPException(status_code=403, detail="Only active employees can check in")

    try:
        ct = CheckType(check_type)
    except ValueError:
        raise HTTPException(status_code=400, detail="check_type must be clock_in or clock_out")

    # 解析生效的打卡要求
    reqs = resolve_requirements(
        policy=employee.policy,
        override_face=employee.override_face,
        override_location=employee.override_location,
        override_lat=employee.override_lat,
        override_lng=employee.override_lng,
        override_radius=employee.override_radius,
    )

    face_passed = None
    location_passed = None

    # 人脸校验
    if reqs["require_face"]:
        if face_image is None:
            raise HTTPException(status_code=400, detail="Face image required")
        known_encoding = load_face_encoding(employee.id)
        if known_encoding is None:
            raise HTTPException(status_code=400, detail="No face registered")
        image_bytes = face_image.file.read()
        face_passed = compare_faces(known_encoding, image_bytes)

    # 地点校验
    if reqs["require_location"]:
        if location_lat is None or location_lng is None:
            raise HTTPException(status_code=400, detail="Location required")
        location_passed = is_within_radius(
            reqs["location_lat"], reqs["location_lng"],
            location_lat, location_lng,
            reqs["location_radius"],
        )

    now = datetime.now(timezone.utc)
    record = CheckRecord(
        employee_id=employee.id,
        check_time=now,
        check_type=ct,
        face_passed=face_passed,
        location_lat=location_lat,
        location_lng=location_lng,
        location_passed=location_passed,
    )
    db.add(record)
    db.commit()
    db.refresh(record)
    return record


@router.get("/today", response_model=list[CheckResponse])
def get_today(
    db: Session = Depends(get_db),
    employee: Employee = Depends(get_current_employee),
):
    today_start = datetime.combine(date.today(), datetime.min.time())
    return (
        db.query(CheckRecord)
        .filter(CheckRecord.employee_id == employee.id, CheckRecord.check_time >= today_start)
        .order_by(CheckRecord.check_time)
        .all()
    )


@router.get("/history", response_model=list[CheckResponse])
def get_history(
    start_date: date | None = Query(None),
    end_date: date | None = Query(None),
    db: Session = Depends(get_db),
    employee: Employee = Depends(get_current_employee),
):
    query = db.query(CheckRecord).filter(CheckRecord.employee_id == employee.id)
    if start_date:
        query = query.filter(CheckRecord.check_time >= datetime.combine(start_date, datetime.min.time()))
    if end_date:
        query = query.filter(CheckRecord.check_time <= datetime.combine(end_date, datetime.max.time()))
    return query.order_by(CheckRecord.check_time.desc()).all()
```

- [ ] **步骤 4：编写 me.py**

```python
# backend/app/api/me.py
from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session

from app.core.deps import get_db, get_current_employee
from app.models.employee import Employee
from app.schemas.employee import EmployeeMeResponse
from app.services.check_service import resolve_requirements

router = APIRouter(prefix="/api/me", tags=["me"])


@router.get("", response_model=EmployeeMeResponse)
def get_me(
    db: Session = Depends(get_db),
    employee: Employee = Depends(get_current_employee),
):
    reqs = resolve_requirements(
        policy=employee.policy,
        override_face=employee.override_face,
        override_location=employee.override_location,
        override_lat=employee.override_lat,
        override_lng=employee.override_lng,
        override_radius=employee.override_radius,
    )
    return EmployeeMeResponse(
        id=employee.id,
        name=employee.name,
        username=employee.username,
        status=employee.status.value,
        face_registered=employee.face_registered,
        must_change_password=employee.must_change_password,
        require_face=reqs["require_face"],
        require_location=reqs["require_location"],
        location_lat=reqs["location_lat"],
        location_lng=reqs["location_lng"],
        location_radius=reqs["location_radius"],
    )
```

- [ ] **步骤 5：在 main.py 注册路由**

```python
from app.api import admin_auth, policies, auth, employees, check, me

app.include_router(check.router)
app.include_router(me.router)
```

- [ ] **步骤 6：运行测试验证通过**

运行：`cd backend && python -m pytest tests/test_check.py -v`
预期：5 passed

- [ ] **步骤 7：提交**

```bash
git add backend/app/api/check.py backend/app/api/me.py backend/tests/test_check.py backend/app/main.py
git commit -m "feat: add check-in/out API, today/history endpoints, and employee self-info"
```

---

### 任务 14：管理员查看打卡记录 API

**文件：**
- 创建：`backend/app/api/records.py`
- 创建：`backend/tests/test_records.py`
- 修改：`backend/app/main.py`

- [ ] **步骤 1：编写失败测试**

```python
# backend/tests/test_records.py
from datetime import datetime, timezone

from app.models.check_record import CheckRecord, CheckType


def test_list_records(client, admin_headers, db, seed_active_employee):
    record = CheckRecord(
        employee_id=seed_active_employee.id,
        check_time=datetime.now(timezone.utc),
        check_type=CheckType.clock_in,
    )
    db.add(record)
    db.commit()

    resp = client.get("/api/records", headers=admin_headers)
    assert resp.status_code == 200
    assert len(resp.json()) == 1


def test_list_records_filter_employee(client, admin_headers, db, seed_active_employee):
    record = CheckRecord(
        employee_id=seed_active_employee.id,
        check_time=datetime.now(timezone.utc),
        check_type=CheckType.clock_in,
    )
    db.add(record)
    db.commit()

    resp = client.get(f"/api/records?employee_id={seed_active_employee.id}", headers=admin_headers)
    assert resp.status_code == 200
    assert len(resp.json()) == 1

    resp = client.get("/api/records?employee_id=9999", headers=admin_headers)
    assert resp.status_code == 200
    assert len(resp.json()) == 0


def test_records_requires_admin(client):
    resp = client.get("/api/records")
    assert resp.status_code == 403
```

- [ ] **步骤 2：运行测试验证失败**

运行：`cd backend && python -m pytest tests/test_records.py -v`
预期：FAIL

- [ ] **步骤 3：编写 records.py**

```python
# backend/app/api/records.py
from datetime import date, datetime

from fastapi import APIRouter, Depends, Query
from sqlalchemy.orm import Session

from app.core.deps import get_db, get_current_admin
from app.models.admin import Admin
from app.models.check_record import CheckRecord
from app.schemas.check_record import CheckRecordResponse

router = APIRouter(prefix="/api/records", tags=["records"])


@router.get("", response_model=list[CheckRecordResponse])
def list_records(
    employee_id: int | None = Query(None),
    start_date: date | None = Query(None),
    end_date: date | None = Query(None),
    db: Session = Depends(get_db),
    _admin: Admin = Depends(get_current_admin),
):
    query = db.query(CheckRecord)
    if employee_id is not None:
        query = query.filter(CheckRecord.employee_id == employee_id)
    if start_date:
        query = query.filter(CheckRecord.check_time >= datetime.combine(start_date, datetime.min.time()))
    if end_date:
        query = query.filter(CheckRecord.check_time <= datetime.combine(end_date, datetime.max.time()))
    return query.order_by(CheckRecord.check_time.desc()).all()
```

- [ ] **步骤 4：在 main.py 注册路由**

```python
from app.api import admin_auth, policies, auth, employees, check, me, records

app.include_router(records.router)
```

- [ ] **步骤 5：运行测试验证通过**

运行：`cd backend && python -m pytest tests/test_records.py -v`
预期：3 passed

- [ ] **步骤 6：提交**

```bash
git add backend/app/api/records.py backend/tests/test_records.py backend/app/main.py
git commit -m "feat: add admin check records API with employee and date filters"
```

---

### 任务 15：初始管理员种子与最终 main.py

**文件：**
- 修改：`backend/app/main.py`

- [ ] **步骤 1：更新 main.py，包含管理员种子逻辑和所有路由**

```python
# backend/app/main.py
import logging

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from app.core.database import Base, SessionLocal, engine
from app.core.security import hash_password
from app.models.admin import Admin
from app.api import admin_auth, policies, auth, employees, check, me, records

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

app = FastAPI(title="CheckMan API")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(admin_auth.router)
app.include_router(policies.router)
app.include_router(auth.router)
app.include_router(employees.router)
app.include_router(check.router)
app.include_router(me.router)
app.include_router(records.router)


@app.on_event("startup")
def on_startup():
    Base.metadata.create_all(bind=engine)
    # 如果没有管理员，创建默认管理员
    db = SessionLocal()
    try:
        admin_count = db.query(Admin).count()
        if admin_count == 0:
            admin = Admin(
                username="admin",
                password_hash=hash_password("admin"),
                must_change_password=True,
            )
            db.add(admin)
            db.commit()
            logger.warning("Default admin created (admin/admin). Please change the password!")
    finally:
        db.close()
```

- [ ] **步骤 2：运行全部测试**

运行：`cd backend && python -m pytest tests/ -v`
预期：全部通过

- [ ] **步骤 3：提交**

```bash
git add backend/app/main.py
git commit -m "feat: finalize main.py with all routers and initial admin seeding"
```

---

### 任务 16：Docker 部署配置

**文件：**
- 创建：`backend/Dockerfile`
- 创建：`docker-compose.yml`
- 创建：`nginx/nginx.conf`
- 创建：`nginx/Dockerfile`

- [ ] **步骤 1：创建后端 Dockerfile**

```dockerfile
# backend/Dockerfile
FROM python:3.11-slim

RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential cmake libboost-all-dev libopenblas-dev liblapack-dev \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY . .

RUN mkdir -p face_data

EXPOSE 8000

CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000"]
```

- [ ] **步骤 2：创建 nginx 配置**

```nginx
# nginx/nginx.conf
server {
    listen 80;
    server_name _;

    # React SPA
    location / {
        root /usr/share/nginx/html;
        index index.html;
        try_files $uri $uri/ /index.html;
    }

    # API 反向代理
    location /api {
        proxy_pass http://backend:8000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        client_max_body_size 10M;
    }
}
```

- [ ] **步骤 3：创建 nginx Dockerfile**

```dockerfile
# nginx/Dockerfile
FROM nginx:alpine
COPY nginx.conf /etc/nginx/conf.d/default.conf
# Web 构建产物将在 Web 前端计划中复制进来
```

- [ ] **步骤 4：创建 docker-compose.yml**

```yaml
# docker-compose.yml
version: "3.8"

services:
  backend:
    build: ./backend
    volumes:
      - db_data:/app/checkman.db
      - face_data:/app/face_data
    expose:
      - "8000"
    restart: unless-stopped

  nginx:
    build: ./nginx
    ports:
      - "80:80"
    depends_on:
      - backend
    restart: unless-stopped

volumes:
  db_data:
  face_data:
```

- [ ] **步骤 5：验证 docker-compose 配置有效**

运行：`cd /Users/xbang/code/VScode/CheckMan && docker-compose config`
预期：输出解析后的配置，无错误

- [ ] **步骤 6：提交**

```bash
git add backend/Dockerfile nginx/ docker-compose.yml
git commit -m "feat: add Docker setup (backend, nginx, docker-compose)"
```

---

### 任务 17：完整集成测试

- [ ] **步骤 1：运行全部测试**

运行：`cd backend && python -m pytest tests/ -v --tb=short`
预期：全部通过

- [ ] **步骤 2：本地启动后端进行冒烟测试**

运行：`cd backend && uvicorn app.main:app --port 8000 &`
预期：服务器启动，首次运行输出 "Default admin created"

- [ ] **步骤 3：用 curl 做冒烟测试**

```bash
# 管理员登录
curl -s -X POST http://localhost:8000/api/admin/login \
  -H "Content-Type: application/json" \
  -d '{"username":"admin","password":"admin"}'
# 预期：{"access_token":"...","token_type":"bearer"}
```

- [ ] **步骤 4：停止服务器并清理**

```bash
kill %1
rm -f backend/checkman.db backend/test.db
```

- [ ] **步骤 5：最终提交**

```bash
git add -A
git commit -m "chore: backend implementation complete, all tests passing"
```
