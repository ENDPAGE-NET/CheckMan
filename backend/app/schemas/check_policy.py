from datetime import datetime

from pydantic import BaseModel


class PolicyCreateRequest(BaseModel):
    name: str
    require_face: bool = False
    require_location: bool = False
    location_lat: float | None = None
    location_lng: float | None = None
    location_radius: float | None = None


class PolicyUpdateRequest(BaseModel):
    name: str | None = None
    require_face: bool | None = None
    require_location: bool | None = None
    location_lat: float | None = None
    location_lng: float | None = None
    location_radius: float | None = None


class PolicyResponse(BaseModel):
    id: int
    name: str
    require_face: bool
    require_location: bool
    location_lat: float | None
    location_lng: float | None
    location_radius: float | None
    created_at: datetime

    model_config = {"from_attributes": True}
