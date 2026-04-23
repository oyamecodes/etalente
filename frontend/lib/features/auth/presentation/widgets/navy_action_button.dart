import 'package:flutter/material.dart';

import '../../../../app/theme.dart';

/// Deep-navy full-width CTA used on the sign-up page ("Create Account").
/// Swaps its label for a spinner while [loading] is true.
class NavyActionButton extends StatelessWidget {
  const NavyActionButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.loading = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 52,
      width: double.infinity,
      child: ElevatedButton(
        onPressed: loading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.navyAction,
          disabledBackgroundColor: AppColors.navyAction.withValues(alpha: 0.6),
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(6),
          ),
        ),
        child: loading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2.4,
                  color: Colors.white,
                ),
              )
            : Text(label, style: AppTextStyles.navyButton),
      ),
    );
  }
}
