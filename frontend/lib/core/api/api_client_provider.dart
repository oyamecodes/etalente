import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'api_client.dart';

/// Cross-cutting HTTP client provider.
///
/// Lives under `core/api/` rather than any one feature because every
/// feature's API layer (`auth`, `jobs`, `stats`, `assistant`) depends
/// on it. Kept as a singleton for the app lifetime; the underlying
/// `http.Client` is closed when the provider is disposed.
final apiClientProvider = Provider<ApiClient>((ref) {
  final client = ApiClient();
  ref.onDispose(client.dispose);
  return client;
});
