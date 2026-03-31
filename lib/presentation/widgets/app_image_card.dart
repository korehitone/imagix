import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../pages/image_details_page.dart';
import '../pages/profile_page.dart';
import 'app_overflow_menu.dart';

class AppDetails extends StatelessWidget {
  final String? imageUrl;
  final String title;
  final String description;

  const AppDetails({
    super.key,
    this.imageUrl,
    this.title = 'Title',
    this.description = 'Description',
  });

  void _openOverflowMenu(BuildContext context) {
    AppOverflowMenu.show(
      context,
      items: [
        AppOverflowMenuItem(
          icon: Icons.image_outlined,
          label: 'View',
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ImageDetailPage(
                imageUrl: imageUrl,
                title: title,
                description: description,
              ),
            ),
          ),
        ),
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
          icon: Icons.edit_outlined,
          label: 'Edit',
          onTap: () {},
        ),
        AppOverflowMenuItem(
          icon: Icons.bookmark_outline,
          label: 'Save',
          onTap: () {},
        ),
        AppOverflowMenuItem(
          icon: Icons.delete_outline,
          label: 'Delete',
          onTap: () {},
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Image Box
        GestureDetector(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ImageDetailPage(
                imageUrl: imageUrl,
                title: title,
                description: description,
              ),
            ),
          ),
          child: Container(
            width: double.infinity,
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
                            color: AppColors.primary.withValues(alpha: 0.4),
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
    Builder(
      builder: (iconContext) => GestureDetector(
        onTap: () => _openOverflowMenu(iconContext),
        child: const Icon(
          Icons.more_horiz,
          color: Colors.black,
          size: 24,
        ),
      ),
    ),
  ],
),
      ],
    );
  }
}