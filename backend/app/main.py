import logging
from contextlib import asynccontextmanager
from fastapi import FastAPI, Request
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse

from app.config import settings
from app.database import connect_to_mongo, close_mongo_connection
from app.auth.routes import router as auth_router
from app.users.routes import router as users_router
from app.music.routes import router as music_router
from app.playlists.routes import router as playlists_router
from app.study.routes import router as study_router
from app.community.routes import router as community_router
from app.events.routes import router as events_router
from app.ai.routes import router as ai_router
from app.admin.routes import router as admin_router
from app.app_version.routes import router as version_router

# Setup logging
logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s [%(levelname)s] %(name)s: %(message)s"
)
logger = logging.getLogger("resonance.main")

@asynccontextmanager
async def lifespan(app: FastAPI):
    logger.info("Initializing Resonance Backend...")
    await connect_to_mongo()
    yield
    logger.info("Shutting down Resonance Backend...")
    await close_mongo_connection()

docs_url = "/docs" if settings.ENVIRONMENT != "production" else None
redoc_url = "/redoc" if settings.ENVIRONMENT != "production" else None

app = FastAPI(
    title="Resonance Campus API",
    description="Production-grade API for Resonance - University Music Streaming & Student Platform",
    version=settings.APP_VERSION,
    docs_url=docs_url,
    redoc_url=redoc_url,
    lifespan=lifespan
)

# CORS Configuration
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Global Exception Handler to ensure clean user-facing error formats
@app.exception_handler(Exception)
async def global_exception_handler(request: Request, exc: Exception):
    logger.error(f"Unhandled exception on {request.method} {request.url.path}: {exc}", exc_info=True)
    return JSONResponse(
        status_code=500,
        content={"detail": "An internal error occurred. Please try again later."}
    )

# Include Routers
app.include_router(auth_router)
app.include_router(users_router)
app.include_router(music_router)
app.include_router(playlists_router)
app.include_router(study_router)
app.include_router(community_router)
app.include_router(events_router)
app.include_router(ai_router)
app.include_router(admin_router)
app.include_router(version_router)

@app.get("/health")
async def health_check():
    return {
        "status": "healthy",
        "app": "Resonance",
        "version": settings.APP_VERSION,
        "environment": settings.ENVIRONMENT
    }
