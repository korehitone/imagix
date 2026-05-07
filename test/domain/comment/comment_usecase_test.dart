import 'package:flutter_test/flutter_test.dart';
import 'package:imagix/core/network/result_state.dart';
import 'package:imagix/domain/auth/repository/auth_repository.dart';
import 'package:imagix/domain/comment/model/comment.dart';
import 'package:imagix/domain/comment/model/comment_request.dart';
import 'package:imagix/domain/comment/repository/comment_repository.dart';
import 'package:imagix/domain/comment/use_case/create_comment_use_case.dart';
import 'package:imagix/domain/comment/use_case/delete_comment_use_case.dart';
import 'package:imagix/domain/comment/use_case/get_comments_use_case.dart';
import 'package:imagix/domain/comment/use_case/update_comment_use_case.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

import 'comment_usecase_test.mocks.dart';

@GenerateMocks([CommentRepository, AuthRepository])
void main() {
  // Biar gak MissingDummyValueError
  provideDummy<ResultState<bool>>(const Success(true));
  provideDummy<ResultState<List<Comment>>>(const Success([]));

  late MockCommentRepository mockCommentRepo;
  late MockAuthRepository mockAuthRepo;
  late CreateCommentUseCase createUC;
  late DeleteCommentUseCase deleteUC;
  late GetCommentsUseCase getCommentsUC;
  late UpdateCommentUseCase updateUC;

  setUp(() {
    mockCommentRepo = MockCommentRepository();
    mockAuthRepo = MockAuthRepository();
    createUC = CreateCommentUseCase(mockCommentRepo, mockAuthRepo);
    deleteUC = DeleteCommentUseCase(mockCommentRepo, mockAuthRepo);
    getCommentsUC = GetCommentsUseCase(mockCommentRepo, mockAuthRepo);
    updateUC = UpdateCommentUseCase(mockCommentRepo, mockAuthRepo);
  });

  const tUserId = 'uid-123';
  const tPostId = 'post-456';
  const tCommentId = 1;
  final tCommentRequest = CommentRequest(
    postId: tPostId,
    comment: "Mantap Kak!",
  );

  final tSupabaseUser = supabase.User(
    id: tUserId,
    appMetadata: {},
    userMetadata: {},
    aud: 'authenticated',
    createdAt: DateTime.now().toIso8601String(),
  );

  // Data Mock Comment sesuai model terbaru (mendukung replies)
  final tComment = Comment(
    id: tCommentId,
    postId: tPostId,
    userId: tUserId,
    parentId: null,
    // Komentar utama
    comment: "Mantap Kak!",
    username: "kak_dev",
    userPhoto: "https://imagix.com/photo.png",
    createdAt: DateTime.now(),
    replies: [], // List kosong sesuai default
  );

  final tCommentsList = [tComment];

  group('CreateCommentUseCase', () {
    test('should return Error when comment is empty', () async {
      final emptyRequest = CommentRequest(postId: tPostId, comment: "   ");
      final result = await createUC.invoke(emptyRequest);

      expect(result, isA<Error>());
      expect((result as Error).error, "Comment can not be empty.");
      verifyNever(mockCommentRepo.create(any, any));
    });

    test('should return Error when session is null', () async {
      when(mockAuthRepo.getCurrentUser()).thenReturn(null);

      final result = await createUC.invoke(tCommentRequest);

      expect(result, isA<Error>());
      expect((result as Error).error, "Session expired. Please sign in again.");
    });

    test('should return Success when repository succeeds', () async {
      when(mockAuthRepo.getCurrentUser()).thenReturn(tSupabaseUser);
      when(
        mockCommentRepo.create(tUserId, tCommentRequest),
      ).thenAnswer((_) async => const Success(true));

      final result = await createUC.invoke(tCommentRequest);

      expect(result, isA<Success<bool>>());
      verify(mockCommentRepo.create(tUserId, tCommentRequest)).called(1);
    });

    test('should map COMMENT_CREATE_FAILED message correctly', () async {
      when(mockAuthRepo.getCurrentUser()).thenReturn(tSupabaseUser);
      when(
        mockCommentRepo.create(any, any),
      ).thenAnswer((_) async => const Error("COMMENT_CREATE_FAILED"));

      final result = await createUC.invoke(tCommentRequest);

      expect(result, isA<Error>());
      expect((result as Error).error, "Failed to post comment.");
    });
  });

  group('DeleteCommentUseCase', () {
    test('should return Success when repository succeeds', () async {
      when(mockAuthRepo.getCurrentUser()).thenReturn(tSupabaseUser);
      when(
        mockCommentRepo.delete(tUserId, tCommentId),
      ).thenAnswer((_) async => const Success(true));

      final result = await deleteUC.invoke(tCommentId);

      expect(result, isA<Success<bool>>());
      verify(mockCommentRepo.delete(tUserId, tCommentId)).called(1);
    });

    test('should map COMMENT_NOT_FOUND_OR_DENIED message correctly', () async {
      when(mockAuthRepo.getCurrentUser()).thenReturn(tSupabaseUser);
      when(
        mockCommentRepo.delete(any, any),
      ).thenAnswer((_) async => const Error("COMMENT_NOT_FOUND_OR_DENIED"));

      final result = await deleteUC.invoke(tCommentId);

      expect(result, isA<Error>());
      expect((result as Error).error, "Failed to delete. Access denied.");
    });
  });

  group('GetCommentsUseCase', () {
    test('should return List<Comment> when logged in', () async {
      when(mockAuthRepo.getCurrentUser()).thenReturn(tSupabaseUser);
      when(
        mockCommentRepo.getComments(tPostId),
      ).thenAnswer((_) async => Success(tCommentsList));

      final result = await getCommentsUC.invoke(tPostId);

      expect(result, isA<Success<List<Comment>>>());
      expect((result as Success).data, tCommentsList);
      verify(mockCommentRepo.getComments(tPostId)).called(1);
    });

    test('should return Error when user is not logged in', () async {
      when(mockAuthRepo.getCurrentUser()).thenReturn(null);

      final result = await getCommentsUC.invoke(tPostId);

      expect(result, isA<Error>());
      expect((result as Error).error, "Please login to view comments.");
      verifyNever(mockCommentRepo.getComments(any));
    });
  });

  group('UpdateCommentUseCase', () {
    test('should return Error when comment text is empty', () async {
      final emptyRequest = CommentRequest(postId: tPostId, comment: "");
      final result = await updateUC.invoke(tCommentId, emptyRequest);

      expect(result, isA<Error>());
      expect((result as Error).error, "Comment can not be empty.");
    });

    test('should return Success when repository succeeds', () async {
      when(mockAuthRepo.getCurrentUser()).thenReturn(tSupabaseUser);
      when(
        mockCommentRepo.update(tUserId, tCommentId, tCommentRequest),
      ).thenAnswer((_) async => const Success(true));

      final result = await updateUC.invoke(tCommentId, tCommentRequest);

      expect(result, isA<Success<bool>>());
      verify(
        mockCommentRepo.update(tUserId, tCommentId, tCommentRequest),
      ).called(1);
    });

    test(
      'should map COMMENT_NOT_FOUND_OR_DENIED correctly during update',
      () async {
        when(mockAuthRepo.getCurrentUser()).thenReturn(tSupabaseUser);
        when(
          mockCommentRepo.update(any, any, any),
        ).thenAnswer((_) async => const Error("COMMENT_NOT_FOUND_OR_DENIED"));

        final result = await updateUC.invoke(tCommentId, tCommentRequest);

        expect(result, isA<Error>());
        expect(
          (result as Error).error,
          "Failed to update. Comment not found or access denied.",
        );
      },
    );
  });
}
