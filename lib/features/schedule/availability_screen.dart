import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/widgets/app_text_field.dart';
import '../../core/widgets/primary_button.dart';
import '../auth/session_controller.dart';
import 'availability_week.dart';

/// Loads the trainer's week and lets them add or close an hour.
class AvailabilityScreen extends StatefulWidget {
  const AvailabilityScreen({required this.session, super.key});

  final SessionController session;

  @override
  State<AvailabilityScreen> createState() => _AvailabilityScreenState();
}

class _AvailabilityScreenState extends State<AvailabilityScreen> {
  AvailabilityPage? _page;
  String? _error;
  var _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final token = widget.session.accessToken;
    if (token == null) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    final now = DateTime.now().toUtc();
    try {
      final page = await widget.session.api.availability(
        accessToken: token,
        from: _rfc3339(now),
        to: _rfc3339(now.add(const Duration(days: 7))),
        centerId: widget.session.selectedCenterId,
      );
      if (!mounted) return;
      setState(() {
        _page = page;
        _loading = false;
      });
    } on Object catch (error) {
      if (!mounted) return;
      setState(() {
        _error = error.toString();
        _loading = false;
      });
    }
  }

  Future<void> _add() async {
    var weekday = DateTime.monday;
    final start = TextEditingController(text: '07:00');
    final end = TextEditingController(text: '08:00');
    final saved = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.card,
          title: const Text(
            'Add hours',
            style: TextStyle(color: AppColors.paper),
          ),
          content: StatefulBuilder(
            builder: (context, setLocal) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButton<int>(
                    value: weekday,
                    dropdownColor: AppColors.card,
                    items: const [
                      DropdownMenuItem(
                        value: DateTime.monday,
                        child: Text('Monday'),
                      ),
                      DropdownMenuItem(
                        value: DateTime.tuesday,
                        child: Text('Tuesday'),
                      ),
                      DropdownMenuItem(
                        value: DateTime.wednesday,
                        child: Text('Wednesday'),
                      ),
                      DropdownMenuItem(
                        value: DateTime.thursday,
                        child: Text('Thursday'),
                      ),
                      DropdownMenuItem(
                        value: DateTime.friday,
                        child: Text('Friday'),
                      ),
                      DropdownMenuItem(
                        value: DateTime.saturday,
                        child: Text('Saturday'),
                      ),
                      DropdownMenuItem(
                        value: DateTime.sunday,
                        child: Text('Sunday'),
                      ),
                    ],
                    onChanged: (value) {
                      if (value == null) return;
                      setLocal(() => weekday = value);
                    },
                  ),
                  AppTextField(
                    label: 'Start',
                    hint: '07:00',
                    controller: start,
                  ),
                  const SizedBox(height: 12),
                  AppTextField(label: 'End', hint: '08:00', controller: end),
                ],
              );
            },
          ),
          actions: [
            PrimaryButton(
              label: 'Save hours',
              onPressed: () => Navigator.pop(context, true),
            ),
          ],
        );
      },
    );
    if (saved != true) {
      start.dispose();
      end.dispose();
      return;
    }
    final token = widget.session.accessToken;
    if (token == null) return;
    final windows = [
      ...?_page?.template,
      TemplateWindow(
        weekday: weekday % 7,
        localStart: start.text,
        localEnd: end.text,
      ),
    ];
    start.dispose();
    end.dispose();
    try {
      await widget.session.api.replaceTemplate(
        accessToken: token,
        windows: windows,
        centerId: widget.session.selectedCenterId,
      );
      await _load();
    } on Object catch (error) {
      if (!mounted) return;
      setState(() => _error = error.toString());
    }
  }

  Future<void> _toggle(HourSlot hour) async {
    final token = widget.session.accessToken;
    if (token == null) return;
    try {
      if (hour.open && hour.startsAt != null && hour.endsAt != null) {
        await widget.session.api.closeHour(
          accessToken: token,
          startsAt: hour.startsAt!,
          endsAt: hour.endsAt!,
          centerId: widget.session.selectedCenterId,
        );
      } else if (hour.id != null) {
        await widget.session.api.reopenHour(
          accessToken: token,
          id: hour.id!,
          centerId: widget.session.selectedCenterId,
        );
      }
      await _load();
    } on Object catch (error) {
      if (!mounted) return;
      setState(() => _error = error.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    final page = _page;
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
            child: _loading
                ? const SizedBox.shrink()
                : AvailabilityWeek(
                    hours: page?.hours ?? const [],
                    onAdd: _add,
                    onToggle: _toggle,
                  ),
          ),
        ],
      ),
    );
  }
}

String _rfc3339(DateTime time) {
  final utc = time.toUtc();
  String two(int value) => value.toString().padLeft(2, '0');
  return '${utc.year.toString().padLeft(4, '0')}-${two(utc.month)}-${two(utc.day)}T${two(utc.hour)}:${two(utc.minute)}:${two(utc.second)}Z';
}
