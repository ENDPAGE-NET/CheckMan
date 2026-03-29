from pathlib import Path

BASE_DIR = Path(__file__).resolve().parent.parent.parent

class Settings:
    SECRET_KEY: str = "checkman-dev-secret-key-change-in-production"
    ALGORITHM: str = "HS256"
    ACCESS_TOKEN_EXPIRE_MINUTES: int = 60 * 24  # 24 hours
    DATABASE_URL: str = f"sqlite:///{BASE_DIR / 'checkman.db'}"
    FACE_DATA_DIR: Path = BASE_DIR / "face_data"

settings = Settings()
settings.FACE_DATA_DIR.mkdir(parents=True, exist_ok=True)
