import 'package:resonance/models/track_model.dart';

class PostModel {
  final String id;
  final String communityId;
  final String university;
  final String userId;
  final String authorName;
  final String? authorImage;
  final String content;
  final Track? songAttachment;
  final List<String> likes;
  final int likesCount;
  final int commentsCount;
  final bool isLikedByMe;

  PostModel({
    required this.id,
    required this.communityId,
    required this.university,
    required this.userId,
    required this.authorName,
    this.authorImage,
    required this.content,
    this.songAttachment,
    this.likes = const [],
    this.likesCount = 0,
    this.commentsCount = 0,
    this.isLikedByMe = false,
  });

  factory PostModel.fromJson(Map<String, dynamic> json,
      {String? currentUserId}) {
    List<String> likesList =
        (json['likes'] as List<dynamic>?)?.map((e) => e.toString()).toList() ??
            [];
    return PostModel(
      id: json['id'] ?? '',
      communityId: json['community_id'] ?? '',
      university: json['university'] ?? '',
      userId: json['user_id'] ?? '',
      authorName: json['author_name'] ?? 'Student',
      authorImage: json['author_image'],
      content: json['content'] ?? '',
      songAttachment: json['song_attachment'] != null
          ? Track.fromJson(json['song_attachment'])
          : null,
      likes: likesList,
      likesCount: json['likes_count'] ?? likesList.length,
      commentsCount: json['comments_count'] ?? 0,
      isLikedByMe: currentUserId != null && likesList.contains(currentUserId),
    );
  }
}

class EventModel {
  final String id;
  final String university;
  final String name;
  final String description;
  final String date;
  final String time;
  final String location;
  final String organizer;
  final String? image;
  final int attendeesCount;
  final bool isAttending;

  EventModel({
    required this.id,
    required this.university,
    required this.name,
    required this.description,
    required this.date,
    required this.time,
    required this.location,
    required this.organizer,
    this.image,
    this.attendeesCount = 0,
    this.isAttending = false,
  });

  factory EventModel.fromJson(Map<String, dynamic> json) {
    return EventModel(
      id: json['id'] ?? '',
      university: json['university'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      date: json['date'] ?? '',
      time: json['time'] ?? '',
      location: json['location'] ?? '',
      organizer: json['organizer'] ?? '',
      image: json['image'],
      attendeesCount: json['attendees_count'] ?? 0,
      isAttending: json['is_attending'] ?? false,
    );
  }
}
