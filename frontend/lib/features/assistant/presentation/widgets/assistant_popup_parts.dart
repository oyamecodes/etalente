import 'package:flutter/material.dart';

import '../../../../app/theme.dart';
import '../../application/assistant_controller.dart';
import 'assistant_avatar.dart';

/// Yellow header row at the top of the assistant popup — avatar,
/// title, "online" row and close button.
class AssistantHeader extends StatelessWidget {
  const AssistantHeader({super.key, required this.onClose});
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.accentYellow,
      padding: const EdgeInsets.fromLTRB(14, 12, 8, 12),
      child: Row(
        children: [
          const AssistantAvatar(size: 40, iconSize: 22, showOnlineDot: true),
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

/// Chat bubble. Aligns right (navy) for user messages and left with an
/// avatar (white) for assistant messages.
class AssistantBubble extends StatelessWidget {
  const AssistantBubble({super.key, required this.message});
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
          color: fromUser ? AppColors.navyAction : AppColors.surface,
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
        const AssistantAvatar(size: 30, iconSize: 16),
        const SizedBox(width: 8),
        Flexible(child: bubble),
      ],
    );
  }
}

/// Quick-reply chips shown only on the initial greeting (before the
/// user has typed anything). Tapping a chip submits its label as a
/// user message.
class AssistantQuickReplies extends StatelessWidget {
  const AssistantQuickReplies({super.key, required this.onTap});
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

/// Bottom input bar — attach button (stub), rounded text field, send
/// button. Disabled while a request is in flight.
class AssistantComposer extends StatelessWidget {
  const AssistantComposer({
    super.key,
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
            icon: const Icon(Icons.attach_file, color: AppColors.mutedText),
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

/// "Help Center" link at the bottom of the popup. Currently a
/// coming-soon stub.
class AssistantFooter extends StatelessWidget {
  const AssistantFooter({super.key, required this.onHelpCenter});
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
              padding:
                  const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
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
