def test_update_me_name(client, employee_headers, seed_active_employee):
    resp = client.put(
        "/api/me",
        json={"name": "产品小王"},
        headers=employee_headers,
    )

    assert resp.status_code == 200
    data = resp.json()
    assert data["name"] == "产品小王"
    assert data["username"] == seed_active_employee.username


def test_update_me_name_rejects_blank_value(client, employee_headers):
    resp = client.put(
        "/api/me",
        json={"name": "   "},
        headers=employee_headers,
    )

    assert resp.status_code == 400
    assert resp.json()["detail"] == "Name cannot be empty"
