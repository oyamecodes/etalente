import '../../../core/api/api_client.dart';
import '../domain/job.dart';

/// Thin wrapper around `GET /api/jobs` and `GET /api/jobs/{id}`.
class JobApi {
  JobApi(this._client);

  final ApiClient _client;

  /// Query params are forwarded as-is. The backend trims empty strings
  /// and clamps page/size on its side — see [JobController].
  Future<JobPage> listJobs({
    String? type,
    String? experience,
    String? location,
    String? search,
    int page = 0,
    int size = 20,
    String? bearerToken,
  }) async {
    final payload = await _client.getJson(
      '/api/jobs',
      query: {
        'type': type,
        'experience': experience,
        'location': location,
        'search': search,
        'page': page,
        'size': size,
      },
      bearerToken: bearerToken,
    );
    return JobPage.fromJson(payload);
  }
}
