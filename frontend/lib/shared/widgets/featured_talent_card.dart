import 'package:flutter/material.dart';

import '../../app/theme.dart';

/// White right-rail card showing two hand-picked profiles with a star.
/// Backend does not expose a talent directory so the content is static
/// and intentionally matches the mock 1:1.
class FeaturedTalentCard extends StatelessWidget {
  const FeaturedTalentCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Featured Talent', style: AppTextStyles.cardSectionTitle),
          const SizedBox(height: 16),
          const _TalentRow(
            initials: 'SW',
            name: 'Sarah J. Watson',
            role: 'React Specialist • 4yrs exp',
            avatarColor: Color(0xFFE87C74),
            starred: true,
          ),
          const SizedBox(height: 12),
          const _TalentRow(
            initials: 'MA',
            name: 'Marcus Aurelius',
            role: 'Python Dev • 6yrs exp',
            avatarColor: Color(0xFF5E6BE0),
            starred: false,
          ),
          const SizedBox(height: 16),
          Center(
            child: TextButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Browse All Talent — coming soon')),
                );
              },
              child: Text('Browse All Talent',
                  style: AppTextStyles.termsLink
                      .copyWith(fontWeight: FontWeight.w700)),
            ),
          ),
        ],
      ),
    );
  }
}

class _TalentRow extends StatelessWidget {
  const _TalentRow({
    required this.initials,
    required this.name,
    required this.role,
    required this.avatarColor,
    required this.starred,
  });

  final String initials;
  final String name;
  final String role;
  final Color avatarColor;
  final bool starred;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          radius: 20,
          backgroundColor: avatarColor,
          child: Text(initials,
              style: AppTextStyles.primaryButton
                  .copyWith(color: Colors.white, letterSpacing: 0)),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(name,
                  style: AppTextStyles.jobStatValue
                      .copyWith(fontWeight: FontWeight.w700)),
              Text(role,
                  style: AppTextStyles.jobMeta
                      .copyWith(fontSize: 12)),
            ],
          ),
        ),
        Icon(
          starred ? Icons.star : Icons.star_border,
          color:
              starred ? AppColors.accentYellow : AppColors.softDivider,
        ),
      ],
    );
  }
}
