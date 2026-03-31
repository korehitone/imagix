import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import 'app_button.dart';
import 'app_text_field.dart';

class _CommentData {
  final String username;
  final String comment;
  final String date;
  final List<_CommentData> replies;

  const _CommentData({
    required this.username,
    required this.comment,
    required this.date,
    this.replies = const [],
  });
}

const List<_CommentData> _dummyComments = [
  _CommentData(
    username: 'alice_wonder',
    comment: 'This is absolutely stunning! Love the composition.',
    date: '2h ago',
    replies: [
      _CommentData(
        username: 'bob_draws',
        comment: 'Totally agree, the lighting is perfect!',
        date: '1h ago',
      ),
    ],
  ),
  _CommentData(
    username: 'john_visuals',
    comment: 'Great work, keep it up!',
    date: '5h ago',
    replies: [
      _CommentData(
        username: 'sara_art',
        comment: 'Yes! One of the best I have seen today.',
        date: '4h ago',
      ),
      _CommentData(
        username: 'mike_snaps',
        comment: 'Incredible detail in this one.',
        date: '3h ago',
      ),
    ],
  ),
  _CommentData(
    username: 'luna_creative',
    comment: 'The colors are so vibrant, wow!',
    date: '1d ago',
    replies: [],
  ),
];

class AppCommentSheet {
  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.6,
          minChildSize: 0.4,
          maxChildSize: 0.9,
          builder: (context, scrollController) {
            return Padding(
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
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
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
                    child: ListView.builder(
                      controller: scrollController,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: _dummyComments.length,
                      itemBuilder: (context, index) {
                        return _buildComment(
                          context,
                          _dummyComments[index],
                          isReply: false,
                        );
                      },
                    ),
                  ),

                  const Divider(
                    color: AppColors.primary,
                    thickness: 1,
                    height: 1,
                  ),

                  const SizedBox(height: 16),

                  // Comment Text Field
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: AppTextField(
                      hint: 'Write a comment...',
                      width: double.infinity,
                      height: 49,
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Submit Button
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: AppButton(
                      label: 'Post Comment',
                      onPressed: () {
                        // TODO: handle post comment
                        Navigator.pop(context);
                      },
                      variant: AppButtonVariant.filled,
                      width: double.infinity,
                    ),
                  ),

                  const SizedBox(height: 16),
                ],
              ),
            );
          },
        );
      },
    );
  }

  static Widget _buildComment(
    BuildContext context,
    _CommentData comment, {
    required bool isReply,
  }) {
    return Padding(
      padding: EdgeInsets.only(
        left: isReply ? 40 : 0,
        bottom: 12,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profile Avatar
              Container(
                width: isReply ? 28 : 36,
                height: isReply ? 28 : 36,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.primary, width: 1.5),
                ),
                child: Icon(
                  Icons.person_outline,
                  size: isReply ? 16 : 20,
                  color: Colors.black,
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
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        Text(
                          comment.date,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Colors.grey,
                              ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 4),

                    // Comment Text
                    Text(
                      comment.comment,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.black,
                          ),
                    ),

                    const SizedBox(height: 4),

                    // Reply Button
                    if (!isReply)
                      GestureDetector(
                        onTap: () {
                          // TODO: handle reply
                        },
                        child: Text(
                          'Reply',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
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
                    .map((reply) => _buildComment(
                          context,
                          reply,
                          isReply: true,
                        ))
                    .toList(),
              ),
            ),
        ],
      ),
    );
  }
}