import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/auth/application/auth_controller.dart';
import '../features/auth/presentation/sign_in_page.dart';
import '../features/auth/presentation/sign_up_page.dart';
import '../features/jobs/presentation/job_board_page.dart';
import '../features/jobs/presentation/job_details_page.dart';

/// Paths that do NOT require an authenticated session.
const _publicPaths = <String>{'/', '/sign-up'};

/// Top-level router.
///
/// Exposed both as a plain factory ([buildRouter]) for widget tests
/// that want to land on a specific location with a fake session, and as
/// a Riverpod provider ([routerProvider]) wired into the real app shell
/// so sign-in / sign-out transitions trigger redirects.
///
/// Guard rules:
/// - Unauthenticated visits to any non-public path → `/`.
/// - Authenticated visits to `/` or `/sign-up` → `/jobs` (avoids
///   reviewing the sign-in page while already logged in on hot-reload).
///
/// Widget tests that need to land on `/jobs` without a session should
/// either call [buildRouter] with a session override, or stick a fake
/// session on `authSessionProvider` before pumping.
GoRouter buildRouter({
  String initialLocation = '/',
  Listenable? refreshListenable,
  bool Function()? isSignedIn,
}) {
  return GoRouter(
    initialLocation: initialLocation,
    refreshListenable: refreshListenable,
    redirect: isSignedIn == null
        ? null
        : (context, state) {
            final signedIn = isSignedIn();
            final location = state.matchedLocation;
            final isPublic = _publicPaths.contains(location);
            if (!signedIn && !isPublic) return '/';
            if (signedIn && isPublic) return '/jobs';
            return null;
          },
    routes: [
      GoRoute(
        path: '/',
        name: 'signIn',
        builder: (_, _) => const SignInPage(),
      ),
      GoRoute(
        path: '/sign-up',
        name: 'signUp',
        builder: (_, _) => const SignUpPage(),
      ),
      GoRoute(
        path: '/jobs',
        name: 'jobBoard',
        builder: (_, _) => const JobBoardPage(),
      ),
      GoRoute(
        path: '/jobs/:id',
        name: 'jobDetails',
        builder: (_, state) =>
            JobDetailsPage(jobId: state.pathParameters['id']!),
      ),
    ],
  );
}

/// Minimal `Listenable` that GoRouter can watch to refresh its guards
/// whenever the Riverpod-held session flips between null and non-null.
class _AuthListenable extends ChangeNotifier {
  _AuthListenable(Ref ref) {
    ref.listen(
      authSessionProvider,
      (prev, next) {
        final wasIn = prev != null;
        final isIn = next != null;
        if (wasIn != isIn) notifyListeners();
      },
    );
  }
}

/// Riverpod-owned [GoRouter] used by the real app shell. Keeps the
/// session-aware guard outside widget tests — tests that don't want
/// the guard just instantiate [buildRouter] directly without passing
/// `isSignedIn`.
final routerProvider = Provider<GoRouter>((ref) {
  final listenable = _AuthListenable(ref);
  ref.onDispose(listenable.dispose);
  return buildRouter(
    refreshListenable: listenable,
    isSignedIn: () => ref.read(authSessionProvider) != null,
  );
});
