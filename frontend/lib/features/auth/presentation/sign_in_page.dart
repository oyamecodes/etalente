import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme.dart';
import '../application/auth_controller.dart';
import 'widgets/etalente_header.dart';
import 'widgets/labeled_text_field.dart';
import 'widgets/or_continue_divider.dart';
import 'widgets/primary_action_button.dart';
import 'widgets/sign_in_footer.dart';
import 'widgets/sign_in_hero.dart';
import 'widgets/social_sign_in_button.dart';
import 'widgets/trust_badges.dart';

/// The "Sign In" screen.
///
/// Layout is mobile-first and matches the supplied design: dark header,
/// navy hero card + white form, trust badges, dark footer. On viewports
/// ≥ 600 px wide the content is centred inside a fixed-width column so
/// the design doesn't stretch on tablet / desktop.
class SignInPage extends ConsumerStatefulWidget {
  const SignInPage({super.key});

  @override
  ConsumerState<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends ConsumerState<SignInPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController =
      TextEditingController(text: 'talent@etalente.co.za');
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  // RFC-5322 simplified: good enough for client-side validation without
  // false-rejecting legitimate addresses.
  static final RegExp _emailRegex =
      RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    FocusScope.of(context).unfocus();
    await ref.read(authControllerProvider.notifier).signIn(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );

    if (!mounted) return;
    final state = ref.read(authControllerProvider);
    state.when(
      data: (session) {
        if (session != null) {
          context.go('/jobs');
        }
      },
      loading: () {},
      error: (error, _) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error.toString().replaceFirst('ApiException(', 'Error ('))),
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
                      horizontal: 16,
                      vertical: 20,
                    ),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(maxWidth: contentMaxWidth),
                        child: _SignInCard(
                          formKey: _formKey,
                          emailController: _emailController,
                          passwordController: _passwordController,
                          obscurePassword: _obscurePassword,
                          onToggleObscure: () => setState(
                              () => _obscurePassword = !_obscurePassword),
                          onSubmit: _submit,
                          loading: loading,
                          onForgotPassword: () =>
                              _showComingSoon('Forgot password'),
                          onGoogle: () => _showComingSoon('Google sign-in'),
                          onLinkedIn: () =>
                              _showComingSoon('LinkedIn sign-in'),
                          onSignUp: () => context.go('/sign-up'),
                          emailValidator: _validateEmail,
                          passwordValidator: _validatePassword,
                        ),
                      ),
                    ),
                  ),
                  const TrustBadges(),
                  const SignInFooter(),
                ],
              ),
            );
          },
        ),
      ),
    );
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
}

class _SignInCard extends StatelessWidget {
  const _SignInCard({
    required this.formKey,
    required this.emailController,
    required this.passwordController,
    required this.obscurePassword,
    required this.onToggleObscure,
    required this.onSubmit,
    required this.loading,
    required this.onForgotPassword,
    required this.onGoogle,
    required this.onLinkedIn,
    required this.onSignUp,
    required this.emailValidator,
    required this.passwordValidator,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final bool obscurePassword;
  final VoidCallback onToggleObscure;
  final VoidCallback onSubmit;
  final bool loading;
  final VoidCallback onForgotPassword;
  final VoidCallback onGoogle;
  final VoidCallback onLinkedIn;
  final VoidCallback onSignUp;
  final String? Function(String?) emailValidator;
  final String? Function(String?) passwordValidator;

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
      child: Column(
        children: [
          const SignInHero(),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 28, 24, 28),
            child: Form(
              key: formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  LabeledTextField(
                    label: 'Email Address',
                    controller: emailController,
                    hint: 'talent@etalente.co.za',
                    prefixIcon: Icons.mail_outline,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    autofillHints: const [AutofillHints.email],
                    validator: emailValidator,
                  ),
                  const SizedBox(height: 22),
                  LabeledTextField(
                    label: 'Password',
                    controller: passwordController,
                    hint: '••••••••',
                    prefixIcon: Icons.lock_outline,
                    obscureText: obscurePassword,
                    textInputAction: TextInputAction.done,
                    autofillHints: const [AutofillHints.password],
                    onSubmitted: (_) => onSubmit(),
                    validator: passwordValidator,
                    trailingLabel: InkWell(
                      onTap: onForgotPassword,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 4, vertical: 2),
                        child: Text('Forgot Password?',
                            style: AppTextStyles.linkStrong),
                      ),
                    ),
                    suffix: IconButton(
                      splashRadius: 20,
                      icon: Icon(
                        obscurePassword
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                        color: AppColors.mutedText,
                        size: 20,
                      ),
                      onPressed: onToggleObscure,
                    ),
                  ),
                  const SizedBox(height: 24),
                  PrimaryActionButton(
                    label: 'Sign In',
                    onPressed: onSubmit,
                    loading: loading,
                  ),
                  const SizedBox(height: 28),
                  const OrContinueDivider(),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: SocialSignInButton(
                          icon: Icons.person_outline,
                          label: 'Google',
                          onPressed: onGoogle,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: SocialSignInButton(
                          icon: Icons.work_outline,
                          label: 'LinkedIn',
                          onPressed: onLinkedIn,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 22),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("Don't have an account?",
                          style: AppTextStyles.bodyMuted),
                      const SizedBox(width: 6),
                      InkWell(
                        onTap: onSignUp,
                        child: Text('Sign up', style: AppTextStyles.linkStrong),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
