import 'package:flutter/material.dart';

import '../../../../app/theme.dart';

/// Outlined text field used on the sign-up page.
///
/// Visually distinct from [LabeledTextField] (used on sign-in):
/// a thin grey rounded outline with the label floating at the top-left,
/// matching the real eTalente website style. Required-field asterisk
/// is rendered in red at the end of the label, like the reference.
class OutlinedLabeledField extends StatelessWidget {
  const OutlinedLabeledField({
    super.key,
    required this.label,
    required this.controller,
    this.required = true,
    this.obscureText = false,
    this.keyboardType,
    this.textInputAction,
    this.autofillHints,
    this.validator,
    this.onSubmitted,
    this.suffix,
  });

  final String label;
  final TextEditingController controller;
  final bool required;
  final bool obscureText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final Iterable<String>? autofillHints;
  final String? Function(String?)? validator;
  final ValueChanged<String>? onSubmitted;
  final Widget? suffix;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      autofillHints: autofillHints,
      style: AppTextStyles.inputText,
      validator: validator,
      onFieldSubmitted: onSubmitted,
      decoration: InputDecoration(
        label: _LabelWithAsterisk(label: label, required: required),
        labelStyle: AppTextStyles.floatingLabel,
        floatingLabelStyle:
            AppTextStyles.floatingLabel.copyWith(color: AppColors.mutedText),
        filled: true,
        fillColor: Colors.white,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 18),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: const BorderSide(color: AppColors.fieldBorder, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide:
              const BorderSide(color: AppColors.navyAction, width: 1.4),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: const BorderSide(color: Colors.redAccent, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: const BorderSide(color: Colors.redAccent, width: 1.4),
        ),
        suffixIcon: suffix,
      ),
    );
  }
}

class _LabelWithAsterisk extends StatelessWidget {
  const _LabelWithAsterisk({required this.label, required this.required});
  final String label;
  final bool required;

  @override
  Widget build(BuildContext context) {
    // Two separate Text widgets rather than a RichText so widget tests
    // can locate the label with a plain `find.text('Full Name')`.
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label, style: AppTextStyles.floatingLabel),
        if (required)
          const Text(
            ' *',
            style: TextStyle(color: Colors.redAccent, fontSize: 13),
          ),
      ],
    );
  }
}
