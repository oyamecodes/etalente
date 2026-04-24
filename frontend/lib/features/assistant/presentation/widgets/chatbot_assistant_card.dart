import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme.dart';
import '../../application/assistant_controller.dart';
import '../../application/assistant_open_provider.dart';

/// Yellow-tinted right-rail card teasing the assistant. Tapping "Ask
/// Assistant" opens the floating chat popup wired to
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
              const _AssistantAvatar(size: 34, iconSize: 18),
              const SizedBox(width: 10),
              Flexible(
                child: Text('eTalente Assistant',
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.cardSectionTitle),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Hi! Need help managing your job posts or finding talent today?',
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

/// Opens the eTalente Assistant popup. Uses an anchored bottom-right
/// card on tablet/desktop (≥700px wide) and a fullscreen dialog on
/// narrow phones. Shared by the right-rail card and the chat FAB.
Future<void> openAssistantSheet(BuildContext context) async {
  final container = ProviderScope.containerOf(context, listen: false);
  container.read(assistantOpenProvider.notifier).state = true;
  try {
    await showGeneralDialog<void>(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'eTalente Assistant',
      barrierColor: Colors.black26,
      transitionDuration: const Duration(milliseconds: 180),
      pageBuilder: (ctx, _, _) {
        final wide = MediaQuery.sizeOf(ctx).width >= 700;
        if (!wide) {
          return const Dialog.fullscreen(child: _AssistantPopup());
        }
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 90),
            child: Align(
              alignment: Alignment.bottomRight,
              child: Material(
                color: Colors.transparent,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxWidth: 380,
                    maxHeight: 560,
                  ),
                  child: const _AssistantPopup(),
                ),
              ),
            ),
          ),
        );
      },
      transitionBuilder: (_, anim, _, child) {
        return FadeTransition(
          opacity: anim,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.04),
              end: Offset.zero,
            ).animate(CurvedAnimation(
              parent: anim,
              curve: Curves.easeOutCubic,
            )),
            child: child,
          ),
        );
      },
    );
  } finally {
    container.read(assistantOpenProvider.notifier).state = false;
  }
}

class _AssistantPopup extends ConsumerStatefulWidget {
  const _AssistantPopup();

  @override
  ConsumerState<_AssistantPopup> createState() => _AssistantPopupState();
}

class _AssistantPopupState extends ConsumerState<_AssistantPopup> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _send(String text) async {
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

  void _comingSoon(String label) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$label — coming soon'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final messages =
        ref.watch(assistantControllerProvider).valueOrNull ?? const [];
    final busy = ref.watch(assistantControllerProvider).isLoading;

    // Show quick-reply chips only on the initial greeting (no user
    // messages yet) to mirror the mock.
    final showChips = !messages.any((m) => m.fromUser);

    return Material(
      color: AppColors.surface,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      elevation: 12,
      shadowColor: Colors.black26,
      child: Column(
        children: [
          _Header(onClose: () => Navigator.of(context).maybePop()),
          Expanded(
            child: Container(
              color: AppColors.dashboardSurface,
              child: ListView.separated(
                controller: _scrollController,
                padding: const EdgeInsets.fromLTRB(14, 16, 14, 8),
                itemCount: messages.length + (showChips ? 1 : 0),
                separatorBuilder: (_, _) => const SizedBox(height: 10),
                itemBuilder: (_, i) {
                  if (i < messages.length) {
                    return _Bubble(message: messages[i]);
                  }
                  return _QuickReplies(
                    onTap: busy ? (_) {} : _send,
                  );
                },
              ),
            ),
          ),
          if (busy)
            const LinearProgressIndicator(
              minHeight: 2,
              backgroundColor: AppColors.dashboardSurface,
            ),
          _Composer(
            controller: _controller,
            busy: busy,
            onSend: _send,
            onAttach: () => _comingSoon('Attachments'),
          ),
          _Footer(onHelpCenter: () => _comingSoon('Help Center')),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.onClose});
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.accentYellow,
      padding: const EdgeInsets.fromLTRB(14, 12, 8, 12),
      child: Row(
        children: [
          const _AssistantAvatar(size: 40, iconSize: 22, showOnlineDot: true),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'eTalente Assistant',
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.cardSectionTitle
                      .copyWith(color: AppColors.onSurface),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Color(0xFF2BB673),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        'Online • Ready to help',
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.jobMeta.copyWith(
                          color: AppColors.onSurface.withValues(alpha: 0.7),
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: onClose,
            icon: const Icon(Icons.close, color: AppColors.onSurface),
            tooltip: 'Close',
          ),
        ],
      ),
    );
  }
}

