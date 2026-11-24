import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Dark gym theme. One palette, one lime accent, 48px primary actions.
abstract final class AppTheme {
  static const radius = 12.0;
  static const actionHeight = 48.0;

  static ThemeData dark() {
    const scheme = ColorScheme.dark(
      primary: AppColors.lime,
      onPrimary: AppColors.charcoal,
      surface: AppColors.card,
      onSurface: AppColors.paper,
      error: AppColors.clay,
      onError: AppColors.charcoal,
      outline: AppColors.line,
    );
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.charcoal,
      colorScheme: scheme,
      textTheme: const TextTheme(
        headlineMedium: TextStyle(
          color: AppColors.paper,
          fontSize: 28,
          fontWeight: FontWeight.w600,
          height: 1.2,
        ),
        titleLarge: TextStyle(
          color: AppColors.paper,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
        titleMedium: TextStyle(
          color: AppColors.paper,
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
        bodyLarge: TextStyle(color: AppColors.paper, fontSize: 16, height: 1.4),
        bodyMedium: TextStyle(
          color: AppColors.muted,
          fontSize: 14,
          height: 1.4,
        ),
        labelLarge: TextStyle(
          color: AppColors.charcoal,
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.card,
        hintStyle: const TextStyle(color: AppColors.muted),
        labelStyle: const TextStyle(color: AppColors.muted),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radius),
          borderSide: const BorderSide(color: AppColors.line),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radius),
          borderSide: const BorderSide(color: AppColors.lime),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radius),
          borderSide: const BorderSide(color: AppColors.clay),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radius),
          borderSide: const BorderSide(color: AppColors.clay),
        ),
      ),
    );
  }
}
