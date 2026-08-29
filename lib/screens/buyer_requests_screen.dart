import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../main.dart';
import '../models/models.dart';
import '../services/api_scope.dart';
import '../widgets/app_bars.dart';

/// "Farmer Buyer Requests" screen. Lists incoming offers from verified buyers
/// in a responsive bento grid with accept/reject actions and a status filter.
class BuyerRequestsScreen extends StatefulWidget {
  const BuyerRequestsScreen({super.key, this.farmerId});

  static const double maxContentWidth = 896;

  /// When set, only requests for this farmer's products are shown.
  final int? farmerId;

  @override
  State<BuyerRequestsScreen> createState() => _BuyerRequestsScreenState();
}

class _BuyerRequestsScreenState extends State<BuyerRequestsScreen> {
  _Status? _filter;
  List<BuyerRequest>? _requests;
  Object? _error;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _filter = _Status.pending;
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final requests = await ApiScope.of(context).fetchRequests(
        farmerId: widget.farmerId,
      );
      if (mounted) {
        setState(() {
          _requests = requests;
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

  Future<void> _setStatus(BuyerRequest request, String status) async {
    try {
      final apiScope = ApiScope.of(context);
      await apiScope.updateRequestStatus(request.id, status);
      if (status == 'accepted') {
        await apiScope.createDeal(requestId: request.id);
      }
      await _load();
    } catch (_) {
      // Keep the current list if the update fails.
    }
  }

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
                    _buildBody(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 48),
        child: Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );
    }
    if (_error != null) {
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
              'Could not load requests',
              style: GoogleFonts.inter(
                fontSize: 16,
                color: AppColors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: _load,
              child: Text(
                'Retry',
                style: GoogleFonts.inter(color: AppColors.primary),
              ),
            ),
          ],
        ),
      );
    }

    final requests = _filtered() ?? const <BuyerRequest>[];
    if (requests.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 48),
        child: Center(
          child: Text(
            'No requests found.',
            style: GoogleFonts.inter(
              fontSize: 16,
              color: AppColors.onSurfaceVariant,
            ),
          ),
        ),
      );
    }
    return _RequestsGrid(
      requests: requests,
      onStatusChanged: _setStatus,
    );
  }

  List<BuyerRequest>? _filtered() {
    final all = _requests;
    if (all == null) return null;
    if (_filter == null) return all;
    return all.where((r) => _fromStatus(r.status) == _filter).toList();
  }
}

enum _Status { pending, accepted, rejected }

_Status _fromStatus(String status) {
  switch (status) {
    case 'accepted':
      return _Status.accepted;
    case 'rejected':
      return _Status.rejected;
    default:
      return _Status.pending;
  }
}

String _toStatus(_Status status) => switch (status) {
      _Status.pending => 'pending',
      _Status.accepted => 'accepted',
      _Status.rejected => 'rejected',
    };

class _Header extends StatelessWidget {
  const _Header({required this.filter, required this.onFilterChanged});

  final _Status? filter;
  final ValueChanged<_Status?> onFilterChanged;

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

  final _Status? filter;
  final ValueChanged<_Status?> onChanged;

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
            child: DropdownButton<_Status?>(
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
                DropdownMenuItem<_Status?>(
                  value: null,
                  child: Text('All Statuses'),
                ),
                DropdownMenuItem<_Status?>(
                  value: _Status.pending,
                  child: Text('Pending'),
                ),
                DropdownMenuItem<_Status?>(
                  value: _Status.accepted,
                  child: Text('Accepted'),
                ),
                DropdownMenuItem<_Status?>(
                  value: _Status.rejected,
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

  final List<BuyerRequest> requests;
  final void Function(BuyerRequest request, String status) onStatusChanged;

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
                  Expanded(
                    child: _RequestCard(
                      request: slice[j],
                      onStatusChanged: onStatusChanged,
                    ),
                  ),
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

class _RequestCard extends StatelessWidget {
  const _RequestCard({
    required this.request,
    required this.onStatusChanged,
  });

  final BuyerRequest request;
  final void Function(BuyerRequest request, String status) onStatusChanged;

  @override
  Widget build(BuildContext context) {
    final status = _fromStatus(request.status);

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
            child:
                _RequestRow(label: 'Product', value: request.productName),
          ),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(color: AppColors.surfaceContainer),
              ),
            ),
            child: _RequestRow(
              label: 'Quantity',
              value: '${_num(request.quantity)} ${request.unit}',
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: _RequestRow(
              label: 'Offered Price',
              value: '₹${_num(request.offeredPrice)} / ${request.unit}',
              valueColor: AppColors.primary,
              valueBold: true,
            ),
          ),
          const SizedBox(height: 8),
          if (status == _Status.pending)
            Row(
              children: [
                Expanded(
                  child: _ActionButton(
                    label: 'Reject',
                    icon: Icons.close,
                    backgroundColor: AppColors.errorContainer,
                    foregroundColor: AppColors.onErrorContainer,
                    onTap: () =>
                        onStatusChanged(request, _toStatus(_Status.rejected)),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _ActionButton(
                    label: 'Accept',
                    icon: Icons.check,
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.onPrimary,
                    onTap: () =>
                        onStatusChanged(request, _toStatus(_Status.accepted)),
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

  final BuyerRequest request;

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
            _initials(request.buyerName),
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
                request.buyerName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.inter(
                  fontSize: 18,
                  height: 28 / 18,
                  color: AppColors.onSurface,
                ),
              ),
              Text(
                _formatDate(request.createdAt),
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
        _StatusPill(status: _fromStatus(request.status)),
      ],
    );
  }
}

String _initials(String name) {
  final words = name.trim().split(RegExp(r'\s+'));
  if (words.isEmpty) return '?';
  return words[0].substring(0, 1).toUpperCase();
}

String _formatDate(String? created) {
  if (created == null || created.isEmpty) return '';
  try {
    final parts = DateTime.parse(created).toLocal();
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${months[parts.month - 1]} ${parts.day}, ${parts.year}';
  } catch (_) {
    return created;
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

  final _Status status;

  @override
  Widget build(BuildContext context) {
    final (bg, fg, text) = switch (status) {
      _Status.accepted => (
          AppColors.primaryFixed,
          AppColors.primaryContainer,
          'Accepted'
        ),
      _Status.rejected => (
          AppColors.errorContainer,
          AppColors.onErrorContainer,
          'Rejected'
        ),
      _Status.pending => (
          AppColors.secondaryFixed,
          const Color(0xFF351000),
          'Pending'
        ),
    };

    return Align(
      alignment: Alignment.centerRight,
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

String _num(num value) {
  if (value == value.roundToDouble()) {
    return value.toStringAsFixed(0);
  }
  return value.toString();
}
