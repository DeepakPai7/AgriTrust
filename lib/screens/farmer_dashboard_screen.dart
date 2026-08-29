import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../main.dart';
import '../models/models.dart';
import '../services/api_scope.dart';
import '../widgets/app_bars.dart';
import 'add_sell_record_screen.dart';
import 'buyer_requests_screen.dart';
import 'deals_screen.dart';
import 'market_prices_screen.dart';
import 'my_products_screen.dart';
import '../services/session.dart';

class FarmerDashboardScreen extends StatelessWidget {
  const FarmerDashboardScreen({super.key});

  static const double maxContentWidth = 1280; // matches Tailwind's max-w-7xl

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Shared top app bar (logo + language switcher).
      appBar: const AppTopBar(showBack: false),
      // Shared bottom navigation bar (Home active).
      bottomNavigationBar: const AppBottomNav(activeIndex: 0),
      body: SafeArea(
        // Leave room for the fixed app bar & nav bar.
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

/// The scrollable dashboard content.
class _DashboardBody extends StatelessWidget {
  const _DashboardBody();

  @override
  Widget build(BuildContext context) {
    // Content is capped at the desktop max width in the parent; here we
    // just lay it out in a column of sections.
    final width = MediaQuery.of(context).size.width;
    final isDesktop = width >= 1024;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _WelcomeSection(isDesktop: isDesktop),
        const SizedBox(height: 32),
        const _StatsGrid(),
        const SizedBox(height: 32),
        if (isDesktop)
          const _DesktopSplit()
        else
          const _MobileStack(),
      ],
    );
  }
}

/// Welcome + "Add Sell Record" header row (responsive).
class _WelcomeSection extends StatelessWidget {
  const _WelcomeSection({required this.isDesktop});

  final bool isDesktop;

  @override
  Widget build(BuildContext context) {
    if (isDesktop) {
      return Row(
        children: [
          _WelcomeText(),
          const Spacer(),
          _AddSellRecordButton(),
        ],
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _WelcomeText(),
        const SizedBox(height: 16),
        _AddSellRecordButton(),
      ],
    );
  }
}

class _WelcomeText extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Hello, ${AppSession.currentUser?.name ?? 'Farmer'}!',
          style: GoogleFonts.inter(
            fontSize: 32,
            height: 40 / 32,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.01,
            color: AppColors.onSurface,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Here is your daily overview.',
          style: GoogleFonts.inter(
            fontSize: 16,
            height: 24 / 16,
            color: AppColors.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class _AddSellRecordButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.primary,
      borderRadius: BorderRadius.circular(8),
      elevation: 1,
      shadowColor: const Color(0x0D059669),
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const AddSellRecordScreen()),
          );
        },
        borderRadius: BorderRadius.circular(8),
        child: Container(
          constraints: const BoxConstraints(minHeight: 56),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.add,
                color: AppColors.onPrimary,
              ),
              const SizedBox(width: 8),
              Text(
                'Add Sell Record',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  height: 20 / 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.onPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Bento-style summary stats grid: 2 cols on mobile, 4 on desktop.
class _StatsGrid extends StatelessWidget {
  const _StatsGrid();

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isDesktop = width >= 768;

    final stats = [
      _StatCard(
        icon: Icons.handshake,
        iconColor: AppColors.primaryContainer,
        iconBg: AppColors.surfaceContainerLow,
        label: 'Active Deals',
        value: '4',
        valueColor: AppColors.onSurface,
      ),
      _StatCard(
        icon: Icons.pending_actions,
        iconColor: AppColors.secondary,
        iconBg: AppColors.secondaryFixed,
        label: 'Pending Requests',
        value: '2',
        valueColor: AppColors.onSurface,
      ),
      _StatCard(
        icon: Icons.inventory_2,
        iconColor: AppColors.tertiaryContainer,
        iconBg: AppColors.surfaceContainerHigh,
        label: 'Products Listed',
        value: '3',
        valueColor: AppColors.onSurface,
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const MyProductsScreen()),
          );
        },
      ),
      _StatCard(
        icon: Icons.account_balance_wallet,
        iconColor: AppColors.primaryContainer,
        iconBg: AppColors.surfaceContainerLow,
        label: 'Expected Settlement',
        value: '₹45,000',
        valueColor: AppColors.primary,
        emphasized: true,
      ),
    ];

    if (isDesktop) {
      return IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (var i = 0; i < stats.length; i++) ...[
              if (i > 0) const SizedBox(width: 16),
              Expanded(child: stats[i]),
            ],
          ],
        ),
      );
    }
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: stats[0]),
            const SizedBox(width: 16),
            Expanded(child: stats[1]),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: stats[2]),
            const SizedBox(width: 16),
            Expanded(child: stats[3]),
          ],
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.label,
    required this.value,
    required this.valueColor,
    this.emphasized = false,
    this.onTap,
  });

  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final String label;
  final String value;
  final Color valueColor;
  final bool emphasized;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(12),
            boxShadow: const [
              BoxShadow(
                color: Color(0x0D059669),
                blurRadius: 4,
                offset: Offset(0, 2),
              ),
            ],
            gradient: emphasized
                ? const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0x1A00855D), Colors.transparent],
                  )
                : null,
            border: emphasized
                ? Border.all(color: const Color(0x3300855D))
                : null,
          ),
          child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 24, color: iconColor),
          ),
          const SizedBox(height: 12),
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
              fontWeight: emphasized ? FontWeight.w700 : FontWeight.w600,
              letterSpacing: -0.01,
              color: valueColor,
            ),
          ),
        ],
        ),
      ),
      ),
    );
  }
}

