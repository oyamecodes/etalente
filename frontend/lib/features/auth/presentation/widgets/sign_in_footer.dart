import 'package:flutter/material.dart';

import '../../../../app/theme.dart';

/// Dark footer band at the bottom of the Sign In screen.
class SignInFooter extends StatelessWidget {
  const SignInFooter({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: AppColors.backgroundDark,
      padding: const EdgeInsets.fromLTRB(24, 32, 24, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '© 2024 eTalente. The Architectural Authority\nin Talent Acquisition.',
            style: AppTextStyles.footerBody,
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              _FooterLink(label: 'Privacy Policy'),
              SizedBox(width: 32),
              _FooterLink(label: 'Terms of Service'),
            ],
          ),
          const SizedBox(height: 18),
          _FooterLink(label: 'Contact Support'),
        ],
      ),
    );
  }
}

class _FooterLink extends StatelessWidget {
  const _FooterLink({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$label — coming soon'),
            duration: const Duration(seconds: 2),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Text(label, style: AppTextStyles.footerLink),
      ),
    );
  }
}
