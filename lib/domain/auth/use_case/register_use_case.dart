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
    final result = await _repository.register(email, password, username);

    return switch (result) {
      Success(data: final d) => Success(d),
      Error(error: final key) => switch (key) {
        "FAILED_CREATE_ACCOUNT" => const Error(
          "Could not create account. Please try again later.",
        ),
        _ => Error(key),
      },
    };
  }
}
