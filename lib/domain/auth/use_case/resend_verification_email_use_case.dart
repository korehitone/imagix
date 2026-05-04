import 'package:imagix/core/utils/helper.dart';
import 'package:imagix/domain/auth/repository/auth_repository.dart';

import '../../../core/network/result_state.dart';

class ResendVerificationEmailUseCase {
  final AuthRepository _repository;

  const ResendVerificationEmailUseCase(this._repository);

  Future<ResultState<bool>> invoke(String email) async {
    if (email.trim().isEmpty) {
      return const Error("EMAIL_IS_EMPTY");
    }

    if (!email.trim().isValidEmail()) {
      return const Error("EMAIL_IS_NOT_VALID");
    }

    final result = await _repository.resendVerificationEmail(email);

    return switch (result) {
      Success(data: final status) => Success(status),
      Error(error: final key) => switch (key) {
        "EMAIL_IS_EMPTY" => const Error("Email is empty."),
        "EMAIL_IS_NOT_VALID" => const Error("Email is not valid."),
        "Email rate limit exceeded" => const Error(
          "Please wait a moment before requesting another verification email.",
        ),
        _ => Error(key),
      },
    };
  }
}
