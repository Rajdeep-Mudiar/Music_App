import logging
from typing import List, Optional
from app.music.provider_base import BaseMusicProvider
from app.music.audius_adapter import AudiusProvider
from app.models.schemas import Track, Artist
from app.database import get_database

logger = logging.getLogger("resonance.music.repository")

class MusicRepository:
    def __init__(self, provider: Optional[BaseMusicProvider] = None):
        self.provider = provider or AudiusProvider()

    async def search(self, query: str, limit: int = 20) -> List[Track]:
        tracks = await self.provider.search_tracks(query, limit=limit)
        await self._cache_tracks(tracks)
        return tracks

    async def get_trending(self, limit: int = 20) -> List[Track]:
        tracks = await self.provider.get_trending_tracks(limit=limit)
        await self._cache_tracks(tracks)
        return tracks

    async def get_track(self, track_id: str) -> Optional[Track]:
        db = get_database()
        if db is not None:
            cached = await db.songs_cache.find_one({"track_id": track_id})
            if cached:
                return Track(**cached["track"])
        
        track = await self.provider.get_track(track_id)
        if track:
            await self._cache_track(track)
        return track

    async def get_stream_url(self, track_id: str) -> str:
        return await self.provider.get_stream_url(track_id)

    async def get_study_tracks(self, vibe: str = "lofi", limit: int = 20) -> List[Track]:
        tracks = await self.provider.get_study_tracks(vibe=vibe, limit=limit)
        await self._cache_tracks(tracks)
        return tracks

    async def search_artists(self, query: str, limit: int = 10) -> List[Artist]:
        return await self.provider.search_artists(query, limit=limit)

    async def get_artist(self, artist_id: str) -> Optional[Artist]:
        return await self.provider.get_artist(artist_id)

    async def _cache_tracks(self, tracks: List[Track]):
        for track in tracks:
            await self._cache_track(track)

    async def _cache_track(self, track: Track):
        db = get_database()
        if db is not None:
            try:
                await db.songs_cache.update_one(
                    {"track_id": track.id},
                    {"$set": {"track_id": track.id, "track": track.model_dump(), "genre": track.genre}},
                    upsert=True
                )
            except Exception as e:
                logger.debug(f"Track caching skip: {e}")

music_repository = MusicRepository()
