class CommentRequest {
  final String postId;
  final int? parentId;
  final String comment;

  const CommentRequest({
    required this.postId,
    this.parentId,
    required this.comment,
  });
}
