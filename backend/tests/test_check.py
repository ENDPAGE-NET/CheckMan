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


def test_check_response_uses_timezone_aware_timestamp(
    client, employee_headers, seed_active_employee
):
    resp = client.post(
        "/api/check",
        data={"check_type": "clock_in"},
        headers=employee_headers,
    )

    assert resp.status_code == 201
    assert resp.json()["check_time"].endswith("Z")


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
