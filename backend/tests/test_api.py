import pytest
from httpx import AsyncClient, ASGITransport
from app.main import app

@pytest.mark.asyncio
async def test_health_and_version():
    async with AsyncClient(transport=ASGITransport(app=app), base_url="http://test") as ac:
        res = await ac.get("/health")
        assert res.status_code == 200
        assert res.json()["status"] == "healthy"

        ver_res = await ac.get("/api/app/version")
        assert ver_res.status_code == 200
        data = ver_res.json()
        assert "latest_version" in data
        assert "minimum_supported_version" in data
        assert "download_url" in data["android"]

@pytest.mark.asyncio
async def test_auth_and_user_flow():
    async with AsyncClient(transport=ASGITransport(app=app), base_url="http://test") as ac:
        # Demo login
        login_res = await ac.post("/api/auth/demo", json={
            "email": "test_student@gauhati.ac.in",
            "name": "Test Student",
            "university": "Gauhati University",
            "department": "CSE"
        })
        assert login_res.status_code == 200
        token_data = login_res.json()
        access_token = token_data["access_token"]
        refresh_token = token_data["refresh_token"]
        assert access_token is not None

        headers = {"Authorization": f"Bearer {access_token}"}

        # Get profile
        me_res = await ac.get("/api/auth/me", headers=headers)
        assert me_res.status_code == 200
        user_profile = me_res.json()
        assert user_profile["email"] == "test_student@gauhati.ac.in"

        # Refresh token
        refresh_res = await ac.post("/api/auth/refresh", json={"refresh_token": refresh_token})
        assert refresh_res.status_code == 200
        assert "access_token" in refresh_res.json()

@pytest.mark.asyncio
async def test_music_and_study_flow():
    async with AsyncClient(transport=ASGITransport(app=app), base_url="http://test") as ac:
        # Login first
        login_res = await ac.post("/api/auth/demo", json={"email": "music_test@gauhati.ac.in"})
        token = login_res.json()["access_token"]
        headers = {"Authorization": f"Bearer {token}"}

        # Trending tracks
        trending_res = await ac.get("/api/music/trending?limit=5")
        assert trending_res.status_code == 200
        tracks = trending_res.json()
        assert len(tracks) > 0

        # Study tracks
        study_res = await ac.get("/api/music/study-tracks?vibe=lofi")
        assert study_res.status_code == 200
        assert len(study_res.json()) > 0

        # Log study session
        session_res = await ac.post("/api/study/session", json={
            "duration_minutes": 25,
            "session_type": "pomodoro",
            "notes": "DSA dynamic programming"
        }, headers=headers)
        assert session_res.status_code == 200
        session_data = session_res.json()
        assert session_data["duration_minutes"] == 25

        # Get stats
        stats_res = await ac.get("/api/study/stats", headers=headers)
        assert stats_res.status_code == 200
        stats = stats_res.json()
        assert stats["total_minutes"] >= 25

@pytest.mark.asyncio
async def test_ai_assistant_flow():
    async with AsyncClient(transport=ASGITransport(app=app), base_url="http://test") as ac:
        # Ask AI to play coding music
        ai_res = await ac.post("/api/ai/chat", json={
            "message": "Play something relaxing for coding"
        })
        assert ai_res.status_code == 200
        ai_data = ai_res.json()
        assert "reply" in ai_data
        assert len(ai_data["tool_calls"]) > 0
