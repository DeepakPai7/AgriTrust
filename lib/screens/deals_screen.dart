import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../main.dart';
import '../models/models.dart';
import '../services/api_scope.dart';
import '../services/session.dart';
import '../widgets/app_bars.dart';
import 'deal_details_screen.dart';

/// "My Deals" screen. Uses the shared top bar and bottom navigation so the
/// chrome is identical everywhere; only the body content differs.
class DealsScreen extends StatefulWidget {
  const DealsScreen({super.key});

  static const double maxContentWidth = 1280;

  @override
  State<DealsScreen> createState() => _DealsScreenState();
}

class _DealsScreenState extends State<DealsScreen> {
  late Future<List<Deal>> _dealsFuture;

  @override
  void initState() {
    super.initState();
    _dealsFuture = _fetch();
  }

  Future<List<Deal>> _fetch() {
    final user = AppSession.currentUser;
    final apiScope = ApiScope.of(context);
    if (user?.role == 'buyer') {
      return apiScope.fetchDeals(buyerId: user?.id);
    }
    return apiScope.fetchDeals(farmerId: user?.id);
  }

  void _reload() {
    setState(() {
      _dealsFuture = _fetch();
    });
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isDesktop = width >= 768;

    return Scaffold(
      appBar: const AppTopBar(showBack: false),
      bottomNavigationBar: const AppBottomNav(activeIndex: 2),
      backgroundColor: AppColors.background,
      body: SafeArea(
        top: false,
        bottom: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(top: 32, bottom: 24),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: DealsScreen.maxContentWidth,
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: isDesktop ? 64 : 16,
                ),
                child: _DealsBody(
                  dealsFuture: _dealsFuture,
                  onRetry: _reload,
                  onDealOpened: _reload,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DealsBody extends StatelessWidget {
  const _DealsBody({
    required this.dealsFuture,
    required this.onRetry,
    required this.onDealOpened,
  });

  final Future<List<Deal>> dealsFuture;
  final VoidCallback onRetry;
  final VoidCallback onDealOpened;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const _DealsHeader(),
        const SizedBox(height: 32),
        FutureBuilder<List<Deal>>(
          future: dealsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 48),
                child: Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                ),
              );
            }
            if (snapshot.hasError) {
              return _ErrorState(
                message: 'Could not load deals',
                onRetry: onRetry,
              );
            }
            final deals = snapshot.data ?? const <Deal>[];
            if (deals.isEmpty) {
              return const _EmptyState();
            }
            return _DealsGrid(deals: deals, onDealOpened: onDealOpened);
          },
        ),
      ],
    );
  }
}

class _DealsHeader extends StatelessWidget {
  const _DealsHeader();

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isDesktop = width >= 768;

