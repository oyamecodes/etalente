import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/application/auth_controller.dart';
import '../data/stats_api.dart';
import '../data/stats_repository.dart';
import '../domain/stats.dart';

final statsApiProvider =
    Provider<StatsApi>((ref) => StatsApi(ref.watch(apiClientProvider)));

final statsRepositoryProvider = Provider<StatsRepository>(
  (ref) => StatsRepository(ref.watch(statsApiProvider)),
);

class StatsController extends AsyncNotifier<Stats> {
  @override
  Future<Stats> build() {
    final session = ref.watch(authSessionProvider);
    return ref.read(statsRepositoryProvider).fetch(bearerToken: session?.token);
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(build);
  }
}

final statsControllerProvider =
    AsyncNotifierProvider<StatsController, Stats>(StatsController.new);
