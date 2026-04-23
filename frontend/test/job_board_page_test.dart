import 'package:etalente/app/router.dart';
import 'package:etalente/features/assistant/application/assistant_controller.dart';
import 'package:etalente/features/auth/application/auth_controller.dart';
import 'package:etalente/features/auth/domain/auth_session.dart';
import 'package:etalente/features/jobs/application/job_board_controller.dart';
import 'package:etalente/features/jobs/domain/job.dart';
import 'package:etalente/features/stats/application/stats_controller.dart';
import 'package:etalente/features/stats/domain/stats.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'test_helpers/fake_dashboard_repos.dart';

const _job1 = Job(
  id: 'job-1',
  title: 'Senior Flutter Engineer',
  location: 'Cape Town, ZA',
  type: 'Full-time',
  experience: '5+ Years',
  salaryRange: 'R900k – R1.2M',
  postedBy: 'Enviro365',
  closingDate: '2026-06-30',
);

const _job2 = Job(
  id: 'job-2',
  title: 'Contract Backend Developer',
  location: 'Remote',
  type: 'Contract',
  experience: '3+ Years',
  salaryRange: 'R750k – R900k',
  postedBy: 'Enviro365 Labs',
  closingDate: '2026-05-15',
);

/// Pumps the whole app rooted at /jobs with a pre-populated session so
/// the router doesn't kick back to sign-in.
Future<void> _pumpJobBoard(
  WidgetTester tester, {
  required FakeJobRepository jobs,
  FakeStatsRepository? stats,
  FakeAssistantRepository? assistant,
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
        statsRepositoryProvider.overrideWithValue(
          stats ?? FakeStatsRepository(),
        ),
        assistantRepositoryProvider.overrideWithValue(
          assistant ?? FakeAssistantRepository(),
        ),
      ],
      child: MaterialApp.router(
        routerConfig: buildRouter(initialLocation: '/jobs'),
      ),
    ),
  );
  // Let AsyncNotifiers resolve.
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 10));
}

void main() {
  testWidgets('renders page chrome and job cards from the repository',
      (tester) async {
    final jobs = FakeJobRepository();
    when(() => jobs.listJobs(
          type: any(named: 'type'),
          experience: any(named: 'experience'),
          location: any(named: 'location'),
          search: any(named: 'search'),
          page: any(named: 'page'),
          size: any(named: 'size'),
          bearerToken: any(named: 'bearerToken'),
        )).thenAnswer((_) async => const JobPage(
          content: [_job1, _job2],
          page: 0,
          size: 20,
          total: 2,
        ));

    await _pumpJobBoard(tester, jobs: jobs);

    expect(find.text('Job Board'), findsOneWidget);
    expect(find.text('Senior Flutter Engineer'), findsOneWidget);
    expect(find.text('Contract Backend Developer'), findsOneWidget);
    // Filter pill row rendered.
    expect(find.text('All Filters'), findsOneWidget);
    expect(find.text('Experience'), findsOneWidget);
    expect(find.text('Contract'), findsWidgets);
  });

  testWidgets('tapping Contract pill re-fetches with type=Contract',
      (tester) async {
    final jobs = FakeJobRepository();
    when(() => jobs.listJobs(
          type: any(named: 'type'),
          experience: any(named: 'experience'),
          location: any(named: 'location'),
          search: any(named: 'search'),
          page: any(named: 'page'),
          size: any(named: 'size'),
          bearerToken: any(named: 'bearerToken'),
        )).thenAnswer((_) async => const JobPage(
          content: [_job1],
          page: 0,
          size: 20,
          total: 1,
        ));

    await _pumpJobBoard(tester, jobs: jobs);

    // Initial load – no type filter.
    verify(() => jobs.listJobs(
          type: null,
          experience: null,
          location: any(named: 'location'),
          search: null,
          page: any(named: 'page'),
          size: 100,
          bearerToken: 'test-token',
        )).called(1);

    // There are potentially multiple "Contract" texts (pill + tags) – grab
    // the pill via the tune-icon-less InkWell by label predicate.
    await tester.tap(find.widgetWithText(InkWell, 'Contract').first);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 10));

    verify(() => jobs.listJobs(
          type: 'Contract',
          experience: null,
          location: any(named: 'location'),
          search: null,
          page: any(named: 'page'),
          size: 100,
          bearerToken: 'test-token',
        )).called(1);
  });

  testWidgets('renders empty state when the repository returns no jobs',
      (tester) async {
    final jobs = FakeJobRepository(); // default stub returns empty page

    await _pumpJobBoard(tester, jobs: jobs);

    expect(find.text('No jobs match those filters'), findsOneWidget);
  });

  testWidgets('quick stats card shows the fetched numbers', (tester) async {
    final jobs = FakeJobRepository();
    final stats = FakeStatsRepository();
    when(() => stats.fetch(bearerToken: any(named: 'bearerToken')))
        .thenAnswer(
      (_) async => const Stats(
        activePosts: 12,
        newApplicants: 48,
        interviewsToday: 3,
      ),
    );

    await _pumpJobBoard(tester, jobs: jobs, stats: stats);

    expect(find.text('Quick Stats'), findsOneWidget);
    expect(find.text('12'), findsOneWidget);
    expect(find.text('48'), findsOneWidget);
    expect(find.text('3'), findsOneWidget);
  });
}
