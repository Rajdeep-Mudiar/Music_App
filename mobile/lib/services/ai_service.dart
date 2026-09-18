import 'package:resonance/core/constants/api_constants.dart';
import 'package:resonance/core/network/api_client.dart';
import 'package:resonance/models/track_model.dart';

class AIResponse {
  final String reply;
  final List<Map<String, dynamic>> toolCalls;
  final List<Track> suggestedTracks;

  AIResponse({
    required this.reply,
    this.toolCalls = const [],
    this.suggestedTracks = const [],
  });

  factory AIResponse.fromJson(Map<String, dynamic> json) {
    var tracksRaw = json['suggested_tracks'] as List<dynamic>? ?? [];
    return AIResponse(
      reply: json['reply'] ?? '',
      toolCalls: (json['tool_calls'] as List<dynamic>?)
              ?.map((e) => e as Map<String, dynamic>)
              .toList() ??
          [],
      suggestedTracks: tracksRaw.map((e) => Track.fromJson(e)).toList(),
    );
  }
}

class AIService {
  final ApiClient apiClient;

  AIService({required this.apiClient});

  Future<AIResponse> sendChatMessage(String message,
      {String? currentTrackId}) async {
    try {
      final res = await apiClient.dio.post(
        ApiConstants.aiChat,
        data: {
          'message': message,
          'current_track_id': currentTrackId,
        },
      );
      if (res.statusCode == 200) {
        return AIResponse.fromJson(res.data);
      }
    } catch (_) {}

    // Fallback response with study tracks
    return AIResponse(
      reply:
          "Here's a curated selection of campus focus beats to keep your workflow steady!",
      suggestedTracks: [
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
      ],
    );
  }

  Future<Map<String, dynamic>?> generateStudyPlan(String prompt,
      {double hours = 2.0}) async {
    try {
      final res = await apiClient.dio.post(
        ApiConstants.aiGeneratePlaylist,
        data: {
          'prompt': prompt,
          'duration_hours': hours,
        },
      );
      if (res.statusCode == 200) {
        return res.data;
      }
    } catch (_) {}
    return null;
  }
}
