import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:imagix/core/network/result_state.dart';
import 'package:imagix/di/dependency_module.dart';
import 'package:imagix/domain/collection/model/collection.dart';
import 'package:imagix/domain/collection/use_case/collection_use_case.dart';
import 'package:imagix/presentation/common/pagination/paginated_state.dart';

class ProfileCollectionsViewModel
    extends AsyncNotifier<PaginatedState<Collection>> {
  CollectionUseCase get _collectionUseCase =>
      ref.read(DependencyModule.collectionUseCaseProvider);

  static const int _limit = 20;

  @override
  FutureOr<PaginatedState<Collection>> build() {
    return PaginatedState<Collection>.empty();
  }

  Future<void> init() async {
    final current = state.value ?? PaginatedState<Collection>.empty();
    if (current.items.isNotEmpty || current.isLoading) return;

    await refresh();
  }

  Future<void> refresh() async {
    final current = state.value ?? PaginatedState<Collection>.empty();

    state = AsyncData(
      current.copyWith(
        isLoading: true,
        isLoadingMore: false,
        items: [],
        hasMore: true,
        errorMessage: null,
      ),
    );

    final result = await _collectionUseCase.getCollections.invoke(
      offset: 0,
      limit: _limit,
    );

    switch (result) {
      case Success(data: final collections):
        state = AsyncData(
          current.copyWith(
            items: collections,
            isLoading: false,
            isLoadingMore: false,
            hasMore: collections.length == _limit,
          ),
        );
        break;

      case Error(error: final msg):
        state = AsyncData(
          current.copyWith(
            isLoading: false,
            isLoadingMore: false,
            errorMessage: msg,
          ),
        );
        break;
    }
  }

  Future<void> loadMore() async {
    final current = state.value ?? PaginatedState<Collection>.empty();

    if (current.isLoading || current.isLoadingMore || !current.hasMore) return;

    state = AsyncData(
      current.copyWith(isLoadingMore: true, errorMessage: null),
    );

    final result = await _collectionUseCase.getCollections.invoke(
      offset: current.items.length,
      limit: _limit,
    );

    switch (result) {
      case Success(data: final newCollections):
        state = AsyncData(
          current.copyWith(
            items: [...current.items, ...newCollections],
            isLoadingMore: false,
            hasMore: newCollections.length == _limit,
          ),
        );
        break;

      case Error(error: final msg):
        state = AsyncData(
          current.copyWith(isLoadingMore: false, errorMessage: msg),
        );
        break;
    }
  }

  void clearError() {
    final current = state.value;
    if (current == null) return;
    state = AsyncData(current.copyWith(errorMessage: null));
  }
}
