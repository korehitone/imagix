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
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary, width: 2),
      ),
      child: Row(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: 16),
              child: TextField(
                controller: controller,
                cursorColor: AppColors.primary,
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
                decoration: InputDecoration(
                  hintText: hint,
                  hintStyle: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                  ),
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ),
          GestureDetector(
            onTap: onSearchTap,
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 12),
              child: Icon(Icons.search, color: AppColors.primary, size: 24),
            ),
          ),
        ],
      ),
    );
  }
}
