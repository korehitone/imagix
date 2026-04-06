import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:imagix/app/navigation/app_router.dart';
import 'package:imagix/core/theme/app_colors.dart';
import 'package:imagix/core/theme/app_text_styles.dart';
import 'package:imagix/core/utils/helper.dart';
import 'package:imagix/di/dependency_module.dart';
import 'package:imagix/presentation/widgets/app_button.dart';

class RestoreAccountPage extends ConsumerStatefulWidget {
  const RestoreAccountPage({super.key});

  @override
  ConsumerState<RestoreAccountPage> createState() => _RestoreAccountPageState();
}

class _RestoreAccountPageState extends ConsumerState<RestoreAccountPage> {
  bool _isSubmitting = false;

  Future<void> _handleRestore() async {
    if (_isSubmitting) return;

    setState(() {
      _isSubmitting = true;
    });

    final ok = await ref
        .read(DependencyModule.authViewModelProvider.notifier)
        .restoreAccount();

    if (!mounted) return;

    setState(() {
      _isSubmitting = false;
    });

    if (ok) {
      context.showMsg('Account restored. Please log in again.');
      context.go(AppRoute.login);
    }
  }

  Future<void> _handleCancel() async {
    if (_isSubmitting) return;

    setState(() {
      _isSubmitting = true;
    });

    await ref.read(DependencyModule.authViewModelProvider.notifier).logout();

    if (!mounted) return;

    setState(() {
      _isSubmitting = false;
    });

    context.go(AppRoute.login);
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(DependencyModule.authViewModelProvider, (prev, next) {
      next.whenOrNull(
        error: (e, stack) {
          context.showMsg(e.toString());
        },
      );
    });

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
                  Icons.person_off_outlined,
                  size: 72,
                  color: AppColors.primary,
                ),
                const SizedBox(height: 20),
                Text(
                  'Account Deleted',
                  style: AppTextStyles.header.copyWith(
                    color: Colors.black,
                    fontSize: 26,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  'This account is scheduled for deletion. You can restore it and then sign in again.',
                  style: AppTextStyles.caption.copyWith(
                    color: Colors.grey[700],
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 28),
                AppButton(
                  label: _isSubmitting ? 'Please wait...' : 'Restore Account',
                  onPressed: _isSubmitting ? () {} : _handleRestore,
                  variant: AppButtonVariant.filled,
                ),
                const SizedBox(height: 12),
                AppButton(
                  label: 'Cancel',
                  onPressed: _isSubmitting ? () {} : _handleCancel,
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
