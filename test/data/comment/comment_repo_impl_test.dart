import 'package:flutter_test/flutter_test.dart';
import 'package:imagix/core/network/result_state.dart';
import 'package:imagix/data/comment/repository/comment_repository_impl.dart';
import 'package:imagix/domain/comment/model/comment.dart';
import 'package:imagix/domain/comment/model/comment_request.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'comment_repo_impl_test.mocks.dart';

@GenerateNiceMocks([
  MockSpec<SupabaseClient>(),
  MockSpec<SupabaseQueryBuilder>(),
  MockSpec<PostgrestFilterBuilder<List<Map<String, dynamic>>>>(
    as: #MockPostgrestFilterBuilderList,
  ),
  MockSpec<PostgrestFilterBuilder<Map<String, dynamic>?>>(
    as: #MockPostgrestFilterBuilderSingle,
  ),
])
void main() {
  late CommentRepositoryImpl repository;
  late MockSupabaseClient mockSupabaseClient;
  late MockSupabaseQueryBuilder mockSupabaseBuilder;
  late MockPostgrestFilterBuilderList mockFilterBuilderList;
  late MockPostgrestFilterBuilderSingle mockFilterBuilderSingle;

  setUp(() {
    mockSupabaseClient = MockSupabaseClient();
    mockSupabaseBuilder = MockSupabaseQueryBuilder();
    mockFilterBuilderList = MockPostgrestFilterBuilderList();
    mockFilterBuilderSingle = MockPostgrestFilterBuilderSingle();

    repository = CommentRepositoryImpl(mockSupabaseClient);
  });

  group('CommentRepositoryImpl', () {
    const tUserId = 'user-123';
    const tPostId = 'post-999';
    const tCommentId = 1;
    final tNow = DateTime.now().toIso8601String();

    final tCommentMap = {
      'id': 1,
      'post_id': tPostId,
      'user_id': tUserId,
      'parent_id': null,
      'comment': 'Hello World',
      'username': 'gemini_user',
      'user_photo': null,
      'created_at': tNow,
      'updated_at': tNow,
    };

    final tReplyMap = {
      'id': 2,
      'post_id': tPostId,
      'user_id': 'other-user',
      'parent_id': 1, // Reply ke id 1
      'comment': 'Reply text',
      'username': 'reply_user',
      'user_photo': null,
      'created_at': tNow,
      'updated_at': tNow,
    };

    group('getComments', () {
      test('should return nested comments on success', () async {
        when(
          mockSupabaseClient.from('comment_list_view'),
        ).thenAnswer((_) => mockSupabaseBuilder);
        when(
          mockSupabaseBuilder.select(),
        ).thenAnswer((_) => mockFilterBuilderList);
        when(
          mockFilterBuilderList.eq('post_id', tPostId),
        ).thenAnswer((_) => mockFilterBuilderList);
        when(
          mockFilterBuilderList.order('created_at', ascending: true),
        ).thenAnswer((_) => mockFilterBuilderList);

        when(
          mockFilterBuilderList.then(any, onError: anyNamed('onError')),
        ).thenAnswer((inv) {
          final callback = inv.positionalArguments[0] as Function;
          // Kita kirim 2 data flat: 1 root, 1 reply
          return Future.value(callback([tCommentMap, tReplyMap]));
        });

        final result = await repository.getComments(tPostId);

        expect(result, isA<Success<List<Comment>>>());
        final data = (result as Success<List<Comment>>).data;

        // Cek apakah nesting jalan (root cuma 1, tapi punya 1 reply)
        expect(data.length, 1);
        expect(data.first.replies.length, 1);
        expect(data.first.replies.first.id, 2);
      });

      test('should return Error when fetch fails', () async {
        when(mockSupabaseClient.from(any)).thenThrow(Exception('DB Error'));
        final result = await repository.getComments(tPostId);
        expect(result, isA<Error>());
      });
    });

    group('create', () {
      final tRequest = CommentRequest(
        postId: tPostId,
        comment: 'Nice!',
        parentId: null,
      );

      test('should return Success(true) when comment created', () async {
        when(
          mockSupabaseClient.from('comments'),
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
          return Future.value(callback({'id': 100}));
        });

        final result = await repository.create(tUserId, tRequest);
        expect(result, isA<Success<bool>>());
      });

      test('should return Error when response is null', () async {
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

        final result = await repository.create(tUserId, tRequest);
        expect((result as Error).error, "COMMENT_CREATE_FAILED");
      });
    });

    group('update', () {
      final tRequest = CommentRequest(
        postId: tPostId,
        comment: 'Updated',
        parentId: null,
      );

      test('should return Success(true) on valid update', () async {
        when(
          mockSupabaseClient.from('comments'),
        ).thenAnswer((_) => mockSupabaseBuilder);
        when(
          mockSupabaseBuilder.update(any),
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
          return Future.value(callback({'id': tCommentId}));
        });

        final result = await repository.update(tUserId, tCommentId, tRequest);
        expect(result, isA<Success<bool>>());
      });

      test(
        'should return Error when update fails or record not found',
        () async {
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
            mockFilterBuilderList.select(any),
          ).thenAnswer((_) => mockFilterBuilderList);
          when(
            mockFilterBuilderList.maybeSingle(),
          ).thenAnswer((_) => mockFilterBuilderSingle);

          when(
            mockFilterBuilderSingle.then(any, onError: anyNamed('onError')),
          ).thenAnswer((inv) {
            final callback = inv.positionalArguments[0] as Function;
            // Kita simulasiin record gak ketemu atau denied by RLS
            return Future.value(callback(null));
          });

          final result = await repository.update(tUserId, tCommentId, tRequest);

          expect(result, isA<Error>());
          expect((result as Error).error, "COMMENT_NOT_FOUND_OR_DENIED");
        },
      );
    });

    group('delete', () {
      test('should return Success(true) when record deleted', () async {
        when(
          mockSupabaseClient.from('comments'),
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
          return Future.value(callback({'id': tCommentId}));
        });

        final result = await repository.delete(tUserId, tCommentId);
        expect(result, isA<Success<bool>>());
      });

      test('should return Error when record not found or denied', () async {
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

        final result = await repository.delete(tUserId, tCommentId);
        expect((result as Error).error, "COMMENT_NOT_FOUND_OR_DENIED");
      });
    });
  });
}
