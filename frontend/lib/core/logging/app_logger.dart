import 'dart:async';
import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';

/// Severity levels roughly aligned with standard logging libraries.
/// Mapped onto `dart:developer.log`'s integer levels (mirrors
/// `package:logging`'s `Level` values) so DevTools can filter by severity.
enum LogLevel {
  debug(500, 'DEBUG'),
  info(800, 'INFO'),
  warn(900, 'WARN'),
  error(1000, 'ERROR');

  const LogLevel(this.value, this.label);
  final int value;
  final String label;
}

/// Central logger for the Flutter client.
///
/// Everything funnels through a single [log] method so we can later swap the
/// sink (Sentry, file, in-app overlay, ...) without touching call sites.
///
/// Design notes:
/// - Uses `dart:developer.log` so entries show up in the IDE debugger and
///   Dart DevTools Logging view with source / stack trace attached.
/// - In release mode `debug`/`info` are suppressed; `warn`/`error` are kept
///   so production crashes still surface somewhere.
/// - Never throws. A broken logger must not crash the app.
class AppLogger {
  AppLogger._();

  /// Exposed so tests (or future Sentry wiring) can intercept log records.
  /// Returning `true` from the sink prevents the default `dart:developer`
  /// emission — useful for silencing noisy tests.
  static bool Function(LogRecord record)? sink;

  static void debug(String message, {String name = 'app', Object? error, StackTrace? stackTrace}) =>
      _emit(LogLevel.debug, name, message, error, stackTrace);

  static void info(String message, {String name = 'app', Object? error, StackTrace? stackTrace}) =>
      _emit(LogLevel.info, name, message, error, stackTrace);

  static void warn(String message, {String name = 'app', Object? error, StackTrace? stackTrace}) =>
      _emit(LogLevel.warn, name, message, error, stackTrace);

  static void error(String message, {String name = 'app', Object? error, StackTrace? stackTrace}) =>
      _emit(LogLevel.error, name, message, error, stackTrace);

  static void _emit(
    LogLevel level,
    String name,
    String message,
    Object? error,
    StackTrace? stackTrace,
  ) {
    // In release we still want warn/error; silence the noisy stuff.
    if (kReleaseMode && level.value < LogLevel.warn.value) return;

    final record = LogRecord(
      level: level,
      name: name,
      message: message,
      error: error,
      stackTrace: stackTrace,
      time: DateTime.now(),
    );

    final intercepted = sink?.call(record) ?? false;
    if (intercepted) return;

    developer.log(
      '[${level.label}] $message',
      name: name,
      level: level.value,
      error: error,
      stackTrace: stackTrace,
      time: record.time,
    );
  }

  /// Install global Flutter + Dart error hooks. Call this once from `main()`
  /// after `WidgetsFlutterBinding.ensureInitialized()`.
  ///
  /// - `FlutterError.onError` catches widget/framework errors (layout, build,
  ///   assertion failures, etc).
  /// - `PlatformDispatcher.instance.onError` catches otherwise-unhandled async
  ///   errors at the zone root.
  static void installGlobalErrorHandlers() {
    FlutterError.onError = (FlutterErrorDetails details) {
      error(
        'Uncaught Flutter error: ${details.exceptionAsString()}',
        name: 'flutter',
        error: details.exception,
        stackTrace: details.stack,
      );
      // Preserve Flutter's own red-screen / console dump in debug.
      FlutterError.presentError(details);
    };

    PlatformDispatcher.instance.onError = (Object err, StackTrace stack) {
      error(
        'Uncaught platform/async error',
        name: 'platform',
        error: err,
        stackTrace: stack,
      );
      return true; // handled
    };
  }

  /// Runs [body] in a guarded [Zone] that catches synchronous or async errors
  /// escaping it. Belt-and-braces with [installGlobalErrorHandlers].
  static Future<T> runGuarded<T>(Future<T> Function() body) {
    return runZonedGuarded<Future<T>>(
          body,
          (err, stack) {
            error('Uncaught zone error', name: 'zone', error: err, stackTrace: stack);
          },
        ) ??
        Future<T>.error(StateError('Zone aborted'));
  }
}

/// Value object passed to the optional test sink.
class LogRecord {
  LogRecord({
    required this.level,
    required this.name,
    required this.message,
    required this.time,
    this.error,
    this.stackTrace,
  });

  final LogLevel level;
  final String name;
  final String message;
  final DateTime time;
  final Object? error;
  final StackTrace? stackTrace;
}
