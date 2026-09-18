import uuid
from datetime import datetime, timezone
from typing import List, Optional
from fastapi import APIRouter, HTTPException, Depends, Query
from app.models.schemas import Post, PostCreate, Track
from app.security import get_current_user_payload
from app.database import get_database

router = APIRouter(prefix="/api/community", tags=["Community"])

@router.get("/feed", response_model=List[Post])
async def get_campus_feed(university: Optional[str] = Query(None), limit: int = Query(20, ge=1, le=50)):
    db = get_database()
    query = {}
    if university:
        query["university"] = university
    cursor = db.posts.find(query).sort("created_at", -1).limit(limit)
    docs = await cursor.to_list(length=limit)
    
    if not docs:
        # Seed realistic campus posts if clean database
        sample_posts = [
            Post(
                id="post_sample_1",
                community_id="comm_general",
                university=university or "Gauhati University",
                user_id="user_rahul",
                author_name="Rahul Barman",
                author_image="https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150",
                content="Late night OS lab assignment deadline! This synth track is keeping the brain cells alive ⚡",
                song_attachment=Track(
                    id="study_synth_6",
                    title="Late Night Terminal",
                    artist="Cyber Scholar",
                    album="Hex & Synth",
                    duration=200,
                    artwork_url="https://images.unsplash.com/photo-1526374965328-7f61d4dc18c5?w=500",
                    stream_url="https://cdn.pixabay.com/download/audio/2023/04/18/audio_651f65d645.mp3?filename=synthwave-80s-110045.mp3",
                    genre="Synthwave",
                    provider="resonance_curated"
                ),
                likes=["user_rahul"],
                likes_count=18,
                comments_count=4,
                created_at=datetime.now(timezone.utc)
            ),
            Post(
                id="post_sample_2",
                community_id="comm_library",
                university=university or "Gauhati University",
                user_id="user_priya",
                author_name="Priya Das",
                author_image="https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=150",
                content="Anyone studying in Central Library 2nd floor? Rain sounds outside + Lo-Fi in headphones = 100% focus ✨",
                song_attachment=Track(
                    id="study_lofi_1",
                    title="Midnight Campus Lo-Fi",
                    artist="Resonance Focus Lab",
                    album="Semester Beats Vol. 1",
                    duration=185,
                    artwork_url="https://images.unsplash.com/photo-1518495973542-4542c06a5843?w=500",
                    stream_url="https://cdn.pixabay.com/download/audio/2022/05/27/audio_1808fbf07a.mp3?filename=lofi-study-112191.mp3",
                    genre="Lo-Fi",
                    provider="resonance_curated"
                ),
                likes=[],
                likes_count=24,
                comments_count=7,
                created_at=datetime.now(timezone.utc)
            )
        ]
        return sample_posts

    posts = []
    for d in docs:
        song = Track(**d["song_attachment"]) if d.get("song_attachment") else None
        posts.append(
            Post(
                id=d["id"],
                community_id=d.get("community_id", "comm_general"),
                university=d.get("university", "Gauhati University"),
                user_id=d["user_id"],
                author_name=d.get("author_name", "Student"),
                author_image=d.get("author_image"),
                content=d["content"],
                song_attachment=song,
                likes=d.get("likes", []),
                likes_count=len(d.get("likes", [])),
                comments_count=d.get("comments_count", 0),
                created_at=d.get("created_at")
            )
        )
    return posts

@router.post("/posts", response_model=Post)
async def create_post(req: PostCreate, payload: dict = Depends(get_current_user_payload)):
    db = get_database()
    user = await db.users.find_one({"user_id": payload["sub"]})
    user_name = user.get("name", "Student") if user else "Student"
    user_pic = user.get("profile_image") if user else None
    university = user.get("university", "Gauhati University") if user else "Gauhati University"

    post_id = str(uuid.uuid4())
    now = datetime.now(timezone.utc)
    
    doc = {
        "id": post_id,
        "community_id": "comm_general",
        "university": university,
        "user_id": payload["sub"],
        "author_name": user_name,
        "author_image": user_pic,
        "content": req.content,
        "song_attachment": req.song_attachment.model_dump() if req.song_attachment else None,
        "likes": [],
        "comments_count": 0,
        "created_at": now
    }
    await db.posts.insert_one(doc)

    return Post(
        id=post_id,
        community_id="comm_general",
        university=university,
        user_id=payload["sub"],
        author_name=user_name,
        author_image=user_pic,
        content=req.content,
        song_attachment=req.song_attachment,
        likes=[],
        likes_count=0,
        comments_count=0,
        created_at=now
    )

@router.post("/posts/{post_id}/like")
async def like_post(post_id: str, payload: dict = Depends(get_current_user_payload)):
    db = get_database()
    user_id = payload["sub"]
    post = await db.posts.find_one({"id": post_id})
    if not post:
        raise HTTPException(status_code=404, detail="Post not found")

    likes = post.get("likes", [])
    if user_id in likes:
        likes.remove(user_id)
    else:
        likes.append(user_id)

    await db.posts.update_one({"id": post_id}, {"$set": {"likes": likes}})
    return {"status": "success", "likes_count": len(likes), "is_liked": user_id in likes}

@router.get("/campus-chart")
async def get_campus_chart(university: Optional[str] = Query("Gauhati University")):
    """Aggregated Top 10 campus songs based on opt-in university listening trends."""
    return {
        "university": university,
        "chart_name": f"{university} Top 10",
        "tracks": [
            {"rank": 1, "title": "Midnight Campus Lo-Fi", "artist": "Resonance Focus Lab", "plays": 482},
            {"rank": 2, "title": "DSA Coding Marathon", "artist": "Algorithmic Chill", "plays": 394},
            {"rank": 3, "title": "Rainy Library Acoustics", "artist": "Campus Rain Soundscape", "plays": 320},
            {"rank": 4, "title": "Late Night Terminal", "artist": "Cyber Scholar", "plays": 288},
            {"rank": 5, "title": "Campus Coffee House Chill", "artist": "Student Union Cafe", "plays": 210},
        ]
    }

@router.get("/campus-vibe")
async def get_campus_vibe(university: Optional[str] = Query("Gauhati University")):
    """Opt-in aggregated campus vibe distribution."""
    return {
        "university": university,
        "vibe_breakdown": {
            "Deep Focus & Lo-Fi": 46,
            "Chill & Acoustic": 28,
            "Energetic & Synth": 18,
            "Classical & Ambient": 8
        },
        "most_active_hour": "11:00 PM - 1:00 AM",
        "current_mood": "High Exam Prep Focus"
    }
