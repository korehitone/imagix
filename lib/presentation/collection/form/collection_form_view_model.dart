import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:imagix/core/network/result_state.dart';
import 'package:imagix/di/dependency_module.dart';
import 'package:imagix/domain/auth/use_case/auth_use_case.dart';
import 'package:imagix/domain/collection/use_case/collection_use_case.dart';

class CollectionFormViewModel extends AsyncNotifier<bool> {
  CollectionUseCase get _collectionUseCase =>
      ref.read(DependencyModule.collectionUseCaseProvider);

  AuthUseCase get _authUseCase =>
      ref.read(DependencyModule.authUseCaseProvider);

  @override
  FutureOr<bool> build() {
    return false;
  }

  Future<void> createCollection(String title) async {
    state = const AsyncLoading();

    final result = await _collectionUseCase.create.invoke(title);

    switch (result) {
      case Success():
        await _refreshProfileCollections();
        state = const AsyncData(true);
        break;

      case Error(error: final msg):
        state = AsyncError(msg, StackTrace.current);
        break;
    }
  }

  Future<void> updateCollection({
    required String collectionId,
    required String title,
  }) async {
    state = const AsyncLoading();

    final result = await _collectionUseCase.update.invoke(collectionId, title);

    switch (result) {
      case Success():
        await _refreshProfileCollections();
        state = const AsyncData(true);
        break;

      case Error(error: final msg):
        state = AsyncError(msg, StackTrace.current);
        break;
    }
  }

  Future<void> _refreshProfileCollections() async {
    final myId = _authUseCase.getCurrentUser.invoke()?.id;

    await ref
        .read(DependencyModule.profileViewModelProvider(null).notifier)
        .init(null);

    if (myId != null) {
      await ref
          .read(DependencyModule.profileViewModelProvider(myId).notifier)
          .init(myId);
    }

    await ref
        .read(DependencyModule.profileCollectionsViewModelProvider.notifier)
        .refresh();
  }
}
