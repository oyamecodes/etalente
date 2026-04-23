import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme.dart';
import '../../../shared/widgets/app_side_nav.dart';
import '../../../shared/widgets/dashboard_shell.dart';
import '../../../shared/widgets/featured_talent_card.dart';
import '../../assistant/presentation/widgets/chatbot_assistant_card.dart';
import '../../stats/presentation/widgets/quick_stats_card.dart';
import '../application/job_detail_controller.dart';
import '../domain/job.dart';

/// Details screen for a single job — mounted at `/jobs/:id`. Reuses
/// [DashboardShell] so navigation and the right rail stay consistent
/// with the Job Board. Description and skills come from the backend's
/// `GET /api/jobs/{id}` endpoint; list-view fields are repeated so the
/// page is self-contained and deep-linkable.
class JobDetailsPage extends ConsumerWidget {
  const JobDetailsPage({super.key, required this.jobId});

  final String jobId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detail = ref.watch(jobDetailProvider(jobId));
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
      body: detail.when(
        loading: () => const Padding(
          padding: EdgeInsets.symmetric(vertical: 48),
          child: Center(child: CircularProgressIndicator()),
        ),
        error: (err, _) => _ErrorState(
          message: err.toString(),
          onRetry: () => ref.invalidate(jobDetailProvider(jobId)),
          onBack: () => context.go('/jobs'),
        ),
        data: (job) => _DetailsBody(job: job),
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

class _DetailsBody extends StatelessWidget {
  const _DetailsBody({required this.job});
  final JobDetail job;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _BackRow(),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(job.title, style: AppTextStyles.pageTitle),
              const SizedBox(height: 8),
              Wrap(
                spacing: 16,
                runSpacing: 6,
                children: [
                  _MetaChip(icon: Icons.place_outlined, text: job.location),
                  _MetaChip(icon: Icons.work_outline, text: job.type),
                  _MetaChip(
                      icon: Icons.person_outline, text: 'Posted by ${job.postedBy}'),
                ],
              ),
              const SizedBox(height: 20),
              const Divider(color: AppColors.softDivider, height: 1),
              const SizedBox(height: 20),
              _StatsRow(job: job),
              if (job.skills.isNotEmpty) ...[
                const SizedBox(height: 24),
                Text('Required Skills',
                    style: AppTextStyles.cardSectionTitle),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final skill in job.skills) _SkillChip(label: skill),
                  ],
                ),
              ],
              if (job.description.isNotEmpty) ...[
                const SizedBox(height: 24),
                Text('About the Role',
                    style: AppTextStyles.cardSectionTitle),
                const SizedBox(height: 10),
                Text(
                  job.description,
                  style: AppTextStyles.pageSubtitle.copyWith(height: 1.5),
                ),
              ],
              const SizedBox(height: 28),
              Align(
                alignment: Alignment.centerLeft,
                child: ElevatedButton(
                  onPressed: () => _comingSoon(context, 'Apply'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.navyAction,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 28, vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    elevation: 0,
                  ),
                  child: const Text('Apply Now'),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _comingSoon(BuildContext context, String label) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$label — coming soon')),
    );
  }
}

class _BackRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        TextButton.icon(
          onPressed: () => context.go('/jobs'),
          icon: const Icon(Icons.arrow_back, size: 18),
          label: const Text('Back to Job Board'),
          style: TextButton.styleFrom(foregroundColor: AppColors.mutedText),
        ),
      ],
    );
  }
}

class _MetaChip extends StatelessWidget {
  const _MetaChip({required this.icon, required this.text});
  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: AppColors.mutedText),
        const SizedBox(width: 6),
        Text(text, style: AppTextStyles.jobMeta),
      ],
    );
  }
}

class _SkillChip extends StatelessWidget {
  const _SkillChip({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.jobIconTile,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        label,
        style: AppTextStyles.jobMeta.copyWith(
          color: AppColors.navyAction,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _StatsRow extends StatelessWidget {
  const _StatsRow({required this.job});
  final JobDetail job;

  @override
  Widget build(BuildContext context) {
    final columns = [
      _StatColumn(label: 'EXPERIENCE', value: job.experience),
      _StatColumn(label: 'SALARY RANGE', value: job.salaryRange),
      _StatColumn(label: 'CLOSING DATE', value: job.closingDate),
    ];
    final width = MediaQuery.sizeOf(context).width;
    if (width < 520) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (var i = 0; i < columns.length; i++) ...[
            if (i > 0) const SizedBox(height: 12),
            columns[i],
          ],
        ],
      );
    }
    return Row(
      children: [
        for (final col in columns) Expanded(child: col),
      ],
    );
  }
}

class _StatColumn extends StatelessWidget {
  const _StatColumn({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.jobStatLabel),
        const SizedBox(height: 6),
        Text(value, style: AppTextStyles.jobStatValue),
      ],
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({
    required this.message,
    required this.onRetry,
    required this.onBack,
  });
  final String message;
  final VoidCallback onRetry;
  final VoidCallback onBack;

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
          Text("Couldn't load job",
              style: AppTextStyles.cardSectionTitle),
          const SizedBox(height: 6),
          Text(message, style: AppTextStyles.pageSubtitle),
          const SizedBox(height: 12),
          Row(
            children: [
              OutlinedButton(
                onPressed: onBack,
                child: const Text('Back'),
              ),
              const SizedBox(width: 12),
              ElevatedButton(
                onPressed: onRetry,
                child: const Text('Retry'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
