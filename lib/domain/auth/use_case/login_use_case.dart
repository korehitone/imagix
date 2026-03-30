import 'package:imagix/domain/auth/repository/auth_repository.dart';

import '../../../core/network/result_state.dart';
import '../../common/model/user_profile.dart';

class LoginUseCase {
  final AuthRepository _repository;
  const LoginUseCase(this._repository);

  Future<ResultState<bool>> invoke(String email, String password) async {
    final result = await _repository.login(email, password);

    if (result is Success<UserProfile>) {
      await _repository.saveLocalUser(result.data);
    }

    return switch (result) {
      Success() => const Success(true),
      Error(error: final key) => switch (key) {
        "ACCOUNT_DELETED" => const Error(
          "This account is scheduled for deletion. Would you like to restore it?",
        ),
        "USER_NOT_FOUND" ||
        "PROFILE_NOT_FOUND" => const Error("Invalid email or password."),
        _ => Error(key),
      },
    };
  }
}
