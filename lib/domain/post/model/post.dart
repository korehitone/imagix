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
  final bool isLiked;
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
    required this.isLiked,
    required this.createdAt,
  });

  Post toggleLike() {
    return copyWith(
      isLiked: !isLiked,
      totalLikes: isLiked ? totalLikes - 1 : totalLikes + 1,
    );
  }

  Post syncLikeState(bool finalIsLiked) {
    if (isLiked == finalIsLiked) return this; // Kalo udah sama, ya udah
    return copyWith(
      isLiked: finalIsLiked,
      totalLikes: finalIsLiked ? totalLikes + 1 : totalLikes - 1,
    );
  }

  Post updateCommentCount(bool isIncrement) {
    return copyWith(
      totalComments: isIncrement ? totalComments + 1 : totalComments - 1,
    );
  }

  Post copyWith({
    String? id,
    String? title,
    String? description,
    bool? isLiked,
    int? totalLikes,
    int? totalComments,
  }) {
    return Post(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      image: image,
      totalComments: totalComments ?? this.totalComments,
      userId: userId,
      authorUsername: authorUsername,
      createdAt: createdAt,
      isLiked: isLiked ?? this.isLiked,
      totalLikes: totalLikes ?? this.totalLikes,
    );
  }
}
