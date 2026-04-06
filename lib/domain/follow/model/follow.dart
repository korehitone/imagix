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

  Follow copyWith({
    String? userId,
    String? username,
    String? photo,
    bool? isFollowing,
  }) => Follow(
    userId: userId ?? this.userId,
    username: username ?? this.username,
    photo: photo ?? this.photo,
    isFollowing: isFollowing ?? this.isFollowing,
  );
}
