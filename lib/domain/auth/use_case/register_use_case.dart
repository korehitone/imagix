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
    // final emailRegex = RegExp(r'^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$');
    // if (!emailRegex.hasMatch(email)) {
    //   return const Error("INVALID_EMAIL_FORMAT");
    // }

    final usernameRegex = RegExp(r'^[A-Za-z0-9._]+$');
    if (!usernameRegex.hasMatch(username)) {
      return const Error(
        "Username can only contain letters, numbers, underscore (_) and dot (.).",
      );
    }

    if (password.length < 6) {
      return const Error("PASSWORD_TOO_SHORT");
    }

    final result = await _repository.register(email, password, username);

    return switch (result) {
      Success(data: final d) => Success(d),
      Error(error: final key) => switch (key) {
        // "INVALID_EMAIL_FORMAT" => const Error("Email is not valid."),
        "PASSWORD_TOO_SHORT" => const Error(
          "Minimum password is 6 characters.",
        ),
        "EMAIL_ALREADY_REGISTERED" => const Error("Email already registered."),
        "FAILED_CREATE_ACCOUNT" => const Error(
          "Could not upload account. Please try again later.",
        ),
        _ => Error(key),
      },
    };
  }
}
