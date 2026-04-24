import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/api_client_provider.dart';
import '../data/auth_api.dart';
import '../data/auth_repository.dart';
import '../domain/auth_session.dart';

final authApiProvider =
    Provider<AuthApi>((ref) => AuthApi(ref.watch(apiClientProvider)));

final authRepositoryProvider =
    Provider<AuthRepository>((ref) => AuthRepository(ref.watch(authApiProvider)));

/// Holds the currently signed-in session (in-memory only for now — the
/// assessment explicitly excludes real auth, so persistence is a
/// deliberate out-of-scope).
final authSessionProvider = StateProvider<AuthSession?>((_) => null);

/// Drives the Sign In form: exposes an [AsyncValue] the UI can switch on
/// for loading / error states, and surfaces the resulting [AuthSession]
/// to [authSessionProvider] on success.
class AuthController extends AsyncNotifier<AuthSession?> {
  @override
  Future<AuthSession?> build() async => ref.read(authSessionProvider);

  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final session = await ref
          .read(authRepositoryProvider)
          .login(email: email, password: password);
      ref.read(authSessionProvider.notifier).state = session;
      return session;
    });
  }

  Future<void> signUp({
    required String name,
    required String email,
    required String password,
    required String confirmPassword,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final session = await ref.read(authRepositoryProvider).signUp(
            name: name,
            email: email,
            password: password,
            confirmPassword: confirmPassword,
            // Acceptance is implicit: the user tapped "Create Account",
            // which matches how the real eTalente portal phrases it.
            acceptTerms: true,
          );
      ref.read(authSessionProvider.notifier).state = session;
      return session;
    });
  }
}

final authControllerProvider =
    AsyncNotifierProvider<AuthController, AuthSession?>(AuthController.new);
