import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Brand mark: developer brackets, sequence cross-line, two nodes.
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
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _LogoPainter(onDark: onDark),
      ),
    );
  }
}

class _LogoPainter extends CustomPainter {
  final bool onDark;

  _LogoPainter({required this.onDark});

  @override
  void paint(Canvas canvas, Size size) {
    final brackets = Paint()
      ..color = onDark ? AppColors.brand300 : AppColors.brand900
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.1
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final cross = Paint()
      ..color = onDark ? AppColors.brand200 : AppColors.brand600
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.08
      ..strokeCap = StrokeCap.round;

    final nodes = Paint()
      ..color = onDark ? AppColors.brand400 : AppColors.brand700
      ..style = PaintingStyle.fill;

    final w = size.width;
    final h = size.height;
    final inset = w * 0.12;

    // Left bracket <
    final left = Path()
      ..moveTo(inset + w * 0.22, inset)
      ..lineTo(inset, h * 0.5)
      ..lineTo(inset + w * 0.22, h - inset);
    canvas.drawPath(left, brackets);

    // Right bracket >
    final right = Path()
      ..moveTo(w - inset - w * 0.22, inset)
      ..lineTo(w - inset, h * 0.5)
      ..lineTo(w - inset - w * 0.22, h - inset);
    canvas.drawPath(right, brackets);

    // Sequence cross-line
    canvas.drawLine(
      Offset(w * 0.32, h * 0.5),
      Offset(w * 0.68, h * 0.5),
      cross,
    );

    // Two nodes
    final r = w * 0.07;
    canvas.drawCircle(Offset(w * 0.38, h * 0.5), r, nodes);
    canvas.drawCircle(Offset(w * 0.62, h * 0.5), r, nodes);
  }

  @override
  bool shouldRepaint(covariant _LogoPainter oldDelegate) =>
      oldDelegate.onDark != onDark;
}
