import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:go_router/go_router.dart';
import 'package:imagix/app/navigation/app_router.dart';
import 'package:imagix/core/utils/helper.dart';
import 'package:imagix/di/dependency_module.dart';
import 'package:imagix/domain/collection/model/collection.dart';
import 'package:imagix/domain/post/model/post.dart';
import 'package:imagix/presentation/common/pagination/paginated_state.dart';
import 'package:imagix/presentation/profile/profile_data.dart';
import 'package:imagix/presentation/widgets/app_collection_card.dart';
import 'package:imagix/presentation/widgets/app_error_widget.dart';

import '../../core/theme/app_colors.dart';
import '../widgets/app_back_button.dart';
import '../widgets/app_image_card.dart';
import '../widgets/app_profile_header.dart';

class ProfilePage extends ConsumerStatefulWidget {
  final String? userId;

  const ProfilePage({super.key, this.userId});

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage> {
  final ScrollController _postScrollController = ScrollController();
  final ScrollController _collectionScrollController = ScrollController();

  String? _lastInitializedPostUserId;
  bool _collectionsInitialized = false;

  @override
  void initState() {
    super.initState();

    _postScrollController.addListener(_onPostScroll);
    _collectionScrollController.addListener(_onCollectionScroll);

    Future.microtask(() {
      ref
          .read(
            DependencyModule.profileViewModelProvider(widget.userId).notifier,
          )
          .init(widget.userId);
    });
  }

  void _onPostScroll() {
    if (!_postScrollController.hasClients) return;
    if (_lastInitializedPostUserId == null) return;

    final position = _postScrollController.position;
    if (position.pixels >= position.maxScrollExtent - 300) {
      ref
          .read(
            DependencyModule.profilePostViewModelProvider(
              _lastInitializedPostUserId!,
            ).notifier,
          )
          .loadMore();
    }
  }

  void _onCollectionScroll() {
    if (!_collectionScrollController.hasClients) return;

    final position = _collectionScrollController.position;
    if (position.pixels >= position.maxScrollExtent - 300) {
      ref
          .read(DependencyModule.profileCollectionsViewModelProvider.notifier)
          .loadMore();
    }
  }

  @override
  void dispose() {
    _postScrollController.dispose();
    _collectionScrollController.dispose();
    super.dispose();
  }

  void _ensurePostPaginationInitialized(String? resolvedUserId) {
    if (resolvedUserId == null) return;
    if (_lastInitializedPostUserId == resolvedUserId) return;

    _lastInitializedPostUserId = resolvedUserId;

    Future.microtask(() {
      if (!mounted) return;
      ref
          .read(
            DependencyModule.profilePostViewModelProvider(
              resolvedUserId,
            ).notifier,
          )
          .init(resolvedUserId);
    });
  }

  // ==========================================
  // TAMBAHAN BARU:
  // init collections hanya saat profile yang tampil
  // ternyata profile milik user login
  // ==========================================
  void _ensureCollectionsInitialized(bool isOwnProfile) {
    if (!isOwnProfile) return;
    if (_collectionsInitialized) return;

    _collectionsInitialized = true;

    Future.microtask(() {
      if (!mounted) return;
      ref
          .read(DependencyModule.profileCollectionsViewModelProvider.notifier)
          .init();
    });
  }

  // ==========================================
  // TAMBAHAN BARU:
  // dialog logout
  // ==========================================
  Future<void> _handleLogout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Logout?'),
        content: const Text('You will need to sign in again to continue.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    final ok = await ref
        .read(DependencyModule.authViewModelProvider.notifier)
        .logout();

    if (!mounted) return;

    if (ok) {
      context.go(AppRoute.login);
    }
  }

  // ==========================================
  // TAMBAHAN BARU:
  // dialog soft delete account
  // ==========================================
  Future<void> _handleDeleteAccount() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete account?'),
        content: const Text(
          'Your account will be soft deleted. You can restore it later by signing in again.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    final ok = await ref
        .read(DependencyModule.authViewModelProvider.notifier)
        .deleteAccount();

    if (!mounted) return;

    if (ok) {
      context.go(AppRoute.login);
    }
  }

  // ==========================================
  // TAMBAHAN BARU:
  // menu titik tiga untuk profile sendiri
  // ==========================================
  Widget _buildOwnProfileMenu() {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert, color: Colors.black),
      onSelected: (value) async {
        if (value == 'logout') {
          await _handleLogout();
        } else if (value == 'delete_account') {
          await _handleDeleteAccount();
        }
      },
      itemBuilder: (context) => const [
        PopupMenuItem<String>(value: 'logout', child: Text('Logout')),
        PopupMenuItem<String>(
          value: 'delete_account',
          child: Text('Delete Account'),
        ),
      ],
    );
  }

  void _showFollowOverlay(String title, bool isFollowersList) {
    final headerData = ref
        .read(DependencyModule.profileViewModelProvider(widget.userId))
        .value;
    final targetId = headerData?.profile?.id;
    if (targetId == null) return;

    if (isFollowersList) {
      ref
          .read(
            DependencyModule.profileViewModelProvider(widget.userId).notifier,
          )
          .fetchFollowers(targetId);
    } else {
      ref
          .read(
            DependencyModule.profileViewModelProvider(widget.userId).notifier,
          )
          .fetchFollowing(targetId);
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Consumer(
        builder: (context, ref, _) {
          final data = ref
              .watch(DependencyModule.profileViewModelProvider(widget.userId))
              .value;
          final list = isFollowersList
              ? (data?.followers ?? [])
              : (data?.followings ?? []);

          return Container(
            height: MediaQuery.of(context).size.height * 0.7,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Column(
              children: [
                const SizedBox(height: 12),
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
                const Divider(),
                Expanded(
                  child: list.isEmpty
                      ? const Center(child: Text("Kosong, Plen!"))
                      : ListView.builder(
                          itemCount: list.length,
                          itemBuilder: (context, index) {
                            final user = list[index];
                            return ListTile(
                              onTap: () {
                                Navigator.pop(context);
                                context.push(
                                  AppRoute.profileWithId(user.userId),
                                );
                              },
                              leading:
                                  user.photo != null && user.photo!.isNotEmpty
                                  ? CircleAvatar(
                                      radius: 20,
                                      backgroundImage: NetworkImage(
                                        user.photo!,
                                      ),
                                    )
                                  : Container(
                                      width: 40,
                                      height: 40,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: AppColors.primary.withValues(
                                            alpha: 0.5,
                                          ),
                                          width: 1,
                                        ),
                                      ),
                                      child: const Icon(
                                        Icons.person_outline,
                                        size: 24,
                                        color: Colors.black,
                                      ),
                                    ),
                              title: Text(
                                user.username,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              trailing: _buildTrailingAction(
                                user,
                                isFollowersList,
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildTrailingAction(dynamic user, bool isFollowersList) {
    // ==========================================
    // PERUBAHAN:
    // jangan lagi pakai widget.userId == null
    // profile sendiri ditentukan dari auth user vs profile yang tampil
    // ==========================================
    final authState = ref.read(DependencyModule.authViewModelProvider);
    final myUserId = authState.value?.user?.id;
    final currentProfileId = ref
        .read(DependencyModule.profileViewModelProvider(widget.userId))
        .value
        ?.profile
        ?.id;

    final isOwnProfile =
        myUserId != null &&
        currentProfileId != null &&
        myUserId == currentProfileId;

    if (!isOwnProfile) return const SizedBox.shrink();

    if (isFollowersList) {
      return IconButton(
        icon: const Icon(Icons.close, color: Colors.grey, size: 20),
        onPressed: () => ref
            .read(
              DependencyModule.profileViewModelProvider(widget.userId).notifier,
            )
            .removeFollower(user.userId),
      );
    }

    return SizedBox(
      height: 32,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: user.isFollowing
              ? Colors.grey[200]
              : AppColors.primary,
          foregroundColor: user.isFollowing ? Colors.black : Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          padding: const EdgeInsets.symmetric(horizontal: 12),
        ),
        onPressed: () {
          ref
              .read(
                DependencyModule.profileViewModelProvider(
                  widget.userId,
                ).notifier,
              )
              .toggleFollowProfile(user.userId);
        },
        child: Text(
          user.isFollowing ? "Unfollow" : "Follow",
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(DependencyModule.profileViewModelProvider(widget.userId), (
      prev,
      next,
    ) {
      final data = next.value;

      if (next is AsyncError) {
        if (prev is AsyncError && prev?.error == next.error) return;
        context.showMsg(next.error.toString());
      }

      if (data?.errorMessage != null) {
        context.showMsg(data!.errorMessage!);
        ref
            .read(
              DependencyModule.profileViewModelProvider(widget.userId).notifier,
            )
            .clearError();
      }
    });

    // ==========================================
    // TAMBAHAN BARU:
    // dengerin error dari logout / delete account
    // ==========================================
    ref.listen(DependencyModule.authViewModelProvider, (prev, next) {
      next.whenOrNull(
        error: (e, stack) {
          context.showMsg(e.toString());
        },
      );
    });

    final headerState = ref.watch(
      DependencyModule.profileViewModelProvider(widget.userId),
    );

    if (headerState.isLoading && !headerState.hasValue) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (headerState.hasError && !headerState.hasValue) {
      final String location = GoRouterState.of(context).matchedLocation;
      final bool isNavMenuRoot = location == AppRoute.menuProfile;
      final bool canNavigateBack = context.canPop() && !isNavMenuRoot;

      return Scaffold(
        appBar: canNavigateBack
            ? AppBar(
                leading: const AppBackButton(),
                backgroundColor: Colors.transparent,
                elevation: 0,
              )
            : null,
        body: AppErrorWidget(
          errorMessage: headerState.error.toString(),
          onRetry: () => ref
              .read(
                DependencyModule.profileViewModelProvider(
                  widget.userId,
                ).notifier,
              )
              .init(widget.userId),
        ),
      );
    }

    final authState = ref.watch(DependencyModule.authViewModelProvider);
    final myUserId = authState.value?.user?.id;

    final headerData = headerState.value ?? ProfileData.empty();
    final resolvedUserId = headerData.profile?.id;

    // ==========================================
    // PERUBAHAN PALING PENTING:
    // profile sendiri jangan ditentuin dari widget.userId == null
    // tapi dari profile yang tampil vs auth user login
    // ==========================================
    final isOwnProfile =
        myUserId != null &&
        resolvedUserId != null &&
        resolvedUserId == myUserId;

    _ensurePostPaginationInitialized(resolvedUserId);
    _ensureCollectionsInitialized(isOwnProfile);

    final postsState = resolvedUserId == null
        ? const AsyncData(PaginatedState<Post>())
        : ref.watch(
            DependencyModule.profilePostViewModelProvider(resolvedUserId),
          );

    final collectionsState = isOwnProfile
        ? ref.watch(DependencyModule.profileCollectionsViewModelProvider)
        : const AsyncData(PaginatedState<Collection>());

    final postData = postsState.value ?? PaginatedState<Post>.empty();
    final collectionData =
        collectionsState.value ?? PaginatedState<Collection>.empty();

    final String location = GoRouterState.of(context).matchedLocation;
    final bool isNavMenuRoot = location == AppRoute.menuProfile;
    final bool canNavigateBack = context.canPop() && !isNavMenuRoot;

    return DefaultTabController(
      length: isOwnProfile ? 2 : 1,
      child: Scaffold(
        extendBody: true,
        backgroundColor: AppColors.background,
        key: ValueKey('profile_${isOwnProfile}_${widget.userId}'),
        body: SafeArea(
          bottom: false,
          child: NestedScrollView(
            headerSliverBuilder: (context, innerBoxIsScrolled) {
              return [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      children: [
                        // ==========================================
                        // PERUBAHAN:
                        // menu kanan atas sekarang ngikut isOwnProfile
                        // yang dihitung dari auth user id
                        // ==========================================
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            canNavigateBack
                                ? const AppBackButton()
                                : const SizedBox(width: 40),
                            isOwnProfile
                                ? _buildOwnProfileMenu()
                                : const SizedBox(width: 40),
                          ],
                        ),
                        AppProfileHeader(
                          username: headerData.profile?.username ?? "user",
                          bio: headerData.profile?.bio ?? "",
                          imageUrl: headerData.profile?.photo,
                          posts: headerData.profile?.totalPosts ?? 0,
                          followers: headerData.profile?.totalFollowers ?? 0,
                          following: headerData.profile?.totalFollowings ?? 0,
                          collections:
                              headerData.profile?.totalCollections ?? 0,
                          isOwnProfile: isOwnProfile,
                          isFollowing: headerData.profile?.isFollowing ?? false,
                          onFollowersTap: () {
                            if ((headerData.profile?.totalFollowers ?? 0) > 0) {
                              _showFollowOverlay("Followers", true);
                            }
                          },
                          onFollowingTap: () {
                            if ((headerData.profile?.totalFollowings ?? 0) >
                                0) {
                              _showFollowOverlay("Following", false);
                            }
                          },
                          onFollow: () {
                            final profileId = headerData.profile?.id;
                            if (profileId != null) {
                              ref
                                  .read(
                                    DependencyModule.profileViewModelProvider(
                                      widget.userId,
                                    ).notifier,
                                  )
                                  .toggleFollowProfile(profileId);
                            }
                          },
                          onEditProfile: () {
                            context.push(
                              AppRoute.editProfile,
                              extra: {
                                'existingUsername':
                                    headerData.profile?.username,
                                'existingBio': headerData.profile?.bio,
                                'existingPhotoUrl': headerData.profile?.photo,
                              },
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                SliverPersistentHeader(
                  pinned: true,
                  delegate: _SliverAppBarDelegate(
                    TabBar(
                      labelColor: AppColors.primary,
                      unselectedLabelColor: Colors.grey,
                      indicatorColor: AppColors.primary,
                      labelStyle: Theme.of(context).textTheme.bodyMedium
                          ?.copyWith(fontWeight: FontWeight.bold),
                      tabs: [
                        const Tab(text: 'Created'),
                        if (isOwnProfile) const Tab(text: 'Saved'),
                      ],
                    ),
                  ),
                ),
              ];
            },
            body: TabBarView(
              children: [
                _buildPostsTab(postData, resolvedUserId),
                if (isOwnProfile) _buildCollectionsTab(collectionData),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPostsTab(PaginatedState<Post> data, String? resolvedUserId) {
    final posts = data.items;

    if (data.isLoading && posts.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (data.errorMessage != null && posts.isEmpty) {
      return AppErrorWidget(
        errorMessage: data.errorMessage!,
        onRetry: () {
          if (resolvedUserId == null) return;
          ref
              .read(
                DependencyModule.profilePostViewModelProvider(
                  resolvedUserId,
                ).notifier,
              )
              .refresh(resolvedUserId);
        },
      );
    }

    if (posts.isEmpty) {
      return const Center(child: Text("No posts yet"));
    }

    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: () async {
        if (resolvedUserId == null) return;
        await ref
            .read(
              DependencyModule.profilePostViewModelProvider(
                resolvedUserId,
              ).notifier,
            )
            .refresh(resolvedUserId);
      },
      child: MasonryGridView.count(
        controller: _postScrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
        itemCount: posts.length + (data.isLoadingMore ? 2 : 0),
        crossAxisCount: 2,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
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
      ),
    );
  }

  Widget _buildCollectionsTab(PaginatedState<Collection> data) {
    final collections = data.items;

    if (data.isLoading && collections.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (data.errorMessage != null && collections.isEmpty) {
      return AppErrorWidget(
        errorMessage: data.errorMessage!,
        onRetry: () => ref
            .read(DependencyModule.profileCollectionsViewModelProvider.notifier)
            .refresh(),
      );
    }

    if (collections.isEmpty) {
      return const Center(child: Text("No collections yet"));
    }

    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: () => ref
          .read(DependencyModule.profileCollectionsViewModelProvider.notifier)
          .refresh(),
      child: GridView.builder(
        controller: _collectionScrollController,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        itemCount: collections.length + (data.isLoadingMore ? 2 : 0),
        physics: const AlwaysScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 173 / 170,
        ),
        itemBuilder: (context, index) {
          if (index >= collections.length) {
            return const Center(child: CircularProgressIndicator());
          }

          final collection = collections[index];
          return AppCollectionCard(
            title: collection.title,
            coverImage: collection.coverImage,
            totalItems: collection.totalItems,
            onTap: () {
              context.push(
                AppRoute.collectionDetail,
                extra: {
                  'collectionId': collection.id,
                  'collectionName': collection.title,
                  'isDefault': collection.isDefault,
                },
              );
            },
          );
        },
      ),
    );
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverAppBarDelegate(this._tabBar);

  final TabBar _tabBar;

  @override
  double get minExtent => _tabBar.preferredSize.height;

  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(color: AppColors.background, child: _tabBar);
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) => false;
}

// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
// import 'package:go_router/go_router.dart';
// import 'package:imagix/app/navigation/app_router.dart';
// import 'package:imagix/core/utils/helper.dart';
// import 'package:imagix/di/dependency_module.dart';
// import 'package:imagix/presentation/profile/profile_data.dart';
// import 'package:imagix/presentation/widgets/app_collection_card.dart';
// import 'package:imagix/presentation/widgets/app_error_widget.dart';
//
// import '../../core/theme/app_colors.dart';
// import '../widgets/app_back_button.dart';
// import '../widgets/app_image_card.dart';
// import '../widgets/app_profile_header.dart';
//
// class ProfilePage extends ConsumerStatefulWidget {
//   // final bool isOwnProfile;
//   final String? userId;
//
//   const ProfilePage({
//     super.key,
//     this.userId,
//     // this.isOwnProfile = true
//   });
//
//   @override
//   ConsumerState<ProfilePage> createState() => _ProfilePageState();
// }
//
// class _ProfilePageState extends ConsumerState<ProfilePage> {
//   final ScrollController _postScrollController = ScrollController();
//   final ScrollController _collectionScrollController = ScrollController();
//
//   Widget _buildCollectionGrid(ProfileData data) {
//     if (data.collections.isEmpty) {
//       return const Padding(
//         padding: EdgeInsets.symmetric(vertical: 32),
//         child: Center(child: Text("No collections yet")),
//       );
//     }
//
//     return GridView.builder(
//       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
//       itemCount: data.collections.length,
//       shrinkWrap: true,
//       physics: const NeverScrollableScrollPhysics(),
//       gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//         crossAxisCount: 2,
//         crossAxisSpacing: 16,
//         mainAxisSpacing: 16,
//         childAspectRatio: 173 / 170,
//       ),
//       itemBuilder: (context, index) {
//         final collection = data.collections[index];
//
//         return AppCollectionCard(
//           title: collection.title,
//           coverImage: collection.coverImage,
//           totalItems: collection.totalItems,
//           onTap: () {
//             context.push(
//               AppRoute.collectionDetail,
//               extra: {
//                 'collectionId': collection.id,
//                 'collectionName': collection.title,
//                 'isDefault': collection.isDefault,
//               },
//             );
//           },
//         );
//       },
//     );
//   }
//
//   // FUNGSI UNTUK TAMPILIN MODAL LIST
//   void _showFollowOverlay(String title, bool isFollowersList) {
//     final targetId =
//         widget.userId ??
//         ref
//             .read(DependencyModule.authUseCaseProvider)
//             .getCurrentUser
//             .invoke()
//             ?.id;
//     if (targetId == null) return;
//
//     // Load data pas dibuka
//     if (isFollowersList) {
//       ref
//           .read(
//             DependencyModule.profileViewModelProvider(widget.userId).notifier,
//           )
//           .fetchFollowers(targetId);
//     } else {
//       ref
//           .read(
//             DependencyModule.profileViewModelProvider(widget.userId).notifier,
//           )
//           .fetchFollowing(targetId);
//     }
//
//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       backgroundColor: Colors.transparent,
//       builder: (context) => Consumer(
//         // Biar modalnya REAKTIF
//         builder: (context, ref, _) {
//           final data = ref
//               .watch(DependencyModule.profileViewModelProvider(widget.userId))
//               .value;
//           final list = isFollowersList
//               ? (data?.followers ?? [])
//               : (data?.followings ?? []);
//
//           return Container(
//             height: MediaQuery.of(context).size.height * 0.7,
//             decoration: const BoxDecoration(
//               color: Colors.white,
//               borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//             ),
//             child: Column(
//               children: [
//                 const SizedBox(height: 12),
//                 Container(
//                   width: 40,
//                   height: 4,
//                   decoration: BoxDecoration(
//                     color: Colors.grey[300],
//                     borderRadius: BorderRadius.circular(10),
//                   ),
//                 ),
//                 Padding(
//                   padding: const EdgeInsets.all(16),
//                   child: Text(
//                     title,
//                     style: const TextStyle(
//                       fontWeight: FontWeight.bold,
//                       fontSize: 18,
//                     ),
//                   ),
//                 ),
//                 const Divider(),
//                 Expanded(
//                   child: list.isEmpty
//                       ? const Center(child: Text("Kosong, Plen!"))
//                       : ListView.builder(
//                           itemCount: list.length,
//                           itemBuilder: (context, index) {
//                             final user = list[index];
//                             return ListTile(
//                               onTap: () {
//                                 // Tutup BottomSheet dulu
//                                 Navigator.pop(context);
//
//                                 // Navigasi ke profile user tersebut
//                                 context.push(
//                                   AppRoute.profileWithId(user.userId),
//                                 );
//                               },
//                               // FOTO PROFIL DINAMIS
//                               leading:
//                                   user.photo != null && user.photo!.isNotEmpty
//                                   ? CircleAvatar(
//                                       radius: 20, // Ukuran standar ListTile
//                                       backgroundImage: NetworkImage(
//                                         user.photo!,
//                                       ),
//                                     )
//                                   : Container(
//                                       width: 40,
//                                       height: 40,
//                                       decoration: BoxDecoration(
//                                         shape: BoxShape.circle,
//                                         border: Border.all(
//                                           color: AppColors.primary.withValues(
//                                             alpha: 0.5,
//                                           ),
//                                           width: 1,
//                                         ),
//                                       ),
//                                       child: const Icon(
//                                         Icons.person_outline,
//                                         size: 24,
//                                         color: Colors.black,
//                                       ),
//                                     ),
//                               title: Text(
//                                 user.username,
//                                 style: const TextStyle(
//                                   fontWeight: FontWeight.w600,
//                                 ),
//                               ),
//                               trailing: _buildTrailingAction(
//                                 user,
//                                 isFollowersList,
//                               ),
//                             );
//                           },
//                         ),
//                   // : ListView.builder(
//                   //     itemCount: list.length,
//                   //     itemBuilder: (context, index) {
//                   //       final user = list[index];
//                   //       return ListTile(
//                   //         leading: CircleAvatar(
//                   //           backgroundImage: user.photo != null
//                   //               ? NetworkImage(user.photo!)
//                   //               : null,
//                   //         ),
//                   //         title: Text(user.username),
//                   //         trailing: _buildTrailingAction(
//                   //           user,
//                   //           isFollowersList,
//                   //         ),
//                   //       );
//                   //     },
//                   //   ),
//                 ),
//               ],
//             ),
//           );
//         },
//       ),
//     );
//   }
//
//   // LOGIC TOMBOL DI DALAM LIST
//   // Widget _buildTrailingAction(dynamic user, bool isFollowersList) {
//   //   final myId = ref
//   //       .read(DependencyModule.authUseCaseProvider)
//   //       .getCurrentUser
//   //       .invoke()
//   //       ?.id;
//   //   final isOwnProfile = widget.userId == null || widget.userId == myId;
//   //
//   //   if (isFollowersList && isOwnProfile) {
//   //     return IconButton(
//   //       icon: const Icon(Icons.close, color: Colors.grey),
//   //       onPressed: () => ref
//   //           .read(DependencyModule.profileViewModelProvider.notifier)
//   //           .removeFollower(user.id),
//   //     );
//   //   }
//   //
//   //   return ElevatedButton(
//   //     style: ElevatedButton.styleFrom(
//   //       backgroundColor: user.isFollowing
//   //           ? Colors.grey[200]
//   //           : AppColors.primary,
//   //       foregroundColor: user.isFollowing ? Colors.black : Colors.white,
//   //       elevation: 0,
//   //     ),
//   //     onPressed: () => ref
//   //         .read(DependencyModule.profileViewModelProvider.notifier)
//   //         .toggleFollowProfile(user.id),
//   //     child: Text(user.isFollowing ? "Unfollow" : "Follow"),
//   //   );
//   // }
//
//   Widget _buildTrailingAction(dynamic user, bool isFollowersList) {
//     // Ambil ID user kita sendiri buat ngecek "Ini profil siapa?"
//     final myId = ref
//         .read(DependencyModule.authUseCaseProvider)
//         .getCurrentUser
//         .invoke()
//         ?.id;
//     final isOwnProfile = widget.userId == null || widget.userId == myId;
//
//     // 1. KUNCI UTAMA: Kalau bukan profil kita, jangan tampilin tombol apa pun!
//     if (!isOwnProfile) return const SizedBox.shrink();
//
//     // 2. LOGIC DI LIST FOLLOWERS KITA SENDIRI
//     if (isFollowersList) {
//       return IconButton(
//         icon: const Icon(Icons.close, color: Colors.grey, size: 20),
//         onPressed: () => ref
//             .read(
//               DependencyModule.profileViewModelProvider(widget.userId).notifier,
//             )
//             .removeFollower(user.userId), // Pake userId sesuai model Follow lu
//       );
//     }
//
//     // 3. LOGIC DI LIST FOLLOWING KITA SENDIRI
//     // Tombol ini bakal reaktif (berubah Follow <-> Unfollow) karena state di ViewModel
//     return SizedBox(
//       height: 32,
//       child: ElevatedButton(
//         style: ElevatedButton.styleFrom(
//           // Kalau user.isFollowing TRUE -> Warnanya abu (Unfollow)
//           // Kalau user.isFollowing FALSE -> Warnanya primary (Follow)
//           backgroundColor: user.isFollowing
//               ? Colors.grey[200]
//               : AppColors.primary,
//           foregroundColor: user.isFollowing ? Colors.black : Colors.white,
//           elevation: 0,
//           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
//           padding: const EdgeInsets.symmetric(horizontal: 12),
//         ),
//         onPressed: () {
//           // Tembak fungsi toggle yang tadi kita benerin wasFollowing-nya
//           ref
//               .read(
//                 DependencyModule.profileViewModelProvider(
//                   widget.userId,
//                 ).notifier,
//               )
//               .toggleFollowProfile(user.userId);
//         },
//         child: Text(
//           user.isFollowing ? "Unfollow" : "Follow", // Teks berubah otomatis
//           style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
//         ),
//       ),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     ref.listen(DependencyModule.profileViewModelProvider(widget.userId), (
//       prev,
//       next,
//     ) {
//       final data = next.value;
//       if (next is AsyncError) {
//         if (prev is AsyncError && prev?.error == next.error) return;
//         context.showMsg(next.error.toString());
//       }
//
//       if (data != null && data.errorMessage != null) {
//         context.showMsg(data.errorMessage!); // TAMPILIN SNACKBAR!
//
//         // RESET ERROR: Biar pas lu scroll atau rebuild, snackbarnya gak muncul lagi
//         ref
//             .read(
//               DependencyModule.profileViewModelProvider(widget.userId).notifier,
//             )
//             .clearError();
//       }
//     });
//
//     final state = ref.watch(
//       DependencyModule.profileViewModelProvider(widget.userId),
//     );
//
//     final myId = ref
//         .read(DependencyModule.authUseCaseProvider)
//         .getCurrentUser
//         .invoke()
//         ?.id;
//     final targetId = widget.userId ?? myId;
//     final currentLoadedId = state.value?.profile?.id;
//
//     if (!state.isLoading) {
//       // A. Datanya bener-bener kosong (abis di-invalidate)
//       // B. ATAU ID yang lagi tampil beda sama yang diminta (Navigasi antar user)
//       // C. ATAU Datanya ada tapi isinya kosong (Initial state dari build())
//       if (state.value == null || currentLoadedId != targetId) {
//         Future.microtask(() {
//           if (mounted) {
//             ref
//                 .read(
//                   DependencyModule.profileViewModelProvider(
//                     widget.userId,
//                   ).notifier,
//                 )
//                 .init(widget.userId);
//           }
//         });
//       }
//     }
//
//     final String location = GoRouterState.of(context).matchedLocation;
//     final bool isNavMenuRoot = location == AppRoute.menuProfile;
//     final bool canNavigateBack = context.canPop() && !isNavMenuRoot;
//     final bool isOwnProfile = widget.userId == null || widget.userId == myId;
//
//     return DefaultTabController(
//       length: isOwnProfile ? 2 : 1,
//       child: Builder(
//         builder: (context) {
//           if (state.isLoading && !state.hasValue) {
//             return const Scaffold(
//               body: Center(child: CircularProgressIndicator()),
//             );
//           }
//
//           if (state.hasError && !state.hasValue) {
//             return Scaffold(
//               appBar: canNavigateBack
//                   ? AppBar(
//                       leading: const AppBackButton(),
//                       backgroundColor: Colors.transparent,
//                       elevation: 0,
//                     )
//                   : null,
//               body: AppErrorWidget(
//                 errorMessage: state.error.toString(),
//                 onRetry: () => ref
//                     .read(
//                       DependencyModule.profileViewModelProvider(
//                         widget.userId,
//                       ).notifier,
//                     )
//                     .init(widget.userId),
//               ),
//             );
//           }
//
//           final data = state.value ?? ProfileData.empty();
//
//           return _buildProfile(data, isOwnProfile, canNavigateBack);
//         },
//       ),
//     );
//   }
//
//   Widget _buildProfile(ProfileData data, bool isOwn, bool canBack) {
//     return Scaffold(
//       extendBody: true,
//       backgroundColor: AppColors.background,
//       key: ValueKey('profile_${isOwn}_${widget.userId}'),
//       body: SafeArea(
//         bottom: false,
//         child: NestedScrollView(
//           headerSliverBuilder: (context, innerBoxIsScrolled) {
//             return [
//               SliverToBoxAdapter(
//                 child: Padding(
//                   padding: const EdgeInsets.symmetric(horizontal: 16),
//                   child: Column(
//                     children: [
//                       // Back Button — only shown when viewing another user's profile
//                       if (canBack)
//                         const Align(
//                           alignment: Alignment.centerLeft,
//                           child: AppBackButton(),
//                         ),
//
//                       // Profile Header Widget
//                       AppProfileHeader(
//                         username: data.profile?.username ?? "user",
//                         bio: data.profile?.bio ?? "",
//                         imageUrl: data.profile?.photo,
//                         posts: data.profile?.totalPosts ?? 0,
//                         followers: data.profile?.totalFollowers ?? 0,
//                         following: data.profile?.totalFollowings ?? 0,
//                         collections: data.profile?.totalCollections ?? 0,
//                         isOwnProfile: isOwn,
//                         isFollowing: data.profile?.isFollowing ?? false,
//                         onFollowersTap: () {
//                           if ((data.profile?.totalFollowers ?? 0) > 0) {
//                             _showFollowOverlay("Followers", true);
//                           }
//                         },
//                         onFollowingTap: () {
//                           if ((data.profile?.totalFollowings ?? 0) > 0) {
//                             _showFollowOverlay("Following", false);
//                           }
//                         },
//                         onFollow: () {
//                           final profileId = data.profile?.id;
//                           if (profileId != null) {
//                             ref
//                                 .read(
//                                   DependencyModule.profileViewModelProvider(
//                                     widget.userId,
//                                   ).notifier,
//                                 )
//                                 .toggleFollowProfile(profileId);
//                           }
//                         },
//                         onEditProfile: () {
//                           context.push(
//                             AppRoute.editProfile,
//                             extra: {
//                               'existingUsername': data.profile?.username,
//                               'existingBio': data.profile?.bio,
//                               'existingPhotoUrl': data.profile?.photo,
//                             },
//                           );
//                         },
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//               SliverPersistentHeader(
//                 pinned: true,
//                 delegate: _SliverAppBarDelegate(
//                   TabBar(
//                     labelColor: AppColors.primary,
//                     unselectedLabelColor: Colors.grey,
//                     indicatorColor: AppColors.primary,
//                     labelStyle: Theme.of(context).textTheme.bodyMedium
//                         ?.copyWith(fontWeight: FontWeight.bold),
//                     tabs: [
//                       const Tab(text: 'Created'),
//                       if (isOwn) const Tab(text: 'Saved'),
//                     ],
//                   ),
//                 ),
//               ),
//             ];
//           },
//           body: TabBarView(
//             children: [
//               data.posts.isEmpty
//                   ? Center(child: Text("No posts yet"))
//                   : MasonryGridView.count(
//                       physics: const AlwaysScrollableScrollPhysics(),
//                       padding: const EdgeInsets.symmetric(
//                         horizontal: 8,
//                         vertical: 12,
//                       ),
//                       itemCount: data.posts.length,
//                       crossAxisCount: 2,
//                       crossAxisSpacing: 8,
//                       mainAxisSpacing: 8,
//                       itemBuilder: (context, index) {
//                         final post = data.posts[index];
//                         return ImageItem(
//                           postId: post.id,
//                           imageUrl: post.image,
//                           title: post.title,
//                           onTap: () {
//                             context.push(AppRoute.imageDetail, extra: post);
//                           },
//                         );
//                       },
//                     ),
//               // Created Tab
//               if (isOwn) _buildCollectionGrid(data), // Saved Tab
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
//
// class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
//   _SliverAppBarDelegate(this._tabBar);
//
//   final TabBar _tabBar;
//
//   @override
//   double get minExtent => _tabBar.preferredSize.height;
//
//   @override
//   double get maxExtent => _tabBar.preferredSize.height;
//
//   @override
//   Widget build(
//     BuildContext context,
//     double shrinkOffset,
//     bool overlapsContent,
//   ) {
//     return Container(
//       color: AppColors
//           .background, // Kasih background biar gak transparan pas nempel
//       child: _tabBar,
//     );
//   }
//
//   @override
//   bool shouldRebuild(_SliverAppBarDelegate oldDelegate) => false;
// }
