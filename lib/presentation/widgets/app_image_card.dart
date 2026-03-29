import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class AppDetails extends StatelessWidget {
  final String? imageUrl;
  final String title;
  final VoidCallback? onTap;
  final VoidCallback? onMore;

  const AppDetails({
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
        // Image Box
        GestureDetector(
          onTap: onTap,
          child: Container(
            width: double.infinity, // ← let grid handle width
            height: 285,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: AppColors.primary, width: 2),
            ),
            child: imageUrl != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(2),
                    child: Image.network(
                      imageUrl!,
                      fit: BoxFit.cover,
                    ),
                  )
                : Center(
                    child: Text(
                      'Image',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.primary.withOpacity(0.4),
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