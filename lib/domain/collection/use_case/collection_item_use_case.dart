import 'package:imagix/domain/collection/use_case/create_collection_item_use_case.dart';
import 'package:imagix/domain/collection/use_case/delete_collection_item_use_case.dart';
import 'package:imagix/domain/collection/use_case/get_collection_items_use_case.dart';

class CollectionItemUseCase {
  final GetCollectionItemsUseCase getItems;
  final CreateCollectionItemUseCase create;
  final DeleteCollectionItemUseCase delete;

  const CollectionItemUseCase({
    required this.getItems,
    required this.create,
    required this.delete,
  });
}
