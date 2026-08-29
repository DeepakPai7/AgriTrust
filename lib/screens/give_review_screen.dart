import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../main.dart';

/// A "Transaction Settled" review screen shown after a deal is settled. The
/// farmer rates their experience dealing with the buyer, leaves optional
/// feedback, may post anonymously, and either submits or defers. Matches the
/// agritrust "Give Review" modal-flow design.
class GiveReviewScreen extends StatelessWidget {
  const GiveReviewScreen({
    super.key,
    this.buyerName = 'Rajesh Kumar',
    this.dealId = 'DC-8492',
    this.dealSummary = '50 Tons Wheat',
  });

  final String buyerName;
  final String dealId;
  final String dealSummary;

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
              child: _ReviewCard(
                buyerName: buyerName,
                dealId: dealId,
                dealSummary: dealSummary,
                isDesktop: isDesktop,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// The agritrust top bar with a close button (page is reachable directly or
/// after a flow closes).
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

class _ReviewCard extends StatelessWidget {
  const _ReviewCard({
    required this.buyerName,
    required this.dealId,
    required this.dealSummary,
    required this.isDesktop,
  });

  final String buyerName;
  final String dealId;
  final String dealSummary;
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
              _BuyerSummaryCard(
                buyerName: buyerName,
                dealId: dealId,
                dealSummary: dealSummary,
              ),
              const SizedBox(height: 24),
              const _OverallRating(),
              const SizedBox(height: 24),
              const _FeedbackField(),
              const SizedBox(height: 16),
              const _AnonymousToggle(),
              const SizedBox(height: 16),
              _Actions(isDesktop: isDesktop),
            ],
          ),
        ),
        const SizedBox(height: 24),
        _LanguageFab(isDesktop: isDesktop),
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
          'Please take a moment to rate your experience.',
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
        boxShadow: [BoxShadow(color: Color(0x1A000000), blurRadius: 15, offset: Offset(0, 10))],
      ),
      child: const Icon(
        Icons.check_circle,
        size: 32,
        color: AppColors.primary,
      ),
    );
  }
}

class _BuyerSummaryCard extends StatelessWidget {
  const _BuyerSummaryCard({
    required this.buyerName,
    required this.dealId,
    required this.dealSummary,
  });

  final String buyerName;
  final String dealId;
  final String dealSummary;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.outlineVariant),
      ),
      child: Row(
        children: [
          const _FarmerAvatar(),
          const SizedBox(width: 24),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Reviewing Buyer',
                  style: TextStyle(
                    fontSize: 14,
                    height: 20 / 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  buyerName,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(
                    fontSize: 24,
                    height: 32 / 24,
                    fontWeight: FontWeight.w600,
                    color: AppColors.onSurface,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Deal #$dealId • $dealSummary',
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    height: 24 / 16,
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FarmerAvatar extends StatelessWidget {
  const _FarmerAvatar();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFC96A2E), Color(0xFF7A4A2B)],
        ),
        boxShadow: const [
          BoxShadow(color: Color(0x22000000), blurRadius: 4),
        ],
      ),
      child: const Center(
        child: Icon(Icons.person, size: 32, color: Colors.white),
      ),
    );
  }
}

/// Interactive 5-star overall rating with hover/fill states.
class _OverallRating extends StatefulWidget {
  const _OverallRating();

  @override
  State<_OverallRating> createState() => _OverallRatingState();
}

class _OverallRatingState extends State<_OverallRating> {
  int _rating = 4;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text(
          'Overall Experience',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 24,
            height: 32 / 24,
            fontWeight: FontWeight.w600,
            color: AppColors.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            for (var i = 1; i <= 5; i++)
              InkWell(
                onTap: () => setState(() => _rating = i),
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Icon(
                    Icons.star,
                    size: 40,
                    color: i <= _rating
                        ? AppColors.primary
                        : AppColors.outline,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          _ratingLabel,
          style: const TextStyle(
            fontSize: 14,
            height: 20 / 14,
            fontWeight: FontWeight.w500,
            color: AppColors.primary,
          ),
        ),
      ],
    );
  }

  String get _ratingLabel {
    switch (_rating) {
      case 1:
        return 'Poor';
      case 2:
        return 'Fair';
      case 3:
        return 'Good';
      case 4:
        return 'Very Good';
      case 5:
        return 'Excellent';
      default:
        return '';
    }
  }
}

