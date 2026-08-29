import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../main.dart';
import '../widgets/app_bars.dart';
import 'buyer_profile_screen.dart';
import 'buyer_request_form_screen.dart';
import 'deals_screen.dart';
import 'marketplace_screen.dart';
import 'my_requests_screen.dart';
import '../services/session.dart';

/// The buyer-facing dashboard: summary stats, quick actions, recent activity
/// and a market insights banner. Mirrors the "Welcome back, Buyer" design.
class BuyerDashboardScreen extends StatelessWidget {
  const BuyerDashboardScreen({super.key});

  static const double maxContentWidth = 1280; // matches Tailwind's max-w-7xl

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Shared top app bar (logo + language switcher).
      appBar: const AppTopBar(showBack: false),
      // Shared bottom navigation bar (Home active).
      bottomNavigationBar: const AppBottomNav(activeIndex: 0),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(top: 32, bottom: 24),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: maxContentWidth,
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: const _DashboardBody(),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// The scrollable dashboard content for the buyer.
class _DashboardBody extends StatelessWidget {
  const _DashboardBody();

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isDesktop = width >= 1024;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _WelcomeSection(),
        const SizedBox(height: 32),
        if (isDesktop)
          const _DesktopSplit()
        else
          const _MobileStack(),
        const SizedBox(height: 32),
        const _RecentActivity(),
        const SizedBox(height: 32),
        const _MarketInsights(),
      ],
    );
  }
}

class _WelcomeSection extends StatelessWidget {
  const _WelcomeSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Welcome back, ${AppSession.currentUser?.name ?? 'Buyer'}',
          style: const TextStyle(
            fontSize: 24,
            height: 32 / 24,
            fontWeight: FontWeight.w600,
            color: AppColors.onSurface,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'Here is a summary of your trading activity today.',
          style: TextStyle(
            fontSize: 16,
            height: 24 / 16,
            color: AppColors.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

/// Desktop: stats (2/3) beside quick actions (1/3).
class _DesktopSplit extends StatelessWidget {
  const _DesktopSplit();

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Expanded(
          flex: 8,
          child: _StatsGrid(),
        ),
        const SizedBox(width: 24),
        Expanded(
          flex: 4,
          child: _QuickActionsColumn(stacked: true),
        ),
      ],
    );
  }
}

/// Mobile: stats then quick actions stacked.
class _MobileStack extends StatelessWidget {
  const _MobileStack();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const _StatsGrid(),
        const SizedBox(height: 24),
        _QuickActionsColumn(stacked: false),
      ],
    );
  }
}

/// The three summary stat cards. 3-across on wider/desktop, stacked on mobile.
class _StatsGrid extends StatelessWidget {
  const _StatsGrid();

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    // Match sm:grid-cols-3 at >=640px.
    final wide = width >= 640;

    final stats = [
      const _StatCard(
        icon: Icons.pending_actions,
        iconColor: AppColors.tertiaryContainer,
        label: 'Active Requests',
        value: '12',
        badge: 'Updated',
        badgeColor: AppColors.onTertiaryContainer,
        badgeBg: AppColors.tertiaryContainer,
      ),
      const _StatCard(
        icon: Icons.handshake,
        iconColor: AppColors.primary,
        label: 'Active Deals',
        value: '5',
        badge: 'Action Required',
        badgeColor: AppColors.onPrimaryFixedVariant,
        badgeBg: AppColors.primaryFixed,
      ),
      const _StatCard(
        icon: Icons.notification_important,
        iconColor: AppColors.error,
        label: 'Pending Actions',
        value: '3',
        badge: 'Critical',
        badgeColor: AppColors.onErrorContainer,
        badgeBg: AppColors.errorContainer,
      ),
    ];

    if (!wide) {
      return Column(
        children: [
          for (var i = 0; i < stats.length; i++) ...[
            if (i > 0) const SizedBox(height: 16),
            stats[i],
          ],
        ],
      );
    }
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var i = 0; i < stats.length; i++) ...[
            if (i > 0) const SizedBox(width: 24),
            Expanded(child: stats[i]),
          ],
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
    required this.badge,
    required this.badgeColor,
    required this.badgeBg,
  });

  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;
  final String badge;
  final Color badgeColor;
  final Color badgeBg;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 128),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.surfaceVariant),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D059669),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, size: 32, color: iconColor),
              const SizedBox(width: 8),
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: badgeBg,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      badge,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        height: 16 / 12,
                        fontWeight: FontWeight.w600,
                        color: badgeColor,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 14,
              height: 20 / 14,
              fontWeight: FontWeight.w500,
              color: AppColors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 32,
              height: 40 / 32,
              fontWeight: FontWeight.w600,
              letterSpacing: -0.01,
              color: AppColors.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}

/// Quick Actions section (Browse Products, Create Request, View Deals).
class _QuickActionsColumn extends StatelessWidget {
  const _QuickActionsColumn({required this.stacked});

