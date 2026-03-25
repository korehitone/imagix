class Profile {
  final String id;
  final String? photo;
  final String username;
  final String? bio;
  final int totalPosts;
  final int totalCollections;

  Profile({
    required this.id,
    this.photo,
    required this.username,
    this.bio,
    required this.totalPosts,
    required this.totalCollections,
  });
}
