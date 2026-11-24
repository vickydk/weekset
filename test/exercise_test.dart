import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:weekset/core/theme/app_theme.dart';
import 'package:weekset/features/exercise/exercise_library.dart';

void main() {
  testWidgets('a movement opens a silent loop', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark(),
        home: const Scaffold(body: DemoLoop(name: 'squat')),
      ),
    );
    expect(find.text('squat'), findsOneWidget);
    expect(find.text('Silent loop'), findsOneWidget);
    await tester.pump(const Duration(seconds: 2));
  });
}
