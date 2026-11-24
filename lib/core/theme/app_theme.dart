import 'package:flutter/material.dart';

import 'app_colors.dart';

abstract final class AppTheme {
  static ThemeData dark() {
    const scheme = ColorScheme.dark(
      primary: AppColors.lime,
      onPrimary: AppColors.charcoal,
      surface: AppColors.card,
      onSurface: AppColors.paper,
      error: AppColors.clay,
    );
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.charcoal,
      colorScheme: scheme,
    );
  }
}
