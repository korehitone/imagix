import 'package:imagix/domain/collection/model/collection.dart';

class CollectionListViewResponse {
  final String id;
  final String userId;
  final String title;
  final int totalItems;
  final String? coverImage;
  final DateTime createdAt;
  final DateTime updatedAt;

  CollectionListViewResponse({
    required this.id,
    required this.userId,
    required this.title,
    required this.totalItems,
    this.coverImage,
    required this.createdAt,
    required this.updatedAt,
  });

  factory CollectionListViewResponse.fromJson(Map<String, dynamic> json) =>
      CollectionListViewResponse(
        id: json['id'] as String,
        userId: json['user_id'] as String,
        title: json['title'] as String,
        totalItems: json['total_items'] as int,
        coverImage: json['cover_image'] as String?,
        createdAt: DateTime.parse(json['created_at'] as String).toLocal(),
        updatedAt: DateTime.parse(json['updated_at'] as String).toLocal(),
      );

  Collection toDomain() => Collection(
    id: id,
    userId: userId,
    title: title,
    createdAt: createdAt,
    updatedAt: updatedAt,
  );
}
