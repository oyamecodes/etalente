import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme.dart';
import '../../application/assistant_open_provider.dart';
import 'open_assistant_sheet.dart';

/// Floating-action button that opens the assistant popup and hides
/// itself while the popup is mounted (so it doesn't overlap the
/// anchored dialog on desktop).
///
/// Shared by the Job Board and Job Details pages so the interaction is
/// identical in both places.
class ChatAssistantFab extends ConsumerWidget {
  const ChatAssistantFab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final open = ref.watch(assistantOpenProvider);
    if (open) return const SizedBox.shrink();
    return FloatingActionButton(
      onPressed: () => openAssistantSheet(context),
      backgroundColor: AppColors.accentYellow,
      foregroundColor: AppColors.onSurface,
      tooltip: 'eTalente Assistant',
      child: const Icon(Icons.chat_bubble_outline),
    );
  }
}
