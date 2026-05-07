import 'package:flutter_test/flutter_test.dart';
import 'package:imagix/core/network/result_state.dart';
import 'package:imagix/data/collection/model/collection_item_response.dart';
import 'package:imagix/data/collection/repository/collection_item_repository_impl.dart';
import 'package:imagix/domain/collection/model/collection_item.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'collection_item_repo_impl_test.mocks.dart';

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
  MockSpec<CollectionItemListViewResponse>(),
])
void main() {
  late CollectionItemRepositoryImpl repository;
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

    repository = CollectionItemRepositoryImpl(mockSupabaseClient);
  });

  group('CollectionItemRepositoryImpl', () {
    group('getItemsByCollection', () {
      const tCollectionId = 'col-123';
      final tResponseData = [
        {
          'item_id': 1,
          'collection_id': tCollectionId,
          'added_at': DateTime.now().toIso8601String(),
          'id': 'post-101',
          'title': 'Beautiful Sunset',
          'image': 'https://example.com/image.jpg',
          'author_username': 'johndoe',
          'total_likes': 10,
          'total_comments': 5,
        },
      ];

      test('should return Success list of items when successful', () async {
        // Arrange
        when(
          mockSupabaseClient.from('collection_item_list_view'),
        ).thenAnswer((_) => mockSupabaseBuilder);

        when(
          mockSupabaseBuilder.select(),
        ).thenAnswer((_) => mockFilterBuilderList);

        when(
          mockFilterBuilderList.eq('collection_id', tCollectionId),
        ).thenAnswer((_) => mockFilterBuilderList);

        when(
          mockFilterBuilderList.order('added_at', ascending: false),
        ).thenAnswer((_) => mockFilterBuilderList);

        when(
          mockFilterBuilderList.range(any, any),
        ).thenAnswer((_) => mockTransformBuilder);

        // Handle .then() untuk PostgrestTransformBuilder
        when(
          mockTransformBuilder.then(any, onError: anyNamed('onError')),
        ).thenAnswer((inv) {
          final callback = inv.positionalArguments[0] as Function;
          return Future.value(callback(tResponseData));
        });

        // Act
        final result = await repository.getItemsByCollection(
          tCollectionId,
          offset: 0,
          limit: 10,
        );

        // Assert
        expect(result, isA<Success<List<CollectionItem>>>());
        verify(mockFilterBuilderList.range(0, 9)).called(1);
      });

      test(
        'should return Error when database query throws exception',
        () async {
          // Arrange
          // Kita buat error pas baru manggil .from() biar simpel
          when(
            mockSupabaseClient.from(any),
          ).thenThrow(Exception('Database connection failed'));

          // Act
          final result = await repository.getItemsByCollection(
            tCollectionId,
            offset: 0,
            limit: 10,
          );

          // Assert
          expect(result, isA<Error>());
          // Verifikasi apakah error-nya ditangkap oleh ExceptionHandler
          // (Asumsi ExceptionHandler mengembalikan string error)
          verify(mockSupabaseClient.from(any)).called(1);
        },
      );
    });

    group('create', () {
      const tColId = 'col-123';
      const tPostId = 'post-123';

      test('should return Success(true) when insert is successful', () async {
        // Arrange
        when(
          mockSupabaseClient.from('collection_items'),
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
          return Future.value(
            callback({'id': 1}),
          ); // Return ID as proof of success
        });

        // Act
        final result = await repository.create(tColId, tPostId);

        // Assert
        expect(result, isA<Success<bool>>());
        expect((result as Success).data, true);
      });

      test('should return Error when response is null', () async {
        // Arrange
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

        // Act
        final result = await repository.create(tColId, tPostId);

        // Assert
        expect(result, isA<Error>());
        expect((result as Error).error, "ITEM_CREATE_FAILED");
      });
    });

    group('delete', () {
      const tItemId = 1;

      test('should return Success(true) when delete is successful', () async {
        // Arrange
        when(
          mockSupabaseClient.from('collection_items'),
        ).thenAnswer((_) => mockSupabaseBuilder);

        when(
          mockSupabaseBuilder.delete(),
        ).thenAnswer((_) => mockFilterBuilderList);

        when(
          mockFilterBuilderList.eq('id', tItemId),
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
          return Future.value(callback({'id': tItemId}));
        });

        // Act
        final result = await repository.delete(tItemId);

        // Assert
        expect(result, isA<Success<bool>>());
      });

      test(
        'should return Error("ITEM_NOT_FOUND") when row does not exist',
        () async {
          // Arrange
          when(
            mockSupabaseClient.from('collection_items'),
          ).thenAnswer((_) => mockSupabaseBuilder);

          when(
            mockSupabaseBuilder.delete(),
          ).thenAnswer((_) => mockFilterBuilderList);

          when(
            mockFilterBuilderList.eq('id', tItemId),
          ).thenAnswer((_) => mockFilterBuilderList);

          when(
            mockFilterBuilderList.select('id'),
          ).thenAnswer((_) => mockFilterBuilderList);

          when(
            mockFilterBuilderList.maybeSingle(),
          ).thenAnswer((_) => mockFilterBuilderSingle);

          // Pakai thenAnswer buat handle callback asinkronus Supabase
          when(
            mockFilterBuilderSingle.then(any, onError: anyNamed('onError')),
          ).thenAnswer((inv) {
            final callback = inv.positionalArguments[0] as Function;
            // Kita balikin null buat simulasi data gak ketemu
            return Future.value(callback(null));
          });

          // Act
          final result = await repository.delete(tItemId);

          // Assert
          expect(result is Error, true);
          expect((result as Error).error, "ITEM_NOT_FOUND");
        },
      );

      test(
        'should return Error from ExceptionHandler when exception occurs',
        () async {
          // Arrange
          // Buat simulasi error di awal chain
          when(
            mockSupabaseClient.from('collection_items'),
          ).thenThrow(Exception('Delete failed'));

          // Act
          final result = await repository.delete(tItemId);

          // Assert
          expect(result is Error, true);
          verify(mockSupabaseClient.from('collection_items')).called(1);
        },
      );
    });
  });
}
