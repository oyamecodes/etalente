import 'package:etalente/app/router.dart';
import 'package:etalente/features/auth/application/auth_controller.dart';
import 'package:etalente/features/auth/domain/auth_session.dart';
import 'package:etalente/features/jobs/application/job_board_controller.dart';
import 'package:etalente/features/stats/application/stats_controller.dart';
import 'package:etalente/features/assistant/application/assistant_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'test_helpers/fake_dashboard_repos.dart';

/// Verifies the router-level auth guard exposed via `routerProvider`.
///
/// `buildRouter` without `isSignedIn` is the test-only path (no guard)
/// — so these tests pump the Riverpod-owned `routerProvider` with an
/// overridden `authSessionProvider`.
void main() {
  testWidgets('unauthenticated visit to /jobs redirects to /', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          jobRepositoryProvider.overrideWithValue(FakeJobRepository()),
          statsRepositoryProvider.overrideWithValue(FakeStatsRepository()),
          assistantRepositoryProvider
              .overrideWithValue(FakeAssistantRepository()),
        ],
        child: Consumer(
          builder: (context, ref, _) {
            final router = ref.watch(routerProvider);
            router.go('/jobs');
            return MaterialApp.router(routerConfig: router);
          },
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Sign-in hero is rendered — 'Sign In' is the large hero heading.
    expect(find.text('Sign In'), findsOneWidget);
  });

  testWidgets('authenticated visit to / redirects to /jobs', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authSessionProvider.overrideWith(
            (_) => const AuthSession(
              token: 't',
              user: AuthenticatedUser(id: '1', email: 'a@b.co', name: 'A'),
            ),
          ),
          jobRepositoryProvider.overrideWithValue(FakeJobRepository()),
          statsRepositoryProvider.overrideWithValue(FakeStatsRepository()),
          assistantRepositoryProvider
              .overrideWithValue(FakeAssistantRepository()),
        ],
        child: Consumer(
          builder: (context, ref, _) {
            final router = ref.watch(routerProvider);
            return MaterialApp.router(routerConfig: router);
          },
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Job board header text confirms redirect succeeded.
    expect(find.text('Job Board'), findsOneWidget);
  });
}
