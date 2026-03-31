import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class AppBackButton extends StatelessWidget {
  const AppBackButton({super.key});

  @override
  Widget build(BuildContext context) {
    final canPop = ModalRoute.of(context)?.canPop ?? false;

    if (!canPop) return const SizedBox.shrink();

    return GestureDetector(
      onTap: () => Navigator.of(context).pop(),
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.secondary, width: 2),
        ),
        child: const Icon(
          Icons.chevron_left,
          color: Colors.black,
          size: 24,
        ),
      ),
    );
  }
}