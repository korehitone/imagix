class CollectionItemResponse {
  final int id;
  final String collectionId;
  final String postId;
  final DateTime createdAt;

  CollectionItemResponse({
    required this.id,
    required this.collectionId,
    required this.postId,
    required this.createdAt,
  });

  factory CollectionItemResponse.fromJson(Map<String, dynamic> json) =>
      CollectionItemResponse(
        id: json['id'] as int,
        collectionId: json['collection_id'] as String,
        postId: json['post_id'] as String,
        createdAt: DateTime.parse(json['created_at'] as String).toLocal(),
      );

  Map<String, dynamic> toJson() => {
    'id': id,
    'collection_id': collectionId,
    'post_id': postId,
  };
}
