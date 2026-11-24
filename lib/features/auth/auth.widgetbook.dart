import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import 'register_screen.dart';

WidgetbookFolder authFolder() {
  return WidgetbookFolder(
    name: 'Auth',
    children: [
      WidgetbookComponent(
        name: 'Register choices',
        useCases: [
          WidgetbookUseCase(
            name: 'client, PT, manager, center',
            builder: (context) =>
                _frame(RegisterChoiceScreen(onChoice: (_) {}, onBack: () {})),
          ),
        ],
      ),
      WidgetbookComponent(
        name: 'Login error',
        useCases: [
          WidgetbookUseCase(
            name: 'same message',
            builder: (context) => _frame(
              const Scaffold(
                body: SafeArea(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: Text(
                      'That email or password is not right.',
                      style: TextStyle(color: AppColors.clay, fontSize: 16),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    ],
  );
}

Widget _frame(Widget child) {
  return Theme(
    data: AppTheme.dark(),
    child: ColoredBox(
      color: AppColors.charcoal,
      child: Center(child: SizedBox(width: 390, height: 844, child: child)),
    ),
  );
}
