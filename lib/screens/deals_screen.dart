import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../main.dart';
import '../widgets/app_bars.dart';
import 'deal_details_screen.dart';

/// "My Deals" screen. Uses the shared top bar and bottom navigation so the
/// chrome is identical everywhere; only the body content differs.
class DealsScreen extends StatelessWidget {
  const DealsScreen({super.key});

  static const double maxContentWidth = 1280;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isDesktop = width >= 768;

    return Scaffold(
      appBar: const AppTopBar(),
      bottomNavigationBar: const AppBottomNav(activeIndex: 2),
      backgroundColor: AppColors.background,
      body: SafeArea(
        top: false,
        bottom: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(top: 32, bottom: 24),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: maxContentWidth),
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: isDesktop ? 64 : 16,
                ),
                child: const _DealsBody(),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DealsBody extends StatelessWidget {
  const _DealsBody();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: const [
        _DealsHeader(),
        SizedBox(height: 32),
        _DealsGrid(),
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

/// Fluid 3-column (lg) / 2-column (md) / 1-column (mobile) deal grid.
class _DealsGrid extends StatelessWidget {
  const _DealsGrid();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 1024 ? 3 : (constraints.maxWidth >= 768 ? 2 : 1);
        const cards = <_DealCard>[
          _DealCard(
            id: '#DC-8492',
            title: 'Premium Wheat',
            status: _DealStatus.inProgress,
            buyer: 'AgriCorp India',
            price: '₹2,400 / Qtl',
            volume: '50 Qtl',
            netAmountLabel: 'Net Amount',
            netAmount: '₹1,20,000',
            financial: _FinancialStatus.pending,
          ),
          _DealCard(
            id: '#DC-8104',
            title: 'Organic Soybeans',
            status: _DealStatus.settled,
            buyer: 'Green Valley Mills',
            price: '₹4,800 / Qtl',
            volume: '20 Qtl',
            netAmountLabel: 'Net Amount',
            netAmount: '₹96,000',
            financial: _FinancialStatus.paid,
          ),
          _DealCard(
            id: '#DC-8555',
            title: 'Sorghum (Jowar)',
            status: _DealStatus.qualityCheck,
            buyer: 'National Grain Co.',
            price: '₹2,100 / Qtl',
            volume: '100 Qtl',
            netAmountLabel: 'Est. Net Amount',
            netAmount: '₹2,10,000',
            financial: _FinancialStatus.review,
          ),
        ];

        // Build rows of `columns` cards each.
        final rows = <Widget>[];
        for (var i = 0; i < cards.length; i += columns) {
          final slice = cards.skip(i).take(columns).toList();
          rows.add(
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (var j = 0; j < slice.length; j++) ...[
                  if (j > 0) const SizedBox(width: 24),
                  Expanded(child: slice[j]),
                ],
              ],
            ),
          );
          if (i + columns < cards.length) {
            rows.add(const SizedBox(height: 24));
          }
        }

        return Column(children: rows);
      },
    );
  }
}

enum _DealStatus { inProgress, settled, qualityCheck }

enum _FinancialStatus { pending, paid, review }

class _DealCard extends StatelessWidget {
  const _DealCard({
    required this.id,
    required this.title,
    required this.status,
    required this.buyer,
    required this.price,
    required this.volume,
    required this.netAmountLabel,
    required this.netAmount,
    required this.financial,
  });

  final String id;
  final String title;
  final _DealStatus status;
  final String buyer;
  final String price;
  final String volume;
  final String netAmountLabel;
  final String netAmount;
  final _FinancialStatus financial;

  @override
  Widget build(BuildContext context) {
    final ringColor = status == _DealStatus.qualityCheck
        ? AppColors.errorContainer
        : Colors.transparent;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute<void>(builder: (_) => const DealDetailsScreen()),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: ringColor),
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
              _DealHeader(id: id, title: title, status: status),
              const SizedBox(height: 16),
              _DealDetails(
                buyer: buyer,
                price: price,
                volume: volume,
              ),
              const SizedBox(height: 16),
              _DealFinancials(
                label: netAmountLabel,
                amount: netAmount,
                financial: financial,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

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
      _DealStatus.inProgress => (AppColors.secondaryContainer, AppColors.onSecondaryContainer),
      _DealStatus.settled => (AppColors.surfaceContainerHigh, AppColors.onSurfaceVariant),
      _DealStatus.qualityCheck => (AppColors.errorContainer, AppColors.onErrorContainer),
    };
    final text = switch (status) {
      _DealStatus.inProgress => 'In Progress',
      _DealStatus.settled => 'Settled',
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
  const _DealFinancials({
    required this.label,
    required this.amount,
    required this.financial,
  });

  final String label;
  final String amount;
  final _FinancialStatus financial;

  @override
  Widget build(BuildContext context) {
    final dividerColor = financial == _FinancialStatus.review
        ? AppColors.errorContainer
        : AppColors.surfaceVariant;

    return Container(
      padding: const EdgeInsets.only(top: 12),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: dividerColor)),
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
                    color: financial == _FinancialStatus.review
                        ? AppColors.onSurface
                        : AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          if (financial != _FinancialStatus.review)
            _PaymentBadge(financial: financial)
          else
            _ReviewButton(),
        ],
      ),
    );
  }
}

class _PaymentBadge extends StatelessWidget {
  const _PaymentBadge({required this.financial});

  final _FinancialStatus financial;

  @override
  Widget build(BuildContext context) {
    final paid = financial == _FinancialStatus.paid;
    final (bg, fg, icon, text) = paid
        ? (AppColors.primaryFixed, AppColors.primaryContainer, Icons.check_circle, 'Paid in Full')
        : (Colors.transparent, AppColors.onSurfaceVariant, Icons.pending, 'Payment Pending');

    return Container(
      padding: paid
          ? const EdgeInsets.symmetric(horizontal: 8, vertical: 2)
          : EdgeInsets.zero,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: fg,
          ),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              text,
              style: GoogleFonts.inter(
                fontSize: 12,
                height: 16 / 12,
                fontWeight: FontWeight.w600,
                color: fg,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ReviewButton extends StatelessWidget {
  const _ReviewButton();

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surfaceContainerHigh,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: () {},
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Review',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  height: 20 / 14,
                  color: AppColors.onSurfaceVariant,
                ),
              ),
              const SizedBox(width: 4),
              const Icon(
                Icons.arrow_forward,
                size: 16,
                color: AppColors.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
