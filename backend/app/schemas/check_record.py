from datetime import datetime, timezone

from pydantic import BaseModel, field_serializer, field_validator


def _normalize_utc_datetime(value: datetime) -> datetime:
    if value.tzinfo is None:
        return value.replace(tzinfo=timezone.utc)
    return value.astimezone(timezone.utc)


class CheckRequest(BaseModel):
    check_type: str
    location_lat: float | None = None
    location_lng: float | None = None


class CheckResponse(BaseModel):
    id: int
    check_time: datetime
    check_type: str
    face_passed: bool | None
    location_lat: float | None
    location_lng: float | None
    location_passed: bool | None

    @field_validator("check_time", mode="before")
    @classmethod
    def validate_check_time(cls, value: datetime) -> datetime:
        return _normalize_utc_datetime(value)

    @field_serializer("check_time")
    def serialize_check_time(self, value: datetime) -> str:
        return _normalize_utc_datetime(value).isoformat().replace("+00:00", "Z")

    model_config = {"from_attributes": True}


class CheckRecordResponse(BaseModel):
    id: int
    employee_id: int
    check_time: datetime
    check_type: str
    face_passed: bool | None
    location_lat: float | None
    location_lng: float | None
    location_passed: bool | None
    created_at: datetime

    @field_validator("check_time", "created_at", mode="before")
    @classmethod
    def validate_datetimes(cls, value: datetime) -> datetime:
        return _normalize_utc_datetime(value)

    @field_serializer("check_time", "created_at")
    def serialize_datetimes(self, value: datetime) -> str:
        return _normalize_utc_datetime(value).isoformat().replace("+00:00", "Z")

    model_config = {"from_attributes": True}
