import uuid
from datetime import datetime, timezone
from fastapi import APIRouter, HTTPException, Depends, status
from app.models.schemas import GoogleAuthRequest, DemoAuthRequest, RefreshTokenRequest, TokenResponse, UserProfile
from app.security import verify_google_token, create_access_token, create_refresh_token, decode_token, get_current_user_payload
from app.database import get_database
from app.config import settings

router = APIRouter(prefix="/api/auth", tags=["Authentication"])

def _user_doc_to_profile(doc: dict) -> UserProfile:
    return UserProfile(
        user_id=doc["user_id"],
        google_id=doc.get("google_id"),
        email=doc["email"],
        name=doc["name"],
        username=doc.get("username"),
        profile_image=doc.get("profile_image"),
        university=doc.get("university"),
        department=doc.get("department"),
        degree=doc.get("degree"),
        year=doc.get("year"),
        semester=doc.get("semester"),
        bio=doc.get("bio", ""),
        favorite_genres=doc.get("favorite_genres", []),
        favorite_artists=doc.get("favorite_artists", []),
        liked_songs=doc.get("liked_songs", []),
        study_minutes=doc.get("study_minutes", 0),
        focus_sessions=doc.get("focus_sessions", 0),
        study_streak=doc.get("study_streak", 0),
        achievements=doc.get("achievements", []),
        is_student_artist=doc.get("is_student_artist", False),
        privacy_settings=doc.get("privacy_settings", {
            "share_activity": True,
            "show_on_leaderboard": True,
            "show_recently_played": True
        }),
        created_at=doc.get("created_at"),
        updated_at=doc.get("updated_at")
    )

@router.post("/google", response_model=TokenResponse)
async def login_google(req: GoogleAuthRequest):
    id_info = await verify_google_token(req.id_token)
    email = id_info.get("email")
    if not email:
        raise HTTPException(status_code=400, detail="Google token does not contain an email")
    
    google_id = id_info.get("sub")
    name = id_info.get("name") or email.split("@")[0]
    picture = id_info.get("picture")

    db = get_database()
    now = datetime.now(timezone.utc)
    
    user = await db.users.find_one({"email": email})
    if not user:
        user_id = str(uuid.uuid4())
        user_doc = {
            "user_id": user_id,
            "google_id": google_id,
            "email": email,
            "name": name,
            "username": email.split("@")[0],
            "profile_image": picture,
            "university": "Gauhati University",
            "department": "Computer Science & Engineering",
            "degree": "B.Tech",
            "year": 3,
            "semester": 6,
            "bio": "Studying code and vibing with campus beats.",
            "favorite_genres": ["Lo-Fi", "Electronic", "Ambient", "Indie"],
            "favorite_artists": [],
            "liked_songs": [],
            "study_minutes": 0,
            "focus_sessions": 0,
            "study_streak": 1,
            "achievements": ["Campus Newcomer"],
            "is_student_artist": False,
            "privacy_settings": {
                "share_activity": True,
                "show_on_leaderboard": True,
                "show_recently_played": True
            },
            "created_at": now,
            "updated_at": now
        }
        await db.users.insert_one(user_doc)
        user = user_doc
    else:
        # Update login timestamp
        await db.users.update_one({"email": email}, {"$set": {"updated_at": now}})

    access_token = create_access_token(data={"sub": user["user_id"], "email": user["email"]})
    refresh_token = create_refresh_token(data={"sub": user["user_id"]})

    return TokenResponse(
        access_token=access_token,
        refresh_token=refresh_token,
        token_type="bearer",
        expires_in=settings.JWT_ACCESS_TOKEN_EXPIRE_MINUTES * 60,
        user=_user_doc_to_profile(user)
    )

@router.post("/demo", response_model=TokenResponse)
async def login_demo(req: DemoAuthRequest = DemoAuthRequest()):
    """Instant login endpoint for development testing and onboarding evaluation."""
    db = get_database()
    email = req.email or "student@gauhati.ac.in"
    name = req.name or "Rajdeep Sharma"
    now = datetime.now(timezone.utc)
    
    user = await db.users.find_one({"email": email})
    if not user:
        user_id = str(uuid.uuid4())
        user_doc = {
            "user_id": user_id,
            "google_id": f"demo_{user_id[:8]}",
            "email": email,
            "name": name,
            "username": email.split("@")[0],
            "profile_image": "https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=150",
            "university": req.university or "Gauhati University",
            "department": req.department or "CSE",
            "degree": "B.Tech",
            "year": 3,
            "semester": 6,
            "bio": "Coding, building systems, and focus listening.",
            "favorite_genres": ["Lo-Fi", "Synthwave", "Ambient", "Acoustic"],
            "favorite_artists": [],
            "liked_songs": ["study_lofi_1", "study_lofi_2"],
            "study_minutes": 180,
            "focus_sessions": 6,
            "study_streak": 4,
            "achievements": ["Campus Newcomer", "Focus Initiate", "Night Owl"],
            "is_student_artist": False,
            "privacy_settings": {
                "share_activity": True,
                "show_on_leaderboard": True,
                "show_recently_played": True
            },
            "created_at": now,
            "updated_at": now
        }
        await db.users.insert_one(user_doc)
        user = user_doc

    access_token = create_access_token(data={"sub": user["user_id"], "email": user["email"]})
    refresh_token = create_refresh_token(data={"sub": user["user_id"]})

    return TokenResponse(
        access_token=access_token,
        refresh_token=refresh_token,
        token_type="bearer",
        expires_in=settings.JWT_ACCESS_TOKEN_EXPIRE_MINUTES * 60,
        user=_user_doc_to_profile(user)
    )

@router.post("/refresh", response_model=TokenResponse)
async def refresh_access_token(req: RefreshTokenRequest):
    payload = decode_token(req.refresh_token)
    if payload.get("type") != "refresh":
        raise HTTPException(status_code=400, detail="Invalid token type for refresh")
    
    user_id = payload.get("sub")
    db = get_database()
    user = await db.users.find_one({"user_id": user_id})
    if not user:
        raise HTTPException(status_code=404, detail="User not found")
    
    new_access_token = create_access_token(data={"sub": user["user_id"], "email": user["email"]})
    new_refresh_token = create_refresh_token(data={"sub": user["user_id"]})

    return TokenResponse(
        access_token=new_access_token,
        refresh_token=new_refresh_token,
        token_type="bearer",
        expires_in=settings.JWT_ACCESS_TOKEN_EXPIRE_MINUTES * 60,
        user=_user_doc_to_profile(user)
    )

@router.get("/me", response_model=UserProfile)
async def get_current_user_profile(payload: dict = Depends(get_current_user_payload)):
    db = get_database()
    user = await db.users.find_one({"user_id": payload["sub"]})
    if not user:
        raise HTTPException(status_code=404, detail="User not found")
    return _user_doc_to_profile(user)

@router.post("/logout")
async def logout(payload: dict = Depends(get_current_user_payload)):
    # Stateless JWT - client securely deletes token
    return {"message": "Logged out successfully"}
