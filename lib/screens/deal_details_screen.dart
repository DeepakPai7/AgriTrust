import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../main.dart';
import '../models/models.dart';
import '../services/api_scope.dart';
import '../services/session.dart';
import '../widgets/app_bars.dart';
import 'payment_success_screen.dart';

/// Task-focused "Deal Details" view. Uses the shared top bar but suppresses
/// the bottom navigation shell so the canvas takes priority for settlement.
class DealDetailsScreen extends StatefulWidget {
  const DealDetailsScreen({super.key, required this.dealId});

  static const double maxContentWidth = 1024; // matches Tailwind's max-w-5xl

  /// Backend deal ID loaded via the API.
  final int dealId;

  @override
  State<DealDetailsScreen> createState() => _DealDetailsScreenState();
}

class _DealDetailsScreenState extends State<DealDetailsScreen> {
  late Future<_DealBundle> _bundleFuture;

  @override
  void initState() {
    super.initState();
    _bundleFuture = _load();
  }

  Future<_DealBundle> _load() async {
    final api = ApiScope.of(context);
    final dealFuture = api.fetchDeal(widget.dealId);
    final calcFuture = api.fetchCalculation(widget.dealId);
    final settlementFuture = api.fetchSettlement(widget.dealId);
    final results = await Future.wait([
      dealFuture,
      calcFuture,
      settlementFuture,
    ]);
    return _DealBundle(
      deal: results[0] as Deal,
      calculation: results[1] as Calculation?,
      settlement: results[2] as Settlement?,
    );
  }

  void _reload() {
    setState(() {
      _bundleFuture = _load();
    });
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isDesktop = width >= 768;

    return Scaffold(
      appBar: const AppTopBar(),
      backgroundColor: AppColors.background,
      body: SafeArea(
        top: false,
        bottom: false,
        child: SingleChildScrollView(
          padding: EdgeInsets.only(
            top: 32,
            bottom: isDesktop ? 48 : 96,
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: DealDetailsScreen.maxContentWidth,
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: isDesktop ? 64 : 16,
                ),
                child: _DetailsBody(
                  bundleFuture: _bundleFuture,
                  onRetry: _reload,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DealBundle {
  const _DealBundle({
    required this.deal,
    required this.calculation,
    required this.settlement,
  });

  final Deal deal;
  final Calculation? calculation;
  final Settlement? settlement;
}

class _DetailsBody extends StatelessWidget {
  const _DetailsBody({required this.bundleFuture, required this.onRetry});

  final Future<_DealBundle> bundleFuture;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<_DealBundle>(
      future: bundleFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 64),
            child: Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            ),
          );
        }
        if (snapshot.hasError) {
          return Column(
            children: [
              const Icon(
                Icons.cloud_off,
                size: 40,
                color: AppColors.onSurfaceVariant,
              ),
              const SizedBox(height: 12),
              Text(
                'Could not load deal details',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  color: AppColors.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: onRetry,
                child: Text(
                  'Retry',
                  style: GoogleFonts.inter(color: AppColors.primary),
                ),
              ),
            ],
          );
        }
        final bundle = snapshot.data!;
        final width = MediaQuery.of(context).size.width;
        final isDesktop = width >= 768;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const _BackBar(),
            const SizedBox(height: 16),
            _DealHeader(bundle: bundle),
            const SizedBox(height: 24),
            _Timeline(bundle: bundle),
            const SizedBox(height: 24),
            if (isDesktop)
              _BentoGrid(bundle: bundle)
            else
              _MobileStack(bundle: bundle),
          ],
        );
      },
    );
  }
}

