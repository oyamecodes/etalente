import 'package:flutter/material.dart';

import '../../app/theme.dart';
import 'app_side_nav.dart';
import 'app_top_bar.dart';

/// Adaptive shell for the dashboard screens:
///
/// - Wide (>= 1100px): sidebar | ( top bar / body + right rail )
/// - Medium (>= 700px): sidebar | (top bar / body) — right rail stacks under body
/// - Narrow: AppBar w/ hamburger → Drawer sidebar, single column body,
///   right-rail cards appear below.
class DashboardShell extends StatelessWidget {
  const DashboardShell({
    super.key,
    required this.active,
    required this.body,
    required this.rightRail,
    this.floatingActionButton,
  });

  final NavItem active;
  final Widget body;

  /// Column of Quick Stats / Featured Talent / Chatbot cards.
  final Widget rightRail;

  final Widget? floatingActionButton;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final isWide = width >= 1100;
    final isMedium = width >= 700 && !isWide;

    if (isWide) {
      return _Desktop(
        active: active,
        body: body,
        rightRail: rightRail,
        floatingActionButton: floatingActionButton,
      );
    }

    if (isMedium) {
      return Scaffold(
        backgroundColor: AppColors.dashboardSurface,
        body: Row(
          children: [
            const SizedBox(width: 240, child: AppSideNav(active: NavItem.jobPosts)),
            Expanded(
              child: Column(
                children: [
                  const AppTopBar(),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          body,
                          const SizedBox(height: 20),
                          rightRail,
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        floatingActionButton: floatingActionButton,
      );
    }

    // Narrow / mobile.
    return _Mobile(
      active: active,
      body: body,
      rightRail: rightRail,
      floatingActionButton: floatingActionButton,
    );
  }
}

class _Desktop extends StatelessWidget {
  const _Desktop({
    required this.active,
    required this.body,
    required this.rightRail,
    this.floatingActionButton,
  });

  final NavItem active;
  final Widget body;
  final Widget rightRail;
  final Widget? floatingActionButton;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.dashboardSurface,
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(width: 240, child: AppSideNav(active: active)),
          Expanded(
            child: Column(
              children: [
                const AppTopBar(),
                Expanded(
                  child: SingleChildScrollView(
                    padding:
                        const EdgeInsets.fromLTRB(32, 24, 32, 40),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(flex: 3, child: body),
                        const SizedBox(width: 24),
                        SizedBox(width: 320, child: rightRail),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: floatingActionButton,
    );
  }
}

class _Mobile extends StatelessWidget {
  const _Mobile({
    required this.active,
    required this.body,
    required this.rightRail,
    this.floatingActionButton,
  });

  final NavItem active;
  final Widget body;
  final Widget rightRail;
  final Widget? floatingActionButton;

  @override
  Widget build(BuildContext context) {
    final scaffoldKey = GlobalKey<ScaffoldState>();
    return Scaffold(
      key: scaffoldKey,
      backgroundColor: AppColors.dashboardSurface,
      drawer: Drawer(
        backgroundColor: AppColors.sidebarNavy,
        width: 280,
        child: AppSideNav(
          active: active,
          onSelect: () {
            if (scaffoldKey.currentState?.isDrawerOpen ?? false) {
              Navigator.of(scaffoldKey.currentContext!).pop();
            }
          },
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            AppTopBar(
              leading: Builder(
                builder: (ctx) => IconButton(
                  icon: const Icon(Icons.menu, color: AppColors.onSurface),
                  onPressed: () => Scaffold.of(ctx).openDrawer(),
                ),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    body,
                    const SizedBox(height: 16),
                    rightRail,
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: floatingActionButton,
    );
  }
}
