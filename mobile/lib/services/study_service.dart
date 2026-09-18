import 'package:resonance/core/constants/api_constants.dart';
import 'package:resonance/core/network/api_client.dart';
import 'package:resonance/models/study_session_model.dart';

class StudyService {
  final ApiClient apiClient;

  StudyService({required this.apiClient});

  Future<Map<String, dynamic>?> logSession({
    required int durationMinutes,
    String sessionType = 'pomodoro',
    String? notes,
  }) async {
    try {
      final res = await apiClient.dio.post(
        ApiConstants.studySession,
        data: {
          'duration_minutes': durationMinutes,
          'session_type': sessionType,
          'notes': notes ?? '',
        },
      );
      if (res.statusCode == 200) {
        return res.data;
      }
    } catch (_) {}
    return null;
  }

  Future<StudyStatsModel> getStats() async {
    try {
      final res = await apiClient.dio.get(ApiConstants.studyStats);
      if (res.statusCode == 200) {
        return StudyStatsModel.fromJson(res.data);
      }
    } catch (_) {}
    return StudyStatsModel(
      totalMinutes: 180,
      totalSessions: 6,
      currentStreak: 4,
      longestStreak: 7,
      weeklyMinutes: [25, 45, 50, 30, 60, 45, 50],
      topStudyGenre: 'Lo-Fi Beats',
    );
  }

  Future<List<StudyRoomModel>> getRooms() async {
    try {
      final res = await apiClient.dio.get(ApiConstants.studyRooms);
      if (res.statusCode == 200) {
        final list = res.data as List<dynamic>;
        return list.map((json) => StudyRoomModel.fromJson(json)).toList();
      }
    } catch (_) {}
    return [
      StudyRoomModel(
        id: 'room_dsa_focus',
        university: 'Gauhati University',
        name: 'DSA & LeetCode Sprint',
        description:
            'Silent focus room for algorithm practice and problem solving.',
        activeStudentsCount: 14,
      ),
      StudyRoomModel(
        id: 'room_deep_work',
        university: 'Gauhati University',
        name: 'Quiet Campus Library Hall',
        description:
            'Rain acoustics and soft ambient lo-fi for reading & writing.',
        activeStudentsCount: 22,
      ),
    ];
  }

  Future<void> joinRoom(String roomId) async {
    try {
      await apiClient.dio.post('/api/study/rooms/$roomId/join');
    } catch (_) {}
  }

  Future<void> leaveRoom(String roomId) async {
    try {
      await apiClient.dio.post('/api/study/rooms/$roomId/leave');
    } catch (_) {}
  }
}
