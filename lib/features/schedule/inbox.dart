import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/widgets/empty_state.dart';
import '../auth/session_controller.dart';

/// One in-app update. Opening it returns the session it belongs to.
class Notice {
  const Notice({required this.id, required this.kind, required this.bookingId});

  final String id;
  final String kind;
  final String bookingId;

  String get label => switch (kind) {
    'confirmed' => 'Hour confirmed',
    'declined' => 'Hour declined',
    'cancelled' => 'Hour cancelled',
    _ => 'Hour requested',
  };

  factory Notice.fromJson(Map<String, dynamic> json) {
    return Notice(
      id: json['id'] as String? ?? '',
      kind: json['kind'] as String? ?? '',
      bookingId: json['booking_id'] as String? ?? '',
    );
  }
}

class InboxPanel extends StatefulWidget {
  const InboxPanel({required this.session, required this.onOpen, super.key});

  final SessionController session;
  final ValueChanged<String> onOpen;

  @override
  State<InboxPanel> createState() => _InboxPanelState();
}

class _InboxPanelState extends State<InboxPanel> {
  List<Notice> _notices = const [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final token = widget.session.accessToken;
    if (token == null) return;
    try {
      final notices = await widget.session.api.notifications(
        accessToken: token,
        centerId: widget.session.selectedCenterId,
      );
      if (!mounted) return;
      setState(() => _notices = notices);
    } on Object {
      if (!mounted) return;
      setState(() => _notices = const []);
    }
  }

  Future<void> _open(Notice notice) async {
    final token = widget.session.accessToken;
    if (token == null) return;
    try {
      final opened = await widget.session.api.openNotification(
        accessToken: token,
        id: notice.id,
        centerId: widget.session.selectedCenterId,
      );
      widget.onOpen(opened.bookingId);
    } on Object {
      widget.onOpen(notice.bookingId);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_notices.isEmpty) {
      return const EmptyState(
        title: 'No updates',
        message: 'Notifications stay in the app.',
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final notice in _notices)
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(
              notice.label,
              style: const TextStyle(color: AppColors.paper, fontSize: 16),
            ),
            onTap: () => _open(notice),
          ),
      ],
    );
  }
}
