import 'package:flutter/material.dart';

/// AGenomics POC v7.3 palette — navy surfaces + teal accent.
/// Mirrors the Clinical Intelligence Platform reference (dark shell, light content).
class AppColors {
  AppColors._();

  // Teal brand ramp (reference --tl / --tl2)
  static const Color brand50 = Color(0xFFF0FDFA);
  static const Color brand100 = Color(0xFFCCFBF1);
  static const Color brand200 = Color(0xFF99F6E4);
  static const Color brand300 = Color(0xFF5EEAD4);
  static const Color brand400 = Color(0xFF2DD4BF); // Dark-theme teal
  static const Color brand500 = Color(0xFF14B8A6);
  static const Color brand600 = Color(0xFF0D9488); // Light-theme primary
  static const Color brand700 = Color(0xFF0F766E);
  static const Color brand800 = Color(0xFF115E59);
  static const Color brand900 = Color(0xFF134E4A);
  static const Color brand950 = Color(0xFF042F2E);

  // Dark navy surfaces (reference --bg / --bg2 / --pan / --side2)
  static const Color night = Color(0xFF070D16);
  static const Color night2 = Color(0xFF0B1421);
  static const Color panel = Color(0xFF0F1B2C);
  static const Color panel2 = Color(0xFF132339);
  static const Color side2 = Color(0xFF080F1A);
  static const Color onTeal = Color(0xFF04121A);

  // Semantic aliases
  static const Color primary = brand600;
  static const Color secondary = brand700;
  static const Color primaryDark = brand800;
  static const Color accent = brand400;

  static const Color primaryLight = Color(0xFFE6FAF7); // tlq ~9% on light
  static const Color primaryMid = Color(0xFF99E6DC);

  // Ink / text (reference light --ink / --t2 / --t3 / --t4)
  static const Color slate = Color(0xFF0E1B2E);
  static const Color ink = Color(0xFF0E1B2E);
  static const Color sidebar = night2;
  static const Color text = ink;
  static const Color textSecondary = Color(0xFF41536B);
  static const Color textTertiary = Color(0xFF657A94);
  static const Color textMuted = Color(0xFF93A3B8);

  // Light surfaces
  static const Color background = Color(0xFFF4F7FA);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceLight = Color(0xFFF8FAFC);

  // Borders (reference --bd / --bd2 light)
  static const Color border = Color(0xFFE4EAF1);
  static const Color borderLight = Color(0xFFEEF2F7);
  static const Color borderStrong = Color(0xFFCBD5E1);

  // Dark-shell text / borders
  static const Color darkInk = Color(0xFFEAF2FB);
  static const Color darkText2 = Color(0xFFA8BDD4);
  static const Color darkText3 = Color(0xFF6E88A6);
  static const Color darkText4 = Color(0xFF4A6180);
  static const Color darkBorder = Color(0xFF1E3149);
  static const Color darkBorder2 = Color(0xFF2A4462);

  // Alerts (reference light semantic)
  static const Color success = Color(0xFF047857);
  static const Color successBg = Color(0xFFE6F7F0);
  static const Color successRing = Color(0xFFA7F3D0);

  static const Color warning = Color(0xFFB45309);
  static const Color warningBg = Color(0xFFFBF3E8);
  static const Color warningRing = Color(0xFFFDE68A);

  static const Color error = Color(0xFFDC2626);
  static const Color errorBg = Color(0xFFFEF2F2);
  static const Color errorRing = Color(0xFFFECACA);

  static const Color info = brand600;
  static const Color infoBg = Color(0xFFE6FAF7);
  static const Color infoRing = Color(0xFF99E6DC);

  static const Color purple = Color(0xFF6D28D9);
  static const Color purpleBg = Color(0xFFF3EEFF);
  static const Color purpleRing = Color(0xFFC4B5FD);

  // Radii — reference --r: 10px
  static const double radius = 10;
  static const double radiusLarge = 10;
  static const double radiusSmall = 7;
  static const double radiusPill = 20;

  // Soft navy-tinted shadows (reference light --sh)
  static const List<BoxShadow> shadowCard = [
    BoxShadow(
      color: Color(0x0D0E1B2E),
      blurRadius: 2,
      offset: Offset(0, 1),
    ),
    BoxShadow(
      color: Color(0x120E1B2E),
      blurRadius: 20,
      offset: Offset(0, 6),
    ),
  ];

  static const List<BoxShadow> shadowGlow = [
    BoxShadow(
      color: Color(0x472DD4BF),
      blurRadius: 14,
      offset: Offset(0, 3),
    ),
  ];

  static const List<BoxShadow> shadowButton = [
    BoxShadow(
      color: Color(0x330D9488),
      blurRadius: 16,
      spreadRadius: -4,
      offset: Offset(0, 6),
    ),
  ];
}
