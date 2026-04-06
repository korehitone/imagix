import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:imagix/core/network/result_state.dart';
import 'package:imagix/di/dependency_module.dart';
import 'package:imagix/domain/auth/use_case/auth_use_case.dart';
import 'package:imagix/domain/collection/use_case/collection_item_use_case.dart';
import 'package:imagix/domain/collection/use_case/collection_use_case.dart';
import 'package:imagix/domain/comment/model/comment_request.dart';
import 'package:imagix/domain/comment/use_case/comment_use_case.dart';
import 'package:imagix/domain/post/model/post.dart';
import 'package:imagix/domain/post/use_case/post_use_case.dart';
import 'package:imagix/presentation/post/detail/image_detail_data.dart';

class ImageDetailViewModel extends AsyncNotifier<ImageDetailData> {
  AuthUseCase get _authUseCase =>
      ref.read(DependencyModule.authUseCaseProvider);

  CommentUseCase get _commentUseCase =>
      ref.read(DependencyModule.commentUseCaseProvider);

  PostUseCase get _postUseCase =>
      ref.read(DependencyModule.postUseCaseProvider);

  CollectionItemUseCase get _collectionItemUseCase =>
      ref.read(DependencyModule.collectionItemUseCaseProvider);

  CollectionUseCase get _collectionUseCase =>
      ref.read(DependencyModule.collectionUseCaseProvider);

  @override
  Future<ImageDetailData> build() async {
    final user = _authUseCase.getCurrentUser.invoke();
    return ImageDetailData.empty().copyWith(userId: user?.id);
  }

  Future<void> init(Post post) async {
    final currentData = state.value;
    if (currentData?.post?.id == post.id && currentData?.post != null) {
      // JANGAN TIMPA STATE! Langsung sync data terbaru dari API & User Info
      getUserId();
      unawaited(fetchComments(post.id));
      await refreshPost(post.id);
      return; // Keluar, biar gak ngetimpa state pake data 'post' dari parameter
    }

    _updateState((current) => current.copyWith(post: post));
    getUserId();
    unawaited(fetchComments(post.id));
    await refreshPost(post.id);
  }

  void _updateState(ImageDetailData Function(ImageDetailData current) update) {
    final current = state.value ?? ImageDetailData.empty();
    state = AsyncData(update(current));
  }

  Future<void> refreshPost(String postId) async {
    final result = await _postUseCase.getPost.invoke(postId);
    switch (result) {
      case Success(data: final freshPost):
        _updateState((current) => current.copyWith(post: freshPost));
        break;
      case Error(error: final msg):
        _updateState((current) => current.copyWith(errorMessage: msg));
        break;
    }
  }

  Future<void> fetchComments(String postId) async {
    final currentData = state.value;
    if (currentData == null) return;

    final result = await _commentUseCase.getComments.invoke(postId);

    switch (result) {
      case Success(data: final comments):
        // ==========================================
        // PENTING:
        // ambil state TERBARU saat response datang,
        // jangan pakai snapshot lama yang bisa bawa post lama
        // ==========================================
        _updateState((current) => current.copyWith(comments: comments));
        break;

      case Error(error: final msg):
        _updateState((current) => current.copyWith(errorMessage: msg));
        break;
    }
  }

  void resetSuccess() {
    final currentData = state.value;
    if (currentData != null) {
      state = AsyncData(currentData.copyWith(isSuccess: false));
    }
  }

  void resetDeleted() {
    final currentData = state.value;
    if (currentData != null) {
      state = AsyncData(currentData.copyWith(isDeleted: false));
    }
  }

  void getUserId() {
    final user = _authUseCase.getCurrentUser.invoke();
    final currentData = state.value;
    if (currentData != null) {
      state = AsyncData(currentData.copyWith(userId: user?.id));
    }
  }

  void setReplyingTo(int parentId, String username) {
    state = AsyncData(
      state.requireValue.copyWith(
        replyingToId: parentId,
        replyingToName: username,
      ),
    );
  }

  void cancelReply() {
    state = AsyncData(
      state.requireValue.copyWith(
        replyingToId: null, // Di copyWith lo, pastiin ini bisa nge-set null
        replyingToName: null,
      ),
    );
  }

  Future<void> submitComment(String? postId, String content) async {
    final currentData = state.requireValue;
    if (postId == null || content.isEmpty) return;

    final post = currentData.post;
    if (post == null) return;
    state = AsyncData(
      currentData.copyWith(post: post.updateCommentCount(true)),
    );
    state = await AsyncValue.guard(() async {
      final result = await _commentUseCase.create.invoke(
        CommentRequest(
          postId: postId,
          comment: content,
          parentId: currentData.replyingToId,
        ),
      );

      return switch (result) {
        Success(data: final status) => () {
          unawaited(fetchComments(postId));
          return currentData.copyWith(
            isSuccess: status,
            replyingToId: null,
            replyingToName: null,
            post: state.value?.post,
          );
        }(),
        Error(error: final msg) => throw Exception(msg), // THROW AJA COK!
      };
    });

    if (state is AsyncError) {
      state = AsyncData(currentData.copyWith(post: post));
    }
  }

