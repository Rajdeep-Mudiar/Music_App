class StudyStatsModel {
  final int totalMinutes;
  final int totalSessions;
  final int currentStreak;
  final int longestStreak;
  final List<int> weeklyMinutes;
  final String topStudyGenre;

  StudyStatsModel({
    required this.totalMinutes,
    required this.totalSessions,
    required this.currentStreak,
    required this.longestStreak,
    required this.weeklyMinutes,
    this.topStudyGenre = 'Lo-Fi',
  });

  factory StudyStatsModel.fromJson(Map<String, dynamic> json) {
    return StudyStatsModel(
      totalMinutes: json['total_minutes'] ?? 0,
      totalSessions: json['total_sessions'] ?? 0,
      currentStreak: json['current_streak'] ?? 1,
      longestStreak: json['longest_streak'] ?? 1,
      weeklyMinutes: (json['weekly_minutes'] as List<dynamic>?)?.map((e) => (e as num).toInt()).toList() ?? [0, 0, 0, 0, 0, 0, 0],
      topStudyGenre: json['top_study_genre'] ?? 'Lo-Fi',
    );
  }
}

class StudyRoomModel {
  final String id;
  final String university;
  final String name;
  final String description;
  final int activeStudentsCount;

  StudyRoomModel({
    required this.id,
    required this.university,
    required this.name,
    required this.description,
    required this.activeStudentsCount,
  });

  factory StudyRoomModel.fromJson(Map<String, dynamic> json) {
    return StudyRoomModel(
      id: json['id'] ?? '',
      university: json['university'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      activeStudentsCount: json['active_students_count'] ?? 0,
    );
  }
}
