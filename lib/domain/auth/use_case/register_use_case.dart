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
      return const Error("Email is empty.");
    }

    if (!email.trim().isValidEmail()) {
      return const Error("Email is not valid.");
    }

    if (username.trim().isEmpty) {
      return const Error("Username is empty.");
    }

    if (!username.trim().isValidUsername()) {
      return const Error(
        "Username can only contain letters, numbers, underscore (_) and dot (.).",
      );
    }

    if (password.trim().isEmpty) {
      return const Error("Password is empty.");
    }

    if (password.trim().length < 6) {
      return const Error("Minimum password is 6 characters");
    }

    final result = await _repository.register(email, password, username);

    return switch (result) {
      Success(data: final d) => Success(d),
      Error(error: final key) => switch (key) {
        "EMAIL_ALREADY_REGISTERED" => const Error("Email already registered."),
        "FAILED_CREATE_ACCOUNT" => const Error(
          "Could not upload account. Please try again later.",
        ),
        _ => Error(key),
      },
    };
  }
}
