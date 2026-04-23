/// Thrown when an HTTP call returns a non-2xx response or fails to
/// decode. Carries the backend's {@code ApiError} message when available
/// so callers can surface it verbatim to the user.
class ApiException implements Exception {
  ApiException(this.message, {this.statusCode});

  final String message;
  final int? statusCode;

  @override
  String toString() => 'ApiException(${statusCode ?? '-'}): $message';
}
