import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme.dart';
import '../../application/job_board_controller.dart';
import '../../domain/job.dart';

/// Bottom-of-list pager — Prev / "Page X of Y" / Next.
///
/// Hidden when there is only one page. Disabled buttons grey out at
/// the edges. Mutates [jobBoardPageProvider]; the controller
/// re-fetches automatically via `ref.watch`.
class JobBoardPager extends ConsumerWidget {
  const JobBoardPager({super.key, required this.page});
  final JobPage page;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (page.totalPages <= 1) return const SizedBox.shrink();

    final current = page.page;
    final totalPages = page.totalPages;
    final canPrev = current > 0;
    final canNext = current < totalPages - 1;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _PagerButton(
            label: 'Previous',
            icon: Icons.chevron_left,
            iconLeading: true,
            enabled: canPrev,
            onTap: () => ref
                .read(jobBoardControllerProvider.notifier)
                .goToPage(current - 1),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Page ${current + 1} of $totalPages',
              style: AppTextStyles.pageSubtitle.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.onSurface,
              ),
            ),
          ),
          _PagerButton(
            label: 'Next',
            icon: Icons.chevron_right,
            iconLeading: false,
            enabled: canNext,
            onTap: () => ref
                .read(jobBoardControllerProvider.notifier)
                .goToPage(current + 1),
          ),
        ],
      ),
    );
  }
}

class _PagerButton extends StatelessWidget {
  const _PagerButton({
    required this.label,
    required this.icon,
    required this.iconLeading,
    required this.enabled,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool iconLeading;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final fg = enabled ? AppColors.navyAction : AppColors.mutedText;
    return OutlinedButton(
      onPressed: enabled ? onTap : null,
      style: OutlinedButton.styleFrom(
        foregroundColor: fg,
        side: BorderSide(color: enabled ? AppColors.navyAction : Colors.black12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (iconLeading) ...[
            Icon(icon, size: 18),
            const SizedBox(width: 6),
          ],
          Text(label),
          if (!iconLeading) ...[
            const SizedBox(width: 6),
            Icon(icon, size: 18),
          ],
        ],
      ),
    );
  }
}
