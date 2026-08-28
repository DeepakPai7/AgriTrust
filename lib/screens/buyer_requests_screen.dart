import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../main.dart';
import '../widgets/app_bars.dart';

/// "Farmer Buyer Requests" screen. Lists incoming offers from verified buyers
/// in a responsive bento grid with accept/reject actions and a status filter.
class BuyerRequestsScreen extends StatefulWidget {
  const BuyerRequestsScreen({super.key});

  static const double maxContentWidth = 896;

  @override
  State<BuyerRequestsScreen> createState() => _BuyerRequestsScreenState();
}

class _BuyerRequestsScreenState extends State<BuyerRequestsScreen> {
  _RequestStatus? _filter = _RequestStatus.pending;
  final List<_RequestData> _requests = _initialRequests();

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
              constraints: const BoxConstraints(
                maxWidth: BuyerRequestsScreen.maxContentWidth,
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: isDesktop ? 64 : 16,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _Header(
                      filter: _filter,
                      onFilterChanged: (f) => setState(() => _filter = f),
                    ),
                    const SizedBox(height: 32),
                    _RequestsGrid(
                      requests: _filtered(),
                      onStatusChanged: (id, status) => setState(() {
                        final i = _requests.indexWhere((r) => r.id == id);
                        if (i >= 0) {
                          _requests[i] = _requests[i].copyWith(status: status);
                        }
                      }),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<_RequestData> _filtered() {
    if (_filter == null) return _requests;
    return _requests.where((r) => r.status == _filter).toList();
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.filter, required this.onFilterChanged});

  final _RequestStatus? filter;
  final ValueChanged<_RequestStatus?> onFilterChanged;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isDesktop = width >= 768;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Buyer Requests',
                    style: GoogleFonts.inter(
                      fontSize: isDesktop ? 32 : 24,
                      height: isDesktop ? 40 / 32 : 32 / 24,
                      fontWeight: FontWeight.w600,
                      letterSpacing: isDesktop ? -0.01 : 0,
                      color: AppColors.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Manage incoming offers from verified buyers.',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      height: 24 / 16,
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            _StatusFilter(
              filter: filter,
              onChanged: onFilterChanged,
            ),
          ],
        ),
        const SizedBox(height: 24),
        const Divider(
          height: 1,
          thickness: 1,
          color: AppColors.outlineVariant,
        ),
      ],
    );
  }
}

class _StatusFilter extends StatelessWidget {
  const _StatusFilter({required this.filter, required this.onChanged});

  final _RequestStatus? filter;
  final ValueChanged<_RequestStatus?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.outlineVariant),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          DropdownButtonHideUnderline(
            child: DropdownButton<_RequestStatus?>(
              value: filter,
              isDense: true,
              borderRadius: BorderRadius.circular(8),
              icon: const Icon(
                Icons.expand_more,
                color: AppColors.onSurfaceVariant,
              ),
              style: GoogleFonts.inter(
                fontSize: 16,
                height: 24 / 16,
                color: AppColors.onSurface,
              ),
              items: const [
                DropdownMenuItem<_RequestStatus?>(
                  value: null,
                  child: Text('All Statuses'),
                ),
                DropdownMenuItem<_RequestStatus?>(
                  value: _RequestStatus.pending,
                  child: Text('Pending'),
                ),
                DropdownMenuItem<_RequestStatus?>(
                  value: _RequestStatus.accepted,
                  child: Text('Accepted'),
                ),
                DropdownMenuItem<_RequestStatus?>(
                  value: _RequestStatus.rejected,
                  child: Text('Rejected'),
                ),
              ],
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }
}

class _RequestsGrid extends StatelessWidget {
  const _RequestsGrid({
    required this.requests,
    required this.onStatusChanged,
  });

  final List<_RequestData> requests;
  final void Function(String id, _RequestStatus status) onStatusChanged;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 1024
            ? 3
            : (constraints.maxWidth >= 768 ? 2 : 1);

        final rows = <Widget>[];
        for (var i = 0; i < requests.length; i += columns) {
          final slice = requests.skip(i).take(columns).toList();
          rows.add(
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (var j = 0; j < slice.length; j++) ...[
                  if (j > 0) const SizedBox(width: 16),
                  Expanded(child: _RequestCard(
                    request: slice[j],
                    onStatusChanged: onStatusChanged,
                  )),
                ],
              ],
            ),
          );
          if (i + columns < requests.length) {
            rows.add(const SizedBox(height: 16));
          }
        }
        return Column(children: rows);
      },
    );
  }
}

enum _RequestStatus { pending, accepted, rejected }

class _RequestData {
  const _RequestData({
    required this.id,
    required this.initials,
    required this.buyer,
    required this.date,
    required this.product,
    required this.quantity,
    required this.price,
    this.status = _RequestStatus.pending,
  });

