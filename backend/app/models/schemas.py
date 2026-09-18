from pydantic import BaseModel, Field, EmailStr
from typing import List, Optional, Dict, Any
from datetime import datetime

# --- AUTH SCHEMAS ---
class GoogleAuthRequest(BaseModel):
    id_token: str

class DemoAuthRequest(BaseModel):
    email: Optional[str] = "student@gauhati.ac.in"
    name: Optional[str] = "Rajdeep Sharma"
    university: Optional[str] = "Gauhati University"
    department: Optional[str] = "CSE"

class RefreshTokenRequest(BaseModel):
    refresh_token: str

class UserProfile(BaseModel):
    user_id: str
    google_id: Optional[str] = None
    email: str
    name: str
    username: Optional[str] = None
    profile_image: Optional[str] = None
    university: Optional[str] = None
    department: Optional[str] = None
    degree: Optional[str] = None
    year: Optional[int] = None
    semester: Optional[int] = None
    bio: Optional[str] = ""
    favorite_genres: List[str] = Field(default_factory=list)
    favorite_artists: List[str] = Field(default_factory=list)
    liked_songs: List[str] = Field(default_factory=list)
    study_minutes: int = 0
    focus_sessions: int = 0
    study_streak: int = 0
    achievements: List[str] = Field(default_factory=list)
    is_student_artist: bool = False
    privacy_settings: Dict[str, bool] = Field(
        default_factory=lambda: {
            "share_activity": True,
            "show_on_leaderboard": True,
            "show_recently_played": True
        }
    )
    created_at: Optional[datetime] = None
    updated_at: Optional[datetime] = None

class TokenResponse(BaseModel):
    access_token: str
    refresh_token: str
    token_type: str = "bearer"
    expires_in: int
    user: UserProfile

class OnboardingRequest(BaseModel):
    username: Optional[str] = None
    university: str
    department: str
    degree: Optional[str] = "B.Tech"
    year: Optional[int] = 3
    semester: Optional[int] = 6
    bio: Optional[str] = None
    favorite_genres: List[str] = Field(default_factory=list)

# --- MUSIC SCHEMAS ---
class Track(BaseModel):
    id: str
    title: str
    artist: str
    artist_id: Optional[str] = None
    album: Optional[str] = None
    duration: int = 0  # in seconds
    artwork_url: Optional[str] = None
    stream_url: str
    genre: Optional[str] = "General"
    provider: str = "audius"
    is_liked: Optional[bool] = False

class Artist(BaseModel):
    id: str
    name: str
    bio: Optional[str] = ""
    artwork_url: Optional[str] = None
    followers_count: int = 0
    is_student_artist: bool = False
    university: Optional[str] = None

class Album(BaseModel):
    id: str
    title: str
    artist: str
    artwork_url: Optional[str] = None
    release_date: Optional[str] = None
    tracks_count: int = 0
    tracks: List[Track] = Field(default_factory=list)

# --- PLAYLIST SCHEMAS ---
class PlaylistSongItem(BaseModel):
    song: Track
    added_by_id: str
    added_by_name: str
    added_at: datetime = Field(default_factory=datetime.utcnow)
    votes: int = 0
    voters: List[str] = Field(default_factory=list)

class PlaylistCreate(BaseModel):
    title: str
    description: Optional[str] = ""
    type: str = "personal"  # personal, university, department, collaborative, ai, study
    is_public: bool = True
    cover_image: Optional[str] = None
    university: Optional[str] = None
    department: Optional[str] = None

class Playlist(BaseModel):
    id: str
    title: str
    description: Optional[str] = ""
    creator_id: str
    creator_name: str
    type: str = "personal"
    is_public: bool = True
    cover_image: Optional[str] = None
    university: Optional[str] = None
    department: Optional[str] = None
    songs: List[PlaylistSongItem] = Field(default_factory=list)
    members: List[str] = Field(default_factory=list)
    created_at: datetime = Field(default_factory=datetime.utcnow)

class AddSongRequest(BaseModel):
    track: Track

# --- STUDY & POMODORO SCHEMAS ---
class StudySessionCreate(BaseModel):
    duration_minutes: int
    session_type: str = "pomodoro"  # pomodoro, custom, deep_focus, break
    notes: Optional[str] = ""

class StudySessionResponse(BaseModel):
    id: str
    user_id: str
    duration_minutes: int
    session_type: str
    completed_at: datetime
    current_streak: int
    total_study_minutes: int
    new_achievements: List[str] = Field(default_factory=list)

class StudyStats(BaseModel):
    total_minutes: int
    total_sessions: int
    current_streak: int
    longest_streak: int
    weekly_minutes: List[int] = Field(default_factory=lambda: [0, 0, 0, 0, 0, 0, 0])
    top_study_genre: str = "Lo-fi"

class StudyRoom(BaseModel):
    id: str
    university: str
    name: str
    description: str
    active_students_count: int
    current_track: Optional[Track] = None

# --- COMMUNITY & EVENTS ---
class PostCreate(BaseModel):
    content: str
    song_attachment: Optional[Track] = None

class Post(BaseModel):
    id: str
    community_id: str
    university: str
    user_id: str
    author_name: str
    author_image: Optional[str] = None
    content: str
    song_attachment: Optional[Track] = None
    likes: List[str] = Field(default_factory=list)
    likes_count: int = 0
    comments_count: int = 0
    created_at: datetime = Field(default_factory=datetime.utcnow)

class EventCreate(BaseModel):
    name: str
    description: str
    date: str
    time: str
    location: str
    organizer: str
    image: Optional[str] = None

class Event(BaseModel):
    id: str
    university: str
    name: str
    description: str
    date: str
    time: str
    location: str
    organizer: str
    image: Optional[str] = None
    attendees: List[str] = Field(default_factory=list)
    attendees_count: int = 0
    is_attending: bool = False

# --- AI & VOICE ---
class ToolCall(BaseModel):
    tool: str
    arguments: Dict[str, Any]
    result: Optional[Any] = None

class AIChatRequest(BaseModel):
    message: str
    current_track_id: Optional[str] = None
    current_mode: Optional[str] = None  # music, study

class AIChatResponse(BaseModel):
    reply: str
    tool_calls: List[ToolCall] = Field(default_factory=list)
    suggested_tracks: List[Track] = Field(default_factory=list)
    playlist_recommendation: Optional[Dict[str, Any]] = None

class AIPlaylistGenerateRequest(BaseModel):
    prompt: str  # e.g. "I have a 4-hour DSA study session tomorrow"
    duration_hours: Optional[float] = 2.0
    vibe: Optional[str] = "focus"

# --- APP VERSION ---
class AndroidVersionInfo(BaseModel):
    download_url: str

class AppVersionResponse(BaseModel):
    latest_version: str
    minimum_supported_version: str
    release_notes: str
    android: AndroidVersionInfo
