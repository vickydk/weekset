import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';

import '../../core/theme/app_theme.dart';
import 'availability_week.dart';

WidgetbookFolder availabilityFolder() {
  return WidgetbookFolder(
    name: 'Availability',
    children: [
      WidgetbookComponent(
        name: 'Week',
        useCases: [
          WidgetbookUseCase(name: 'empty template', builder: _empty),
          WidgetbookUseCase(name: 'open week', builder: _open),
          WidgetbookUseCase(name: 'one hour closed', builder: _closed),
        ],
      ),
    ],
  );
}

Widget _frame(Widget child) {
  return Theme(
    data: AppTheme.dark(),
    child: Scaffold(
      body: Padding(padding: const EdgeInsets.all(24), child: child),
    ),
  );
}

Widget _empty(BuildContext context) {
  return _frame(AvailabilityWeek(hours: const [], onAdd: () {}));
}

Widget _open(BuildContext context) {
  return _frame(
    const AvailabilityWeek(
      hours: [
        HourSlot(time: '07:00', open: true),
        HourSlot(time: '08:00', open: true),
      ],
    ),
  );
}

Widget _closed(BuildContext context) {
  return _frame(
    const AvailabilityWeek(
      hours: [
        HourSlot(time: '07:00', open: false),
        HourSlot(time: '08:00', open: true),
      ],
    ),
  );
}
