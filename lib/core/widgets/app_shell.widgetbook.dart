import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import 'app_shell.dart';

/// Default catalogue case for the empty shell.
Widget buildAppShellUseCase(BuildContext context) {
  return Theme(data: AppTheme.dark(), child: const AppShell());
}
