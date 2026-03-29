from datetime import datetime

from pydantic import BaseModel


class AdminLoginResponse(BaseModel):
    access_token: str
    token_type: str = "bearer"
    must_change_password: bool
    username: str
    is_super: bool


class AdminChangePasswordRequest(BaseModel):
    old_password: str
    new_password: str


class AdminCreateRequest(BaseModel):
    username: str
    password: str
    is_super: bool = False


class AdminResponse(BaseModel):
    id: int
    username: str
    is_super: bool
    must_change_password: bool
    created_at: datetime
    model_config = {"from_attributes": True}
