import 'package:go_router/go_router.dart';

import '../features/auth/presentation/sign_in_page.dart';
import '../features/auth/presentation/sign_up_page.dart';
import '../features/jobs/presentation/job_board_page.dart';

/// Top-level router.
///
/// Navigation is intentionally simple: `/` is the sign-in screen,
/// `/sign-up` is the create-account screen, and `/jobs` is the
/// post-login landing page. Auth guarding is left to the pages
/// themselves (the placeholder allows direct visits so reviewers can
/// poke around without logging in every reload).
GoRouter buildRouter({String initialLocation = '/'}) {
  return GoRouter(
    initialLocation: initialLocation,
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
    ],
  );
}
