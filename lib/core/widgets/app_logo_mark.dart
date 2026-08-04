import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Brand mark: teal rounded square with serif-style "A" (POC .bmark).
class AppLogoMark extends StatelessWidget {
  final double size;
  final bool onDark;

  const AppLogoMark({
    super.key,
    this.size = 28,
    this.onDark = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(size * 0.25),
        gradient: const LinearGradient(
          begin: Alignment(-0.6, -0.8),
          end: Alignment(0.7, 0.9),
          colors: [
            AppColors.brand400,
            AppColors.brand600,
            AppColors.brand700,
          ],
          stops: [0.0, 0.55, 1.0],
        ),
        boxShadow: onDark
            ? [
                BoxShadow(
                  color: AppColors.brand400.withValues(alpha: 0.34),
                  blurRadius: 14,
                  offset: const Offset(0, 3),
                ),
              ]
            : AppColors.shadowGlow,
      ),
      alignment: Alignment.center,
      child: Text(
        'A',
        style: TextStyle(
          fontFamily: 'Mulish',
          fontWeight: FontWeight.w700,
          fontSize: size * 0.53,
          height: 1,
          color: AppColors.onTeal,
        ),
      ),
    );
  }
}
