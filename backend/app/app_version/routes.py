from fastapi import APIRouter
from app.models.schemas import AppVersionResponse, AndroidVersionInfo
from app.config import settings
from app.database import get_database

router = APIRouter(prefix="/api/app", tags=["Application Version Management"])

@router.get("/version", response_model=AppVersionResponse)
async def get_app_version():
    db = get_database()
    latest_meta = None
    if db is not None:
        try:
            latest_meta = await db.app_versions.find_one(sort=[("created_at", -1)])
        except Exception:
            pass

    if latest_meta:
        return AppVersionResponse(
            latest_version=latest_meta.get("latest_version", settings.APP_VERSION),
            minimum_supported_version=latest_meta.get("minimum_supported_version", settings.MIN_SUPPORTED_VERSION),
            release_notes=latest_meta.get("release_notes", settings.RELEASE_NOTES),
            android=AndroidVersionInfo(
                download_url=latest_meta.get("download_url", settings.APK_DOWNLOAD_URL)
            )
        )

    return AppVersionResponse(
        latest_version=settings.APP_VERSION,
        minimum_supported_version=settings.MIN_SUPPORTED_VERSION,
        release_notes=settings.RELEASE_NOTES,
        android=AndroidVersionInfo(
            download_url=settings.APK_DOWNLOAD_URL
        )
    )
