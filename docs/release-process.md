# Automated Release & In-App Update Delivery

Resonance features an automated CI/CD release pipeline and in-app update delivery mechanism supporting both direct GitHub Release APK distribution and future Google Play / Apple App Store channels.

## 1. CI/CD Release Flow

```
Developer                       GitHub Actions                             GitHub Releases              User Device
    │                                  │                                          │                          │
    ├── Create tag: v1.0.1 ───────────►│                                          │                          │
    │   git push origin v1.0.1         ├─ Run Tests & Analyzers                   │                          │
    │                                  ├─ Build Signed APK & AAB                  │                          │
    │                                  ├─ Create GitHub Release ─────────────────►│                          │
    │                                  └─ Upload app-release.apk                  │                          │
    │                                                                             │                          │
    │                                                                             │   App launches           │
    │                                                                             │   calls /api/app/version │
    │                                                                             │◄─────────┼───────────────┤
    │                                                                             │          ▼               │
    │                                                                             │   Prompts UpdateDialog   │
    │                                                                             │   [Update Now] [Later]   │
    │                                                                             │◄── Downloads latest APK ─┤
```

## 2. In-App Update Verification Logic

1. **Version Check**: On startup, the Flutter client calls `GET /api/app/version`.
2. **Semantic Version Comparison**:
   - `installed_version < minimum_supported_version`: Triggers a **Mandatory Force Update** blocking modal. The user cannot dismiss until updating.
   - `installed_version < latest_version`: Triggers an **Optional Update Banner/Dialog** with release notes and `[Update Now]` and `[Later]` buttons.
   - `installed_version == latest_version`: No prompt shown.

## 3. Direct APK & Google Play Compatibility

- **Direct GitHub Distribution**: The `[Update Now]` button securely opens the verified GitHub release APK download link via `url_launcher`.
- **Google Play Compatibility**: For builds targeted at Google Play, the update service will automatically redirect to `market://details?id=com.resonance.campus.resonance` rather than downloading external binaries, complying fully with Google Play Developer Program Policies.

## 4. Keystore Generation (Release Signing)

Generate your release keystore locally (do not commit into git):

```bash
keytool -genkey -v -keystore release.keystore -alias resonance -keyalg RSA -keysize 2048 -validity 10000
```

Store base64-encoded keystore in GitHub Secret `ANDROID_KEYSTORE_BASE64` and configure signing credentials in GitHub Secrets.
