from datetime import datetime, timezone, date

from fastapi import APIRouter, Depends, File, Form, HTTPException, Query, UploadFile, status
from sqlalchemy.orm import Session

from app.core.deps import get_db, get_current_employee
from app.models.employee import Employee, EmployeeStatus
from app.models.check_record import CheckRecord, CheckType
from app.schemas.check_record import CheckResponse
from app.services.check_service import resolve_requirements, is_within_radius
from app.services.face_service import load_face_encoding, compare_faces

router = APIRouter(prefix="/api/check", tags=["check"])


@router.post("", response_model=CheckResponse, status_code=status.HTTP_201_CREATED)
def check_in(
    check_type: str = Form(...),
    location_lat: float | None = Form(None),
    location_lng: float | None = Form(None),
    face_image: UploadFile = File(None),
    db: Session = Depends(get_db),
    employee: Employee = Depends(get_current_employee),
):
    if employee.status != EmployeeStatus.active:
        raise HTTPException(status_code=403, detail="Only active employees can check in")

    try:
        ct = CheckType(check_type)
    except ValueError:
        raise HTTPException(status_code=400, detail="check_type must be clock_in or clock_out")

    reqs = resolve_requirements(
        policy=employee.policy,
        override_face=employee.override_face,
        override_location=employee.override_location,
        override_lat=employee.override_lat,
        override_lng=employee.override_lng,
        override_radius=employee.override_radius,
    )

    face_passed = None
    location_passed = None

    if reqs["require_face"]:
        if face_image is None:
            raise HTTPException(status_code=400, detail="Face image required")
        known_encoding = load_face_encoding(employee.id)
        if known_encoding is None:
            raise HTTPException(status_code=400, detail="No face registered")
        image_bytes = face_image.file.read()
        face_passed = compare_faces(known_encoding, image_bytes)

    if reqs["require_location"]:
        if location_lat is None or location_lng is None:
            raise HTTPException(status_code=400, detail="Location required")
        location_passed = is_within_radius(
            reqs["location_lat"], reqs["location_lng"],
            location_lat, location_lng,
            reqs["location_radius"],
        )

    # 验证失败时拒绝打卡
    if face_passed is False:
        raise HTTPException(status_code=400, detail="人脸验证未通过")
    if location_passed is False:
        raise HTTPException(status_code=400, detail="位置验证未通过，不在打卡范围内")

    now = datetime.now(timezone.utc)
    record = CheckRecord(
        employee_id=employee.id,
        check_time=now,
        check_type=ct,
        face_passed=face_passed,
        location_lat=location_lat,
        location_lng=location_lng,
        location_passed=location_passed,
    )
    db.add(record)
    db.commit()
    db.refresh(record)
    return record


@router.get("/today", response_model=list[CheckResponse])
def get_today(
    db: Session = Depends(get_db),
    employee: Employee = Depends(get_current_employee),
):
    today_start = datetime.combine(date.today(), datetime.min.time())
    return (
        db.query(CheckRecord)
        .filter(CheckRecord.employee_id == employee.id, CheckRecord.check_time >= today_start)
        .order_by(CheckRecord.check_time)
        .all()
    )


@router.get("/history", response_model=list[CheckResponse])
def get_history(
    start_date: date | None = Query(None),
    end_date: date | None = Query(None),
    db: Session = Depends(get_db),
    employee: Employee = Depends(get_current_employee),
):
    query = db.query(CheckRecord).filter(CheckRecord.employee_id == employee.id)
    if start_date:
        query = query.filter(CheckRecord.check_time >= datetime.combine(start_date, datetime.min.time()))
    if end_date:
        query = query.filter(CheckRecord.check_time <= datetime.combine(end_date, datetime.max.time()))
    return query.order_by(CheckRecord.check_time.desc()).all()
