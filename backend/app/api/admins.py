import secrets
import string

from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session

from app.core.deps import get_db, get_current_super_admin
from app.core.security import hash_password
from app.models.admin import Admin
from app.schemas.admin import AdminCreateRequest, AdminResponse

router = APIRouter(prefix="/api/admins", tags=["admins"])


def _generate_temp_password(length: int = 8) -> str:
    chars = string.ascii_letters + string.digits
    return "".join(secrets.choice(chars) for _ in range(length))


@router.get("", response_model=list[AdminResponse])
def list_admins(db: Session = Depends(get_db), _admin: Admin = Depends(get_current_super_admin)):
    return db.query(Admin).order_by(Admin.created_at).all()


@router.post("", response_model=AdminResponse, status_code=status.HTTP_201_CREATED)
def create_admin(body: AdminCreateRequest, db: Session = Depends(get_db), _admin: Admin = Depends(get_current_super_admin)):
    existing = db.query(Admin).filter(Admin.username == body.username).first()
    if existing is not None:
        raise HTTPException(status_code=409, detail="Username already taken")
    admin = Admin(username=body.username, password_hash=hash_password(body.password), is_super=body.is_super, must_change_password=True)
    db.add(admin)
    db.commit()
    db.refresh(admin)
    return admin


@router.delete("/{admin_id}", status_code=status.HTTP_204_NO_CONTENT)
def delete_admin(admin_id: int, db: Session = Depends(get_db), current_admin: Admin = Depends(get_current_super_admin)):
    if admin_id == current_admin.id:
        raise HTTPException(status_code=400, detail="Cannot delete yourself")
    target = db.get(Admin, admin_id)
    if target is None:
        raise HTTPException(status_code=404, detail="Admin not found")
    db.delete(target)
    db.commit()


@router.post("/{admin_id}/reset-password")
def reset_admin_password(admin_id: int, db: Session = Depends(get_db), _admin: Admin = Depends(get_current_super_admin)):
    target = db.get(Admin, admin_id)
    if target is None:
        raise HTTPException(status_code=404, detail="Admin not found")
    temp_password = _generate_temp_password()
    target.password_hash = hash_password(temp_password)
    target.must_change_password = True
    db.commit()
    return {"message": "Password reset", "temp_password": temp_password}
