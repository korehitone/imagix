extension SupabaseDecode on Object? {
  // 1. Decoder buat List (Feed, Search, dsb)
  List<T> decodeList<T>(T Function(Map<String, dynamic>) fromJson) {
    try {
      if (this == null) return []; // Balikin list kosong kalau null

      final data = this as List<dynamic>;
      return data.map((item) {
        return fromJson(item as Map<String, dynamic>);
      }).toList();
    } catch (e) {
      // Di sini lu bisa pake logger lu tadi
      throw FormatException('Failed to decode list response: $e');
    }
  }

  // 2. Decoder buat Single Object (Profile, Post Detail)
  T? decodeSingle<T>(T Function(Map<String, dynamic>) fromJson) {
    try {
      if (this == null) return null;

      return fromJson(this as Map<String, dynamic>);
    } catch (e) {
      throw FormatException('Failed to decode single response: $e');
    }
  }
}
