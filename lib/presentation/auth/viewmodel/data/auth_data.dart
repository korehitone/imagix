import 'package:supabase_flutter/supabase_flutter.dart';

class AuthData {
  final User? user;
  final bool isSuccess;
  final bool isSend;
  final bool isDeletedAccount;

  const AuthData({
    this.user,
    this.isSuccess = false,
    this.isSend = false,
    this.isDeletedAccount = false,
  });

  AuthData copyWith({
    User? user,
    bool clearUser = false,
    bool? isSuccess,
    bool? isSend,
    bool? isDeletedAccount,
  }) => AuthData(
    user: clearUser ? null : (user ?? this.user),
    isSuccess: isSuccess ?? this.isSuccess,
    isSend: isSend ?? this.isSend,
    isDeletedAccount: isDeletedAccount ?? this.isDeletedAccount,
  );
}