  Future<void> deleteComment(int commentId, postId) async {
    final currentData = state.requireValue;
    if (postId == null) return;
    final post = currentData.post;
    if (post == null) return;
    state = AsyncData(
      currentData.copyWith(post: post.updateCommentCount(false)),
    );

    state = await AsyncValue.guard(() async {
      final result = await _commentUseCase.delete.invoke(commentId);
      return switch (result) {
        Success(data: final status) => () {
          unawaited(fetchComments(postId));
          return currentData.copyWith(
            isSuccess: status,
            replyingToId: null,
            replyingToName: null,
            post: state.value?.post,
          );
        }(),
        Error(error: final msg) => throw Exception(msg), // THROW AJA COK!
      };
    });
    if (state is AsyncError) {
      state = AsyncData(currentData.copyWith(post: post));
    }
  }

  Future<void> toggleLike(String postId) async {
    final currentData = state.value;
    if (currentData?.post == null) return;

    final postBefore = currentData!.post!;

    // --- 1. OPTIMISTIC UPDATE ---
    final updatedPost = postBefore.toggleLike();
    state = AsyncData(currentData.copyWith(post: updatedPost));

    // --- 2. TEMBAK API ---
    final result = await _postUseCase.toggleLike.invoke(postId);

    // --- 3. HANDLE RESULT PAKE SWITCH ---
    switch (result) {
      case Success(data: final isLikedResult):
        // FINAL SYNC: Pakai data asli dari server
        _updateState(
          (current) =>
              current.copyWith(post: postBefore.syncLikeState(isLikedResult)),
        );
        break;

      case Error(error: final msg):
        // --- 4. ROLLBACK ---
        // Kalau gagal, balikin ke data SEBELUM dipencet (postBefore)
        state = AsyncData(
          currentData.copyWith(post: postBefore, errorMessage: msg),
        );
        break;
    }
  }

  Future<void> fetchUserCollection(String postId) async {
    // ==========================================
    // PAKAI STATE SAAT INI KALAU ADA
    // KALAU BELUM ADA, PAKAI EMPTY
    // ==========================================
    final currentData = state.value ?? ImageDetailData.empty();

    state = const AsyncLoading();

    final result = await _collectionUseCase.getCollectionWithSaved.invoke(
      postId,
    );

    switch (result) {
      case Success(data: final list):
        state = AsyncData(currentData.copyWith(collections: list));
        break;

      case Error(error: final msg):
        state = AsyncError(msg, StackTrace.current);
        state = AsyncData(currentData.copyWith(errorMessage: msg));
        break;
    }
  }

  Future<void> toggleSaveToCollection(
    String collectionId,
    String postId,
  ) async {
    final currentData = state.value;
    if (currentData == null) return;

    final collections = currentData.collections;

    final optimisticCollections = collections.map((c) {
      if (c.id == collectionId) return c.copyWith(isSaved: true);
      return c;
    }).toList();

    state = AsyncData(currentData.copyWith(collections: optimisticCollections));

    final result = await _collectionItemUseCase.create.invoke(
      collectionId,
      postId,
    );

    switch (result) {
      case Success(data: final isSuccess):
        // ==========================================
        // UPDATE STATE DETAIL POST
        // ==========================================
        state = AsyncData(
          currentData.copyWith(
            isSuccess: isSuccess,
            collections: optimisticCollections,
          ),
        );

        // ==========================================
        // PENTING:
        // REFRESH PROFILE COLLECTIONS
        // biar item list collection di tab Saved ikut update
        // ==========================================
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

        resetSuccess();
        break;

      case Error(error: final msg):
        state = AsyncData(
          currentData.copyWith(
            collections: collections,
            isSuccess: false,
            errorMessage: msg,
          ),
        );
        break;
    }
  }

  Future<void> deletePost(String postId) async {
    final result = await _postUseCase.delete.invoke(postId);

    switch (result) {
      case Success():
        final myId = _authUseCase.getCurrentUser.invoke()?.id;

        // refresh semua list yang mungkin menampilkan post ini
        await ref
            .read(DependencyModule.homeViewModelProvider.notifier)
            .refresh();

        await ref
            .read(DependencyModule.profileViewModelProvider(null).notifier)
            .init(null);

        if (myId != null) {
          await ref
              .read(DependencyModule.profileViewModelProvider(myId).notifier)
              .init(myId);

          await ref
              .read(
                DependencyModule.profilePostViewModelProvider(myId).notifier,
              )
              .refresh(myId);
        }

        _updateState((current) => current.copyWith(isDeleted: true));
        break;

      case Error(error: final msg):
        _updateState((current) => current.copyWith(errorMessage: msg));
        break;
    }
  }

  void clearError() {
    _updateState((current) => current.copyWith(errorMessage: null));
  }
}
