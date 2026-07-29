import 'package:flutter/material.dart';

/// Brand Identity v2 — Deep Indigo & Lavender (July 2026).
/// Supersedes the Emerald palette (Brand Kit v1).
class AppColors {
  AppColors._();

  // Brand ramp
  static const Color brand50 = Color(0xFFF5F4FC);
  static const Color brand100 = Color(0xFFEBE9F9);
  static const Color brand200 = Color(0xFFCECBF6);
  static const Color brand300 = Color(0xFFAFA9EC); // Lavender
  static const Color brand400 = Color(0xFF9189DF);
  static const Color brand500 = Color(0xFF7268CE);
  static const Color brand600 = Color(0xFF5548B8); // Interactive violet
  static const Color brand700 = Color(0xFF443A99);
  static const Color brand800 = Color(0xFF332C77);
  static const Color brand900 = Color(0xFF26215C); // Brand core / Deep Indigo
  static const Color brand950 = Color(0xFF171339);

  static const Color night = Color(0xFF110E28);
  static const Color night2 = Color(0xFF1C1840);

  // Semantic aliases used across the app
  static const Color primary = brand900;
  static const Color secondary = brand600;
  static const Color primaryDark = brand950;
  static const Color accent = brand300;

  static const Color primaryLight = brand50;
  static const Color primaryMid = brand200;

  // Enterprise slate / ink
  static const Color slate = Color(0xFF0F172A);
  static const Color ink = Color(0xFF0F172A);
  static const Color sidebar = night;
  static const Color text = ink;
  static const Color textSecondary = Color(0xFF475569); // slate-600
  static const Color textTertiary = Color(0xFF94A3B8); // slate-400

  static const Color background = Color(0xFFF8FAFC); // soft / slate-50
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceLight = brand50;

  static const Color border = Color(0xFFE4E1F4); // indigo-tint
  static const Color borderLight = brand100;

  // Alerts stay semantic — not remapped into the brand ramp
  static const Color success = Color(0xFF059669);
  static const Color successBg = Color(0xFFECFDF5);
  static const Color successRing = Color(0xFFA7F3D0);

  static const Color warning = Color(0xFFD97706);
  static const Color warningBg = Color(0xFFFFFBEB);
  static const Color warningRing = Color(0xFFFDE68A);

  static const Color error = Color(0xFFDC2626);
  static const Color errorBg = Color(0xFFFEF2F2);
  static const Color errorRing = Color(0xFFFECACA);

  static const Color info = brand600;
  static const Color infoBg = brand50;
  static const Color infoRing = brand200;

  static const Color purple = brand600;
  static const Color purpleBg = brand50;
  static const Color purpleRing = brand200;

  // Radii — cards 16px; actions are pill-shaped
  static const double radius = 12;
  static const double radiusLarge = 16;
  static const double radiusPill = 999;

  // Indigo-tinted shadows (never neutral black on light)
  static const List<BoxShadow> shadowCard = [
    BoxShadow(
      color: Color(0x0A171339),
      blurRadius: 2,
      offset: Offset(0, 1),
    ),
    BoxShadow(
      color: Color(0x1F171339),
      blurRadius: 32,
      spreadRadius: -12,
      offset: Offset(0, 12),
    ),
  ];

  static const List<BoxShadow> shadowGlow = [
    BoxShadow(
      color: Color(0x2EAFA9EC),
      blurRadius: 0,
      spreadRadius: 1,
    ),
    BoxShadow(
      color: Color(0x735548B8),
      blurRadius: 70,
      spreadRadius: -24,
      offset: Offset(0, 24),
    ),
  ];

  static const List<BoxShadow> shadowButton = [
    BoxShadow(
      color: Color(0x4026215C),
      blurRadius: 24,
      spreadRadius: -8,
      offset: Offset(0, 10),
    ),
  ];
}
