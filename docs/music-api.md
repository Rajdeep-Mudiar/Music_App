# Legal Music Provider Architecture

Resonance strictly adheres to legal and ethical software development practices. The platform streams legally licensed, open audio protocols and public creative commons music.

## 1. Core Principles

- **No Scraping**: No copyrighted proprietary services (such as Spotify, Apple Music, or YouTube) are scraped.
- **No DRM Circumvention**: The application does not bypass digital rights management.
- **No Piracy**: No unauthorized audio tracks or downloaded copyrighted streams are stored or distributed.

## 2. Provider Abstraction Architecture

To ensure decoupling, Resonance implements a modular 3-tier music architecture:

```
MusicRepository
      ↓
MusicApiService
      ↓
ProviderAdapter (BaseMusicProvider)
      ├── AudiusProvider (Decentralized Open Music Protocol)
      └── CuratedStudyProvider (Royalty-Free Campus Soundscapes)
```

## 3. Audius API Integration

Audius is a decentralized, community-owned open streaming network with official public APIs:
- **Discovery Endpoint**: `https://api.audius.co`
- **Trending Tracks**: `GET /v1/tracks/trending?app_name=ResonanceCampus`
- **Search Tracks**: `GET /v1/tracks/search?query=...&app_name=ResonanceCampus`
- **Audio Stream**: `https://api.audius.co/v1/tracks/{track_id}/stream?app_name=ResonanceCampus`

## 4. Curated Student Study Fallbacks

To provide uninterrupted study sessions during offline or low-connectivity periods, Resonance includes curated high-bitrate royalty-free ambient and lo-fi tracks for:
- Midnight Campus Lo-Fi
- DSA Coding Marathon
- Rainy Library Acoustics
- Late Night Terminal Synthwave