  final bool stacked;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const _SectionHeader('Quick Actions'),
        const SizedBox(height: 16),
        _QuickActionButton(
          icon: Icons.storefront,
          label: 'Browse Products',
          filled: true,
          onTap: () {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute<void>(
                builder: (_) => const MarketplaceScreen(),
              ),
            );
          },
        ),
        const SizedBox(height: 8),
        _QuickActionButton(
          icon: Icons.add_circle,
          label: 'Create Request',
          filled: false,
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => const BuyerRequestFormScreen(),
              ),
            );
          },
        ),
        const SizedBox(height: 8),
        _QuickActionButton(
          icon: Icons.list_alt,
          label: 'My Requests',
          filled: false,
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => const MyRequestsScreen(),
              ),
            );
          },
        ),
        const SizedBox(height: 8),
        _QuickActionButton(
          icon: Icons.list_alt,
          label: 'View Deals',
          filled: false,
          onTap: () {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute<void>(builder: (_) => const DealsScreen()),
            );
          },
        ),
        const SizedBox(height: 8),
        _QuickActionButton(
          icon: Icons.person,
          label: 'My Profile',
          filled: false,
          onTap: () {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute<void>(
                builder: (_) => const BuyerProfileScreen(),
              ),
            );
          },
        ),
      ],
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  const _QuickActionButton({
    required this.icon,
    required this.label,
    required this.filled,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final bool filled;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final Color bg = filled ? AppColors.primary : AppColors.surfaceContainer;
    final Color fg = filled ? AppColors.onPrimary : AppColors.onSurface;

    return Material(
      color: bg,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          constraints: const BoxConstraints(minHeight: 56),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 20, color: fg),
              const SizedBox(width: 8),
              Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  height: 20 / 14,
                  fontWeight: FontWeight.w500,
                  color: fg,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader(this.title);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: GoogleFonts.inter(
        fontSize: 24,
        height: 32 / 24,
        fontWeight: FontWeight.w600,
        color: AppColors.secondary,
      ),
    );
  }
}

/// The "Recent Activity" list with a footer link to view all activity.
class _RecentActivity extends StatelessWidget {
  const _RecentActivity();

  @override
  Widget build(BuildContext context) {
    const activities = [
      _Activity(
        icon: Icons.agriculture,
        iconColor: AppColors.onPrimaryContainer,
        iconBg: AppColors.primaryContainer,
        title: 'Farmer Ramesh listed ',
        highlight: '50Q Toor Dal',
        subtitle: '2 hours ago • Location: Hubli',
      ),
      _Activity(
        icon: Icons.task_alt,
        iconColor: AppColors.onTertiaryContainer,
        iconBg: AppColors.tertiaryContainer,
        title: 'Deal ',
        highlight: '#123',
        subtitle: '5 hours ago • 100Q Soya Bean',
      ),
      _Activity(
        icon: Icons.local_shipping,
        iconColor: AppColors.onSecondaryContainer,
        iconBg: AppColors.secondaryContainer,
        title: 'Shipment for Deal ',
        highlight: '#120',
        subtitle: 'Yesterday • Carrier: FastTrack',
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.surfaceVariant),
            boxShadow: const [
              BoxShadow(
                color: Color(0x0D059669),
                blurRadius: 4,
                offset: Offset(0, 2),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                color: AppColors.surfaceBright,
                alignment: Alignment.centerLeft,
                child: const _SectionHeader('Recent Activity'),
              ),
              for (var i = 0; i < activities.length; i++) ...[
                if (i > 0)
                  const Divider(
                    height: 1,
                    thickness: 1,
                    color: Color(0x4DBCCAC0),
                  ),
                _ActivityTile(activity: activities[i]),
              ],
              Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                color: AppColors.surfaceBright,
                child: Center(
                  child: TextButton(
                    onPressed: () {},
                    child: Text(
                      'View All Activity',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Activity {
  const _Activity({
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.title,
    required this.highlight,
    required this.subtitle,
  });

  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final String title;
  final String highlight;
  final String subtitle;
}

class _ActivityTile extends StatelessWidget {
  const _ActivityTile({required this.activity});

  final _Activity activity;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {},
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: activity.iconBg,
                shape: BoxShape.circle,
              ),
              child: Icon(activity.icon, size: 20, color: activity.iconColor),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text.rich(
                    TextSpan(
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        height: 24 / 16,
                        color: AppColors.onSurface,
                      ),
                      children: [
                        TextSpan(text: activity.title),
                        TextSpan(
                          text: activity.highlight,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    activity.subtitle,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      height: 20 / 14,
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right,
              color: AppColors.primary,
            ),
          ],
        ),
      ),
    );
  }
}

/// The "Market Insights" promotional banner at the bottom.
class _MarketInsights extends StatelessWidget {
  const _MarketInsights();

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.outlineVariant),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1A000000),
            blurRadius: 15,
            offset: Offset(0, 10),
          ),
        ],
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF85F8C4),
            Color(0xFFFFE3B3),
            Color(0xFFFFFFFF),
          ],
        ),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 256),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 28,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'Market Insights',
                      style: TextStyle(
                        fontSize: 32,
                        height: 40 / 32,
                        fontWeight: FontWeight.w600,
                        letterSpacing: -0.01,
                        color: AppColors.primary,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Stay ahead of the curve with real-time commodity pricing and supply trends.',
                      style: TextStyle(
                        fontSize: 16,
                        height: 24 / 16,
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                    SizedBox(height: 16),
                    _ViewReportsButton(),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Icon(
                Icons.eco,
                size: 140,
                color: AppColors.primary.withValues(alpha: 0.12),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ViewReportsButton extends StatelessWidget {
  const _ViewReportsButton();

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.primary,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: () {},
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            'View Reports',
            style: GoogleFonts.inter(
              fontSize: 14,
              height: 20 / 14,
              fontWeight: FontWeight.w500,
              color: AppColors.onPrimary,
            ),
          ),
        ),
      ),
    );
  }
}
