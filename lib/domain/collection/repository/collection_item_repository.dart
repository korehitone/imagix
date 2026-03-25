import 'package:imagix/core/network/result_state.dart';
import 'package:imagix/domain/collection/model/collection_item.dart';

abstract class CollectionItemRepository {
  Stream<ResultState<List<CollectionItem>>> getItemsByCollection(
    String collectionId,
  );
}
