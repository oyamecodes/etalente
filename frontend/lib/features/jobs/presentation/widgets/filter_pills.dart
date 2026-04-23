import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme.dart';
import '../../application/job_board_controller.dart';

/// The "All Filters / Skills / Experience / Contract" pill row in the
/// mock. "All Filters" is the active/selected state (yellow, tune icon)
/// and means "no type filter applied".
///
/// Skills is not yet supported by the backend and shows a snackbar.
/// Experience and Contract map to the existing `experience`/`type`
/// backend filters.
class FilterPills extends ConsumerWidget {
  const FilterPills({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filters = ref.watch(jobBoardFiltersProvider);
    final hasAnyActive =
        filters.type != null || filters.experience != null;

    return Wrap(
      spacing: 10,
      runSpacing: 10,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        _Pill(
          label: 'All Filters',
          icon: Icons.tune,
          selected: !hasAnyActive,
          onTap: () {
            ref.read(jobBoardFiltersProvider.notifier).state =
                const JobBoardFilters();
          },
        ),
        _Pill(
          label: 'Skills',
          selected: false,
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Skills filter — coming soon')),
            );
          },
        ),
        _ExperiencePill(),
        _Pill(
          label: 'Contract',
          selected: filters.type == 'Contract',
          onTap: () {
            final next = filters.type == 'Contract' ? null : 'Contract';
            ref.read(jobBoardFiltersProvider.notifier).update(
                  (s) => s.copyWith(type: next),
                );
          },
        ),
      ],
    );
  }
}

class _ExperiencePill extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filters = ref.watch(jobBoardFiltersProvider);
    final active = filters.experience != null;

    return _Pill(
      label: active ? '${filters.experience}+ Years' : 'Experience',
      selected: active,
      onTap: () async {
        final picked = await showModalBottomSheet<String?>(
          context: context,
          builder: (_) => SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  title: const Text('Any experience'),
                  onTap: () => Navigator.of(context).pop(''),
                ),
                for (final years in ['1', '3', '5', '7'])
                  ListTile(
                    title: Text('$years+ years'),
                    onTap: () => Navigator.of(context).pop(years),
                  ),
              ],
            ),
          ),
        );
        if (picked == null) return;
        ref.read(jobBoardFiltersProvider.notifier).update(
              (s) => s.copyWith(experience: picked.isEmpty ? null : picked),
            );
      },
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({
    required this.label,
    required this.selected,
    required this.onTap,
    this.icon,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final bg = selected ? AppColors.accentYellow : AppColors.surface;
    final borderColor =
        selected ? AppColors.accentYellow : AppColors.softDivider;
    return Material(
      color: bg,
      borderRadius: BorderRadius.circular(24),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Container(
          padding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: borderColor, width: 1),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 16, color: AppColors.onSurface),
                const SizedBox(width: 6),
              ],
              Text(
                label,
                style: selected
                    ? AppTextStyles.pillActive
                    : AppTextStyles.pillInactive,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
