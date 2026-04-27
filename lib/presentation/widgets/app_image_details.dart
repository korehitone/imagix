import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:imagix/app/navigation/app_router.dart';
import 'package:imagix/di/dependency_module.dart';

import '../../core/theme/app_colors.dart';
import 'app_collection_picker_sheet.dart';
import 'app_comment_sheet.dart';

class AppImageActions extends ConsumerWidget {
  final String title;
  final String description;
  final String postId;
  final String ownerId;
  final String? ownerPhoto;
  final String ownerName;
  final VoidCallback? onProfileTap;

  // final ValueChanged<bool>? onLikedChanged;

  const AppImageActions({
    super.key,
    required this.title,
    required this.description,
    required this.postId,
    required this.ownerId,
    this.ownerPhoto,
    required this.ownerName,
    this.onProfileTap,
    // this.isOwner = false,
    // this.onLikedChanged,
  });

  void _showDeletePostConfirmation(
    BuildContext context,
    WidgetRef ref,
    String postId,
  ) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text("Delete Post?"),
        content: const Text("Are you sure want to delete this post?."),
        actions: [
          TextButton(
            onPressed: () => dialogContext.pop(),
            child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () {
              ref
                  .read(
                    DependencyModule.imageDetailViewModelProvider(
                      postId,
                    ).notifier,
                  )
                  .deletePost(postId);

              dialogContext.pop();
            },
            child: const Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(
      DependencyModule.imageDetailViewModelProvider(postId),
    );
    final bool isOwner = state.value?.userId == ownerId;
    final post = state.value?.post;

    final bool isLiked = post?.isLiked ?? false;
    final int likeCount = post?.totalLikes ?? 0;
    final int commentCount = post?.totalComments ?? 0;

    return SizedBox(
      // width: 364,
      width: double.infinity,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Like, Comment, More row
            Row(
              children: [
                GestureDetector(
                  onTap: () {
                    ref
                        .read(
                          DependencyModule.imageDetailViewModelProvider(
                            postId,
                          ).notifier,
                        )
                        .toggleLike(postId);
                  },
                  child: Row(
                    children: [
                      Icon(
                        isLiked ? Icons.favorite : Icons.favorite_border,
                        color: isLiked ? AppColors.primary : Colors.black,
                        size: 28,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '$likeCount',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 16),

                // Comment icon — opens comment sheet directly
                GestureDetector(
                  onTap: () => AppCommentSheet.show(context, ownerId, postId),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.chat_bubble_outline,
                        color: Colors.black,
                        size: 28,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '$commentCount',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),

                const Spacer(),

                if (isOwner) ...[
                  // JIKA OWNER: Edit & Delete Bejejer
                  IconButton(
                    visualDensity: VisualDensity.compact,
                    icon: const Icon(Icons.edit_outlined, color: Colors.black),
                    onPressed: () async {
                      await context.push(
                        AppRoute.createPost,
                        extra: {
                          'isEditMode': true,
                          'postId': postId,
                          'existingTitle': post?.title ?? title,
                          'existingDescription':
                              post?.description ?? description,
                          'existingImageUrl':
                              post?.image, // Biar bisa buat preview
                        },
                      );
                      if (!context.mounted) return;

                      await ref
                          .read(
                            DependencyModule.imageDetailViewModelProvider(
                              postId,
                            ).notifier,
                          )
                          .refreshPost(postId);
                    },
                  ),
                  IconButton(
                    visualDensity: VisualDensity.compact,
                    icon: const Icon(
                      Icons.delete_outline,
                      color: Colors.redAccent,
                    ),
                    onPressed: () {
                      // Logic Delete Lu
                      _showDeletePostConfirmation(context, ref, postId);
                    },
                  ),
                ],
                // JIKA BUKAN OWNER: Bookmark Saja
                IconButton(
                  visualDensity: VisualDensity.compact,
                  icon: const Icon(
                    Icons.bookmark_add_outlined,
                    color: Colors.black,
                  ),
                  onPressed: () async {
                    await ref
                        .read(
                          DependencyModule.imageDetailViewModelProvider(
                            postId,
                          ).notifier,
                        )
                        .fetchUserCollection(postId);
                    if (!context.mounted) return;
                    AppCollectionPickerSheet.show(context, postId);
                  },
                ),
              ],
            ),

            const SizedBox(height: 12),

            _buildUserProfile(context),

            const SizedBox(height: 12),

            // Title
            Text(
              post?.title ?? title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 4),

            // Description
            Text(
              post?.description ?? description,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserProfile(BuildContext context) {
    const double avatarSize = 40;
    return InkWell(
      onTap: onProfileTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            // Avatar dengan Border & Fallback Logic (Persis kayak di Comment)
            Container(
              width: avatarSize,
              height: avatarSize,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.primary, width: 1.5),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(avatarSize / 2),
                child: (ownerPhoto != null)
                    ? Image.network(
                        ownerPhoto!,
                        width: avatarSize,
                        height: avatarSize,
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, progress) {
                          if (progress == null) return child;
                          return const Center(
                            child: SizedBox(
                              width: 15,
                              height: 15,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppColors.primary,
                              ),
                            ),
                          );
                        },
                        errorBuilder: (context, error, stack) => const Icon(
                          Icons.person_outline,
                          size: 20,
                          color: Colors.black,
                        ),
                      )
                    : const Icon(
                        Icons.person_outline,
                        size: 20,
                        color: Colors.black,
                      ),
              ),
            ),
            const SizedBox(width: 12),

            // Username Saja
            Text(
              ownerName,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
