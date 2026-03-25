class CollectionItem {
  final int itemId;
  final String collectionId;
  final DateTime addedAt;
  final String postId;
  final String title;
  final String image;
  final String authorUsername;
  final int totalLikes;
  final int totalComments;

  CollectionItem({
    required this.itemId,
    required this.collectionId,
    required this.addedAt,
    required this.postId,
    required this.title,
    required this.image,
    required this.authorUsername,
    required this.totalLikes,
    required this.totalComments,
  });
}
