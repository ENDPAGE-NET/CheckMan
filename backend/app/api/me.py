from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session

from app.core.deps import get_db, get_current_employee
from app.models.employee import Employee
from app.schemas.employee import EmployeeMeResponse, EmployeeMeUpdateRequest
from app.services.check_service import resolve_requirements

router = APIRouter(prefix="/api/me", tags=["me"])


def _build_me_response(employee: Employee) -> EmployeeMeResponse:
    reqs = resolve_requirements(
        policy=employee.policy,
        override_face=employee.override_face,
        override_location=employee.override_location,
        override_lat=employee.override_lat,
        override_lng=employee.override_lng,
        override_radius=employee.override_radius,
    )
    return EmployeeMeResponse(
        id=employee.id,
        name=employee.name,
        username=employee.username,
        status=employee.status.value,
        face_registered=employee.face_registered,
        must_change_password=employee.must_change_password,
        require_face=reqs["require_face"],
        require_location=reqs["require_location"],
        location_lat=reqs["location_lat"],
        location_lng=reqs["location_lng"],
        location_radius=reqs["location_radius"],
    )


@router.get("", response_model=EmployeeMeResponse)
def get_me(
    db: Session = Depends(get_db),
    employee: Employee = Depends(get_current_employee),
):
    return _build_me_response(employee)


@router.put("", response_model=EmployeeMeResponse)
def update_me(
    body: EmployeeMeUpdateRequest,
    db: Session = Depends(get_db),
    employee: Employee = Depends(get_current_employee),
):
    name = body.name.strip()
    if not name:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Name cannot be empty",
        )
    if len(name) > 100:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Name is too long",
        )

    employee.name = name
    db.add(employee)
    db.commit()
    db.refresh(employee)
    return _build_me_response(employee)
