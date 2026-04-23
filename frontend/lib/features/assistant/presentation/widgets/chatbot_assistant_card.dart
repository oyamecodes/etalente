import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme.dart';
import '../../application/assistant_controller.dart';

/// Yellow-tinted right-rail card teasing the assistant. Tapping "Ask
/// Assistant" opens a modal chat sheet wired to
/// `POST /api/assistant/message`.
class ChatbotAssistantCard extends ConsumerWidget {
  const ChatbotAssistantCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.chatbotCardBg,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: AppColors.accentYellow,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.chat_bubble_outline,
                    size: 18, color: AppColors.onSurface),
              ),
              const SizedBox(width: 10),
              Text('Chatbot Assistant',
                  style: AppTextStyles.cardSectionTitle),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Hi! Need help managing your timesheets or job posts today?',
            style: AppTextStyles.jobMeta
                .copyWith(color: AppColors.onSurface),
          ),
          const SizedBox(height: 14),
          ElevatedButton(
            onPressed: () => openAssistantSheet(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.navyAction,
              foregroundColor: Colors.white,
              padding:
                  const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              elevation: 0,
              textStyle: AppTextStyles.navyButton.copyWith(fontSize: 13),
            ),
            child: const Text('Ask Assistant'),
          ),
        ],
      ),
    );
  }
}

/// Public so the chat FAB can share the same sheet.
Future<void> openAssistantSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    showDragHandle: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (_) => const _AssistantSheet(),
  );
}

class _AssistantSheet extends ConsumerStatefulWidget {
  const _AssistantSheet();

  @override
  ConsumerState<_AssistantSheet> createState() => _AssistantSheetState();
}

class _AssistantSheetState extends ConsumerState<_AssistantSheet> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final text = _controller.text;
    if (text.trim().isEmpty) return;
    _controller.clear();
    await ref.read(assistantControllerProvider.notifier).send(text);
    await Future.delayed(const Duration(milliseconds: 50));
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final messages =
        ref.watch(assistantControllerProvider).valueOrNull ?? const [];
    final busy = ref.watch(assistantControllerProvider).isLoading;

    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        bottom: MediaQuery.viewInsetsOf(context).bottom + 16,
        top: 8,
      ),
      child: SizedBox(
        height: MediaQuery.sizeOf(context).height * 0.7,
        child: Column(
          children: [
            Row(
              children: [
                const Icon(Icons.chat_bubble_outline,
                    color: AppColors.navyAction),
                const SizedBox(width: 8),
                Text('Assistant', style: AppTextStyles.cardSectionTitle),
              ],
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.separated(
                controller: _scrollController,
                itemCount: messages.length,
                separatorBuilder: (_, _) => const SizedBox(height: 8),
                itemBuilder: (_, i) => _Bubble(message: messages[i]),
              ),
            ),
            if (busy)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 6),
                child: LinearProgressIndicator(minHeight: 2),
              ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    minLines: 1,
                    maxLines: 4,
                    onSubmitted: (_) => _send(),
                    decoration: InputDecoration(
                      hintText: 'Ask anything…',
                      filled: true,
                      fillColor: AppColors.dashboardSurface,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filled(
                  onPressed: busy ? null : _send,
                  icon: const Icon(Icons.send, size: 18),
                  style: IconButton.styleFrom(
                    backgroundColor: AppColors.navyAction,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Bubble extends StatelessWidget {
  const _Bubble({required this.message});
  final ChatMessage message;

  @override
  Widget build(BuildContext context) {
    final fromUser = message.fromUser;
    return Align(
      alignment: fromUser ? Alignment.centerRight : Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.sizeOf(context).width * 0.8,
        ),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: fromUser
                ? AppColors.navyAction
                : AppColors.dashboardSurface,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Text(
            message.text,
            style: AppTextStyles.jobMeta.copyWith(
              color: fromUser ? Colors.white : AppColors.onSurface,
              height: 1.35,
            ),
          ),
        ),
      ),
    );
  }
}
