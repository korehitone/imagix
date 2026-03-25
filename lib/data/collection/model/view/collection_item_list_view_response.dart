import 'package:imagix/domain/collection/model/collection_item.dart';

class CollectionItemListViewResponse {
  final int itemId; // ID dari junction table collections_items
  final String collectionId;
  final DateTime addedAt;
  final String id; // Post ID
  final String title;
  final String image;
  final String authorUsername;
  final int totalLikes;
  final int totalComments;

  CollectionItemListViewResponse({
    required this.itemId,
    required this.collectionId,
    required this.addedAt,
    required this.id,
    required this.title,
    required this.image,
    required this.authorUsername,
    required this.totalLikes,
    required this.totalComments,
  });

  factory CollectionItemListViewResponse.fromJson(Map<String, dynamic> json) =>
      CollectionItemListViewResponse(
        itemId: json['item_id'] as int,
        collectionId: json['collection_id'] as String,
        addedAt: DateTime.parse(json['added_at'] as String).toLocal(),
        id: json['id'] as String,
        title: json['title'] as String,
        image: json['image'] as String,
        authorUsername: json['author_username'] as String,
        totalLikes: json['total_likes'] as int,
        totalComments: json['total_comments'] as int,
      );

  CollectionItem toDomain() => CollectionItem(
    itemId: itemId,
    collectionId: collectionId,
    addedAt: addedAt,
    postId: id,
    title: title,
    image: image,
    authorUsername: authorUsername,
    totalLikes: totalLikes,
    totalComments: totalComments,
  );
}
