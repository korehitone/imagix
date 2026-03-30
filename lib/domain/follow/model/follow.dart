class Follow {
  final String userId;
  final String username;
  final String? photo;
  final bool isFollowing;

  Follow({
    required this.userId,
    required this.username,
    this.photo,
    required this.isFollowing,
  });
}
