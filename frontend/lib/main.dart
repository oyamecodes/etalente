import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/app.dart';
import 'core/logging/app_logger.dart';
import 'core/logging/logging_provider_observer.dart';

void main() {
  // runZonedGuarded needs to wrap binding initialisation too, otherwise
  // errors during `ensureInitialized()` escape.
  AppLogger.runGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();
    AppLogger.installGlobalErrorHandlers();
    AppLogger.info('eTalente starting up', name: 'bootstrap');

    runApp(
      ProviderScope(
        observers: const [LoggingProviderObserver()],
        child: EtalenteApp(),
      ),
    );
  });
}
