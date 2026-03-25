class UserProfile {
  final String id;
  final String username;
  final String email;
  final String bio;
  final String photo;
  final int totalPosts;
  final int totalCollections;

  UserProfile({
    required this.id,
    required this.username,
    required this.email,
    required this.bio,
    required this.photo,
    this.totalPosts = 0,
    this.totalCollections = 0,
  });

  // Untuk convert dari Map (JSON) ke Object
  factory UserProfile.fromJson(Map<String, dynamic> json) => UserProfile(
    id: json['id'],
    username: json['username'],
    email: json['email'],
    bio: json['bio'],
    photo: json['photo'],
    totalPosts: json['total_posts'] ?? 0,
    totalCollections: json['total_collections'] ?? 0,
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
  };
}
