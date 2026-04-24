import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme.dart';
import 'assistant_avatar.dart';
import 'open_assistant_sheet.dart';

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
              const AssistantAvatar(size: 34, iconSize: 18),
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
