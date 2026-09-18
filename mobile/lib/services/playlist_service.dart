import 'package:resonance/core/constants/api_constants.dart';
import 'package:resonance/core/network/api_client.dart';
import 'package:resonance/models/playlist_model.dart';
import 'package:resonance/models/track_model.dart';

class PlaylistService {
  final ApiClient apiClient;

  PlaylistService({required this.apiClient});

  Future<List<PlaylistModel>> getCampusPlaylists() async {
    try {
      final res = await apiClient.dio.get(ApiConstants.playlistsCampus);
      if (res.statusCode == 200) {
        final list = res.data as List<dynamic>;
        return list.map((json) => PlaylistModel.fromJson(json)).toList();
      }
    } catch (_) {}
    return _getStarterPlaylists();
  }

  Future<PlaylistModel?> getPlaylistDetail(String playlistId) async {
    try {
      final res =
          await apiClient.dio.get('${ApiConstants.playlists}/$playlistId');
      if (res.statusCode == 200) {
        return PlaylistModel.fromJson(res.data);
      }
    } catch (_) {}

    final starters = _getStarterPlaylists();
    for (final p in starters) {
      if (p.id == playlistId) return p;
    }
    return null;
  }

  Future<void> voteSong(String playlistId, String songId) async {
    try {
      await apiClient.dio
          .post('${ApiConstants.playlists}/$playlistId/songs/$songId/vote');
    } catch (_) {}
  }

  List<PlaylistModel> _getStarterPlaylists() {
    // Get the 16 fallback tracks
    final tracks = [
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
    ];

    return [
      PlaylistModel(
        id: 'campus_cse_1',
        title: 'CSE Night Coding Marathon',
        description:
            'Heavy focus, synth beats, and lo-fi rhythms for debugging past midnight.',
        creatorId: 'campus_admin',
        creatorName: 'CSE Society',
        type: 'department',
        isPublic: true,
        coverImage:
            'https://images.unsplash.com/photo-1555066931-4365d14bab8c?w=500',
        university: 'Gauhati University',
        department: 'CSE',
        songs: [
          PlaylistSongItem(
              song: tracks[1],
              addedById: 'admin',
              addedByName: 'CSE Society',
              votes: 15),
          PlaylistSongItem(
              song: tracks[5],
              addedById: 'admin',
              addedByName: 'CSE Society',
              votes: 14),
          PlaylistSongItem(
              song: tracks[7],
              addedById: 'admin',
              addedByName: 'CSE Society',
              votes: 13),
          PlaylistSongItem(
              song: tracks[11],
              addedById: 'admin',
              addedByName: 'CSE Society',
              votes: 12),
          PlaylistSongItem(
              song: tracks[0],
              addedById: 'admin',
              addedByName: 'CSE Society',
              votes: 10),
        ],
      ),
      PlaylistModel(
        id: 'campus_exam_2',
        title: 'Exam Week Calm',
        description:
            'Gentle acoustics, ambient rain, and calming piano for low-stress prep.',
        creatorId: 'campus_admin',
        creatorName: 'Student Welfare',
        type: 'university',
        isPublic: true,
        coverImage:
            'https://images.unsplash.com/photo-1497633762265-9d179a990aa6?w=500',
        university: 'Gauhati University',
        department: 'All',
        songs: [
          PlaylistSongItem(
              song: tracks[2],
              addedById: 'admin',
              addedByName: 'Student Welfare',
              votes: 20),
          PlaylistSongItem(
              song: tracks[3],
              addedById: 'admin',
              addedByName: 'Student Welfare',
              votes: 19),
          PlaylistSongItem(
              song: tracks[4],
              addedById: 'admin',
              addedByName: 'Student Welfare',
              votes: 17),
          PlaylistSongItem(
              song: tracks[8],
              addedById: 'admin',
              addedByName: 'Student Welfare',
              votes: 15),
          PlaylistSongItem(
              song: tracks[10],
              addedById: 'admin',
              addedByName: 'Student Welfare',
              votes: 14),
        ],
      ),
      PlaylistModel(
        id: 'campus_hostel_3',
        title: 'Hostel Balcony Chill',
        description:
            'Evening chai tunes, indie guitars, and nostalgic student anthems.',
        creatorId: 'campus_admin',
        creatorName: 'Hostel Block 4',
        type: 'collaborative',
        isPublic: true,
        coverImage:
            'https://images.unsplash.com/photo-1518495973542-4542c06a5843?w=500',
        university: 'Gauhati University',
        department: 'All',
        songs: [
          PlaylistSongItem(
              song: tracks[6],
              addedById: 'admin',
              addedByName: 'Hostel Block 4',
              votes: 18),
          PlaylistSongItem(
              song: tracks[9],
              addedById: 'admin',
              addedByName: 'Hostel Block 4',
              votes: 16),
          PlaylistSongItem(
              song: tracks[0],
              addedById: 'admin',
              addedByName: 'Hostel Block 4',
              votes: 14),
          PlaylistSongItem(
              song: tracks[4],
              addedById: 'admin',
              addedByName: 'Hostel Block 4',
              votes: 12),
          PlaylistSongItem(
              song: tracks[8],
              addedById: 'admin',
              addedByName: 'Hostel Block 4',
              votes: 10),
        ],
      ),
    ];
  }
}
