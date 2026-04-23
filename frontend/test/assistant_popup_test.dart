import 'package:etalente/app/router.dart';
import 'package:etalente/features/assistant/application/assistant_controller.dart';
import 'package:etalente/features/assistant/domain/assistant_reply.dart';
import 'package:etalente/features/assistant/presentation/widgets/chatbot_assistant_card.dart';
import 'package:etalente/features/auth/application/auth_controller.dart';
import 'package:etalente/features/auth/domain/auth_session.dart';
import 'package:etalente/features/jobs/application/job_board_controller.dart';
import 'package:etalente/features/stats/application/stats_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'test_helpers/fake_dashboard_repos.dart';

Future<void> _pumpJobBoard(
  WidgetTester tester, {
  required FakeAssistantRepository assistant,
}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        authSessionProvider.overrideWith(
          (ref) => const AuthSession(
            token: 'test-token',
            user: AuthenticatedUser(
              id: '1',
              email: 'a@b.co',
              name: 'Test User',
            ),
          ),
        ),
        jobRepositoryProvider.overrideWithValue(FakeJobRepository()),
        statsRepositoryProvider.overrideWithValue(FakeStatsRepository()),
        assistantRepositoryProvider.overrideWithValue(assistant),
      ],
      child: MaterialApp.router(
        routerConfig: buildRouter(initialLocation: '/jobs'),
      ),
    ),
  );
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 10));
}

void main() {
  testWidgets('popup renders header, seeded greeting and quick replies',
      (tester) async {
    final assistant = FakeAssistantRepository();

    await _pumpJobBoard(tester, assistant: assistant);
    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();

    expect(find.text('eTalente Assistant'), findsWidgets);
    expect(find.text('Online • Ready to help'), findsOneWidget);
    expect(find.textContaining("I'm your eTalente Assistant"),
        findsOneWidget);
    expect(find.text('Post New Job'), findsOneWidget);
    expect(find.text('Review Applicants'), findsOneWidget);
  });

  testWidgets('tapping a quick-reply chip sends it as a user message',
      (tester) async {
    final assistant = FakeAssistantRepository();
    when(() => assistant.sendMessage(any(),
            bearerToken: any(named: 'bearerToken')))
        .thenAnswer((_) async => const AssistantReply(
              reply: 'Sure — walk me through the role.',
              timestamp: '2026-01-01T00:00:00Z',
              source: 'canned',
            ));

    await _pumpJobBoard(tester, assistant: assistant);
    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Post New Job'));
    await tester.pumpAndSettle();

    verify(() => assistant.sendMessage('Post New Job',
        bearerToken: any(named: 'bearerToken'))).called(1);
    // Chip label is echoed in the transcript as the user's message.
    expect(find.text('Post New Job'), findsOneWidget);
    expect(find.text('Sure — walk me through the role.'), findsOneWidget);
    // Chips disappear once a user message exists.
    expect(find.text('Review Applicants'), findsNothing);
  });

  testWidgets('FAB hides while the popup is open and reappears on close',
      (tester) async {
    await _pumpJobBoard(tester, assistant: FakeAssistantRepository());

    expect(find.byType(FloatingActionButton), findsOneWidget);

    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();

    expect(find.byType(FloatingActionButton), findsNothing);

    await tester.tap(find.widgetWithIcon(IconButton, Icons.close));
    await tester.pumpAndSettle();

    expect(find.byType(FloatingActionButton), findsOneWidget);
  });
}
