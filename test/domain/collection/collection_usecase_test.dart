import 'package:flutter_test/flutter_test.dart';
import 'package:imagix/core/network/result_state.dart';
import 'package:imagix/domain/auth/repository/auth_repository.dart';
import 'package:imagix/domain/collection/model/collection.dart';
import 'package:imagix/domain/collection/repository/collection_repository.dart';
import 'package:imagix/domain/collection/use_case/create_collection_use_case.dart';
import 'package:imagix/domain/collection/use_case/delete_collection_use_case.dart';
import 'package:imagix/domain/collection/use_case/get_collection_with_saved_use_case.dart';
import 'package:imagix/domain/collection/use_case/update_collection_use_case.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

import 'collection_usecase_test.mocks.dart';

@GenerateMocks([CollectionRepository, AuthRepository])
void main() {
  provideDummy<ResultState<bool>>(const Success(true));
  provideDummy<ResultState<List<Collection>>>(const Success([]));

  late MockCollectionRepository mockCollectionRepo;
  late MockAuthRepository mockAuthRepo;
  late CreateCollectionUseCase createUC;
  late DeleteCollectionUseCase deleteUC;
  late UpdateCollectionUseCase updateUC;
  late GetCollectionWithSavedUseCase getWithSavedUC;

  setUp(() {
    mockCollectionRepo = MockCollectionRepository();
    mockAuthRepo = MockAuthRepository();
    createUC = CreateCollectionUseCase(mockCollectionRepo, mockAuthRepo);
    deleteUC = DeleteCollectionUseCase(mockCollectionRepo, mockAuthRepo);
    updateUC = UpdateCollectionUseCase(mockCollectionRepo, mockAuthRepo);
    getWithSavedUC = GetCollectionWithSavedUseCase(
      mockCollectionRepo,
      mockAuthRepo,
    );
  });

  const tUserId = 'uid-123';
  const tCollectionId = 'coll-456';
  const tTitle = 'My New Collection';

  final tSupabaseUser = supabase.User(
    id: tUserId,
    appMetadata: {},
    userMetadata: {},
    aud: 'authenticated',
    createdAt: DateTime.now().toIso8601String(),
  );

  // Data Mock Collection sesuai model terbaru Kakak
  final tCollection = Collection(
    id: tCollectionId,
    userId: tUserId,
    title: 'Vibe Check',
    totalItems: 5,
    coverImage: 'https://imagix.com/cover.png',
    isDefault: false,
    isSaved: true,
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  );

  final tCollectionList = [tCollection];

  group('CreateCollectionUseCase', () {
    test('should return Error when title is empty', () async {
      final result = await createUC.invoke("   ");

      expect(result, isA<Error>());
      expect((result as Error).error, "Title can not be empty.");
      verifyNever(mockCollectionRepo.create(any, any));
    });

    test('should return Error when session is null', () async {
      when(mockAuthRepo.getCurrentUser()).thenReturn(null);

      final result = await createUC.invoke(tTitle);

      expect(result, isA<Error>());
      expect((result as Error).error, "Session expired. Please log in.");
    });

    test('should return Success when repository succeeds', () async {
      when(mockAuthRepo.getCurrentUser()).thenReturn(tSupabaseUser);
      when(
        mockCollectionRepo.create(tUserId, tTitle),
      ).thenAnswer((_) async => const Success(true));

      final result = await createUC.invoke(tTitle);

      expect(result, isA<Success<bool>>());
      verify(mockCollectionRepo.create(tUserId, tTitle)).called(1);
    });

    test('should map CREATE_FAILED error message correctly', () async {
      when(mockAuthRepo.getCurrentUser()).thenReturn(tSupabaseUser);
      when(
        mockCollectionRepo.create(any, any),
      ).thenAnswer((_) async => const Error("CREATE_FAILED"));

      final result = await createUC.invoke(tTitle);

      expect(result, isA<Error>());
      expect((result as Error).error, "Failed to upload collection.");
    });
  });

  group('DeleteCollectionUseCase', () {
    test('should return Error when session is null', () async {
      when(mockAuthRepo.getCurrentUser()).thenReturn(null);

      final result = await deleteUC.invoke(tCollectionId);

      expect(result, isA<Error>());
      expect((result as Error).error, "Session expired. Please log in.");
    });

    test('should return Success when repo succeeds', () async {
      when(mockAuthRepo.getCurrentUser()).thenReturn(tSupabaseUser);
      when(
        mockCollectionRepo.delete(tUserId, tCollectionId),
      ).thenAnswer((_) async => const Success(true));

      final result = await deleteUC.invoke(tCollectionId);

      expect(result, isA<Success<bool>>());
      verify(mockCollectionRepo.delete(tUserId, tCollectionId)).called(1);
    });

    test('should map ACTION_DENIED_OR_NOT_FOUND correctly', () async {
      when(mockAuthRepo.getCurrentUser()).thenReturn(tSupabaseUser);
      when(
        mockCollectionRepo.delete(any, any),
      ).thenAnswer((_) async => const Error("ACTION_DENIED_OR_NOT_FOUND"));

      final result = await deleteUC.invoke(tCollectionId);

      expect(result, isA<Error>());
      expect(
        (result as Error).error,
        "Access denied. Collection not found or you don't have permission.",
      );
    });
  });

  group('UpdateCollectionUseCase', () {
    test('should return Error when title is empty', () async {
      final result = await updateUC.invoke(tCollectionId, "");

      expect(result, isA<Error>());
      expect((result as Error).error, "Title can not be empty.");
    });

    test('should return Success when repo succeeds', () async {
      when(mockAuthRepo.getCurrentUser()).thenReturn(tSupabaseUser);
      when(
        mockCollectionRepo.update(tUserId, tCollectionId, tTitle),
      ).thenAnswer((_) async => const Success(true));

      final result = await updateUC.invoke(tCollectionId, tTitle);

      expect(result, isA<Success<bool>>());
      verify(
        mockCollectionRepo.update(tUserId, tCollectionId, tTitle),
      ).called(1);
    });

    test('should map ACTION_DENIED_OR_NOT_FOUND correctly', () async {
      when(mockAuthRepo.getCurrentUser()).thenReturn(tSupabaseUser);
      when(
        mockCollectionRepo.update(any, any, any),
      ).thenAnswer((_) async => const Error("ACTION_DENIED_OR_NOT_FOUND"));

      final result = await updateUC.invoke(tCollectionId, tTitle);

      expect(result, isA<Error>());
      expect(
        (result as Error).error,
        "Failed to update. Collection not found or access denied.",
      );
    });
  });

  group('GetCollectionWithSavedUseCase', () {
    const tPostId = 'post-789';

    test(
      'should return Success(List<Collection>) when session exists and repo succeeds',
      () async {
        // 1. Arrange
        when(mockAuthRepo.getCurrentUser()).thenReturn(tSupabaseUser);
        when(
          mockCollectionRepo.getUserCollectionsWithSaved(tUserId, tPostId),
        ).thenAnswer((_) async => Success(tCollectionList));

        // 2. Act
        final result = await getWithSavedUC.invoke(tPostId);

        // 3. Assert
        expect(result, isA<Success<List<Collection>>>());
        expect((result as Success).data, tCollectionList);

        // Pastikan parameter yang dikirim ke repo bener (user.id & postId)
        verify(
          mockCollectionRepo.getUserCollectionsWithSaved(tUserId, tPostId),
        ).called(1);
      },
    );

    test(
      'should return Error when user session is null (Early Return)',
      () async {
        // 1. Arrange (User null)
        when(mockAuthRepo.getCurrentUser()).thenReturn(null);

        // 2. Act
        final result = await getWithSavedUC.invoke(tPostId);

        // 3. Assert
        expect(result, isA<Error>());
        expect((result as Error).error, "Session expired. Please log in.");

        // PENTING: Verifikasi repo TIDAK PERNAH dipanggil kalo user-nya nggak ada
        verifyNever(mockCollectionRepo.getUserCollectionsWithSaved(any, any));
      },
    );

    test('should passthrough error message when repository fails', () async {
      // 1. Arrange
      const tErrorMessage = "DATABASE_ERROR";
      when(mockAuthRepo.getCurrentUser()).thenReturn(tSupabaseUser);
      when(
        mockCollectionRepo.getUserCollectionsWithSaved(any, any),
      ).thenAnswer((_) async => const Error(tErrorMessage));

      // 2. Act
      final result = await getWithSavedUC.invoke(tPostId);

      // 3. Assert
      expect(result, isA<Error>());
      expect((result as Error).error, tErrorMessage);
    });
  });
}
