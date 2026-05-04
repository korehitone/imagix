import 'package:imagix/domain/auth/repository/auth_repository.dart';

import '../../../core/network/result_state.dart';
import '../repository/collection_repository.dart';

class UpdateCollectionUseCase {
  final CollectionRepository _collectionRepository;
  final AuthRepository _authRepository;

  const UpdateCollectionUseCase(
    this._collectionRepository,
    this._authRepository,
  );

  Future<ResultState<bool>> invoke(String collectionId, String title) async {
    if (title.trim().isEmpty) {
      return Error("Title can not be empty.");
    }

    final user = _authRepository.getCurrentUser();
    if (user == null) {
      return const Error("Session expired. Please log in again.");
    }

    final result = await _collectionRepository.update(
      user.id,
      collectionId,
      title,
    );
    return switch (result) {
      Success(data: final d) => Success(d),
      Error(error: final key) => Error(
        key == "ACTION_DENIED_OR_NOT_FOUND"
            ? "Failed to update. Collection not found or access denied."
            : key,
      ),
    };
  }
}
