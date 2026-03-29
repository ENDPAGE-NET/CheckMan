from fastapi.testclient import TestClient


def test_admin_login_returns_must_change_password(client: TestClient, seed_admin):
    res = client.post("/api/admin/login", json={"username": "admin", "password": "admin123"})
    assert res.status_code == 200
    data = res.json()
    assert "must_change_password" in data
    assert data["must_change_password"] is True


def test_admin_change_password_success(client: TestClient, admin_headers):
    res = client.post(
        "/api/admin/change-password",
        json={"old_password": "admin123", "new_password": "newpass123"},
        headers=admin_headers,
    )
    assert res.status_code == 200
    assert res.json()["message"] == "Password changed"

    login_res = client.post("/api/admin/login", json={"username": "admin", "password": "newpass123"})
    assert login_res.status_code == 200
    assert login_res.json()["must_change_password"] is False


def test_admin_change_password_wrong_old(client: TestClient, admin_headers):
    res = client.post(
        "/api/admin/change-password",
        json={"old_password": "wrong", "new_password": "newpass123"},
        headers=admin_headers,
    )
    assert res.status_code == 400


def test_admin_change_password_no_auth(client: TestClient):
    res = client.post(
        "/api/admin/change-password",
        json={"old_password": "admin123", "new_password": "newpass123"},
    )
    assert res.status_code == 403
