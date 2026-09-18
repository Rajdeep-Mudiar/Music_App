import logging
import httpx
from typing import List, Optional, Dict, Any
from app.music.provider_base import BaseMusicProvider
from app.models.schemas import Track, Artist, Album
from app.config import settings

logger = logging.getLogger("resonance.music.audius")

# Curated high-reliability open legal study streams (Creative Commons / Open Royalty-Free)
CURATED_STUDY_TRACKS = [
    Track(
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
    Track(
        id="study_lofi_2",
        title="DSA Coding Marathon",
        artist="Algorithmic Chill",
        album="Deep Work Sessions",
        duration=210,
        artwork_url="https://images.unsplash.com/photo-1516321318423-f06f85e504b3?w=500",
        stream_url="https://cdn.pixabay.com/download/audio/2022/01/18/audio_d0a13f69d2.mp3?filename=lofi-chill-medium-version-159456.mp3",
        genre="Study",
        provider="resonance_curated"
    ),
    Track(
        id="study_ambient_3",
        title="Rainy Library Acoustics",
        artist="Campus Rain Soundscape",
        album="Focus Atmosphere",
        duration=240,
        artwork_url="https://images.unsplash.com/photo-1519791883288-dc8bd696e667?w=500",
        stream_url="https://cdn.pixabay.com/download/audio/2021/09/06/audio_73138bcf53.mp3?filename=rain-and-thunder-nature-sounds-7803.mp3",
        genre="Ambient",
        provider="resonance_curated"
    ),
    Track(
        id="study_classical_4",
        title="Exam Calm Classical Flow",
        artist="Symphony of Focus",
        album="Clarity",
        duration=195,
        artwork_url="https://images.unsplash.com/photo-1507838153414-b4b713384a76?w=500",
        stream_url="https://cdn.pixabay.com/download/audio/2022/03/10/audio_c3527e3057.mp3?filename=relaxed-vlog-night-street-131746.mp3",
        genre="Classical",
        provider="resonance_curated"
    ),
    Track(
        id="study_cafe_5",
        title="Campus Coffee House Chill",
        artist="Student Union Cafe",
        album="Study Room Vibes",
        duration=225,
        artwork_url="https://images.unsplash.com/photo-1501339847302-ac426a4a7cbb?w=500",
        stream_url="https://cdn.pixabay.com/download/audio/2022/10/14/audio_9939f792cb.mp3?filename=chill-abstract-intention-12099.mp3",
        genre="Chillout",
        provider="resonance_curated"
    ),
    Track(
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
    Track(
        id="study_lofi_7",
        title="Sunset Hostel Balcony",
        artist="Campus Dusk",
        album="Hostel Diarie",
        duration=190,
        artwork_url="https://images.unsplash.com/photo-1507525428034-b723cf961d3e?w=500",
        stream_url="https://cdn.pixabay.com/download/audio/2022/11/06/audio_c97a5b3a4a.mp3?filename=lofi-study-beat-126297.mp3",
        genre="Lo-Fi",
        provider="resonance_curated"
    ),
    Track(
        id="study_electronic_8",
        title="Neon Matrix Focus",
        artist="Quantum Pulse",
        album="Digital Architecture",
        duration=215,
        artwork_url="https://images.unsplash.com/photo-1550745165-9bc0b252726f?w=500",
        stream_url="https://cdn.pixabay.com/download/audio/2022/03/15/audio_c8c8a73467.mp3?filename=electronic-future-beats-117997.mp3",
        genre="Electronic",
        provider="resonance_curated"
    ),
    Track(
        id="study_acoustic_9",
        title="Morning Library Sunlight",
        artist="Acoustic Scholar",
        album="Golden Hour Notes",
        duration=175,
        artwork_url="https://images.unsplash.com/photo-1497633762265-9d179a990aa6?w=500",
        stream_url="https://cdn.pixabay.com/download/audio/2022/02/07/audio_d0a13f69d2.mp3?filename=acoustic-guitars-ambient-14092.mp3",
        genre="Acoustic",
        provider="resonance_curated"
    ),
    Track(
        id="study_jazz_10",
        title="Midnight Study Session Jazz",
        artist="The Quad Trio",
        album="Late Hours Vol. 2",
        duration=230,
        artwork_url="https://images.unsplash.com/photo-1511192336575-5a79af67a629?w=500",
        stream_url="https://cdn.pixabay.com/download/audio/2022/05/16/audio_db6591201e.mp3?filename=coffee-chill-out-111155.mp3",
        genre="Jazz",
        provider="resonance_curated"
    ),
    Track(
        id="study_chill_11",
        title="Deep Focus Alpha Waves",
        artist="Neuro Beats",
        album="Cognitive Flow",
        duration=250,
        artwork_url="https://images.unsplash.com/photo-1451187580459-43490279c0fa?w=500",
        stream_url="https://cdn.pixabay.com/download/audio/2021/08/04/audio_12b0c7443c.mp3?filename=meditation-ambient-sound-6321.mp3",
        genre="Ambient",
        provider="resonance_curated"
    ),
    Track(
        id="study_synth_12",
        title="Cyberpunk Code Runner",
        artist="Byte Wizard",
        album="Binary Horizons",
        duration=205,
        artwork_url="https://images.unsplash.com/photo-1555066931-4365d14bab8c?w=500",
        stream_url="https://cdn.pixabay.com/download/audio/2022/10/25/audio_2c9435e055.mp3?filename=synthwave-action-retro-123498.mp3",
        genre="Synthwave",
        provider="resonance_curated"
    ),
    Track(
        id="study_piano_13",
        title="Autumn Campus Stroll",
        artist="Clara Sterling",
        album="University Woods",
        duration=180,
        artwork_url="https://images.unsplash.com/photo-1506744038136-46273834b3fb?w=500",
        stream_url="https://cdn.pixabay.com/download/audio/2022/04/27/audio_33878b277a.mp3?filename=emotional-piano-melody-110825.mp3",
        genre="Classical",
        provider="resonance_curated"
    ),
    Track(
        id="study_lofi_14",
        title="3 AM Thesis Writing",
        artist="Graduate Beatmaker",
        album="Deadline Dreams",
        duration=195,
        artwork_url="https://images.unsplash.com/photo-1434030216411-0b793f4b4173?w=500",
        stream_url="https://cdn.pixabay.com/download/audio/2023/01/01/audio_145b40cf61.mp3?filename=lofi-chill-hop-133182.mp3",
        genre="Lo-Fi",
        provider="resonance_curated"
    ),
    Track(
        id="study_ambient_15",
        title="Brahmaputra Riverside Breeze",
        artist="Assam Sound Labs",
        album="Campus Nature Series",
        duration=220,
        artwork_url="https://images.unsplash.com/photo-1470071459604-3b5ec3a7fe05?w=500",
        stream_url="https://cdn.pixabay.com/download/audio/2021/11/24/audio_82e666a0a2.mp3?filename=nature-birds-forest-ambience-9938.mp3",
        genre="Ambient",
        provider="resonance_curated"
    ),
    Track(
        id="study_pop_16",
        title="Upbeat Campus Motivation",
        artist="Solar Energy",
        album="Freshman Momentum",
        duration=190,
        artwork_url="https://images.unsplash.com/photo-1514525253161-7a46d19cd819?w=500",
        stream_url="https://cdn.pixabay.com/download/audio/2022/06/07/audio_b2879555cb.mp3?filename=energetic-indie-rock-upbeat-113881.mp3",
        genre="Indie",
        provider="resonance_curated"
    )
]

class AudiusProvider(BaseMusicProvider):
    def __init__(self):
        self.base_url = "https://api.audius.co"
        self.app_name = settings.AUDIUS_APP_NAME

    def _parse_track(self, item: Dict[str, Any]) -> Track:
        artwork = item.get("artwork") or {}
        art_url = artwork.get("480x480") or artwork.get("150x150") or artwork.get("1000x1000")
        if not art_url:
            art_url = "https://images.unsplash.com/photo-1470225620780-dba8ba36b745?w=500"

        track_id = str(item.get("id"))
        user = item.get("user") or {}
        artist_name = user.get("name") or "Unknown Artist"
        stream_url = f"{self.base_url}/v1/tracks/{track_id}/stream?app_name={self.app_name}"

        return Track(
            id=track_id,
            title=item.get("title") or "Untitled Track",
            artist=artist_name,
            artist_id=str(user.get("id", "")),
            album=item.get("mood") or "Single",
            duration=int(item.get("duration", 180)),
            artwork_url=art_url,
            stream_url=stream_url,
            genre=item.get("genre") or "General",
            provider="audius"
        )

    async def search_tracks(self, query: str, limit: int = 20) -> List[Track]:
        # Check if searching for study/lofi keywords
        q_lower = query.lower()
        matched_curated = [t for t in CURATED_STUDY_TRACKS if q_lower in t.title.lower() or q_lower in t.genre.lower() or q_lower in t.artist.lower()]
        
        try:
            async with httpx.AsyncClient(timeout=7.0) as client:
                res = await client.get(
                    f"{self.base_url}/v1/tracks/search",
                    params={"query": query, "app_name": self.app_name, "limit": limit}
                )
                if res.status_code == 200:
                    data = res.json().get("data", [])
                    parsed = [self._parse_track(item) for item in data if item.get("id")]
                    return matched_curated + parsed
        except Exception as e:
            logger.warning(f"Audius search failed: {e}. Returning curated matches.")
        
        return matched_curated or [t for t in CURATED_STUDY_TRACKS if "lofi" in t.title.lower()]

    async def get_trending_tracks(self, limit: int = 20) -> List[Track]:
        try:
            async with httpx.AsyncClient(timeout=7.0) as client:
                res = await client.get(
                    f"{self.base_url}/v1/tracks/trending",
                    params={"app_name": self.app_name, "limit": limit}
                )
                if res.status_code == 200:
                    data = res.json().get("data", [])
                    parsed = [self._parse_track(item) for item in data if item.get("id")]
                    # Prepend a couple curated focus tracks for student relevance
                    return CURATED_STUDY_TRACKS[:2] + parsed
        except Exception as e:
            logger.warning(f"Audius trending failed: {e}. Falling back to curated tracks.")
        
        return CURATED_STUDY_TRACKS

    async def get_track(self, track_id: str) -> Optional[Track]:
        # Check curated list
        for t in CURATED_STUDY_TRACKS:
            if t.id == track_id:
                return t
        
        try:
            async with httpx.AsyncClient(timeout=6.0) as client:
                res = await client.get(
                    f"{self.base_url}/v1/tracks/{track_id}",
                    params={"app_name": self.app_name}
                )
                if res.status_code == 200:
                    item = res.json().get("data")
                    if item:
                        return self._parse_track(item)
        except Exception as e:
            logger.warning(f"Failed to fetch track {track_id}: {e}")
        return None

    async def get_stream_url(self, track_id: str) -> str:
        for t in CURATED_STUDY_TRACKS:
            if t.id == track_id:
                return t.stream_url
        return f"{self.base_url}/v1/tracks/{track_id}/stream?app_name={self.app_name}"

    async def search_artists(self, query: str, limit: int = 10) -> List[Artist]:
        try:
            async with httpx.AsyncClient(timeout=6.0) as client:
                res = await client.get(
                    f"{self.base_url}/v1/users/search",
                    params={"query": query, "app_name": self.app_name, "limit": limit}
                )
                if res.status_code == 200:
                    data = res.json().get("data", [])
                    artists = []
                    for user in data:
                        profile_pic = (user.get("profile_picture") or {}).get("480x480")
                        artists.append(
                            Artist(
                                id=str(user.get("id")),
                                name=user.get("name") or "Artist",
                                bio=user.get("bio") or "",
                                artwork_url=profile_pic or "https://images.unsplash.com/photo-1511671782779-c97d3d27a1d4?w=500",
                                followers_count=int(user.get("follower_count", 0)),
                                is_student_artist=False
                            )
                        )
                    return artists
        except Exception as e:
            logger.warning(f"Search artists failed: {e}")
        return []

    async def get_artist(self, artist_id: str) -> Optional[Artist]:
        try:
            async with httpx.AsyncClient(timeout=6.0) as client:
                res = await client.get(
                    f"{self.base_url}/v1/users/{artist_id}",
                    params={"app_name": self.app_name}
                )
                if res.status_code == 200:
                    user = res.json().get("data")
                    if user:
                        profile_pic = (user.get("profile_picture") or {}).get("480x480")
                        return Artist(
                            id=str(user.get("id")),
                            name=user.get("name") or "Artist",
                            bio=user.get("bio") or "",
                            artwork_url=profile_pic or "https://images.unsplash.com/photo-1511671782779-c97d3d27a1d4?w=500",
                            followers_count=int(user.get("follower_count", 0)),
                            is_student_artist=False
                        )
        except Exception as e:
            logger.warning(f"Get artist failed: {e}")
        return None

    async def get_study_tracks(self, vibe: str = "lofi", limit: int = 20) -> List[Track]:
        results = await self.search_tracks(f"study {vibe}", limit=limit)
        if not results:
            return CURATED_STUDY_TRACKS
        return results
