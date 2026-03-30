import 'package:imagix/domain/auth/repository/auth_repository.dart';

import '../../../core/network/result_state.dart';

class DeleteAccountUseCase {
  final AuthRepository _repository;
  const DeleteAccountUseCase(this._repository);

  Future<ResultState<bool>> invoke() async {
    final user = _repository.getCurrentUser();
    if (user == null) {
      return const Error("Session expired. Please sign in again.");
    }

    final result = await _repository.deleteAccount(user.id);

    return switch (result) {
      Success(data: final d) => () async {
        await _repository.logout();
        return Success(d);
      }(),
      Error(error: final key) => Error(
        key == "AUTH_ACTION_DENIED"
            ? "Access denied. You don't have permission to delete this account."
            : key,
      ),
    };
  }
}
