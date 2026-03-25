class UserResponse {
  final String id;
  final String username;
  final String? photo;
  final String? bio;
  final DateTime createdAt;
  final DateTime updatedAt;

  UserResponse({
    required this.id,
    required this.username,
    this.photo,
    this.bio,
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserResponse.fromJson(Map<String, dynamic> json) => UserResponse(
    id: json['id'] as String,
    username: json['username'] as String,
    photo: json['photo'] as String?,
    bio: json['bio'] as String?,
    createdAt: DateTime.parse(json['created_at'] as String).toLocal(),
    updatedAt: DateTime.parse(json['updated_at'] as String).toLocal(),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'username': username,
    'photo': photo,
    'bio': bio,
  };

  UserResponse copyWith({
    String? id,
    String? username,
    String? photo,
    String? bio,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserResponse(
      id: id ?? this.id,
      username: username ?? this.username,
      photo: photo ?? this.photo,
      bio: bio ?? this.bio,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
