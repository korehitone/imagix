class Collection {
  final String id;
  final String userId;
  final String title;
  final int totalItems;
  final String? coverImage;
  final bool isDefault;
  final DateTime createdAt;
  final DateTime updatedAt;

  Collection({
    required this.id,
    required this.userId,
    required this.title,
    this.totalItems = 0, // Default 0 kalau ambil dari tabel biasa
    this.coverImage,
    required this.isDefault,
    required this.createdAt,
    required this.updatedAt,
  });
}
