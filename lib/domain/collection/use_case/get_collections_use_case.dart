import 'package:imagix/domain/auth/repository/auth_repository.dart';
import 'package:imagix/domain/collection/repository/collection_repository.dart';

import '../../../core/network/result_state.dart';
import '../model/collection.dart';

class GetCollectionsUseCase {
  final CollectionRepository _collectionRepository;
  final AuthRepository _authRepository;

  const GetCollectionsUseCase(this._collectionRepository, this._authRepository);

  Future<ResultState<List<Collection>>> invoke() async {
    final user = _authRepository.getCurrentUser();
    if (user == null) {
      return const Error("Session expired. Please log in.");
    }

    final result = await _collectionRepository.getUserCollections(user.id);

    return switch (result) {
      Success(data: final list) => Success(list),
      Error(error: final key) => Error(key),
    };
  }
}
