import 'package:imagix/domain/auth/use_case/delete_account_use_case.dart';
import 'package:imagix/domain/auth/use_case/get_local_user_use_case.dart';
import 'package:imagix/domain/auth/use_case/login_use_case.dart';
import 'package:imagix/domain/auth/use_case/logout_use_case.dart';
import 'package:imagix/domain/auth/use_case/register_use_case.dart';
import 'package:imagix/domain/auth/use_case/restore_account_use_case.dart';

class AuthUseCase {
  final LoginUseCase login;
  final RegisterUseCase register;
  final LogoutUseCase logout;
  final DeleteAccountUseCase deleteAccount;
  final RestoreAccountUseCase restoreAccount;
  final GetLocalUserUseCase getLocalUser;

  const AuthUseCase({
    required this.login,
    required this.register,
    required this.logout,
    required this.deleteAccount,
    required this.restoreAccount,
    required this.getLocalUser,
  });
}
