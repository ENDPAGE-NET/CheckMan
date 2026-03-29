from __future__ import annotations

import enum
from datetime import datetime, timezone

from sqlalchemy import Boolean, DateTime, Enum, Float, ForeignKey, Integer, String
from sqlalchemy.orm import Mapped, mapped_column, relationship

from app.core.database import Base


class EmployeeStatus(str, enum.Enum):
    pending = "pending"
    active = "active"
    rejected = "rejected"


class Employee(Base):
    __tablename__ = "employees"

    id: Mapped[int] = mapped_column(Integer, primary_key=True, autoincrement=True)
    name: Mapped[str] = mapped_column(String(100), nullable=False)
    username: Mapped[str] = mapped_column(String(50), unique=True, nullable=False)
    password_hash: Mapped[str] = mapped_column(String(128), nullable=False)
    must_change_password: Mapped[bool] = mapped_column(Boolean, default=False)
    status: Mapped[EmployeeStatus] = mapped_column(
        Enum(EmployeeStatus), default=EmployeeStatus.pending
    )
    face_registered: Mapped[bool] = mapped_column(Boolean, default=False)
    policy_id: Mapped[int | None] = mapped_column(
        Integer, ForeignKey("check_policies.id", ondelete="SET NULL"), nullable=True
    )
    override_face: Mapped[bool | None] = mapped_column(Boolean, nullable=True)
    override_location: Mapped[bool | None] = mapped_column(Boolean, nullable=True)
    override_lat: Mapped[float | None] = mapped_column(Float, nullable=True)
    override_lng: Mapped[float | None] = mapped_column(Float, nullable=True)
    override_radius: Mapped[float | None] = mapped_column(Float, nullable=True)
    created_at: Mapped[datetime] = mapped_column(
        DateTime, default=lambda: datetime.now(timezone.utc)
    )

    policy = relationship("CheckPolicy", lazy="joined")
