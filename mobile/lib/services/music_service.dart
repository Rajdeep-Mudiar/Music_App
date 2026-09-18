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
        return list.map((json) => Track.fromJson(json)).toList();
      }
    } catch (_) {}
    return _getFallbackTracks();
  }

  Future<List<Track>> searchTracks(String query, {int limit = 20}) async {
    try {
      final res = await apiClient.dio.get(
        ApiConstants.musicSearch,
        queryParameters: {'q': query, 'limit': limit},
      );
      if (res.statusCode == 200) {
        final list = res.data as List<dynamic>;
        return list.map((json) => Track.fromJson(json)).toList();
      }
    } catch (_) {}
    return _getFallbackTracks()
        .where((t) =>
            t.title.toLowerCase().contains(query.toLowerCase()) ||
            t.artist.toLowerCase().contains(query.toLowerCase()))
        .toList();
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
    ];
  }
}
