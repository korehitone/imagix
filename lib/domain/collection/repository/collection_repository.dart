import '../../../core/network/result_state.dart';
import '../model/collection.dart';

abstract class CollectionRepository {
  Future<ResultState<List<Collection>>> getUserCollections(
    String userId, {
    required int offset,
    required int limit,
  });
  Future<ResultState<List<Collection>>> getUserCollectionsWithSaved(
    String userId,
    String postId,
  );

  Future<ResultState<bool>> create(String userId, String title);

  Future<ResultState<bool>> update(
    String userId,
    String collectionId,
    String title,
  );

  Future<ResultState<bool>> delete(String userId, String collectionId);
}