class _BackBar extends StatelessWidget {
  const _BackBar();

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: InkWell(
        onTap: () => Navigator.of(context).maybePop(),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.arrow_back,
                size: 20,
                color: AppColors.onSurfaceVariant,
              ),
              const SizedBox(width: 6),
              Text(
                'Back to Deals',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  height: 20 / 14,
                  color: AppColors.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

bool _isSettled(_DealBundle bundle) {
  if (bundle.settlement != null &&
      (bundle.settlement!.status == 'paid' ||
          bundle.settlement!.status == 'completed')) {
    return true;
  }
  return bundle.deal.status == 'completed';
}

String _formatDate(String iso) {
  try {
    final parts = DateTime.parse(iso).toLocal();
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${months[parts.month - 1]} ${parts.day}, ${parts.year}';
  } catch (_) {
    return iso;
  }
}

String _initials(String name) {
  final words = name.trim().split(RegExp(r'\s+'));
  if (words.isEmpty) return '?';
  if (words.length == 1) return words[0].substring(0, 1).toUpperCase();
  return (words[0][0] + words[1][0]).toUpperCase();
}

/// Header: deal id + status badge + created date + action buttons.
class _DealHeader extends StatelessWidget {
  const _DealHeader({required this.bundle});

  final _DealBundle bundle;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isDesktop = width >= 768;
    final deal = bundle.deal;
    final settled = _isSettled(bundle);

    final titleBlock = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Deal #DC-${deal.id}',
          style: GoogleFonts.inter(
            fontSize: 32,
            height: 40 / 32,
            letterSpacing: -0.01,
            fontWeight: FontWeight.w600,
            color: AppColors.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 12,
          runSpacing: 8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            _StatusBadge(settled: settled),
            Text(
              'Created ${deal.createdAt == null || deal.createdAt!.isEmpty ? '' : _formatDate(deal.createdAt!)}',
              style: GoogleFonts.inter(
                fontSize: 16,
                height: 24 / 16,
                color: AppColors.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ],
    );

    final actions = _HeaderActions(bundle: bundle, settled: settled);

    if (isDesktop) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(child: titleBlock),
          const SizedBox(width: 16),
          actions,
        ],
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        titleBlock,
        const SizedBox(height: 16),
        actions,
      ],
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.settled});

  final bool settled;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: settled ? AppColors.primaryFixed : AppColors.secondaryFixed,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        settled ? 'Settled' : 'Settlement Pending',
        style: GoogleFonts.inter(
          fontSize: 12,
          height: 16 / 12,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.6,
        color: settled
            ? AppColors.onPrimaryFixedVariant
            : const Color(0xFF351000),
        ),
      ),
    );
  }
}

/// The "Raise Dispute" and "Confirm & Pay" action buttons. Stacks on mobile.
class _HeaderActions extends StatelessWidget {
  const _HeaderActions({required this.bundle, required this.settled});

  final _DealBundle bundle;
  final bool settled;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isDesktop = width >= 768;
    final role = AppSession.currentUser?.role;

    final dispute = OutlinedButton(
      onPressed: () {},
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.onSurface,
        side: const BorderSide(color: AppColors.outline),
        minimumSize: Size(isDesktop ? 0 : double.infinity, 56),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: Text(
        'Raise Dispute',
        style: GoogleFonts.inter(
          fontSize: 14,
          height: 20 / 14,
          fontWeight: FontWeight.w500,
        ),
      ),
    );

    // Farmers only settle/dispute through manual channels; they may still
    // raise a dispute but do not initiate the buyer payment here.
    if (role == 'farmer') {
      return isDesktop
          ? Row(
              mainAxisSize: MainAxisSize.min,
              children: [dispute],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [dispute],
            );
    }

    final pay = _PayButton(bundle: bundle, settled: settled, isDesktop: isDesktop);

    if (isDesktop) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          dispute,
          const SizedBox(width: 12),
          pay,
        ],
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        dispute,
        const SizedBox(height: 8),
        pay,
      ],
    );
  }
}

class _PayButton extends StatefulWidget {
  const _PayButton({
    required this.bundle,
    required this.settled,
    required this.isDesktop,
  });

  final _DealBundle bundle;
  final bool settled;
  final bool isDesktop;

  @override
  State<_PayButton> createState() => _PayButtonState();
}

class _PayButtonState extends State<_PayButton> {
  bool _submitting = false;

