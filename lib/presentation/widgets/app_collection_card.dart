import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

class AppCollectionCard extends StatelessWidget {
  final String title;
  final String? coverImage;
  final int totalItems;
  final VoidCallback? onTap;

  const AppCollectionCard({
    super.key,
    required this.title,
    this.coverImage,
    this.totalItems = 0,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      // ==========================================
      // TAP COLLECTION CARD
      // navigasi dikontrol dari luar
      // ==========================================
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ==========================================
          // COVER IMAGE
          // ==========================================
          Container(
            width: double.infinity,
            height: 120,
            decoration: BoxDecoration(
              color: AppColors.secondary,
              borderRadius: BorderRadius.circular(12),
            ),
            child: coverImage != null && coverImage!.isNotEmpty
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      coverImage!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return _buildPlaceholder();
                      },
                    ),
                  )
                : _buildPlaceholder(),
          ),

          const SizedBox(height: 8),

          // ==========================================
          // TITLE
          // ==========================================
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 2),

          // ==========================================
          // TOTAL ITEMS
          // ==========================================
          Text(
            '$totalItems item${totalItems == 1 ? '' : 's'}',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.secondary, AppColors.primary],
        ),
      ),
      child: const Center(
        child: Icon(Icons.collections_outlined, color: Colors.white, size: 36),
      ),
    );
  }
}
