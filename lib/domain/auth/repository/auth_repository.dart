import 'package:imagix/core/network/result_state.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract class AuthRepository {
  Stream<ResultState<bool>> login(String email, String password);
  Stream<ResultState<bool>> register(
    String email,
    String password,
    String username,
  );
  Future<void> logout();
  User? getCurrentUser();
}
