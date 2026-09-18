import re
from typing import List, Dict, Any, Optional
from fastapi import APIRouter, HTTPException, Depends
from app.models.schemas import (
    AIChatRequest, AIChatResponse, ToolCall,
    AIPlaylistGenerateRequest, Track
)
from app.music.music_repository import music_repository
from app.security import get_optional_user_payload

router = APIRouter(prefix="/api/ai", tags=["AI Music Assistant & Voice"])

@router.post("/chat", response_model=AIChatResponse)
async def ai_chat(req: AIChatRequest, user_payload: Optional[dict] = Depends(get_optional_user_payload)):
    msg = req.message.strip().lower()
    tool_calls: List[ToolCall] = []
    suggested_tracks: List[Track] = []
    reply = ""

    # Tool detection heuristics / function execution
    if any(k in msg for k in ["study", "focus", "pomodoro", "coding", "dsa", "exam"]):
        tracks = await music_repository.get_study_tracks(vibe="lofi", limit=4)
        suggested_tracks = tracks
        tool_calls.append(ToolCall(
            tool="recommend_music",
            arguments={"vibe": "lofi", "intent": "study_focus"},
            result={"tracks_count": len(tracks), "first_track": tracks[0].title if tracks else None}
        ))
        if "start" in msg or "timer" in msg or "session" in msg:
            tool_calls.append(ToolCall(
                tool="start_study_session",
                arguments={"duration_minutes": 25, "session_type": "pomodoro"},
                result={"status": "initiated", "timer_minutes": 25}
            ))
            reply = f"I've set up a 25-minute Pomodoro focus block for you with '{tracks[0].title if tracks else 'Lo-fi Beats'}' on deck. Ready when you are!"
        else:
            reply = f"Here are the highest-rated campus focus tracks for your study session. Playing '{tracks[0].title if tracks else 'Study Lo-Fi'}' now."

    elif "pause" in msg or "stop" in msg:
        tool_calls.append(ToolCall(
            tool="pause_music",
            arguments={},
            result={"state": "paused"}
        ))
        reply = "Music paused."

    elif "next" in msg or "skip" in msg:
        tool_calls.append(ToolCall(
            tool="skip_song",
            arguments={"direction": "next"},
            result={"state": "skipped"}
        ))
        reply = "Skipping to next track in queue."

    elif "play" in msg or "listen" in msg:
        query = re.sub(r"^(play|listen to|put on)\s*", "", req.message, flags=re.IGNORECASE).strip()
        if not query:
            query = "lofi"
        tracks = await music_repository.search(query, limit=5)
        suggested_tracks = tracks
        if tracks:
            tool_calls.append(ToolCall(
                tool="play_song",
                arguments={"track_id": tracks[0].id, "title": tracks[0].title, "artist": tracks[0].artist},
                result={"status": "playing", "track_id": tracks[0].id}
            ))
            reply = f"Playing '{tracks[0].title}' by {tracks[0].artist}."
        else:
            reply = f"I couldn't find matches for '{query}'. Trying top trending beats instead."
            tracks = await music_repository.get_trending(limit=3)
            suggested_tracks = tracks

    elif "playlist" in msg:
        tool_calls.append(ToolCall(
            tool="create_playlist",
            arguments={"title": "AI Curated Session", "type": "ai"},
            result={"status": "created"}
        ))
        tracks = await music_repository.get_study_tracks(vibe="ambient", limit=5)
        suggested_tracks = tracks
        reply = "I've generated a customized study playlist tailored to your listening habits."

    else:
        # Default helpful assistant reply with recommendations
        tracks = await music_repository.get_trending(limit=3)
        suggested_tracks = tracks
        tool_calls.append(ToolCall(
            tool="recommend_music",
            arguments={"category": "campus_trending"},
            result={"tracks_count": len(tracks)}
        ))
        reply = "I am your Resonance AI Music Assistant. You can ask me to play coding tunes, start a Pomodoro timer, generate an exam playlist, or discover campus hits!"

    return AIChatResponse(
        reply=reply,
        tool_calls=tool_calls,
        suggested_tracks=suggested_tracks
    )

@router.post("/generate-playlist")
async def generate_ai_playlist(req: AIPlaylistGenerateRequest):
    """
    Generates structured multi-block study playlists from natural language.
    e.g. 'I have a 4-hour DSA study session tomorrow'
    """
    hours = req.duration_hours or 2.0
    blocks_count = max(1, int(hours * 2))  # e.g. 4 blocks for 2 hours (25 min each)

    study_tracks = await music_repository.get_study_tracks(limit=blocks_count * 3)

    blocks = []
    track_idx = 0
    for i in range(1, blocks_count + 1):
        block_tracks = study_tracks[track_idx:track_idx + 3]
        track_idx += 3
        blocks.append({
            "block_number": i,
            "name": f"Focus Block {i}",
            "duration_minutes": 25,
            "tracks": [t.model_dump() for t in block_tracks]
        })
        if i < blocks_count:
            blocks.append({
                "block_number": i,
                "name": f"Break {i}",
                "duration_minutes": 5,
                "recommended_activity": "Hydrate, stretch, step away from screens."
            })

    return {
        "title": f"AI Plan: {req.prompt}",
        "total_duration_hours": hours,
        "blocks": blocks,
        "summary": f"Structured {len(blocks)} focus and break intervals optimized for deep retention."
    }

@router.post("/voice-intent")
async def parse_voice_command(speech_text: str):
    """
    Pipeline: Voice -> Speech-to-Text -> Intent Detection -> Tool Call -> Action
    """
    req = AIChatRequest(message=speech_text)
    return await ai_chat(req)
