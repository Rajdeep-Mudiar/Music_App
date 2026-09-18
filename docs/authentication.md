# Resonance Authentication & Security Architecture

Resonance implements a secure, passwordless authentication model combining Google Identity Services and industry-standard JSON Web Tokens (JWT).

## 1. Authentication Flow

```
Flutter Client                Google Identity Service           FastAPI Backend              MongoDB
     │                                 │                               │                        │
     ├──── Request Google Sign-In ────►│                               │                        │
     │◄─── Returns Google ID Token ────┤                               │                        │
     │                                                                 │                        │
     ├────────────────────── Send Google ID Token ────────────────────►│                        │
     │                                                                 ├─ Verify Token with     │
     │                                                                 │  google-auth transport │
     │                                                                 ├─ Find or create user ─►│
     │                                                                 │◄─ User document ───────┤
     │                                                                 ├─ Generate JWT Pair:    │
     │                                                                 │  • Access Token (30m)  │
     │                                                                 │  • Refresh Token (30d) │
     │◄───────────────── Return Access & Refresh Tokens ───────────────┤                        │
     │                                                                                          │
     ├─ Store in FlutterSecureStorage                                                           │
     └─ Inject Bearer Token into Dio Requests                                                   │
```

## 2. Security Guarantees & Non-Negotiable Rules

1. **Google Client Secret Protection**:
   The `GOOGLE_CLIENT_SECRET` is strictly held on the backend environment (`.env`). It is NEVER placed inside the Flutter codebase, Android APK, Git repository, or client configurations.
2. **Secure Token Storage**:
   Tokens are stored on mobile using `flutter_secure_storage`:
   - On Android: Backed by `EncryptedSharedPreferences` and Android KeyStore.
   - On iOS: Backed by the iOS Keychain.
   Tokens are never stored in plain `SharedPreferences`.
3. **Automatic Token Rotation**:
   Dio's `InterceptorsWrapper` catches any 401 Unauthorized response, seamlessly performs a background refresh using `/api/auth/refresh`, updates the local tokens, and retries the original request without disrupting playback or study sessions.
4. **Instant Campus Demo Login**:
   For local development and evaluator testing, the backend provides `/api/auth/demo` allowing instant one-click login without needing preconfigured Google Cloud Console client credentials.
