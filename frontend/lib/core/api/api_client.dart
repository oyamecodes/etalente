import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../logging/app_logger.dart';
import 'api_exception.dart';

/// Thin HTTP wrapper around `package:http`. Keeps JSON encoding, header
/// defaults and error shaping in one place so feature repositories stay
/// focused on domain mapping.
class ApiClient {
  ApiClient({http.Client? httpClient, String? baseUrl})
      : _httpClient = httpClient ?? http.Client(),
        _baseUrl = baseUrl ?? defaultBaseUrl;

  final http.Client _httpClient;
  final String _baseUrl;

  /// Base URL resolution order:
  ///
  /// 1. `--dart-define=API_BASE_URL=...` (explicit wins).
  /// 2. Platform defaults: `10.0.2.2:8080` on Android emulator (loopback
  ///    alias to host), `localhost:8080` everywhere else.
  static String get defaultBaseUrl {
    const fromDefine = String.fromEnvironment('API_BASE_URL');
    if (fromDefine.isNotEmpty) return fromDefine;
    if (!kIsWeb && Platform.isAndroid) return 'http://10.0.2.2:8080';
    return 'http://localhost:8080';
  }

  Future<Map<String, dynamic>> postJson(
    String path,
    Map<String, dynamic> body, {
    String? bearerToken,
  }) async {
    final uri = Uri.parse('$_baseUrl$path');
    AppLogger.debug('POST $uri', name: 'api');
    final http.Response response;
    try {
      response = await _httpClient.post(
        uri,
        headers: _headers(bearerToken),
        body: jsonEncode(body),
      );
    } on SocketException catch (e, st) {
      AppLogger.warn('POST $uri network unreachable: ${e.message}',
          name: 'api', error: e, stackTrace: st);
      throw ApiException('Network unreachable: ${e.message}');
    } on http.ClientException catch (e, st) {
      AppLogger.warn('POST $uri client error: ${e.message}',
          name: 'api', error: e, stackTrace: st);
      throw ApiException('Network error: ${e.message}');
    }

    AppLogger.debug('POST $uri → ${response.statusCode}', name: 'api');
    return _decode(response, uri);
  }

  /// GET helper. [query] values are stringified and url-encoded; null
  /// values are dropped so repositories can pass filter params directly
  /// without pre-filtering.
  Future<Map<String, dynamic>> getJson(
    String path, {
    Map<String, Object?>? query,
    String? bearerToken,
  }) async {
    final cleaned = <String, String>{};
    query?.forEach((k, v) {
      if (v == null) return;
      final s = v.toString();
      if (s.isEmpty) return;
      cleaned[k] = s;
    });
    final uri = Uri.parse('$_baseUrl$path').replace(
      queryParameters: cleaned.isEmpty ? null : cleaned,
    );
    AppLogger.debug('GET $uri', name: 'api');
    final http.Response response;
    try {
      response = await _httpClient.get(uri, headers: _headers(bearerToken));
    } on SocketException catch (e, st) {
      AppLogger.warn('GET $uri network unreachable: ${e.message}',
          name: 'api', error: e, stackTrace: st);
      throw ApiException('Network unreachable: ${e.message}');
    } on http.ClientException catch (e, st) {
      AppLogger.warn('GET $uri client error: ${e.message}',
          name: 'api', error: e, stackTrace: st);
      throw ApiException('Network error: ${e.message}');
    }

    AppLogger.debug('GET $uri → ${response.statusCode}', name: 'api');
    return _decode(response, uri);
  }

  Map<String, String> _headers(String? bearerToken) {
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (bearerToken != null && bearerToken.isNotEmpty)
        'Authorization': 'Bearer $bearerToken',
    };
  }

  Map<String, dynamic> _decode(http.Response response, Uri uri) {
    Map<String, dynamic>? payload;
    if (response.body.isNotEmpty) {
      try {
        payload = jsonDecode(response.body) as Map<String, dynamic>;
      } on FormatException catch (e, st) {
        AppLogger.warn(
          'Non-JSON response from $uri (status ${response.statusCode})',
          name: 'api',
          error: e,
          stackTrace: st,
        );
        throw ApiException(
          'Unexpected response (non-JSON, status ${response.statusCode})',
          statusCode: response.statusCode,
        );
      }
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return payload ?? const <String, dynamic>{};
    }

    // Backend uses a consistent error envelope — see common/error.ApiError
    // on the Spring side. Prefer its `message`, fall back to a generic.
    final message = payload?['message'] as String? ??
        'Request failed with status ${response.statusCode}';
    AppLogger.warn(
      '$uri → ${response.statusCode}: $message',
      name: 'api',
    );
    throw ApiException(message, statusCode: response.statusCode);
  }

  void dispose() => _httpClient.close();
}
