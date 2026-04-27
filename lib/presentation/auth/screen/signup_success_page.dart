import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:imagix/app/navigation/app_router.dart';
import 'package:imagix/core/theme/app_colors.dart';
import 'package:imagix/core/theme/app_text_styles.dart';
import 'package:imagix/di/dependency_module.dart';
import 'package:imagix/presentation/common/invalid_route_page.dart';
import 'package:imagix/presentation/widgets/app_button.dart';

class SignUpSuccessPage extends ConsumerStatefulWidget {
  final String email;

  const SignUpSuccessPage({super.key, required this.email});

  @override
  ConsumerState<SignUpSuccessPage> createState() => _SignUpSuccessPageState();
}

class _SignUpSuccessPageState extends ConsumerState<SignUpSuccessPage> {
  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      ref.read(DependencyModule.authViewModelProvider.notifier).resetSuccess();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.email.trim().isEmpty) {
      return const InvalidRoutePage(message: 'Missing signup email.');
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.mark_email_read_outlined,
                  size: 72,
                  color: AppColors.primary,
                ),
                const SizedBox(height: 20),
                Text(
                  'Verify Your Email',
                  style: AppTextStyles.header.copyWith(
                    color: Colors.black,
                    fontSize: 28,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  'We sent a confirmation link to:',
                  style: AppTextStyles.caption.copyWith(
                    color: Colors.grey[700],
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  widget.email,
                  style: AppTextStyles.caption.copyWith(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  'Please check your inbox and spam folder, then tap the link in the email to continue.',
                  style: AppTextStyles.caption.copyWith(
                    color: Colors.grey[700],
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 28),
                AppButton(
                  label: 'Go to Login',
                  onPressed: () {
                    context.go(AppRoute.login);
                  },
                  variant: AppButtonVariant.filled,
                  width: double.infinity,
                ),
                const SizedBox(height: 12),
                AppButton(
                  label: 'Resend Email',
                  onPressed: () {
                    context.go(
                      AppRoute.resendEmail,
                      extra: {'email': widget.email},
                    );
                  },
                  variant: AppButtonVariant.outlined,
                  width: double.infinity,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
