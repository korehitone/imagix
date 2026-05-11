import 'package:flutter_test/flutter_test.dart';
import 'package:imagix/core/network/result_state.dart';
import 'package:imagix/domain/auth/repository/auth_repository.dart';
import 'package:imagix/domain/common/model/user_profile.dart';
import 'package:imagix/domain/profile/model/profile.dart';
import 'package:imagix/domain/profile/model/profile_request.dart';
import 'package:imagix/domain/profile/repository/profile_repository.dart';
import 'package:imagix/domain/profile/use_case/get_profile_use_case.dart';
import 'package:imagix/domain/profile/use_case/get_profiles_by_query_use_case.dart';
import 'package:imagix/domain/profile/use_case/update_profile_use_case.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

import 'profile_usecase_test.mocks.dart';

@GenerateMocks([ProfileRepository, AuthRepository])
void main() {
  provideDummy<ResultState<Profile>>(
    Success(Profile(
      id: '',
      username: '',
      totalPosts: 0,
      totalCollections: 0,
      totalFollowers: 0,
      totalFollowings: 0,
      isFollowing: false,
    )),
  );
  provideDummy<ResultState<List<Profile>>>(Success([]));
  provideDummy<ResultState<UserProfile>>(
    Success(UserProfile(
      id: '',
      username: '',
      email: null,
      bio: null,
      photo: null,
    )),
  );

  late MockProfileRepository mockProfileRepo;
  late MockAuthRepository mockAuthRepo;
  late GetProfilesByQueryUseCase getProfilesByQueryUC;
  late GetProfileUseCase getProfileUC;
  late UpdateProfileUseCase updateProfileUC;

  setUp(() {
    mockProfileRepo = MockProfileRepository();
    mockAuthRepo = MockAuthRepository();
    getProfilesByQueryUC = GetProfilesByQueryUseCase(mockProfileRepo);
    getProfileUC = GetProfileUseCase(mockProfileRepo, mockAuthRepo);
    updateProfileUC = UpdateProfileUseCase(mockProfileRepo, mockAuthRepo);
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

  final tProfile = Profile(
    id: tTargetUserId,
    username: 'testuser',
    bio: 'Hello!',
    totalPosts: 5,
    totalCollections: 2,
    totalFollowers: 10,
    totalFollowings: 3,
    isFollowing: false,
  );

  final tOwnProfile = Profile(
    id: tCurrentUserId,
    username: 'me',
    bio: 'My bio',
    totalPosts: 3,
    totalCollections: 1,
    totalFollowers: 5,
    totalFollowings: 7,
    isFollowing: false,
  );

  final tProfileRequest = ProfileRequest(
    username: 'newuser',
    bio: 'New bio',
  );

  final tLocalUser = UserProfile(
    id: tCurrentUserId,
    username: 'olduser',
    email: 'test@test.com',
    bio: 'Old bio',
    photo: null,
  );

  group('GetProfilesByQueryUseCase', () {
    test('should return list of profiles from repository', () async {
      when(
        mockProfileRepo.getProfilesByQuery(
          'test',
          offset: 0,
          limit: 20,
        ),
      ).thenAnswer((_) async => Success([tProfile]));

      final result = await getProfilesByQueryUC.invoke('test',
          offset: 0, limit: 20);

      expect(result, isA<Success<List<Profile>>>());
      expect((result as Success).data, [tProfile]);
      verify(
        mockProfileRepo.getProfilesByQuery('test', offset: 0, limit: 20),
      ).called(1);
    });
  });

  group('GetProfileUseCase', () {
    test('should return profile when authenticated', () async {
      when(mockAuthRepo.getCurrentUser()).thenReturn(tSupabaseUser);
      when(
        mockProfileRepo.getProfile(tCurrentUserId, tTargetUserId),
      ).thenAnswer((_) async => Success(tProfile));

      final result = await getProfileUC.invoke(tTargetUserId);

      expect(result, isA<Success<Profile>>());
      expect((result as Success<Profile>).data, tProfile);
    });

    test('should sync local user when viewing own profile', () async {
      when(mockAuthRepo.getCurrentUser()).thenReturn(tSupabaseUser);
      when(mockAuthRepo.getLocalUser()).thenReturn(tLocalUser);
      when(
        mockProfileRepo.getProfile(tCurrentUserId, tCurrentUserId),
      ).thenAnswer((_) async => Success(tOwnProfile));

      await getProfileUC.invoke(tCurrentUserId);

      verify(mockAuthRepo.saveLocalUser(any)).called(1);
    });

    test('should map PROFILE_NOT_FOUND to user-friendly message', () async {
      when(mockAuthRepo.getCurrentUser()).thenReturn(tSupabaseUser);
      when(
        mockProfileRepo.getProfile(tCurrentUserId, tTargetUserId),
      ).thenAnswer((_) async => const Error("PROFILE_NOT_FOUND"));

      final result = await getProfileUC.invoke(tTargetUserId);

      expect(result, isA<Error>());
      expect(
        (result as Error).error,
        "User profile not found.",
      );
    });

    test('should return Error when session is null', () async {
      when(mockAuthRepo.getCurrentUser()).thenReturn(null);

      final result = await getProfileUC.invoke(tTargetUserId);

      expect(result, isA<Error>());
      expect(
        (result as Error).error,
        "Session expired. Please sign in again.",
      );
    });
  });

  group('UpdateProfileUseCase', () {
    test('should return Success when profile updated successfully', () async {
      when(mockAuthRepo.getCurrentUser()).thenReturn(tSupabaseUser);
      when(
        mockProfileRepo.updateProfile(tCurrentUserId, tProfileRequest),
      ).thenAnswer((_) async => Success(tLocalUser));

      final result = await updateProfileUC.invoke(tProfileRequest);

      expect(result, isA<Success<bool>>());
      expect((result as Success<bool>).data, true);
    });

    test('should save local user on successful update', () async {
      when(mockAuthRepo.getCurrentUser()).thenReturn(tSupabaseUser);
      when(
        mockProfileRepo.updateProfile(any, any),
      ).thenAnswer((_) async => Success(tLocalUser));

      await updateProfileUC.invoke(tProfileRequest);

      verify(mockAuthRepo.saveLocalUser(tLocalUser)).called(1);
    });

    test('should return Error when username is empty', () async {
      final request = ProfileRequest(username: '', bio: 'New bio');

      final result = await updateProfileUC.invoke(request);

      expect(result, isA<Error>());
      expect(
        (result as Error).error,
        "Username can not be empty.",
      );
      verifyNever(mockProfileRepo.updateProfile(any, any));
    });

    test('should return Error when username contains invalid characters',
        () async {
      final request = ProfileRequest(username: 'user name!', bio: 'New bio');

      final result = await updateProfileUC.invoke(request);

      expect(result, isA<Error>());
      expect(
        (result as Error).error,
        "Username can only contain letters, numbers, underscore (_) and dot (.).",
      );
    });

    test('should return Error when session is null', () async {
      when(mockAuthRepo.getCurrentUser()).thenReturn(null);

      final result = await updateProfileUC.invoke(tProfileRequest);

      expect(result, isA<Error>());
      expect(
        (result as Error).error,
        "Session expired. Please sign in again.",
      );
    });

    test('should map UPDATE_PROFILE_FAILED to user-friendly message',
        () async {
      when(mockAuthRepo.getCurrentUser()).thenReturn(tSupabaseUser);
      when(
        mockProfileRepo.updateProfile(any, any),
      ).thenAnswer((_) async => const Error("UPDATE_PROFILE_FAILED"));

      final result = await updateProfileUC.invoke(tProfileRequest);

      expect(result, isA<Error>());
      expect(
        (result as Error).error,
        "Failed to update profile.",
      );
    });
  });
}
