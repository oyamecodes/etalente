import '../../../core/api/api_client.dart';
import '../domain/stats.dart';

class StatsApi {
  StatsApi(this._client);

  final ApiClient _client;

  Future<Stats> fetch({String? bearerToken}) async {
    final payload =
        await _client.getJson('/api/stats', bearerToken: bearerToken);
    return Stats.fromJson(payload);
  }
}
