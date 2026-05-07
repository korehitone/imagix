import 'package:flutter_test/flutter_test.dart';
import 'package:imagix/core/network/result_state.dart';
import 'package:imagix/data/collection/repository/collection_repository_impl.dart';
import 'package:imagix/domain/collection/model/collection.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'collection_repo_impl_test.mocks.dart';

@GenerateNiceMocks([
  MockSpec<SupabaseClient>(),
  MockSpec<SupabaseQueryBuilder>(),
  MockSpec<PostgrestTransformBuilder<List<Map<String, dynamic>>>>(
    as: #MockPostgrestTransformBuilder,
  ),
  MockSpec<PostgrestFilterBuilder<List<Map<String, dynamic>>>>(
    as: #MockPostgrestFilterBuilderList,
  ),
  MockSpec<PostgrestFilterBuilder<Map<String, dynamic>?>>(
    as: #MockPostgrestFilterBuilderSingle,
  ),
])
void main() {
  late CollectionRepositoryImpl repository;
  late MockSupabaseClient mockSupabaseClient;
  late MockSupabaseQueryBuilder mockSupabaseBuilder;
  late MockPostgrestFilterBuilderList mockFilterBuilderList;
  late MockPostgrestFilterBuilderSingle mockFilterBuilderSingle;
  late MockPostgrestTransformBuilder mockTransformBuilder;

  setUp(() {
    mockSupabaseClient = MockSupabaseClient();
    mockSupabaseBuilder = MockSupabaseQueryBuilder();
    mockFilterBuilderList = MockPostgrestFilterBuilderList();
    mockFilterBuilderSingle = MockPostgrestFilterBuilderSingle();
    mockTransformBuilder = MockPostgrestTransformBuilder();

    repository = CollectionRepositoryImpl(mockSupabaseClient);
  });

  group('CollectionRepositoryImpl', () {
    const tUserId = 'user-123';
    const tPostId = 'post-999';
    const tColId = 'col-1';
    final tNow = DateTime.now().toIso8601String();

    final tCollectionMap = {
      'id': tColId,
      'user_id': tUserId,
      'title': 'My Favorites',
      'total_items': 0, // Wajib int
      'is_default': false, // Wajib bool
      'cover_image': null,
      'created_at': tNow, // Wajib String ISO8601
      'updated_at': tNow, // Wajib String ISO8601
    };

    group('getUserCollections', () {
      test('should return Success list of collections on success', () async {
        when(
          mockSupabaseClient.from('collection_list_view'),
        ).thenAnswer((_) => mockSupabaseBuilder);
        when(
          mockSupabaseBuilder.select(),
        ).thenAnswer((_) => mockFilterBuilderList);
        when(
          mockFilterBuilderList.eq('user_id', tUserId),
        ).thenAnswer((_) => mockFilterBuilderList);
        when(
          mockFilterBuilderList.order('created_at', ascending: false),
        ).thenAnswer((_) => mockFilterBuilderList);
        when(
          mockFilterBuilderList.range(any, any),
        ).thenAnswer((_) => mockTransformBuilder);

        when(
          mockTransformBuilder.then(any, onError: anyNamed('onError')),
        ).thenAnswer((inv) {
          final callback = inv.positionalArguments[0] as Function;
          return Future.value(callback([tCollectionMap]));
        });

        final result = await repository.getUserCollections(
          tUserId,
          offset: 0,
          limit: 10,
        );

        expect(result, isA<Success<List<Collection>>>());
        verify(mockFilterBuilderList.range(0, 9)).called(1);
      });

      test('should return empty list when no data found', () async {
        when(
          mockSupabaseClient.from(any),
        ).thenAnswer((_) => mockSupabaseBuilder);
        when(
          mockSupabaseBuilder.select(),
        ).thenAnswer((_) => mockFilterBuilderList);
        when(
          mockFilterBuilderList.eq(any, any),
        ).thenAnswer((_) => mockFilterBuilderList);
        when(
          mockFilterBuilderList.order(any, ascending: anyNamed('ascending')),
        ).thenAnswer((_) => mockFilterBuilderList);
        when(
          mockFilterBuilderList.range(any, any),
        ).thenAnswer((_) => mockTransformBuilder);

        when(
          mockTransformBuilder.then(any, onError: anyNamed('onError')),
        ).thenAnswer((inv) {
          final callback = inv.positionalArguments[0] as Function;
          return Future.value(callback(<Map<String, dynamic>>[]));
        });

        final result = await repository.getUserCollections(
          tUserId,
          offset: 0,
          limit: 10,
        );
        expect((result as Success).data, isEmpty);
      });

      test('should return Error when exception occurs', () async {
        when(mockSupabaseClient.from(any)).thenThrow(Exception('Server Down'));
        final result = await repository.getUserCollections(
          tUserId,
          offset: 0,
          limit: 10,
        );
        expect(result, isA<Error>());
      });
    });

    group('getUserCollectionsWithSaved', () {
      test(
        'should return collections with isSaved true when post exists in collection',
        () async {
          // Mock Collections
          when(
            mockSupabaseClient.from('collection_list_view'),
          ).thenAnswer((_) => mockSupabaseBuilder);
          when(
            mockSupabaseBuilder.select(),
          ).thenAnswer((_) => mockFilterBuilderList);
          when(
            mockFilterBuilderList.eq('user_id', tUserId),
          ).thenAnswer((_) => mockFilterBuilderList);
          when(
            mockFilterBuilderList.then(any, onError: anyNamed('onError')),
          ).thenAnswer((inv) {
            final callback = inv.positionalArguments[0] as Function;
            return Future.value(callback([tCollectionMap]));
          });

          // Mock Saved Items
          final mockItemBuilder = MockSupabaseQueryBuilder();
          final mockItemFilter = MockPostgrestFilterBuilderList();
          when(
            mockSupabaseClient.from('collection_item_list_view'),
          ).thenAnswer((_) => mockItemBuilder);
          when(
            mockItemBuilder.select('collection_id'),
          ).thenAnswer((_) => mockItemFilter);
          when(
            mockItemFilter.eq('id', tPostId),
          ).thenAnswer((_) => mockItemFilter);
          when(
            mockItemFilter.then(any, onError: anyNamed('onError')),
          ).thenAnswer((inv) {
            final callback = inv.positionalArguments[0] as Function;
            return Future.value(
              callback([
                {'collection_id': tColId},
              ]),
            );
          });

          final result = await repository.getUserCollectionsWithSaved(
            tUserId,
            tPostId,
          );

          expect(
            (result as Success<List<Collection>>).data.first.isSaved,
            true,
          );
        },
      );

      test(
        'should return isSaved false when post is not in the collection',
        () async {
          // Reuse logic but return different saved ID
          when(
            mockSupabaseClient.from('collection_list_view'),
          ).thenAnswer((_) => mockSupabaseBuilder);
          when(
            mockSupabaseBuilder.select(),
          ).thenAnswer((_) => mockFilterBuilderList);
          when(
            mockFilterBuilderList.eq(any, any),
          ).thenAnswer((_) => mockFilterBuilderList);
          when(
            mockFilterBuilderList.then(any, onError: anyNamed('onError')),
          ).thenAnswer((inv) {
            final callback = inv.positionalArguments[0] as Function;
            return Future.value(callback([tCollectionMap]));
          });

          final mockItemBuilder = MockSupabaseQueryBuilder();
          final mockItemFilter = MockPostgrestFilterBuilderList();
          when(
            mockSupabaseClient.from('collection_item_list_view'),
          ).thenAnswer((_) => mockItemBuilder);
          when(mockItemBuilder.select(any)).thenAnswer((_) => mockItemFilter);
          when(mockItemFilter.eq(any, any)).thenAnswer((_) => mockItemFilter);
          when(
            mockItemFilter.then(any, onError: anyNamed('onError')),
          ).thenAnswer((inv) {
            final callback = inv.positionalArguments[0] as Function;
            return Future.value(
              callback([
                {'collection_id': 'different-col'},
              ]),
            );
          });

          final result = await repository.getUserCollectionsWithSaved(
            tUserId,
            tPostId,
          );
          expect(
            (result as Success<List<Collection>>).data.first.isSaved,
            false,
          );
        },
      );

      test('should return Error when query fails', () async {
        when(mockSupabaseClient.from(any)).thenThrow(Exception('Fetch fail'));
        final result = await repository.getUserCollectionsWithSaved(
          tUserId,
          tPostId,
        );
        expect(result, isA<Error>());
      });
    });

    group('create', () {
      test('should return Success(true) when insert succeeds', () async {
        when(
          mockSupabaseClient.from('collections'),
        ).thenAnswer((_) => mockSupabaseBuilder);
        when(
          mockSupabaseBuilder.insert(any),
        ).thenAnswer((_) => mockFilterBuilderList);
        when(
          mockFilterBuilderList.select('id'),
        ).thenAnswer((_) => mockFilterBuilderList);
        when(
          mockFilterBuilderList.maybeSingle(),
        ).thenAnswer((_) => mockFilterBuilderSingle);
        when(
          mockFilterBuilderSingle.then(any, onError: anyNamed('onError')),
        ).thenAnswer((inv) {
          final callback = inv.positionalArguments[0] as Function;
          return Future.value(callback({'id': 'new-uuid'}));
        });

        final result = await repository.create(tUserId, 'New');
        expect(result, isA<Success<bool>>());
      });

      test(
        'should return Error("CREATE_FAILED") when result is null',
        () async {
          when(
            mockSupabaseClient.from(any),
          ).thenAnswer((_) => mockSupabaseBuilder);
          when(
            mockSupabaseBuilder.insert(any),
          ).thenAnswer((_) => mockFilterBuilderList);
          when(
            mockFilterBuilderList.select(any),
          ).thenAnswer((_) => mockFilterBuilderList);
          when(
            mockFilterBuilderList.maybeSingle(),
          ).thenAnswer((_) => mockFilterBuilderSingle);
          when(
            mockFilterBuilderSingle.then(any, onError: anyNamed('onError')),
          ).thenAnswer((inv) {
            final callback = inv.positionalArguments[0] as Function;
            return Future.value(callback(null));
          });

          final result = await repository.create(tUserId, 'New');
          expect((result as Error).error, "CREATE_FAILED");
        },
      );
    });

    group('update', () {
      test('should return Success(true) when update succeeds', () async {
        when(
          mockSupabaseClient.from('collections'),
        ).thenAnswer((_) => mockSupabaseBuilder);
        when(
          mockSupabaseBuilder.update(any),
        ).thenAnswer((_) => mockFilterBuilderList);
        when(
          mockFilterBuilderList.eq(any, any),
        ).thenAnswer((_) => mockFilterBuilderList);
        when(
          mockFilterBuilderList.select(),
        ).thenAnswer((_) => mockFilterBuilderList);
        when(
          mockFilterBuilderList.maybeSingle(),
        ).thenAnswer((_) => mockFilterBuilderSingle);
        when(
          mockFilterBuilderSingle.then(any, onError: anyNamed('onError')),
        ).thenAnswer((inv) {
          final callback = inv.positionalArguments[0] as Function;
          return Future.value(callback({'id': tColId}));
        });

        final result = await repository.update(tUserId, tColId, 'New Title');
        expect(result, isA<Success<bool>>());
      });

      test('should return Error when record not found', () async {
        when(
          mockSupabaseClient.from(any),
        ).thenAnswer((_) => mockSupabaseBuilder);
        when(
          mockSupabaseBuilder.update(any),
        ).thenAnswer((_) => mockFilterBuilderList);
        when(
          mockFilterBuilderList.eq(any, any),
        ).thenAnswer((_) => mockFilterBuilderList);
        when(
          mockFilterBuilderList.select(),
        ).thenAnswer((_) => mockFilterBuilderList);
        when(
          mockFilterBuilderList.maybeSingle(),
        ).thenAnswer((_) => mockFilterBuilderSingle);
        when(
          mockFilterBuilderSingle.then(any, onError: anyNamed('onError')),
        ).thenAnswer((inv) {
          final callback = inv.positionalArguments[0] as Function;
          return Future.value(callback(null));
        });

        final result = await repository.update(tUserId, tColId, 'New Title');
        expect((result as Error).error, "ACTION_DENIED_OR_NOT_FOUND");
      });
    });

    group('delete', () {
      test('should return Success(true) when delete succeeds', () async {
        when(
          mockSupabaseClient.from('collections'),
        ).thenAnswer((_) => mockSupabaseBuilder);
        when(
          mockSupabaseBuilder.delete(),
        ).thenAnswer((_) => mockFilterBuilderList);
        when(
          mockFilterBuilderList.eq(any, any),
        ).thenAnswer((_) => mockFilterBuilderList);
        when(
          mockFilterBuilderList.select('id'),
        ).thenAnswer((_) => mockFilterBuilderList);
        when(
          mockFilterBuilderList.maybeSingle(),
        ).thenAnswer((_) => mockFilterBuilderSingle);
        when(
          mockFilterBuilderSingle.then(any, onError: anyNamed('onError')),
        ).thenAnswer((inv) {
          final callback = inv.positionalArguments[0] as Function;
          return Future.value(callback({'id': tColId}));
        });

        final result = await repository.delete(tUserId, tColId);
        expect(result, isA<Success<bool>>());
      });

      test('should return Error when ACTION_DENIED_OR_NOT_FOUND', () async {
        when(
          mockSupabaseClient.from(any),
        ).thenAnswer((_) => mockSupabaseBuilder);
        when(
          mockSupabaseBuilder.delete(),
        ).thenAnswer((_) => mockFilterBuilderList);
        when(
          mockFilterBuilderList.eq(any, any),
        ).thenAnswer((_) => mockFilterBuilderList);
        when(
          mockFilterBuilderList.select(any),
        ).thenAnswer((_) => mockFilterBuilderList);
        when(
          mockFilterBuilderList.maybeSingle(),
        ).thenAnswer((_) => mockFilterBuilderSingle);
        when(
          mockFilterBuilderSingle.then(any, onError: anyNamed('onError')),
        ).thenAnswer((inv) {
          final callback = inv.positionalArguments[0] as Function;
          return Future.value(callback(null));
        });

        final result = await repository.delete(tUserId, tColId);
        expect((result as Error).error, "ACTION_DENIED_OR_NOT_FOUND");
      });
    });
  });
}
