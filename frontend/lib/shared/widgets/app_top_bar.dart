import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/theme.dart';
import '../../features/auth/application/auth_controller.dart';
import '../../features/jobs/application/job_board_controller.dart';

/// Header row above the main content on the Job Board. Contains the
/// search field, the alert/help icons, a "Post a Job" CTA and the user
/// avatar. On mobile, [leading] injects a hamburger button.
class AppTopBar extends ConsumerStatefulWidget {
  const AppTopBar({super.key, this.leading});

  final Widget? leading;

  @override
  ConsumerState<AppTopBar> createState() => _AppTopBarState();
}

class _AppTopBarState extends ConsumerState<AppTopBar> {
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    final current = ref.read(jobBoardFiltersProvider).search ?? '';
    _searchController = TextEditingController(text: current);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _submit(String value) {
    final trimmed = value.trim();
    ref.read(jobBoardFiltersProvider.notifier).update(
          (s) => s.copyWith(search: trimmed.isEmpty ? null : trimmed),
        );
  }

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(authSessionProvider);
    final initial = (session?.user.name.isNotEmpty ?? false)
        ? session!.user.name.trim()[0].toUpperCase()
        : 'E';

    return Container(
      height: 68,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(
          bottom: BorderSide(color: AppColors.softDivider, width: 1),
        ),
      ),
      child: Row(
        children: [
          if (widget.leading != null) ...[
            widget.leading!,
            const SizedBox(width: 8),
          ],
          Expanded(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: TextField(
                controller: _searchController,
                onSubmitted: _submit,
                textInputAction: TextInputAction.search,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: AppColors.dashboardSurface,
                  hintText: 'Search for jobs, skills...',
                  hintStyle: AppTextStyles.inputHint.copyWith(fontSize: 14),
                  prefixIcon: const Icon(Icons.search,
                      size: 20, color: AppColors.mutedText),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(40),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(40),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(40),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          _BellButton(onTap: () => _comingSoon(context, 'Notifications')),
          const SizedBox(width: 4),
          IconButton(
            onPressed: () => _comingSoon(context, 'Help centre'),
            icon: const Icon(Icons.help_outline,
                size: 22, color: AppColors.mutedText),
          ),
          const SizedBox(width: 4),
          _PostJobButton(onTap: () => _comingSoon(context, 'Post a Job')),
          const SizedBox(width: 10),
          CircleAvatar(
            radius: 18,
            backgroundColor: AppColors.navyAction,
            child: Text(initial,
                style: AppTextStyles.primaryButton
                    .copyWith(color: Colors.white, letterSpacing: 0)),
          ),
        ],
      ),
    );
  }

  void _comingSoon(BuildContext context, String label) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$label — coming soon')),
    );
  }
}

class _BellButton extends StatelessWidget {
  const _BellButton({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onTap,
      icon: Stack(
        clipBehavior: Clip.none,
        children: [
          const Icon(Icons.notifications_none,
              size: 22, color: AppColors.mutedText),
          Positioned(
            right: -1,
            top: -1,
            child: Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                color: AppColors.closingSoon,
                shape: BoxShape.circle,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PostJobButton extends StatelessWidget {
  const _PostJobButton({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.navyAction,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        elevation: 0,
        textStyle: AppTextStyles.navyButton.copyWith(fontSize: 13),
      ),
      child: const Text('Post a Job'),
    );
  }
}
