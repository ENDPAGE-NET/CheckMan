from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session

from app.core.deps import get_db, get_current_admin
from app.core.security import verify_password, hash_password, create_access_token
from app.models.admin import Admin
from app.schemas.auth import LoginRequest
from app.schemas.admin import AdminLoginResponse, AdminChangePasswordRequest

router = APIRouter(prefix="/api/admin", tags=["admin-auth"])


@router.post("/login", response_model=AdminLoginResponse)
def admin_login(body: LoginRequest, db: Session = Depends(get_db)):
    admin = db.query(Admin).filter(Admin.username == body.username).first()
    if admin is None or not verify_password(body.password, admin.password_hash):
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Invalid credentials")
    token = create_access_token(subject_id=admin.id, role="admin")
    return AdminLoginResponse(
        access_token=token,
        must_change_password=admin.must_change_password,
        username=admin.username,
        is_super=admin.is_super,
    )


@router.post("/change-password")
def admin_change_password(
    body: AdminChangePasswordRequest,
    admin: Admin = Depends(get_current_admin),
    db: Session = Depends(get_db),
):
    if not verify_password(body.old_password, admin.password_hash):
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="Old password incorrect")
    admin.password_hash = hash_password(body.new_password)
    admin.must_change_password = False
    db.commit()
    return {"message": "Password changed"}
