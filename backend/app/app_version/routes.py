import time
import httpx
from fastapi import APIRouter
from app.models.schemas import AppVersionResponse, AndroidVersionInfo
from app.config import settings
from app.database import get_database

router = APIRouter(prefix="/api/app", tags=["Application Version Management"])

# In-memory cache for GitHub release data (TTL = 300 seconds)
_cached_release: dict = {}
_cached_at: float = 0

async def _fetch_github_latest_release() -> dict:
    global _cached_release, _cached_at
    now = time.time()
    if _cached_release and (now - _cached_at < 300):
        return _cached_release

    try:
        async with httpx.AsyncClient(timeout=4.0) as client:
            res = await client.get(
                "https://api.github.com/repos/Rajdeep-Mudiar/Music_App/releases/latest",
                headers={"User-Agent": "Resonance-Backend-Service"}
            )
            if res.status_code == 200:
                data = res.json()
                tag = data.get("tag_name", "").lstrip("v")
                body = data.get("body", "").strip()
                download_url = settings.APK_DOWNLOAD_URL
                for asset in data.get("assets", []):
                    if asset.get("name", "").endswith(".apk"):
                        download_url = asset.get("browser_download_url", download_url)
                        break

                if tag:
                    _cached_release = {
                        "latest_version": tag,
                        "release_notes": body if body else f"New features and stability updates in version {tag}.",
                        "download_url": download_url
                    }
                    _cached_at = now
                    return _cached_release
    except Exception:
        pass

    return _cached_release

@router.get("/version", response_model=AppVersionResponse)
async def get_app_version():
    # 1. Check if a newer version is published on GitHub Releases automatically
    gh_release = await _fetch_github_latest_release()
    latest_version = gh_release.get("latest_version") if gh_release else settings.APP_VERSION
    release_notes = gh_release.get("release_notes") if gh_release else settings.RELEASE_NOTES
    download_url = gh_release.get("download_url") if gh_release else settings.APK_DOWNLOAD_URL

    # 2. Check MongoDB overrides if present
    db = get_database()
    if db is not None:
        try:
            latest_meta = await db.app_versions.find_one(sort=[("created_at", -1)])
            if latest_meta:
                latest_version = latest_meta.get("latest_version", latest_version)
                release_notes = latest_meta.get("release_notes", release_notes)
                download_url = latest_meta.get("download_url", download_url)
        except Exception:
            pass

    return AppVersionResponse(
        latest_version=latest_version,
        minimum_supported_version=settings.MIN_SUPPORTED_VERSION,
        release_notes=release_notes,
        android=AndroidVersionInfo(
            download_url=download_url
        )
    )
