class Track {
  final String id;
  final String title;
  final String artist;
  final String? artistId;
  final String? album;
  final int duration;
  final String? artworkUrl;
  final String streamUrl;
  final String genre;
  final String provider;
  final bool isLiked;

  Track({
    required this.id,
    required this.title,
    required this.artist,
    this.artistId,
    this.album,
    this.duration = 0,
    this.artworkUrl,
    required this.streamUrl,
    this.genre = 'General',
    this.provider = 'audius',
    this.isLiked = false,
  });

  factory Track.fromJson(Map<String, dynamic> json) {
    return Track(
      id: json['id']?.toString() ?? '',
      title: json['title'] ?? 'Unknown Track',
      artist: json['artist'] ?? 'Unknown Artist',
      artistId: json['artist_id']?.toString(),
      album: json['album'],
      duration: json['duration'] is int ? json['duration'] : int.tryParse(json['duration']?.toString() ?? '0') ?? 0,
      artworkUrl: json['artwork_url'],
      streamUrl: json['stream_url'] ?? '',
      genre: json['genre'] ?? 'General',
      provider: json['provider'] ?? 'audius',
      isLiked: json['is_liked'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'artist': artist,
      'artist_id': artistId,
      'album': album,
      'duration': duration,
      'artwork_url': artworkUrl,
      'stream_url': streamUrl,
      'genre': genre,
      'provider': provider,
      'is_liked': isLiked,
    };
  }

  Track copyWith({bool? isLiked}) {
    return Track(
      id: id,
      title: title,
      artist: artist,
      artistId: artistId,
      album: album,
      duration: duration,
      artworkUrl: artworkUrl,
      streamUrl: streamUrl,
      genre: genre,
      provider: provider,
      isLiked: isLiked ?? this.isLiked,
    );
  }
}
