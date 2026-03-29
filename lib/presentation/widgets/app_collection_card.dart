import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class AppCollectionCard extends StatelessWidget {
  final String? imageUrl;
  final String title;
  final VoidCallback? onTap;
  final VoidCallback? onMore;

  const AppCollectionCard({
    super.key,
    this.imageUrl,
    this.title = 'Title',
    this.onTap,
    this.onMore,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Collection Image Box
        GestureDetector(
          onTap: onTap,
          child: Container(
            width: double.infinity,
            height: 120,
            decoration: BoxDecoration(
              color: AppColors.secondary,
              borderRadius: BorderRadius.circular(4),
            ),
            child: imageUrl != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: Image.network(
                      imageUrl!,
                      fit: BoxFit.cover,
                    ),
                  )
                : Center(
                    child: Text(
                      'Collections',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.white,
                          ),
                    ),
                  ),
          ),
        ),

        const SizedBox(height: 7),

        // Title + Ellipsis
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            GestureDetector(
              onTap: onMore,
              child: const Icon(
                Icons.more_horiz,
                color: Colors.black,
                size: 24,
              ),
            ),
          ],
        ),
      ],
    );
  }
}