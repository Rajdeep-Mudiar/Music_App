import 'package:flutter/foundation.dart';

class ApiConstants {
  // Support --dart-define=API_BASE_URL=https://...
  static String get baseUrl {
    const envUrl = String.fromEnvironment('API_BASE_URL');
    if (envUrl.isNotEmpty) {
      return envUrl;
    }
    if (kIsWeb) {
      return 'http://localhost:8000';
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return 'http://10.0.2.2:8000'; // Android emulator localhost
      default:
        return 'http://localhost:8000';
    }
  }

  // Auth endpoints
  static const String authGoogle = '/api/auth/google';
  static const String authDemo = '/api/auth/demo';
  static const String authRefresh = '/api/auth/refresh';
  static const String authMe = '/api/auth/me';
  static const String authLogout = '/api/auth/logout';

  // Users
  static const String userProfile = '/api/users/profile';
  static const String userOnboarding = '/api/users/onboarding';

  // Music
  static const String musicTrending = '/api/music/trending';
  static const String musicSearch = '/api/music/search';
  static const String musicStudyTracks = '/api/music/study-tracks';

  // Playlists
  static const String playlists = '/api/playlists';
  static const String playlistsMy = '/api/playlists/me';
  static const String playlistsCampus = '/api/playlists/campus';

  // Study
  static const String studySession = '/api/study/session';
  static const String studyStats = '/api/study/stats';
  static const String studyRooms = '/api/study/rooms';

  // Community & Events
  static const String communityFeed = '/api/community/feed';
  static const String communityPost = '/api/community/posts';
  static const String campusChart = '/api/community/campus-chart';
  static const String campusVibe = '/api/community/campus-vibe';
  static const String events = '/api/events';

  // AI & Voice
  static const String aiChat = '/api/ai/chat';
  static const String aiGeneratePlaylist = '/api/ai/generate-playlist';

  // App Version
  static const String appVersion = '/api/app/version';
}
