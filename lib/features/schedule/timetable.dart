import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/status_chip.dart';
import '../auth/session_controller.dart';
import 'client_week.dart';

/// Who trains when. The row has a name and a status, never a workout note.
class TimetableList extends StatelessWidget {
  const TimetableList({required this.sessions, super.key});

  final List<WeekBooking> sessions;

  @override
  Widget build(BuildContext context) {
    if (sessions.isEmpty) {
      return const EmptyState(
        title: 'No one is booked',
        message: 'Confirmed and requested hours show up here.',
      );
    }
    return ListView(
      children: [
        for (final session in sessions)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                Text(
                  session.time,
                  style: const TextStyle(
                    color: AppColors.paper,
                    fontSize: 28,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    session.title,
                    style: const TextStyle(
                      color: AppColors.paper,
                      fontSize: 16,
                    ),
                  ),
                ),
                StatusChip(status: session.status),
              ],
            ),
          ),
      ],
    );
  }
}

class TimetableScreen extends StatefulWidget {
  const TimetableScreen({required this.session, super.key});

  final SessionController session;

  @override
  State<TimetableScreen> createState() => _TimetableScreenState();
}

class _TimetableScreenState extends State<TimetableScreen> {
  List<WeekBooking> _sessions = const [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  String? _branchId() {
    final selected = widget.session.selectedBranchId;
    if (selected != null && selected.isNotEmpty) return selected;
    final membership = widget.session.profile?.activeMembership;
    if (membership == null || membership.branches.isEmpty) return null;
    return membership.branches.first.id;
  }

  Future<void> _load() async {
    final token = widget.session.accessToken;
    if (token == null) return;
    final now = DateTime.now().toUtc();
    try {
      final sessions = await widget.session.api.timetable(
        accessToken: token,
        from: _stamp(now),
        to: _stamp(now.add(const Duration(days: 7))),
        centerId: widget.session.centerHeader,
        branchId: _branchId(),
      );
      if (!mounted) return;
      setState(() => _sessions = sessions);
    } on Object {
      if (!mounted) return;
      setState(() => _sessions = const []);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: TimetableList(sessions: _sessions),
    );
  }
}

String _stamp(DateTime time) {
  final utc = time.toUtc();
  String two(int value) => value.toString().padLeft(2, '0');
  return '${utc.year.toString().padLeft(4, '0')}-${two(utc.month)}-${two(utc.day)}T${two(utc.hour)}:${two(utc.minute)}:${two(utc.second)}Z';
}
