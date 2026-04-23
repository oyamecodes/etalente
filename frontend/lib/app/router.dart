import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../features/auth/presentation/sign_in_page.dart';
import '../features/auth/presentation/sign_up_page.dart';

/// Top-level router.
///
/// Navigation is intentionally simple: `/` is the sign-in screen,
/// `/sign-up` is the create-account screen, and `/jobs` is a placeholder
/// post-login landing page until the full job board is built.
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
        builder: (_, _) => Scaffold(
          appBar: AppBar(title: const Text('Job Board')),
          body: const Center(child: Text('Coming soon')),
        ),
      ),
    ],
  );
}
