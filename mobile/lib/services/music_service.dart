import 'package:resonance/core/constants/api_constants.dart';
import 'package:resonance/core/network/api_client.dart';
import 'package:resonance/models/track_model.dart';

class MusicService {
  final ApiClient apiClient;

  MusicService({required this.apiClient});

  Future<List<Track>> getTrending({int limit = 20}) async {
    try {
      final res = await apiClient.dio.get(
        ApiConstants.musicTrending,
        queryParameters: {'limit': limit},
      );
      if (res.statusCode == 200) {
        final list = res.data as List<dynamic>;
        if (list.isNotEmpty) {
          return list.map((json) => Track.fromJson(json)).toList();
        }
      }
    } catch (_) {}

    // Direct Open Trending Hits Fallback
    try {
      final directRes = await apiClient.dio.get(
        'https://itunes.apple.com/search',
        queryParameters: {
          'term': 'top hits 2026',
          'media': 'music',
          'limit': limit
        },
      );
      if (directRes.statusCode == 200) {
        final results = directRes.data['results'] as List<dynamic>? ?? [];
        final parsed = results
            .where((item) => item['previewUrl'] != null)
            .map((item) => _parseItunesTrack(item as Map<String, dynamic>))
            .toList();
        if (parsed.isNotEmpty) {
          return _getFallbackTracks().take(4).toList() + parsed;
        }
      }
    } catch (_) {}

    return _getFallbackTracks();
  }

