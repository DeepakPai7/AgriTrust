import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../main.dart';
import '../screens/deals_screen.dart';
import '../screens/farmer_dashboard_screen.dart';
import '../screens/market_prices_screen.dart';

/// Shared top app bar (logo + language switcher) used across screens so the
/// header navigation is identical everywhere.
class AppTopBar extends StatelessWidget implements PreferredSizeWidget {
  const AppTopBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(64);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      toolbarHeight: 64,
      backgroundColor: AppColors.surface,
      elevation: 0,
      scrolledUnderElevation: 0,
      shadowColor: Colors.transparent,
      flexibleSpace: const DecoratedBox(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Color(0x0D059669),
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
      ),
      titleSpacing: 0,
      title: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: const [
            Flexible(child: AppLogo()),
            AppLanguageButton(),
          ],
        ),
      ),
    );
  }
}

/// Brand logo (icon + wordmark).
class AppLogo extends StatelessWidget {
  const AppLogo({super.key});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {},
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.agriculture,
                color: AppColors.primary,
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  'DealCheck',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 24,
                    height: 1.33,
                    fontWeight: FontWeight.w600,
                    letterSpacing: -0.01,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Language switcher; shows a compact icon on narrow screens to avoid
/// overflowing the app bar.
class AppLanguageButton extends StatelessWidget {
  const AppLanguageButton({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final showLabel = width >= 480;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {},
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.language,
                size: 20,
                color: AppColors.onSurfaceVariant,
              ),
              if (showLabel) ...[
                const SizedBox(width: 8),
                Text(
                  'English/ಕನ್ನಡ',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    height: 20 / 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Shared bottom navigation bar used by all main screens. Navigation order:
/// Home, Marketplace, Deals, Profile. Active item is highlighted.
class AppBottomNav extends StatelessWidget {
  const AppBottomNav({super.key, required this.activeIndex});

  /// Zero-based index of the active top-level tab.
  final int activeIndex;

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 768;

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.outlineVariant)),
        boxShadow: [
          BoxShadow(
            color: Color(0x0D000000),
            blurRadius: 10,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _NavItem(
              icon: Icons.dashboard,
              label: 'Home',
              active: activeIndex == 0,
              showLabel: isDesktop,
              onTap: () => _open(context, 0),
            ),
            _NavItem(
              icon: Icons.storefront,
              label: 'Marketplace',
              active: activeIndex == 1,
              showLabel: isDesktop,
              onTap: () => _open(context, 1),
            ),
            _NavItem(
              icon: Icons.handshake,
              label: 'Deals',
              active: activeIndex == 2,
              showLabel: isDesktop,
              onTap: () => _open(context, 2),
            ),
            _NavItem(
              icon: Icons.person,
              label: 'Profile',
              active: activeIndex == 3,
              showLabel: isDesktop,
              onTap: () {},
            ),
          ],
        ),
      ),
    );
  }

  void _open(BuildContext context, int index) {
    if (index == activeIndex) return;
    final screen = switch (index) {
      0 => const FarmerDashboardScreen(),
      1 => const MarketPricesScreen(),
      2 => const DealsScreen(),
      _ => null,
    };
    if (screen == null) return;
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => screen),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.label,
    required this.active,
    required this.showLabel,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool active;
  final bool showLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = active ? AppColors.onPrimaryContainer : AppColors.onSurfaceVariant;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      child: Material(
        color: active ? AppColors.primaryContainer : Colors.transparent,
        borderRadius: BorderRadius.circular(999),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(999),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  color: active ? AppColors.onPrimaryContainer : color,
                ),
                if (showLabel) ...[
                  const SizedBox(height: 4),
                  Text(
                    label,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      height: 20 / 14,
                      fontWeight: FontWeight.w500,
                      color: active
                          ? AppColors.onPrimaryContainer
                          : AppColors.onSurfaceVariant,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
