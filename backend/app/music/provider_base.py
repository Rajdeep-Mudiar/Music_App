from abc import ABC, abstractmethod
from typing import List, Optional
from app.models.schemas import Track, Artist, Album

class BaseMusicProvider(ABC):
    @abstractmethod
    async def search_tracks(self, query: str, limit: int = 20) -> List[Track]:
        pass

    @abstractmethod
    async def get_trending_tracks(self, limit: int = 20) -> List[Track]:
        pass

    @abstractmethod
    async def get_track(self, track_id: str) -> Optional[Track]:
        pass

    @abstractmethod
    async def get_stream_url(self, track_id: str) -> str:
        pass

    @abstractmethod
    async def search_artists(self, query: str, limit: int = 10) -> List[Artist]:
        pass

    @abstractmethod
    async def get_artist(self, artist_id: str) -> Optional[Artist]:
        pass

    @abstractmethod
    async def get_study_tracks(self, vibe: str = "lofi", limit: int = 20) -> List[Track]:
        pass
