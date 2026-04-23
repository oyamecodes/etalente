import 'package:flutter/material.dart';

import '../../../../app/theme.dart';

/// Outlined white button with an icon + label, used for the Google and
/// LinkedIn sign-in alternatives (UI-only, per the assessment brief).
class SocialSignInButton extends StatelessWidget {
  const SocialSignInButton({
    super.key,
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          backgroundColor: AppColors.surface,
          foregroundColor: AppColors.onSurface,
          side: const BorderSide(color: AppColors.outlineBorder, width: 1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18, color: AppColors.onSurface),
            const SizedBox(width: 10),
            Text(label, style: AppTextStyles.socialButton),
          ],
        ),
      ),
    );
  }
}
