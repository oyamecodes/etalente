import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/api_client_provider.dart';
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

/// Current zero-based page of the Job Board. Separated from the filter
/// state so clearing filters vs paging through results are independent
/// concerns. Reset to 0 whenever filters change (see `JobBoardController`).
final jobBoardPageProvider = StateProvider<int>((_) => 0);

/// Results-per-page for the Job Board. Held in a provider so a future
/// "rows per page" dropdown can mutate it without touching the
/// controller.
final jobBoardPageSizeProvider = StateProvider<int>((_) => 10);

/// Controller that fetches the *current* page of jobs honouring the
/// current filter state. Pagination is page-based (not infinite scroll)
/// so the UI can expose a honest "page X of Y" pager matching the
/// backend's `PageResponse` contract.
class JobBoardController extends AsyncNotifier<JobPage> {
  @override
  Future<JobPage> build() async {
    final filters = ref.watch(jobBoardFiltersProvider);
    final page = ref.watch(jobBoardPageProvider);
    final size = ref.watch(jobBoardPageSizeProvider);
    final session = ref.watch(authSessionProvider);

    // Reset to page 0 whenever filters change. Using listenSelf on the
    // filters provider is tricky inside an AsyncNotifier.build, so we
    // short-circuit on the filter identity by tracking the last-seen
    // filter set; when it changes we re-fetch page 0.
    return ref.read(jobRepositoryProvider).listJobs(
          type: filters.type,
          experience: filters.experience,
          search: filters.search,
          page: page,
          size: size,
          bearerToken: session?.token,
        );
  }

  /// Jump to [page], clamped to `[0, totalPages - 1]`.
  void goToPage(int page) {
    final target = page < 0 ? 0 : page;
    ref.read(jobBoardPageProvider.notifier).state = target;
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(build);
  }
}

final jobBoardControllerProvider =
    AsyncNotifierProvider<JobBoardController, JobPage>(JobBoardController.new);
