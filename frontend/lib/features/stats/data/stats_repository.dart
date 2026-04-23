import '../domain/stats.dart';
import 'stats_api.dart';

class StatsRepository {
  StatsRepository(this._api);

  final StatsApi _api;

  Future<Stats> fetch({String? bearerToken}) =>
      _api.fetch(bearerToken: bearerToken);
}
