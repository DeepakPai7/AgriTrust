import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../main.dart';
import '../models/models.dart';
import '../services/api_scope.dart';
import '../services/session.dart';
import '../widgets/app_bars.dart';

/// Buyer-facing "My Requests" list. Shows the requests the logged-in buyer has
/// submitted to farmers with their status and review actions. Data is fetched
/// from the backend (filtered by the current buyer). Suppresses the desktop-only
/// bottom shell per the design, but keeps the shared top bar.
class MyRequestsScreen extends StatefulWidget {
  const MyRequestsScreen({super.key});

  static const double maxContentWidth = 896; // matches Tailwind's max-w-4xl

  @override
  State<MyRequestsScreen> createState() => _MyRequestsScreenState();
}

class _MyRequestsScreenState extends State<MyRequestsScreen> {
  List<BuyerRequest>? _requests;
  Object? _error;
  bool _loading = true;

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
      final buyerId = AppSession.currentUser?.id;
      final requests = await ApiScope.of(context).fetchRequests(buyerId: buyerId);
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
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.only(top: 80, bottom: 80),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxWidth: MyRequestsScreen.maxContentWidth,
                  ),
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: isDesktop ? 64 : 16,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'My Requests',
                          style: GoogleFonts.inter(
                            fontSize: isDesktop ? 32 : 24,
                            height: isDesktop ? 40 / 32 : 32 / 24,
                            fontWeight: FontWeight.w600,
                            letterSpacing: isDesktop ? -0.01 : 0,
                            color: AppColors.onBackground,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildBody(),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            // Desktop-only language selector FAB (bottom-right).
            if (isDesktop) const Positioned(right: 24, bottom: 24, child: _LanguageFab()),
          ],
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

    final requests = _requests ?? const <BuyerRequest>[];
    if (requests.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 48),
        child: Center(
          child: Text(
            'No requests yet.',
            style: GoogleFonts.inter(
              fontSize: 16,
              color: AppColors.onSurfaceVariant,
            ),
          ),
        ),
      );
    }

    final data = requests.map(_RequestCardData.fromRequest).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var i = 0; i < data.length; i++) ...[
          if (i > 0) const SizedBox(height: 16),
          _RequestCard(data: data[i]),
        ],
      ],
    );
  }
}

enum _ReqStatus { pending, accepted, rejected }

_ReqStatus _fromStatus(String status) {
  switch (status) {
    case 'accepted':
      return _ReqStatus.accepted;
    case 'rejected':
      return _ReqStatus.rejected;
    default:
      return _ReqStatus.pending;
  }
}

class _RequestCardData {
  const _RequestCardData({
    required this.code,
    required this.name,
    required this.status,
    required this.product,
    required this.quantity,
    required this.price,
    required this.date,
  });

  /// Maps a backend [BuyerRequest] into display card data.
  factory _RequestCardData.fromRequest(BuyerRequest r) {
    final name = r.buyerName.isNotEmpty ? r.buyerName : 'Your Request';
    return _RequestCardData(
      code: 'REQ-${r.id}',
      name: name,
      status: _fromStatus(r.status),
      product: r.productName,
      quantity: '${_num(r.quantity)} ${r.unit}',
      price: '₹${_num(r.offeredPrice)}/${r.unit}',
      date: _formatDate(r.createdAt),
    );
  }

  final String code;
  final String name;
  final _ReqStatus status;
  final String product;
  final String quantity;
  final String price;
  final String date;
}

String _formatDate(String? created) {
  if (created == null || created.isEmpty) return '';
  try {
    final d = DateTime.parse(created).toLocal();
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${d.day} ${months[d.month - 1]} ${d.year}';
  } catch (_) {
    return created;
  }
}

String _num(num value) {
  if (value == value.roundToDouble()) {
    return value.toStringAsFixed(0);
  }
  return value.toString();
}

class _RequestCard extends StatelessWidget {
  const _RequestCard({required this.data});

  final _RequestCardData data;

  @override
  Widget build(BuildContext context) {
    final rejected = data.status == _ReqStatus.rejected;

    return Opacity(
      // Rejected cards are slightly dimmed per the design.
      opacity: rejected ? 0.75 : 1,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(8),
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
            _CardHeader(data: data),
            const SizedBox(height: 8),
            _InfoGrid(data: data),
            const SizedBox(height: 8),
            _CardActions(status: data.status),
          ],
        ),
      ),
    );
  }
}

class _CardHeader extends StatelessWidget {
  const _CardHeader({required this.data});

