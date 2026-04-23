import 'package:etalente/app/router.dart';
import 'package:etalente/features/auth/application/auth_controller.dart';
import 'package:etalente/features/auth/data/auth_repository.dart';
import 'package:etalente/features/auth/domain/auth_session.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _FakeAuthRepository extends Mock implements AuthRepository {}

Future<void> _pumpSignUp(WidgetTester tester, AuthRepository repo) async {
  final router = buildRouter();
  router.go('/sign-up');
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        authRepositoryProvider.overrideWithValue(repo),
      ],
      child: MaterialApp.router(routerConfig: router),
    ),
  );
  await tester.pump();
}

Future<void> _tapCreateAccount(WidgetTester tester) async {
  final button = find.widgetWithText(ElevatedButton, 'Create Account');
  await tester.ensureVisible(button);
  await tester.pumpAndSettle();
  await tester.tap(button);
  await tester.pump();
}

void main() {
  testWidgets('renders all labelled controls from the mock', (tester) async {
    final repo = _FakeAuthRepository();
    await _pumpSignUp(tester, repo);

    expect(find.text('Create Account'), findsNWidgets(2)); // title + CTA
    expect(find.text('eTalente'), findsOneWidget);
    expect(find.text('Talent'), findsOneWidget);
    expect(find.text('Employer'), findsOneWidget);
    expect(find.text('Full Name'), findsOneWidget);
    expect(find.text('E-Mail'), findsOneWidget);
    expect(find.text('Password'), findsOneWidget);
    expect(find.text('Confirm Password'), findsOneWidget);
    // "Terms" and "Privacy Policy" are TextSpans inside a RichText, not
    // plain Text widgets; search the rendered RichText for the inline
    // link labels rather than using find.text (which only matches
    // Text widgets).
    // "Terms" and "Privacy Policy" appear as TextSpans inside the
    // terms-agreement RichText. Match the distinctive "By clicking Create
    // Account" lead-in so we don't collide with the footer's
    // "Terms of Service" link.
    expect(
      find.byWidgetPredicate((w) =>
          w is RichText &&
          w.text.toPlainText().contains('By clicking Create Account') &&
          w.text.toPlainText().contains('Terms') &&
          w.text.toPlainText().contains('Privacy Policy')),
      findsOneWidget,
    );
    expect(find.text('Already have an account?'), findsOneWidget);
    expect(find.text('Log In'), findsOneWidget);
  });

  testWidgets('shows validation errors for empty fields', (tester) async {
    final repo = _FakeAuthRepository();
    await _pumpSignUp(tester, repo);

    await _tapCreateAccount(tester);

    expect(find.text('Name is required'), findsOneWidget);
    expect(find.text('Email is required'), findsOneWidget);
    expect(find.text('Password is required'), findsOneWidget);
    expect(find.text('Please confirm your password'), findsOneWidget);
    verifyNever(() => repo.signUp(
          name: any(named: 'name'),
          email: any(named: 'email'),
          password: any(named: 'password'),
          confirmPassword: any(named: 'confirmPassword'),
          acceptTerms: any(named: 'acceptTerms'),
        ));
  });

  testWidgets('shows mismatched-password error', (tester) async {
    final repo = _FakeAuthRepository();
    await _pumpSignUp(tester, repo);

    final fields = find.byType(TextFormField);
    await tester.enterText(fields.at(0), 'Jane Doe');
    await tester.enterText(fields.at(1), 'jane@etalente.co.za');
    await tester.enterText(fields.at(2), 'secret123');
    await tester.enterText(fields.at(3), 'secret999');

    await _tapCreateAccount(tester);

    expect(find.text('Passwords do not match'), findsOneWidget);
  });

  testWidgets('calls repository with trimmed name/email on submit',
      (tester) async {
    final repo = _FakeAuthRepository();
    when(() => repo.signUp(
          name: any(named: 'name'),
          email: any(named: 'email'),
          password: any(named: 'password'),
          confirmPassword: any(named: 'confirmPassword'),
          acceptTerms: any(named: 'acceptTerms'),
        )).thenAnswer((_) async => const AuthSession(
          token: 'mock-jwt-token',
          user: AuthenticatedUser(
              id: '1', email: 'jane@etalente.co.za', name: 'Jane Doe'),
        ));

    await _pumpSignUp(tester, repo);

    final fields = find.byType(TextFormField);
    await tester.enterText(fields.at(0), '  Jane Doe  ');
    await tester.enterText(fields.at(1), '  jane@etalente.co.za  ');
    await tester.enterText(fields.at(2), 'secret123');
    await tester.enterText(fields.at(3), 'secret123');

    await _tapCreateAccount(tester);
    await tester.pump(const Duration(milliseconds: 10));

    verify(() => repo.signUp(
          name: 'Jane Doe',
          email: 'jane@etalente.co.za',
          password: 'secret123',
          confirmPassword: 'secret123',
          acceptTerms: true,
        )).called(1);
  });

  testWidgets('toggles password visibility independently', (tester) async {
    final repo = _FakeAuthRepository();
    await _pumpSignUp(tester, repo);

    // Two password fields → two visibility-off icons initially.
    expect(find.byIcon(Icons.visibility_off_outlined), findsNWidgets(2));
    await tester.tap(find.byIcon(Icons.visibility_off_outlined).first);
    await tester.pump();
    expect(find.byIcon(Icons.visibility_outlined), findsOneWidget);
    expect(find.byIcon(Icons.visibility_off_outlined), findsOneWidget);
  });

  testWidgets('switches Talent/Employer segments', (tester) async {
    final repo = _FakeAuthRepository();
    await _pumpSignUp(tester, repo);

    // Both tappable; we just verify the tap goes through without error.
    await tester.tap(find.text('Employer'));
    await tester.pump();
    await tester.tap(find.text('Talent'));
    await tester.pump();
  });
}
