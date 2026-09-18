# Resonance - System Architecture

Resonance is a university-tailored mobile music streaming and student productivity ecosystem designed for modern campus life.

## 1. Monorepo Organization

```
university_music/
│
├── mobile/                  # Flutter Mobile Client (Material 3)
│   ├── lib/
│   │   ├── core/            # Theme, constants, networking, secure storage, routing
│   │   ├── models/          # Data schemas: Track, UserModel, Playlist, Study, etc.
│   │   ├── services/        # AudioPlayer, AuthService, MusicService, StudyService, etc.
│   │   ├── providers/       # Riverpod state notifiers & future providers
│   │   ├── features/        # Home, Search, Study, Community, Library, AI, Auth, Player
│   │   ├── widgets/         # MiniPlayer, SongTile, UpdateDialog
│   │   └── main.dart
│   ├── android/             # Native Android shell & permissions
│   ├── ios/                 # Native iOS shell
│   ├── test/                # Unit, widget, and state tests
│   └── pubspec.yaml
│
├── backend/                 # FastAPI REST Engine
│   ├── app/
│   │   ├── main.py          # Entrypoint, CORS, Lifespan, Routers
│   │   ├── config.py        # Pydantic Settings & environment variables
│   │   ├── database.py      # Async Motor client & MongoDB indexes
│   │   ├── security.py      # JWT creation, token refresh, Google ID token verification
│   │   ├── auth/            # Authentication routes
│   │   ├── users/           # Profile, onboarding, music match
│   │   ├── music/           # Audius adapter, music repository, streaming routes
│   │   ├── playlists/       # Personal & collaborative playlists
│   │   ├── study/           # Pomodoro, streaks, focus session logging, study rooms
│   │   ├── community/       # Campus feed, top 10 charts, campus vibe
│   │   ├── events/          # Campus concerts & hackathon events with RSVP
│   │   ├── ai/              # AI music assistant & voice intent tool execution
│   │   ├── admin/           # Moderation, reports, admin metrics
│   │   └── app_version/     # In-app version management & APK update endpoint
│   ├── tests/               # Pytest async test suite
│   ├── Dockerfile           # Production container build
│   └── requirements.txt
│
├── .github/workflows/       # Automated CI/CD (Flutter CI, Android Release, Backend CI)
├── docs/                    # Technical architecture & deployment guides
├── docker-compose.yml       # Production/local Docker orchestration
└── README.md
```

## 2. Audio Engine & State Flow

- **Playback Engine**: Built on `just_audio` + `audio_service`, supporting background playback, lock-screen controls, and system notifications.
- **State Management**: Governed by `flutter_riverpod`, ensuring reactive synchronization between the persistent `MiniPlayer`, the full-screen playback screen, and the active queue.
- **Error Recovery**: If external decentralized audio nodes encounter connectivity timeouts, the engine automatically falls back to curated local/CDN campus study audio without throwing exceptions.

## 3. Database Schema Design (MongoDB)

- `users`: Stores user credentials, campus affiliations, study minutes, streaks, and achievements.
- `songs_cache`: Caches previously queried tracks to minimize outbound API latency.
- `playlists`: Holds personal, collaborative, department, and AI-generated playlists with vote tracking.
- `study_sessions`: Chronological log of focus blocks and Pomodoro sessions.
- `posts` & `comments`: University community message boards.
- `events`: Campus events, dates, locations, and attendee rosters.
- `reports`: Content and user moderation tickets.
- `app_versions`: Historical and current release metadata.
