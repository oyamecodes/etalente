import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app_logger.dart';

/// Forwards Riverpod lifecycle failures to [AppLogger].
///
/// We deliberately only log *failures* — not every add / update / dispose —
/// so the logs stay useful. Controllers that catch errors internally (the
/// [AsyncNotifier] pattern: `AsyncValue.error`) will also surface here,
/// which is exactly what we want for debugging network / auth flows.
class LoggingProviderObserver extends ProviderObserver {
  const LoggingProviderObserver();

  @override
  void providerDidFail(
    ProviderBase<Object?> provider,
    Object error,
    StackTrace stackTrace,
    ProviderContainer container,
  ) {
    AppLogger.error(
      'Provider failed: ${provider.name ?? provider.runtimeType}',
      name: 'riverpod',
      error: error,
      stackTrace: stackTrace,
    );
  }
}
