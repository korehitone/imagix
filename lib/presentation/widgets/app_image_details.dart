import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import 'app_comment_sheet.dart';

class AppImageActions extends StatefulWidget {
  final String title;
  final String description;
  final VoidCallback? onMoreTap;
  final ValueChanged<bool>? onLikedChanged;

  const AppImageActions({
    super.key,
    required this.title,
    required this.description,
    this.onMoreTap,
    this.onLikedChanged,
  });

  @override
  State<AppImageActions> createState() => _AppImageActionsState();
}

class _AppImageActionsState extends State<AppImageActions> {
  bool _liked = false;

  void _toggleLike() {
    setState(() => _liked = !_liked);
    widget.onLikedChanged?.call(_liked);
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 364,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Like, Comment, More row
            Row(
              children: [
                GestureDetector(
                  onTap: _toggleLike,
                  child: Icon(
                    _liked ? Icons.thumb_up : Icons.thumb_up_outlined,
                    color: _liked ? AppColors.primary : Colors.black,
                    size: 28,
                  ),
                ),

                const SizedBox(width: 16),

                // Comment icon — opens comment sheet directly
                GestureDetector(
                  onTap: () => AppCommentSheet.show(context),
                  child: const Icon(
                    Icons.chat_bubble_outline,
                    color: Colors.black,
                    size: 28,
                  ),
                ),

                const Spacer(),

                GestureDetector(
                  onTap: widget.onMoreTap,
                  child: const Icon(
                    Icons.more_horiz,
                    color: Colors.black,
                    size: 28,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Title
            Text(
              widget.title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
            ),

            const SizedBox(height: 4),

            // Description
            Text(
              widget.description,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}