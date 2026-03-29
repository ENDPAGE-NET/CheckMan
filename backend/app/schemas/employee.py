from datetime import datetime

from pydantic import BaseModel


class EmployeeResponse(BaseModel):
    id: int
    name: str
    username: str
    status: str
    face_registered: bool
    must_change_password: bool
    policy_id: int | None
    override_face: bool | None
    override_location: bool | None
    override_lat: float | None
    override_lng: float | None
    override_radius: float | None
    created_at: datetime

    model_config = {"from_attributes": True}


class EmployeeUpdateRequest(BaseModel):
    name: str | None = None
    policy_id: int | None = None
    override_face: bool | None = None
    override_location: bool | None = None
    override_lat: float | None = None
    override_lng: float | None = None
    override_radius: float | None = None


class EmployeeMeResponse(BaseModel):
    id: int
    name: str
    username: str
    status: str
    face_registered: bool
    must_change_password: bool
    require_face: bool
    require_location: bool
    location_lat: float | None
    location_lng: float | None
    location_radius: float | None


class EmployeeMeUpdateRequest(BaseModel):
    name: str


class EmployeeCreateRequest(BaseModel):
    name: str
    username: str
    password: str
    policy_id: int | None = None