class _FeedbackField extends StatelessWidget {
  const _FeedbackField();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Write your feedback (Optional)',
          style: TextStyle(
            fontSize: 14,
            height: 20 / 14,
            fontWeight: FontWeight.w500,
            color: AppColors.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          maxLines: 4,
          controller: TextEditingController(),
          style: GoogleFonts.inter(
            fontSize: 16,
            height: 24 / 16,
            color: AppColors.onSurface,
          ),
          decoration: InputDecoration(
            filled: true,
            fillColor: AppColors.surface,
            hintText: 'How was your experience dealing with Rajesh?',
            hintStyle: GoogleFonts.inter(
              fontSize: 16,
              color: AppColors.outline,
            ),
            contentPadding: const EdgeInsets.all(16),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.outlineVariant),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.outlineVariant),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}

class _AnonymousToggle extends StatefulWidget {
  const _AnonymousToggle();

  @override
  State<_AnonymousToggle> createState() => _AnonymousToggleState();
}

class _AnonymousToggleState extends State<_AnonymousToggle> {
  bool _anonymous = false;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: InkWell(
        onTap: () => setState(() => _anonymous = !_anonymous),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              width: 44,
              height: 24,
              decoration: BoxDecoration(
                color: _anonymous
                    ? AppColors.primary
                    : AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Align(
                alignment: _anonymous
                    ? Alignment.centerRight
                    : Alignment.centerLeft,
                child: Container(
                  width: 20,
                  height: 20,
                  margin: const EdgeInsets.all(2),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(color: Color(0x22000000), blurRadius: 2),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            const Flexible(
              child: Text(
                'Post anonymously',
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 16,
                  height: 24 / 16,
                  color: AppColors.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Actions extends StatelessWidget {
  const _Actions({required this.isDesktop});

  final bool isDesktop;

  @override
  Widget build(BuildContext context) {
    final later = OutlinedButton(
      onPressed: () => Navigator.of(context).maybePop(),
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.onSurfaceVariant,
        side: const BorderSide(color: AppColors.outlineVariant),
        minimumSize: Size(isDesktop ? 0 : double.infinity, 56),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: const Text(
        'Maybe Later',
        style: TextStyle(
          fontSize: 14,
          height: 20 / 14,
          fontWeight: FontWeight.w500,
        ),
      ),
    );

    final submit = Material(
      color: AppColors.primary,
      borderRadius: BorderRadius.circular(8),
      elevation: 2,
      shadowColor: const Color(0xFF000000),
      child: InkWell(
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Thank you! Review submitted.')),
          );
          Navigator.of(context).maybePop();
        },
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
                  'Submit Review',
                  style: TextStyle(
                    fontSize: 14,
                    height: 20 / 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.onPrimary,
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.send, size: 18, color: AppColors.onPrimary),
              ],
            ),
          ),
        ),
      ),
    );

    if (isDesktop) {
      return Row(
        children: [
          Expanded(flex: 1, child: later),
          const SizedBox(width: 16),
          Expanded(flex: 2, child: submit),
        ],
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        later,
        const SizedBox(height: 8),
        submit,
      ],
    );
  }
}

class _LanguageFab extends StatelessWidget {
  const _LanguageFab({required this.isDesktop});

  final bool isDesktop;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.center,
      child: MaterialButton(
        onPressed: () {},
        color: AppColors.surfaceContainerHigh,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(999),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.language, size: 20, color: AppColors.onSurface),
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
    );
  }
}
