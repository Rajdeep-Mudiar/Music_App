import uuid
from datetime import datetime, timezone
from typing import List, Optional
from fastapi import APIRouter, HTTPException, Depends, Query
from app.models.schemas import Playlist, PlaylistCreate, AddSongRequest, PlaylistSongItem, Track
from app.security import get_current_user_payload, get_optional_user_payload
from app.database import get_database

router = APIRouter(prefix="/api/playlists", tags=["Playlists"])

@router.post("", response_model=Playlist)
async def create_playlist(req: PlaylistCreate, payload: dict = Depends(get_current_user_payload)):
    db = get_database()
    user = await db.users.find_one({"user_id": payload["sub"]})
    creator_name = user.get("name", "Student") if user else "Student"
    university = req.university or (user.get("university") if user else None)
    department = req.department or (user.get("department") if user else None)

    playlist_id = str(uuid.uuid4())
    now = datetime.now(timezone.utc)
    
    doc = {
        "id": playlist_id,
        "title": req.title,
        "description": req.description,
        "creator_id": payload["sub"],
        "creator_name": creator_name,
        "type": req.type,
        "is_public": req.is_public,
        "cover_image": req.cover_image or "https://images.unsplash.com/photo-1511671782779-c97d3d27a1d4?w=500",
        "university": university,
        "department": department,
        "songs": [],
        "members": [payload["sub"]],
        "created_at": now
    }
    await db.playlists.insert_one(doc)
    return Playlist(**doc)

@router.get("/me", response_model=List[Playlist])
async def get_my_playlists(payload: dict = Depends(get_current_user_payload)):
    db = get_database()
    cursor = db.playlists.find({"$or": [{"creator_id": payload["sub"]}, {"members": payload["sub"]}]}).sort("created_at", -1)
    results = await cursor.to_list(length=50)
    return [Playlist(**doc) for doc in results]

from app.music.audius_adapter import CURATED_STUDY_TRACKS

def _get_starter_playlists(university: Optional[str] = None) -> List[Playlist]:
    now = datetime.now(timezone.utc)
    
    # Coding Marathon (Synth & Lo-Fi tracks)
    coding_tracks = [CURATED_STUDY_TRACKS[i] for i in [1, 5, 7, 11, 0, 13] if i < len(CURATED_STUDY_TRACKS)]
    coding_items = [
        PlaylistSongItem(
            song=t,
            added_by_id="campus_admin",
            added_by_name="CSE Society",
            added_at=now,
            votes=15 - idx,
            voters=["campus_admin"]
        ) for idx, t in enumerate(coding_tracks)
    ]

    # Exam Calm (Classical, Piano & Ambient tracks)
    exam_tracks = [CURATED_STUDY_TRACKS[i] for i in [2, 3, 4, 8, 10, 12, 14] if i < len(CURATED_STUDY_TRACKS)]
    exam_items = [
        PlaylistSongItem(
            song=t,
            added_by_id="campus_admin",
            added_by_name="Student Welfare",
            added_at=now,
            votes=20 - idx,
            voters=["campus_admin"]
        ) for idx, t in enumerate(exam_tracks)
    ]

    # Hostel Balcony Chill (Lo-Fi, Jazz, Acoustic & Indie tracks)
    hostel_tracks = [CURATED_STUDY_TRACKS[i] for i in [6, 9, 0, 4, 8, 15] if i < len(CURATED_STUDY_TRACKS)]
    hostel_items = [
        PlaylistSongItem(
            song=t,
            added_by_id="campus_admin",
            added_by_name="Hostel Block 4",
            added_at=now,
            votes=18 - idx,
            voters=["campus_admin"]
        ) for idx, t in enumerate(hostel_tracks)
    ]

    return [
        Playlist(
            id="campus_cse_1",
            title="CSE Night Coding Marathon",
            description="Heavy focus, synth beats, and lo-fi rhythms for debugging past midnight.",
            creator_id="campus_admin",
            creator_name="CSE Society",
            type="department",
            is_public=True,
            cover_image="https://images.unsplash.com/photo-1555066931-4365d14bab8c?w=500",
            university=university or "Gauhati University",
            department="CSE",
            songs=coding_items,
            members=["campus_admin"],
            created_at=now
        ),
        Playlist(
            id="campus_exam_2",
            title="Exam Week Calm",
            description="Gentle acoustics, ambient rain, and calming piano for low-stress prep.",
            creator_id="campus_admin",
            creator_name="Student Welfare",
            type="university",
            is_public=True,
            cover_image="https://images.unsplash.com/photo-1497633762265-9d179a990aa6?w=500",
            university=university or "Gauhati University",
            department="All",
            songs=exam_items,
            members=["campus_admin"],
            created_at=now
        ),
        Playlist(
            id="campus_hostel_3",
            title="Hostel Balcony Chill",
            description="Evening chai tunes, indie guitars, and nostalgic student anthems.",
            creator_id="campus_admin",
            creator_name="Hostel Block 4",
            type="collaborative",
            is_public=True,
            cover_image="https://images.unsplash.com/photo-1518495973542-4542c06a5843?w=500",
            university=university or "Gauhati University",
            department="All",
            songs=hostel_items,
            members=["campus_admin"],
            created_at=now
        )
    ]

