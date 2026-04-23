import 'package:flutter/material.dart';

import '../../../../app/theme.dart';
import '../../../../shared/widgets/app_logo_mark.dart';

/// Dark header band at the very top of the Sign In screen.
class EtalenteHeader extends StatelessWidget {
  const EtalenteHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.backgroundDark,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
      child: Row(
        children: [
          const AppLogoMark(size: 28),
          const SizedBox(width: 12),
          Text('ETALENTE', style: AppTextStyles.logoWordmark),
        ],
      ),
    );
  }
}
