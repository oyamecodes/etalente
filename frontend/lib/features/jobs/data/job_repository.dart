import '../domain/job.dart';
import 'job_api.dart';

/// Repository layer — the only thing presentation code should depend on
/// for jobs. Kept intentionally thin; business rules (filter parsing,
/// search debouncing, etc.) live in the application controller.
class JobRepository {
  JobRepository(this._api);

  final JobApi _api;

  Future<JobPage> listJobs({
    String? type,
    String? experience,
    String? location,
    String? search,
    int page = 0,
    int size = 20,
    String? bearerToken,
  }) {
    return _api.listJobs(
      type: type,
      experience: experience,
      location: location,
      search: search,
      page: page,
      size: size,
      bearerToken: bearerToken,
    );
  }

  Future<JobDetail> findById(String id, {String? bearerToken}) {
    return _api.findById(id, bearerToken: bearerToken);
  }
}
