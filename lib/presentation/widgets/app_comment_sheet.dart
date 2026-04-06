import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:imagix/core/utils/helper.dart';
import 'package:imagix/di/dependency_module.dart';
import 'package:imagix/domain/comment/model/comment.dart';
import 'package:imagix/presentation/widgets/app_error_widget.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../../core/theme/app_colors.dart';

// class _CommentData {
//   final String username;
//   final String comment;
//   final String date;
//   final List<_CommentData> replies;
//
//   const _CommentData({
//     required this.username,
//     required this.comment,
//     required this.date,
//     this.replies = const [],
//   });
// }
//
// const List<_CommentData> _dummyComments = [
//   _CommentData(
//     username: 'alice_wonder',
//     comment: 'This is absolutely stunning! Love the composition.',
//     date: '2h ago',
//     replies: [
//       _CommentData(
//         username: 'bob_draws',
//         comment: 'Totally agree, the lighting is perfect!',
//         date: '1h ago',
//       ),
//     ],
//   ),
//   _CommentData(
//     username: 'john_visuals',
//     comment: 'Great work, keep it up!',
//     date: '5h ago',
//     replies: [
//       _CommentData(
//         username: 'sara_art',
//         comment: 'Yes! One of the best I have seen today.',
//         date: '4h ago',
//       ),
//       _CommentData(
//         username: 'mike_snaps',
//         comment: 'Incredible detail in this one.',
//         date: '3h ago',
//       ),
//     ],
//   ),
//   _CommentData(
//     username: 'luna_creative',
//     comment: 'The colors are so vibrant, wow!',
//     date: '1d ago',
//     replies: [],
//   ),
// ];

