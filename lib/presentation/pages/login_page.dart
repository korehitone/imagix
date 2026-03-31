import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../widgets/app_button.dart';
import '../widgets/app_text_field.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 36.0),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height -
                  MediaQuery.of(context).padding.top -
                  MediaQuery.of(context).padding.bottom,
            ),
            child: IntrinsicHeight(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Title
                  Text(
                    'IMAGIX',
                    style: AppTextStyles.header.copyWith(
                      color: AppColors.primary,
                    ),
                  ),

                  const SizedBox(height: 3),

                  // Logo
                  SvgPicture.asset(
                    'assets/logo/imagix-icon.svg',
                    width: 160,
                    height: 160,
                  ),

                  const SizedBox(height: 62),

                  // Email
                  AppTextField(
                    hint: 'Email',
                    keyboardType: TextInputType.emailAddress,
                  ),

                  const SizedBox(height: 20),

                  // Password
                  const AppTextField(
                    hint: 'Password',
                    obscureText: true,
                  ),

                  const SizedBox(height: 27),

                  // Login Button
                  AppButton(
                    label: 'Login',
                    onPressed: () {
                      // TODO: handle login
                    },
                    variant: AppButtonVariant.filled,
                  ),

                  const SizedBox(height: 24),

                  // Don't have an account
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Don't have an account? ",
                        style: AppTextStyles.caption.copyWith(
                          color: Colors.grey,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          // TODO: Navigate to sign up page
                        },
                        child: Text(
                          'Sign Up',
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}