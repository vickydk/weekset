import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

/// One movement from the seeded library.
class Movement {
  const Movement({required this.slug, required this.name});

  final String slug;
  final String name;

  factory Movement.fromJson(Map<String, dynamic> json) {
    return Movement(
      slug: json['slug'] as String? ?? '',
      name: json['name'] as String? ?? '',
    );
  }
}

/// A silent loop. It repeats and plays no sound.
class DemoLoop extends StatefulWidget {
  const DemoLoop({required this.name, super.key});

  final String name;

  @override
  State<DemoLoop> createState() => _DemoLoopState();
}

class _DemoLoopState extends State<DemoLoop>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FadeTransition(
          opacity: Tween<double>(begin: 0.4, end: 1).animate(_controller),
          child: Text(
            widget.name,
            style: const TextStyle(
              color: AppColors.paper,
              fontSize: 28,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Silent loop',
          style: TextStyle(color: AppColors.muted, fontSize: 14),
        ),
      ],
    );
  }
}

class ExerciseLibrary extends StatelessWidget {
  const ExerciseLibrary({required this.movements, this.onOpen, super.key});

  final List<Movement> movements;
  final ValueChanged<Movement>? onOpen;

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        for (final movement in movements)
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(
              movement.name,
              style: const TextStyle(color: AppColors.paper, fontSize: 16),
            ),
            onTap: onOpen == null ? null : () => onOpen!(movement),
          ),
      ],
    );
  }
}
