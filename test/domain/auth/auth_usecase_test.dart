import 'package:flutter_test/flutter_test.dart';
import 'package:imagix/core/network/result_state.dart';
import 'package:imagix/domain/auth/repository/auth_repository.dart';
import 'package:imagix/domain/auth/use_case/delete_account_use_case.dart';
import 'package:imagix/domain/auth/use_case/get_current_user_use_case.dart';
import 'package:imagix/domain/auth/use_case/get_local_user_use_case.dart';
import 'package:imagix/domain/auth/use_case/login_use_case.dart';
import 'package:imagix/domain/auth/use_case/logout_use_case.dart';
import 'package:imagix/domain/auth/use_case/register_use_case.dart';
import 'package:imagix/domain/auth/use_case/resend_verification_email_use_case.dart';
import 'package:imagix/domain/auth/use_case/restore_account_use_case.dart';
import 'package:imagix/domain/auth/use_case/save_local_user_use_case.dart';
import 'package:imagix/domain/common/model/user_profile.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'auth_usecase_test.mocks.dart';

@GenerateNiceMocks([MockSpec<AuthRepository>()])
void main() {
  provideDummy<ResultState<UserProfile>>(const Error("DUMMY_ERROR"));
  provideDummy<ResultState<bool>>(const Success(true));
  provideDummy<ResultState<String>>(const Success("DUMMY_STRING"));

  late MockAuthRepository mockRepo;

  // Use Cases
  late LoginUseCase loginUC;
  late RegisterUseCase registerUC;
  late DeleteAccountUseCase deleteAccountUC;
  late LogoutUseCase logoutUC;
  late GetCurrentUserUseCase getCurrentUserUC;
  late GetLocalUserUseCase getLocalUserUC;
  late ResendVerificationEmailUseCase resendEmailUC;
  late RestoreAccountUseCase restoreAccountUC;
  late SaveLocalUserUseCase saveLocalUC;

  setUp(() {
    mockRepo = MockAuthRepository();
    loginUC = LoginUseCase(mockRepo);
    registerUC = RegisterUseCase(mockRepo);
    deleteAccountUC = DeleteAccountUseCase(mockRepo);
    logoutUC = LogoutUseCase(mockRepo);
    getCurrentUserUC = GetCurrentUserUseCase(mockRepo);
    getLocalUserUC = GetLocalUserUseCase(mockRepo);
    resendEmailUC = ResendVerificationEmailUseCase(mockRepo);
    restoreAccountUC = RestoreAccountUseCase(mockRepo);
    saveLocalUC = SaveLocalUserUseCase(mockRepo);
  });

  // Mock Data
  final tUser = User(
    id: 'uid-123',
    appMetadata: {},
    userMetadata: {},
    aud: '',
    createdAt: '',
  );

  final tUserProfile = UserProfile(
    id: 'uid-123',
    username: 'kak_dev',
    email: 'kak@imagix.com',
    bio: 'Flutter Developer',
    photo: null,
  );

  group('LoginUseCase', () {
    const tEmail = 'kak@imagix.com';
    const tPass = 'password123';

    // 1. Test Email Kosong
    test('should return Error when email is empty', () async {
      final result = await loginUC.invoke('  ', tPass);
      expect(result, isA<Error>());
      // DISESUAIKAN: Karena di Use Case Kakak return "Email is empty."
      expect((result as Error).error, "Email is empty.");
      verifyNever(mockRepo.login(any, any));
    });

    // 2. Test Format Email Tidak Valid
    test('should return Error when email format is not valid', () async {
      final result = await loginUC.invoke('this-not-email', tPass);
      expect(result, isA<Error>());
      expect((result as Error).error, "Email is not valid.");
      verifyNever(mockRepo.login(any, any));
    });

    // 3. Test Password Kosong
    test('should return Error when password is empty', () async {
      final result = await loginUC.invoke(tEmail, '  ');
      expect(result, isA<Error>());
      expect((result as Error).error, "Password is empty.");
      verifyNever(mockRepo.login(any, any));
    });

    // 4. Test User Not Found (Mapping Error dari Repo)
    test(
      'should return specific message when user or profile is not found',
      () async {
        when(
          mockRepo.login(any, any),
        ).thenAnswer((_) async => const Error("USER_NOT_FOUND"));

        final result = await loginUC.invoke(tEmail, tPass);

        expect(result, isA<Error>());
        expect((result as Error).error, "Invalid email or password.");
      },
    );

    // 5. Test Default Error (Logic switch underscore _)
    test('should return raw error key for unhandled error keys', () async {
      const unknownError = "SOMETHING_WENT_WRONG_ON_SERVER";
      when(
        mockRepo.login(any, any),
      ).thenAnswer((_) async => const Error(unknownError));

      final result = await loginUC.invoke(tEmail, tPass);

      expect(result, isA<Error>());
      expect((result as Error).error, unknownError);
    });

    // 6. Test Success Flow
    test('should save user locally and return LOGGED_IN on Success', () async {
      when(
        mockRepo.login(any, any),
      ).thenAnswer((_) async => Success(tUserProfile));

      final result = await loginUC.invoke(tEmail, tPass);

      expect(result, isA<Success<String>>());
      expect((result as Success).data, "LOGGED_IN");
      verify(mockRepo.saveLocalUser(tUserProfile)).called(1);
    });

    // 7. Test Account Deleted Flow
    test(
      'should return Success(ACCOUNT_DELETED) when repo returns ACCOUNT_DELETED error',
      () async {
        when(
          mockRepo.login(any, any),
        ).thenAnswer((_) async => const Error("ACCOUNT_DELETED"));

        final result = await loginUC.invoke(tEmail, tPass);

        expect(result, isA<Success<String>>());
        expect((result as Success).data, "ACCOUNT_DELETED");

        verifyNever(mockRepo.saveLocalUser(any));
      },
    );
  });

  group('RegisterUseCase', () {
    const tEmail = 'kak@imagix.com';
    const tPass = '123456';
    const tUser = 'kak_dev';

    test(
      'should return Error and NEVER call repo when email is empty',
      () async {
        final result = await registerUC.invoke('   ', tPass, tUser);

        expect(result, isA<Error>());
        expect((result as Error).error, "Email is empty.");
        verifyNever(mockRepo.register(any, any, any));
      },
    );

    test(
      'should return Error and NEVER call repo when email format invalid',
      () async {
        final result = await registerUC.invoke('not.email', tPass, tUser);

        expect(result, isA<Error>());
        expect((result as Error).error, "Email is not valid.");
        verifyNever(mockRepo.register(any, any, any));
      },
    );

    test(
      'should return Error and NEVER call repo when username is empty',
      () async {
        final result = await registerUC.invoke(tEmail, tPass, '');

        expect(result, isA<Error>());
        expect((result as Error).error, "Username is empty.");
        verifyNever(mockRepo.register(any, any, any));
      },
    );

    test(
      'should return Error and NEVER call repo when username format invalid',
      () async {
        final result = await registerUC.invoke(tEmail, tPass, 'user!@#');

        expect(result, isA<Error>());
        expect(
          (result as Error).error,
          "Username can only contain letters, numbers, underscore (_) and dot (.).",
        );
        verifyNever(mockRepo.register(any, any, any));
      },
    );

    test(
      'should return Error and NEVER call repo when password is empty',
      () async {
        final result = await registerUC.invoke(tEmail, '  ', tUser);

        expect(result, isA<Error>());
        expect((result as Error).error, "Password is empty.");
        verifyNever(mockRepo.register(any, any, any));
      },
    );

    test(
      'should return Error and NEVER call repo when password < 6 chars',
      () async {
        final result = await registerUC.invoke(tEmail, '12345', tUser);

        expect(result, isA<Error>());
        expect((result as Error).error, "Minimum password is 6 characters");
        verifyNever(mockRepo.register(any, any, any));
      },
    );

    test('should map EMAIL_ALREADY_REGISTERED from repo correctly', () async {
      when(
        mockRepo.register(any, any, any),
      ).thenAnswer((_) async => const Error("EMAIL_ALREADY_REGISTERED"));

      final result = await registerUC.invoke(tEmail, tPass, tUser);

      expect(result, isA<Error>());
      expect((result as Error).error, "Email already registered.");
    });

    test('should map FAILED_CREATE_ACCOUNT from repo correctly', () async {
      when(
        mockRepo.register(any, any, any),
      ).thenAnswer((_) async => const Error("FAILED_CREATE_ACCOUNT"));

      final result = await registerUC.invoke(tEmail, tPass, tUser);

      expect(result, isA<Error>());
      expect(
        (result as Error).error,
        "Could not upload account. Please try again later.",
      );
    });

    test('should return raw error key for unhandled server errors', () async {
      const tUnknownError = "SERVER_BOOM_500";
      when(
        mockRepo.register(any, any, any),
      ).thenAnswer((_) async => const Error(tUnknownError));

      final result = await registerUC.invoke(tEmail, tPass, tUser);

      expect(result, isA<Error>());
      expect((result as Error).error, tUnknownError);
    });

    test(
      'should return Success(true) when all valid and repo succeeds',
      () async {
        when(
          mockRepo.register(any, any, any),
        ).thenAnswer((_) async => const Success(true));

        final result = await registerUC.invoke(tEmail, tPass, tUser);

        expect(result, isA<Success<bool>>());
        expect((result as Success).data, true);
        verify(mockRepo.register(tEmail, tPass, tUser)).called(1);
      },
    );
  });

  group('DeleteAccountUseCase', () {
    test(
      'should return Error and NEVER call deleteAccount when user is null',
      () async {
        // Stubbing: Simulasi session habis
        when(mockRepo.getCurrentUser()).thenReturn(null);

        final result = await deleteAccountUC.invoke();

        expect(result, isA<Error>());
        expect(
          (result as Error).error,
          "Session expired. Please sign in again.",
        );

        // Mastiin repo nggak ditembak sama sekali
        verifyNever(mockRepo.deleteAccount(any));
      },
    );

    // --- 2. SUCCESS FLOW (Sudah ada, tapi kita pastikan side-effectnya) ---
    test('should perform cleanup and logout on successful deletion', () async {
      when(mockRepo.getCurrentUser()).thenReturn(tUser);
      when(
        mockRepo.deleteAccount(tUser.id),
      ).thenAnswer((_) async => const Success(true));

      final result = await deleteAccountUC.invoke();

      expect(result, isA<Success<bool>>());
      // Verifikasi urutan side effect
      verify(mockRepo.clearLocalUser()).called(1);
      verify(mockRepo.logout()).called(1);
    });

    // --- 3. SPECIFIC ERROR (AUTH_ACTION_DENIED) ---
    test(
      'should return mapped error and NOT logout when action is denied',
      () async {
        when(mockRepo.getCurrentUser()).thenReturn(tUser);
        when(
          mockRepo.deleteAccount(tUser.id),
        ).thenAnswer((_) async => const Error("AUTH_ACTION_DENIED"));

        final result = await deleteAccountUC.invoke();

        expect(result, isA<Error>());
        expect(
          (result as Error).error,
          "Access denied. You don't have permission to delete this account.",
        );

        // PENTING: Mastiin kalau error, user GA KELOGOUT otomatis (data lokal aman)
        verifyNever(mockRepo.clearLocalUser());
        verifyNever(mockRepo.logout());
      },
    );

    // --- 4. GENERIC ERROR ---
    test('should return raw error key for other types of errors', () async {
      const otherError = "NETWORK_FAILURE";
      when(mockRepo.getCurrentUser()).thenReturn(tUser);
      when(
        mockRepo.deleteAccount(tUser.id),
      ).thenAnswer((_) async => const Error(otherError));

      final result = await deleteAccountUC.invoke();

      expect(result, isA<Error>());
      expect((result as Error).error, otherError);

      verifyNever(mockRepo.clearLocalUser());
      verifyNever(mockRepo.logout());
    });
  });

  group('ResendVerificationEmailUseCase', () {
    const tEmail = 'kak@imagix.com';

    test(
      'should return Error and NEVER call repo when email is empty',
      () async {
        final result = await resendEmailUC.invoke('   ');

        expect(result, isA<Error>());
        expect((result as Error).error, "Email is empty");
        verifyNever(mockRepo.resendVerificationEmail(any));
      },
    );

    test(
      'should return Error and NEVER call repo when email format invalid',
      () async {
        final result = await resendEmailUC.invoke('not-email');

        expect(result, isA<Error>());
        expect((result as Error).error, "Email is not valid.");
        verifyNever(mockRepo.resendVerificationEmail(any));
      },
    );

    test(
      'should return specific error for rate limit exceeded from repo',
      () async {
        when(
          mockRepo.resendVerificationEmail(any),
        ).thenAnswer((_) async => const Error("Email rate limit exceeded"));

        final result = await resendEmailUC.invoke(tEmail);

        expect(result, isA<Error>());
        expect(
          (result as Error).error,
          "Please wait a moment before requesting another verification email.",
        );
      },
    );
  });

  group('RestoreAccountUseCase', () {
    const tUserId = 'uid-123';

    // 1. Jalur Sukses (Sudah Kakak buat, ini versi rapihnya)
    test(
      'should call repo restore when session exists and return Success',
      () async {
        when(mockRepo.getCurrentUser()).thenReturn(tUser);
        when(
          mockRepo.restoreAccount(tUserId),
        ).thenAnswer((_) async => const Success(true));

        final result = await restoreAccountUC.execute();

        expect(result, isA<Success<bool>>());
        expect((result as Success).data, true);
        verify(mockRepo.restoreAccount(tUserId)).called(1);
      },
    );

    // 2. Jalur Gagal: Session Null (Early Return)
    test('should return Error when no active session is found', () async {
      // Setup repo balikin null
      when(mockRepo.getCurrentUser()).thenReturn(null);

      final result = await restoreAccountUC.execute();

      expect(result, isA<Error>());
      expect((result as Error).error, "No active session found.");
      verifyNever(mockRepo.restoreAccount(any));
    });

    // 3. Jalur Gagal: Mapping Error (AUTH_ACTION_DENIED)
    test('should map AUTH_ACTION_DENIED error correctly from repo', () async {
      when(mockRepo.getCurrentUser()).thenReturn(tUser);
      when(
        mockRepo.restoreAccount(tUserId),
      ).thenAnswer((_) async => const Error("AUTH_ACTION_DENIED"));

      final result = await restoreAccountUC.execute();

      expect(result, isA<Error>());
      // Sesuai logic ternary Kakak di Use Case
      expect(
        (result as Error).error,
        "Failed to restore account. Access denied.",
      );
    });

    // 4. Jalur Gagal: Error Lainnya (Passthrough)
    test('should return raw error key for unhandled error keys', () async {
      const unknownError = "DATABASE_OFFLINE";
      when(mockRepo.getCurrentUser()).thenReturn(tUser);
      when(
        mockRepo.restoreAccount(tUserId),
      ).thenAnswer((_) async => const Error(unknownError));

      final result = await restoreAccountUC.execute();

      expect(result, isA<Error>());
      expect((result as Error).error, unknownError);
    });
  });

  group('LogoutUseCase', () {
    test(
      'should clear local data and call repo logout in correct order',
      () async {
        await logoutUC.execute();

        verifyInOrder([mockRepo.clearLocalUser(), mockRepo.logout()]);

        verifyNoMoreInteractions(mockRepo);
      },
    );
  });

  group('GetCurrentUserUseCase', () {
    test('should return Supabase User from repository', () {
      // Arrange
      when(mockRepo.getCurrentUser()).thenReturn(tUser);

      // Act
      final result = getCurrentUserUC.invoke();

      // Assert
      expect(result, tUser);
      verify(mockRepo.getCurrentUser()).called(1);
    });

    test('should return null when no session is active', () {
      when(mockRepo.getCurrentUser()).thenReturn(null);

      final result = getCurrentUserUC.invoke();

      expect(result, isNull);
    });
  });

  group('GetLocalUserUseCase', () {
    test('should return UserProfile from local storage via repository', () {
      // Arrange
      when(mockRepo.getLocalUser()).thenReturn(tUserProfile);

      // Act
      final result = getLocalUserUC.invoke();

      // Assert
      expect(result, tUserProfile);
      verify(mockRepo.getLocalUser()).called(1);
    });

    test('should return null when no local user is saved', () {
      when(mockRepo.getLocalUser()).thenReturn(null);

      final result = getLocalUserUC.invoke();

      expect(result, isNull);
    });
  });

  group('SaveLocalUserUseCase', () {
    test('should call repository to save UserProfile', () async {
      // Act
      await saveLocalUC.invoke(tUserProfile);

      // Assert
      verify(mockRepo.saveLocalUser(tUserProfile)).called(1);
      verifyNoMoreInteractions(mockRepo);
    });
  });
}
