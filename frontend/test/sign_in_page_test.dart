import 'package:etalente/app/router.dart';
import 'package:etalente/features/auth/application/auth_controller.dart';
import 'package:etalente/features/auth/data/auth_repository.dart';
import 'package:etalente/features/auth/domain/auth_session.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _FakeAuthRepository extends Mock implements AuthRepository {}

Future<void> _pumpSignIn(WidgetTester tester, AuthRepository repo) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        authRepositoryProvider.overrideWithValue(repo),
      ],
      child: MaterialApp.router(routerConfig: buildRouter()),
    ),
  );
  // Let riverpod build initial state.
  await tester.pump();
}

void main() {
  testWidgets('renders all labelled controls from the mock', (tester) async {
    final repo = _FakeAuthRepository();
    await _pumpSignIn(tester, repo);

    expect(find.text('Sign In'), findsOneWidget);
    expect(find.text('THE ARCHITECTURAL AUTHORITY'), findsOneWidget);
    expect(find.text('EMAIL ADDRESS'), findsOneWidget);
    expect(find.text('PASSWORD'), findsOneWidget);
    expect(find.text('Forgot Password?'), findsOneWidget);
    expect(find.text('SIGN IN'), findsOneWidget);
    expect(find.text('OR CONTINUE WITH'), findsOneWidget);
    expect(find.text('Google'), findsOneWidget);
    expect(find.text('LinkedIn'), findsOneWidget);
    expect(find.text("Don't have an account?"), findsOneWidget);
    expect(find.text('Sign up'), findsOneWidget);
    expect(find.text('SECURE SSL'), findsOneWidget);
    expect(find.text('POPIA COMPLIANT'), findsOneWidget);
  });

  testWidgets('shows validation error when email is malformed',
      (tester) async {
    final repo = _FakeAuthRepository();
    await _pumpSignIn(tester, repo);

    // Clear the pre-populated email and enter something invalid.
    final emailField = find.byType(TextFormField).first;
    await tester.enterText(emailField, 'not-an-email');
    await tester.enterText(find.byType(TextFormField).last, 'secret123');

    await tester.tap(find.text('SIGN IN'));
    await tester.pump();

    expect(find.text('Enter a valid email address'), findsOneWidget);
    verifyNever(() => repo.login(
          email: any(named: 'email'),
          password: any(named: 'password'),
        ));
  });

  testWidgets('shows validation error when password is too short',
      (tester) async {
    final repo = _FakeAuthRepository();
    await _pumpSignIn(tester, repo);

    await tester.enterText(find.byType(TextFormField).last, '123');
    await tester.tap(find.text('SIGN IN'));
    await tester.pump();

    expect(find.text('Password must be at least 6 characters'), findsOneWidget);
  });

  testWidgets('calls repository with trimmed email on submit',
      (tester) async {
    final repo = _FakeAuthRepository();
    when(() => repo.login(
          email: any(named: 'email'),
          password: any(named: 'password'),
        )).thenAnswer((_) async => const AuthSession(
          token: 'mock-jwt-token',
          user: AuthenticatedUser(
              id: '1', email: 'a@b.co', name: 'Recruitment Admin'),
        ));

    await _pumpSignIn(tester, repo);

    await tester.enterText(find.byType(TextFormField).first, '  a@b.co  ');
    await tester.enterText(find.byType(TextFormField).last, 'secret123');
    await tester.tap(find.text('SIGN IN'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 10));

    verify(() => repo.login(email: 'a@b.co', password: 'secret123'))
        .called(1);
  });

  testWidgets('toggles password visibility when the eye icon is tapped',
      (tester) async {
    final repo = _FakeAuthRepository();
    await _pumpSignIn(tester, repo);

    // Initially obscured → visibility icon visible.
    expect(find.byIcon(Icons.visibility_outlined), findsOneWidget);
    await tester.tap(find.byIcon(Icons.visibility_outlined));
    await tester.pump();
    expect(find.byIcon(Icons.visibility_off_outlined), findsOneWidget);
  });
}
