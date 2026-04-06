import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:imagix/app/navigation/app_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/helper.dart';
import '../../../di/dependency_module.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_text_field.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  void _clearFields() {
    _emailController.clear();
    _passwordController.clear();
  }

  String? _getValidationError() {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty) return "Email can not be empty.";
    if (!email.isValidEmail()) return "Email is not valid.";
    if (password.isEmpty) return "Password can not be empty.";

    return null;
  }

  void _handleLogin() {
    final error = _getValidationError();

    if (error != null) {
      context.showMsg(error);
      return;
    }

    ref
        .read(DependencyModule.authViewModelProvider.notifier)
        .login(_emailController.text.trim(), _passwordController.text.trim());
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(DependencyModule.authViewModelProvider, (prev, next) {
      next.whenOrNull(
        data: (data) {
          if (data.isDeletedAccount) {
            context.go(AppRoute.restoreAccount);
            return;
          }
          if (data.isSuccess) {
            _clearFields();
            ref
                .read(DependencyModule.authViewModelProvider.notifier)
                .resetSuccess();
            context.go(AppRoute.home);
          }
        },
        error: (e, stack) {
          _passwordController.clear();
          context.showMsg(e.toString());
          // ScaffoldMessenger.of(
          //   context,
          // ).showSnackBar(SnackBar(content: Text(e.toString())));
        },
      );
    });

    final state = ref.watch(DependencyModule.authViewModelProvider);

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

                  // Password
                  AppTextField(
                    controller: _passwordController,
                    hint: 'Password',
                    obscureText: true,
                  ),

                  const SizedBox(height: 27),

                  // Login Button
                  AppButton(
                    label: 'Login',
                    onPressed: state.isLoading ? () {} : _handleLogin,
                    variant: AppButtonVariant.filled,
                  ),

                  const SizedBox(height: 12),

                  GestureDetector(
                    onTap: () {
                      context.go(AppRoute.resendEmail);
                    },
                    child: Text(
                      'Resend verification email',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
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
                          context.go(AppRoute.signup);
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
