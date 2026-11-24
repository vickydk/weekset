import 'package:flutter_test/flutter_test.dart';
import 'package:weekset/app.dart';

void main() {
  testWidgets('shows the empty Weekset shell', (tester) async {
    await tester.pumpWidget(const WeeksetApp());

    expect(find.text('Weekset'), findsOneWidget);
  });
}
