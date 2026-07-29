import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_theme.dart';

enum StatusBadgeType { live, sandbox, off, success, warning, error, info, teal }

class StatusBadge extends StatelessWidget {
  final String label;
  final StatusBadgeType type;
  final bool showDot;

  const StatusBadge({
    super.key,
    required this.label,
    this.type = StatusBadgeType.teal,
    this.showDot = false,
  });

  @override
  Widget build(BuildContext context) {
    final (bg, fg, border) = switch (type) {
      StatusBadgeType.live || StatusBadgeType.success => (
        AppColors.successBg,
        AppColors.success,
        AppColors.successRing,
      ),
      StatusBadgeType.sandbox || StatusBadgeType.warning => (
        AppColors.warningBg,
        AppColors.warning,
        AppColors.warningRing,
      ),
      StatusBadgeType.error => (
        AppColors.errorBg,
        AppColors.error,
        AppColors.errorRing,
      ),
      StatusBadgeType.info => (
        AppColors.infoBg,
        AppColors.info,
        AppColors.infoRing,
      ),
      StatusBadgeType.teal => (
        AppColors.primaryLight,
        AppColors.brand700,
        AppColors.primaryMid,
      ),
      StatusBadgeType.off => (
        AppColors.surfaceLight,
        AppColors.textSecondary,
        AppColors.border,
      ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppColors.radiusPill),
        border: Border.all(color: border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (showDot) ...[
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(color: fg, shape: BoxShape.circle),
            ),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: TextStyle(
              fontFamily: AppTheme.fontFamily,
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: fg,
            ),
          ),
        ],
      ),
    );
  }
}
