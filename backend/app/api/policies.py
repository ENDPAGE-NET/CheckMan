from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session

from app.core.deps import get_db, get_current_admin
from app.models.admin import Admin
from app.models.check_policy import CheckPolicy
from app.schemas.check_policy import PolicyCreateRequest, PolicyUpdateRequest, PolicyResponse

router = APIRouter(prefix="/api/policies", tags=["policies"])


@router.get("", response_model=list[PolicyResponse])
def list_policies(db: Session = Depends(get_db), _admin: Admin = Depends(get_current_admin)):
    return db.query(CheckPolicy).all()


@router.post("", response_model=PolicyResponse, status_code=status.HTTP_201_CREATED)
def create_policy(
    body: PolicyCreateRequest,
    db: Session = Depends(get_db),
    _admin: Admin = Depends(get_current_admin),
):
    policy = CheckPolicy(**body.model_dump())
    db.add(policy)
    db.commit()
    db.refresh(policy)
    return policy


@router.put("/{policy_id}", response_model=PolicyResponse)
def update_policy(
    policy_id: int,
    body: PolicyUpdateRequest,
    db: Session = Depends(get_db),
    _admin: Admin = Depends(get_current_admin),
):
    policy = db.get(CheckPolicy, policy_id)
    if policy is None:
        raise HTTPException(status_code=404, detail="Policy not found")
    for key, value in body.model_dump(exclude_unset=True).items():
        setattr(policy, key, value)
    db.commit()
    db.refresh(policy)
    return policy


@router.delete("/{policy_id}", status_code=status.HTTP_204_NO_CONTENT)
def delete_policy(
    policy_id: int,
    db: Session = Depends(get_db),
    _admin: Admin = Depends(get_current_admin),
):
    policy = db.get(CheckPolicy, policy_id)
    if policy is None:
        raise HTTPException(status_code=404, detail="Policy not found")
    db.delete(policy)
    db.commit()
