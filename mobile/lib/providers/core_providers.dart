import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:resonance/core/network/api_client.dart';
import 'package:resonance/core/storage/secure_storage_service.dart';
import 'package:resonance/services/audio_player_service.dart';
import 'package:resonance/services/auth_service.dart';
import 'package:resonance/services/music_service.dart';
import 'package:resonance/services/study_service.dart';
import 'package:resonance/services/community_service.dart';
import 'package:resonance/services/ai_service.dart';
import 'package:resonance/services/playlist_service.dart';
import 'package:resonance/services/update_service.dart';

final secureStorageProvider = Provider<SecureStorageService>((ref) {
  return SecureStorageService();
});

final apiClientProvider = Provider<ApiClient>((ref) {
  final storage = ref.watch(secureStorageProvider);
  return ApiClient(storageService: storage);
});

final authServiceProvider = Provider<AuthService>((ref) {
  final client = ref.watch(apiClientProvider);
  final storage = ref.watch(secureStorageProvider);
  return AuthService(apiClient: client, storageService: storage);
});

final musicServiceProvider = Provider<MusicService>((ref) {
  final client = ref.watch(apiClientProvider);
  return MusicService(apiClient: client);
});

final playlistServiceProvider = Provider<PlaylistService>((ref) {
  final client = ref.watch(apiClientProvider);
  return PlaylistService(apiClient: client);
});

final studyServiceProvider = Provider<StudyService>((ref) {
  final client = ref.watch(apiClientProvider);
  return StudyService(apiClient: client);
});

final communityServiceProvider = Provider<CommunityService>((ref) {
  final client = ref.watch(apiClientProvider);
  return CommunityService(apiClient: client);
});

final aiServiceProvider = Provider<AIService>((ref) {
  final client = ref.watch(apiClientProvider);
  return AIService(apiClient: client);
});

final updateServiceProvider = Provider<UpdateService>((ref) {
  final client = ref.watch(apiClientProvider);
  return UpdateService(apiClient: client);
});

final audioPlayerServiceProvider = Provider<AudioPlayerService>((ref) {
  final service = AudioPlayerService();
  ref.onDispose(() => service.dispose());
  return service;
});