  Future<void> _confirmPay() async {
    if (_submitting) return;
    setState(() => _submitting = true);
    final deal = widget.bundle.deal;
    final net = widget.bundle.calculation?.netAmount ??
        deal.agreedPrice * deal.quantity;
    final api = ApiScope.of(context);
    try {
      await api.createOrUpdateSettlement(
        deal.id,
        deliveredQuantity: deal.quantity,
        paymentAmount: net,
        status: 'completed',
      );
      await api.updateDealStatus(deal.id, 'completed');
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute<void>(
            builder: (_) => PaymentSuccessScreen(
              dealId: 'DC-${deal.id}',
              productName: deal.productName,
              quantity: deal.quantity,
              unit: deal.unit,
              amount: net,
            ),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final disabled = widget.settled;

    return Material(
      color: disabled ? AppColors.outlineVariant : AppColors.primary,
      borderRadius: BorderRadius.circular(8),
      shadowColor: const Color(0xFF000000),
      elevation: disabled ? 0 : 1,
      child: InkWell(
        onTap: disabled ? null : _confirmPay,
        borderRadius: BorderRadius.circular(8),
        child: SizedBox(
          height: 56,
          width: widget.isDesktop ? null : double.infinity,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Center(
              child: _submitting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.onPrimary,
                      ),
                    )
                  : Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.payments,
                          color: AppColors.onPrimary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          disabled ? 'Settled' : 'Confirm & Pay',
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
        ),
      ),
    );
  }
}

/// Process Timeline card with the four settlement steps.
class _Timeline extends StatelessWidget {
  const _Timeline({required this.bundle});

  final _DealBundle bundle;

  @override
  Widget build(BuildContext context) {
    final settled = _isSettled(bundle);
    final steps = <_TimelineStep>[
      const _TimelineStep(label: 'Agreed', state: _StepState.done),
      const _TimelineStep(label: 'Inspected', state: _StepState.done),
      _TimelineStep(
        label: 'Settlement',
        state: settled ? _StepState.done : _StepState.current,
      ),
      _TimelineStep(
        label: 'Closed',
        state: settled ? _StepState.done : _StepState.upcoming,
      ),
    ];

    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Process Timeline',
            style: GoogleFonts.inter(
              fontSize: 24,
              height: 32 / 24,
              fontWeight: FontWeight.w600,
              color: AppColors.secondary,
            ),
          ),
          const SizedBox(height: 16),
          LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth;
              final stepWidth = constraints.maxWidth / steps.length;
              final doneCount = settled ? 4 : 3;
              final progressWidth = width * (doneCount / steps.length);
              return SizedBox(
                height: 72,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    // Track.
                    Positioned(
                      left: 0,
                      right: 0,
                      top: 16,
                      child: Container(
                        height: 2,
                        color: AppColors.surfaceVariant,
                      ),
                    ),
                    // Progress.
                    Positioned(
                      left: 0,
                      top: 16,
                      width: progressWidth,
                      child: Container(
                        height: 2,
                        color: AppColors.primary,
                      ),
                    ),
                    // Steps.
                    for (var i = 0; i < steps.length; i++)
                      Positioned(
                        left: stepWidth * i,
                        width: stepWidth,
                        top: 0,
                        child: Column(
                          children: [
                            _StepDot(state: steps[i].state),
                            const SizedBox(height: 8),
                            Text(
                              steps[i].label,
                              textAlign: TextAlign.center,
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                height: 20 / 14,
                                fontWeight: steps[i].state == _StepState.current
                                    ? FontWeight.bold
                                    : FontWeight.w400,
                                color: steps[i].state == _StepState.current ||
                                        steps[i].state == _StepState.done
                                    ? AppColors.onSurface
                                    : AppColors.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

enum _StepState { done, current, upcoming }

class _TimelineStep {
  const _TimelineStep({required this.label, required this.state});

  final String label;
  final _StepState state;
}

class _StepDot extends StatelessWidget {
  const _StepDot({required this.state});

  final _StepState state;

  @override
  Widget build(BuildContext context) {
    final done = state == _StepState.done;
    final current = state == _StepState.current;

    final Widget child;
    if (done) {
      child = Container(
        width: 32,
        height: 32,
        decoration: const BoxDecoration(
          color: AppColors.primary,
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.check,
          size: 16,
          color: AppColors.onPrimary,
        ),
      );
    } else if (current) {
      child = Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.primary, width: 2),
          color: AppColors.surface,
        ),
        child: Center(
          child: Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
          ),
        ),
      );
    } else {
      child = Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.outlineVariant, width: 2),
          color: AppColors.surface,
        ),
      );
    }

    return Container(
      color: AppColors.surface,
      child: child,
    );
  }
}

/// Desktop bento grid: product (8/12) beside participants (4/12), then the
/// full-width financial settlement card.
class _BentoGrid extends StatelessWidget {
  const _BentoGrid({required this.bundle});

