import 'package:imagix/domain/auth/repository/auth_repository.dart';
import 'package:imagix/domain/collection/repository/collection_item_repository.dart';

import '../../../core/network/result_state.dart';

class CreateCollectionItemUseCase {
  final CollectionItemRepository _collectionItemRepository;
  final AuthRepository _authRepository;

  const CreateCollectionItemUseCase(
    this._collectionItemRepository,
    this._authRepository,
  );

  Future<ResultState<bool>> invoke(String collectionId, String postId) async {
    final user = _authRepository.getCurrentUser();
    if (user == null) {
      return const Error("Session expired. Please log in.");
    }
    final result = await _collectionItemRepository.create(collectionId, postId);
    return switch (result) {
      Success(data: final d) => Success(d),
      Error(error: final key) => Error(
        key == "ITEM_CREATE_FAILED" ? "Failed to add item to collection." : key,
      ),
    };
  }
}
