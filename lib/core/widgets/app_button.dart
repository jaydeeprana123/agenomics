import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_theme.dart';

enum AppButtonVariant { primary, secondary, danger, ghost }

class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final IconData? icon;
  final bool isLoading;
  final bool expanded;
  final double? height;

  const AppButton({
    super.key,
    required this.label,
    this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.icon,
    this.isLoading = false,
    this.expanded = false,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    final (bg, fg, border, shadows) = switch (variant) {
      AppButtonVariant.primary => (
          AppColors.brand600,
          Colors.white,
          AppColors.brand600,
          AppColors.shadowButton,
        ),
      AppButtonVariant.secondary => (
          AppColors.surface,
          AppColors.textSecondary,
          AppColors.borderStrong,
          const <BoxShadow>[],
        ),
      AppButtonVariant.danger => (
          AppColors.error,
          Colors.white,
          AppColors.error,
          const <BoxShadow>[],
        ),
      AppButtonVariant.ghost => (
          Colors.transparent,
          AppColors.brand600,
          Colors.transparent,
          const <BoxShadow>[],
        ),
    };

    final radius = BorderRadius.circular(AppColors.radiusSmall);

    final child = Row(
      mainAxisSize: expanded ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (isLoading)
          SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: fg,
            ),
          )
        else ...[
          if (icon != null) ...[
            Icon(icon, size: 16, color: fg),
            const SizedBox(width: 6),
          ],
          Text(
            label,
            style: TextStyle(
              fontFamily: AppTheme.fontFamily,
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: fg,
            ),
          ),
        ],
      ],
    );

    return SizedBox(
      height: height ?? 40,
      width: expanded ? double.infinity : null,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: radius,
          boxShadow: onPressed == null || isLoading ? null : shadows,
        ),
        child: Material(
          color: bg,
          borderRadius: radius,
          child: InkWell(
            onTap: isLoading ? null : onPressed,
            borderRadius: radius,
            hoverColor: variant == AppButtonVariant.primary
                ? AppColors.brand700.withValues(alpha: 0.2)
                : null,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                borderRadius: radius,
                border: Border.all(color: border),
              ),
              alignment: Alignment.center,
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}
