import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:weekset/app.dart';
import 'package:weekset/core/theme/app_theme.dart';
import 'package:weekset/core/widgets/locked_screen.dart';
import 'package:weekset/core/widgets/option_switcher.dart';
import 'package:weekset/core/widgets/status_chip.dart';
import 'package:weekset/core/widgets/suspended_screen.dart';

void main() {
  testWidgets('shows the empty Weekset shell', (tester) async {
    await tester.pumpWidget(const WeeksetApp());

    expect(find.text('Weekset'), findsOneWidget);
  });

  testWidgets('a 390-wide locked frame stays inside the safe area', (
    tester,
  ) async {
    await _pumpPhone(tester, LockedScreen(onHaveCode: () {}, onSignOut: () {}));
    expect(find.text('I have a code'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('suspended names the center and the other-center action', (
    tester,
  ) async {
    await _pumpPhone(
      tester,
      SuspendedScreen(
        centerName: 'Harbor Club',
        onSignOut: () {},
        onOpenOtherCenter: () {},
      ),
    );
    expect(find.text('Membership paused'), findsOneWidget);
    expect(find.text('Open my other center'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('status chips keep a label', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark(),
        home: const Scaffold(
          body: Wrap(
            children: [
              StatusChip(status: SessionStatus.requested),
              StatusChip(status: SessionStatus.confirmed),
              StatusChip(status: SessionStatus.declined),
              StatusChip(status: SessionStatus.cancelled),
              StatusChip(status: SessionStatus.completed),
            ],
          ),
        ),
      ),
    );
    expect(find.text('Requested'), findsOneWidget);
    expect(find.text('Confirmed'), findsOneWidget);
    expect(find.text('Declined'), findsOneWidget);
    expect(find.text('Cancelled'), findsOneWidget);
    expect(find.text('Completed'), findsOneWidget);
  });

  testWidgets('the current center is labeled, not only colored', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark(),
        home: Scaffold(
          body: CenterSwitcher(
            selectedId: 'harbor',
            onSelected: (_) {},
            centers: const [
              SwitcherOption(id: 'harbor', title: 'Harbor Club'),
              SwitcherOption(id: 'north', title: 'North Gym'),
            ],
          ),
        ),
      ),
    );
    expect(find.text('Current'), findsOneWidget);
  });
}

Future<void> _pumpPhone(WidgetTester tester, Widget child) async {
  tester.view.physicalSize = const Size(390, 844);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(MaterialApp(theme: AppTheme.dark(), home: child));
}
