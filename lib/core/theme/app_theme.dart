import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app_colors.dart';

class AppTheme {
  AppTheme._();

  /// POC uses IBM Plex Sans / Newsreader; Mulish is the bundled stand-in.
  static const String fontFamily = 'Mulish';
  static const String fontDisplay = 'Mulish';
  static const String fontMono = 'Mulish';

  static ThemeData get light {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.brand600,
      primary: AppColors.primary,
      secondary: AppColors.secondary,
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
          fontFamily: fontDisplay,
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: AppColors.text,
          letterSpacing: -0.3,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppColors.radiusLarge),
          side: const BorderSide(color: AppColors.border),
        ),
        margin: EdgeInsets.zero,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppColors.radiusSmall),
          borderSide: const BorderSide(color: AppColors.borderStrong),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppColors.radiusSmall),
          borderSide: const BorderSide(color: AppColors.borderStrong),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppColors.radiusSmall),
          borderSide: const BorderSide(color: AppColors.brand600, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppColors.radiusSmall),
          borderSide: const BorderSide(color: AppColors.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppColors.radiusSmall),
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
          backgroundColor: AppColors.brand600,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppColors.radiusSmall),
          ),
          textStyle: const TextStyle(
            fontFamily: fontFamily,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ).copyWith(
          overlayColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.hovered)) {
              return AppColors.brand700.withValues(alpha: 0.12);
            }
            return null;
          }),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.text,
          backgroundColor: AppColors.surface,
          side: const BorderSide(color: AppColors.borderStrong),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppColors.radiusSmall),
          ),
          textStyle: const TextStyle(
            fontFamily: fontFamily,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.brand600,
          textStyle: const TextStyle(
            fontFamily: fontFamily,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      dataTableTheme: DataTableThemeData(
        headingRowColor: WidgetStateProperty.all(
          AppColors.ink.withValues(alpha: 0.022),
        ),
        headingTextStyle: const TextStyle(
          fontFamily: fontFamily,
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: AppColors.textMuted,
          letterSpacing: 0.11 * 10,
        ),
        dataTextStyle: const TextStyle(
          fontFamily: fontFamily,
          fontSize: 12.5,
          color: AppColors.text,
          fontWeight: FontWeight.w500,
        ),
        dividerThickness: 1,
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.panel,
        contentTextStyle: const TextStyle(
          fontFamily: fontFamily,
          color: AppColors.darkInk,
          fontSize: 13,
        ),
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
      focusColor: AppColors.brand600,
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontFamily: fontDisplay,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.4,
          height: 1.12,
          color: AppColors.text,
        ),
        displayMedium: TextStyle(
          fontFamily: fontDisplay,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.4,
          height: 1.12,
          color: AppColors.text,
        ),
        headlineLarge: TextStyle(
          fontFamily: fontDisplay,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.4,
          color: AppColors.text,
        ),
        headlineMedium: TextStyle(
          fontFamily: fontDisplay,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.3,
          color: AppColors.text,
        ),
        headlineSmall: TextStyle(
          fontFamily: fontDisplay,
          fontWeight: FontWeight.w600,
          color: AppColors.text,
        ),
        titleLarge: TextStyle(fontFamily: fontFamily, fontWeight: FontWeight.w600, color: AppColors.text),
        titleMedium: TextStyle(fontFamily: fontFamily, fontWeight: FontWeight.w600, color: AppColors.text),
        titleSmall: TextStyle(fontFamily: fontFamily, fontWeight: FontWeight.w500, color: AppColors.text),
        bodyLarge: TextStyle(fontFamily: fontFamily, fontWeight: FontWeight.w400, height: 1.55, color: AppColors.text),
        bodyMedium: TextStyle(fontFamily: fontFamily, fontWeight: FontWeight.w400, height: 1.55, color: AppColors.text),
        bodySmall: TextStyle(fontFamily: fontFamily, fontWeight: FontWeight.w400, color: AppColors.textSecondary),
        labelLarge: TextStyle(fontFamily: fontFamily, fontWeight: FontWeight.w600, color: AppColors.text),
        labelMedium: TextStyle(fontFamily: fontFamily, fontWeight: FontWeight.w500, color: AppColors.textSecondary),
        labelSmall: TextStyle(
          fontFamily: fontMono,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.15 * 10,
          color: AppColors.textMuted,
        ),
      ),
    );
  }
}
