class PostResponse {
  final String id;
  final String title;
  final String description;
  final String image;
  final String userId;
  final DateTime createdAt;
  final DateTime updatedAt;

  PostResponse({
    required this.id,
    required this.title,
    required this.description,
    required this.image,
    required this.userId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory PostResponse.fromJson(Map<String, dynamic> json) => PostResponse(
    id: json['id'] as String,
    title: json['title'] as String,
    description: json['description'] as String,
    image: json['image'] as String,
    userId: json['user_id'] as String,
    createdAt: DateTime.parse(json['created_at'] as String).toLocal(),
    updatedAt: DateTime.parse(json['updated_at'] as String).toLocal(),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'description': description,
    'image': image,
    'user_id': userId,
  };

  PostResponse copyWith({
    String? id,
    String? title,
    String? description,
    String? image,
    String? userId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PostResponse(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      image: image ?? this.image,
      userId: userId ?? this.userId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