  Future<List<Track>> searchTracks(String query, {int limit = 20}) async {
    // 1. Try backend search
    try {
      final res = await apiClient.dio.get(
        ApiConstants.musicSearch,
        queryParameters: {'q': query, 'limit': limit},
      );
      if (res.statusCode == 200) {
        final list = res.data as List<dynamic>;
        if (list.isNotEmpty) {
          return list.map((json) => Track.fromJson(json)).toList();
        }
      }
    } catch (_) {}

    // 2. Direct high-speed Open Music Search (No API Key required)
    try {
      final directRes = await apiClient.dio.get(
        'https://itunes.apple.com/search',
        queryParameters: {'term': query, 'media': 'music', 'limit': limit},
      );
      if (directRes.statusCode == 200) {
        final results = directRes.data['results'] as List<dynamic>? ?? [];
        final parsed = results
            .where((item) => item['previewUrl'] != null)
            .map((item) => _parseItunesTrack(item as Map<String, dynamic>))
            .toList();
        if (parsed.isNotEmpty) {
          final curatedMatches = _getFallbackTracks()
              .where((t) =>
                  t.title.toLowerCase().contains(query.toLowerCase()) ||
                  t.artist.toLowerCase().contains(query.toLowerCase()) ||
                  t.genre.toLowerCase().contains(query.toLowerCase()))
              .toList();
          return curatedMatches + parsed;
        }
      }
    } catch (_) {}

    return _getFallbackTracks()
        .where((t) =>
            t.title.toLowerCase().contains(query.toLowerCase()) ||
            t.artist.toLowerCase().contains(query.toLowerCase()) ||
            t.genre.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }

  Track _parseItunesTrack(Map<String, dynamic> json) {
    final trackId = json['trackId']?.toString() ??
        json['collectionId']?.toString() ??
        'trk';
    final artwork = (json['artworkUrl100'] as String?)
            ?.replaceAll('100x100bb', '600x600bb') ??
        'https://images.unsplash.com/photo-1511671782779-c97d3d27a1d4?w=500';
    final millis = json['trackTimeMillis'] as int? ?? 180000;
    final duration = (millis / 1000).round();

    return Track(
      id: 'itunes_$trackId',
      title: json['trackName'] ?? json['collectionName'] ?? 'Untitled Track',
      artist: json['artistName'] ?? 'Various Artists',
      artistId: json['artistId']?.toString(),
      album: json['collectionName'] ?? 'Single',
      duration: duration,
      artworkUrl: artwork,
      streamUrl: json['previewUrl'] ?? '',
      genre: json['primaryGenreName'] ?? 'Music',
    );
  }

  Future<List<Track>> getStudyTracks(
      {String vibe = 'lofi', int limit = 20}) async {
    try {
      final res = await apiClient.dio.get(
        ApiConstants.musicStudyTracks,
        queryParameters: {'vibe': vibe, 'limit': limit},
      );
      if (res.statusCode == 200) {
        final list = res.data as List<dynamic>;
        return list.map((json) => Track.fromJson(json)).toList();
      }
    } catch (_) {}
    return _getFallbackTracks();
  }

  Future<void> likeTrack(String trackId) async {
    try {
      await apiClient.dio.post('/api/music/like/$trackId');
    } catch (_) {}
  }

  Future<void> unlikeTrack(String trackId) async {
    try {
      await apiClient.dio.post('/api/music/unlike/$trackId');
    } catch (_) {}
  }

  Future<void> recordHistory(String trackId) async {
    try {
      await apiClient.dio.post('/api/music/history/$trackId');
    } catch (_) {}
  }

  List<Track> _getFallbackTracks() {
    return [
      Track(
        id: 'study_lofi_1',
        title: 'Midnight Campus Lo-Fi',
        artist: 'Resonance Focus Lab',
        album: 'Semester Beats Vol. 1',
        duration: 185,
        artworkUrl:
            'https://images.unsplash.com/photo-1518495973542-4542c06a5843?w=500',
        streamUrl:
            'https://cdn.pixabay.com/download/audio/2022/05/27/audio_1808fbf07a.mp3?filename=lofi-study-112191.mp3',
        genre: 'Lo-Fi',
      ),
      Track(
        id: 'study_lofi_2',
        title: 'DSA Coding Marathon',
        artist: 'Algorithmic Chill',
        album: 'Deep Work Sessions',
        duration: 210,
        artworkUrl:
            'https://images.unsplash.com/photo-1516321318423-f06f85e504b3?w=500',
        streamUrl:
            'https://cdn.pixabay.com/download/audio/2022/01/18/audio_d0a13f69d2.mp3?filename=lofi-chill-medium-version-159456.mp3',
        genre: 'Study',
      ),
      Track(
        id: 'study_ambient_3',
        title: 'Rainy Library Acoustics',
        artist: 'Campus Rain Soundscape',
        album: 'Focus Atmosphere',
        duration: 240,
        artworkUrl:
            'https://images.unsplash.com/photo-1519791883288-dc8bd696e667?w=500',
        streamUrl:
            'https://cdn.pixabay.com/download/audio/2021/09/06/audio_73138bcf53.mp3?filename=rain-and-thunder-nature-sounds-7803.mp3',
        genre: 'Ambient',
      ),
      Track(
        id: 'study_classical_4',
        title: 'Exam Calm Classical Flow',
        artist: 'Symphony of Focus',
        album: 'Clarity',
        duration: 195,
        artworkUrl:
            'https://images.unsplash.com/photo-1507838153414-b4b713384a76?w=500',
        streamUrl:
            'https://cdn.pixabay.com/download/audio/2022/03/10/audio_c3527e3057.mp3?filename=relaxed-vlog-night-street-131746.mp3',
        genre: 'Classical',
      ),
      Track(
        id: 'study_cafe_5',
        title: 'Campus Coffee House Chill',
        artist: 'Student Union Cafe',
        album: 'Study Room Vibes',
        duration: 225,
        artworkUrl:
            'https://images.unsplash.com/photo-1501339847302-ac426a4a7cbb?w=500',
        streamUrl:
            'https://cdn.pixabay.com/download/audio/2022/10/14/audio_9939f792cb.mp3?filename=chill-abstract-intention-12099.mp3',
        genre: 'Chillout',
      ),
      Track(
        id: 'study_synth_6',
        title: 'Late Night Terminal',
        artist: 'Cyber Scholar',
        album: 'Hex & Synth',
        duration: 200,
        artworkUrl:
            'https://images.unsplash.com/photo-1526374965328-7f61d4dc18c5?w=500',
        streamUrl:
            'https://cdn.pixabay.com/download/audio/2023/04/18/audio_651f65d645.mp3?filename=synthwave-80s-110045.mp3',
        genre: 'Synthwave',
      ),
      Track(
        id: 'study_lofi_7',
        title: 'Sunset Hostel Balcony',
        artist: 'Campus Dusk',
        album: 'Hostel Diaries',
        duration: 190,
        artworkUrl:
            'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?w=500',
        streamUrl:
            'https://cdn.pixabay.com/download/audio/2022/11/06/audio_c97a5b3a4a.mp3?filename=lofi-study-beat-126297.mp3',
        genre: 'Lo-Fi',
      ),
      Track(
        id: 'study_electronic_8',
        title: 'Neon Matrix Focus',
        artist: 'Quantum Pulse',
        album: 'Digital Architecture',
        duration: 215,
        artworkUrl:
            'https://images.unsplash.com/photo-1550745165-9bc0b252726f?w=500',
        streamUrl:
            'https://cdn.pixabay.com/download/audio/2022/03/15/audio_c8c8a73467.mp3?filename=electronic-future-beats-117997.mp3',
        genre: 'Electronic',
      ),
      Track(
        id: 'study_acoustic_9',
        title: 'Morning Library Sunlight',
        artist: 'Acoustic Scholar',
        album: 'Golden Hour Notes',
        duration: 175,
        artworkUrl:
            'https://images.unsplash.com/photo-1497633762265-9d179a990aa6?w=500',
        streamUrl:
            'https://cdn.pixabay.com/download/audio/2022/02/07/audio_d0a13f69d2.mp3?filename=acoustic-guitars-ambient-14092.mp3',
        genre: 'Acoustic',
      ),
      Track(
        id: 'study_jazz_10',
        title: 'Midnight Study Session Jazz',
        artist: 'The Quad Trio',
        album: 'Late Hours Vol. 2',
        duration: 230,
        artworkUrl:
            'https://images.unsplash.com/photo-1511192336575-5a79af67a629?w=500',
        streamUrl:
            'https://cdn.pixabay.com/download/audio/2022/05/16/audio_db6591201e.mp3?filename=coffee-chill-out-111155.mp3',
        genre: 'Jazz',
      ),
      Track(
        id: 'study_chill_11',
        title: 'Deep Focus Alpha Waves',
        artist: 'Neuro Beats',
        album: 'Cognitive Flow',
        duration: 250,
        artworkUrl:
            'https://images.unsplash.com/photo-1451187580459-43490279c0fa?w=500',
        streamUrl:
            'https://cdn.pixabay.com/download/audio/2021/08/04/audio_12b0c7443c.mp3?filename=meditation-ambient-sound-6321.mp3',
        genre: 'Ambient',
      ),
      Track(
        id: 'study_synth_12',
        title: 'Cyberpunk Code Runner',
        artist: 'Byte Wizard',
        album: 'Binary Horizons',
        duration: 205,
        artworkUrl:
            'https://images.unsplash.com/photo-1555066931-4365d14bab8c?w=500',
        streamUrl:
            'https://cdn.pixabay.com/download/audio/2022/10/25/audio_2c9435e055.mp3?filename=synthwave-action-retro-123498.mp3',
        genre: 'Synthwave',
      ),
      Track(
        id: 'study_piano_13',
        title: 'Autumn Campus Stroll',
        artist: 'Clara Sterling',
        album: 'University Woods',
        duration: 180,
        artworkUrl:
            'https://images.unsplash.com/photo-1506744038136-46273834b3fb?w=500',
        streamUrl:
            'https://cdn.pixabay.com/download/audio/2022/04/27/audio_33878b277a.mp3?filename=emotional-piano-melody-110825.mp3',
        genre: 'Classical',
      ),
      Track(
        id: 'study_lofi_14',
        title: '3 AM Thesis Writing',
        artist: 'Graduate Beatmaker',
        album: 'Deadline Dreams',
        duration: 195,
        artworkUrl:
            'https://images.unsplash.com/photo-1434030216411-0b793f4b4173?w=500',
        streamUrl:
            'https://cdn.pixabay.com/download/audio/2023/01/01/audio_145b40cf61.mp3?filename=lofi-chill-hop-133182.mp3',
        genre: 'Lo-Fi',
      ),
      Track(
        id: 'study_ambient_15',
        title: 'Brahmaputra Riverside Breeze',
        artist: 'Assam Sound Labs',
        album: 'Campus Nature Series',
        duration: 220,
        artworkUrl:
            'https://images.unsplash.com/photo-1470071459604-3b5ec3a7fe05?w=500',
        streamUrl:
            'https://cdn.pixabay.com/download/audio/2021/11/24/audio_82e666a0a2.mp3?filename=nature-birds-forest-ambience-9938.mp3',
        genre: 'Ambient',
      ),
      Track(
        id: 'study_pop_16',
        title: 'Upbeat Campus Motivation',
        artist: 'Solar Energy',
        album: 'Freshman Momentum',
        duration: 190,
        artworkUrl:
            'https://images.unsplash.com/photo-1514525253161-7a46d19cd819?w=500',
        streamUrl:
            'https://cdn.pixabay.com/download/audio/2022/06/07/audio_b2879555cb.mp3?filename=energetic-indie-rock-upbeat-113881.mp3',
        genre: 'Indie',
      ),
    ];
  }
}
