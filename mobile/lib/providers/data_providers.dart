import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:resonance/models/track_model.dart';
import 'package:resonance/models/community_model.dart';
import 'package:resonance/models/study_session_model.dart';
import 'package:resonance/providers/core_providers.dart';

final trendingTracksProvider = FutureProvider<List<Track>>((ref) async {
  final musicService = ref.watch(musicServiceProvider);
  return await musicService.getTrending(limit: 20);
});

final studyTracksProvider = FutureProvider<List<Track>>((ref) async {
  final musicService = ref.watch(musicServiceProvider);
  return await musicService.getStudyTracks(vibe: 'lofi', limit: 15);
});

final campusFeedProvider = FutureProvider<List<PostModel>>((ref) async {
  final communityService = ref.watch(communityServiceProvider);
  return await communityService.getFeed();
});

final campusEventsProvider = FutureProvider<List<EventModel>>((ref) async {
  final communityService = ref.watch(communityServiceProvider);
  return await communityService.getEvents();
});

final studyRoomsProvider = FutureProvider<List<StudyRoomModel>>((ref) async {
  final studyService = ref.watch(studyServiceProvider);
  return await studyService.getRooms();
});

final studyStatsProvider = FutureProvider<StudyStatsModel>((ref) async {
  final studyService = ref.watch(studyServiceProvider);
  return await studyService.getStats();
});
