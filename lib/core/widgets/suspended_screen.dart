import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import 'primary_button.dart';
import 'secondary_button.dart';

/// The only membership is paused. No tabs.
class SuspendedScreen extends StatelessWidget {
  const SuspendedScreen({
    required this.centerName,
    required this.onSignOut,
    this.onOpenOtherCenter,
    super.key,
  });

  final String centerName;
  final VoidCallback onSignOut;
  final VoidCallback? onOpenOtherCenter;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 48, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                centerName,
                style: const TextStyle(
                  color: AppColors.muted,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Membership paused',
                style: TextStyle(
                  color: AppColors.paper,
                  fontSize: 28,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                '$centerName paused this membership. Session notes stay with the center.',
                style: const TextStyle(
                  color: AppColors.muted,
                  fontSize: 16,
                  height: 1.4,
                ),
              ),
              const Spacer(),
              if (onOpenOtherCenter != null)
                PrimaryButton(
                  label: 'Open my other center',
                  onPressed: onOpenOtherCenter,
                ),
              SecondaryButton(label: 'Sign out', onPressed: onSignOut),
            ],
          ),
        ),
      ),
    );
  }
}
