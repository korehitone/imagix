class Profile {
  final String id;
  final String? photo;
  final String username;
  final String? bio;
  final int totalPosts;
  final int totalCollections;
  final int totalFollowers;
  final int totalFollowings;
  final bool isFollowing;

  Profile({
    required this.id,
    this.photo,
    required this.username,
    this.bio,
    required this.totalPosts,
    required this.totalCollections,
    required this.totalFollowers,
    required this.totalFollowings,
    required this.isFollowing,
  });
}
