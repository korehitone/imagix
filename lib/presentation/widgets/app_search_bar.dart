import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class AppSearchBar extends StatelessWidget {
  final TextEditingController? controller;
  final String hint;
  final VoidCallback? onSearchTap;

  const AppSearchBar({
    super.key,
    this.controller,
    this.hint = 'Hinted search text',
    this.onSearchTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          // Text Field
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: 16),
              child: TextField(
                controller: controller,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.white,
                    ),
                decoration: InputDecoration(
                  hintText: hint,
                  hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.white.withOpacity(0.7),
                      ),
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ),
          ),

          // Search Icon
          GestureDetector(
            onTap: onSearchTap,
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 12),
              child: Icon(Icons.search, color: Colors.white, size: 24),
            ),
          ),
        ],
      ),
    );
  }
}