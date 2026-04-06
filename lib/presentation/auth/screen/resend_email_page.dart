import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:imagix/core/theme/app_colors.dart';
import 'package:imagix/core/theme/app_text_styles.dart';
import 'package:imagix/core/utils/helper.dart';
import 'package:imagix/di/dependency_module.dart';
import 'package:imagix/presentation/widgets/app_button.dart';
import 'package:imagix/presentation/widgets/app_text_field.dart';

class ResendEmailPage extends ConsumerStatefulWidget {
  const ResendEmailPage({super.key});

  @override
  ConsumerState<ResendEmailPage> createState() => _ResendEmailPageState();
}

class _ResendEmailPageState extends ConsumerState<ResendEmailPage> {
  final TextEditingController _emailController = TextEditingController();

  String? _getValidationError() {
    final email = _emailController.text.trim();

    if (email.isEmpty) return "Email can not be empty.";
    if (!email.isValidEmail()) return "Email is not valid.";

    return null;
  }

  Future<void> _handleResend() async {
    final error = _getValidationError();

    if (error != null) {
      context.showMsg(error);
      return;
    }

    await ref
        .read(DependencyModule.authViewModelProvider.notifier)
        .resendVerificationEmail(_emailController.text.trim());
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(DependencyModule.authViewModelProvider, (prev, next) {
      next.whenOrNull(
        data: (data) {
          if (data.isSend) {
            context.showMsg(
              "Verification email sent. Please check your inbox.",
            );
            ref
                .read(DependencyModule.authViewModelProvider.notifier)
                .resetSend();
          }
        },
        error: (e, stack) {
          context.showMsg(e.toString());
        },
      );
    });

    final state = ref.watch(DependencyModule.authViewModelProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Resend Email',
                  style: AppTextStyles.header.copyWith(
                    color: Colors.black,
                    fontSize: 23,
                  ),
                ),
                const SizedBox(height: 20),
                AppTextField(
                  hint: 'Email',
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 27),
                AppButton(
                  label: 'Resend',
                  onPressed: state.isLoading ? () {} : _handleResend,
                  variant: AppButtonVariant.filled,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// import 'package:flutter/material.dart';
// import '../../../core/theme/app_colors.dart';
// import '../../../core/theme/app_text_styles.dart';
// import '../../widgets/app_button.dart';
// import '../../widgets/app_text_field.dart';
//
// class ResendEmailPage extends StatefulWidget {
//   const ResendEmailPage({super.key});
//
//   @override
//   State<ResendEmailPage> createState() => _ResendEmailPageState();
// }
//
// class _ResendEmailPageState extends State<ResendEmailPage> {
//   final TextEditingController _emailController = TextEditingController();
//
//   @override
//   void dispose() {
//     _emailController.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: AppColors.background,
//       body: SafeArea(
//         child: Center(
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               // Title
//               Text(
//                 'Resend Email',
//                 style: AppTextStyles.header.copyWith(
//                   color: Colors.black,
//                   fontSize: 23,
//                 ),
//               ),
//
//               const SizedBox(height: 20),
//
//               // Email Field
//               AppTextField(
//                 hint: 'Email',
//                 controller: _emailController,
//                 keyboardType: TextInputType.emailAddress,
//               ),
//
//               const SizedBox(height: 27),
//
//               // Resend Button
//               AppButton(
//                 label: 'Resend',
//                 onPressed: () {
//                   // TODO: handle resend email
//                 },
//                 variant: AppButtonVariant.filled,
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
