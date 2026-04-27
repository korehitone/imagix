import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:imagix/app/navigation/app_router.dart';
import 'package:imagix/core/theme/app_colors.dart';
import 'package:imagix/presentation/widgets/app_back_button.dart';

class InvalidRoutePage extends StatelessWidget {
  final String message;

  const InvalidRoutePage({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    final canGoBack = context.canPop();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: canGoBack
                    ? const AppBackButton()
                    : TextButton(
                        onPressed: () => context.go(AppRoute.home),
                        child: const Text('Go Home'),
                      ),
              ),
              const Spacer(),
              Text(
                message,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 16),
              if (canGoBack)
                ElevatedButton(
                  onPressed: () => context.pop(),
                  child: const Text('Back'),
                )
              else
                ElevatedButton(
                  onPressed: () => context.go(AppRoute.home),
                  child: const Text('Go Home'),
                ),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}