    return Row(
      children: [
        Expanded(
          child: Text(
            'Active Deals',
            style: GoogleFonts.inter(
              fontSize: isDesktop ? 32 : 24,
              height: isDesktop ? 40 / 32 : 32 / 24,
              fontWeight: FontWeight.w600,
              letterSpacing: isDesktop ? -0.01 : 0,
              color: AppColors.secondary,
            ),
          ),
        ),
        Material(
          color: AppColors.surface,
          shape: const CircleBorder(),
          elevation: 0,
          child: InkWell(
            onTap: () {},
            customBorder: const CircleBorder(),
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Icon(
                Icons.filter_list,
                color: AppColors.primary,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

enum _DealStatus { inProgress, settled, qualityCheck }

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 48),
      child: Column(
        children: [
          const Icon(
            Icons.cloud_off,
            size: 40,
            color: AppColors.onSurfaceVariant,
          ),
          const SizedBox(height: 12),
          Text(
            message,
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 16,
              height: 24 / 16,
              color: AppColors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 16),
          TextButton(
            onPressed: onRetry,
            child: Text(
              'Retry',
              style: GoogleFonts.inter(
                fontSize: 14,
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 48),
      child: Center(
        child: Text(
          'No deals yet.',
          style: GoogleFonts.inter(
            fontSize: 16,
            color: AppColors.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}

/// Fluid 3-column (lg) / 2-column (md) / 1-column (mobile) deal grid.
class _DealsGrid extends StatelessWidget {
  const _DealsGrid({required this.deals, required this.onDealOpened});

  final List<Deal> deals;
  final VoidCallback onDealOpened;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 1024
            ? 3
            : (constraints.maxWidth >= 768 ? 2 : 1);

        final rows = <Widget>[];
        for (var i = 0; i < deals.length; i += columns) {
          final slice = deals.skip(i).take(columns).toList();
          rows.add(
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (var j = 0; j < slice.length; j++) ...[
                  if (j > 0) const SizedBox(width: 24),
                  Expanded(
                    child: _DealCard(
                      deal: slice[j],
                      onDealOpened: onDealOpened,
                    ),
                  ),
                ],
              ],
            ),
          );
          if (i + columns < deals.length) {
            rows.add(const SizedBox(height: 24));
          }
        }

        return Column(children: rows);
      },
    );
  }
}

class _DealCard extends StatelessWidget {
  const _DealCard({required this.deal, required this.onDealOpened});

  final Deal deal;
  final VoidCallback onDealOpened;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () async {
          await Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => DealDetailsScreen(dealId: deal.id),
            ),
          );
          onDealOpened();
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _DealHeader(
                id: '#DC-${deal.id}',
                title: deal.productName,
                status: _statusFor(deal),
              ),
              const SizedBox(height: 16),
              _DealDetails(
                buyer: deal.buyerName,
                price: '₹${_num(deal.agreedPrice)} / ${deal.unit}',
                volume: '${_num(deal.quantity)} ${deal.unit}',
              ),
              const SizedBox(height: 16),
              _DealFinancials(
                label: 'Agreed Amount',
                amount: '₹${_num(deal.agreedPrice * deal.quantity)}',
              ),
            ],
          ),
        ),
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

_DealStatus _statusFor(Deal deal) =>
    deal.status == 'completed' ? _DealStatus.settled : _DealStatus.inProgress;

class _DealHeader extends StatelessWidget {
  const _DealHeader({
    required this.id,
    required this.title,
    required this.status,
  });

  final String id;
  final String title;
  final _DealStatus status;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Deal ID: $id',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  height: 20 / 14,
                  color: AppColors.outline,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.inter(
                  fontSize: 24,
                  height: 32 / 24,
                  fontWeight: FontWeight.w600,
                  color: AppColors.onSurface,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        _StatusBadge(status: status),
      ],
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});

  final _DealStatus status;

  @override
  Widget build(BuildContext context) {
    final (bg, fg) = switch (status) {
      _DealStatus.inProgress => (
          AppColors.secondaryContainer,
          AppColors.onSecondaryContainer
        ),
      _DealStatus.settled => (
          AppColors.surfaceContainerHigh,
          AppColors.onSurfaceVariant
        ),
      _DealStatus.qualityCheck => (
          AppColors.errorContainer,
          AppColors.onErrorContainer
        ),
    };
    final text = switch (status) {
      _DealStatus.inProgress => 'In Progress',
      _DealStatus.settled => 'Completed',
      _DealStatus.qualityCheck => 'Quality Check',
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text,
        style: GoogleFonts.inter(
          fontSize: 12,
          height: 16 / 12,
          fontWeight: FontWeight.w600,
          color: fg,
        ),
      ),
    );
  }
}

class _DealDetails extends StatelessWidget {
  const _DealDetails({
    required this.buyer,
    required this.price,
    required this.volume,
  });

  final String buyer;
  final String price;
  final String volume;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.storefront,
                size: 16,
                color: AppColors.outline,
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  'Buyer: $buyer',
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    height: 24 / 16,
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _DetailColumn(label: 'Agreed Price', value: price),
              ),
              Expanded(
                child: _DetailColumn(label: 'Volume', value: volume),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DetailColumn extends StatelessWidget {
  const _DetailColumn({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 14,
            height: 20 / 14,
            color: AppColors.outline,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: GoogleFonts.inter(
            fontSize: 16,
            height: 24 / 16,
            color: AppColors.onSurface,
          ),
        ),
      ],
    );
  }
}

class _DealFinancials extends StatelessWidget {
  const _DealFinancials({required this.label, required this.amount});

  final String label;
  final String amount;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 12),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: AppColors.surfaceVariant)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    height: 20 / 14,
                    color: AppColors.secondary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  amount,
                  style: GoogleFonts.inter(
                    fontSize: 24,
                    height: 32 / 24,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.arrow_forward_ios,
                  size: 14,
                  color: AppColors.primary,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
