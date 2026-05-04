import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:imagix/app/navigation/app_router.dart';
import 'package:imagix/di/dependency_module.dart';
import 'package:imagix/presentation/auth/viewmodel/data/auth_data.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/helper.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_text_field.dart';

class SignUpPage extends ConsumerStatefulWidget {
  const SignUpPage({super.key});

  @override
  ConsumerState<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends ConsumerState<SignUpPage> {
  final _emailController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  void _clearFields() {
    _emailController.clear();
    _usernameController.clear();
    _passwordController.clear();
    _confirmPasswordController.clear();
  }

  String? _getValidationError() {
    final email = _emailController.text.trim();
    final username = _usernameController.text.trim();
    final password = _passwordController.text.trim();
    final confirm = _confirmPasswordController.text.trim();

    if (email.isEmpty) return "Email can not be empty.";
    if (!email.isValidEmail()) return "Email is not valid.";
    if (username.isEmpty) return "Username can not be empty.";
    if (!username.isValidUsername()) {
      return "Username can only contain letters, numbers, underscore (_) and dot (.).";
    }
    if (password.isEmpty) return "Password can not be empty.";
    if (confirm.isEmpty) return "Confirm Password can not be empty.";
    if (password != confirm) return "Passwords do not match!";

    return null; // Artinya lolos sensor
  }

  void _handleSignUp() {
    final error = _getValidationError();

    if (error != null) {
      context.showMsg(error);
      return;
    }

    ref
        .read(DependencyModule.authViewModelProvider.notifier)
        .register(
          _emailController.text.trim(),
          _passwordController.text.trim(),
          _usernameController.text.trim(),
        );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AsyncValue<AuthData>>(DependencyModule.authViewModelProvider, (
      prev,
      next,
    ) {
      next.whenOrNull(
        data: (data) {
          if (data.isSuccess) {
            _clearFields();

            ref
                .read(DependencyModule.authViewModelProvider.notifier)
                .resetSuccess();

            context.showMsg(
              "We've sent a confirmation link to your email. Please check your inbox and spam folder.",
            );

            context.go(AppRoute.login);
          }
        },
        error: (e, stack) {
          _passwordController.clear();
          _confirmPasswordController.clear();
          context.showMsg(e.toString());
          // ScaffoldMessenger.of(
          //   context,
          // ).showSnackBar(SnackBar(content: Text(e.toString())));
        },
      );
    });

    final authState = ref.watch(DependencyModule.authViewModelProvider);
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 36.0),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight:
                  MediaQuery.of(context).size.height -
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
                    controller: _emailController,
                    hint: 'Email',
                    keyboardType: TextInputType.emailAddress,
                  ),

                  const SizedBox(height: 20),

                  // Username
                  AppTextField(
                    controller: _usernameController,
                    hint: 'Username',
                  ),

                  const SizedBox(height: 20),

                  // Password
                  AppTextField(
                    controller: _passwordController,
                    hint: 'Password',
                    obscureText: true,
                  ),

                  const SizedBox(height: 20),

                  // Confirm Password
                  AppTextField(
                    controller: _confirmPasswordController,
                    hint: 'Confirm Password',
                    obscureText: true,
                  ),

                  const SizedBox(height: 27),

                  // Sign Up Button
                  AppButton(
                    label: 'Sign Up',
                    onPressed: authState.isLoading ? () {} : _handleSignUp,
                    variant: AppButtonVariant.filled,
                  ),

                  const SizedBox(height: 24),

                  // Already have an account
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Already have an account? ',
                        style: AppTextStyles.caption.copyWith(
                          color: Colors.grey,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          context.go(AppRoute.login);
                        },
                        child: Text(
                          'Log In',
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
