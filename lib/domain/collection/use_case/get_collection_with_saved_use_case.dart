import 'package:imagix/core/network/result_state.dart';
import 'package:imagix/domain/auth/repository/auth_repository.dart';
import 'package:imagix/domain/collection/model/collection.dart';
import 'package:imagix/domain/collection/repository/collection_repository.dart';

class GetCollectionWithSavedUseCase {
  final CollectionRepository _collectionRepository;
  final AuthRepository _authRepository;

  const GetCollectionWithSavedUseCase(
    this._collectionRepository,
    this._authRepository,
  );

  Future<ResultState<List<Collection>>> invoke(String postId) async {
    final user = _authRepository.getCurrentUser();
    if (user == null) {
      return const Error("Session expired. Please log in.");
    }
    final result = await _collectionRepository.getUserCollectionsWithSaved(
      user.id,
      postId,
    );
    return switch (result) {
      Success(data: final list) => Success(list),
      Error(error: final key) => Error(key),
    };
  }
}
