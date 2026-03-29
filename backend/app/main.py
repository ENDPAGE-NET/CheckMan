import logging

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from app.core.database import Base, SessionLocal, engine
from app.core.security import hash_password
from app.models.admin import Admin
from app.api import admin_auth, admins, policies, auth, employees, check, me, records

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

app = FastAPI(title="CheckMan API")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(admin_auth.router)
app.include_router(admins.router)
app.include_router(policies.router)
app.include_router(auth.router)
app.include_router(employees.router)
app.include_router(check.router)
app.include_router(me.router)
app.include_router(records.router)


@app.on_event("startup")
def on_startup():
    Base.metadata.create_all(bind=engine)
    db = SessionLocal()
    try:
        admin_count = db.query(Admin).count()
        if admin_count == 0:
            admin = Admin(
                username="admin",
                password_hash=hash_password("admin"),
                must_change_password=True,
                is_super=True,
            )
            db.add(admin)
            db.commit()
            logger.warning("Default admin created (admin/admin). Please change the password!")
    finally:
        db.close()
