import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app_colors.dart';

class AppTheme {
  AppTheme._();

  static const String fontFamily = 'Mulish';

  static ThemeData get light {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      primary: AppColors.primary,
      secondary: AppColors.primaryDark,
      surface: AppColors.surface,
      error: AppColors.error,
      brightness: Brightness.light,
    );

    return ThemeData(
      useMaterial3: true,
      fontFamily: fontFamily,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.background,
      dividerColor: AppColors.border,
      appBarTheme: const AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.text,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        titleTextStyle: TextStyle(
          fontFamily: fontFamily,
          fontSize: 16,
          fontWeight: FontWeight.w800,
          color: AppColors.text,
          letterSpacing: -0.3,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppColors.radius),
          side: const BorderSide(color: AppColors.border),
        ),
        margin: EdgeInsets.zero,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppColors.radius),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppColors.radius),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppColors.radius),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppColors.radius),
          borderSide: const BorderSide(color: AppColors.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppColors.radius),
          borderSide: const BorderSide(color: AppColors.error, width: 1.5),
        ),
        labelStyle: const TextStyle(
          fontFamily: fontFamily,
          fontSize: 13,
          color: AppColors.textSecondary,
          fontWeight: FontWeight.w500,
        ),
        hintStyle: const TextStyle(
          fontFamily: fontFamily,
          fontSize: 13,
          color: AppColors.textTertiary,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppColors.radius),
          ),
          textStyle: const TextStyle(
            fontFamily: fontFamily,
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.text,
          side: const BorderSide(color: AppColors.border),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppColors.radius),
          ),
          textStyle: const TextStyle(
            fontFamily: fontFamily,
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          textStyle: const TextStyle(
            fontFamily: fontFamily,
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      dataTableTheme: DataTableThemeData(
        headingRowColor: WidgetStateProperty.all(AppColors.surfaceLight),
        headingTextStyle: const TextStyle(
          fontFamily: fontFamily,
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: AppColors.textSecondary,
          letterSpacing: 0.4,
        ),
        dataTextStyle: const TextStyle(
          fontFamily: fontFamily,
          fontSize: 13,
          color: AppColors.text,
          fontWeight: FontWeight.w500,
        ),
        dividerThickness: 1,
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppColors.radius),
        ),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.primary,
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return AppColors.primary;
          return null;
        }),
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(fontFamily: fontFamily, fontWeight: FontWeight.w900, color: AppColors.text),
        displayMedium: TextStyle(fontFamily: fontFamily, fontWeight: FontWeight.w800, color: AppColors.text),
        headlineLarge: TextStyle(fontFamily: fontFamily, fontWeight: FontWeight.w800, color: AppColors.text),
        headlineMedium: TextStyle(fontFamily: fontFamily, fontWeight: FontWeight.w800, color: AppColors.text),
        headlineSmall: TextStyle(fontFamily: fontFamily, fontWeight: FontWeight.w700, color: AppColors.text),
        titleLarge: TextStyle(fontFamily: fontFamily, fontWeight: FontWeight.w700, color: AppColors.text),
        titleMedium: TextStyle(fontFamily: fontFamily, fontWeight: FontWeight.w600, color: AppColors.text),
        titleSmall: TextStyle(fontFamily: fontFamily, fontWeight: FontWeight.w600, color: AppColors.text),
        bodyLarge: TextStyle(fontFamily: fontFamily, fontWeight: FontWeight.w400, color: AppColors.text),
        bodyMedium: TextStyle(fontFamily: fontFamily, fontWeight: FontWeight.w400, color: AppColors.text),
        bodySmall: TextStyle(fontFamily: fontFamily, fontWeight: FontWeight.w400, color: AppColors.textSecondary),
        labelLarge: TextStyle(fontFamily: fontFamily, fontWeight: FontWeight.w700, color: AppColors.text),
        labelMedium: TextStyle(fontFamily: fontFamily, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
        labelSmall: TextStyle(fontFamily: fontFamily, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
      ),
    );
  }
}