  final _RequestCardData data;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(bottom: 8),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppColors.outlineVariant),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data.code,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    height: 16 / 12,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.6,
                    color: AppColors.outline,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  data.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(
                    fontSize: 24,
                    height: 32 / 24,
                    fontWeight: FontWeight.w600,
                    color: AppColors.secondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          _StatusPill(status: data.status),
        ],
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.status});

  final _ReqStatus status;

  @override
  Widget build(BuildContext context) {
    final (bg, fg, text) = switch (status) {
      _ReqStatus.pending => (
          AppColors.surfaceContainerHigh,
          AppColors.onSurfaceVariant,
          'Pending'
        ),
      _ReqStatus.accepted => (
          AppColors.primaryContainer,
          AppColors.onPrimaryContainer,
          'Accepted'
        ),
      _ReqStatus.rejected => (
          AppColors.errorContainer,
          AppColors.onErrorContainer,
          'Rejected'
        ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(4),
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

/// Two-column info grid (Product, Quantity, Offered Price, Date).
class _InfoGrid extends StatelessWidget {
  const _InfoGrid({required this.data});

  final _RequestCardData data;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final twoUp = constraints.maxWidth >= 420;
        final items = <_InfoItem>[
          _InfoItem(label: 'Product', value: data.product),
          _InfoItem(label: 'Quantity', value: data.quantity),
          _InfoItem(label: 'Offered Price', value: data.price),
          _InfoItem(label: 'Date', value: data.date),
        ];

        if (!twoUp) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (var i = 0; i < items.length; i++) ...[
                if (i > 0) const SizedBox(height: 8),
                items[i],
              ],
            ],
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [items[0], const SizedBox(height: 8), items[2]],
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [items[1], const SizedBox(height: 8), items[3]],
              ),
            ),
          ],
        );
      },
    );
  }
}

class _InfoItem extends StatelessWidget {
  const _InfoItem({required this.label, required this.value});

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
            fontWeight: FontWeight.w500,
            color: AppColors.outline,
          ),
        ),
        const SizedBox(height: 2),
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

class _CardActions extends StatelessWidget {
  const _CardActions({required this.status});

  final _ReqStatus status;

  @override
  Widget build(BuildContext context) {
    if (status == _ReqStatus.pending) {
      return Align(
        alignment: Alignment.centerRight,
        child: Wrap(
          spacing: 8,
          runSpacing: 8,
          alignment: WrapAlignment.end,
          children: [
            _ActionButton.outline(label: 'Cancel Request', onTap: () {}),
            _ActionButton.filled(label: 'View Details', onTap: () {}),
          ],
        ),
      );
    }

    if (status == _ReqStatus.accepted) {
      return Align(
        alignment: Alignment.centerRight,
        child: _ActionButton.neutral(label: 'View Details', onTap: () {}),
      );
    }

    return Align(
      alignment: Alignment.centerRight,
      child: _ActionButton.outline(label: 'View Details', onTap: () {}),
    );
  }
}

/// Compact action buttons that adapt to the card width.
class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.label,
    required this.bg,
    required this.fg,
    required this.border,
    required this.onTap,
  });

  final String label;
  final Color bg;
  final Color fg;
  final bool border;
  final VoidCallback onTap;

  const _ActionButton.outline({required String label, required VoidCallback onTap})
      : this(
          label: label,
          bg: AppColors.surfaceContainerLowest,
          fg: AppColors.onSurface,
          border: true,
          onTap: onTap,
        );

  const _ActionButton.filled({required String label, required VoidCallback onTap})
      : this(
          label: label,
          bg: AppColors.primary,
          fg: AppColors.onPrimary,
          border: false,
          onTap: onTap,
        );

  const _ActionButton.neutral({required String label, required VoidCallback onTap})
      : this(
          label: label,
          bg: AppColors.surfaceContainerHigh,
          fg: AppColors.onSurfaceVariant,
          border: false,
          onTap: onTap,
        );

  @override
  Widget build(BuildContext context) {
    return Material(
      color: bg,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4),
        side: border ? const BorderSide(color: AppColors.outline) : BorderSide.none,
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(4),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 14,
              height: 20 / 14,
              fontWeight: FontWeight.w500,
              color: fg,
            ),
          ),
        ),
      ),
    );
  }
}

/// Desktop-only floating language selector button.
class _LanguageFab extends StatelessWidget {
  const _LanguageFab();

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 6,
      shape: const CircleBorder(),
      color: AppColors.surfaceContainerHigh,
      child: InkWell(
        onTap: () {},
        customBorder: const CircleBorder(),
        child: const Padding(
          padding: EdgeInsets.all(16),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.language, color: AppColors.onSurface),
              SizedBox(width: 8),
              Text(
                'ಕನ್ನಡ',
                style: TextStyle(
                  fontSize: 14,
                  height: 20 / 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.onSurface,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
