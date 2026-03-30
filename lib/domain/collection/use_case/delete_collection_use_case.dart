import 'package:imagix/domain/auth/repository/auth_repository.dart';
import 'package:imagix/domain/collection/repository/collection_repository.dart';

import '../../../core/network/result_state.dart';

class DeleteCollectionUseCase {
  final CollectionRepository _collectionRepository;
  final AuthRepository _authRepository;

  const DeleteCollectionUseCase(
    this._collectionRepository,
    this._authRepository,
  );

  Future<ResultState<bool>> invoke(String collectionId) async {
    final user = _authRepository.getCurrentUser();
    if (user == null) {
      return const Error("Session expired. Please log in.");
    }
    final result = await _collectionRepository.delete(user.id, collectionId);

    return switch (result) {
      Success(data: final d) => Success(d),
      Error(error: final key) => Error(
        key == "ACTION_DENIED_OR_NOT_FOUND"
            ? "Access denied. Collection not found or you don't have permission."
            : key,
      ),
    };
  }
}
