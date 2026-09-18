# 🎵 Resonance: University Music Streaming & Student Platform

> **Resonance** is a production-ready, university-focused mobile music streaming and student productivity ecosystem. It bridges legal decentralized music streaming, Pomodoro focus tools, AI music generation, campus communities, and direct GitHub/Play Store application update management.

---

## ✨ Features

- **🎧 Legal Music Streaming**: Powered by Audius decentralized open audio protocol and Creative Commons campus soundscapes with zero copyright violations or DRM circumvention.
- **⏱️ Study Mode & Pomodoro**: 25/5, 50/10, and custom focus intervals with automatic ambient soundscape switching, daily study streaks, and focus analytics.
- **🤖 AI Music & Study Assistant**: Natural language assistant with function calling (`search_music`, `play_song`, `start_study_session`, `create_playlist`) and voice command execution.
- **🏫 University Communities**: Campus feeds, top 10 campus charts, virtual study rooms with active student counts, and campus concert events with RSVP.
- **🤝 Collaborative Playlists**: Students can invite friends, contribute tracks with attribution ("Rajdeep added Lo-fi Study #3"), and vote on songs.
- **📱 Persistent Audio Engine**: Powered by `just_audio` and `audio_service` with floating mini-player, full-screen player, queue management, and lock-screen controls.
- **🔒 Production Security**: Google ID token verification, short-lived JWTs (30m) with long-lived refresh tokens (30d) stored securely via `flutter_secure_storage`.
- **🚀 In-App Update Delivery**: Semantic version comparison against `/api/app/version` with direct GitHub Release APK distribution and Google Play compatibility.
- **🔄 Automated CI/CD**: Complete GitHub Actions pipelines for formatting, linting, tests, release builds, and GitHub release automation.

---

## 🛠️ Technology Stack

| Layer | Technologies |
|---|---|
| **Mobile** | Flutter 3.29+, Dart 3.9+, Material 3, Riverpod 2.6+, GoRouter, just_audio, audio_service, Dio, flutter_secure_storage, cached_network_image |
| **Backend** | Python 3.11+, FastAPI, Pydantic v2, Motor (AsyncIO MongoDB), PyJWT, Google Auth, Uvicorn |
| **Database** | MongoDB 8.0+ |
| **Music Source** | Audius Open Protocol API + Curated Campus Soundscapes |
| **DevOps** | Docker, Docker Compose, GitHub Actions |

---

## 🚀 Quick Start Guide

### 1. Prerequisites
- Python 3.11+
- Flutter 3.29+ & Dart
- MongoDB running locally on `localhost:27017` or Docker

### 2. Backend Setup
```bash
cd backend

# Create and activate virtual environment (optional)
python -m venv venv
# On Windows:
venv\Scripts\activate

# Install dependencies
pip install -r requirements.txt

# Start backend server
uvicorn app.main:app --reload --port 8000
```
Backend will be live at `http://localhost:8000`. Swagger API docs available at `http://localhost:8000/docs`.

### 3. Mobile App Setup
```bash
cd mobile

# Fetch packages
flutter pub get

# Run test suite
flutter test

# Launch mobile app
flutter run
```

### 4. Running with Docker Compose
```bash
docker-compose up -d --build
```

---

## 🧪 Testing

### Backend Tests
```bash
# Run pytest test suite
python -m pytest backend/tests -v
```

### Mobile Tests
```bash
cd mobile
flutter test
```

---

## 📚 Technical Documentation

- [System Architecture](file:///f:/Vibe_Coding/Music_App/docs/architecture.md)
- [Authentication & Security Flow](file:///f:/Vibe_Coding/Music_App/docs/authentication.md)
- [Legal Music Provider Architecture](file:///f:/Vibe_Coding/Music_App/docs/music-api.md)
- [Cloud Deployment & Docker](file:///f:/Vibe_Coding/Music_App/docs/deployment.md)
- [Release Process & In-App Update Engine](file:///f:/Vibe_Coding/Music_App/docs/release-process.md)

---

## ⚖️ License & Compliance

All music streamed through Resonance is obtained through official decentralized open protocol APIs (Audius) or licensed under Creative Commons. No copyrighted proprietary streams are downloaded, cached against provider terms, or bypassed.
