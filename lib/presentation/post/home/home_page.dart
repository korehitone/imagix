import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:go_router/go_router.dart';
import 'package:imagix/app/navigation/app_router.dart';
import 'package:imagix/core/utils/helper.dart';
import 'package:imagix/di/dependency_module.dart';
import 'package:imagix/domain/post/model/post.dart';
import 'package:imagix/presentation/common/pagination/paginated_state.dart';
import 'package:imagix/presentation/widgets/app_empty_widget.dart';
import 'package:imagix/presentation/widgets/app_error_widget.dart';
import 'package:imagix/presentation/widgets/app_image_card.dart';

import '../../../core/theme/app_colors.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      ref.read(DependencyModule.homeViewModelProvider.notifier).init();
    });

    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;

    final position = _scrollController.position;
    if (position.pixels >= position.maxScrollExtent - 300) {
      ref.read(DependencyModule.homeViewModelProvider.notifier).loadMore();
    }
  }

  // void _maybePrefetch(PaginatedState<Post> data) {
  //   if (!_scrollController.hasClients) return;
  //   if (data.items.isEmpty) return;
  //   if (data.isLoading || data.isLoadingMore || !data.hasMore) return;
  //
  //   final position = _scrollController.position;
  //
  //   // Kalau maxScrollExtent masih kecil, artinya konten belum cukup
  //   // panjang untuk benar-benar di-scroll. Prefetch page berikutnya.
  //   if (position.maxScrollExtent < 200) {
  //     ref.read(DependencyModule.homeViewModelProvider.notifier).loadMore();
  //   }
  // }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(DependencyModule.homeViewModelProvider, (prev, next) {
      if (next is AsyncError) {
        if (prev is AsyncError && prev?.error == next.error) return;
        context.showMsg(next.error.toString());
      }

      final data = next.value;
      if (data?.errorMessage != null) {
        context.showMsg(data!.errorMessage!);
        ref.read(DependencyModule.homeViewModelProvider.notifier).clearError();
      }
    });
    final state = ref.watch(DependencyModule.homeViewModelProvider);
    final data = state.value ?? PaginatedState<Post>.empty();
    final posts = data.items;

    //
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   if (!mounted) return;
    //   _maybePrefetch(data);
    // });

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          color: AppColors.primary,
          onRefresh: () => ref
              .read(DependencyModule.homeViewModelProvider.notifier)
              .refresh(),
          child: data.isLoading && posts.isEmpty
              ? Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                )
              : data.errorMessage != null && posts.isEmpty
              ? AppErrorWidget(
                  errorMessage: data.errorMessage!,
                  onRetry: () => ref
                      .read(DependencyModule.homeViewModelProvider.notifier)
                      .refresh(),
                )
              : posts.isEmpty
              ? const AppEmptyWidget()
              : _buildDataLayer(posts, data.isLoadingMore),
        ),
      ),
    );
  }

  Widget _buildDataLayer(List<Post> posts, bool isLoadingMore) {
    return MasonryGridView.count(
      controller: _scrollController,
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      itemCount: posts.length + (isLoadingMore ? 2 : 0),
      crossAxisCount: 2,
      crossAxisSpacing: 8,
      mainAxisSpacing: 8,
      itemBuilder: (context, index) {
        if (index >= posts.length) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 24),
            child: Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            ),
          );
        }
        final post = posts[index];
        return ImageItem(
          postId: post.id,
          imageUrl: post.image,
          title: post.title,
          onTap: () {
            context.push(AppRoute.imageDetail, extra: post);
          },
        );
      },
    );
  }
}
