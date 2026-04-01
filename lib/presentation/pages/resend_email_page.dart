import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../widgets/app_button.dart';
import '../widgets/app_text_field.dart';

class ResendEmailPage extends StatefulWidget {
  const ResendEmailPage({super.key});

  @override
  State<ResendEmailPage> createState() => _ResendEmailPageState();
}

class _ResendEmailPageState extends State<ResendEmailPage> {
  final TextEditingController _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Title
              Text(
                'Resend Email',
                style: AppTextStyles.header.copyWith(
                  color: Colors.black,
                  fontSize: 23,
                ),
              ),

              const SizedBox(height: 20),

              // Email Field
              AppTextField(
                hint: 'Email',
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
              ),

              const SizedBox(height: 27),

              // Resend Button
              AppButton(
                label: 'Resend',
                onPressed: () {
                  // TODO: handle resend email
                },
                variant: AppButtonVariant.filled,
              ),
            ],
          ),
        ),
      ),
    );
  }
}