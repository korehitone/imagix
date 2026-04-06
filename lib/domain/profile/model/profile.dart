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

  Profile copyWith({
    String? id,
    String? photo,
    String? username,
    String? bio,
    int? totalPosts,
    int? totalCollections,
    int? totalFollowers,
    int? totalFollowings,
    bool? isFollowing,
  }) => Profile(
    // Kalau ada data baru pake data baru, kalau gak ada pake data lama (this)
    id: id ?? this.id,
    photo: photo ?? this.photo,
    username: username ?? this.username,
    bio: bio ?? this.bio,
    totalPosts: totalPosts ?? this.totalPosts,
    totalCollections: totalCollections ?? this.totalCollections,
    totalFollowers: totalFollowers ?? this.totalFollowers,
    totalFollowings: totalFollowings ?? this.totalFollowings,
    isFollowing: isFollowing ?? this.isFollowing,
  );
}
