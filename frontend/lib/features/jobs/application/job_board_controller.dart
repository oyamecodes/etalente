import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/application/auth_controller.dart';
import '../data/job_api.dart';
import '../data/job_repository.dart';
import '../domain/job.dart';

final jobApiProvider =
    Provider<JobApi>((ref) => JobApi(ref.watch(apiClientProvider)));

final jobRepositoryProvider = Provider<JobRepository>(
  (ref) => JobRepository(ref.watch(jobApiProvider)),
);

/// UI-level filter state. Each filter maps to a query param the backend
/// already understands (`type`, `experience`, `search`). "All Filters" is
/// represented as `type == null`.
class JobBoardFilters {
  const JobBoardFilters({
    this.type,
    this.experience,
    this.search,
  });

  final String? type;
  final String? experience;
  final String? search;

  JobBoardFilters copyWith({
    Object? type = _sentinel,
    Object? experience = _sentinel,
    Object? search = _sentinel,
  }) {
    return JobBoardFilters(
      type: identical(type, _sentinel) ? this.type : type as String?,
      experience:
          identical(experience, _sentinel) ? this.experience : experience as String?,
      search: identical(search, _sentinel) ? this.search : search as String?,
    );
  }

  static const _sentinel = Object();
}

final jobBoardFiltersProvider = StateProvider<JobBoardFilters>(
  (_) => const JobBoardFilters(),
);

/// Controller that fetches jobs honouring the current filter state. The
/// page currently renders *all* results in one scrollable column; the
/// default size=100 exploits the backend's cap so we avoid implementing
/// infinite-scroll plumbing up-front.
class JobBoardController extends AsyncNotifier<JobPage> {
  @override
  Future<JobPage> build() async {
    final filters = ref.watch(jobBoardFiltersProvider);
    final session = ref.watch(authSessionProvider);
    return ref.read(jobRepositoryProvider).listJobs(
          type: filters.type,
          experience: filters.experience,
          search: filters.search,
          size: 100,
          bearerToken: session?.token,
        );
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(build);
  }
}

final jobBoardControllerProvider =
    AsyncNotifierProvider<JobBoardController, JobPage>(JobBoardController.new);
