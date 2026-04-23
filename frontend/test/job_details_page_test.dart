import 'package:etalente/app/router.dart';
import 'package:etalente/features/assistant/application/assistant_controller.dart';
import 'package:etalente/features/auth/application/auth_controller.dart';
import 'package:etalente/features/auth/domain/auth_session.dart';
import 'package:etalente/features/jobs/application/job_board_controller.dart';
import 'package:etalente/features/jobs/domain/job.dart';
import 'package:etalente/features/stats/application/stats_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'test_helpers/fake_dashboard_repos.dart';

Future<void> _pumpDetails(
  WidgetTester tester, {
  required FakeJobRepository jobs,
  String id = 'job-1',
}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        authSessionProvider.overrideWith(
          (ref) => const AuthSession(
            token: 'test-token',
            user: AuthenticatedUser(
              id: '1',
              email: 'a@b.co',
              name: 'Test User',
            ),
          ),
        ),
        jobRepositoryProvider.overrideWithValue(jobs),
        statsRepositoryProvider.overrideWithValue(FakeStatsRepository()),
        assistantRepositoryProvider.overrideWithValue(FakeAssistantRepository()),
      ],
      child: MaterialApp.router(
        routerConfig: buildRouter(initialLocation: '/jobs/$id'),
      ),
    ),
  );
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 10));
}

void main() {
  testWidgets('renders title, skills and description from the repository',
      (tester) async {
    final jobs = FakeJobRepository();
    when(() => jobs.findById(any(), bearerToken: any(named: 'bearerToken')))
        .thenAnswer(
      (_) async => const JobDetail(
        id: 'job-1',
        title: 'Principal Platform Engineer',
        location: 'Johannesburg, ZA',
        type: 'Full-time',
        experience: '7+ Years',
        salaryRange: 'R1.2M – R1.5M',
        postedBy: 'Enviro365',
        closingDate: '2026-07-15',
        description: 'Lead the platform team on mission-critical systems.',
        skills: ['Kubernetes', 'Go', 'Terraform'],
      ),
    );

    await _pumpDetails(tester, jobs: jobs);

    expect(find.text('Principal Platform Engineer'), findsOneWidget);
    expect(find.text('Kubernetes'), findsOneWidget);
    expect(find.text('Terraform'), findsOneWidget);
    expect(find.textContaining('Lead the platform team'), findsOneWidget);
    expect(find.text('Apply Now'), findsOneWidget);
    verify(() => jobs.findById('job-1', bearerToken: 'test-token')).called(1);
  });

  testWidgets('renders error state with Retry when repository throws',
      (tester) async {
    final jobs = FakeJobRepository();
    when(() => jobs.findById(any(), bearerToken: any(named: 'bearerToken')))
        .thenThrow(Exception('boom'));

    await _pumpDetails(tester, jobs: jobs);

    expect(find.text("Couldn't load job"), findsOneWidget);
    expect(find.text('Retry'), findsOneWidget);
    expect(find.text('Back'), findsOneWidget);
  });
}
