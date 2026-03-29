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


def test_admin_create_employee(client, admin_headers, seed_admin):
    resp = client.post("/api/employees/create", json={"name": "New Guy", "username": "newguy", "password": "init123"}, headers=admin_headers)
    assert resp.status_code == 201
    data = resp.json()
    assert data["name"] == "New Guy"
    assert data["username"] == "newguy"
    assert data["status"] == "active"
    assert data["must_change_password"] is True
    assert data["face_registered"] is False

def test_admin_create_employee_with_policy(client, admin_headers, seed_admin):
    pol_resp = client.post("/api/policies", json={"name": "TestPolicy"}, headers=admin_headers)
    policy_id = pol_resp.json()["id"]
    resp = client.post("/api/employees/create", json={"name": "Policy Guy", "username": "polguy", "password": "init123", "policy_id": policy_id}, headers=admin_headers)
    assert resp.status_code == 201
    assert resp.json()["policy_id"] == policy_id

def test_admin_create_employee_duplicate_username(client, admin_headers, seed_active_employee, seed_admin):
    resp = client.post("/api/employees/create", json={"name": "Dup", "username": "employee1", "password": "init123"}, headers=admin_headers)
    assert resp.status_code == 409
