import 'package:flutter/widgets.dart';
import 'package:widgetbook/widgetbook.dart';

import 'core/theme/app_theme.dart';
import 'core/widgets/app_shell.widgetbook.dart';

/// Catalogue entry. Run with `flutter run -t lib/widgetbook.dart`.
void main() {
  runApp(const WidgetbookApp());
}

class WidgetbookApp extends StatelessWidget {
  const WidgetbookApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Widgetbook.material(
      directories: [
        WidgetbookFolder(
          name: 'App',
          children: [
            WidgetbookComponent(
              name: 'AppShell',
              useCases: [
                WidgetbookUseCase(
                  name: 'default',
                  builder: buildAppShellUseCase,
                ),
              ],
            ),
          ],
        ),
      ],
      addons: [
        MaterialThemeAddon(
          themes: [
            WidgetbookTheme(name: 'Weekset Dark', data: AppTheme.dark()),
          ],
        ),
      ],
    );
  }
}
