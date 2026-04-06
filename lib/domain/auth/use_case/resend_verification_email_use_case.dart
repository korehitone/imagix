import 'package:imagix/domain/auth/repository/auth_repository.dart';

import '../../../core/network/result_state.dart';

class ResendVerificationEmailUseCase {
  final AuthRepository _repository;

  const ResendVerificationEmailUseCase(this._repository);

  Future<ResultState<bool>> invoke(String email) async {
    final result = await _repository.resendVerificationEmail(email);

    return switch (result) {
      Success(data: final status) => Success(status),
      Error(error: final key) => Error(
        key == "Email rate limit exceeded"
            ? "Please wait a moment before requesting another verification email."
            : key,
      ),
    };
  }
}
