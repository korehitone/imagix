class Post {
  final String id;
  final String title;
  final String description;
  final String image;
  final String userId;
  final String authorUsername;
  final String? authorPhoto;
  final int totalLikes;
  final int totalComments;
  final DateTime createdAt;

  const Post({
    required this.id,
    required this.title,
    required this.description,
    required this.image,
    required this.userId,
    required this.authorUsername,
    this.authorPhoto,
    required this.totalLikes,
    required this.totalComments,
    required this.createdAt,
  });
}
