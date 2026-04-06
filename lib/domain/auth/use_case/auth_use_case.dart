import 'package:imagix/domain/auth/use_case/delete_account_use_case.dart';
import 'package:imagix/domain/auth/use_case/get_current_user_use_case.dart';
import 'package:imagix/domain/auth/use_case/get_local_user_use_case.dart';
import 'package:imagix/domain/auth/use_case/login_use_case.dart';
import 'package:imagix/domain/auth/use_case/logout_use_case.dart';
import 'package:imagix/domain/auth/use_case/register_use_case.dart';
import 'package:imagix/domain/auth/use_case/resend_verification_email_use_case.dart';
import 'package:imagix/domain/auth/use_case/restore_account_use_case.dart';
import 'package:imagix/domain/auth/use_case/save_local_user_use_case.dart';

class AuthUseCase {
  final LoginUseCase login;
  final RegisterUseCase register;
  final GetCurrentUserUseCase getCurrentUser;
  final SaveLocalUserUseCase saveLocalUser;
  final LogoutUseCase logout;
  final DeleteAccountUseCase deleteAccount;
  final RestoreAccountUseCase restoreAccount;
  final GetLocalUserUseCase getLocalUser;
  final ResendVerificationEmailUseCase resendVerificationEmail;

  const AuthUseCase({
    required this.login,
    required this.register,
    required this.getCurrentUser,
    required this.saveLocalUser,
    required this.logout,
    required this.deleteAccount,
    required this.restoreAccount,
    required this.getLocalUser,
    required this.resendVerificationEmail,
  });
}
