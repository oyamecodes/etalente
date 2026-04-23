import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme.dart';
import '../../../shared/widgets/app_logo_mark.dart';
import '../application/auth_controller.dart';
import 'widgets/etalente_header.dart';
import 'widgets/navy_action_button.dart';
import 'widgets/outlined_labeled_field.dart';
import 'widgets/role_toggle.dart';
import 'widgets/sign_in_footer.dart';
import 'widgets/terms_agreement_text.dart';

/// Create-Account screen matching the real eTalente portal
/// (https://etalente.co.za/sign-up) — outlined fields with floating
/// labels, Talent/Employer toggle, inline-link terms acceptance, and a
/// dark-navy CTA. Visually different from [SignInPage] by design: that
/// screen follows the supplied PDF mock, this one follows the live
/// website which the user explicitly asked us to match.
class SignUpPage extends ConsumerStatefulWidget {
  const SignUpPage({super.key});

  @override
  ConsumerState<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends ConsumerState<SignUpPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  AccountRole _role = AccountRole.talent;

  static final RegExp _emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    FocusScope.of(context).unfocus();
    await ref.read(authControllerProvider.notifier).signUp(
          name: _nameController.text.trim(),
          email: _emailController.text.trim(),
          password: _passwordController.text,
          confirmPassword: _confirmController.text,
        );

