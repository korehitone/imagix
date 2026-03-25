import 'package:imagix/domain/profile/model/profile.dart';

class ProfileViewResponse {
  final String id;
  final String? photo;
  final String username;
  final String? bio;
  final int totalPosts;
  final int totalCollections;

  ProfileViewResponse({
    required this.id,
    this.photo,
    required this.username,
    this.bio,
    required this.totalPosts,
    required this.totalCollections,
  });

  factory ProfileViewResponse.fromJson(Map<String, dynamic> json) =>
      ProfileViewResponse(
        id: json['id'] as String,
        photo: json['photo'] as String?,
        username: json['username'] as String,
        bio: json['bio'] as String?,
        totalPosts: json['total_posts'] as int,
        totalCollections: json['total_collections'] as int,
      );

  Profile toDomain() => Profile(
    id: id,
    photo: photo,
    username: username,
    bio: bio,
    totalPosts: totalPosts,
    totalCollections: totalCollections,
  );
}
