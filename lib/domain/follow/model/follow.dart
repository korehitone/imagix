class Follow {
  final int followId;
  final String userId;
  final String username;
  final String? photo;

  Follow({
    required this.followId,
    required this.userId,
    required this.username,
    this.photo,
  });
}
