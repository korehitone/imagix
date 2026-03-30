import 'package:imagix/domain/collection/use_case/create_collection_use_case.dart';
import 'package:imagix/domain/collection/use_case/delete_collection_use_case.dart';
import 'package:imagix/domain/collection/use_case/get_collections_use_case.dart';
import 'package:imagix/domain/collection/use_case/update_collection_use_case.dart';

class CollectionUseCase {
  final GetCollectionsUseCase getCollections;
  final CreateCollectionUseCase create;
  final UpdateCollectionUseCase update;
  final DeleteCollectionUseCase delete;

  const CollectionUseCase({
    required this.getCollections,
    required this.create,
    required this.update,
    required this.delete,
  });
}
