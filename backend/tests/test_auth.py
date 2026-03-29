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
