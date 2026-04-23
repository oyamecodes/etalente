import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme.dart';
import '../../application/stats_controller.dart';

/// Navy right-rail card showing the three top-line numbers with a
/// "View Full Dashboard" CTA underneath. Wired to the backend's
/// `GET /api/stats`.
class QuickStatsCard extends ConsumerWidget {
  const QuickStatsCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(statsControllerProvider);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.statsCardNavy,
        borderRadius: BorderRadius.circular(16),
      ),
      child: stats.when(
        loading: () => const SizedBox(
          height: 160,
          child: Center(
            child: CircularProgressIndicator(
                color: AppColors.accentYellow, strokeWidth: 2),
          ),
        ),
        error: (err, _) => _Error(onRetry: () {
          ref.read(statsControllerProvider.notifier).refresh();
        }),
        data: (data) => Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Quick Stats', style: AppTextStyles.cardSectionTitleInverse),
            const SizedBox(height: 18),
            _Row(label: 'Active Posts', value: '${data.activePosts}'),
            const SizedBox(height: 14),
            _Row(
              label: 'New Applicants',
              value: '${data.newApplicants}',
              valueColor: AppColors.accentYellow,
            ),
            const SizedBox(height: 14),
            _Row(label: 'Interviews Today', value: '${data.interviewsToday}'),
            const SizedBox(height: 20),
            OutlinedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Dashboard view — coming soon')),
                );
              },
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(44),
                foregroundColor: Colors.white,
                side: BorderSide(
                    color: Colors.white.withValues(alpha: 0.2)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text('View Full Dashboard'),
            ),
          ],
        ),
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({
    required this.label,
    required this.value,
    this.valueColor,
  });

  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: AppTextStyles.statsLabel),
        Text(
          value,
          style: AppTextStyles.statsValue.copyWith(
            color: valueColor ?? Colors.white,
          ),
        ),
      ],
    );
  }
}

class _Error extends StatelessWidget {
  const _Error({required this.onRetry});
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text("Couldn't load stats",
            style: AppTextStyles.cardSectionTitleInverse),
        const SizedBox(height: 8),
        Text('Please check your connection and retry.',
            style: AppTextStyles.statsLabel),
        const SizedBox(height: 12),
        TextButton(
          onPressed: onRetry,
          style: TextButton.styleFrom(foregroundColor: Colors.white),
          child: const Text('Retry'),
        ),
      ],
    );
  }
}
