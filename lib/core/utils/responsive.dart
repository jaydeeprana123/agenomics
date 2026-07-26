import 'package:flutter/material.dart';

enum ScreenType { mobile, tablet, laptop, desktop }

class Responsive {
  Responsive._();

  static const double mobileBreakpoint = 600;
  static const double tabletBreakpoint = 900;
  static const double laptopBreakpoint = 1200;

  static ScreenType of(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    if (width < mobileBreakpoint) return ScreenType.mobile;
    if (width < tabletBreakpoint) return ScreenType.tablet;
    if (width < laptopBreakpoint) return ScreenType.laptop;
    return ScreenType.desktop;
  }

  static bool isMobile(BuildContext context) =>
      of(context) == ScreenType.mobile;

  static bool isTablet(BuildContext context) =>
      of(context) == ScreenType.tablet;

  static bool isDesktop(BuildContext context) {
    final type = of(context);
    return type == ScreenType.laptop || type == ScreenType.desktop;
  }

  static bool showSidebar(BuildContext context) =>
      MediaQuery.sizeOf(context).width >= tabletBreakpoint;

  static double contentMaxWidth(BuildContext context) {
    switch (of(context)) {
      case ScreenType.mobile:
        return double.infinity;
      case ScreenType.tablet:
        return 800;
      case ScreenType.laptop:
        return 1100;
      case ScreenType.desktop:
        return 1400;
    }
  }

  static int formColumns(BuildContext context) {
    switch (of(context)) {
      case ScreenType.mobile:
        return 1;
      case ScreenType.tablet:
        return 2;
      case ScreenType.laptop:
      case ScreenType.desktop:
        return 3;
    }
  }

  static EdgeInsets pagePadding(BuildContext context) {
    if (isMobile(context)) {
      return const EdgeInsets.all(12);
    }
    return const EdgeInsets.all(16);
  }
}
