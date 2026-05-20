import 'package:flutter_test/flutter_test.dart';
import 'package:imagix/core/network/result_state.dart';
import 'package:imagix/domain/auth/repository/auth_repository.dart';
import 'package:imagix/domain/collection/model/collection_item.dart';
import 'package:imagix/domain/collection/repository/collection_item_repository.dart';
import 'package:imagix/domain/collection/use_case/create_collection_item_use_case.dart';
import 'package:imagix/domain/collection/use_case/delete_collection_item_use_case.dart';
import 'package:imagix/domain/collection/use_case/get_collection_items_use_case.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

import 'collection_item_usecase_test.mocks.dart';

// Generate Mocks
@GenerateMocks([CollectionItemRepository, AuthRepository])
void main() {
  provideDummy<ResultState<bool>>(const Success(true));
  provideDummy<ResultState<List<CollectionItem>>>(const Success([]));

  late MockCollectionItemRepository mockCollectionRepo;
  late MockAuthRepository mockAuthRepo;
  late CreateCollectionItemUseCase createUC;
  late DeleteCollectionItemUseCase deleteUC;
  late GetCollectionItemsUseCase getItemsUC;

  setUp(() {
    mockCollectionRepo = MockCollectionItemRepository();
    mockAuthRepo = MockAuthRepository();
    createUC = CreateCollectionItemUseCase(mockCollectionRepo, mockAuthRepo);
    deleteUC = DeleteCollectionItemUseCase(mockCollectionRepo, mockAuthRepo);
    getItemsUC = GetCollectionItemsUseCase(mockCollectionRepo, mockAuthRepo);
  });

  const tUserId = 'uid-123';
  const tCollectionId = 'coll-abc';
  const tPostId = 'post-xyz';
  const tItemId = 101;

  // Mock Supabase User
  final tSupabaseUser = supabase.User(
    id: tUserId,
    appMetadata: {},
    userMetadata: {},
    aud: 'authenticated',
    createdAt: DateTime.now().toIso8601String(),
  );

  final tCollectionItem = CollectionItem(
    itemId: tItemId,
    collectionId: tCollectionId,
    addedAt: DateTime.now(),
    postId: tPostId,
    title: 'Koguma Super Cub',
    image: 'https://imagix.com/cub.png',
    authorUsername: 'kak_dev',
    totalLikes: 10,
    totalComments: 5,
  );

  final tCollectionItemsList = [tCollectionItem];

  group('CreateCollectionItemUseCase', () {
    test('should return Error when user session is null', () async {
      when(mockAuthRepo.getCurrentUser()).thenReturn(null);

      final result = await createUC.invoke(tCollectionId, tPostId);

      expect(result, isA<Error>());
      expect((result as Error).error, "Session expired. Please log in.");
      verifyNever(mockCollectionRepo.create(any, any));
    });

    test('should return Success(true) when repository succeeds', () async {
      when(mockAuthRepo.getCurrentUser()).thenReturn(tSupabaseUser);
      when(
        mockCollectionRepo.create(tCollectionId, tPostId),
      ).thenAnswer((_) async => const Success(true));

      final result = await createUC.invoke(tCollectionId, tPostId);

      expect(result, isA<Success<bool>>());
      expect((result as Success).data, true);
      verify(mockCollectionRepo.create(tCollectionId, tPostId)).called(1);
    });

    test('should map ITEM_CREATE_FAILED error message correctly', () async {
      when(mockAuthRepo.getCurrentUser()).thenReturn(tSupabaseUser);
      when(
        mockCollectionRepo.create(any, any),
      ).thenAnswer((_) async => const Error("ITEM_CREATE_FAILED"));

      final result = await createUC.invoke(tCollectionId, tPostId);

      expect(result, isA<Error>());
      expect((result as Error).error, "Failed to add item to collection.");
    });
  });

  group('DeleteCollectionItemUseCase', () {
    test('should return Error when user session is null', () async {
      when(mockAuthRepo.getCurrentUser()).thenReturn(null);

      final result = await deleteUC.invoke(tItemId);

      expect(result, isA<Error>());
      expect((result as Error).error, "Session expired. Please log in.");
      verifyNever(mockCollectionRepo.delete(any));
    });

    test('should return Success(true) when repository succeeds', () async {
      when(mockAuthRepo.getCurrentUser()).thenReturn(tSupabaseUser);
      when(
        mockCollectionRepo.delete(tItemId),
      ).thenAnswer((_) async => const Success(true));

      final result = await deleteUC.invoke(tItemId);

      expect(result, isA<Success<bool>>());
      verify(mockCollectionRepo.delete(tItemId)).called(1);
    });

    test('should map ITEM_NOT_FOUND error message correctly', () async {
      when(mockAuthRepo.getCurrentUser()).thenReturn(tSupabaseUser);
      when(
        mockCollectionRepo.delete(any),
      ).thenAnswer((_) async => const Error("ITEM_NOT_FOUND"));

      final result = await deleteUC.invoke(tItemId);

      expect(result, isA<Error>());
      expect((result as Error).error, "Item not found or already deleted.");
    });
  });

  group('GetCollectionItemsUseCase', () {
    const tOffset = 0;
    const tLimit = 10;

    test('should return Error when user session is null', () async {
      when(mockAuthRepo.getCurrentUser()).thenReturn(null);

      final result = await getItemsUC.invoke(
        tCollectionId,
        offset: tOffset,
        limit: tLimit,
      );

      expect(result, isA<Error>());
      expect((result as Error).error, "Session expired. Please log in.");
    });

    test(
      'should return Success(List<CollectionItem>) from repository',
      () async {
        when(mockAuthRepo.getCurrentUser()).thenReturn(tSupabaseUser);
        when(
          mockCollectionRepo.getItemsByCollection(
            tCollectionId,
            offset: tOffset,
            limit: tLimit,
          ),
        ).thenAnswer((_) async => Success(tCollectionItemsList));

        final result = await getItemsUC.invoke(
          tCollectionId,
          offset: tOffset,
          limit: tLimit,
        );

        expect(result, isA<Success<List<CollectionItem>>>());
        expect((result as Success).data, tCollectionItemsList);
        verify(
          mockCollectionRepo.getItemsByCollection(
            tCollectionId,
            offset: tOffset,
            limit: tLimit,
          ),
        ).called(1);
      },
    );

    test(
      'should return raw error key for unhandled repository errors',
      () async {
        const tErrorKey = "SERVER_FETCH_ERROR";
        when(mockAuthRepo.getCurrentUser()).thenReturn(tSupabaseUser);
        when(
          mockCollectionRepo.getItemsByCollection(
            any,
            offset: anyNamed('offset'),
            limit: anyNamed('limit'),
          ),
        ).thenAnswer((_) async => const Error(tErrorKey));

        final result = await getItemsUC.invoke(
          tCollectionId,
          offset: tOffset,
          limit: tLimit,
        );

        expect(result, isA<Error>());
        expect((result as Error).error, tErrorKey);
      },
    );
  });
}
