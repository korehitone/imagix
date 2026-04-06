import 'package:imagix/domain/auth/repository/auth_repository.dart';
import 'package:imagix/domain/collection/repository/collection_item_repository.dart';

import '../../../core/network/result_state.dart';
import '../model/collection_item.dart';

class GetCollectionItemsUseCase {
  final CollectionItemRepository _collectionItemRepository;
  final AuthRepository _authRepository;

  const GetCollectionItemsUseCase(
    this._collectionItemRepository,
    this._authRepository,
  );

  Future<ResultState<List<CollectionItem>>> invoke(
    String collectionId, {
    required int offset,
    required int limit,
  }) async {
    final user = _authRepository.getCurrentUser();
    if (user == null) {
      return const Error("Session expired. Please log in.");
    }
    final result = await _collectionItemRepository.getItemsByCollection(
      collectionId,
      offset: offset,
      limit: limit,
    );
    return switch (result) {
      Success(data: final list) => Success(list),
      Error(error: final key) => Error(
        key,
      ), // Error teknis dari ExceptionHandler
    };
  }
}
