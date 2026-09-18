class UserModel {
  final String userId;
  final String email;
  final String name;
  final String? username;
  final String? profileImage;
  final String? university;
  final String? department;
  final String? degree;
  final int? year;
  final int? semester;
  final String bio;
  final List<String> favoriteGenres;
  final List<String> likedSongs;
  final int studyMinutes;
  final int focusSessions;
  final int studyStreak;
  final List<String> achievements;
  final bool isStudentArtist;

  UserModel({
    required this.userId,
    required this.email,
    required this.name,
    this.username,
    this.profileImage,
    this.university,
    this.department,
    this.degree,
    this.year,
    this.semester,
    this.bio = '',
    this.favoriteGenres = const [],
    this.likedSongs = const [],
    this.studyMinutes = 0,
    this.focusSessions = 0,
    this.studyStreak = 1,
    this.achievements = const [],
    this.isStudentArtist = false,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      userId: json['user_id'] ?? '',
      email: json['email'] ?? '',
      name: json['name'] ?? '',
      username: json['username'],
      profileImage: json['profile_image'],
      university: json['university'],
      department: json['department'],
      degree: json['degree'],
      year: json['year'],
      semester: json['semester'],
      bio: json['bio'] ?? '',
      favoriteGenres: (json['favorite_genres'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      likedSongs: (json['liked_songs'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      studyMinutes: json['study_minutes'] ?? 0,
      focusSessions: json['focus_sessions'] ?? 0,
      studyStreak: json['study_streak'] ?? 1,
      achievements: (json['achievements'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      isStudentArtist: json['is_student_artist'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'email': email,
      'name': name,
      'username': username,
      'profile_image': profileImage,
      'university': university,
      'department': department,
      'degree': degree,
      'year': year,
      'semester': semester,
      'bio': bio,
      'favorite_genres': favoriteGenres,
      'liked_songs': likedSongs,
      'study_minutes': studyMinutes,
      'focus_sessions': focusSessions,
      'study_streak': studyStreak,
      'achievements': achievements,
      'is_student_artist': isStudentArtist,
    };
  }
}
