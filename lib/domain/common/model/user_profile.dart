import 'package:imagix/domain/profile/model/profile.dart';

class UserProfile {
  final String id;
  final String username;
  final String? email;
  final String? bio;
  final String? photo;
  final int totalPosts;
  final int totalCollections;
  final int totalFollowers;
  final int totalFollowings;

  UserProfile({
    required this.id,
    required this.username,
    required this.email,
    required this.bio,
    required this.photo,
    this.totalPosts = 0,
    this.totalCollections = 0,
    this.totalFollowers = 0,
    this.totalFollowings = 0,
  });

  UserProfile copyWith({
    String? id,
    String? username,
    String? email,
    String? bio,
    String? photo,
    int? totalPosts,
    int? totalCollections,
    int? totalFollowers,
    int? totalFollowings,
  }) => UserProfile(
    id: id ?? this.id,
    username: username ?? this.username,
    email: email ?? this.email,
    bio: bio ?? this.bio,
    photo: photo ?? this.photo,
    totalPosts: totalPosts ?? this.totalPosts,
    totalCollections: totalCollections ?? this.totalCollections,
    totalFollowers: totalFollowers ?? this.totalFollowers,
    totalFollowings: totalFollowings ?? this.totalFollowings,
  );

  Profile toDomain() => Profile(
    id: id,
    username: username,
    totalPosts: totalPosts,
    photo: photo,
    bio: bio,
    totalCollections: totalCollections,
    totalFollowers: totalFollowers,
    totalFollowings: totalFollowings,
    isFollowing: false,
  );

  // Untuk convert dari Map (JSON) ke Object
  factory UserProfile.fromJson(Map<String, dynamic> json) => UserProfile(
    id: json['id'],
    username: json['username'],
    email: json['email'],
    bio: json['bio'],
    photo: json['photo'],
    totalPosts: json['total_posts'] ?? 0,
    totalCollections: json['total_collections'] ?? 0,
    totalFollowers: json['total_followers'] ?? 0,
    totalFollowings: json['total_followings'] ?? 0,
  );

  // Untuk convert dari Object ke Map (JSON) buat disimpan
  Map<String, dynamic> toJson() => {
    'id': id,
    'username': username,
    'email': email,
    'bio': bio,
    'photo': photo,
    'total_posts': totalPosts,
    'total_collections': totalCollections,
    'total_followers': totalFollowers,
    'total_followings': totalFollowings,
  };
}
