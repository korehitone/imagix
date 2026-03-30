import 'dart:convert';

import 'package:imagix/core/error/exception_handler.dart';
import 'package:imagix/core/local/global_preferences.dart';
import 'package:imagix/core/network/result_state.dart';
import 'package:imagix/domain/auth/repository/auth_repository.dart';
import 'package:imagix/domain/common/model/user_profile.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthRepositoryImpl implements AuthRepository {
  final SupabaseClient _client;
  final GlobalPreferences _pref;
  static const _userKey = 'user_profile';

  AuthRepositoryImpl(this._client, this._pref);

  @override
  User? getCurrentUser() => _client.auth.currentUser;

  @override
  UserProfile? getLocalUser() {
    final data = _pref.getString(_userKey);
    return data != null
        ? UserProfile.fromJson(jsonDecode(data))
        : null; // Decode di sini!
  }

  @override
  Future<void> saveLocalUser(UserProfile user) async {
    await _pref.saveString(_userKey, jsonEncode(user.toJson()));
  }

  @override
  Future<void> clearLocalUser() async {
    await _pref.remove(_userKey); // Cuma hapus local data
  }

  @override
  Future<ResultState<UserProfile>> login(String email, String password) async {
    try {
      final response = await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );

      final userAuth = response.user;
      if (userAuth == null) return const Error("USER_NOT_FOUND");

      final Map<String, dynamic>? user = await _client
          .from('profile_view')
          .select()
          .eq('id', userAuth.id)
          .maybeSingle();

      if (user == null) return const Error("PROFILE_NOT_FOUND");

      if (user['deleted_at'] != null) {
        return const Error("ACCOUNT_DELETED");
      }
      user['email'] = userAuth.email;

      return Success(UserProfile.fromJson(user));
    } catch (e) {
      return Error(ExceptionHandler.handle(e));
    }
  }

  @override
  Future<void> logout() async {
    _client.auth.signOut();
  }

  @override
  Future<ResultState<bool>> register(
    String email,
    String password,
    String username,
  ) async {
    try {
      final response = await _client.auth.signUp(
        email: email,
        password: password,
        data: {'username': username},
      );

      if (response.user != null) {
        return const Success(true);
      } else {
        return const Error("FAILED_CREATE_ACCOUNT");
      }
    } catch (e) {
      return Error(ExceptionHandler.handle(e));
    }
  }

  @override
  Future<ResultState<bool>> deleteAccount(String userId) async {
    try {
      final response = await _client
          .from('users')
          .update({'deleted_at': "now()"})
          .eq('id', userId)
          .select('id')
          .maybeSingle();

      if (response == null) {
        return const Error("AUTH_ACTION_DENIED");
      }

      return const Success(true);
    } catch (e) {
      return Error(ExceptionHandler.handle(e));
    }
  }

  @override
  Future<ResultState<bool>> restoreAccount(String userId) async {
    try {
      final response = await _client
          .from('users')
          .update({'deleted_at': null})
          .eq('id', userId)
          .select('id')
          .maybeSingle();

      if (response == null) {
        return const Error("AUTH_ACTION_DENIED");
      }
      return Success(true);
    } catch (e) {
      return Error(ExceptionHandler.handle(e));
    }
  }
}