  final String id;
  final String initials;
  final String buyer;
  final String date;
  final String product;
  final String quantity;
  final String price;
  final _RequestStatus status;

  _RequestData copyWith({_RequestStatus? status}) {
    return _RequestData(
      id: id,
      initials: initials,
      buyer: buyer,
      date: date,
      product: product,
      quantity: quantity,
      price: price,
      status: status ?? this.status,
    );
  }
}

List<_RequestData> _initialRequests() => const [
      _RequestData(
        id: 'rc1',
        initials: 'A',
        buyer: 'AgriCorp India',
        date: 'Oct 24, 2023',
        product: 'Premium Wheat',
        quantity: '50 Quintals',
        price: '₹2,200 / Qtl',
      ),
      _RequestData(
        id: 'rc2',
        initials: 'G',
        buyer: 'Green Valley Mills',
        date: 'Oct 23, 2023',
        product: 'Organic Rice',
        quantity: '200 Quintals',
        price: '₹3,150 / Qtl',
      ),
      _RequestData(
        id: 'rc3',
        initials: 'S',
        buyer: 'Sunfresh Produce',
        date: 'Oct 22, 2023',
        product: 'Soybeans',
        quantity: '120 Quintals',
        price: '₹4,800 / Qtl',
      ),
    ];

class _RequestCard extends StatelessWidget {
  const _RequestCard({
    required this.request,
    required this.onStatusChanged,
  });

  final _RequestData request;
  final void Function(String id, _RequestStatus status) onStatusChanged;

  @override
  Widget build(BuildContext context) {
    final status = request.status;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.surfaceContainer),
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
          _RequestHeader(request: request),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(color: AppColors.surfaceContainer),
              ),
            ),
            child: _RequestRow(label: 'Product', value: request.product),
          ),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(color: AppColors.surfaceContainer),
              ),
            ),
            child: _RequestRow(label: 'Quantity', value: request.quantity),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: _RequestRow(
              label: 'Offered Price',
              value: request.price,
              valueColor: AppColors.primary,
              valueBold: true,
            ),
          ),
          const SizedBox(height: 8),
          if (status == _RequestStatus.pending)
            Row(
              children: [
                Expanded(
                  child: _ActionButton(
                    label: 'Reject',
                    icon: Icons.close,
                    backgroundColor: AppColors.errorContainer,
                    foregroundColor: AppColors.onErrorContainer,
                    onTap: () => onStatusChanged(request.id, _RequestStatus.rejected),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _ActionButton(
                    label: 'Accept',
                    icon: Icons.check,
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.onPrimary,
                    onTap: () => onStatusChanged(request.id, _RequestStatus.accepted),
                  ),
                ),
              ],
            ),
          const SizedBox(height: 8),
          OutlinedButton(
            onPressed: () {},
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primary,
              side: const BorderSide(color: AppColors.primaryContainer),
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              'View Details',
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RequestHeader extends StatelessWidget {
  const _RequestHeader({required this.request});

  final _RequestData request;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: const BoxDecoration(
            color: AppColors.surfaceContainerHigh,
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: Text(
            request.initials,
            style: GoogleFonts.inter(
              fontSize: 24,
              height: 1.1,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                request.buyer,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.inter(
                  fontSize: 18,
                  height: 28 / 18,
                  color: AppColors.onSurface,
                ),
              ),
              Text(
                request.date,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  height: 20 / 14,
                  color: AppColors.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        _StatusPill(status: request.status),
      ],
    );
  }
}

class _RequestRow extends StatelessWidget {
  const _RequestRow({
    required this.label,
    required this.value,
    this.valueColor = AppColors.onSurface,
    this.valueBold = false,
  });

  final String label;
  final String value;
  final Color valueColor;
  final bool valueBold;

  @override
  Widget build(BuildContext context) {
    return Row(
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
        const SizedBox(width: 8),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.right,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.inter(
              fontSize: 16,
              height: 24 / 16,
              color: valueColor,
              fontWeight: valueBold ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.label,
    required this.icon,
    required this.backgroundColor,
    required this.foregroundColor,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final Color backgroundColor;
  final Color foregroundColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: backgroundColor,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 18, color: foregroundColor),
              const SizedBox(width: 4),
              Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: foregroundColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.status});

  final _RequestStatus status;

  @override
  Widget build(BuildContext context) {
    final (bg, fg, text) = switch (status) {
      _RequestStatus.accepted => (
          AppColors.primaryFixed,
          AppColors.primaryContainer,
          'Accepted'
        ),
      _RequestStatus.rejected => (
          AppColors.errorContainer,
          AppColors.onErrorContainer,
          'Rejected'
        ),
      _RequestStatus.pending => (
          AppColors.secondaryFixed,
          const Color(0xFF351000),
          'Pending'
        ),
    };

    return Align(
      alignment: Alignment.center,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
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
      ),
    );
  }
}
