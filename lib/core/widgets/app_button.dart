import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

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
    final (bg, fg, border) = switch (variant) {
      AppButtonVariant.primary => (
          AppColors.primary,
          Colors.white,
          AppColors.primary,
        ),
      AppButtonVariant.secondary => (
          AppColors.surface,
          AppColors.text,
          AppColors.border,
        ),
      AppButtonVariant.danger => (
          AppColors.error,
          Colors.white,
          AppColors.error,
        ),
      AppButtonVariant.ghost => (
          Colors.transparent,
          AppColors.primary,
          Colors.transparent,
        ),
    };

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
              fontFamily: 'Mulish',
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: fg,
            ),
          ),
        ],
      ],
    );

    return SizedBox(
      height: height ?? 40,
      width: expanded ? double.infinity : null,
      child: Material(
        color: bg,
        borderRadius: BorderRadius.circular(AppColors.radius),
        child: InkWell(
          onTap: isLoading ? null : onPressed,
          borderRadius: BorderRadius.circular(AppColors.radius),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppColors.radius),
              border: Border.all(color: border),
            ),
            alignment: Alignment.center,
            child: child,
          ),
        ),
      ),
    );
  }
}
