import 'package:flutter/material.dart';

import '../../../../app/theme.dart';

/// Two thin rules flanking "OR CONTINUE WITH" — as in the mock.
class OrContinueDivider extends StatelessWidget {
  const OrContinueDivider({super.key});

  @override
  Widget build(BuildContext context) {
    final rule = Expanded(
      child: Container(height: 1, color: AppColors.outlineBorder),
    );
    return Row(
      children: [
        rule,
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'OR CONTINUE WITH',
            style: AppTextStyles.orDivider,
          ),
        ),
        rule,
      ],
    );
  }
}
