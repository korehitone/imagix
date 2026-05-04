import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:go_router/go_router.dart';
import 'package:imagix/app/navigation/app_router.dart';
import 'package:imagix/core/theme/app_colors.dart';
import 'package:imagix/core/utils/helper.dart';
import 'package:imagix/di/dependency_module.dart';
import 'package:imagix/domain/post/model/post.dart';
import 'package:imagix/domain/profile/model/profile.dart';
import 'package:imagix/presentation/common/pagination/paginated_state.dart';
import 'package:imagix/presentation/widgets/app_error_widget.dart';
import 'package:imagix/presentation/widgets/app_image_card.dart';
import 'package:imagix/presentation/widgets/app_search_bar.dart';

enum SearchType { posts, profiles }

class SearchPage extends ConsumerStatefulWidget {
  const SearchPage({super.key});

  @override
  ConsumerState<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends ConsumerState<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  SearchType _selectedType = SearchType.posts;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;

    final position = _scrollController.position;
    if (position.pixels >= position.maxScrollExtent - 300) {
      if (_selectedType == SearchType.posts) {
        ref
            .read(DependencyModule.searchPostViewModelProvider.notifier)
            .loadMore();
      } else {
        ref
            .read(DependencyModule.searchProfileViewModelProvider.notifier)
            .loadMore();
      }
    }
  }

  void _handleSearch() {
    final query = _searchController.text;

    if (_selectedType == SearchType.posts) {
      ref
          .read(DependencyModule.searchPostViewModelProvider.notifier)
          .search(query);
    } else {
      ref
          .read(DependencyModule.searchProfileViewModelProvider.notifier)
          .search(query);
    }
  }

  void _handleFilterChange(SearchType type) {
    setState(() {
      _selectedType = type;
    });

    final query = _searchController.text.trim();
    if (query.isEmpty) return;

    _handleSearch();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // ref.listen(DependencyModule.searchViewModelProvider, (prev, next) {
    //   final data = next.value;
    //   if (data?.errorMessage != null) {
    //     context.showMsg(data!.errorMessage!);
    //     ref
    //         .read(DependencyModule.searchViewModelProvider.notifier)
    //         .clearError();
    //   }
    // });

    ref.listen(DependencyModule.searchPostViewModelProvider, (prev, next) {
      final data = next.value;
      if (_selectedType == SearchType.posts &&
          data?.errorMessage != null &&
          (data?.items.isNotEmpty ?? false)) {
        context.showMsg(data!.errorMessage!);
        ref
            .read(DependencyModule.searchPostViewModelProvider.notifier)
            .clearError();
      }
    });

    ref.listen(DependencyModule.searchProfileViewModelProvider, (prev, next) {
      final data = next.value;
      if (_selectedType == SearchType.profiles &&
          data?.errorMessage != null &&
          (data?.items.isNotEmpty ?? false)) {
        context.showMsg(data!.errorMessage!);
        ref
            .read(DependencyModule.searchProfileViewModelProvider.notifier)
            .clearError();
      }
    });

    // final state = ref.watch(DependencyModule.searchViewModelProvider);
    // final data = state.value ?? SearchState.empty();

    final postState = ref.watch(DependencyModule.searchPostViewModelProvider);
    final profileState = ref.watch(
      DependencyModule.searchProfileViewModelProvider,
    );

    final postData = postState.value ?? PaginatedState<Post>.empty();
    final profileData = profileState.value ?? PaginatedState<Profile>.empty();

    return Scaffold(
      extendBody: true,
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              const SizedBox(height: 12),
              AppSearchBar(
                controller: _searchController,
                hint: _selectedType == SearchType.posts
                    ? 'Search posts'
                    : 'Search profiles',
                onSearchTap: _handleSearch,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _FilterChipButton(
                      label: 'Posts',
                      isSelected: _selectedType == SearchType.posts,
                      onTap: () => _handleFilterChange(SearchType.posts),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _FilterChipButton(
                      label: 'Profiles',
                      isSelected: _selectedType == SearchType.profiles,
                      onTap: () => _handleFilterChange(SearchType.profiles),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Expanded(
                child: _selectedType == SearchType.posts
                    ? _buildPostResults(postData)
                    : _buildProfileResults(profileData),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPostResults(PaginatedState<Post> data) {
    final posts = data.items;

    if (_searchController.text.trim().isEmpty) {
      return const Center(child: Text("Start searching"));
    }

    if (data.isLoading && posts.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (data.errorMessage != null && posts.isEmpty) {
      return AppErrorWidget(
        errorMessage: data.errorMessage!,
        onRetry: _handleSearch,
      );
    }

    if (posts.isEmpty) {
      return const Center(child: Text("No posts found"));
    }

    return MasonryGridView.count(
      controller: _scrollController,
      crossAxisCount: 2,
      crossAxisSpacing: 8,
      mainAxisSpacing: 8,
      itemCount: posts.length + (data.isLoadingMore ? 2 : 0),
      itemBuilder: (context, index) {
        if (index >= posts.length) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 24),
            child: Center(child: CircularProgressIndicator()),
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

  Widget _buildProfileResults(PaginatedState<Profile> data) {
    final profiles = data.items;

    if (_searchController.text.trim().isEmpty) {
      return const Center(child: Text("Start searching"));
    }

    if (data.isLoading && profiles.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (data.errorMessage != null && profiles.isEmpty) {
      return AppErrorWidget(
        errorMessage: data.errorMessage!,
        onRetry: _handleSearch,
      );
    }

    if (profiles.isEmpty) {
      return const Center(child: Text("No profiles found"));
    }

    return ListView.separated(
      controller: _scrollController,
      itemCount: profiles.length + (data.isLoadingMore ? 1 : 0),
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        if (index >= profiles.length) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 24),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        final profile = profiles[index];
        return _ProfileSearchItem(profile: profile);
      },
    );
  }
}

class _ProfileSearchItem extends StatelessWidget {
  final Profile profile;

  const _ProfileSearchItem({required this.profile});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        context.push(AppRoute.profileWithId(profile.id));
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.primary, width: 1.5),
        ),
        child: Row(
          children: [
            profile.photo != null && profile.photo!.isNotEmpty
                ? CircleAvatar(
                    radius: 24,
                    backgroundImage: NetworkImage(profile.photo!),
                  )
                : Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.primary, width: 1.5),
                    ),
                    child: const Icon(
                      Icons.person_outline,
                      color: Colors.black,
                    ),
                  ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    profile.username,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  if ((profile.bio ?? '').trim().isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      profile.bio!,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: Colors.grey[700]),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterChipButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterChipButton({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 42,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.primary, width: 1.5),
        ),
        child: Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: isSelected ? Colors.white : AppColors.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
