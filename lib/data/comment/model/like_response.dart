class LikeResponse {
  final int id;
  final String postId;
  final String userId;
  final DateTime createdAt;

  LikeResponse({
    required this.id,
    required this.postId,
    required this.userId,
    required this.createdAt,
  });

  factory LikeResponse.fromJson(Map<String, dynamic> json) => LikeResponse(
    id: json['id'] as int,
    postId: json['post_id'] as String,
    userId: json['user_id'] as String,
    createdAt: DateTime.parse(json['created_at'] as String).toLocal(),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'post_id': postId,
    'user_id': userId,
  };
}
