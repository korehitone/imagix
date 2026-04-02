import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../widgets/app_button.dart';
import 'package:flutter_svg/flutter_svg.dart';

class FirstPage extends StatelessWidget {
  const FirstPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 36.0),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Title
                Text(
                  'IMAGIX',
                  style: AppTextStyles.header.copyWith(
                    color: AppColors.primary,
                  ),
                ),

                const SizedBox(height: 16),

                // Logo
                SvgPicture.asset(
                  'assets/logo/imagix-icon.svg',
                  width: 160,
                  height: 160,
                ),

                const SizedBox(height: 62),

                // Log In Button
                AppButton(
                  label: 'Log In',
                  onPressed: () {},
                  variant: AppButtonVariant.filled,
                ),

                const SizedBox(height: 27),

                // Sign Up Button
                AppButton(
                  label: 'Sign Up',
                  onPressed: () {},
                  variant: AppButtonVariant.outlined,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}