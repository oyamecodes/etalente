import 'package:flutter/material.dart';

import '../../../../app/theme.dart';

/// Navy "Sign In" hero block with a faint grid overlay — top section
/// of the sign-in card in the supplied mock.
class SignInHero extends StatelessWidget {
  const SignInHero({super.key});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      child: Stack(
        children: [
          Container(
            color: AppColors.cardNavy,
            padding: const EdgeInsets.symmetric(vertical: 44, horizontal: 24),
            width: double.infinity,
            child: Column(
              children: [
                Text('Sign In', style: AppTextStyles.heroTitle),
                const SizedBox(height: 10),
                Text(
                  'THE ARCHITECTURAL AUTHORITY',
                  style: AppTextStyles.heroSubtitle,
                ),
              ],
            ),
          ),
          Positioned.fill(
            child: IgnorePointer(
              child: CustomPaint(painter: _GridPainter()),
            ),
          ),
        ],
      ),
    );
  }
}

class _GridPainter extends CustomPainter {
  static const double _cell = 18;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.gridOverlay
      ..strokeWidth = 1;

    // Grid is only drawn in the top-right quadrant for the same subtle
    // "blueprint" feel as the mock without overpowering the title.
    final startX = size.width * 0.45;
    for (double x = startX; x <= size.width; x += _cell) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y <= size.height; y += _cell) {
      canvas.drawLine(Offset(startX, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