    if (!mounted) return;
    final state = ref.read(authControllerProvider);
    state.when(
      data: (session) {
        if (session != null) context.go('/jobs');
      },
      loading: () {},
      error: (error, _) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error.toString()
                .replaceFirst('ApiException(', 'Error (')),
          ),
        );
      },
    );
  }

  void _showComingSoon(String label) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$label — coming soon'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    final loading = authState.isLoading;

    return Scaffold(
      backgroundColor: AppColors.pageBackground,
      body: SafeArea(
        top: false,
        bottom: false,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final contentMaxWidth =
                constraints.maxWidth >= 600 ? 440.0 : double.infinity;
            return SingleChildScrollView(
              child: Column(
                children: [
                  const EtalenteHeader(),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 20),
                    child: Center(
                      child: ConstrainedBox(
                        constraints:
                            BoxConstraints(maxWidth: contentMaxWidth),
                        child: _SignUpCard(
                          formKey: _formKey,
                          nameController: _nameController,
                          emailController: _emailController,
                          passwordController: _passwordController,
                          confirmController: _confirmController,
                          obscurePassword: _obscurePassword,
                          obscureConfirm: _obscureConfirm,
                          role: _role,
                          loading: loading,
                          onToggleObscurePassword: () => setState(
                              () => _obscurePassword = !_obscurePassword),
                          onToggleObscureConfirm: () => setState(
                              () => _obscureConfirm = !_obscureConfirm),
                          onRoleChanged: (r) => setState(() => _role = r),
                          onSubmit: _submit,
                          onTapTerms: () => _showComingSoon('Terms'),
                          onTapPrivacy: () =>
                              _showComingSoon('Privacy Policy'),
                          onTapLogIn: () => context.go('/'),
                          nameValidator: _validateName,
                          emailValidator: _validateEmail,
                          passwordValidator: _validatePassword,
                          confirmValidator: _validateConfirm,
                        ),
                      ),
                    ),
                  ),
                  const SignInFooter(),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  String? _validateName(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return 'Name is required';
    if (v.length > 120) return 'Name must be 120 characters or fewer';
    return null;
  }

  String? _validateEmail(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return 'Email is required';
    if (!_emailRegex.hasMatch(v)) return 'Enter a valid email address';
    return null;
  }

  String? _validatePassword(String? value) {
    final v = value ?? '';
    if (v.isEmpty) return 'Password is required';
    if (v.length < 6) return 'Password must be at least 6 characters';
    return null;
  }

  String? _validateConfirm(String? value) {
    if ((value ?? '').isEmpty) return 'Please confirm your password';
    if (value != _passwordController.text) return 'Passwords do not match';
    return null;
  }
}

class _SignUpCard extends StatelessWidget {
  const _SignUpCard({
    required this.formKey,
    required this.nameController,
    required this.emailController,
    required this.passwordController,
    required this.confirmController,
    required this.obscurePassword,
    required this.obscureConfirm,
    required this.role,
    required this.loading,
    required this.onToggleObscurePassword,
    required this.onToggleObscureConfirm,
    required this.onRoleChanged,
    required this.onSubmit,
    required this.onTapTerms,
    required this.onTapPrivacy,
    required this.onTapLogIn,
    required this.nameValidator,
    required this.emailValidator,
    required this.passwordValidator,
    required this.confirmValidator,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController nameController;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final TextEditingController confirmController;
  final bool obscurePassword;
  final bool obscureConfirm;
  final AccountRole role;
  final bool loading;
  final VoidCallback onToggleObscurePassword;
  final VoidCallback onToggleObscureConfirm;
  final ValueChanged<AccountRole> onRoleChanged;
  final VoidCallback onSubmit;
  final VoidCallback onTapTerms;
  final VoidCallback onTapPrivacy;
  final VoidCallback onTapLogIn;
  final String? Function(String?) nameValidator;
  final String? Function(String?) emailValidator;
  final String? Function(String?) passwordValidator;
  final String? Function(String?) confirmValidator;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(24, 32, 24, 28),
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Logo + wordmark (navy, on white) — mirrors the header of
            // the real sign-up page.
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                const AppLogoMark(size: 28, color: AppColors.navyAction),
                const SizedBox(width: 10),
                Text('eTalente', style: AppTextStyles.logoWordmarkNavy),
              ],
            ),
            const SizedBox(height: 20),
            Center(
              child: Text('Create Account',
                  style: AppTextStyles.sectionTitle),
            ),
            const SizedBox(height: 20),
            RoleToggle(value: role, onChanged: onRoleChanged),
            const SizedBox(height: 24),
            OutlinedLabeledField(
              label: 'Full Name',
              controller: nameController,
              keyboardType: TextInputType.name,
              textInputAction: TextInputAction.next,
              autofillHints: const [AutofillHints.name],
              validator: nameValidator,
            ),
            const SizedBox(height: 16),
            OutlinedLabeledField(
              label: 'E-Mail',
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              autofillHints: const [AutofillHints.email],
              validator: emailValidator,
            ),
            const SizedBox(height: 16),
            OutlinedLabeledField(
              label: 'Password',
              controller: passwordController,
              obscureText: obscurePassword,
              textInputAction: TextInputAction.next,
              autofillHints: const [AutofillHints.newPassword],
              validator: passwordValidator,
              suffix: IconButton(
                splashRadius: 20,
                icon: Icon(
                  obscurePassword
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  color: AppColors.mutedText,
                  size: 20,
                ),
                onPressed: onToggleObscurePassword,
              ),
            ),
            const SizedBox(height: 16),
            OutlinedLabeledField(
              label: 'Confirm Password',
              controller: confirmController,
              obscureText: obscureConfirm,
              textInputAction: TextInputAction.done,
              autofillHints: const [AutofillHints.newPassword],
              onSubmitted: (_) => onSubmit(),
              validator: confirmValidator,
              suffix: IconButton(
                splashRadius: 20,
                icon: Icon(
                  obscureConfirm
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  color: AppColors.mutedText,
                  size: 20,
                ),
                onPressed: onToggleObscureConfirm,
              ),
            ),
            const SizedBox(height: 20),
            TermsAgreementText(
              onTapTerms: onTapTerms,
              onTapPrivacy: onTapPrivacy,
            ),
            const SizedBox(height: 20),
            NavyActionButton(
              label: 'Create Account',
              onPressed: onSubmit,
              loading: loading,
            ),
            const SizedBox(height: 20),
            Wrap(
              alignment: WrapAlignment.center,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 6,
              runSpacing: 4,
              children: [
                Text('Already have an account?',
                    style: AppTextStyles.bodyMuted),
                InkWell(
                  onTap: onTapLogIn,
                  child: Text(
                    'Log In',
                    style: AppTextStyles.termsLink
                        .copyWith(fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
