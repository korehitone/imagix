// test/data/auth/auth_repo_impl_test.dart

import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:imagix/core/local/global_preferences.dart';
import 'package:imagix/core/network/result_state.dart';
import 'package:imagix/data/auth/repository/auth_repository_impl.dart';
import 'package:imagix/domain/common/model/user_profile.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// import '../../helper/mocks.dart' hide MockUser, MockGlobalPreferences;
import 'auth_repo_impl_test.mocks.dart';

final testUserProfile = UserProfile(
  id: 'user123',
  username: 'testuser',
  email: 'test@email.com',
  bio: 'Test bio',
  photo: 'https://example.com/photo.jpg',
  totalPosts: 5,
  totalCollections: 3,
  totalFollowers: 100,
  totalFollowings: 50,
);

@GenerateNiceMocks([
  MockSpec<GlobalPreferences>(),
  MockSpec<User>(),
  MockSpec<UserIdentity>(),
  MockSpec<SupabaseClient>(),
  MockSpec<GoTrueClient>(),
  MockSpec<SupabaseQueryBuilder>(),
  MockSpec<PostgrestFilterBuilder>(),
  MockSpec<PostgrestFilterBuilder<List<Map<String, dynamic>>>>(
    as: #MockPostgrestFilterBuilderList,
  ),
  MockSpec<PostgrestFilterBuilder<Map<String, dynamic>?>>(
    as: #MockPostgrestFilterBuilderSingle,
  ),
  MockSpec<ResendResponse>(),
  MockSpec<AuthResponse>(),
])
void main() {
  late AuthRepositoryImpl repository;
  late MockSupabaseClient mockSupabaseClient;
  late MockGlobalPreferences mockGlobalPreferences;
  late MockGoTrueClient mockGoTrueClient;
  late MockSupabaseQueryBuilder mockSupabaseBuilder;
  late MockPostgrestFilterBuilderList mockFilterBuilderList;
  late MockPostgrestFilterBuilderSingle mockFilterBuilderSingle;
  late MockUser mockUser;

  setUp(() {
    mockGlobalPreferences = MockGlobalPreferences();
    mockGoTrueClient = MockGoTrueClient();
    mockUser = MockUser();
    mockSupabaseClient = MockSupabaseClient();
    mockSupabaseBuilder = MockSupabaseQueryBuilder();
    mockFilterBuilderList = MockPostgrestFilterBuilderList();
    mockFilterBuilderSingle = MockPostgrestFilterBuilderSingle();

    when(mockSupabaseClient.auth).thenReturn(mockGoTrueClient);

    repository = AuthRepositoryImpl(mockSupabaseClient, mockGlobalPreferences);
  });

  group('AuthRepositoryImpl', () {
    // get current user
    group('getCurrentUser()', () {
      test('should return current user when user is logged in', () {
        when(mockGoTrueClient.currentUser).thenReturn(mockUser);

        final result = repository.getCurrentUser();

        expect(result, mockUser);
        verify(mockGoTrueClient.currentUser).called(1);
      });

      test('should return null when no user is logged in', () {
        when(mockGoTrueClient.currentUser).thenReturn(null);

        final result = repository.getCurrentUser();

        expect(result, isNull);
        verify(mockGoTrueClient.currentUser).called(1);
      });
    });

    //   get local user
    group('getLocalUser()', () {
      test('should return UserProfile when user is stored locally', () {
        final jsonString = jsonEncode(testUserProfile.toJson());
        when(
          mockGlobalPreferences.getString('user_profile'),
        ).thenReturn(jsonString);

        final result = repository.getLocalUser();

        expect(result, isNotNull);
        expect(result!.id, 'user123');
        expect(result.username, 'testuser');
        expect(result.email, 'test@email.com');
        expect(result.bio, 'Test bio');
        expect(result.photo, 'https://example.com/photo.jpg');
        verify(mockGlobalPreferences.getString('user_profile')).called(1);
      });

      test('should return null when no local user is stored', () {
        when(mockGlobalPreferences.getString('user_profile')).thenReturn(null);

        final result = repository.getLocalUser();

        expect(result, null);
        verify(mockGlobalPreferences.getString('user_profile')).called(1);
      });

      test('should parse JSON correctly with all fields', () {
        final fullJson = jsonEncode({
          'id': 'user456',
          'username': 'johndoe',
          'email': 'john@example.com',
          'bio': 'Software developer',
          'photo': 'https://example.com/john.jpg',
          'total_posts': 10,
          'total_collections': 5,
          'total_followers': 500,
          'total_followings': 100,
        });
        when(
          mockGlobalPreferences.getString('user_profile'),
        ).thenReturn(fullJson);

        final result = repository.getLocalUser();

        expect(result!.id, 'user456');
        expect(result.username, 'johndoe');
        expect(result.totalPosts, 10);
        expect(result.totalFollowers, 500);
      });
    });
    //   save local user
    group('saveLocalUser()', () {
      test('should save user as JSON string to preferences', () async {
        when(
          mockGlobalPreferences.saveString('user_profile', any),
        ).thenAnswer((_) async => {});

        await repository.saveLocalUser(testUserProfile);

        verify(
          mockGlobalPreferences.saveString(
            'user_profile',
            jsonEncode(testUserProfile.toJson()),
          ),
        ).called(1);
      });

      test('should save with correct JSON structure', () async {
        final capturedJson = <String>[];
        when(mockGlobalPreferences.saveString('user_profile', any)).thenAnswer((
          invocation,
        ) async {
          capturedJson.add(invocation.positionalArguments[1]);
        });

        await repository.saveLocalUser(testUserProfile);

        expect(capturedJson.length, 1);
        final decoded = jsonDecode(capturedJson.first);
        expect(decoded['id'], 'user123');
        expect(decoded['username'], 'testuser');
        expect(decoded['email'], 'test@email.com');
        expect(decoded['total_posts'], 5);
      });

      test('should handle null values in user profile', () async {
        final userWithNulls = UserProfile(
          id: 'user789',
          username: 'nulluser',
          email: null,
          bio: null,
          photo: null,
        );
        when(
          mockGlobalPreferences.saveString(any, any),
        ).thenAnswer((_) async => {});

        await repository.saveLocalUser(userWithNulls);

        verify(mockGlobalPreferences.saveString(any, any)).called(1);
      });
    });
    //   delete local user
    group('clearLocalUser()', () {
      test('should remove user_profile from local preferences', () async {
        when(
          mockGlobalPreferences.remove('user_profile'),
        ).thenAnswer((_) async => {});

        await repository.clearLocalUser();

        verify(mockGlobalPreferences.remove('user_profile')).called(1);
      });

      test('should only remove the user_profile key', () async {
        when(mockGlobalPreferences.remove(any)).thenAnswer((_) async => {});

        await repository.clearLocalUser();

        verify(mockGlobalPreferences.remove('user_profile')).called(1);
        verifyNoMoreInteractions(mockGlobalPreferences);
      });
    });
    //   login - success
    group('login() - Success', () {
      test('should return Success with UserProfile on valid login', () async {
        // Arrange
        final mockAuthResponse = MockAuthResponse();
        final mockUser = MockUser();
        const userId = 'user123';
        const userEmail = 'test@email.com';

        when(mockUser.id).thenReturn(userId);
        when(mockUser.email).thenReturn(userEmail);
        when(mockAuthResponse.user).thenReturn(mockUser);

        when(
          mockGoTrueClient.signInWithPassword(
            email: userEmail,
            password: 'password123',
          ),
        ).thenAnswer((_) async => mockAuthResponse);

        when(
          (mockSupabaseClient as dynamic).rpc(
            'get_account_deleted_status',
            params: {'target_user_id': userId},
          ),
        ).thenAnswer((_) => mockFilterBuilderList);

        when(
          mockFilterBuilderList.then(any, onError: anyNamed('onError')),
        ).thenAnswer((invocation) {
          final callback = invocation.positionalArguments[0] as Function;
          return Future.value(
            callback([
              {'deleted_at': null},
            ]),
          );
        });

        when(
          mockSupabaseClient.from('profile_view'),
        ).thenAnswer((_) => mockSupabaseBuilder);

        when(
          mockSupabaseBuilder.select(),
        ).thenAnswer((_) => mockFilterBuilderList);

        when(
          mockFilterBuilderList.eq('id', userId),
        ).thenAnswer((_) => mockFilterBuilderList);

        when(
          mockFilterBuilderList.maybeSingle(),
        ).thenAnswer((_) => mockFilterBuilderSingle);

        when(
          mockFilterBuilderSingle.then(any, onError: anyNamed('onError')),
        ).thenAnswer((invocation) {
          final callback = invocation.positionalArguments[0] as Function;
          return Future.value(
            callback({
              'id': userId,
              'username': 'testuser',
              'email': 'old@email.com',
              'bio': 'Test bio',
              'photo': 'https://example.com/photo.jpg',
              'total_posts': 5,
              'total_collections': 3,
              'total_followers': 100,
              'total_followings': 50,
            }),
          );
        });

        // Act
        final result = await repository.login(userEmail, 'password123');

        // Assert
        expect(result is Success<UserProfile>, true);
        final successResult = result as Success<UserProfile>;
        expect(successResult.data.id, userId);
        expect(successResult.data.username, 'testuser');
        expect(successResult.data.email, userEmail); // Should be updated
        expect(successResult.data.bio, 'Test bio');
      });

      test('should update email from auth response', () async {
        // Arrange
        final mockAuthResponse = MockAuthResponse();
        final mockUser = MockUser();
        const userId = 'user123';
        const authEmail = 'auth@email.com';

        when(mockUser.id).thenReturn(userId);
        when(mockUser.email).thenReturn(authEmail);
        when(mockAuthResponse.user).thenReturn(mockUser);

        when(
          mockGoTrueClient.signInWithPassword(
            email: authEmail,
            password: 'password123',
          ),
        ).thenAnswer((_) async => mockAuthResponse);

        when(
          (mockSupabaseClient as dynamic).rpc(any, params: anyNamed('params')),
        ).thenAnswer((_) => mockFilterBuilderList);

        when(
          mockFilterBuilderList.then(any, onError: anyNamed('onError')),
        ).thenAnswer((invocation) {
          final callback = invocation.positionalArguments[0] as Function;
          return Future.value(
            callback([
              {'deleted_at': null},
            ]),
          );
        });

        when(
          mockSupabaseClient.from(any),
        ).thenAnswer((_) => mockSupabaseBuilder);

        when(
          mockSupabaseBuilder.select(any),
        ).thenAnswer((_) => mockFilterBuilderList);

        when(
          mockFilterBuilderList.eq(any, any),
        ).thenAnswer((_) => mockFilterBuilderList);

        // Transisi dari List ke Single juga pake thenAnswer
        when(
          mockFilterBuilderList.maybeSingle(),
        ).thenAnswer((_) => mockFilterBuilderSingle);

        // Bagian ini tetep pake thenAnswer yang manggil callback (buat handle await)
        when(
          mockFilterBuilderSingle.then(any, onError: anyNamed('onError')),
        ).thenAnswer((invocation) {
          final callback = invocation.positionalArguments[0] as Function;
          return Future.value(
            callback({
              'id': userId,
              'username': 'testuser',
              'email': 'old@email.com',
              'bio': null,
              'photo': null,
              'total_posts': 0,
              'total_collections': 0,
              'total_followers': 0,
              'total_followings': 0,
            }),
          );
        });

        // Act
        final result = await repository.login(authEmail, 'password123');

        // Assert
        expect(result is Success<UserProfile>, true);
        final successResult = result as Success<UserProfile>;
        expect(successResult.data.email, authEmail);
      });
    });

    // login() Tests - ERROR CASES

    group('login() - Error Cases', () {
      test(
        'should return Error("USER_NOT_FOUND") when auth user is null',
        () async {
          // Arrange
          final mockAuthResponse = MockAuthResponse();
          when(mockAuthResponse.user).thenReturn(null);

          when(
            mockGoTrueClient.signInWithPassword(
              email: 'test@email.com',
              password: 'password123',
            ),
          ).thenAnswer((_) async => mockAuthResponse);

          // Act
          final result = await repository.login(
            'test@email.com',
            'password123',
          );

          // Assert
          expect(result is Error, true);
          expect((result as Error).error, 'USER_NOT_FOUND');
        },
      );

      test(
        'should return Error("PROFILE_NOT_FOUND") when RPC returns empty list',
        () async {
          // Arrange
          final mockAuthResponse = MockAuthResponse();
          final mockUser = MockUser();
          const userId = 'user123';

          when(mockUser.id).thenReturn(userId);
          when(mockAuthResponse.user).thenReturn(mockUser);

          when(
            mockGoTrueClient.signInWithPassword(
              email: 'test@email.com',
              password: 'password123',
            ),
          ).thenAnswer((_) async => mockAuthResponse);

          when(
            (mockSupabaseClient as dynamic).rpc(
              'get_account_deleted_status',
              params: {'target_user_id': userId},
            ),
          ).thenAnswer((_) => mockFilterBuilderList); // Empty list

          when(
            mockFilterBuilderList.then(any, onError: anyNamed('onError')),
          ).thenAnswer((invocation) {
            final callback = invocation.positionalArguments[0] as Function;
            return Future.value(callback(<Map<String, dynamic>>[]));
          });

          // (_) async => [])

          // Act
          final result = await repository.login(
            'test@email.com',
            'password123',
          );

          // Assert
          expect(result is Error, true);
          expect((result as Error).error, 'PROFILE_NOT_FOUND');
        },
      );

      test(
        'should return Error("ACCOUNT_DELETED") when account is deleted',
        () async {
          // Arrange
          final mockAuthResponse = MockAuthResponse();
          final mockUser = MockUser();
          const userId = 'user123';

          when(mockUser.id).thenReturn(userId);
          when(mockAuthResponse.user).thenReturn(mockUser);

          when(
            mockGoTrueClient.signInWithPassword(
              email: 'test@email.com',
              password: 'password123',
            ),
          ).thenAnswer((_) async => mockAuthResponse);

          when(
            mockSupabaseClient.rpc(
              'get_account_deleted_status',
              params: {'target_user_id': userId},
            ),
          ).thenAnswer((_) => mockFilterBuilderList);

          when(
            mockFilterBuilderList.then(any, onError: anyNamed('onError')),
          ).thenAnswer((invocation) {
            final callback = invocation.positionalArguments[0] as Function;
            return Future.value(
              callback([
                {'deleted_at': '2024-01-01T00:00:00Z'},
              ]),
            );
          });
          //   {'deleted_at': '2024-01-01T00:00:00Z'},

          // Act
          final result = await repository.login(
            'test@email.com',
            'password123',
          );

          // Assert
          expect(result is Error, true);
          expect((result as Error).error, 'ACCOUNT_DELETED');
        },
      );

      test(
        'should return Error("PROFILE_NOT_FOUND") when profile query returns null',
        () async {
          // Arrange
          final mockAuthResponse = MockAuthResponse();
          final mockUser = MockUser();
          const userId = 'user123';

          when(mockUser.id).thenReturn(userId);
          when(mockAuthResponse.user).thenReturn(mockUser);

          when(
            mockGoTrueClient.signInWithPassword(
              email: 'test@email.com',
              password: 'password123',
            ),
          ).thenAnswer((_) async => mockAuthResponse);

          when(
            mockSupabaseClient.rpc(
              'get_account_deleted_status',
              params: {'target_user_id': userId},
            ),
          ).thenAnswer((_) => mockFilterBuilderList);

          when(
            mockFilterBuilderList.then(any, onError: anyNamed('onError')),
          ).thenAnswer((invocation) {
            final callback = invocation.positionalArguments[0] as Function;
            return Future.value(
              callback([
                {'deleted_at': null},
              ]),
            );
          });

          //  {'deleted_at': null},

          when(
            mockSupabaseClient.from('profile_view'),
          ).thenAnswer((_) => mockSupabaseBuilder);

          when(
            mockSupabaseBuilder.select(),
          ).thenAnswer((_) => mockFilterBuilderList);

          when(
            mockFilterBuilderList.eq('id', userId),
          ).thenAnswer((_) => mockFilterBuilderList);

          when(
            mockFilterBuilderList.maybeSingle(),
          ).thenAnswer((_) => mockFilterBuilderSingle);

          when(
            mockFilterBuilderSingle.then(any, onError: anyNamed('onError')),
          ).thenAnswer((invocation) {
            final callback = invocation.positionalArguments[0] as Function;
            return Future.value(callback(null));
          });

          // when(
          //   mockPostgREST.maybeSingle(),
          // ).thenAnswer((_) async => null); // Profile not found

          // Act
          final result = await repository.login(
            'test@email.com',
            'password123',
          );

          // Assert
          expect(result is Error, true);
          expect((result as Error).error, 'PROFILE_NOT_FOUND');
        },
      );

      test(
        'should return Error when Supabase login throws exception',
        () async {
          // Arrange
          when(
            mockGoTrueClient.signInWithPassword(
              email: 'test@email.com',
              password: 'wrongpassword',
            ),
          ).thenThrow(Exception('Invalid login credentials'));

          // Act
          final result = await repository.login(
            'test@email.com',
            'wrongpassword',
          );

          // Assert
          expect(result is Error, true);
        },
      );

      test('should return Error when RPC throws exception', () async {
        // Arrange
        final mockAuthResponse = MockAuthResponse();
        final mockUser = MockUser();
        const userId = 'user123';

        when(mockUser.id).thenReturn(userId);
        when(mockAuthResponse.user).thenReturn(mockUser);

        when(
          mockGoTrueClient.signInWithPassword(
            email: 'test@email.com',
            password: 'password123',
          ),
        ).thenAnswer((_) async => mockAuthResponse);

        when(
          mockSupabaseClient.rpc(
            'get_account_deleted_status',
            params: {'target_user_id': userId},
          ),
        ).thenThrow(Exception('RPC error'));

        // Act
        final result = await repository.login('test@email.com', 'password123');

        // Assert
        expect(result is Error, true);
      });

      test('should return Error when profile query throws exception', () async {
        // Arrange
        final mockAuthResponse = MockAuthResponse();
        final mockUser = MockUser();
        const userId = 'user123';

        when(mockUser.id).thenReturn(userId);
        when(mockAuthResponse.user).thenReturn(mockUser);

        when(
          mockGoTrueClient.signInWithPassword(
            email: 'test@email.com',
            password: 'password123',
          ),
        ).thenAnswer((_) async => mockAuthResponse);

        when(
          mockSupabaseClient.rpc(
            'get_account_deleted_status',
            params: {'target_user_id': userId},
          ),
        ).thenAnswer((_) => mockFilterBuilderList);

        when(
          mockFilterBuilderList.then(any, onError: anyNamed('onError')),
        ).thenAnswer((invocation) {
          final callback = invocation.positionalArguments[0] as Function;
          return Future.value(
            callback([
              {'deleted_at': null},
            ]),
          );
        });

        when(
          mockSupabaseClient.from('profile_view'),
        ).thenAnswer((_) => mockSupabaseBuilder);

        when(
          mockSupabaseBuilder.select(),
        ).thenAnswer((_) => mockFilterBuilderList);

        when(
          mockFilterBuilderList.eq('id', userId),
        ).thenAnswer((_) => mockFilterBuilderList);

        when(
          mockFilterBuilderList.maybeSingle(),
        ).thenAnswer((_) => mockFilterBuilderSingle);

        when(
          mockFilterBuilderSingle.then(any, onError: anyNamed('onError')),
        ).thenThrow(Exception('Query error'));

        // Act
        final result = await repository.login('test@email.com', 'password123');

        // Assert
        expect(result is Error, true);
      });
    });

    // logout() Tests

    group('logout()', () {
      test('should call auth.signOut()', () async {
        // Arrange
        when(mockGoTrueClient.signOut()).thenAnswer((_) async => {});

        // Act
        await repository.logout();

        // Assert
        verify(mockGoTrueClient.signOut()).called(1);
      });

      test('should throw error when signOut fails', () async {
        // Arrange
        when(mockGoTrueClient.signOut()).thenThrow(Exception('Logout failed'));

        // Act & Assert
        expect(() => repository.logout(), throwsException);
      });
    });

    // register() Tests - Success

    group('register() - success', () {
      test(
        'should return Success(true) when registration is successful and email not registered',
        () async {
          // Arrange
          final mockAuthResponse = MockAuthResponse();
          final mockUser = MockUser();

          when(mockUser.identities).thenReturn([
            MockUserIdentity(),
            // Pastikan MockUserIdentity sudah ada di file .mocks.dart lu
          ]);

          // when(mockUser.identities).thenReturn([]); // Not empty = first time
          when(mockAuthResponse.user).thenReturn(mockUser);

          when(
            mockGoTrueClient.signUp(
              email: 'newuser@email.com',
              password: 'password123',
              data: {'username': 'newuser'},
              emailRedirectTo: 'com.korehitone.imagix://email-confirm',
            ),
          ).thenAnswer((_) async => mockAuthResponse);

          // Act
          final result = await repository.register(
            'newuser@email.com',
            'password123',
            'newuser',
          );

          // Assert
          expect(result is Success<bool>, true);
          expect((result as Success).data, true);
          verify(
            mockGoTrueClient.signUp(
              email: 'newuser@email.com',
              password: 'password123',
              data: {'username': 'newuser'},
              emailRedirectTo: 'com.korehitone.imagix://email-confirm',
            ),
          ).called(1);
        },
      );
    });

    // register() Tests - ERROR CASES

    group('register() - Error Cases', () {
      test(
        'should return Error("EMAIL_ALREADY_REGISTERED") when email exists',
        () async {
          // Arrange
          final mockAuthResponse = MockAuthResponse();
          final mockUser = MockUser();

          when(mockUser.identities).thenReturn([]);
          when(mockAuthResponse.user).thenReturn(mockUser);

          when(
            mockGoTrueClient.signUp(
              email: 'existing@email.com',
              password: 'password123',
              data: {'username': 'existinguser'},
              emailRedirectTo: 'com.korehitone.imagix://email-confirm',
            ),
          ).thenAnswer((_) async => mockAuthResponse);

          // Act
          final result = await repository.register(
            'existing@email.com',
            'password123',
            'existinguser',
          );

          // Assert
          expect(result is Error, true);
          expect((result as Error).error, 'EMAIL_ALREADY_REGISTERED');
        },
      );

      test(
        'should return Error("FAILED_CREATE_ACCOUNT") when user is null',
        () async {
          // Arrange
          final mockAuthResponse = MockAuthResponse();
          when(mockAuthResponse.user).thenReturn(null);

          when(
            mockGoTrueClient.signUp(
              email: 'test@email.com',
              password: 'password123',
              data: {'username': 'testuser'},
              emailRedirectTo: 'com.korehitone.imagix://email-confirm',
            ),
          ).thenAnswer((_) async => mockAuthResponse);

          // Act
          final result = await repository.register(
            'test@email.com',
            'password123',
            'testuser',
          );

          // Assert
          expect(result is Error, true);
          expect((result as Error).error, 'FAILED_CREATE_ACCOUNT');
        },
      );

      test(
        'should return Error when Supabase signup throws exception',
        () async {
          // Arrange
          when(
            mockGoTrueClient.signUp(
              email: 'test@email.com',
              password: 'password123',
              data: {'username': 'testuser'},
              emailRedirectTo: 'com.korehitone.imagix://email-confirm',
            ),
          ).thenThrow(Exception('Signup error'));

          // Act
          final result = await repository.register(
            'test@email.com',
            'password123',
            'testuser',
          );

          // Assert
          expect(result is Error, true);
        },
      );
    });

    // deleteAccount() Tests

    group('deleteAccount()', () {
      test(
        'should call RPC soft_delete_my_account and return Success',
        () async {
          // Arrange
          when(
            mockSupabaseClient.rpc('soft_delete_my_account'),
          ).thenAnswer((_) => mockFilterBuilderList);

          when(
            mockFilterBuilderList.then(any, onError: anyNamed('onError')),
          ).thenAnswer((invocation) {
            final callback = invocation.positionalArguments[0] as Function;
            return Future.value(callback(<Map<String, dynamic>>[{}]));
          });

          // Act
          final result = await repository.deleteAccount('user123');

          // Assert
          expect(result is Success<bool>, true);
          expect((result as Success).data, true);
          verify(mockSupabaseClient.rpc('soft_delete_my_account')).called(1);
        },
      );

      test('should return Error when RPC throws exception', () async {
        // Arrange
        when(
          mockSupabaseClient.rpc('soft_delete_my_account'),
        ).thenThrow(Exception('Delete failed'));

        // Act
        final result = await repository.deleteAccount('user123');

        // Assert
        expect(result is Error, true);
      });
    });

    // restoreAccount() Tests

    group('restoreAccount()', () {
      test('should call RPC restore_my_account and return Success', () async {
        // Arrange
        when(
          mockSupabaseClient.rpc('restore_my_account'),
        ).thenAnswer((_) => mockFilterBuilderList);

        when(
          mockFilterBuilderList.then(any, onError: anyNamed('onError')),
        ).thenAnswer((invocation) {
          final callback = invocation.positionalArguments[0] as Function;
          return Future.value(callback(<Map<String, dynamic>>[{}]));
        });

        // Act
        final result = await repository.restoreAccount('user123');

        // Assert
        expect(result is Success<bool>, true);
        expect((result as Success).data, true);
        verify(mockSupabaseClient.rpc('restore_my_account')).called(1);
      });

      test('should return Error when RPC throws exception', () async {
        // Arrange
        when(
          mockSupabaseClient.rpc('restore_my_account'),
        ).thenThrow(Exception('Restore failed'));

        // Act
        final result = await repository.restoreAccount('user123');

        // Assert
        expect(result is Error, true);
      });
    });

    // ========================================================================
    // resendVerificationEmail() Tests
    // ========================================================================

    group('resendVerificationEmail()', () {
      test(
        'should call auth.resend with correct parameters and return Success',
        () async {
          // Arrange
          final mockResendResponse = MockResendResponse();
          when(
            mockGoTrueClient.resend(
              type: OtpType.signup,
              email: 'test@email.com',
              emailRedirectTo: 'com.korehitone.imagix://email-confirm',
            ),
          ).thenAnswer((_) async => mockResendResponse);

          // Act
          final result = await repository.resendVerificationEmail(
            'test@email.com',
          );

          // Assert
          expect(result is Success<bool>, true);
          expect((result as Success).data, true);
          verify(
            mockGoTrueClient.resend(
              type: OtpType.signup,
              email: 'test@email.com',
              emailRedirectTo: 'com.korehitone.imagix://email-confirm',
            ),
          ).called(1);
        },
      );

      test(
        'should return Error when Supabase resend throws exception',
        () async {
          // Arrange
          when(
            mockGoTrueClient.resend(
              type: OtpType.signup,
              email: 'test@email.com',
              emailRedirectTo: 'com.korehitone.imagix://email-confirm',
            ),
          ).thenThrow(Exception('Resend failed'));

          // Act
          final result = await repository.resendVerificationEmail(
            'test@email.com',
          );

          // Assert
          expect(result is Error, true);
        },
      );
    });
  });
}
