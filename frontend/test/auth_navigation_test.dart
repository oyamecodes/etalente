import 'package:etalente/app/router.dart';
import 'package:etalente/features/auth/application/auth_controller.dart';
import 'package:etalente/features/auth/data/auth_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _FakeAuthRepository extends Mock implements AuthRepository {}

Future<void> _pumpApp(WidgetTester tester, AuthRepository repo) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [authRepositoryProvider.overrideWithValue(repo)],
      child: MaterialApp.router(routerConfig: buildRouter()),
    ),
  );
  await tester.pump();
}

void main() {
  testWidgets('sign-in "Sign up" link navigates to sign-up page',
      (tester) async {
    await _pumpApp(tester, _FakeAuthRepository());

    // On sign-in: the page title "Sign In" is visible.
    expect(find.text('Sign In'), findsOneWidget);

    final link = find.widgetWithText(InkWell, 'Sign up');
    await tester.ensureVisible(link);
    await tester.pumpAndSettle();
    await tester.tap(link);
    await tester.pumpAndSettle();

    // On sign-up: Talent/Employer toggle is near the top of the page.
    expect(find.text('Talent'), findsOneWidget);
    expect(find.text('Employer'), findsOneWidget);
  });

  testWidgets('sign-up "Log In" link navigates back to sign-in page',
      (tester) async {
    await _pumpApp(tester, _FakeAuthRepository());

    // Navigate to sign-up first.
    final signUpLink = find.widgetWithText(InkWell, 'Sign up');
    await tester.ensureVisible(signUpLink);
    await tester.pumpAndSettle();
    await tester.tap(signUpLink);
    await tester.pumpAndSettle();
    expect(find.text('Talent'), findsOneWidget);

    // Now tap the "Log In" link.
    final logIn = find.widgetWithText(InkWell, 'Log In');
    await tester.ensureVisible(logIn);
    await tester.pumpAndSettle();
    await tester.tap(logIn);
    await tester.pumpAndSettle();

    // Back on sign-in.
    expect(find.text('Sign In'), findsOneWidget);
  });
}
