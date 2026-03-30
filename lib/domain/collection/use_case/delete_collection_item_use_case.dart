import 'package:imagix/domain/auth/repository/auth_repository.dart';
import 'package:imagix/domain/collection/repository/collection_item_repository.dart';

import '../../../core/network/result_state.dart';

class DeleteCollectionItemUseCase {
  final CollectionItemRepository _collectionItemRepository;
  final AuthRepository _authRepository;

  const DeleteCollectionItemUseCase(
    this._collectionItemRepository,
    this._authRepository,
  );

  Future<ResultState<bool>> invoke(int itemId) async {
    final user = _authRepository.getCurrentUser();
    if (user == null) {
      return const Error("Session expired. Please log in.");
    }
    final result = await _collectionItemRepository.delete(itemId);
    return switch (result) {
      Success(data: final d) => Success(d),
      Error(error: final key) => Error(
        key == "ITEM_NOT_FOUND" ? "Item not found or already deleted." : key,
      ),
    };
  }
}
