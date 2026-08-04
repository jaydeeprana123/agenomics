import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class AppCard extends StatefulWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Color? color;
  final VoidCallback? onTap;

  const AppCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.color,
    this.onTap,
  });

  @override
  State<AppCard> createState() => _AppCardState();
}

class _AppCardState extends State<AppCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final card = AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOut,
      margin: widget.margin,
      padding: widget.padding ?? const EdgeInsets.all(16),
      transform: widget.onTap != null && _hovered
          ? Matrix4.translationValues(0, -4, 0)
          : Matrix4.identity(),
      decoration: BoxDecoration(
        color: widget.color,
        gradient: widget.color == null
            ? const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [AppColors.surface, Color(0xFFF8FAFC)],
              )
            : null,
        borderRadius: BorderRadius.circular(AppColors.radiusLarge),
        border: Border.all(
          color: _hovered && widget.onTap != null
              ? AppColors.brand600.withValues(alpha: 0.45)
              : AppColors.border,
        ),
        boxShadow: AppColors.shadowCard,
      ),
      child: widget.child,
    );

    if (widget.onTap == null) return card;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: InkWell(
        onTap: widget.onTap,
        borderRadius: BorderRadius.circular(AppColors.radiusLarge),
        child: card,
      ),
    );
  }
}
