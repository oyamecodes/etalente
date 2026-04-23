import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme.dart';
import '../../features/auth/application/auth_controller.dart';

/// Sidebar nav entries. Only [NavItem.jobPosts] is wired; the rest show a
/// "coming soon" snackbar per the current scope.
enum NavItem { dashboard, jobPosts, myApplications, interviews, messages }

extension NavItemLabel on NavItem {
  String get label => switch (this) {
        NavItem.dashboard => 'Dashboard',
        NavItem.jobPosts => 'Job Posts',
        NavItem.myApplications => 'My Applications',
        NavItem.interviews => 'Interviews',
        NavItem.messages => 'Messages',
      };

  IconData get icon => switch (this) {
        NavItem.dashboard => Icons.dashboard_outlined,
        NavItem.jobPosts => Icons.work_outline,
        NavItem.myApplications => Icons.assignment_outlined,
        NavItem.interviews => Icons.calendar_today_outlined,
        NavItem.messages => Icons.mail_outline,
      };
}

/// Dark-navy left rail matching the mock. Rendered directly on desktop
/// and inside a [Drawer] on mobile.
class AppSideNav extends ConsumerWidget {
  const AppSideNav({
    super.key,
    required this.active,
    this.onSelect,
  });

  final NavItem active;

  /// Called after the active item is changed — used by the mobile drawer
  /// to close itself. Desktop rail passes null.
  final VoidCallback? onSelect;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Material(
      color: AppColors.sidebarNavy,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('eTalente',
                      style: AppTextStyles.logoWordmark
                          .copyWith(fontSize: 24, letterSpacing: 0)),
                  const SizedBox(height: 2),
                  Text('Recruitment Portal',
                      style: AppTextStyles.bodyMuted.copyWith(
                          color: Colors.white.withValues(alpha: 0.6),
                          fontSize: 11,
                          fontWeight: FontWeight.w500)),
                ],
              ),
            ),
            const SizedBox(height: 36),
            for (final item in NavItem.values)
              _NavTile(
                item: item,
                active: item == active,
                onTap: () => _handleTap(context, ref, item),
              ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: ElevatedButton(
                onPressed: () => _comingSoon(context, 'Upgrade Plan'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accentYellow,
                  foregroundColor: AppColors.onSurface,
                  minimumSize: const Size.fromHeight(48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  textStyle: GoogleFontsSurrogate.bold(14),
                  elevation: 0,
                ),
                child: const Text('Upgrade Plan'),
              ),
            ),
            _FooterTile(
              icon: Icons.settings_outlined,
              label: 'Settings',
              onTap: () => _comingSoon(context, 'Settings'),
            ),
            _FooterTile(
              icon: Icons.logout_outlined,
              label: 'Logout',
              onTap: () {
                ref.read(authSessionProvider.notifier).state = null;
                onSelect?.call();
                context.go('/');
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _handleTap(BuildContext context, WidgetRef ref, NavItem item) {
    if (item == NavItem.jobPosts) {
      onSelect?.call();
      return;
    }
    _comingSoon(context, item.label);
  }

  void _comingSoon(BuildContext context, String label) {
    onSelect?.call();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$label — coming soon')),
    );
  }
}

class _NavTile extends StatelessWidget {
  const _NavTile({
    required this.item,
    required this.active,
    required this.onTap,
  });

  final NavItem item;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final background = active ? AppColors.accentYellow : Colors.transparent;
    final fg = active
        ? AppColors.onSurface
        : Colors.white.withValues(alpha: 0.82);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
      child: Material(
        color: background,
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: onTap,
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                Icon(item.icon, size: 20, color: fg),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    item.label,
                    overflow: TextOverflow.ellipsis,
                    style: active
                        ? AppTextStyles.sidebarItemActive
                        : AppTextStyles.sidebarItem,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FooterTile extends StatelessWidget {
  const _FooterTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
        child: Row(
          children: [
            Icon(icon,
                size: 18,
                color: Colors.white.withValues(alpha: 0.82)),
            const SizedBox(width: 12),
            Text(label, style: AppTextStyles.sidebarItem),
          ],
        ),
      ),
    );
  }
}

/// Wrapper so theme.dart doesn't need to expose GoogleFonts for the
/// sidebar button text style — keeps button font consistent with the rest.
class GoogleFontsSurrogate {
  const GoogleFontsSurrogate._();
  static TextStyle bold(double size) => AppTextStyles.primaryButton.copyWith(
        fontSize: size,
        letterSpacing: 0.2,
      );
}
