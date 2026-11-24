import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:weekset/core/theme/app_theme.dart';
import 'package:weekset/features/schedule/availability_week.dart';

void main() {
  testWidgets('the hour is larger than the open or closed label', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark(),
        home: const Scaffold(
          body: AvailabilityWeek(
            hours: [
              HourSlot(time: '07:00', open: true),
              HourSlot(time: '08:00', open: false),
            ],
          ),
        ),
      ),
    );

    final hour = tester.widget<Text>(find.text('07:00'));
    final open = tester.widget<Text>(find.text('Open'));
    final closed = tester.widget<Text>(find.text('Closed'));
    expect(hour.style!.fontSize!, greaterThan(open.style!.fontSize!));
    expect(closed.data, 'Closed');
  });

  testWidgets('an empty template offers add hours', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark(),
        home: Scaffold(
          body: AvailabilityWeek(hours: const [], onAdd: () {}),
        ),
      ),
    );
    expect(find.text('No hours yet'), findsOneWidget);
    expect(find.text('Add hours'), findsOneWidget);
  });
}
