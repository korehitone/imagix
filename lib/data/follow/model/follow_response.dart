class FollowResponse {
  final int followId;
  final DateTime createdAt;
  final String followerId;
  final String followerUsername;
  final String? followerPhoto;
  final String followingId;
  final String followingUsername;
  final String? followingPhoto;
  final bool isFollowing;

  FollowResponse({
    required this.followId,
    required this.createdAt,
    required this.followerId,
    required this.followerUsername,
    this.followerPhoto,
    required this.followingId,
    required this.followingUsername,
    this.followingPhoto,
    required this.isFollowing,
  });

  factory FollowResponse.fromJson(Map<String, dynamic> json) => FollowResponse(
    followId: json['follow_id'] as int,
    createdAt: DateTime.parse(json['created_at'] as String).toLocal(),
    followerId: json['follower_id'] as String,
    followerUsername: json['follower_username'] as String,
    followerPhoto: json['follower_photo'] as String?,
    followingId: json['following_id'] as String,
    followingUsername: json['following_username'] as String,
    followingPhoto: json['following_photo'] as String?,
    isFollowing: json['is_followed_by_me'] as bool,
  );
}
