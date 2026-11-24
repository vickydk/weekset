import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/session_card.dart';
import '../../core/widgets/status_chip.dart';
import 'availability_week.dart';

/// A booking on the client's week.
class WeekBooking {
  const WeekBooking({
    required this.id,
    required this.time,
    required this.title,
    required this.status,
    required this.startsAt,
    required this.endsAt,
  });

  final String id;
  final String time;
  final String title;
  final SessionStatus status;
  final String startsAt;
  final String endsAt;

  factory WeekBooking.fromJson(Map<String, dynamic> json) {
    final raw = json['status'] as String? ?? 'requested';
    final client = json['client_name'] as String? ?? '';
    final trainer = json['trainer_name'] as String? ?? '';
    final title = client.isNotEmpty && trainer.isNotEmpty
        ? '$client · $trainer'
        : (trainer.isNotEmpty ? trainer : 'Session');
    return WeekBooking(
      id: json['id'] as String? ?? '',
      time: _clock(json['starts_at'] as String? ?? ''),
      title: title,
      status: SessionStatus.values.byName(raw),
      startsAt: json['starts_at'] as String? ?? '',
      endsAt: json['ends_at'] as String? ?? '',
    );
  }
}

String _clock(String iso) {
  final parsed = DateTime.tryParse(iso);
  if (parsed == null) return iso;
  final local = parsed.toLocal();
  final hour = local.hour.toString().padLeft(2, '0');
  final minute = local.minute.toString().padLeft(2, '0');
  return '$hour:$minute';
}

/// Open hours the client can request, then the hours already asked for.
class ClientWeek extends StatelessWidget {
  const ClientWeek({
    required this.open,
    required this.bookings,
    this.onRequest,
    super.key,
  });

  final List<HourSlot> open;
  final List<WeekBooking> bookings;
  final ValueChanged<HourSlot>? onRequest;

  @override
  Widget build(BuildContext context) {
    if (open.isEmpty && bookings.isEmpty) {
      return const EmptyState(
        title: 'No open hours',
        message: 'When your PT publishes an hour, it shows up here.',
      );
    }
    return ListView(
      children: [
        for (final hour in open)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Material(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(12),
              child: InkWell(
                onTap: onRequest == null ? null : () => onRequest!(hour),
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
                      const Text(
                        'Open',
                        style: TextStyle(color: AppColors.muted, fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        for (final booking in bookings)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: SessionCard(
              time: booking.time,
              title: booking.title,
              status: booking.status,
            ),
          ),
      ],
    );
  }
}
