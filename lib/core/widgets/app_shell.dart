import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Empty home until a role shell is wired.
class AppShell extends StatelessWidget {
  const AppShell({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: SafeArea(
        child: Center(
          child: Text(
            'Weekset',
            style: TextStyle(
              color: AppColors.paper,
              fontSize: 32,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}
