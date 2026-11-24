import 'package:flutter/material.dart';

import 'core/routing/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/widgets/app_shell.dart';

class WeeksetApp extends StatelessWidget {
  const WeeksetApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Weekset',
      theme: AppTheme.dark(),
      initialRoute: AppRouter.home,
      routes: {AppRouter.home: (context) => const AppShell()},
    );
  }
}
