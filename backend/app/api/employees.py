import secrets
import string

from fastapi import APIRouter, Depends, HTTPException, Query, status
from sqlalchemy.orm import Session

from app.core.deps import get_db, get_current_admin
from app.core.security import hash_password
from app.models.admin import Admin
from app.models.employee import Employee, EmployeeStatus
from app.schemas.employee import EmployeeResponse, EmployeeUpdateRequest, EmployeeCreateRequest
from app.services.face_service import delete_face

router = APIRouter(prefix="/api/employees", tags=["employees"])


def _generate_temp_password(length: int = 8) -> str:
    chars = string.ascii_letters + string.digits
    return "".join(secrets.choice(chars) for _ in range(length))


@router.get("", response_model=list[EmployeeResponse])
def list_employees(
    status_filter: EmployeeStatus | None = Query(None, alias="status"),
    name: str | None = Query(None),
    db: Session = Depends(get_db),
    _admin: Admin = Depends(get_current_admin),
):
    query = db.query(Employee)
    if status_filter is not None:
        query = query.filter(Employee.status == status_filter)
    if name is not None:
        query = query.filter(Employee.name.contains(name))
    return query.all()


@router.post("/create", response_model=EmployeeResponse, status_code=status.HTTP_201_CREATED)
def admin_create_employee(
    body: EmployeeCreateRequest,
    db: Session = Depends(get_db),
    _admin: Admin = Depends(get_current_admin),
):
    existing = db.query(Employee).filter(Employee.username == body.username).first()
    if existing is not None:
        raise HTTPException(status_code=409, detail="Username already taken")
    employee = Employee(
        name=body.name,
        username=body.username,
        password_hash=hash_password(body.password),
        status=EmployeeStatus.active,
        must_change_password=True,
        face_registered=False,
        policy_id=body.policy_id,
    )
    db.add(employee)
    db.commit()
    db.refresh(employee)
    return employee


@router.post("/{employee_id}/approve", response_model=EmployeeResponse)
def approve_employee(
    employee_id: int,
    db: Session = Depends(get_db),
    _admin: Admin = Depends(get_current_admin),
):
    emp = db.get(Employee, employee_id)
    if emp is None:
        raise HTTPException(status_code=404, detail="Employee not found")
    if emp.status != EmployeeStatus.pending:
        raise HTTPException(status_code=400, detail="Can only approve pending employees")
    emp.status = EmployeeStatus.active
    db.commit()
    db.refresh(emp)
    return emp


@router.post("/{employee_id}/reject", response_model=EmployeeResponse)
def reject_employee(
    employee_id: int,
    db: Session = Depends(get_db),
    _admin: Admin = Depends(get_current_admin),
):
    emp = db.get(Employee, employee_id)
    if emp is None:
        raise HTTPException(status_code=404, detail="Employee not found")
    if emp.status != EmployeeStatus.pending:
        raise HTTPException(status_code=400, detail="Can only reject pending employees")
    emp.status = EmployeeStatus.rejected
    db.commit()
    db.refresh(emp)
    return emp


@router.put("/{employee_id}", response_model=EmployeeResponse)
def update_employee(
    employee_id: int,
    body: EmployeeUpdateRequest,
    db: Session = Depends(get_db),
    _admin: Admin = Depends(get_current_admin),
):
    emp = db.get(Employee, employee_id)
    if emp is None:
        raise HTTPException(status_code=404, detail="Employee not found")
    for key, value in body.model_dump(exclude_unset=True).items():
        setattr(emp, key, value)
    db.commit()
    db.refresh(emp)
    return emp


@router.delete("/{employee_id}", status_code=status.HTTP_204_NO_CONTENT)
def delete_employee(
    employee_id: int,
    db: Session = Depends(get_db),
    _admin: Admin = Depends(get_current_admin),
):
    emp = db.get(Employee, employee_id)
    if emp is None:
        raise HTTPException(status_code=404, detail="Employee not found")
    delete_face(emp.id)
    db.delete(emp)
    db.commit()


@router.post("/{employee_id}/reset-password")
def reset_password(
    employee_id: int,
    db: Session = Depends(get_db),
    _admin: Admin = Depends(get_current_admin),
):
    emp = db.get(Employee, employee_id)
    if emp is None:
        raise HTTPException(status_code=404, detail="Employee not found")
    temp_password = _generate_temp_password()
    emp.password_hash = hash_password(temp_password)
    emp.must_change_password = True
    db.commit()
    return {"message": "Password reset", "temp_password": temp_password}


@router.post("/{employee_id}/reset-face")
def reset_face(
    employee_id: int,
    db: Session = Depends(get_db),
    _admin: Admin = Depends(get_current_admin),
):
    emp = db.get(Employee, employee_id)
    if emp is None:
        raise HTTPException(status_code=404, detail="Employee not found")
    delete_face(emp.id)
    emp.face_registered = False
    db.commit()
    return {"message": "Face data reset"}
