from pydantic import BaseModel


class LoginRequest(BaseModel):
    username: str
    password: str


class TokenResponse(BaseModel):
    access_token: str
    token_type: str = "bearer"


class RegisterRequest(BaseModel):
    name: str
    username: str
    password: str


class ChangePasswordRequest(BaseModel):
    old_password: str
    new_password: str


class EmployeeLoginResponse(BaseModel):
    access_token: str
    token_type: str = "bearer"
    status: str
    must_change_password: bool
    face_registered: bool
