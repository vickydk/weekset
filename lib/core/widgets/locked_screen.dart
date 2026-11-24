import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import 'primary_button.dart';
import 'secondary_button.dart';

/// No membership yet. No tabs.
class LockedScreen extends StatelessWidget {
  const LockedScreen({
    required this.onHaveCode,
    required this.onSignOut,
    super.key,
  });

  final VoidCallback onHaveCode;
  final VoidCallback onSignOut;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 48, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Account ready',
                style: TextStyle(
                  color: AppColors.paper,
                  fontSize: 28,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'There is no menu until a manager, or the fitness center, sends a code.',
                style: TextStyle(
                  color: AppColors.muted,
                  fontSize: 16,
                  height: 1.4,
                ),
              ),
              const Spacer(),
              PrimaryButton(label: 'I have a code', onPressed: onHaveCode),
              SecondaryButton(label: 'Sign out', onPressed: onSignOut),
            ],
          ),
        ),
      ),
    );
  }
}
