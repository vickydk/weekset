import 'package:flutter_test/flutter_test.dart';
import 'package:weekset/features/schedule/session_log.dart';

void main() {
  test('a session log keeps the note, the load, and the edit time', () {
    final log = SessionLogView.fromJson({
      'note': 'felt strong',
      'updated_at': '2026-11-23T08:00:00Z',
      'exercises': [
        {
          'name': 'squat',
          'sets': [
            {'reps': 5, 'load': '40', 'unit': 'kg'},
          ],
        },
      ],
    });
    expect(log.note, 'felt strong');
    expect(log.lines, ['squat  5 × 40 kg']);
    expect(log.updatedAt, '2026-11-23T08:00:00Z');
  });
}
