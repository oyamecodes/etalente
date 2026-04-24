import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme.dart';
import '../../application/assistant_controller.dart';
import '../../application/assistant_open_provider.dart';
import 'assistant_popup_parts.dart';

/// Opens the eTalente Assistant popup.
///
/// Responsive:
/// - viewport ≥ 700px wide → anchored bottom-right dialog capped at
///   380×560 (matches `job board 2.jpeg`).
/// - narrower → fullscreen `Dialog` so the input isn't cramped on
///   phones.
///
/// Flips `assistantOpenProvider` on entry and clears it on exit so the
/// chat FAB can hide itself while the popup is mounted.
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
          AssistantHeader(onClose: () => Navigator.of(context).maybePop()),
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
                    return AssistantBubble(message: messages[i]);
                  }
                  return AssistantQuickReplies(
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
          AssistantComposer(
            controller: _controller,
            busy: busy,
            onSend: _send,
            onAttach: () => _comingSoon('Attachments'),
          ),
          AssistantFooter(onHelpCenter: () => _comingSoon('Help Center')),
        ],
      ),
    );
  }
}
