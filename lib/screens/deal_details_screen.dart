import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../main.dart';
import '../widgets/app_bars.dart';

/// Task-focused "Deal Details" view. Uses the shared top bar but suppresses
/// the bottom navigation shell so the canvas takes priority for settlement.
class DealDetailsScreen extends StatelessWidget {
  const DealDetailsScreen({super.key});

  static const double maxContentWidth = 896; // matches Tailwind's max-w-4xl

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
          padding: const EdgeInsets.fromLTRB(0, 32, 0, 24),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: maxContentWidth),
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: isDesktop ? 64 : 16,
                ),
                child: const _DetailsBody(),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DetailsBody extends StatelessWidget {
  const _DetailsBody();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _BackBar(),
        SizedBox(height: 16),
        _DealHeader(),
        SizedBox(height: 24),
        _Timeline(),
        SizedBox(height: 24),
        _ParticipantsProductGrid(),
        SizedBox(height: 24),
        _FinancialCard(),
        SizedBox(height: 24),
        _ActionCard(),
      ],
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
                size: 18,
                color: AppColors.primary,
              ),
              const SizedBox(width: 4),
              Text(
                'Back to Deals',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  height: 20 / 14,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DealHeader extends StatelessWidget {
  const _DealHeader();

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isDesktop = width >= 768;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Deal #DC-8492-KT',
                style: GoogleFonts.inter(
                  fontSize: isDesktop ? 24 : 24,
                  height: 32 / 24,
                  fontWeight: FontWeight.w600,
                  color: AppColors.onSurface,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Initiated on 12 Oct 2023',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  height: 24 / 16,
                  color: AppColors.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        _SettlementBadge(),
      ],
    );
  }
}

class _SettlementBadge extends StatelessWidget {
  const _SettlementBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.secondaryContainer,
        borderRadius: BorderRadius.circular(999),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D059669),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        'Pending Settlement',
        style: GoogleFonts.inter(
          fontSize: 12,
          height: 16 / 12,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.6,
          color: AppColors.onSecondaryContainer,
        ),
      ),
    );
  }
}

class _Timeline extends StatelessWidget {
  const _Timeline();

  static const _segments = <_TimelineSegment>[
    _TimelineSegment(label: 'Agreed', color: AppColors.primary, emphasized: false),
    _TimelineSegment(label: 'Inspected', color: AppColors.primary, emphasized: false),
    _TimelineSegment(label: 'Settlement', color: AppColors.primaryContainer, emphasized: true),
    _TimelineSegment(label: 'Closed', color: AppColors.surfaceVariant, emphasized: false),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: SizedBox(
            height: 8,
            child: Row(
              children: [
                for (var i = 0; i < _segments.length; i++) ...[
                  if (i > 0)
                    Container(
                      width: 1,
                      color: AppColors.surface,
                    ),
                  Expanded(
                    child: Container(
                      color: _segments[i].color,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
        const SizedBox(height: 4),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Row(
            children: [
              for (var i = 0; i < _segments.length; i++) ...[
                if (i > 0) const SizedBox(width: 1),
                Expanded(
                  child: Text(
                    _segments[i].label,
                    textAlign: i == _segments.length - 1
                        ? TextAlign.end
                        : (i == 0 ? TextAlign.start : TextAlign.center),
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      height: 16 / 12,
                      fontWeight: _segments[i].emphasized
                          ? FontWeight.w600
                          : FontWeight.w400,
                      color: _segments[i].emphasized
                          ? AppColors.primary
                          : AppColors.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _TimelineSegment {
  const _TimelineSegment({
    required this.label,
    required this.color,
    required this.emphasized,
  });

  final String label;
  final Color color;
  final bool emphasized;
}

class _ParticipantsProductGrid extends StatelessWidget {
  const _ParticipantsProductGrid();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final sideBySide = constraints.maxWidth >= 768;
        final participants = const _InfoCard(
          title: 'Participants',
          child: _Participants(),
        );
        final product = const _InfoCard(
          title: 'Produce Details',
          child: _ProduceDetails(),
        );

        if (sideBySide) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: participants),
              const SizedBox(width: 16),
              Expanded(child: product),
            ],
          );
        }
        return Column(
          children: [
            participants,
            const SizedBox(height: 16),
            product,
          ],
        );
      },
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0x4DBCCAC0)),
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
          Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 14,
              height: 20 / 14,
              letterSpacing: 0.4,
              color: AppColors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}

class _Participants extends StatelessWidget {
  const _Participants();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _ParticipantRow(
          initials: 'RM',
          name: 'Ramesh Gowda',
          role: 'Farmer (Seller)',
          avatarColor: AppColors.primaryContainer,
          avatarTextColor: AppColors.onPrimaryContainer,
        ),
        Divider(height: 8, color: AppColors.outlineVariant),
        SizedBox(height: 8),
        _ParticipantRow(
          initials: 'AF',
          name: 'AgriFoods Ltd.',
          role: 'Institutional Buyer',
          avatarColor: AppColors.tertiaryContainer,
          avatarTextColor: AppColors.onTertiaryContainer,
        ),
      ],
    );
  }
}

class _ParticipantRow extends StatelessWidget {
  const _ParticipantRow({
    required this.initials,
    required this.name,
    required this.role,
    required this.avatarColor,
    required this.avatarTextColor,
  });

  final String initials;
  final String name;
  final String role;
  final Color avatarColor;
  final Color avatarTextColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: avatarColor,
            shape: BoxShape.circle,
          ),
          child: Text(
            initials,
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w700,
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
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.inter(
                  fontSize: 16,
                  height: 24 / 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.onSurface,
                ),
              ),
              Text(
                role,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  height: 20 / 14,
                  color: AppColors.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ProduceDetails extends StatelessWidget {
  const _ProduceDetails();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.surfaceBright,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.spa,
                size: 20,
                color: AppColors.secondary,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Premium Toor Dal',
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    height: 24 / 16,
                    fontWeight: FontWeight.w500,
                    color: AppColors.onSurface,
                  ),
                ),
              ),
              Text(
                'Grade A',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  height: 24 / 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.onSurface,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            const Expanded(
              child: _ProduceStat(label: 'Quantity', value: '50 Quintals'),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _ProduceStat(label: 'Agreed Rate', value: '₹6,800/Q'),
            ),
          ],
        ),
      ],
    );
  }
}

