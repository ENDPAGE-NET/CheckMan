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
    admin = Admin(username="admin", password_hash=hash_password("admin123"), is_super=True)
    db.add(admin)
    db.commit()
    db.refresh(admin)
    return admin


@pytest.fixture
def seed_normal_admin(db):
    admin = Admin(username="manager", password_hash=hash_password("mgr123"), is_super=False)
    db.add(admin)
    db.commit()
    db.refresh(admin)
    return admin


@pytest.fixture
def normal_admin_token(seed_normal_admin):
    return create_access_token(subject_id=seed_normal_admin.id, role="admin")


@pytest.fixture
def normal_admin_headers(normal_admin_token):
    return {"Authorization": f"Bearer {normal_admin_token}"}


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
