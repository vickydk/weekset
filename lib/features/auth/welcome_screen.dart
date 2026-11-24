import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/widgets/primary_button.dart';
import '../../core/widgets/secondary_button.dart';

/// First screen. Register and log in both start here.
class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({
    required this.onLogIn,
    required this.onCreateAccount,
    super.key,
  });

  final VoidCallback onLogIn;
  final VoidCallback onCreateAccount;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 72, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'HARBOR CLUB',
                style: TextStyle(
                  color: AppColors.muted,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.4,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Your week, with your trainer.',
                style: TextStyle(
                  color: AppColors.paper,
                  fontSize: 32,
                  fontWeight: FontWeight.w600,
                  height: 1.15,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'See open hours, keep a fixed week, and read every session after it happens.',
                style: TextStyle(
                  color: AppColors.muted,
                  fontSize: 16,
                  height: 1.4,
                ),
              ),
              const Spacer(),
              PrimaryButton(label: 'Continue with email', onPressed: onLogIn),
              SecondaryButton(
                label: 'Create account',
                onPressed: onCreateAccount,
              ),
              const SizedBox(height: 8),
              const Center(
                child: Text(
                  'Your center sends the invite.',
                  style: TextStyle(color: AppColors.muted, fontSize: 13),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
