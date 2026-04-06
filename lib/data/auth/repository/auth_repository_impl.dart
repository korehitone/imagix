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

      final statusResponse = await _client.rpc(
        'get_account_deleted_status',
        params: {'target_user_id': userAuth.id},
      );

      final statusRows = statusResponse as List<dynamic>;

      if (statusRows.isEmpty) {
        return const Error("PROFILE_NOT_FOUND");
      }

      final status = Map<String, dynamic>.from(statusRows.first);

      if (status['deleted_at'] != null) {
        return const Error("ACCOUNT_DELETED");
      }

      final Map<String, dynamic>? user = await _client
          .from('profile_view')
          .select()
          .eq('id', userAuth.id)
          .maybeSingle();

      if (user == null) {
        return const Error("PROFILE_NOT_FOUND");
      }

      user['email'] = userAuth.email;

      return Success(UserProfile.fromJson(user));
    } catch (e) {
      return Error(ExceptionHandler.handle(e));
    }
  }

  @override
  Future<void> logout() async {
    await _client.auth.signOut();
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
        emailRedirectTo: 'com.korehitone.imagix://email-confirm',
      );

      if (response.user != null) {
        if (response.user?.identities != null &&
            response.user!.identities!.isEmpty) {
          return Error("EMAIL_ALREADY_REGISTERED");
        }
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
      // final response = await _client
      //     .from('users')
      //     .update({'deleted_at': DateTime.now().toIso8601String()})
      //     .eq('id', userId)
      //     .select('id')
      //     .maybeSingle();

      // if (response == null) {
      //   return const Error("AUTH_ACTION_DENIED");
      // }

      await _client.rpc('soft_delete_my_account');

      return const Success(true);
    } catch (e) {
      return Error(ExceptionHandler.handle(e));
    }
  }

  @override
  Future<ResultState<bool>> restoreAccount(String userId) async {
    try {
      // final response = await _client
      //     .from('users')
      //     .update({'deleted_at': null})
      //     .eq('id', userId)
      //     .select('id')
      //     .maybeSingle();
      //
      // if (response == null) {
      //   return const Error("AUTH_ACTION_DENIED");
      // }

      await _client.rpc('restore_my_account');
      return Success(true);
    } catch (e) {
      return Error(ExceptionHandler.handle(e));
    }
  }

  @override
  Future<ResultState<bool>> resendVerificationEmail(String email) async {
    try {
      await _client.auth.resend(
        type: OtpType.signup,
        email: email,
        emailRedirectTo: 'com.korehitone.imagix://email-confirm',
      );
      return const Success(true);
    } catch (e) {
      return Error(ExceptionHandler.handle(e));
    }
  }
}
