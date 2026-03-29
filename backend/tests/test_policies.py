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
