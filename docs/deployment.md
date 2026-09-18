# Production Deployment & Infrastructure

Resonance backend is engineered to run in containerized cloud environments such as Docker, Kubernetes, Render, Railway, AWS ECS, or DigitalOcean App Platform.

## 1. Docker Compose Orchestration

For unified local or self-hosted deployment:

```bash
# Clone the repository
git clone https://github.com/resonance-app/resonance.git
cd resonance

# Start Backend + MongoDB
docker-compose up -d --build
```

The FastAPI backend will bind to `http://localhost:8000` with automated health checks at `/health`.

## 2. Production Environment Variables

Configure the following environment variables on your cloud provider:

| Variable | Description | Example |
|---|---|---|
| `ENVIRONMENT` | Deployment stage | `production` |
| `PORT` | HTTP port | `8000` |
| `MONGO_URI` | Managed MongoDB connection string | `mongodb+srv://admin:pass@cluster.mongodb.net` |
| `MONGO_DB_NAME` | Target database name | `resonance_production` |
| `JWT_SECRET` | 32+ character cryptographic secret | `a8d3f1...` |
| `GOOGLE_CLIENT_ID` | OAuth 2.0 Web Client ID | `*.apps.googleusercontent.com` |
| `GOOGLE_CLIENT_SECRET` | Backend Google OAuth secret | `GOCSPX-...` |
| `AUDIUS_APP_NAME` | Registered Audius application name | `ResonanceCampus` |
| `APP_VERSION` | Current production version | `1.0.0` |
| `MIN_SUPPORTED_VERSION`| Minimum client version allowed | `1.0.0` |
| `APK_DOWNLOAD_URL` | Direct link to latest GitHub release APK | `https://github.com/.../app-release.apk` |

## 3. Flutter Production Build

To build the release Android APK:

```bash
cd mobile
flutter build apk --release --dart-define=API_BASE_URL=https://api.resonance-campus.com
```

Output: `mobile/build/app/outputs/flutter-apk/app-release.apk`