@router.get("/campus", response_model=List[Playlist])
async def get_campus_playlists(university: Optional[str] = Query(None)):
    db = get_database()
    if db is not None:
        try:
            query = {"type": {"$in": ["university", "department", "collaborative"]}}
            if university:
                query["university"] = university
            cursor = db.playlists.find(query).sort("created_at", -1).limit(20)
            results = await cursor.to_list(length=20)
            if results:
                return [Playlist(**doc) for doc in results]
        except Exception:
            pass

    return _get_starter_playlists(university=university)

@router.get("/{playlist_id}", response_model=Playlist)
async def get_playlist(playlist_id: str):
    db = get_database()
    if db is not None:
        try:
            doc = await db.playlists.find_one({"id": playlist_id})
            if doc:
                return Playlist(**doc)
        except Exception:
            pass

    # Check starter playlists
    for p in _get_starter_playlists():
        if p.id == playlist_id:
            return p

    raise HTTPException(status_code=404, detail="Playlist not found")

@router.post("/{playlist_id}/songs", response_model=Playlist)
async def add_song_to_playlist(playlist_id: str, req: AddSongRequest, payload: dict = Depends(get_current_user_payload)):
    db = get_database()
    user = await db.users.find_one({"user_id": payload["sub"]})
    adder_name = user.get("name", "Student") if user else "Student"

    song_item = PlaylistSongItem(
        song=req.track,
        added_by_id=payload["sub"],
        added_by_name=adder_name,
        added_at=datetime.now(timezone.utc),
        votes=1,
        voters=[payload["sub"]]
    )

    result = await db.playlists.find_one_and_update(
        {"id": playlist_id},
        {
            "$push": {"songs": song_item.model_dump()},
            "$addToSet": {"members": payload["sub"]}
        },
        return_document=True
    )
    if not result:
        raise HTTPException(status_code=404, detail="Playlist not found")
    return Playlist(**result)

@router.delete("/{playlist_id}/songs/{song_id}", response_model=Playlist)
async def remove_song_from_playlist(playlist_id: str, song_id: str, payload: dict = Depends(get_current_user_payload)):
    db = get_database()
    result = await db.playlists.find_one_and_update(
        {"id": playlist_id},
        {"$pull": {"songs": {"song.id": song_id}}},
        return_document=True
    )
    if not result:
        raise HTTPException(status_code=404, detail="Playlist not found")
    return Playlist(**result)

@router.post("/{playlist_id}/songs/{song_id}/vote", response_model=Playlist)
async def vote_playlist_song(playlist_id: str, song_id: str, payload: dict = Depends(get_current_user_payload)):
    db = get_database()
    user_id = payload["sub"]
    playlist = await db.playlists.find_one({"id": playlist_id})
    if not playlist:
        raise HTTPException(status_code=404, detail="Playlist not found")

    updated_songs = []
    for item in playlist.get("songs", []):
        if item["song"]["id"] == song_id:
            voters = item.get("voters", [])
            if user_id in voters:
                voters.remove(user_id)
                item["votes"] = max(0, item.get("votes", 1) - 1)
            else:
                voters.append(user_id)
                item["votes"] = item.get("votes", 0) + 1
            item["voters"] = voters
        updated_songs.append(item)

    # Sort songs by vote count descending for collaborative playlists
    if playlist.get("type") == "collaborative":
        updated_songs.sort(key=lambda s: s.get("votes", 0), reverse=True)

    result = await db.playlists.find_one_and_update(
        {"id": playlist_id},
        {"$set": {"songs": updated_songs}},
        return_document=True
    )
    return Playlist(**result)
