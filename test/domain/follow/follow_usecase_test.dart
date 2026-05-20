import 'package:flutter_test/flutter_test.dart';
import 'package:imagix/core/network/result_state.dart';
import 'package:imagix/domain/auth/repository/auth_repository.dart';
import 'package:imagix/domain/follow/model/follow.dart';
import 'package:imagix/domain/follow/repository/follow_repository.dart';
import 'package:imagix/domain/follow/use_case/get_follower_use_case.dart';
import 'package:imagix/domain/follow/use_case/get_following_use_case.dart';
import 'package:imagix/domain/follow/use_case/remove_follower_use_case.dart';
import 'package:imagix/domain/follow/use_case/toggle_follow_use_case.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

import 'follow_usecase_test.mocks.dart';

@GenerateMocks([FollowRepository, AuthRepository])
void main() {
  provideDummy<ResultState<bool>>(const Success(true));
  provideDummy<ResultState<List<Follow>>>(const Success([]));

  late MockFollowRepository mockFollowRepo;
  late MockAuthRepository mockAuthRepo;
  late GetFollowerUseCase getFollowerUC;
  late GetFollowingUseCase getFollowingUC;
  late RemoveFollowerUseCase removeFollowerUC;
  late ToggleFollowUseCase toggleFollowUC;

  setUp(() {
    mockFollowRepo = MockFollowRepository();
    mockAuthRepo = MockAuthRepository();
    getFollowerUC = GetFollowerUseCase(mockFollowRepo);
    getFollowingUC = GetFollowingUseCase(mockFollowRepo);
    removeFollowerUC = RemoveFollowerUseCase(mockFollowRepo, mockAuthRepo);
    toggleFollowUC = ToggleFollowUseCase(mockFollowRepo, mockAuthRepo);
  });

  const tCurrentUserId = 'my-uid-123';
  const tTargetUserId = 'target-uid-456';

  final tSupabaseUser = supabase.User(
    id: tCurrentUserId,
    appMetadata: {},
    userMetadata: {},
    aud: 'authenticated',
    createdAt: DateTime.now().toIso8601String(),
  );

  // Mock Data Follow sesuai model terbaru Kakak
  final tFollowList = [
    Follow(
      userId: tTargetUserId,
      username: 'user_keren',
      photo: 'https://imagix.com/profile.jpg',
      isFollowing: true,
    ),
  ];

  group('GetFollowerUseCase', () {
    test('should return List<Follow> from repository', () async {
      when(
        mockFollowRepo.getFollowers(tCurrentUserId),
      ).thenAnswer((_) async => Success(tFollowList));

      final result = await getFollowerUC.invoke(tCurrentUserId);

      expect(result, isA<Success<List<Follow>>>());
      expect((result as Success).data, tFollowList);
      verify(mockFollowRepo.getFollowers(tCurrentUserId)).called(1);
    });
  });

  group('GetFollowingUseCase', () {
    test('should return List<Follow> from repository', () async {
      when(
        mockFollowRepo.getFollowing(tCurrentUserId),
      ).thenAnswer((_) async => Success(tFollowList));

      final result = await getFollowingUC.invoke(tCurrentUserId);

      expect(result, isA<Success<List<Follow>>>());
      expect((result as Success).data, tFollowList);
      verify(mockFollowRepo.getFollowing(tCurrentUserId)).called(1);
    });
  });

  group('RemoveFollowerUseCase', () {
    test(
      'should return Success when session exists and repo succeeds',
      () async {
        when(mockAuthRepo.getCurrentUser()).thenReturn(tSupabaseUser);
        when(
          mockFollowRepo.removeFollower(tCurrentUserId, tTargetUserId),
        ).thenAnswer((_) async => const Success(true));

        final result = await removeFollowerUC.invoke(tTargetUserId);

        expect(result, isA<Success<bool>>());
        verify(
          mockFollowRepo.removeFollower(tCurrentUserId, tTargetUserId),
        ).called(1);
      },
    );

    test('should return Error when user is not logged in', () async {
      when(mockAuthRepo.getCurrentUser()).thenReturn(null);

      final result = await removeFollowerUC.invoke(tTargetUserId);

      expect(result, isA<Error>());
      expect((result as Error).error, "Session expired. Please sign in again.");
      verifyNever(mockFollowRepo.removeFollower(any, any));
    });
  });

  group('ToggleFollowUseCase', () {
    test('should return Success(bool) when toggle succeeds', () async {
      when(mockAuthRepo.getCurrentUser()).thenReturn(tSupabaseUser);
      when(
        mockFollowRepo.toggleFollow(tCurrentUserId, tTargetUserId),
      ).thenAnswer((_) async => const Success(true));

      final result = await toggleFollowUC.invoke(tTargetUserId);

      expect(result, isA<Success<bool>>());
      expect((result as Success).data, true);
      verify(
        mockFollowRepo.toggleFollow(tCurrentUserId, tTargetUserId),
      ).called(1);
    });

    test('should map FOLLOW_ACTION_FAILED message correctly', () async {
      when(mockAuthRepo.getCurrentUser()).thenReturn(tSupabaseUser);
      when(
        mockFollowRepo.toggleFollow(any, any),
      ).thenAnswer((_) async => const Error("FOLLOW_ACTION_FAILED"));

      final result = await toggleFollowUC.invoke(tTargetUserId);

      expect(result, isA<Error>());
      expect(
        (result as Error).error,
        "Failed to follow. Please try again later.",
      );
    });

    test('should return Error when session is null', () async {
      when(mockAuthRepo.getCurrentUser()).thenReturn(null);

      final result = await toggleFollowUC.invoke(tTargetUserId);

      expect(result, isA<Error>());
      expect((result as Error).error, "Session expired. Please sign in again.");
    });
  });
}
