import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../main.dart';

/// "Payment Successful" confirmation screen shown to the buyer after settling
/// a deal. Reuses the checkmark success-badge styling from the review flow but
/// shows the payment summary and a single "Done" action (no rating form).
class PaymentSuccessScreen extends StatelessWidget {
  const PaymentSuccessScreen({
    super.key,
    required this.dealId,
    required this.productName,
    required this.quantity,
    required this.unit,
    required this.amount,
  });

  final String dealId;
  final String productName;
  final double quantity;
  final String unit;
  final double amount;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isDesktop = width >= 768;

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: _TopBar(),
      body: SafeArea(
        top: false,
        bottom: false,
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: isDesktop ? 64 : 16,
            vertical: 32,
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: _SuccessCard(
                dealId: dealId,
                productName: productName,
                quantity: quantity,
                unit: unit,
                amount: amount,
                isDesktop: isDesktop,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Top bar with a close button (back to Deals).
class _TopBar extends StatelessWidget implements PreferredSizeWidget {
  @override
  Size get preferredSize => const Size.fromHeight(64);

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isDesktop = width >= 768;

    return AppBar(
      backgroundColor: AppColors.surface,
      elevation: 0,
      toolbarHeight: 64,
      automaticallyImplyLeading: false,
      titleSpacing: 0,
      title: Padding(
        padding: EdgeInsets.symmetric(horizontal: isDesktop ? 64 : 16),
        child: Row(
          children: [
            const Icon(
              Icons.agriculture,
              color: AppColors.primary,
              size: 26,
            ),
            const SizedBox(width: 8),
            Text(
              'agritrust',
              style: GoogleFonts.inter(
                fontSize: 24,
                height: 32 / 24,
                letterSpacing: -0.01,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
            const Spacer(),
            IconButton(
              tooltip: 'Close',
              onPressed: () => Navigator.of(context).maybePop(),
              icon: const Icon(
                Icons.close,
                color: AppColors.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SuccessCard extends StatelessWidget {
  const _SuccessCard({
    required this.dealId,
    required this.productName,
    required this.quantity,
    required this.unit,
    required this.amount,
    required this.isDesktop,
  });

  final String dealId;
  final String productName;
  final double quantity;
  final String unit;
  final double amount;
  final bool isDesktop;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const _SuccessHeader(),
        const SizedBox(height: 32),
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(12),
            boxShadow: const [
              BoxShadow(
                color: Color(0x1A000000),
                blurRadius: 15,
                offset: Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _SummaryRow(label: 'Deal ID', value: dealId),
              const SizedBox(height: 12),
              _SummaryRow(label: 'Product', value: productName),
              const SizedBox(height: 12),
              _SummaryRow(
                label: 'Quantity',
                value: '${_num(quantity)} $unit',
              ),
              const SizedBox(height: 12),
              _SummaryRow(label: 'Amount Paid', value: '₹${_num(amount)}'),
              const SizedBox(height: 24),
              _DoneButton(isDesktop: isDesktop),
            ],
          ),
        ),
      ],
    );
  }
}

class _SuccessHeader extends StatelessWidget {
  const _SuccessHeader();

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        _SuccessBadge(),
        SizedBox(height: 8),
        Text(
          'Transaction Settled',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 32,
            height: 40 / 32,
            letterSpacing: -0.01,
            fontWeight: FontWeight.w600,
            color: AppColors.onSurface,
          ),
        ),
        SizedBox(height: 4),
        Text(
          'Your payment was successful.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 18,
            height: 28 / 18,
            color: AppColors.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class _SuccessBadge extends StatelessWidget {
  const _SuccessBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 64,
      height: 64,
      decoration: const BoxDecoration(
        color: AppColors.primaryContainer,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(color: Color(0x1A000000), blurRadius: 15, offset: Offset(0, 10)),
        ],
      ),
      child: const Icon(
        Icons.check_circle,
        size: 32,
        color: AppColors.primary,
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 14,
                height: 20 / 14,
                color: AppColors.onSurfaceVariant,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.inter(
                fontSize: 16,
                height: 24 / 16,
                fontWeight: FontWeight.w600,
                color: AppColors.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DoneButton extends StatelessWidget {
  const _DoneButton({required this.isDesktop});

  final bool isDesktop;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.primary,
      borderRadius: BorderRadius.circular(8),
      elevation: 2,
      shadowColor: const Color(0xFF000000),
      child: InkWell(
        onTap: () => Navigator.of(context).maybePop(),
        borderRadius: BorderRadius.circular(8),
        child: SizedBox(
          height: 56,
          width: isDesktop ? null : double.infinity,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Done',
                  style: TextStyle(
                    fontSize: 14,
                    height: 20 / 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.onPrimary,
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.check, size: 18, color: AppColors.onPrimary),
              ],
            ),
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