/// Desktop layout: requests (2/3) beside quick actions (1/3).
class _DesktopSplit extends StatelessWidget {
  const _DesktopSplit();

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Expanded(
          flex: 2,
          child: _RequestsSection(),
        ),
        const SizedBox(width: 24),
        Expanded(
          flex: 1,
          child: _QuickActionsSection(isStacked: true),
        ),
      ],
    );
  }
}

/// Mobile layout: requests then quick actions stacked.
class _MobileStack extends StatelessWidget {
  const _MobileStack();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const _RequestsSection(),
        const SizedBox(height: 32),
        _QuickActionsSection(isStacked: false),
      ],
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
        color: AppColors.onSurface,
      ),
    );
  }
}

class _RequestsSection extends StatefulWidget {
  const _RequestsSection();

  @override
  State<_RequestsSection> createState() => _RequestsSectionState();
}

class _RequestsSectionState extends State<_RequestsSection> {
  static const int _maxShown = 2;
  List<_Request> _requests = const [];
  bool _loading = true;
  Object? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final farmerId = AppSession.currentUser?.id;
      final fetched = await ApiScope.of(context).fetchRequests(farmerId: farmerId);
      if (mounted) {
        setState(() {
          _requests = fetched.take(_maxShown).map(_toTile).toList();
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e;
          _loading = false;
        });
      }
    }
  }

  _Request _toTile(BuyerRequest r) {
    final name = r.buyerName;
    final initial = name.trim().isEmpty ? '?' : name.trim()[0].toUpperCase();
    final (badge, badgeColor, badgeBg) = switch (r.status) {
      'accepted' => (
          'Accepted',
          AppColors.primaryContainer,
          AppColors.primaryFixed,
        ),
      'rejected' => (
          'Rejected',
          AppColors.onErrorContainer,
          AppColors.errorContainer,
        ),
      _ => (
          'Pending Review',
          AppColors.secondary,
          const Color(0x80FFDBCC),
        ),
    };
    return _Request(
      initial: initial,
      name: name,
      crop: r.productName,
      cropQty: '${_num(r.quantity)} ${r.unit}',
      price: '₹${_num(r.offeredPrice)}/${r.unit}',
      badge: badge,
      badgeColor: badgeColor,
      badgeBg: badgeBg,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const _SectionHeader('Recent Buyer Requests'),
        const SizedBox(height: 16),
        Material(
          color: AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(12),
          elevation: 0,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x0D059669),
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (_loading)
                  const Padding(
                    padding: EdgeInsets.all(24),
                    child: Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primary,
                      ),
                    ),
                  )
                else if (_error != null)
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(
                      'Could not load requests.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                  )
                else if (_requests.isEmpty)
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(
                      'No buyer requests yet.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                  )
                else
                  for (var i = 0; i < _requests.length; i++) ...[
                    if (i > 0)
                      const Divider(
                        height: 1,
                        thickness: 1,
                        color: Color(0x4DBCCAC0),
                      ),
                    _RequestTile(request: _requests[i]),
                  ],
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: const BoxDecoration(
                    color: AppColors.surfaceContainerLow,
                  ),
                  child: TextButton(
                    onPressed: () {
                      final farmerId = AppSession.currentUser?.id;
                      Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) =>
                              BuyerRequestsScreen(farmerId: farmerId),
                        ),
                      );
                    },
                    child: Text(
                      'View All Requests',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _Request {
  const _Request({
    required this.initial,
    required this.name,
    required this.crop,
    required this.cropQty,
    required this.price,
    required this.badge,
    required this.badgeColor,
    required this.badgeBg,
  });

  final String initial;
  final String name;
  final String crop;
  final String cropQty;
  final String price;
  final String badge;
  final Color badgeColor;
  final Color badgeBg;
}

class _RequestTile extends StatelessWidget {
  const _RequestTile({required this.request});

  final _Request request;

  @override
  Widget build(BuildContext context) {
    // Stacked layout on narrow screens to avoid overflow.
    final width = MediaQuery.of(context).size.width;
    final compact = width < 480;

    final rightBlock = Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        const SizedBox(height: 4),
        Text(
          request.price,
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: request.badgeBg,
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text(
            request.badge,
            style: GoogleFonts.inter(
              fontSize: 12,
              height: 16 / 12,
              fontWeight: FontWeight.w600,
              color: request.badgeColor,
            ),
          ),
        ),
      ],
    );

    final title = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          request.name,
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.onSurface,
          ),
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.eco,
              size: 16,
              color: AppColors.onSurfaceVariant,
            ),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                '${request.crop} - ${request.cropQty}',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: AppColors.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ),
      ],
    );

    final avatar = Container(
      width: 48,
      height: 48,
      decoration: const BoxDecoration(
        color: AppColors.surfaceContainerHigh,
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Text(
        request.initial,
        style: GoogleFonts.inter(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: AppColors.onSurface,
        ),
      ),
    );

    return InkWell(
      onTap: () {},
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: compact
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      avatar,
                      const SizedBox(width: 16),
                      Expanded(child: title),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 12,
                    runSpacing: 8,
                    alignment: WrapAlignment.spaceBetween,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text(
                        request.price,
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: request.badgeBg,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          request.badge,
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: request.badgeColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              )
            : Row(
                children: [
                  avatar,
                  const SizedBox(width: 16),
                  Expanded(child: title),
                  rightBlock,
                ],
              ),
      ),
    );
  }
}

