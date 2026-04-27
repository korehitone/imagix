class RoutePayload {
  static Map<String, dynamic>? asMap(Object? extra) {
    return extra is Map<String, dynamic> ? extra : null;
  }

  static T? asType<T>(Object? extra) {
    return extra is T ? extra : null;
  }
}
