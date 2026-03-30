import 'package:imagix/core/network/result_state.dart';
import 'package:imagix/domain/collection/model/collection_item.dart';

abstract class CollectionItemRepository {
  Future<ResultState<List<CollectionItem>>> getItemsByCollection(
    String collectionId,
  );
  Future<ResultState<bool>> create(String collectionId, String postId);
  Future<ResultState<bool>> delete(int itemId);
}
