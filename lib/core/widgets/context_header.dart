import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Names the center, and the branch when the role is tied to one.
class ContextHeader extends StatelessWidget {
  const ContextHeader({required this.centerName, this.branchName, super.key});

  final String centerName;
  final String? branchName;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          centerName,
          style: const TextStyle(
            color: AppColors.paper,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        if (branchName != null && branchName!.isNotEmpty) ...[
          const SizedBox(height: 2),
          Text(
            branchName!,
            style: const TextStyle(color: AppColors.muted, fontSize: 14),
          ),
        ],
      ],
    );
  }
}
