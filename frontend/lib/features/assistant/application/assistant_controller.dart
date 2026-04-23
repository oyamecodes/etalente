import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/application/auth_controller.dart';
import '../data/assistant_api.dart';
import '../data/assistant_repository.dart';

final assistantApiProvider =
    Provider<AssistantApi>((ref) => AssistantApi(ref.watch(apiClientProvider)));

final assistantRepositoryProvider = Provider<AssistantRepository>(
  (ref) => AssistantRepository(ref.watch(assistantApiProvider)),
);

/// One entry in the chat transcript kept in memory while the assistant
/// sheet is open.
class ChatMessage {
  const ChatMessage({
    required this.text,
    required this.fromUser,
    this.source,
  });

  final String text;
  final bool fromUser;

  /// Server-reported provider tag (`canned`, `gemini`, `fallback`). Only
  /// set on assistant replies — kept so the UI can surface a subtle hint
  /// when a provider falls back.
  final String? source;
}

/// Holds the open assistant conversation. AsyncNotifier so the UI can
/// show a spinner while a reply is in flight.
class AssistantController extends AsyncNotifier<List<ChatMessage>> {
  @override
  Future<List<ChatMessage>> build() async {
    return const <ChatMessage>[
      ChatMessage(
        text:
            'Hi! Need help managing your timesheets or job posts today?',
        fromUser: false,
      ),
    ];
  }

  Future<void> send(String message) async {
    final trimmed = message.trim();
    if (trimmed.isEmpty) return;
    final current = state.valueOrNull ?? const <ChatMessage>[];
    final withUser = [
      ...current,
      ChatMessage(text: trimmed, fromUser: true),
    ];
    state = AsyncValue.data(withUser);

    try {
      final session = ref.read(authSessionProvider);
      final reply = await ref
          .read(assistantRepositoryProvider)
          .sendMessage(trimmed, bearerToken: session?.token);
      state = AsyncValue.data([
        ...withUser,
        ChatMessage(
          text: reply.reply,
          fromUser: false,
          source: reply.source,
        ),
      ]);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      // Keep the transcript intact even if a single send failed.
      state = AsyncValue.data([
        ...withUser,
        const ChatMessage(
          text:
              "Sorry, I couldn't reach the assistant right now. Please try again.",
          fromUser: false,
          source: 'fallback',
        ),
      ]);
    }
  }
}

final assistantControllerProvider =
    AsyncNotifierProvider<AssistantController, List<ChatMessage>>(
  AssistantController.new,
);
