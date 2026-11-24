import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// A booking status. The label and the icon both carry the meaning.
enum SessionStatus { requested, confirmed, declined, cancelled, completed }

class StatusChip extends StatelessWidget {
  const StatusChip({required this.status, super.key});

  final SessionStatus status;

  @override
  Widget build(BuildContext context) {
    final (label, icon, color) = switch (status) {
      SessionStatus.requested => ('Requested', Icons.schedule, AppColors.muted),
      SessionStatus.confirmed => (
        'Confirmed',
        Icons.check_circle_outline,
        AppColors.lime,
      ),
      SessionStatus.declined => ('Declined', Icons.block, AppColors.clay),
      SessionStatus.cancelled => ('Cancelled', Icons.close, AppColors.muted),
      SessionStatus.completed => ('Completed', Icons.task_alt, AppColors.paper),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.line),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
