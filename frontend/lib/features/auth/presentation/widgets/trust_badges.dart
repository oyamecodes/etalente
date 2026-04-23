import 'package:flutter/material.dart';

import '../../../../app/theme.dart';

/// "SECURE SSL" / "POPIA COMPLIANT" row shown under the sign-in card.
class TrustBadges extends StatelessWidget {
  const TrustBadges({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _Badge(icon: Icons.verified_user_outlined, label: 'SECURE SSL'),
          SizedBox(width: 28),
          _Badge(icon: Icons.shield_outlined, label: 'POPIA COMPLIANT'),
        ],
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: AppColors.mutedText),
        const SizedBox(width: 6),
        Text(label, style: AppTextStyles.trustBadge),
      ],
    );
  }
}
