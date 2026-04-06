class Collection {
  final String id;
  final String userId;
  final String title;
  final int totalItems;
  final String? coverImage;
  final bool isDefault;
  final bool isSaved;
  final DateTime createdAt;
  final DateTime updatedAt;

  Collection({
    required this.id,
    required this.userId,
    required this.title,
    this.totalItems = 0, // Default 0 kalau ambil dari tabel biasa
    this.coverImage,
    required this.isDefault,
    this.isSaved = false,
    required this.createdAt,
    required this.updatedAt,
  });

  Collection copyWith({bool? isSaved}) => Collection(
    id: id,
    userId: userId,
    title: title,
    totalItems: totalItems,
    coverImage: coverImage,
    isDefault: isDefault,
    isSaved: isSaved ?? this.isSaved,
    createdAt: createdAt,
    updatedAt: updatedAt,
  );
}
