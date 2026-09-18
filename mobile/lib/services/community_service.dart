import 'package:resonance/core/constants/api_constants.dart';
import 'package:resonance/core/network/api_client.dart';
import 'package:resonance/models/community_model.dart';
import 'package:resonance/models/track_model.dart';

class CommunityService {
  final ApiClient apiClient;

  CommunityService({required this.apiClient});

  Future<List<PostModel>> getFeed({String? university}) async {
    try {
      final res = await apiClient.dio.get(
        ApiConstants.communityFeed,
        queryParameters: university != null ? {'university': university} : null,
      );
      if (res.statusCode == 200) {
        final list = res.data as List<dynamic>;
        return list.map((json) => PostModel.fromJson(json)).toList();
      }
    } catch (_) {}
    return _getFallbackPosts();
  }

  Future<PostModel?> createPost({required String content, Track? songAttachment}) async {
    try {
      final res = await apiClient.dio.post(
        ApiConstants.communityPost,
        data: {
          'content': content,
          'song_attachment': songAttachment?.toJson(),
        },
      );
      if (res.statusCode == 200) {
        return PostModel.fromJson(res.data);
      }
    } catch (_) {}
    return null;
  }

  Future<bool> likePost(String postId) async {
    try {
      final res = await apiClient.dio.post('/api/community/posts/$postId/like');
      if (res.statusCode == 200) {
        return res.data['is_liked'] ?? false;
      }
    } catch (_) {}
    return false;
  }

  Future<List<EventModel>> getEvents({String? university}) async {
    try {
      final res = await apiClient.dio.get(
        ApiConstants.events,
        queryParameters: university != null ? {'university': university} : null,
      );
      if (res.statusCode == 200) {
        final list = res.data as List<dynamic>;
        return list.map((json) => EventModel.fromJson(json)).toList();
      }
    } catch (_) {}
    return [
      EventModel(
        id: 'event_acoustics_1',
        university: 'Gauhati University',
        name: 'Acoustic Sunset by the Lake',
        description: 'Student singer-songwriters showcase their original indie and acoustic music.',
        date: 'Tomorrow, Oct 24',
        time: '5:30 PM',
        location: 'Campus Amphitheatre',
        organizer: 'Resonance Music Club',
        image: 'https://images.unsplash.com/photo-1514525253161-7a46d19cd819?w=600',
        attendeesCount: 38,
      ),
      EventModel(
        id: 'event_hack_beats_2',
        university: 'Gauhati University',
        name: 'Hackathon Synth & Beats Night',
        description: 'Live continuous DJ set paired with 24-hour campus hackathon sprint.',
        date: 'Saturday, Nov 02',
        time: '8:00 PM',
        location: 'CSE Seminar Hall',
        organizer: 'Coding & Tech Society',
        image: 'https://images.unsplash.com/photo-1501386761578-eac5c94b800a?w=600',
        attendeesCount: 92,
      ),
    ];
  }

  Future<bool> rsvpEvent(String eventId) async {
    try {
      final res = await apiClient.dio.post('/api/events/$eventId/rsvp');
      if (res.statusCode == 200) {
        return res.data['status'] == 'registered';
      }
    } catch (_) {}
    return false;
  }

  List<PostModel> _getFallbackPosts() {
    return [
      PostModel(
        id: 'post_1',
        communityId: 'comm_general',
        university: 'Gauhati University',
        userId: 'user_rahul',
        authorName: 'Rahul Barman',
        authorImage: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150',
        content: 'Late night OS lab assignment deadline! This synth track is keeping the brain cells alive ⚡',
        songAttachment: Track(
          id: 'study_synth_6',
          title: 'Late Night Terminal',
          artist: 'Cyber Scholar',
          album: 'Hex & Synth',
          duration: 200,
          artworkUrl: 'https://images.unsplash.com/photo-1526374965328-7f61d4dc18c5?w=500',
          streamUrl: 'https://cdn.pixabay.com/download/audio/2023/04/18/audio_651f65d645.mp3?filename=synthwave-80s-110045.mp3',
          genre: 'Synthwave',
        ),
        likesCount: 18,
        commentsCount: 4,
      ),
      PostModel(
        id: 'post_2',
        communityId: 'comm_library',
        university: 'Gauhati University',
        userId: 'user_priya',
        authorName: 'Priya Das',
        authorImage: 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=150',
        content: 'Anyone studying in Central Library 2nd floor? Rain sounds outside + Lo-Fi in headphones = 100% focus ✨',
        songAttachment: Track(
          id: 'study_lofi_1',
          title: 'Midnight Campus Lo-Fi',
          artist: 'Resonance Focus Lab',
          album: 'Semester Beats Vol. 1',
          duration: 185,
          artworkUrl: 'https://images.unsplash.com/photo-1518495973542-4542c06a5843?w=500',
          streamUrl: 'https://cdn.pixabay.com/download/audio/2022/05/27/audio_1808fbf07a.mp3?filename=lofi-study-112191.mp3',
          genre: 'Lo-Fi',
        ),
        likesCount: 24,
        commentsCount: 7,
      ),
    ];
  }
}