class _AssistantAvatar extends StatelessWidget {
  const _AssistantAvatar({
    required this.size,
    required this.iconSize,
    this.showOnlineDot = false,
  });

  final double size;
  final double iconSize;
  final bool showOnlineDot;

  @override
  Widget build(BuildContext context) {
    final avatar = Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        color: AppColors.accentYellow,
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Icon(Icons.smart_toy_outlined,
          size: iconSize, color: AppColors.onSurface),
    );
    if (!showOnlineDot) return avatar;
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned.fill(child: avatar),
          Positioned(
            right: -1,
            bottom: -1,
            child: Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: const Color(0xFF2BB673),
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.accentYellow, width: 2),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickReplies extends StatelessWidget {
  const _QuickReplies({required this.onTap});
  final ValueChanged<String> onTap;

  static const _options = ['Post New Job', 'Review Applicants'];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 40, top: 2),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          for (final label in _options)
            InkWell(
              onTap: () => onTap(label),
              borderRadius: BorderRadius.circular(999),
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: AppColors.navyAction, width: 1),
                ),
                child: Text(
                  label,
                  style: AppTextStyles.jobMeta.copyWith(
                    color: AppColors.navyAction,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
        ],
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
    final bubble = ConstrainedBox(
      constraints: BoxConstraints(
        maxWidth: MediaQuery.sizeOf(context).width * 0.75,
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color:
              fromUser ? AppColors.navyAction : AppColors.surface,
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
    );

    if (fromUser) {
      return Align(alignment: Alignment.centerRight, child: bubble);
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        const _AssistantAvatar(size: 30, iconSize: 16),
        const SizedBox(width: 8),
        Flexible(child: bubble),
      ],
    );
  }
}

class _Composer extends StatelessWidget {
  const _Composer({
    required this.controller,
    required this.busy,
    required this.onSend,
    required this.onAttach,
  });

  final TextEditingController controller;
  final bool busy;
  final ValueChanged<String> onSend;
  final VoidCallback onAttach;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.surface,
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          IconButton(
            onPressed: onAttach,
            icon: const Icon(Icons.attach_file,
                color: AppColors.mutedText),
            tooltip: 'Attach',
          ),
          Expanded(
            child: TextField(
              controller: controller,
              minLines: 1,
              maxLines: 3,
              onSubmitted: busy ? null : onSend,
              decoration: InputDecoration(
                hintText: 'Type your message…',
                filled: true,
                fillColor: AppColors.dashboardSurface,
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Material(
            color: AppColors.navyAction,
            shape: const CircleBorder(),
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: busy ? null : () => onSend(controller.text),
              child: const SizedBox(
                width: 40,
                height: 40,
                child: Icon(Icons.send, size: 18, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Footer extends StatelessWidget {
  const _Footer({required this.onHelpCenter});
  final VoidCallback onHelpCenter;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.surface,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          InkWell(
            onTap: onHelpCenter,
            borderRadius: BorderRadius.circular(4),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: 6, vertical: 4),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.help_outline,
                      size: 14, color: AppColors.mutedText),
                  const SizedBox(width: 6),
                  Text(
                    'Help Center',
                    style: AppTextStyles.jobMeta.copyWith(
                      color: AppColors.mutedText,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
