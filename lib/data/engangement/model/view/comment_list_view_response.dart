import '../../../../domain/engangement/model/comment.dart';

class CommentListViewResponse {
  final int id;
  final String postId;
  final String userId;
  final int? parentId;
  final String comment;
  final String username;
  final String? userPhoto;
  final DateTime createdAt;
  final DateTime updatedAt;

  CommentListViewResponse({
    required this.id,
    required this.postId,
    required this.userId,
    this.parentId,
    required this.comment,
    required this.username,
    this.userPhoto,
    required this.createdAt,
    required this.updatedAt,
  });

  factory CommentListViewResponse.fromJson(Map<String, dynamic> json) =>
      CommentListViewResponse(
        id: json['id'] as int,
        postId: json['post_id'] as String,
        userId: json['user_id'] as String,
        parentId: json['parent_id'] as int?,
        comment: json['comment'] as String,
        username: json['username'] as String,
        userPhoto: json['user_photo'] as String?,
        createdAt: DateTime.parse(json['created_at'] as String).toLocal(),
        updatedAt: DateTime.parse(json['updated_at'] as String).toLocal(),
      );

  Comment toDomain() => Comment(
    id: id,
    postId: postId,
    userId: userId,
    parentId: parentId,
    comment: comment,
    username: username,
    userPhoto: userPhoto,
    createdAt: createdAt,
  );
}
