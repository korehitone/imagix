import 'package:imagix/domain/profile/model/profile.dart';

class ProfileResponse {
  final String id;
  final String? photo;
  final String username;
  final String? bio;
  final int totalPosts;
  final int totalCollections;
  final int totalFollowers;
  final int totalFollowings;
  final bool isFollowing;

  ProfileResponse({
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

  factory ProfileResponse.fromJson(Map<String, dynamic> json) =>
      ProfileResponse(
        id: json['id'] as String,
        photo: json['photo'] as String?,
        username: json['username'] as String,
        bio: json['bio'] as String?,
        totalPosts: json['total_posts'] as int,
        totalCollections: json['total_collections'] as int,
        totalFollowers: json['total_followers'] as int,
        totalFollowings: json['total_followings'] as int,
        isFollowing: json['is_followed_by_me'] as bool,
      );

  Profile toDomain() => Profile(
    id: id,
    photo: photo,
    username: username,
    bio: bio,
    totalPosts: totalPosts,
    totalCollections: totalCollections,
    totalFollowings: totalFollowings,
    totalFollowers: totalFollowers,
    isFollowing: isFollowing,
  );
}
