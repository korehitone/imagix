class CommentResponse {
  final int id;
  final String postId;
  final String userId;
  final int? parentId; // Nullable untuk main comment, isi ID jika reply
  final String comment;
  final DateTime createdAt;
  final DateTime updatedAt;

  CommentResponse({
    required this.id,
    required this.postId,
    required this.userId,
    this.parentId,
    required this.comment,
    required this.createdAt,
    required this.updatedAt,
  });

  factory CommentResponse.fromJson(Map<String, dynamic> json) =>
      CommentResponse(
        id: json['id'] as int,
        postId: json['post_id'] as String,
        userId: json['user_id'] as String,
        parentId: json['parent_id'] as int?,
        comment: json['comment'] as String,
        createdAt: DateTime.parse(json['created_at'] as String).toLocal(),
        updatedAt: DateTime.parse(json['updated_at'] as String).toLocal(),
      );

  Map<String, dynamic> toJson() => {
    'id': id,
    'post_id': postId,
    'user_id': userId,
    'parent_id': parentId,
    'comment': comment,
  };

  CommentResponse copyWith({
    int? id,
    String? postId,
    String? userId,
    int? parentId,
    String? comment,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CommentResponse(
      id: id ?? this.id,
      postId: postId ?? this.postId,
      userId: userId ?? this.userId,
      parentId: parentId ?? this.parentId,
      comment: comment ?? this.comment,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
