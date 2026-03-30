import 'package:imagix/core/network/result_state.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../common/model/user_profile.dart';

abstract class AuthRepository {
  Future<ResultState<UserProfile>> login(String email, String password);
  Future<ResultState<bool>> register(
    String email,
    String password,
    String username,
  );
  Future<void> logout();
  User? getCurrentUser();
  Future<ResultState<bool>> deleteAccount(String userId);
  Future<ResultState<bool>> restoreAccount(String userId);

  UserProfile? getLocalUser();
  Future<void> saveLocalUser(UserProfile user);
  Future<void> clearLocalUser();
}