  final _DealBundle bundle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 8,
              child: _ProductCard(bundle: bundle),
            ),
            const SizedBox(width: 24),
            Expanded(
              flex: 4,
              child: _ParticipantColumn(bundle: bundle),
            ),
          ],
        ),
        const SizedBox(height: 24),
        _FinancialCard(bundle: bundle),
      ],
    );
  }
}

/// Mobile layout: product, participants, financial stacked.
class _MobileStack extends StatelessWidget {
  const _MobileStack({required this.bundle});

  final _DealBundle bundle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _ProductCard(bundle: bundle),
        const SizedBox(height: 16),
        _ParticipantColumn(bundle: bundle),
        const SizedBox(height: 16),
        _FinancialCard(bundle: bundle),
      ],
    );
  }
}

/// Shared elevated card used across the deal details sections.
class _Card extends StatelessWidget {
  const _Card({required this.child, this.padding = const EdgeInsets.all(16)});

  final Widget child;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D059669),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _ProductCard extends StatelessWidget {
  const _ProductCard({required this.bundle});

  final _DealBundle bundle;

  @override
  Widget build(BuildContext context) {
    final deal = bundle.deal;
    final calc = bundle.calculation;
    final unit = deal.unit;
    final effective = _num(calc?.effectivePrice ?? deal.agreedPrice);

    return _Card(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const _ProductHero(),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Product Details',
                  style: GoogleFonts.inter(
                    fontSize: 24,
                    height: 32 / 24,
                    fontWeight: FontWeight.w600,
                    color: AppColors.secondary,
                  ),
                ),
                const SizedBox(height: 16),
                _DetailRow(
                  label: 'Commodity',
                  value: deal.productName,
                  valueBold: true,
                ),
                if (bundle.calculation != null) ...[
                  _DetailRow(
                    label: 'Effective Price per ${unit.isEmpty ? 'unit' : unit}',
                    value: '₹$effective',
                    valueColor: AppColors.primary,
                    valueBold: true,
                    highlight: true,
                  ),
                ] else ...[
                  _DetailRow(
                    label: 'Agreed Rate per ${unit.isEmpty ? 'unit' : unit}',
                    value: '₹${_num(deal.agreedPrice)}',
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Decorative gradient placeholder in place of the produce photo.
class _ProductHero extends StatelessWidget {
  const _ProductHero();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      height: 192,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF7A4A2B), Color(0xFFC96A2E), Color(0xFFF2B880)],
          ),
        ),
        child: Center(
          child: Icon(
            Icons.eco,
            size: 72,
            color: Colors.white70,
          ),
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.label,
    required this.value,
    this.valueColor = AppColors.onSurface,
    this.valueBold = false,
    this.highlight = false,
  });

  final String label;
  final String value;
  final Color valueColor;
  final bool valueBold;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    final row = Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 16,
                height: 24 / 16,
                color: AppColors.onSurfaceVariant,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: GoogleFonts.inter(
                fontSize: 16,
                height: 24 / 16,
                fontWeight: valueBold ? FontWeight.w600 : FontWeight.w400,
                color: valueColor,
              ),
            ),
          ),
        ],
      ),
    );

    if (highlight) {
      return Container(
        margin: const EdgeInsets.only(top: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(8),
        ),
        child: row,
      );
    }

    return Container(
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppColors.surfaceVariant),
        ),
      ),
      child: row,
    );
  }
}

class _ParticipantColumn extends StatelessWidget {
  const _ParticipantColumn({required this.bundle});

  final _DealBundle bundle;

  @override
  Widget build(BuildContext context) {
    final deal = bundle.deal;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _ParticipantCard(
          title: 'Farmer (Seller)',
          initials: _initials(deal.farmerName),
          name: deal.farmerName,
          location: deal.location ?? '',
          avatarColor: AppColors.primaryContainer,
          avatarTextColor: AppColors.onPrimaryContainer,
          showLocationIcon: true,
        ),
        const SizedBox(height: 24),
        _ParticipantCard(
          title: 'Buyer',
          icon: Icons.storefront,
          name: deal.buyerName,
          location: 'Institutional Buyer ID: ${deal.buyerId}',
          avatarColor: AppColors.tertiaryContainer,
          avatarTextColor: AppColors.onTertiaryContainer,
          showLocationIcon: false,
        ),
      ],
    );
  }
}

class _ParticipantCard extends StatelessWidget {
  const _ParticipantCard({
    required this.title,
    required this.name,
    required this.location,
    required this.avatarColor,
    required this.avatarTextColor,
    this.initials,
    this.icon,
    required this.showLocationIcon,
  });

