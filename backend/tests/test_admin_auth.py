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


def test_admin_login_returns_username_and_is_super(client, seed_admin):
    resp = client.post("/api/admin/login", json={"username": "admin", "password": "admin123"})
    assert resp.status_code == 200
    data = resp.json()
    assert data["username"] == "admin"
    assert "is_super" in data
