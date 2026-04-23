import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/application/auth_controller.dart';
import '../domain/job.dart';
import 'job_board_controller.dart';

/// Fetches a single job detail from `GET /api/jobs/{id}`. Keyed by job
/// id so revisiting the same job re-uses the cached [AsyncValue].
final jobDetailProvider =
    FutureProvider.family.autoDispose<JobDetail, String>((ref, id) async {
  final repo = ref.watch(jobRepositoryProvider);
  final session = ref.watch(authSessionProvider);
  return repo.findById(id, bearerToken: session?.token);
});
