class FollowResponse {
  final int id; // Tetap int, gak usah nullable
  final String followerId;
  final String followingId;
  final DateTime createdAt;

  FollowResponse({
    required this.id,
    required this.followerId,
    required this.followingId,
    required this.createdAt,
  });

  factory FollowResponse.fromJson(Map<String, dynamic> json) => FollowResponse(
    id: json['id'] as int,
    followerId: json['follower_id'] as String,
    followingId: json['following_id'] as String,
    createdAt: DateTime.parse(json['created_at'] as String).toLocal(),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'follower_id': followerId,
    'following_id': followingId,
  };
}
