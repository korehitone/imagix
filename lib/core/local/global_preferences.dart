import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'model/user_profile.dart';

class GlobalPreferences {
  final SharedPreferences _pref;
  GlobalPreferences(this._pref);

  static const _keyUser = 'user_profile';

  Future<void> saveUser(UserProfile user) async {
    final String userData = jsonEncode(user.toJson());
    await _pref.setString(_keyUser, userData);
  }

  UserProfile? getUser() {
    final String? userData = _pref.getString(_keyUser);
    if (userData == null) return null;

    return UserProfile.fromJson(jsonDecode(userData));
  }

  Future<void> clearUser() async {
    await _pref.remove(_keyUser);
    // Dark mode biasanya nggak dihapus pas logout, biar tetep estetik
  }
}
