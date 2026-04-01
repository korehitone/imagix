import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../pages/profile_page.dart';
import 'app_comment_sheet.dart';
import 'app_overflow_menu.dart';
import 'app_collection_picker_sheet.dart';

class AppImageActions extends StatefulWidget {
  final String title;
  final String description;
  final bool isOwner;
  final ValueChanged<bool>? onLikedChanged;

  const AppImageActions({
    super.key,
    required this.title,
    required this.description,
    this.isOwner = false,
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

  void _openOverflowMenu(BuildContext context) {
    AppOverflowMenu.show(
      context,
      items: [
        // Owner only
        if (widget.isOwner) ...[
          AppOverflowMenuItem(
            icon: Icons.edit_outlined,
            label: 'Edit',
            onTap: () {},
          ),
          AppOverflowMenuItem(
            icon: Icons.delete_outline,
            label: 'Delete',
            onTap: () {},
          ),
        ],
        // Non-owner only
        if (!widget.isOwner) ...[
          AppOverflowMenuItem(
            icon: Icons.person_outline,
            label: 'Profile',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const ProfilePage(isOwnProfile: false),
              ),
            ),
          ),
          AppOverflowMenuItem(
            icon: Icons.bookmark_outline,
            label: 'Save',
            onTap: () => AppCollectionPickerSheet.show(context),
          ),
        ],
      ],
    );
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

                // Builder gives ellipsis its own local context
                Builder(
                  builder: (btnContext) => GestureDetector(
                    onTap: () => _openOverflowMenu(btnContext),
                    child: const Icon(
                      Icons.more_horiz,
                      color: Colors.black,
                      size: 28,
                    ),
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