from typing import List, Optional
from fastapi import APIRouter, HTTPException, Query, Depends
from datetime import datetime, timezone
from app.models.schemas import Track, Artist
from app.music.music_repository import music_repository
from app.security import get_optional_user_payload, get_current_user_payload
from app.database import get_database

router = APIRouter(prefix="/api/music", tags=["Music"])

@router.get("/trending", response_model=List[Track])
async def get_trending_tracks(limit: int = Query(20, ge=1, le=50)):
    return await music_repository.get_trending(limit=limit)

@router.get("/search", response_model=List[Track])
async def search_tracks(q: str = Query(..., min_length=1), limit: int = Query(20, ge=1, le=50)):
    return await music_repository.search(q, limit=limit)

@router.get("/study-tracks", response_model=List[Track])
async def get_study_tracks(vibe: str = Query("lofi"), limit: int = Query(20, ge=1, le=50)):
    return await music_repository.get_study_tracks(vibe=vibe, limit=limit)

@router.get("/tracks/{track_id}", response_model=Track)
async def get_track_detail(track_id: str):
    track = await music_repository.get_track(track_id)
    if not track:
        raise HTTPException(status_code=404, detail="Track not found")
    return track

@router.get("/tracks/{track_id}/stream")
async def get_track_stream(track_id: str):
    url = await music_repository.get_stream_url(track_id)
    return {"stream_url": url}

@router.get("/artists/{artist_id}", response_model=Artist)
async def get_artist_detail(artist_id: str):
    artist = await music_repository.get_artist(artist_id)
    if not artist:
        raise HTTPException(status_code=404, detail="Artist not found")
    return artist

@router.post("/like/{track_id}")
async def like_track(track_id: str, payload: dict = Depends(get_current_user_payload)):
    db = get_database()
    await db.users.update_one(
        {"user_id": payload["sub"]},
        {"$addToSet": {"liked_songs": track_id}}
    )
    return {"message": "Track added to liked songs", "track_id": track_id}

@router.post("/unlike/{track_id}")
async def unlike_track(track_id: str, payload: dict = Depends(get_current_user_payload)):
    db = get_database()
    await db.users.update_one(
        {"user_id": payload["sub"]},
        {"$pull": {"liked_songs": track_id}}
    )
    return {"message": "Track removed from liked songs", "track_id": track_id}

@router.post("/history/{track_id}")
async def record_playback_history(track_id: str, payload: dict = Depends(get_current_user_payload)):
    db = get_database()
    now = datetime.now(timezone.utc)
    await db.listening_history.insert_one({
        "user_id": payload["sub"],
        "track_id": track_id,
        "played_at": now
    })
    return {"status": "recorded"}
