class Comment {
  final int id;
  final String postId;
  final String userId;
  final int?
  parentId; // Kalau null berarti komentar utama, kalau ada isi berarti reply
  final String comment;
  final String username;
  final String? userPhoto;
  final DateTime createdAt;
  final List<Comment> replies;

  const Comment({
    required this.id,
    required this.postId,
    required this.userId,
    this.parentId,
    required this.comment,
    required this.username,
    this.userPhoto,
    required this.createdAt,
    this.replies = const [],
  });

  Comment copyWith({List<Comment>? replies}) => Comment(
    id: id,
    postId: postId,
    userId: userId,
    parentId: parentId,
    comment: comment,
    username: username,
    userPhoto: userPhoto,
    createdAt: createdAt,
    replies: replies ?? this.replies,
  );
}
