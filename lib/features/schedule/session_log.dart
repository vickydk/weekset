/// A finished session the client can read and cannot edit.
class SessionLogView {
  const SessionLogView({
    required this.note,
    required this.updatedAt,
    required this.lines,
  });

  final String note;
  final String updatedAt;
  final List<String> lines;

  factory SessionLogView.fromJson(Map<String, dynamic> json) {
    final lines = <String>[];
    for (final raw in json['exercises'] as List<dynamic>? ?? []) {
      final exercise = raw as Map<String, dynamic>;
      final name = exercise['name'] as String? ?? '';
      for (final setRaw in exercise['sets'] as List<dynamic>? ?? []) {
        final set = setRaw as Map<String, dynamic>;
        lines.add('$name  ${set['reps']} × ${set['load']} kg');
      }
    }
    return SessionLogView(
      note: json['note'] as String? ?? '',
      updatedAt: json['updated_at'] as String? ?? '',
      lines: lines,
    );
  }
}
