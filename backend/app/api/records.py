from datetime import date, datetime

from fastapi import APIRouter, Depends, Query
from sqlalchemy.orm import Session

from app.core.deps import get_db, get_current_admin
from app.models.admin import Admin
from app.models.check_record import CheckRecord
from app.schemas.check_record import CheckRecordResponse

router = APIRouter(prefix="/api/records", tags=["records"])


@router.get("", response_model=list[CheckRecordResponse])
def list_records(
    employee_id: int | None = Query(None),
    start_date: date | None = Query(None),
    end_date: date | None = Query(None),
    db: Session = Depends(get_db),
    _admin: Admin = Depends(get_current_admin),
):
    query = db.query(CheckRecord)
    if employee_id is not None:
        query = query.filter(CheckRecord.employee_id == employee_id)
    if start_date:
        query = query.filter(CheckRecord.check_time >= datetime.combine(start_date, datetime.min.time()))
    if end_date:
        query = query.filter(CheckRecord.check_time <= datetime.combine(end_date, datetime.max.time()))
    return query.order_by(CheckRecord.check_time.desc()).all()
