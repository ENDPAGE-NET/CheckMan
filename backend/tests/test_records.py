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
