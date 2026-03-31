import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../pages/collections_page.dart';
import 'app_overflow_menu.dart';

class AppCollectionCard extends StatelessWidget {
  final String? imageUrl;
  final String title;

  const AppCollectionCard({
    super.key,
    this.imageUrl,
    this.title = 'Title',
  });

  void _openOverflowMenu(BuildContext context) {
  AppOverflowMenu.show(
    context,
    items: [
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
  );
}

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Collection Image Box
        GestureDetector(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => CollectionsPage(collectionName: title),
            ),
          ),
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