import '../domain/auth_session.dart';
import 'auth_api.dart';

/// Application-facing auth contract. A repository-shaped seam keeps the
/// controller decoupled from HTTP specifics — handy for widget tests and
/// for adding persistence later (e.g. `flutter_secure_storage`).
class AuthRepository {
  AuthRepository(this._api);

  final AuthApi _api;

  Future<AuthSession> login({
    required String email,
    required String password,
  }) =>
      _api.login(email: email, password: password);

  Future<AuthSession> signUp({
    required String name,
    required String email,
    required String password,
    required String confirmPassword,
    required bool acceptTerms,
  }) =>
      _api.signUp(
        name: name,
        email: email,
        password: password,
        confirmPassword: confirmPassword,
        acceptTerms: acceptTerms,
      );
}
