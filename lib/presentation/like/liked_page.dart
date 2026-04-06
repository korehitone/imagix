import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:go_router/go_router.dart';
import 'package:imagix/app/navigation/app_router.dart';
import 'package:imagix/core/theme/app_colors.dart';
import 'package:imagix/core/utils/helper.dart';
import 'package:imagix/di/dependency_module.dart';
import 'package:imagix/domain/post/model/post.dart';
import 'package:imagix/presentation/common/pagination/paginated_state.dart';
import 'package:imagix/presentation/widgets/app_error_widget.dart';
import 'package:imagix/presentation/widgets/app_image_card.dart';

class LikedPage extends ConsumerStatefulWidget {
  const LikedPage({super.key});

  @override
  ConsumerState<LikedPage> createState() => _LikedPageState();
}

class _LikedPageState extends ConsumerState<LikedPage> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      ref.read(DependencyModule.likedViewModelProvider.notifier).init();
    });

    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;

    final position = _scrollController.position;
    if (position.pixels >= position.maxScrollExtent - 300) {
      ref.read(DependencyModule.likedViewModelProvider.notifier).loadMore();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(DependencyModule.likedViewModelProvider, (prev, next) {
      if (next is AsyncError) {
        if (prev is AsyncError && prev?.error == next.error) return;
        context.showMsg(next.error.toString());
      }

      final data = next.value;

      if (data?.errorMessage != null && (data?.items.isNotEmpty ?? false)) {
        context.showMsg(data!.errorMessage!);
        ref.read(DependencyModule.likedViewModelProvider.notifier).clearError();
      }
    });

    final state = ref.watch(DependencyModule.likedViewModelProvider);
    final data = state.value ?? PaginatedState<Post>.empty();
    final posts = data.items;

    return Scaffold(
      extendBody: true,
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child:
            // if (state.isLoading && !state.hasValue) {
            //   return const Center(child: CircularProgressIndicator());
            // }
            //
            // if (state.hasError && !state.hasValue) {
            //   return AppErrorWidget(
            //     errorMessage: state.error.toString(),
            //     onRetry: () => ref
            //         .read(DependencyModule.likedViewModelProvider.notifier)
            //         .refresh(),
            //   );
            // }
            //
            // if (posts == null || posts.isEmpty) {
            //   return Center(
            //     child: Padding(
            //       padding: const EdgeInsets.symmetric(horizontal: 32),
            //       child: Column(
            //         mainAxisAlignment: MainAxisAlignment.center,
            //         children: [
            //           Icon(
            //             Icons.favorite_border,
            //             size: 64,
            //             color: Colors.grey[500],
            //           ),
            //           const SizedBox(height: 16),
            //           Text(
            //             'No liked posts yet',
            //             style: Theme.of(context).textTheme.titleMedium
            //                 ?.copyWith(
            //                   color: Colors.black,
            //                   fontWeight: FontWeight.bold,
            //                 ),
            //           ),
            //           const SizedBox(height: 8),
            //           Text(
            //             'Posts you like will appear here.',
            //             textAlign: TextAlign.center,
            //             style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            //               color: Colors.grey[600],
            //             ),
            //           ),
            //         ],
            //       ),
            //     ),
            //   );
            // }
            RefreshIndicator(
              color: AppColors.primary,
              onRefresh: () => ref
                  .read(DependencyModule.likedViewModelProvider.notifier)
                  .refresh(),
              child: data.isLoading && posts.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : data.errorMessage != null && posts.isEmpty
                  ? AppErrorWidget(
                      errorMessage: data.errorMessage!,
                      onRetry: () => ref
                          .read(
                            DependencyModule.likedViewModelProvider.notifier,
                          )
                          .refresh(),
                    )
                  : posts.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.favorite_border,
                              size: 64,
                              color: Colors.grey[500],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No liked posts yet',
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Posts you like will appear here.',
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(color: Colors.grey[600]),
                            ),
                          ],
                        ),
                      ),
                    )
                  : _buildDataLayer(posts, data.isLoadingMore),
            ),
      ),
    );
  }

  Widget _buildDataLayer(List<Post> posts, bool isLoadingMore) {
    return CustomScrollView(
      controller: _scrollController,
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            child: Text(
              'Liked Posts',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          sliver: SliverMasonryGrid.count(
            crossAxisCount: 2,
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            childCount: posts.length + (isLoadingMore ? 2 : 0),
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
                onTap: () async {
                  await context.push(AppRoute.imageDetail, extra: post);

                  if (!context.mounted) return;

                  await ref
                      .read(DependencyModule.likedViewModelProvider.notifier)
                      .refresh();
                },
              );
            },
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 100)),
      ],
    );
  }
}

// import 'package:flutter/material.dart';
//
// import '../../core/theme/app_colors.dart';
// import '../widgets/app_collection_card.dart';
// import '../widgets/app_image_card.dart';
// import '../widgets/app_search_bar.dart';
//
// class LikedPage extends StatefulWidget {
//   const LikedPage({super.key});
//
//   @override
//   State<LikedPage> createState() => _SavedPageState();
// }
//
// class _SavedPageState extends State<LikedPage> {
//   int _currentIndex = 3;
//   final TextEditingController _searchController = TextEditingController();
//
//   @override
//   void dispose() {
//     _searchController.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       extendBody: true,
//       backgroundColor: AppColors.background,
//       body: SafeArea(
//         bottom: false,
//         child: Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 16),
//           child: CustomScrollView(
//             slivers: [
//               // Search Bar & Collections Header
//               SliverToBoxAdapter(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     const SizedBox(height: 12),
//                     AppSearchBar(
//                       controller: _searchController,
//                       onSearchTap: () {
//                         // TODO: handle search
//                       },
//                     ),
//                     const SizedBox(height: 24),
//
//                     // Collections Header
//                     Text(
//                       'Collections',
//                       style: Theme.of(context).textTheme.headlineSmall
//                           ?.copyWith(
//                             color: Colors.black,
//                             fontWeight: FontWeight.bold,
//                           ),
//                     ),
//                     const SizedBox(height: 12),
//                   ],
//                 ),
//               ),
//
//               // Collections Grid
//               SliverGrid(
//                 delegate: SliverChildBuilderDelegate(
//                   (context, index) => AppCollectionCard(title: 'Title'),
//                   childCount: 4,
//                 ),
//                 gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//                   crossAxisCount: 2,
//                   crossAxisSpacing: 16,
//                   mainAxisSpacing: 5,
//                   childAspectRatio: 173 / 151,
//                 ),
//               ),
//
//               // Last Added Header
//               SliverToBoxAdapter(
//                 child: Padding(
//                   padding: const EdgeInsets.only(top: 24, bottom: 12),
//                   child: Text(
//                     'Last Added',
//                     style: Theme.of(context).textTheme.headlineSmall?.copyWith(
//                       color: Colors.black,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                 ),
//               ),
//
//               // Images Grid
//               SliverGrid(
//                 delegate: SliverChildBuilderDelegate(
//                   (context, index) => ImageItem(title: 'Title'),
//                   childCount: 10,
//                 ),
//                 gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//                   crossAxisCount: 2,
//                   crossAxisSpacing: 16,
//                   mainAxisSpacing: 16,
//                   childAspectRatio: 173 / 329,
//                 ),
//               ),
//
//               // Bottom padding for nav bar
//               const SliverToBoxAdapter(child: SizedBox(height: 100)),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
