import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme.dart';
import '../../../shared/widgets/dashboard_shell.dart';
import '../../../shared/widgets/app_side_nav.dart';
import '../../../shared/widgets/featured_talent_card.dart';
import '../../assistant/application/assistant_open_provider.dart';
import '../../assistant/presentation/widgets/chatbot_assistant_card.dart';
import '../../stats/presentation/widgets/quick_stats_card.dart';
import '../application/job_board_controller.dart';
import 'widgets/filter_pills.dart';
import 'widgets/job_card.dart';

/// Job Board — post-auth landing page. Adaptive layout via
/// [DashboardShell]. Main column shows the page title, filter pills and
/// the list of job cards from `GET /api/jobs`. Right rail shows Quick
/// Stats, Featured Talent and the Chatbot Assistant card. A floating
/// chat FAB opens the assistant sheet from any layout.
class JobBoardPage extends ConsumerWidget {
  const JobBoardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final jobs = ref.watch(jobBoardControllerProvider);
    final assistantOpen = ref.watch(assistantOpenProvider);

    return DashboardShell(
      active: NavItem.jobPosts,
      floatingActionButton: assistantOpen
          ? null
          : FloatingActionButton(
              onPressed: () => openAssistantSheet(context),
              backgroundColor: AppColors.accentYellow,
              foregroundColor: AppColors.onSurface,
              child: const Icon(Icons.chat_bubble_outline),
            ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _Header(),
          const SizedBox(height: 20),
          jobs.when(
            loading: () => const Padding(
              padding: EdgeInsets.symmetric(vertical: 48),
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (err, _) => _ErrorState(
              message: err.toString(),
              onRetry: () => ref
                  .read(jobBoardControllerProvider.notifier)
                  .refresh(),
            ),
            data: (page) {
              if (page.content.isEmpty) {
                return const _EmptyState();
              }
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (var i = 0; i < page.content.length; i++) ...[
                    JobCard(
                      job: page.content[i],
                      // First card is highlighted in the mock with a red
                      // closing date — keep that cue for the top result.
                      closingSoon: i == 0,
                      bookmarked: i == 1,
                      onTap: () =>
                          context.go('/jobs/${page.content[i].id}'),
                    ),
                    if (i != page.content.length - 1)
                      const SizedBox(height: 16),
                  ],
                ],
              );
            },
          ),
        ],
      ),
      rightRail: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: const [
          QuickStatsCard(),
          SizedBox(height: 16),
          FeaturedTalentCard(),
          SizedBox(height: 16),
          ChatbotAssistantCard(),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.sizeOf(context).width >= 900;
    final title = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Job Board', style: AppTextStyles.pageTitle),
        const SizedBox(height: 6),
        Text(
          "Manage your active listings and discover new talent for your "
          "organization's growth.",
          style: AppTextStyles.pageSubtitle,
        ),
      ],
    );

    if (wide) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(child: title),
          const FilterPills(),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        title,
        const SizedBox(height: 12),
        const FilterPills(),
      ],
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          const Icon(Icons.search_off,
              size: 48, color: AppColors.mutedText),
          const SizedBox(height: 12),
          Text('No jobs match those filters',
              style: AppTextStyles.cardSectionTitle),
          const SizedBox(height: 6),
          Text(
            'Try clearing the filters or searching for something different.',
            style: AppTextStyles.pageSubtitle,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text("Couldn't load jobs",
              style: AppTextStyles.cardSectionTitle),
          const SizedBox(height: 6),
          Text(message, style: AppTextStyles.pageSubtitle),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerLeft,
            child: OutlinedButton(
              onPressed: onRetry,
              child: const Text('Retry'),
            ),
          ),
        ],
      ),
    );
  }
}
