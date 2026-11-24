import 'package:flutter/material.dart';

import '../auth/session_controller.dart';
import 'exercise_library.dart';

/// The twelve movements. Opening one plays a silent loop.
class ExerciseScreen extends StatefulWidget {
  const ExerciseScreen({required this.session, super.key});

  final SessionController session;

  @override
  State<ExerciseScreen> createState() => _ExerciseScreenState();
}

class _ExerciseScreenState extends State<ExerciseScreen> {
  List<Movement> _movements = const [];
  Movement? _open;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final token = widget.session.accessToken;
    if (token == null) return;
    try {
      final movements = await widget.session.api.exercises(accessToken: token);
      if (!mounted) return;
      setState(() => _movements = movements);
    } on Object {
      if (!mounted) return;
      setState(() => _movements = const []);
    }
  }

  @override
  Widget build(BuildContext context) {
    final open = _open;
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (open != null) ...[
            DemoLoop(name: open.name),
            const SizedBox(height: 16),
          ],
          Expanded(
            child: ExerciseLibrary(
              movements: _movements,
              onOpen: (movement) => setState(() => _open = movement),
            ),
          ),
        ],
      ),
    );
  }
}
