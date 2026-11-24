import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/primary_button.dart';
import '../../core/widgets/secondary_button.dart';

/// One saved weekly window.
class TemplateWindow {
  const TemplateWindow({
    required this.weekday,
    required this.localStart,
    required this.localEnd,
  });

  final int weekday;
  final String localStart;
  final String localEnd;

  factory TemplateWindow.fromJson(Map<String, dynamic> json) {
    return TemplateWindow(
      weekday: json['weekday'] as int? ?? 0,
      localStart: json['local_start'] as String? ?? '',
      localEnd: json['local_end'] as String? ?? '',
    );
  }
}

/// One concrete hour on the trainer's week.
class HourSlot {
  const HourSlot({
    required this.time,
    required this.open,
    this.id,
    this.startsAt,
    this.endsAt,
  });

  final String time;
  final bool open;
  final String? id;
  final String? startsAt;
  final String? endsAt;
}

/// Open windows plus the template the trainer edits.
class AvailabilityPage {
  const AvailabilityPage({required this.hours, required this.template});

  final List<HourSlot> hours;
  final List<TemplateWindow> template;

  factory AvailabilityPage.fromJson(Map<String, dynamic> json) {
    final hours = <HourSlot>[];
    for (final raw in json['windows'] as List<dynamic>? ?? []) {
      final row = raw as Map<String, dynamic>;
      hours.add(
        HourSlot(
          time: _hour(row['starts_at'] as String? ?? ''),
          open: true,
          startsAt: row['starts_at'] as String?,
          endsAt: row['ends_at'] as String?,
        ),
      );
    }
    for (final raw in json['closed'] as List<dynamic>? ?? []) {
      final row = raw as Map<String, dynamic>;
      hours.add(
        HourSlot(
          time: _hour(row['starts_at'] as String? ?? ''),
          open: false,
          id: row['id'] as String?,
          startsAt: row['starts_at'] as String?,
          endsAt: row['ends_at'] as String?,
        ),
      );
    }
    hours.sort((a, b) => a.time.compareTo(b.time));
    final template = <TemplateWindow>[
      for (final raw in json['template'] as List<dynamic>? ?? [])
        TemplateWindow.fromJson(raw as Map<String, dynamic>),
    ];
    return AvailabilityPage(hours: hours, template: template);
  }
}

String _hour(String iso) {
  if (iso.length < 16) return iso;
  final parsed = DateTime.tryParse(iso);
  if (parsed == null) return iso.substring(11, 16);
  final local = parsed.toLocal();
  final hour = local.hour.toString().padLeft(2, '0');
  final minute = local.minute.toString().padLeft(2, '0');
  return '$hour:$minute';
}

/// The trainer's week. The hour is the largest text, with an open or closed label.
class AvailabilityWeek extends StatelessWidget {
  const AvailabilityWeek({
    required this.hours,
    this.onAdd,
    this.onToggle,
    super.key,
  });

  final List<HourSlot> hours;
  final VoidCallback? onAdd;
  final ValueChanged<HourSlot>? onToggle;

  @override
  Widget build(BuildContext context) {
    if (hours.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const EmptyState(
            title: 'No hours yet',
            message:
                'Add the hours you can train. An empty week stays unpublished.',
          ),
          if (onAdd != null) ...[
            const SizedBox(height: 16),
            PrimaryButton(label: 'Add hours', onPressed: onAdd),
          ],
        ],
      );
    }
    return ListView(
      children: [
        for (final hour in hours) _row(hour),
        if (onAdd != null) ...[
          const SizedBox(height: 16),
          SecondaryButton(label: 'Add hours', onPressed: onAdd),
        ],
      ],
    );
  }

  Widget _row(HourSlot hour) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onToggle == null ? null : () => onToggle!(hour),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.line),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  hour.time,
                  style: const TextStyle(
                    color: AppColors.paper,
                    fontSize: 28,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  hour.open ? 'Open' : 'Closed',
                  style: const TextStyle(color: AppColors.muted, fontSize: 14),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
