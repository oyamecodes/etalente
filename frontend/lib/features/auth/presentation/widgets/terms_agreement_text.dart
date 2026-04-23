import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../../../../app/theme.dart';

/// "By clicking Create Account, you agree to our Terms, Privacy Policy"
/// — the inline legal-acceptance sentence that replaces the usual
/// checkbox on the real eTalente portal. Both links are tappable.
class TermsAgreementText extends StatelessWidget {
  const TermsAgreementText({
    super.key,
    required this.onTapTerms,
    required this.onTapPrivacy,
  });

  final VoidCallback onTapTerms;
  final VoidCallback onTapPrivacy;

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        style: AppTextStyles.termsBody,
        children: [
          const TextSpan(text: 'By clicking Create Account, you agree to our '),
          TextSpan(
            text: 'Terms',
            style: AppTextStyles.termsLink,
            recognizer: TapGestureRecognizer()..onTap = onTapTerms,
          ),
          const TextSpan(text: ', '),
          TextSpan(
            text: 'Privacy Policy',
            style: AppTextStyles.termsLink,
            recognizer: TapGestureRecognizer()..onTap = onTapPrivacy,
          ),
        ],
      ),
    );
  }
}
