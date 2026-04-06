import 'dart:async';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:imagix/core/network/result_state.dart';
import 'package:imagix/di/dependency_module.dart';
import 'package:imagix/domain/auth/use_case/auth_use_case.dart';
import 'package:imagix/domain/post/model/post.dart';
import 'package:imagix/domain/post/model/post_request.dart';
import 'package:imagix/domain/post/use_case/post_use_case.dart';

class UploadViewModel extends AsyncNotifier<Post?> {
  PostUseCase get _postUseCase =>
      ref.read(DependencyModule.postUseCaseProvider);

  AuthUseCase get _authUseCase =>
      ref.read(DependencyModule.authUseCaseProvider);

  @override
  FutureOr<Post?> build() {
    return null;
  }

  Future<void> uploadPost({
    required String title,
    required String description,
    required File? imageFile,
  }) async {
    state = const AsyncLoading();

    final request = PostRequest(
      title: title,
      description: description,
      imageFile: imageFile,
    );

    final result = await _postUseCase.create.invoke(request);

    state = await switch (result) {
      Success(data: final post) => () async {
        await _refreshRelatedStates();
        return AsyncData(post);
      }(),
      Error(error: final msg) => Future.value(
        AsyncError(msg, StackTrace.current),
      ),
    };
  }

  Future<void> updatePost({
    required String postId,
    required String title,
    required String description,
  }) async {
    state = const AsyncLoading();

    final request = PostRequest(title: title, description: description);

    final result = await _postUseCase.update.invoke(postId, request);

    state = await switch (result) {
      Success() => () async {
        await _refreshRelatedStates(postId: postId);
        return const AsyncData(null);
      }(),
      Error(error: final msg) => Future.value(
        AsyncError(msg, StackTrace.current),
      ),
    };
  }

  Future<void> _refreshRelatedStates({String? postId}) async {
    final myId = _authUseCase.getCurrentUser.invoke()?.id;

    await ref.read(DependencyModule.homeViewModelProvider.notifier).refresh();

    await ref
        .read(DependencyModule.profileViewModelProvider(null).notifier)
        .init(null);

    if (myId != null) {
      await ref
          .read(DependencyModule.profileViewModelProvider(myId).notifier)
          .init(myId);

      await ref
          .read(DependencyModule.profilePostViewModelProvider(myId).notifier)
          .refresh(myId);
    }
  }

  // PERLU DITAMBAHKAN:
  // reset state upload setelah sukses/error sudah dipakai UI
  void resetState() {
    state = const AsyncData(null);
  }
}
