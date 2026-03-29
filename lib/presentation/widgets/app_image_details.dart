import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class AppImageActions extends StatefulWidget {
  final String title;
  final String description;

  const AppImageActions({
    super.key,
    required this.title,
    required this.description,
  });

  @override
  State<AppImageActions> createState() => _AppImageActionsState();
}

class _AppImageActionsState extends State<AppImageActions> {
  bool _liked = false;

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
                  onTap: () => setState(() => _liked = !_liked),
                  child: Icon(
                    _liked ? Icons.thumb_up : Icons.thumb_up_outlined,
                    color: _liked ? AppColors.primary : Colors.black,
                    size: 28,
                  ),
                ),

                const SizedBox(width: 16),

                GestureDetector(
                  onTap: () {},
                  child: const Icon(
                    Icons.chat_bubble_outline,
                    color: Colors.black,
                    size: 28,
                  ),
                ),

                const Spacer(),

                GestureDetector(
                  onTap: () {},
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