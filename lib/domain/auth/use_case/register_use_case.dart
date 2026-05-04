import 'package:imagix/core/utils/helper.dart';
import 'package:imagix/domain/auth/repository/auth_repository.dart';

import '../../../core/network/result_state.dart';

class RegisterUseCase {
  final AuthRepository _repository;
  const RegisterUseCase(this._repository);

  Future<ResultState<bool>> invoke(
    String email,
    String password,
    String username,
  ) async {
    if (email.trim().isEmpty) {
      return const Error("EMAIL_IS_EMPTY");
    }

    if (!email.trim().isValidEmail()) {
      return const Error("EMAIL_IS_NOT_VALID");
    }

    if (username.trim().isEmpty) {
      return const Error("USERNAME_IS_EMPTY");
    }

    if (!username.trim().isValidUsername()) {
      return const Error("USERNAME_IS_NOT_VALID");
    }

    if (password.trim().isEmpty) {
      return const Error("PASSWORD_IS_EMPTY");
    }

    if (password.trim().length < 6) {
      return const Error("PASSWORD_TOO_SHORT");
    }

    final result = await _repository.register(email, password, username);

    return switch (result) {
      Success(data: final d) => Success(d),
      Error(error: final key) => switch (key) {
        "PASSWORD_TOO_SHORT" => const Error(
          "Minimum password is 6 characters.",
        ),
        "EMAIL_ALREADY_REGISTERED" => const Error("Email already registered."),
        "FAILED_CREATE_ACCOUNT" => const Error(
          "Could not upload account. Please try again later.",
        ),
        "PASSWORD_IS_EMPTY" => const Error("Password is empty."),
        "EMAIL_IS_EMPTY" => const Error("Email is empty."),
        "USERNAME_IS_EMPTY" => const Error("Username is empty."),
        "EMAIL_IS_NOT_VALID" => const Error("Email is not valid."),
        "USERNAME_IS_NOT_VALID" => const Error(
          "Username can only contain letters, numbers, underscore (_) and dot (.).",
        ),
        _ => Error(key),
      },
    };
  }
}
