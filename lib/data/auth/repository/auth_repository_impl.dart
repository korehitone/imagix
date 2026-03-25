import 'package:imagix/core/error/exception_handler.dart';
import 'package:imagix/core/local/global_preferences.dart';
import 'package:imagix/core/local/model/user_profile.dart';
import 'package:imagix/core/network/result_state.dart';
import 'package:imagix/domain/auth/repository/auth_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthRepositoryImpl implements AuthRepository {
  final SupabaseClient _client;
  final GlobalPreferences _pref;

  AuthRepositoryImpl(this._client, this._pref);

  @override
  User? getCurrentUser() => _client.auth.currentUser;

  @override
  Stream<ResultState<bool>> login(String email, String password) async* {
    yield const Loading();
    try {
      final response = await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );

      final userAuth = response.user;
      if (userAuth != null) {
        final Map<String, dynamic> user = await _client
            .from('profile_view')
            .select()
            .eq('id', userAuth.id)
            .single();

        user['email'] = userAuth.email;

        await _pref.saveUser(UserProfile.fromJson(user));
        yield const Success(true);
      } else {
        yield const Error("Failed to get data, please try again.");
      }
    } catch (e) {
      final error = ExceptionHandler.handle(e);
      yield Error(error);
    }
  }

  @override
  Future<void> logout() async {
    await _pref.clearUser();
    _client.auth.signOut();
  }

  @override
  Stream<ResultState<bool>> register(
    String email,
    String password,
    String username,
  ) async* {
    yield const Loading();
    try {
      final response = await _client.auth.signUp(
        email: email,
        password: password,
        data: {'username': username},
      );

      if (response.user != null) {
        yield const Success(true);
      } else {
        yield const Error("Failed to create account.");
      }
    } on AuthException catch (e) {
      yield Error(e.message);
    } catch (e) {
      yield Error(e.toString());
    }
  }
}
