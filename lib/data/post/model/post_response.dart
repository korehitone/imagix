import 'package:imagix/domain/post/model/post.dart';

class PostResponse {
  final String id;
  final String title;
  final String description;
  final String image;
  final String userId;
  final String authorUsername;
  final String? authorPhoto;
  final int totalLikes;
  final int totalComments;
  final bool isLiked;
  final DateTime createdAt;
  final DateTime updatedAt;

  PostResponse({
    required this.id,
    required this.title,
    required this.description,
    required this.image,
    required this.userId,
    required this.authorUsername,
    this.authorPhoto,
    required this.totalLikes,
    required this.totalComments,
    required this.isLiked,
    required this.createdAt,
    required this.updatedAt,
  });

  factory PostResponse.fromJson(Map<String, dynamic> json) => PostResponse(
    id: json['id'] as String,
    title: json['title'] as String,
    description: json['description'] as String,
    image: json['image'] as String,
    userId: json['user_id'] as String,
    authorUsername: json['author_username'] as String,
    authorPhoto: json['author_photo'] as String?,
    totalLikes: json['total_likes'] as int,
    totalComments: json['total_comments'] as int,
    isLiked: json['is_liked'] as bool,
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
    isLiked: isLiked,
    createdAt: createdAt,
  );
}