class AppCommentSheet {
  static void show(BuildContext context, String postOwnerId, String postId) {
    final TextEditingController commentController = TextEditingController();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Consumer(
          builder: (context, ref, child) {
            ref.listen(DependencyModule.imageDetailViewModelProvider(postId), (
              prev,
              next,
            ) {
              if (next is AsyncError) {
                if (prev is AsyncError && prev?.error == next.error) return;

                context.showMsg(next.error.toString());
              }
              final nextData = next.value;
              if (nextData != null && nextData.isSuccess) {
                ref
                    .read(
                      DependencyModule.imageDetailViewModelProvider(
                        postId,
                      ).notifier,
                    )
                    .resetSuccess();
              }
            });

            final state = ref.watch(
              DependencyModule.imageDetailViewModelProvider(postId),
            );
            final data = state.value;
            return DraggableScrollableSheet(
              expand: false,
              initialChildSize: 0.6,
              minChildSize: 0.4,
              maxChildSize: 0.9,
              builder: (context, scrollController) {
                return Scaffold(
                  resizeToAvoidBottomInset: false,
                  body: Padding(
                    padding: EdgeInsets.only(
                      bottom: MediaQuery.of(context).viewInsets.bottom,
                    ),
                    child: Column(
                      children: [
                        // Drag handle
                        Container(
                          width: 40,
                          height: 4,
                          margin: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: Colors.grey.withValues(alpha: 0.4),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),

                        // Title
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              'Comments',
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 8),

                        const Divider(
                          color: AppColors.primary,
                          thickness: 1,
                          height: 1,
                        ),

                        const SizedBox(height: 8),

                        // Comments List
                        Expanded(
                          child: data != null
                              ? (data.comments.isEmpty
                                    ? const Center(
                                        child: Text("No comments yet"),
                                      )
                                    : ListView.builder(
                                        controller: scrollController,
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 16,
                                        ),
                                        itemCount: data.comments.length,
                                        itemBuilder: (context, index) {
                                          final comment = data.comments[index];
                                          return _buildComment(
                                            context,
                                            ref,
                                            comment,
                                            isReply: false,
                                            currentUserId: data.userId,
                                            postOwnerId: postOwnerId,
                                            rootParentId: comment.id,
                                          );
                                        },
                                      ))
                              : state.hasError && !state.isLoading
                              ? AppErrorWidget(
                                  errorMessage: state.error.toString(),
                                  onRetry: () {
                                    ref
                                        .read(
                                          DependencyModule.imageDetailViewModelProvider(
                                            postId,
                                          ).notifier,
                                        )
                                        .fetchComments(postId);
                                  },
                                )
                              : const Center(
                                  child: CircularProgressIndicator(),
                                ),
                        ),

                        const Divider(
                          color: AppColors.primary,
                          thickness: 1,
                          height: 1,
                        ),

                        state.maybeWhen(
                          data: (data) {
                            if (data.replyingToName == null) {
                              return const SizedBox.shrink();
                            }
                            return Container(
                              width: double.infinity,
                              color: Colors.grey[100],
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              child: Row(
                                children: [
                                  Text(
                                    "Replying to @${data.replyingToName}",
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.blueGrey,
                                    ),
                                  ),
                                  const Spacer(),
                                  GestureDetector(
                                    onTap: () => ref
                                        .read(
                                          DependencyModule.imageDetailViewModelProvider(
                                            postId,
                                          ).notifier,
                                        )
                                        .cancelReply(),
                                    child: const Icon(
                                      Icons.close,
                                      size: 16,
                                      color: Colors.red,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                          orElse: () => const SizedBox.shrink(),
                        ),
                        const SizedBox(height: 16),

                        //
                        Container(
                          padding: EdgeInsets.fromLTRB(
                            16,
                            8,
                            16,
                            24,
                          ), // Kasih space bawah biar gak mepet home bar
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border(
                              top: BorderSide(color: Colors.grey[200]!),
                            ),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            // Biar sejajar bawah kalo text-nya panjang
                            children: [
                              // Input Field (Pake Expanded biar dia makan sisa tempat)
                              Expanded(
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.grey[100],
                                    borderRadius: BorderRadius.circular(
                                      24,
                                    ), // Bikin rounded biar kekinian
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                  ),
                                  child: TextField(
                                    controller: commentController,
                                    maxLines: 4,
                                    minLines: 1,
                                    decoration: const InputDecoration(
                                      hintText: 'Add a comment...',
                                      border: InputBorder.none,
                                      hintStyle: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey,
                                      ),
                                    ),
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                ),
                              ),

                              const SizedBox(width: 12),

                              // TOMBOL POST MODERN (Cuma teks)
                              ValueListenableBuilder<TextEditingValue>(
                                valueListenable: commentController,
                                builder: (context, value, child) {
                                  final isNotEmpty = value.text
                                      .trim()
                                      .isNotEmpty;
                                  return GestureDetector(
                                    onTap: isNotEmpty
                                        ? () {
                                            final text = commentController.text
                                                .trim();
                                            ref
                                                .read(
                                                  DependencyModule.imageDetailViewModelProvider(
                                                    postId,
                                                  ).notifier,
                                                )
                                                .submitComment(postId, text);
                                            commentController.clear();
                                            FocusScope.of(
                                              context,
                                            ).unfocus(); // Tutup keyboard abis post
                                          }
                                        : null,
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 10,
                                      ),
                                      child: Text(
                                        'Post',
                                        style: TextStyle(
                                          color: isNotEmpty
                                              ? AppColors.primary
                                              : Colors.grey[400],
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15,
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                        // Comment Text Field
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  static Widget _buildComment(
    BuildContext context,
    WidgetRef ref,
    Comment comment, {
    required bool isReply,
    required String? currentUserId, // Tambahin ini
    required String postOwnerId,
    int? rootParentId,
  }) {
    final double avatarSize = isReply ? 28 : 36;
    final bool isMyComment = comment.userId == currentUserId;
    final bool isPostOwner = postOwnerId == currentUserId;
    final bool canDelete = isMyComment || isPostOwner;
    final int effectiveParentId = rootParentId ?? comment.id;

    return Padding(
      padding: EdgeInsets.only(left: isReply ? 40 : 0, bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profile Avatar
              Container(
                width: avatarSize,
                height: avatarSize,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.primary, width: 1.5),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(avatarSize / 2),
                  child:
                      (comment.userPhoto != null &&
                          comment.userPhoto!.isNotEmpty)
                      ? Image.network(
                          comment.userPhoto!,
                          width: avatarSize,
                          // Samain ukurannya
                          height: avatarSize,
                          // Samain ukurannya
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, progress) {
                            if (progress == null) return child;
                            return const Center(
                              child: SizedBox(
                                width: 15,
                                height: 15,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              ),
                            );
                          },
                          errorBuilder: (context, error, stack) => Icon(
                            Icons.person_outline,
                            size: isReply ? 16 : 20, // Ukuran ikon juga dinamis
                            color: Colors.black,
                          ),
                        )
                      : Icon(
                          Icons.person_outline,
                          size: isReply ? 16 : 20,
                          color: Colors.black,
                        ),
                ),
              ),

              const SizedBox(width: 10),

              // Comment Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Username + Date
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          comment.username,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        Text(
                          timeago.format(comment.createdAt),
                          style: Theme.of(
                            context,
                          ).textTheme.bodySmall?.copyWith(color: Colors.grey),
                        ),
                      ],
                    ),

                    const SizedBox(height: 4),

                    // Comment Text
                    Text(
                      comment.comment,
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: Colors.black),
                    ),

                    const SizedBox(height: 4),

                    // Reply Button
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // if (!isReply)
                        GestureDetector(
                          onTap: () {
                            ref
                                .read(
                                  DependencyModule.imageDetailViewModelProvider(
                                    comment.postId,
                                  ).notifier,
                                )
                                .setReplyingTo(
                                  effectiveParentId,
                                  comment.username,
                                );
                          },
                          child: Text(
                            'Reply',
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ),
                        if (canDelete)
                          SizedBox(
                            width: 24,
                            height: 24,
                            child: PopupMenuButton<String>(
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(maxWidth: 100),
                              icon: const Icon(
                                Icons.more_vert,
                                size: 18,
                                color: Colors.grey,
                              ),
                              onSelected: (value) {
                                if (value == 'delete') {
                                  _showDeleteConfirmation(
                                    context,
                                    ref,
                                    comment.id,
                                    comment.postId,
                                  );
                                }
                              },
                              itemBuilder: (context) => [
                                const PopupMenuItem(
                                  value: 'delete',
                                  height: 35,
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.delete_outline,
                                        size: 18,
                                        color: Colors.red,
                                      ),
                                      SizedBox(width: 8),
                                      Text(
                                        'Delete',
                                        style: TextStyle(
                                          color: Colors.red,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          )
                        else
                          const SizedBox.shrink(),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),

          // Replies
          if (comment.replies.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Column(
                children: comment.replies
                    .map(
                      (reply) => _buildComment(
                        context,
                        ref,
                        reply,
                        isReply: true,
                        currentUserId: currentUserId,
                        postOwnerId: postOwnerId,
                        rootParentId: effectiveParentId,
                      ),
                    )
                    .toList(),
              ),
            ),
        ],
      ),
    );
  }

  static void _showDeleteConfirmation(
    BuildContext context,
    WidgetRef ref,
    int commentId,
    String postId,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Comment?"),
        content: const Text("Are you sure want to delete this comment?."),
        actions: [
          TextButton(
            onPressed: () => context.pop(),
            child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () {
              // Panggil logic delete di ViewModel lewat Notifier
              ref
                  .read(
                    DependencyModule.imageDetailViewModelProvider(
                      postId,
                    ).notifier,
                  )
                  .deleteComment(commentId, postId);
              context.pop();
            },
            child: const Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
