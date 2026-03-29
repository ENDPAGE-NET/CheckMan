def test_list_admins(client, admin_headers, seed_admin):
    resp = client.get("/api/admins", headers=admin_headers)
    assert resp.status_code == 200
    data = resp.json()
    assert len(data) >= 1
    assert data[0]["username"] == "admin"
    assert "is_super" in data[0]

def test_list_admins_requires_super(client, normal_admin_headers, seed_normal_admin):
    resp = client.get("/api/admins", headers=normal_admin_headers)
    assert resp.status_code == 403

def test_create_admin(client, admin_headers, seed_admin):
    resp = client.post("/api/admins", json={"username": "newadmin", "password": "pass123", "is_super": False}, headers=admin_headers)
    assert resp.status_code == 201
    data = resp.json()
    assert data["username"] == "newadmin"
    assert data["is_super"] is False
    assert data["must_change_password"] is True

def test_create_admin_duplicate_username(client, admin_headers, seed_admin):
    resp = client.post("/api/admins", json={"username": "admin", "password": "pass123"}, headers=admin_headers)
    assert resp.status_code == 409

def test_create_admin_requires_super(client, normal_admin_headers, seed_normal_admin):
    resp = client.post("/api/admins", json={"username": "x", "password": "p"}, headers=normal_admin_headers)
    assert resp.status_code == 403

def test_delete_admin(client, admin_headers, seed_admin, db):
    from app.core.security import hash_password
    from app.models.admin import Admin
    target = Admin(username="todelete", password_hash=hash_password("p"), is_super=False)
    db.add(target)
    db.commit()
    db.refresh(target)
    resp = client.delete(f"/api/admins/{target.id}", headers=admin_headers)
    assert resp.status_code == 204

def test_delete_self_forbidden(client, admin_headers, seed_admin):
    resp = client.delete(f"/api/admins/{seed_admin.id}", headers=admin_headers)
    assert resp.status_code == 400

def test_reset_admin_password(client, admin_headers, seed_admin, db):
    from app.core.security import hash_password
    from app.models.admin import Admin
    target = Admin(username="resetme", password_hash=hash_password("old"), is_super=False)
    db.add(target)
    db.commit()
    db.refresh(target)
    resp = client.post(f"/api/admins/{target.id}/reset-password", headers=admin_headers)
    assert resp.status_code == 200
    data = resp.json()
    assert "temp_password" in data
