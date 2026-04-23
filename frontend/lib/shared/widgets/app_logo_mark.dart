import 'dart:math' as math;

import 'package:flutter/material.dart';

/// The compass / divider glyph from the supplied design.
///
/// Rendered via [CustomPainter] rather than an SVG asset so the app
/// works without shipping a binary logo (and so the stroke scales
/// cleanly at any size). Swap this for the official brand asset if /
/// when one becomes available.
class AppLogoMark extends StatelessWidget {
  const AppLogoMark({super.key, this.size = 28, this.color});

  final double size;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: size,
      child: CustomPaint(
        painter: _CompassPainter(color ?? const Color(0xFFF5C64C)),
      ),
    );
  }
}

class _CompassPainter extends CustomPainter {
  _CompassPainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final stroke = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.shortestSide * 0.09
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final fill = Paint()..color = color;

    final pivot = Offset(size.width / 2, size.height * 0.18);
    final legHeight = size.height * 0.72;

    // Left leg
    canvas.drawLine(
      pivot,
      pivot + Offset(-size.width * 0.28, legHeight),
      stroke,
    );
    // Right leg
    canvas.drawLine(
      pivot,
      pivot + Offset(size.width * 0.28, legHeight),
      stroke,
    );
    // Cross-brace about 2/3 down
    final braceY = pivot.dy + legHeight * 0.55;
    final braceLeft = Offset(
      pivot.dx - (legHeight * 0.55) * (0.28 / 0.72),
      braceY,
    );
    final braceRight = Offset(
      pivot.dx + (legHeight * 0.55) * (0.28 / 0.72),
      braceY,
    );
    canvas.drawLine(braceLeft, braceRight, stroke);

    // Pivot circle
    canvas.drawCircle(pivot, size.shortestSide * 0.085, fill);

    // Tip marker (small filled dot at left leg bottom, echoes the mark)
    final leftTip = pivot + Offset(-size.width * 0.28, legHeight);
    canvas.drawCircle(leftTip, size.shortestSide * 0.055, fill);

    // Needle ornamentation (very short slash from pivot up)
    final topTick = pivot + const Offset(0, -6);
    final topTickEnd = topTick + Offset(size.width * 0.05, -size.height * 0.06);
    canvas.drawLine(topTick, topTickEnd, stroke);

    // Subtle arc (optional geometric accent)
    final arcRect = Rect.fromCircle(
      center: Offset(pivot.dx, pivot.dy + legHeight * 0.65),
      radius: size.width * 0.22,
    );
    canvas.drawArc(arcRect, math.pi * 1.15, math.pi * 0.7, false, stroke);
  }

  @override
  bool shouldRepaint(covariant _CompassPainter oldDelegate) =>
      oldDelegate.color != color;
}