  final String title;
  final String name;
  final String location;
  final Color avatarColor;
  final Color avatarTextColor;
  final String? initials;
  final IconData? icon;
  final bool showLocationIcon;

  @override
  Widget build(BuildContext context) {
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title.toUpperCase(),
            style: GoogleFonts.inter(
              fontSize: 14,
              height: 20 / 14,
              letterSpacing: 0.04,
              fontWeight: FontWeight.w500,
              color: AppColors.secondary,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: avatarColor,
                  shape: BoxShape.circle,
                ),
                child: icon != null
                    ? Icon(icon, color: avatarTextColor, size: 24)
                    : Text(
                        initials ?? '?',
                        style: GoogleFonts.inter(
                          fontSize: 24,
                          fontWeight: FontWeight.w600,
                          color: avatarTextColor,
                        ),
                      ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        height: 24 / 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.onSurface,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (showLocationIcon) ...[
                          const Padding(
                            padding: EdgeInsets.only(top: 3),
                            child: Icon(
                              Icons.location_on,
                              size: 16,
                              color: AppColors.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(width: 4),
                        ],
                        Expanded(
                          child: Text(
                            location,
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              height: 20 / 14,
                              color: AppColors.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _FinancialCard extends StatelessWidget {
  const _FinancialCard({required this.bundle});

  final _DealBundle bundle;

  @override
  Widget build(BuildContext context) {
    final deal = bundle.deal;
    final calc = bundle.calculation;
    final gross = calc?.grossAmount ?? deal.agreedPrice * deal.quantity;
    final deductions = calc?.deductions ?? 0;
    final net = calc?.netAmount ?? (gross - deductions);

    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Icon(
                Icons.account_balance,
                size: 28,
                color: AppColors.secondary,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Financial Settlement',
                  style: GoogleFonts.inter(
                    fontSize: 24,
                    height: 32 / 24,
                    fontWeight: FontWeight.w600,
                    color: AppColors.onSurface,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(height: 1, color: AppColors.surfaceVariant),
          _FinancialRow(
            label:
                'Gross Amount (${_num(deal.quantity)} ${deal.unit} × ₹${_num(deal.agreedPrice)})',
            value: '₹${_num(gross)}',
            valueColor: AppColors.onSurface,
          ),
          _FinancialRow(
            label: 'Deductions',
            value: '-₹${_num(deductions)}',
            valueColor: AppColors.error,
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surfaceBright,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.surfaceVariant),
            ),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final narrow = constraints.maxWidth < 420;
                if (narrow) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Final Net Settlement',
                        style: GoogleFonts.inter(
                          fontSize: 24,
                          height: 32 / 24,
                          fontWeight: FontWeight.w600,
                          color: AppColors.onSurface,
                        ),
                      ),
                      const SizedBox(height: 8),
                      _NetValue(value: net),
                    ],
                  );
                }
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Flexible(
                      child: Text(
                        'Final Net Settlement',
                        style: GoogleFonts.inter(
                          fontSize: 24,
                          height: 32 / 24,
                          fontWeight: FontWeight.w600,
                          color: AppColors.onSurface,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    _NetValue(value: net),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _NetValue extends StatelessWidget {
  const _NetValue({required this.value});

  final num value;

  @override
  Widget build(BuildContext context) {
    return Text(
      '₹${_num(value)}',
      style: GoogleFonts.inter(
        fontSize: 32,
        height: 40 / 32,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.02,
        color: AppColors.primary,
      ),
    );
  }
}

class _FinancialRow extends StatelessWidget {
  const _FinancialRow({
    required this.label,
    required this.value,
    required this.valueColor,
  });

  final String label;
  final String value;
  final Color valueColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppColors.surfaceVariant),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 16,
                height: 24 / 16,
                color: AppColors.onSurfaceVariant,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: GoogleFonts.inter(
                fontSize: 16,
                height: 24 / 16,
                fontWeight: FontWeight.w600,
                color: valueColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

String _num(num value) {
  if (value == value.roundToDouble()) {
    return value.toStringAsFixed(0).replaceAllMapped(
          RegExp(r'\B(?=(\d{3})+(?!\d))'),
          (_) => ',',
        );
  }
  return value.toString();
}
