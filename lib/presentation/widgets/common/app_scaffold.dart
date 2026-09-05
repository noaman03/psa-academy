import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';

class NavDestinationItem {
  final String label;
  final IconData icon;
  final IconData? selectedIcon;

  const NavDestinationItem({
    required this.label,
    required this.icon,
    this.selectedIcon,
  });
}

class AppScaffold extends StatelessWidget {
  final String title;
  final String roleBadgeText;
  final String userName;
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;
  final List<NavDestinationItem> destinations;
  final Widget body;
  final List<Widget>? actions;
  final Widget? floatingActionButton;
  final VoidCallback? onLogout;

  const AppScaffold({
    super.key,
    required this.title,
    required this.roleBadgeText,
    required this.userName,
    required this.selectedIndex,
    required this.onDestinationSelected,
    required this.destinations,
    required this.body,
    this.actions,
    this.floatingActionButton,
    this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isDesktop = width >= AppSpacing.tabletBreakpoint;

    if (isDesktop) {
      return Scaffold(
        backgroundColor: AppColors.background,
        floatingActionButton: floatingActionButton,
        body: Row(
          children: [
            // Fixed Left Dark Navy Sidebar (Stitch Design)
            Container(
              width: AppSpacing.sidebarWidth,
              decoration: const BoxDecoration(
                color: AppColors.secondary,
                border: Border(
                  right: BorderSide(color: AppColors.outlineVariant, width: 0.5),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Brand Header
                  Padding(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: AppRadius.mdBorderRadius,
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.sports_soccer,
                              color: AppColors.textWhite,
                              size: 22,
                            ),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'PSA ACADEMY',
                              style: AppTypography.labelLg.copyWith(
                                color: AppColors.textWhite,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.8,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.primaryDark,
                                borderRadius: AppRadius.smBorderRadius,
                              ),
                              child: Text(
                                roleBadgeText.toUpperCase(),
                                style: AppTypography.labelSm.copyWith(
                                  color: AppColors.primaryLight,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 9,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const Divider(color: Color(0xFF1E3A5F), height: 1),

                  const SizedBox(height: AppSpacing.md),

                  // Nav items
                  Expanded(
                    child: ListView.builder(
                      itemCount: destinations.length,
                      itemBuilder: (context, index) {
                        final item = destinations[index];
                        final isSelected = index == selectedIndex;
                        return Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 4,
                          ),
                          child: InkWell(
                            onTap: () => onDestinationSelected(index),
                            borderRadius: AppRadius.mdBorderRadius,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 10,
                              ),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? const Color(0xFF1E3A5F)
                                    : Colors.transparent,
                                borderRadius: AppRadius.mdBorderRadius,
                                border: isSelected
                                    ? const Border(
                                        left: BorderSide(
                                          color: AppColors.primary,
                                          width: 4,
                                        ),
                                      )
                                    : null,
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    isSelected
                                        ? (item.selectedIcon ?? item.icon)
                                        : item.icon,
                                    color: isSelected
                                        ? AppColors.primaryLight
                                        : AppColors.textTertiary,
                                    size: 20,
                                  ),
                                  const SizedBox(width: AppSpacing.sm),
                                  Text(
                                    item.label,
                                    style: AppTypography.bodyMd.copyWith(
                                      color: isSelected
                                          ? AppColors.textWhite
                                          : AppColors.textTertiary,
                                      fontWeight: isSelected
                                          ? FontWeight.w600
                                          : FontWeight.w400,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  // Bottom User Info & Logout
                  const Divider(color: Color(0xFF1E3A5F), height: 1),
                  Padding(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 18,
                          backgroundColor: AppColors.primaryDark,
                          child: Text(
                            userName.isNotEmpty
                                ? userName[0].toUpperCase()
                                : 'U',
                            style: AppTypography.labelMd
                                .copyWith(color: AppColors.textWhite),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                userName,
                                style: AppTypography.labelMd.copyWith(
                                  color: AppColors.textWhite,
                                  fontWeight: FontWeight.w600,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                roleBadgeText,
                                style: AppTypography.labelSm.copyWith(
                                  color: AppColors.textTertiary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (onLogout != null)
                          IconButton(
                            icon: const Icon(
                              Icons.logout,
                              color: AppColors.textTertiary,
                              size: 18,
                            ),
                            tooltip: 'Logout',
                            onPressed: onLogout,
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Main Content Area
            Expanded(
              child: Column(
                children: [
                  // Desktop Top bar
                  Container(
                    height: 64,
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.lg,
                    ),
                    decoration: const BoxDecoration(
                      color: AppColors.surface,
                      border: Border(
                        bottom: BorderSide(color: AppColors.outline, width: 1),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          title,
                          style: AppTypography.headlineSm.copyWith(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Row(
                          children: actions ?? [],
                        ),
                      ],
                    ),
                  ),

                  // Scrollable Body
                  Expanded(
                    child: body,
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    // Mobile / Compact Layout
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: AppTypography.headlineSm.copyWith(
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(
              userName,
              style: AppTypography.labelSm.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
        actions: [
          ...?actions,
          if (onLogout != null)
            IconButton(
              icon: const Icon(Icons.logout, size: 20),
              tooltip: 'Logout',
              onPressed: onLogout,
            ),
        ],
      ),
      body: body,
      floatingActionButton: floatingActionButton,
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: AppColors.surface,
          border: Border(
            top: BorderSide(color: AppColors.outline, width: 1),
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: selectedIndex,
          onTap: onDestinationSelected,
          type: BottomNavigationBarType.fixed,
          backgroundColor: AppColors.surface,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: AppColors.textTertiary,
          elevation: 0,
          selectedLabelStyle: AppTypography.labelSm.copyWith(
            fontWeight: FontWeight.w700,
          ),
          unselectedLabelStyle: AppTypography.labelSm,
          items: destinations
              .map(
                (d) => BottomNavigationBarItem(
                  icon: Icon(d.icon),
                  activeIcon: Icon(d.selectedIcon ?? d.icon),
                  label: d.label,
                ),
              )
              .toList(),
        ),
      ),
    );
  }
}
