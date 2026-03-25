import 'package:imagix/domain/post/model/post.dart';

class PostListViewResponse {
  final String id;
  final String title;
  final String description;
  final String image;
  final String userId;
  final String authorUsername;
  final String? authorPhoto;
  final int totalLikes;
  final int totalComments;
  final DateTime createdAt;
  final DateTime updatedAt;

  PostListViewResponse({
    required this.id,
    required this.title,
    required this.description,
    required this.image,
    required this.userId,
    required this.authorUsername,
    this.authorPhoto,
    required this.totalLikes,
    required this.totalComments,
    required this.createdAt,
    required this.updatedAt,
  });

  factory PostListViewResponse.fromJson(Map<String, dynamic> json) =>
      PostListViewResponse(
        id: json['id'] as String,
        title: json['title'] as String,
        description: json['description'] as String,
        image: json['image'] as String,
        userId: json['user_id'] as String,
        authorUsername: json['author_username'] as String,
        authorPhoto: json['author_photo'] as String?,
        totalLikes: json['total_likes'] as int,
        totalComments: json['total_comments'] as int,
        createdAt: DateTime.parse(json['created_at'] as String).toLocal(),
        updatedAt: DateTime.parse(json['updated_at'] as String).toLocal(),
      );

  Post toDomain() => Post(
    id: id,
    title: title,
    description: description,
    image: image,
    userId: userId,
    authorUsername: authorUsername,
    totalLikes: totalLikes,
    totalComments: totalComments,
    createdAt: createdAt,
  );
}
