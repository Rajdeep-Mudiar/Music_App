import os
from pydantic_settings import BaseSettings, SettingsConfigDict
from typing import Optional

class Settings(BaseSettings):
    model_config = SettingsConfigDict(env_file=".env", extra="ignore")

    ENVIRONMENT: str = "development"
    PORT: int = 8000
    HOST: str = "0.0.0.0"
    
    MONGO_URI: str = "mongodb://localhost:27017"
    MONGO_DB_NAME: str = "resonance_db"
    
    JWT_SECRET: str = "resonance_super_secret_jwt_key_for_dev_32chars"
    JWT_ALGORITHM: str = "HS256"
    JWT_ACCESS_TOKEN_EXPIRE_MINUTES: int = 30
    JWT_REFRESH_TOKEN_EXPIRE_DAYS: int = 30
    
    GOOGLE_CLIENT_ID: Optional[str] = None
    GOOGLE_CLIENT_SECRET: Optional[str] = None
    
    AUDIUS_APP_NAME: str = "ResonanceCampus"
    
    APP_VERSION: str = "1.0.0"
    MIN_SUPPORTED_VERSION: str = "1.0.0"
    APK_DOWNLOAD_URL: str = "https://github.com/resonance-app/resonance/releases/latest/download/app-release.apk"
    RELEASE_NOTES: str = "Initial release of Resonance with Music Streaming, Campus Communities, and Study Mode."

settings = Settings()
