import 'package:flutter_test/flutter_test.dart';
import 'package:imagix/core/network/result_state.dart';
import 'package:imagix/data/follow/repository/follow_repository_impl.dart';
import 'package:imagix/domain/follow/model/follow.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'follow_repo_impl_test.mocks.dart';

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
  late FollowRepositoryImpl repository;
  late MockSupabaseClient mockSupabaseClient;
  late MockSupabaseQueryBuilder mockSupabaseBuilder;
  late MockPostgrestFilterBuilderList mockFilterBuilderList;
  late MockPostgrestFilterBuilderSingle mockFilterBuilderSingle;

  setUp(() {
    mockSupabaseClient = MockSupabaseClient();
    mockSupabaseBuilder = MockSupabaseQueryBuilder();
    mockFilterBuilderList = MockPostgrestFilterBuilderList();
    mockFilterBuilderSingle = MockPostgrestFilterBuilderSingle();

    repository = FollowRepositoryImpl(mockSupabaseClient);
  });

  group('FollowRepositoryImpl', () {
    const tCurrentUserId = 'user-me';
    const tTargetUserId = 'user-them';
    final tNow = DateTime.now().toIso8601String();

    final tFollowMap = {
      'follow_id': 1,
      'created_at': tNow,
      'follower_id': 'user-a',
      'follower_username': 'user_a_name',
      'follower_photo': null,
      'following_id': 'user-b',
      'following_username': 'user_b_name',
      'following_photo': null,
      'is_followed_by_me': true,
    };

    group('getFollowers', () {
      test('should return list of followers on success', () async {
        when(
          mockSupabaseClient.from('follows_view'),
        ).thenAnswer((_) => mockSupabaseBuilder);
        when(
          mockSupabaseBuilder.select(),
        ).thenAnswer((_) => mockFilterBuilderList);
        when(
          mockFilterBuilderList.eq('following_id', tCurrentUserId),
        ).thenAnswer((_) => mockFilterBuilderList);
        when(
          mockFilterBuilderList.order('created_at', ascending: false),
        ).thenAnswer((_) => mockFilterBuilderList);

        when(
          mockFilterBuilderList.then(any, onError: anyNamed('onError')),
        ).thenAnswer((inv) {
          final callback = inv.positionalArguments[0] as Function;
          return Future.value(callback([tFollowMap]));
        });

        final result = await repository.getFollowers(tCurrentUserId);

        expect(result, isA<Success<List<Follow>>>());
        final data = (result as Success<List<Follow>>).data;
        expect(data.length, 1);
        // Pastikan mapping userId benar untuk follower
        expect(data.first.userId, tFollowMap['follower_id']);
      });

      test('should return Error when fetch followers fails', () async {
        when(
          mockSupabaseClient.from('follows_view'),
        ).thenThrow(Exception('Followers fail'));

        final result = await repository.getFollowers(tCurrentUserId);

        expect(result, isA<Error>());
      });
    });

    group('getFollowing', () {
      test('should return list of following on success', () async {
        when(
          mockSupabaseClient.from('follows_view'),
        ).thenAnswer((_) => mockSupabaseBuilder);
        when(
          mockSupabaseBuilder.select(),
        ).thenAnswer((_) => mockFilterBuilderList);
        when(
          mockFilterBuilderList.eq('follower_id', tCurrentUserId),
        ).thenAnswer((_) => mockFilterBuilderList);
        when(
          mockFilterBuilderList.order('created_at', ascending: false),
        ).thenAnswer((_) => mockFilterBuilderList);

        when(
          mockFilterBuilderList.then(any, onError: anyNamed('onError')),
        ).thenAnswer((inv) {
          final callback = inv.positionalArguments[0] as Function;
          return Future.value(callback([tFollowMap]));
        });

        final result = await repository.getFollowing(tCurrentUserId);

        expect(result, isA<Success<List<Follow>>>());
        final data = (result as Success<List<Follow>>).data;
        expect(data.length, 1);
        // Pastikan mapping userId benar untuk following
        expect(data.first.userId, tFollowMap['following_id']);
      });

      test('should return Error when fetch following fails', () async {
        when(
          mockSupabaseClient.from('follows_view'),
        ).thenThrow(Exception('Following fail'));

        final result = await repository.getFollowing(tCurrentUserId);

        expect(result, isA<Error>());
      });
    });

    group('toggleFollow', () {
      test(
        'should insert and return Success(true) when record NOT exists (Follow)',
        () async {
          when(
            mockSupabaseClient.from('follows'),
          ).thenAnswer((_) => mockSupabaseBuilder);
          when(
            mockSupabaseBuilder.select(),
          ).thenAnswer((_) => mockFilterBuilderList);
          when(
            mockFilterBuilderList.eq(any, any),
          ).thenAnswer((_) => mockFilterBuilderList);

          // 1. Mock existing check returns null
          when(
            mockFilterBuilderList.maybeSingle(),
          ).thenAnswer((_) => mockFilterBuilderSingle);
          when(
            mockFilterBuilderSingle.then(any, onError: anyNamed('onError')),
          ).thenAnswer((inv) {
            final callback = inv.positionalArguments[0] as Function;
            return Future.value(callback(null));
          });

          // 2. Mock Insert
          final mockInsertBuilder = MockSupabaseQueryBuilder();
          final mockInsertFilter = MockPostgrestFilterBuilderList();
          final mockInsertSingle = MockPostgrestFilterBuilderSingle();

          when(
            mockSupabaseClient.from('follows'),
          ).thenAnswer((_) => mockInsertBuilder);
          when(
            mockInsertBuilder.insert(any),
          ).thenAnswer((_) => mockInsertFilter);
          when(
            mockInsertFilter.select('follower_id'),
          ).thenAnswer((_) => mockInsertFilter);
          when(
            mockInsertFilter.maybeSingle(),
          ).thenAnswer((_) => mockInsertSingle);

          when(
            mockInsertSingle.then(any, onError: anyNamed('onError')),
          ).thenAnswer((inv) {
            final callback = inv.positionalArguments[0] as Function;
            return Future.value(callback({'follower_id': tCurrentUserId}));
          });

          final result = await repository.toggleFollow(
            tCurrentUserId,
            tTargetUserId,
          );

          expect(result, isA<Success<bool>>());
          expect((result as Success<bool>).data, true);
        },
      );

      test(
        'should delete and return Success(false) when record EXISTS (Unfollow)',
        () async {
          when(
            mockSupabaseClient.from('follows'),
          ).thenAnswer((_) => mockSupabaseBuilder);
          when(
            mockSupabaseBuilder.select(),
          ).thenAnswer((_) => mockFilterBuilderList);
          when(
            mockFilterBuilderList.eq(any, any),
          ).thenAnswer((_) => mockFilterBuilderList);

          // 1. Mock existing check returns data
          when(
            mockFilterBuilderList.maybeSingle(),
          ).thenAnswer((_) => mockFilterBuilderSingle);
          when(
            mockFilterBuilderSingle.then(any, onError: anyNamed('onError')),
          ).thenAnswer((inv) {
            final callback = inv.positionalArguments[0] as Function;
            return Future.value(callback({'follower_id': tCurrentUserId}));
          });

          // 2. Mock Delete
          when(
            mockSupabaseBuilder.delete(),
          ).thenAnswer((_) => mockFilterBuilderList);

          final result = await repository.toggleFollow(
            tCurrentUserId,
            tTargetUserId,
          );

          expect(result, isA<Success<bool>>());
          expect((result as Success<bool>).data, false);
        },
      );

      test('should return Error when follow action failed', () async {
        // Simulasi existing null tapi insert juga null
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
          mockFilterBuilderList.maybeSingle(),
        ).thenAnswer((_) => mockFilterBuilderSingle);

        // Existing check null
        when(
          mockFilterBuilderSingle.then(any, onError: anyNamed('onError')),
        ).thenAnswer((inv) {
          final callback = inv.positionalArguments[0] as Function;
          return Future.value(callback(null));
        });

        // Insert mock
        when(
          mockSupabaseBuilder.insert(any),
        ).thenAnswer((_) => mockFilterBuilderList);
        when(
          mockFilterBuilderList.select(any),
        ).thenAnswer((_) => mockFilterBuilderList);
        // Insert return null
        when(
          mockFilterBuilderList.maybeSingle(),
        ).thenAnswer((_) => mockFilterBuilderSingle);

        final result = await repository.toggleFollow(
          tCurrentUserId,
          tTargetUserId,
        );
        expect((result as Error).error, "FOLLOW_ACTION_FAILED");
      });
    });

    group('removeFollower', () {
      test('should return Success(true) when follower removed', () async {
        when(
          mockSupabaseClient.from('follows'),
        ).thenAnswer((_) => mockSupabaseBuilder);
        when(
          mockSupabaseBuilder.delete(),
        ).thenAnswer((_) => mockFilterBuilderList);
        when(
          mockFilterBuilderList.eq(any, any),
        ).thenAnswer((_) => mockFilterBuilderList);

        final result = await repository.removeFollower(
          tCurrentUserId,
          tTargetUserId,
        );
        expect(result, isA<Success<bool>>());
      });

      test('should return Error when delete throws exception', () async {
        when(mockSupabaseClient.from(any)).thenThrow(Exception('Delete fail'));
        final result = await repository.removeFollower(
          tCurrentUserId,
          tTargetUserId,
        );
        expect(result, isA<Error>());
      });
    });
  });
}