/// Quick Actions grid.
class _QuickActionsSection extends StatelessWidget {
  const _QuickActionsSection({required this.isStacked});

  final bool isStacked;

  @override
  Widget build(BuildContext context) {
    final actions = [
      _QuickAction(
        icon: Icons.trending_up,
        color: AppColors.tertiaryContainer,
        label: 'Market Prices',
        dashed: false,
        fullWidth: false,
        onTap: () {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const MarketPricesScreen()),
          );
        },
      ),
      _QuickAction(
        icon: Icons.handshake,
        color: AppColors.primary,
        label: 'View Deals',
        dashed: false,
        fullWidth: false,
        onTap: () {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const DealsScreen()),
          );
        },
      ),
      _QuickAction(
        icon: Icons.add_circle,
        color: AppColors.onSurfaceVariant,
        label: 'More Actions',
        dashed: true,
        fullWidth: true,
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const _SectionHeader('Quick Actions'),
        const SizedBox(height: 16),
        if (isStacked)
          Column(
            children: [
              for (var i = 0; i < actions.length; i++) ...[
                if (i > 0) const SizedBox(height: 8),
                actions[i],
              ],
            ],
          )
        else
          Column(
            children: [
              Row(
                children: [
                  Expanded(child: actions[0]),
                  const SizedBox(width: 8),
                  Expanded(child: actions[1]),
                ],
              ),
              const SizedBox(height: 8),
              actions[2],
            ],
          ),
      ],
    );
  }
}

class _QuickAction extends StatelessWidget {
  const _QuickAction({
    required this.icon,
    required this.color,
    required this.label,
    required this.dashed,
    required this.fullWidth,
    this.onTap,
  });

  final IconData icon;
  final Color color;
  final String label;
  final bool dashed;
  final bool fullWidth;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    Widget content = Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
        border: dashed ? Border.all(color: AppColors.outlineVariant) : null,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 32, color: color),
          const SizedBox(height: 8),
          Text(
            label,
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 14,
              height: 20 / 14,
              fontWeight: FontWeight.w500,
              color: dashed
                  ? AppColors.onSurfaceVariant
                  : AppColors.onSurface,
            ),
          ),
        ],
      ),
    );

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: content,
      ),
    );
  }
}

String _num(num value) {
  if (value == value.roundToDouble()) {
    return value.toStringAsFixed(0);
  }
  return value.toString();
}
