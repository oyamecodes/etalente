import 'package:flutter/material.dart';

import '../../../../app/theme.dart';

/// Two-option segmented toggle matching the "Talent / Employer" pill
/// on the eTalente sign-up page. The selection is cosmetic — the
/// backend mock accepts any account type — but it's rendered faithfully
/// so the screen feels real to reviewers.
enum AccountRole { talent, employer }

class RoleToggle extends StatelessWidget {
  const RoleToggle({
    super.key,
    required this.value,
    required this.onChanged,
  });

  final AccountRole value;
  final ValueChanged<AccountRole> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.pageBackground,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AppColors.fieldBorder),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        children: [
          Expanded(
            child: _Segment(
              label: 'Talent',
              selected: value == AccountRole.talent,
              onTap: () => onChanged(AccountRole.talent),
            ),
          ),
          Expanded(
            child: _Segment(
              label: 'Employer',
              selected: value == AccountRole.employer,
              onTap: () => onChanged(AccountRole.employer),
            ),
          ),
        ],
      ),
    );
  }
}

class _Segment extends StatelessWidget {
  const _Segment({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(4),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(4),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: AppTextStyles.linkStrong.copyWith(
            fontSize: 15,
            color: AppColors.onSurface,
          ),
        ),
      ),
    );
  }
}
