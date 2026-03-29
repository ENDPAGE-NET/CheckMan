from fastapi import APIRouter, Depends, File, Form, HTTPException, UploadFile, status
from sqlalchemy.orm import Session

from app.core.deps import get_db, get_current_employee
from app.core.security import hash_password, verify_password, create_access_token
from app.models.employee import Employee, EmployeeStatus
from app.schemas.auth import ChangePasswordRequest, EmployeeLoginResponse, LoginRequest
from app.schemas.employee import EmployeeResponse
from app.services.face_service import encode_and_save_face

router = APIRouter(prefix="/api/auth", tags=["employee-auth"])


@router.post("/register", response_model=EmployeeResponse, status_code=status.HTTP_201_CREATED)
def register(
    name: str = Form(...),
    username: str = Form(...),
    password: str = Form(...),
    face_image: UploadFile = File(...),
    db: Session = Depends(get_db),
):
    existing = db.query(Employee).filter(Employee.username == username).first()
    if existing is not None:
        if existing.status == EmployeeStatus.rejected:
            db.delete(existing)
            db.flush()
        else:
            raise HTTPException(status_code=409, detail="Username already taken")

    employee = Employee(
        name=name,
        username=username,
        password_hash=hash_password(password),
        status=EmployeeStatus.pending,
        face_registered=False,
    )
    db.add(employee)
    db.commit()
    db.refresh(employee)

    image_bytes = face_image.file.read()
    success = encode_and_save_face(employee.id, image_bytes)
    if success:
        employee.face_registered = True
        db.commit()
        db.refresh(employee)

    return employee


@router.post("/login", response_model=EmployeeLoginResponse)
def login(body: LoginRequest, db: Session = Depends(get_db)):
    employee = db.query(Employee).filter(Employee.username == body.username).first()
    if employee is None or not verify_password(body.password, employee.password_hash):
        raise HTTPException(status_code=401, detail="Invalid credentials")
    token = create_access_token(subject_id=employee.id, role="employee")
    return EmployeeLoginResponse(
        access_token=token,
        status=employee.status.value,
        must_change_password=employee.must_change_password,
        face_registered=employee.face_registered,
    )


@router.post("/change-password")
def change_password(
    body: ChangePasswordRequest,
    db: Session = Depends(get_db),
    employee: Employee = Depends(get_current_employee),
):
    if not verify_password(body.old_password, employee.password_hash):
        raise HTTPException(status_code=400, detail="Old password incorrect")
    employee.password_hash = hash_password(body.new_password)
    employee.must_change_password = False
    db.commit()
    return {"message": "Password changed"}


@router.post("/register-face")
def register_face(
    face_image: UploadFile = File(...),
    db: Session = Depends(get_db),
    employee: Employee = Depends(get_current_employee),
):
    image_bytes = face_image.file.read()
    success = encode_and_save_face(employee.id, image_bytes)
    if not success:
        raise HTTPException(status_code=400, detail="No face detected in image")
    employee.face_registered = True
    db.commit()
    return {"message": "Face registered"}
