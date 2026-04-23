import '../../../core/api/api_client.dart';
import '../domain/auth_session.dart';

/// Thin HTTP boundary for `/api/auth/*`. Kept separate from the
/// repository so a future token-refresh layer (or a fake for tests) can
/// wrap it without churn.
class AuthApi {
  AuthApi(this._client);

  final ApiClient _client;

  Future<AuthSession> login({
    required String email,
    required String password,
  }) async {
    final json = await _client.postJson('/api/auth/login', {
      'email': email,
      'password': password,
    });
    return AuthSession.fromJson(json);
  }

  /// Mirrors `POST /api/auth/signup`. The terms checkbox is collapsed to
  /// a link-click acceptance on the UI side (matching the real eTalente
  /// portal), but the backend still expects the boolean field so we
  /// always send `true` when the user submits.
  Future<AuthSession> signUp({
    required String name,
    required String email,
    required String password,
    required String confirmPassword,
    required bool acceptTerms,
  }) async {
    final json = await _client.postJson('/api/auth/signup', {
      'name': name,
      'email': email,
      'password': password,
      'confirmPassword': confirmPassword,
      'acceptTerms': acceptTerms,
    });
    return AuthSession.fromJson(json);
  }
}
