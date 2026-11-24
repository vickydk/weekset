import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../auth/session_controller.dart';
import 'availability_week.dart';
import 'client_week.dart';

/// The client's week: open hours to request, and the hours already asked for.
class ClientWeekScreen extends StatefulWidget {
  const ClientWeekScreen({required this.session, super.key});

  final SessionController session;

  @override
  State<ClientWeekScreen> createState() => _ClientWeekScreenState();
}

class _ClientWeekScreenState extends State<ClientWeekScreen> {
  List<HourSlot> _open = const [];
  List<WeekBooking> _bookings = const [];
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final token = widget.session.accessToken;
    if (token == null) return;
    final now = DateTime.now().toUtc();
    final from = _stamp(now);
    final to = _stamp(now.add(const Duration(days: 7)));
    try {
      final hours = await widget.session.api.availability(
        accessToken: token,
        from: from,
        to: to,
        centerId: widget.session.selectedCenterId,
      );
      final bookings = await widget.session.api.bookings(
        accessToken: token,
        from: from,
        to: to,
        centerId: widget.session.selectedCenterId,
      );
      if (!mounted) return;
      setState(() {
        _open = hours.hours.where((hour) => hour.open).toList();
        _bookings = bookings;
        _error = null;
      });
    } on Object catch (error) {
      if (!mounted) return;
      setState(() => _error = error.toString());
    }
  }

  Future<void> _request(HourSlot hour) async {
    final token = widget.session.accessToken;
    if (token == null || hour.startsAt == null || hour.endsAt == null) return;
    try {
      await widget.session.api.requestBooking(
        accessToken: token,
        startsAt: hour.startsAt!,
        endsAt: hour.endsAt!,
        centerId: widget.session.selectedCenterId,
      );
      await _load();
    } on Object catch (error) {
      if (!mounted) return;
      setState(() => _error = error.toString());
    }
  }

  Future<void> _repeat(HourSlot hour) async {
    final token = widget.session.accessToken;
    if (token == null || hour.startsAt == null || hour.endsAt == null) return;
    try {
      await widget.session.api.repeatBooking(
        accessToken: token,
        startsAt: hour.startsAt!,
        endsAt: hour.endsAt!,
        centerId: widget.session.selectedCenterId,
      );
      await _load();
    } on Object catch (error) {
      if (!mounted) return;
      setState(() => _error = error.toString());
    }
  }

  Future<void> _skip(WeekBooking booking) async {
    final token = widget.session.accessToken;
    if (token == null || booking.seriesId.isEmpty) return;
    final parsed = DateTime.tryParse(booking.startsAt);
    if (parsed == null) return;
    final day =
        '${parsed.toUtc().year.toString().padLeft(4, '0')}-${parsed.toUtc().month.toString().padLeft(2, '0')}-${parsed.toUtc().day.toString().padLeft(2, '0')}';
    try {
      await widget.session.api.skipOccurrence(
        accessToken: token,
        seriesId: booking.seriesId,
        occurrenceOn: day,
        centerId: widget.session.selectedCenterId,
      );
      await _load();
    } on Object catch (error) {
      if (!mounted) return;
      setState(() => _error = error.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_error != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text(
                _error!,
                style: const TextStyle(color: AppColors.clay),
              ),
            ),
          Expanded(
            child: ClientWeek(
              open: _open,
              bookings: _bookings,
              onRequest: _request,
              onRepeat: _repeat,
              onSkip: _skip,
            ),
          ),
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
