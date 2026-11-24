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
  List<AssignedClient> _clients = const [];
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
      final clients = await widget.session.api.trainerClients(
        accessToken: token,
        centerId: widget.session.selectedCenterId,
      );
      if (!mounted) return;
      setState(() {
        _movements = movements;
        _clients = clients;
      });
    } on Object {
      if (!mounted) return;
      setState(() => _movements = const []);
    }
  }

  Future<void> _assign(AssignedClient client) async {
    final token = widget.session.accessToken;
    final movement = _open;
    if (token == null || movement == null) return;
    final now = DateTime.now();
    final date =
        '${now.year.toString().padLeft(4, '0')}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    try {
      await widget.session.api.assignSolo(
        accessToken: token,
        clientId: client.id,
        planDate: date,
        slug: movement.slug,
        centerId: widget.session.selectedCenterId,
      );
    } on Object {
      return;
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
            for (final client in _clients)
              TextButton(
                onPressed: () => _assign(client),
                child: Text('Assign solo day to ${client.name}'),
              ),
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
