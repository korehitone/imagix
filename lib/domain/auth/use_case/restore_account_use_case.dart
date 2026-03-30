import 'package:imagix/domain/auth/repository/auth_repository.dart';

import '../../../core/network/result_state.dart';

class RestoreAccountUseCase {
  final AuthRepository _repository;

  const RestoreAccountUseCase(this._repository);

  Future<ResultState<bool>> execute() async {
    final user = _repository.getCurrentUser();
    if (user == null) {
      return const Error("No active session found.");
    }

    final result = await _repository.restoreAccount(user.id);

    return switch (result) {
      Success(data: final d) => Success(d),
      Error(error: final key) => Error(
        key == "AUTH_ACTION_DENIED"
            ? "Failed to restore account. Access denied."
            : key,
      ),
    };
  }
}
