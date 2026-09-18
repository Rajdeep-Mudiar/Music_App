import os
from pathlib import Path
from pydantic_settings import BaseSettings, SettingsConfigDict
from typing import Optional

# Resolve root directory of the repository where the root .env resides
ROOT_DIR = Path(__file__).resolve().parent.parent.parent
ROOT_ENV_FILE = ROOT_DIR / ".env"
BACKEND_ENV_FILE = Path(__file__).resolve().parent.parent / ".env"

class Settings(BaseSettings):
    model_config = SettingsConfigDict(
        env_file=[str(ROOT_ENV_FILE), str(BACKEND_ENV_FILE), ".env"],
        extra="ignore",
        env_file_encoding="utf-8",
    )

    ENVIRONMENT: str = "development"
    PORT: int = 8000
    HOST: str = "0.0.0.0"
    
    MONGO_URI: str = "mongodb://localhost:27017"
    MONGO_DB_NAME: str = "resonance_db"
    
    # Loaded from root .env; has safe dev fallback for test runners / CI
    JWT_SECRET: str = "resonance_dev_jwt_secret_override_in_env_32chars"
    JWT_ALGORITHM: str = "HS256"
    JWT_ACCESS_TOKEN_EXPIRE_MINUTES: int = 30
    JWT_REFRESH_TOKEN_EXPIRE_DAYS: int = 30
    
    GOOGLE_CLIENT_ID: Optional[str] = None
    GOOGLE_CLIENT_SECRET: Optional[str] = None
    
    AUDIUS_APP_NAME: str = "ResonanceCampus"
    
    APP_VERSION: str = "1.0.0"
    MIN_SUPPORTED_VERSION: str = "1.0.0"
    APK_DOWNLOAD_URL: str = "https://github.com/Rajdeep-Mudiar/Music_App/releases/latest/download/app-release.apk"
    RELEASE_NOTES: str = "Initial release of Resonance with Music Streaming, Campus Communities, and Study Mode."

settings = Settings()
