import 'package:imagix/core/utils/helper.dart';
import 'package:imagix/domain/auth/repository/auth_repository.dart';

import '../../../core/network/result_state.dart';
import '../../common/model/user_profile.dart';

class LoginUseCase {
  final AuthRepository _repository;

  const LoginUseCase(this._repository);

  Future<ResultState<String>> invoke(String email, String password) async {
    if (email.trim().isEmpty) {
      return const Error("Email is empty.");
    }

    if (!email.trim().isValidEmail()) {
      return const Error("Email is not valid.");
    }

    if (password.trim().isEmpty) {
      return const Error("Password is empty.");
    }

    final result = await _repository.login(email, password);

    if (result is Success<UserProfile>) {
      await _repository.saveLocalUser(result.data);
    }

    return switch (result) {
      Success() => const Success("LOGGED_IN"),
      Error(error: final key) => switch (key) {
        "ACCOUNT_DELETED" => const Success("ACCOUNT_DELETED"),
        "USER_NOT_FOUND" ||
        "PROFILE_NOT_FOUND" => const Error("Invalid email or password."),
        _ => Error(key),
      },
    };
  }
}