class _ProduceStat extends StatelessWidget {
  const _ProduceStat({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceBright,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 14,
              height: 20 / 14,
              color: AppColors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 18,
              height: 28 / 18,
              fontWeight: FontWeight.w600,
              color: AppColors.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}

class _FinancialCard extends StatelessWidget {
  const _FinancialCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0x4DBCCAC0)),
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
          Text(
            'Financial Settlement',
            style: GoogleFonts.inter(
              fontSize: 24,
              height: 32 / 24,
              fontWeight: FontWeight.w600,
              color: AppColors.onSurface,
            ),
          ),
          const Divider(height: 24, color: AppColors.outlineVariant),
          const _FinancialRow(
            label: 'Gross Amount (50Q x ₹6,800)',
            value: '₹3,40,000',
            valueColor: AppColors.onSurface,
          ),
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.only(left: 8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              decoration: const BoxDecoration(
                border: Border(
                  left: BorderSide(color: AppColors.errorContainer, width: 2),
                ),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(height: 8),
                  Text(
                    'Deductions',
                    style: TextStyle(
                      fontSize: 14,
                      height: 20 / 14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                  SizedBox(height: 8),
                  _FinancialRow(
                    label: 'Transport Loading',
                    value: '- ₹2,500',
                    valueColor: AppColors.error,
                  ),
                  SizedBox(height: 8),
                  _FinancialRow(
                    label: 'Market Commission (1.5%)',
                    value: '- ₹5,100',
                    valueColor: AppColors.error,
                  ),
                  SizedBox(height: 8),
                  _FinancialRow(
                    label: 'Moisture Quality Deduction',
                    value: '- ₹1,200',
                    valueColor: AppColors.error,
                  ),
                  SizedBox(height: 8),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            color: const Color(0x0F00855D),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final narrow = constraints.maxWidth < 360;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Net Payable to Farmer',
                      style: GoogleFonts.inter(
                        fontSize: 24,
                        height: 32 / 24,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                    if (!narrow) const SizedBox(height: 4),
                    Text(
                      '₹3,31,200',
                      style: GoogleFonts.inter(
                        fontSize: 48,
                        height: 56 / 48,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
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
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 16,
              height: 24 / 16,
              color: AppColors.onSurface,
            ),
          ),
        ),
        const SizedBox(width: 8),
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
    );
  }
}

class _ActionCard extends StatefulWidget {
  const _ActionCard();

  @override
  State<_ActionCard> createState() => _ActionCardState();
}

class _ActionCardState extends State<_ActionCard> {
  bool _agreed = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0x3300855D)),
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
          const Text(
            'Final Confirmation',
            style: TextStyle(
              fontSize: 14,
              height: 20 / 14,
              color: AppColors.onSurface,
            ),
          ),
          const SizedBox(height: 16),
          Material(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(8),
            child: InkWell(
              onTap: () => setState(() => _agreed = !_agreed),
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 20,
                      height: 20,
                      child: Checkbox(
                        value: _agreed,
                        onChanged: (v) => setState(() => _agreed = v ?? false),
                        activeColor: AppColors.primary,
                        side: const BorderSide(
                          color: AppColors.outlineVariant,
                          width: 1.5,
                        ),
                        materialTapTargetSize:
                            MaterialTapTargetSize.shrinkWrap,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'I, Ramesh Gowda, agree to the final deductions and the net settlement amount of ₹3,31,200. I authorize the transfer to my registered bank account ending in 4921.',
                        style: TextStyle(
                          fontSize: 16,
                          height: 24 / 16,
                          color: AppColors.onSurface,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          const _ActionButtons(),
        ],
      ),
    );
  }
}

class _ActionButtons extends StatelessWidget {
  const _ActionButtons();

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isDesktop = width >= 768;

    final confirm = SizedBox(
      height: 56,
      child: Material(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(8),
        shadowColor: const Color(0xFF000000),
        elevation: 4,
        child: InkWell(
          onTap: () {},
          borderRadius: BorderRadius.circular(8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.check_circle,
                color: AppColors.onPrimary,
              ),
              const SizedBox(width: 8),
              Text(
                'Confirm & Settle',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  height: 20 / 14,
                  color: AppColors.onPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );

    final dispute = SizedBox(
      height: 56,
      child: Material(
        color: AppColors.surfaceContainer,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: const BorderSide(color: AppColors.outline),
        ),
        child: InkWell(
          onTap: () {},
          borderRadius: BorderRadius.circular(8),
          child: Center(
            child: Text(
              'Raise Dispute',
              style: GoogleFonts.inter(
                fontSize: 14,
                height: 20 / 14,
                color: AppColors.onSurface,
              ),
            ),
          ),
        ),
      ),
    );

    if (isDesktop) {
      return Row(
        children: [
          Expanded(flex: 2, child: confirm),
          const SizedBox(width: 16),
          Expanded(child: dispute),
        ],
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        confirm,
        const SizedBox(height: 16),
        dispute,
      ],
    );
  }
}
