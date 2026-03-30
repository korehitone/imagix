import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class AppImageBox extends StatelessWidget {
  final String? imageUrl;
  final double? width;
  final double? height;
  final VoidCallback? onTap;

  const AppImageBox({
    super.key,
    this.imageUrl,
    this.width,
    this.height,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: AppColors.primary, width: 2),
        ),
        child: imageUrl != null
            ? ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.network(
                  imageUrl!,
                  fit: BoxFit.cover,
                ),
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.image_outlined,
                    color: AppColors.primary.withValues(alpha: 0.4),
                    size: 32,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'image',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.primary.withValues(alpha: 0.4),
                        ),
                  ),
                ],
              ),
      ),
    );
  }
}