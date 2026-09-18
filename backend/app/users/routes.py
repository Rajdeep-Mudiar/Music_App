from datetime import datetime, timezone
from typing import List, Dict, Any
from fastapi import APIRouter, HTTPException, Depends
from app.models.schemas import UserProfile, OnboardingRequest
from app.security import get_current_user_payload
from app.database import get_database
from app.auth.routes import _user_doc_to_profile

router = APIRouter(prefix="/api/users", tags=["Users"])

@router.put("/profile", response_model=UserProfile)
async def update_profile(updates: Dict[str, Any], payload: dict = Depends(get_current_user_payload)):
    db = get_database()
    allowed_fields = ["name", "bio", "favorite_genres", "favorite_artists", "privacy_settings", "profile_image"]
    filtered_updates = {k: v for k, v in updates.items() if k in allowed_fields}
    filtered_updates["updated_at"] = datetime.now(timezone.utc)

    result = await db.users.find_one_and_update(
        {"user_id": payload["sub"]},
        {"$set": filtered_updates},
        return_document=True
    )
    if not result:
        raise HTTPException(status_code=404, detail="User not found")
    return _user_doc_to_profile(result)

@router.post("/onboarding", response_model=UserProfile)
async def complete_onboarding(req: OnboardingRequest, payload: dict = Depends(get_current_user_payload)):
    db = get_database()
    update_data = {
        "university": req.university,
        "department": req.department,
        "degree": req.degree,
        "year": req.year,
        "semester": req.semester,
        "updated_at": datetime.now(timezone.utc)
    }
    if req.username:
        update_data["username"] = req.username
    if req.bio:
        update_data["bio"] = req.bio
    if req.favorite_genres:
        update_data["favorite_genres"] = req.favorite_genres

    result = await db.users.find_one_and_update(
        {"user_id": payload["sub"]},
        {"$set": update_data},
        return_document=True
    )
    if not result:
        raise HTTPException(status_code=404, detail="User not found")
    return _user_doc_to_profile(result)

@router.get("/{user_id}", response_model=UserProfile)
async def get_user_profile(user_id: str):
    db = get_database()
    user = await db.users.find_one({"user_id": user_id})
    if not user:
        raise HTTPException(status_code=404, detail="User not found")
    return _user_doc_to_profile(user)

@router.post("/{target_user_id}/follow")
async def follow_user(target_user_id: str, payload: dict = Depends(get_current_user_payload)):
    current_id = payload["sub"]
    if current_id == target_user_id:
        raise HTTPException(status_code=400, detail="Cannot follow yourself")
    db = get_database()
    await db.users.update_one({"user_id": current_id}, {"$addToSet": {"following": target_user_id}})
    await db.users.update_one({"user_id": target_user_id}, {"$addToSet": {"followers": current_id}})
    return {"message": "Followed successfully"}

@router.post("/{target_user_id}/unfollow")
async def unfollow_user(target_user_id: str, payload: dict = Depends(get_current_user_payload)):
    current_id = payload["sub"]
    db = get_database()
    await db.users.update_one({"user_id": current_id}, {"$pull": {"following": target_user_id}})
    await db.users.update_one({"user_id": target_user_id}, {"$pull": {"followers": current_id}})
    return {"message": "Unfollowed successfully"}

@router.get("/music-match/{target_user_id}")
async def get_music_match(target_user_id: str, payload: dict = Depends(get_current_user_payload)):
    """
    Computes student music match score based on common genres, liked songs, and study preferences.
    """
    current_id = payload["sub"]
    db = get_database()
    u1 = await db.users.find_one({"user_id": current_id})
    u2 = await db.users.find_one({"user_id": target_user_id})
    if not u1 or not u2:
        raise HTTPException(status_code=404, detail="One or both users not found")

    genres1 = set(g.lower() for g in u1.get("favorite_genres", []))
    genres2 = set(g.lower() for g in u2.get("favorite_genres", []))
    common_genres = list(genres1.intersection(genres2))

    songs1 = set(u1.get("liked_songs", []))
    songs2 = set(u2.get("liked_songs", []))
    common_songs = list(songs1.intersection(songs2))

    # Base score calculation
    match_pct = 50
    if genres1 and genres2:
        genre_overlap = len(common_genres) / max(len(genres1.union(genres2)), 1)
        match_pct += int(genre_overlap * 35)
    if common_songs:
        match_pct += min(len(common_songs) * 5, 15)
    
    match_pct = min(match_pct, 98)

    return {
        "user_name": u2.get("name"),
        "match_percentage": match_pct,
        "common_genres": common_genres or ["Lo-Fi", "Focus"],
        "common_songs_count": len(common_songs),
        "vibe": "Campus Focus Duo" if match_pct > 80 else "Eclectic Beats Match"
    }
