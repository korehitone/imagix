import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../widgets/app_button.dart';
import '../widgets/app_text_field.dart';

class SignUpPage extends StatelessWidget {
  const SignUpPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 36.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 48),

              // Title
              Text(
                'IMAGIX',
                style: AppTestStyles.header.copyWith(
                  color: AppColors.primary,
                  fontSize: 40,
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

              // Username
              AppTextField(
                hint: 'Username',
              ),

              const SizedBox(height: 20),

              // Password
              AppTextField(
                hint: 'Password',
                obscureText: true,
              ),

              const SizedBox(height: 20),

              // Confirm Password
              AppTextField(
                hint: 'Confirm Password',
                obscureText: true,
              ),

              const SizedBox(height: 27),

              // Sign Up Button
              AppButton(
                label: 'Sign Up',
                onPressed: () {
                  // TODO: handle sign up
                },
                variant: AppButtonVariant.filled,
              ),

              const SizedBox(height: 24),

              // Already have an account
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Already have an account? ',
                    style: AppTestStyles.caption.copyWith(color: Colors.grey),
                  ),
                  GestureDetector(
                    onTap: () {
                      // TODO: Navigate to login page
                    },
                    child: Text(
                      'Log In',
                      style: AppTestStyles.caption.copyWith(
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
    );
  }
}