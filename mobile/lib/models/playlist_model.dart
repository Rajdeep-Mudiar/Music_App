import 'package:resonance/models/track_model.dart';

class PlaylistSongItem {
  final Track song;
  final String addedById;
  final String addedByName;
  final int votes;
  final List<String> voters;

  PlaylistSongItem({
    required this.song,
    required this.addedById,
    required this.addedByName,
    this.votes = 0,
    this.voters = const [],
  });

  factory PlaylistSongItem.fromJson(Map<String, dynamic> json) {
    return PlaylistSongItem(
      song: Track.fromJson(json['song'] ?? {}),
      addedById: json['added_by_id'] ?? '',
      addedByName: json['added_by_name'] ?? '',
      votes: json['votes'] ?? 0,
      voters: (json['voters'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
    );
  }
}

class PlaylistModel {
  final String id;
  final String title;
  final String description;
  final String creatorId;
  final String creatorName;
  final String type;
  final bool isPublic;
  final String? coverImage;
  final String? university;
  final String? department;
  final List<PlaylistSongItem> songs;

  PlaylistModel({
    required this.id,
    required this.title,
    this.description = '',
    required this.creatorId,
    required this.creatorName,
    this.type = 'personal',
    this.isPublic = true,
    this.coverImage,
    this.university,
    this.department,
    this.songs = const [],
  });

  factory PlaylistModel.fromJson(Map<String, dynamic> json) {
    var rawSongs = json['songs'] as List<dynamic>? ?? [];
    List<PlaylistSongItem> parsedSongs = [];
    for (var s in rawSongs) {
      if (s is Map<String, dynamic>) {
        parsedSongs.add(PlaylistSongItem.fromJson(s));
      }
    }

    return PlaylistModel(
      id: json['id'] ?? '',
      title: json['title'] ?? 'Playlist',
      description: json['description'] ?? '',
      creatorId: json['creator_id'] ?? '',
      creatorName: json['creator_name'] ?? 'Student',
      type: json['type'] ?? 'personal',
      isPublic: json['is_public'] ?? true,
      coverImage: json['cover_image'],
      university: json['university'],
      department: json['department'],
      songs: parsedSongs,
    );
  }
}
