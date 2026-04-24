import 'package:flutter/material.dart';

import '../../../../app/theme.dart';
import '../../domain/job.dart';

/// Tag pill style (colour) derived from the wire-form employment type.
class _TypeStyle {
  const _TypeStyle(this.bg, this.fg);
  final Color bg;
  final Color fg;
}

_TypeStyle _styleFor(String type) {
  switch (type) {
    case 'Full-time':
    case 'Part-time':
      return const _TypeStyle(AppColors.tagFullTimeBg, AppColors.tagFullTimeFg);
    case 'Contract':
      return const _TypeStyle(AppColors.tagContractBg, AppColors.tagContractFg);
    case 'Internship':
      return const _TypeStyle(
          AppColors.tagInternshipBg, AppColors.tagInternshipFg);
    default:
      return const _TypeStyle(AppColors.tagFullTimeBg, AppColors.tagFullTimeFg);
  }
}

/// One job listing card rendered in the main column. Visual design
/// matches the Job Board mock: square icon tile, title + meta row
/// (location / company / type-pill), bookmark on the right, divider,
/// then a 4-column stat row.
class JobCard extends StatelessWidget {
  const JobCard({
    super.key,
    required this.job,
    this.bookmarked = false,
    this.closingSoon = false,
    this.onTap,
    this.onToggleBookmark,
  });

  final Job job;

  final bool bookmarked;

  /// When `true`, the closing date is rendered in red to match the
  /// highlighted first card in the mock.
  final bool closingSoon;

  final VoidCallback? onTap;
  final VoidCallback? onToggleBookmark;

  @override
  Widget build(BuildContext context) {
    final style = _styleFor(job.type);

    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppColors.jobIconTile,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.code,
                        size: 22, color: AppColors.navyAction),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(job.title,
                            style: AppTextStyles.jobTitle,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis),
                        const SizedBox(height: 6),
                        Wrap(
                          spacing: 14,
                          runSpacing: 4,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            _MetaChip(
                                icon: Icons.place_outlined,
                                text: job.location),
                            _MetaChip(
                                icon: Icons.business_outlined,
                                text: job.company.isEmpty
                                    ? 'eTalente Systems'
                                    : job.company),
                            _TypePill(type: job.type, style: style),
                          ],
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: onToggleBookmark,
                    icon: Icon(
                      bookmarked
                          ? Icons.bookmark
                          : Icons.bookmark_border,
                      color: bookmarked
                          ? AppColors.accentYellow
                          : AppColors.mutedText,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Divider(color: AppColors.softDivider, height: 1),
              const SizedBox(height: 14),
              _StatsRow(job: job, closingSoon: closingSoon),
            ],
          ),
        ),
      ),
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
        Icon(icon, size: 14, color: AppColors.mutedText),
        const SizedBox(width: 4),
        Text(text, style: AppTextStyles.jobMeta),
      ],
    );
  }
}

class _TypePill extends StatelessWidget {
  const _TypePill({required this.type, required this.style});
  final String type;
  final _TypeStyle style;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: style.bg,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        type,
        style: AppTextStyles.jobMeta.copyWith(
          color: style.fg,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
      ),
    );
  }
}

class _StatsRow extends StatelessWidget {
  const _StatsRow({required this.job, required this.closingSoon});
  final Job job;
  final bool closingSoon;

  @override
  Widget build(BuildContext context) {
    final columns = [
      _StatColumn(label: 'EXPERIENCE', value: job.experience),
      _StatColumn(label: 'SALARY RANGE', value: job.salaryRange),
      _StatColumn(label: 'POSTED BY', value: job.postedBy),
      _StatColumn(
        label: 'CLOSING DATE',
        value: _formatDate(job.closingDate),
        valueColor:
            closingSoon ? AppColors.closingSoon : AppColors.onSurface,
      ),
    ];

    // Narrow: wrap to 2 columns.
    final width = MediaQuery.sizeOf(context).width;
    if (width < 520) {
      return Wrap(
        runSpacing: 12,
        children: [
          SizedBox(
              width: (width - 32) / 2 - 8, child: columns[0]),
          SizedBox(
              width: (width - 32) / 2 - 8, child: columns[1]),
          SizedBox(
              width: (width - 32) / 2 - 8, child: columns[2]),
          SizedBox(
              width: (width - 32) / 2 - 8, child: columns[3]),
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
  const _StatColumn({
    required this.label,
    required this.value,
    this.valueColor,
  });

  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.jobStatLabel),
        const SizedBox(height: 6),
        Text(
          value,
          style: AppTextStyles.jobStatValue.copyWith(
            color: valueColor ?? AppColors.onSurface,
          ),
        ),
      ],
    );
  }
}

/// Turns a backend-emitted ISO date (`YYYY-MM-DD`) into something
/// closer to the mock ("24 Nov 2023"). Returns the original string on
/// any parsing failure so display degrades gracefully.
String _formatDate(String iso) {
  try {
    final parts = iso.split('-');
    if (parts.length != 3) return iso;
    final year = int.parse(parts[0]);
    final month = int.parse(parts[1]);
    final day = int.parse(parts[2]);
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${day.toString().padLeft(2, '0')} ${months[month - 1]} $year';
  } catch (_) {
    return iso;
  }
}
