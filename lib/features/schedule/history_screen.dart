import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/widgets/empty_state.dart';
import '../auth/session_controller.dart';
import 'client_week.dart';
import 'session_log.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({required this.session, super.key});

  final SessionController session;

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<WeekBooking> _bookings = const [];
  SessionLogView? _log;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final token = widget.session.accessToken;
    if (token == null) return;
    final now = DateTime.now().toUtc();
    try {
      final bookings = await widget.session.api.bookings(
        accessToken: token,
        from: _stamp(now.subtract(const Duration(days: 13))),
        to: _stamp(now.add(const Duration(days: 1))),
        centerId: widget.session.centerHeader,
      );
      if (!mounted) return;
      setState(() {
        _bookings = bookings
            .where((booking) => booking.status.name == 'completed')
            .toList();
      });
    } on Object {
      if (!mounted) return;
      setState(() => _bookings = const []);
    }
  }

  Future<void> _open(WeekBooking booking) async {
    final token = widget.session.accessToken;
    if (token == null) return;
    try {
      final log = await widget.session.api.readLog(
        accessToken: token,
        bookingId: booking.id,
        centerId: widget.session.centerHeader,
      );
      if (!mounted) return;
      setState(() => _log = log);
    } on Object {
      if (!mounted) return;
      setState(() => _log = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final log = _log;
    return Padding(
      padding: const EdgeInsets.all(24),
      child: _bookings.isEmpty
          ? const EmptyState(
              title: 'No sessions yet',
              message: 'A finished hour shows its note, sets, and load here.',
            )
          : ListView(
              children: [
                for (final booking in _bookings)
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      '${booking.time}  ${booking.title}',
                      style: const TextStyle(
                        color: AppColors.paper,
                        fontSize: 16,
                      ),
                    ),
                    onTap: () => _open(booking),
                  ),
                if (log != null) ...[
                  const SizedBox(height: 16),
                  Text(
                    log.note,
                    style: const TextStyle(
                      color: AppColors.paper,
                      fontSize: 18,
                    ),
                  ),
                  for (final line in log.lines)
                    Text(
                      line,
                      style: const TextStyle(
                        color: AppColors.muted,
                        fontSize: 14,
                      ),
                    ),
                  Text(
                    log.updatedAt,
                    style: const TextStyle(
                      color: AppColors.muted,
                      fontSize: 12,
                    ),
                  ),
                ],
              ],
            ),
    );
  }
}

String _stamp(DateTime time) {
  final utc = time.toUtc();
  String two(int value) => value.toString().padLeft(2, '0');
  return '${utc.year.toString().padLeft(4, '0')}-${two(utc.month)}-${two(utc.day)}T${two(utc.hour)}:${two(utc.minute)}:${two(utc.second)}Z';
}
