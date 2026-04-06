import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:imagix/core/network/result_state.dart';
import 'package:imagix/di/dependency_module.dart';
import 'package:imagix/domain/auth/use_case/auth_use_case.dart';
import 'package:imagix/presentation/auth/viewmodel/data/auth_data.dart';

class AuthViewModel extends AsyncNotifier<AuthData> {
  AuthUseCase get _authUsecase =>
      ref.read(DependencyModule.authUseCaseProvider);

  @override
  FutureOr<AuthData> build() {
    final user = _authUsecase.getCurrentUser.invoke();
    return AuthData(user: user);
  }

  Future<void> register(String email, String password, String username) async {
    final current =
        state.value ?? AuthData(user: _authUsecase.getCurrentUser.invoke());

    state = const AsyncLoading();

    final result = await _authUsecase.register.invoke(
      email,
      password,
      username,
    );

    switch (result) {
      case Success():
        state = AsyncData(current.copyWith(isSuccess: true));
        break;

      case Error(error: final msg):
        state = AsyncError(msg, StackTrace.current);
        break;
    }
  }

  Future<void> login(String email, String password) async {
    state = const AsyncLoading();

    final result = await _authUsecase.login.invoke(email, password);

    switch (result) {
      case Success(data: final status):
        if (status == "ACCOUNT_DELETED") {
          // session auth masih ada, dipakai buat restore
          final currentUser = _authUsecase.getCurrentUser.invoke();

          state = AsyncData(
            AuthData(
              user: currentUser,
              isSuccess: false,
              isSend: false,
              isDeletedAccount: true,
            ),
          );
          return;
        }

        final freshUser = _authUsecase.getCurrentUser.invoke();

        state = AsyncData(
          AuthData(
            user: freshUser,
            isSuccess: true,
            isSend: false,
            isDeletedAccount: false,
          ),
        );
        break;

      case Error(error: final msg):
        state = AsyncError(msg, StackTrace.current);
        break;
    }
  }

  Future<bool> logout() async {
    try {
      state = const AsyncLoading();
      await _authUsecase.logout.execute();
      state = const AsyncData(AuthData(user: null, isSuccess: false));
      return true;
    } catch (e) {
      state = AsyncError(e, StackTrace.current);
      return false;
    }
  }

  void resetDeletedAccount() {
    final current = state.value;
    if (current == null) return;

    state = AsyncData(current.copyWith(isDeletedAccount: false));
  }

  Future<bool> deleteAccount() async {
    state = const AsyncLoading();

    final result = await _authUsecase.deleteAccount.invoke();

    switch (result) {
      case Success():
        state = const AsyncData(AuthData(user: null, isSuccess: false));
        return true;

      case Error(error: final msg):
        state = AsyncError(msg, StackTrace.current);
        return false;
    }
  }

  Future<bool> restoreAccount() async {
    state = const AsyncLoading();

    final result = await _authUsecase.restoreAccount.execute();

    switch (result) {
      case Success():
        await _authUsecase.logout.execute();
        state = const AsyncData(AuthData(user: null, isSuccess: false));
        return true;

      case Error(error: final msg):
        state = AsyncError(msg, StackTrace.current);
        return false;
    }
  }

  Future<bool> resendVerificationEmail(String email) async {
    final currentUser = state.value?.user;

    state = const AsyncLoading();

    final result = await _authUsecase.resendVerificationEmail.invoke(email);

    switch (result) {
      case Success():
        state = AsyncData(AuthData(user: currentUser, isSend: true));
        return true;

      case Error(error: final msg):
        state = AsyncError(msg, StackTrace.current);
        return false;
    }
  }

  void resetSuccess() {
    final current = state.value;
    if (current == null) return;
    state = AsyncData(current.copyWith(isSuccess: false));
  }

  void resetSend() {
    final current = state.value;
    if (current == null) return;
    state = AsyncData(current.copyWith(isSend: false));
  }
}

// import 'dart:async';
//
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:imagix/core/network/result_state.dart';
// import 'package:imagix/di/dependency_module.dart';
// import 'package:imagix/domain/auth/use_case/auth_use_case.dart';
// import 'package:imagix/presentation/auth/viewmodel/data/auth_data.dart';
//
// class AuthViewModel extends AsyncNotifier<AuthData> {
//   AuthUseCase get _authUsecase =>
//       ref.read(DependencyModule.authUseCaseProvider);
//   @override
//   FutureOr<AuthData> build() {
//     final user = _authUsecase.getCurrentUser.invoke();
//     return AuthData(user: user);
//   }
//
//   Future<void> register(String email, String password, String username) async {
//     state = await AsyncValue.guard(() async {
//       final result = await _authUsecase.register.invoke(
//         email,
//         password,
//         username,
//       );
//       return state.requireValue.copyWith(isSuccess: result.getOrThrow());
//     });
//   }
//
//   Future<void> login(String email, String password) async {
//     state = await AsyncValue.guard(() async {
//       final result = await _authUsecase.login.invoke(email, password);
//       return state.requireValue.copyWith(isSuccess: result.getOrThrow());
//     });
//   }
// }
