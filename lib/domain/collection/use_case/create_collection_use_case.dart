import 'package:imagix/domain/auth/repository/auth_repository.dart';
import 'package:imagix/domain/collection/repository/collection_repository.dart';

import '../../../core/network/result_state.dart';

class CreateCollectionUseCase {
  final CollectionRepository _collectionRepository;
  final AuthRepository _authRepository;

  const CreateCollectionUseCase(
    this._collectionRepository,
    this._authRepository,
  );

  Future<ResultState<bool>> invoke(String title) async {
    if (title.isEmpty) {
      return Error("Title can not be empty.");
    }

    final user = _authRepository.getCurrentUser();
    if (user == null) {
      return const Error("Session expired. Please log in.");
    }

    final result = await _collectionRepository.create(user.id, title);

    return switch (result) {
      Success(data: final d) => Success(d),
      Error(error: final key) => Error(
        key == "CREATE_FAILED" ? "Failed to create collection." : key,
      ),
    };
  }
}
