import '../../../core/network/result_state.dart';
import '../model/collection.dart';

abstract class CollectionRepository {
  Stream<ResultState<List<Collection>>> getUserCollections();
}
