import 'package:etalente/features/assistant/data/assistant_repository.dart';
import 'package:etalente/features/assistant/domain/assistant_reply.dart';
import 'package:etalente/features/jobs/data/job_repository.dart';
import 'package:etalente/features/jobs/domain/job.dart';
import 'package:etalente/features/stats/data/stats_repository.dart';
import 'package:etalente/features/stats/domain/stats.dart';
import 'package:mocktail/mocktail.dart';

/// Fakes used by widget tests that happen to navigate through the Job
/// Board. They return empty / zero data so downstream widgets render
/// without needing a real backend.
class FakeJobRepository extends Mock implements JobRepository {
  FakeJobRepository() {
    when(() => listJobs(
          type: any(named: 'type'),
          experience: any(named: 'experience'),
          location: any(named: 'location'),
          search: any(named: 'search'),
          page: any(named: 'page'),
          size: any(named: 'size'),
          bearerToken: any(named: 'bearerToken'),
        )).thenAnswer(
      (_) async => const JobPage(content: [], page: 0, size: 20, total: 0),
    );
    when(() => findById(any(), bearerToken: any(named: 'bearerToken')))
        .thenAnswer(
      (invocation) async => JobDetail(
        id: invocation.positionalArguments.first as String,
        title: 'Senior Flutter Engineer',
        location: 'Cape Town, ZA',
        type: 'Full-time',
        experience: '5+ Years',
        salaryRange: 'R85k - R120k',
        postedBy: 'Recruitment Team',
        closingDate: '2026-05-24',
        description: 'Fake description for tests.',
        skills: const ['Flutter', 'Dart', 'Riverpod'],
      ),
    );
  }
}

class FakeStatsRepository extends Mock implements StatsRepository {
  FakeStatsRepository() {
    when(() => fetch(bearerToken: any(named: 'bearerToken'))).thenAnswer(
      (_) async => const Stats(
        activePosts: 0,
        newApplicants: 0,
        interviewsToday: 0,
      ),
    );
  }
}

class FakeAssistantRepository extends Mock implements AssistantRepository {
  FakeAssistantRepository() {
    when(() => sendMessage(any(), bearerToken: any(named: 'bearerToken')))
        .thenAnswer(
      (_) async => const AssistantReply(
        reply: 'ok',
        timestamp: '2026-01-01T00:00:00Z',
        source: 'canned',
      ),
    );
  }
}
