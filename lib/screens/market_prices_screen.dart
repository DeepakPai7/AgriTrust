import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../main.dart';
import '../widgets/app_bars.dart';

/// Market Prices screen. Uses the shared top bar and bottom navigation so the
/// chrome is identical everywhere; only the body content differs.
class MarketPricesScreen extends StatelessWidget {
  const MarketPricesScreen({super.key});

  static const double maxContentWidth = 1280;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isDesktop = width >= 768;

    return Scaffold(
      appBar: const AppTopBar(),
      bottomNavigationBar: const AppBottomNav(activeIndex: 1),
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
                child: const _MarketBody(),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _MarketBody extends StatelessWidget {
  const _MarketBody();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const _PageHeader(),
        const SizedBox(height: 32),
        const _InsightCard(),
        const SizedBox(height: 32),
        _PriceGrid(),
      ],
    );
  }
}

class _PageHeader extends StatelessWidget {
  const _PageHeader();

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isDesktop = width >= 768;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Market Prices',
          style: GoogleFonts.inter(
            fontSize: isDesktop ? 32 : 24,
            height: 1.33,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.01,
            color: AppColors.onBackground,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Real-time agricultural commodity prices across local mandis.',
          style: GoogleFonts.inter(
            fontSize: 16,
            height: 24 / 16,
            color: AppColors.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 16),
        Material(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          elevation: 0,
          child: Container(
            padding: const EdgeInsets.all(16),
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
            child: isDesktop
                ? const _SearchRow()
                : const _SearchColumn(),
          ),
        ),
      ],
    );
  }
}

class _SearchRow extends StatelessWidget {
  const _SearchRow();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(child: _SearchField()),
        const SizedBox(width: 16),
        const Expanded(child: _LocationDropdown()),
        const SizedBox(width: 16),
        const _FilterButton(),
      ],
    );
  }
}

class _SearchColumn extends StatelessWidget {
  const _SearchColumn();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const _SearchField(),
        const SizedBox(height: 16),
        const _LocationDropdown(),
        const SizedBox(height: 16),
        const _FilterButton(),
      ],
    );
  }
}

class _SearchField extends StatelessWidget {
  const _SearchField();

  @override
  Widget build(BuildContext context) {
    return TextField(
      style: GoogleFonts.inter(
        fontSize: 16,
        color: AppColors.onSurface,
      ),
      decoration: InputDecoration(
        hintText: 'Search Crop (e.g., Tomato)',
        hintStyle: GoogleFonts.inter(
          fontSize: 16,
          color: AppColors.onSurfaceVariant,
        ),
        prefixIcon: const Padding(
          padding: EdgeInsets.symmetric(horizontal: 10),
          child: Icon(
            Icons.search,
            color: AppColors.onSurfaceVariant,
          ),
        ),
        prefixIconConstraints: const BoxConstraints(minWidth: 40),
        filled: true,
        fillColor: AppColors.surfaceBright,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
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
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
      ),
    );
  }
}

class _LocationDropdown extends StatelessWidget {
  const _LocationDropdown();

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      isExpanded: true,
      initialValue: 'All Locations',
      icon: const Icon(
        Icons.expand_more,
        color: AppColors.onSurfaceVariant,
      ),
      borderRadius: BorderRadius.circular(8),
      style: GoogleFonts.inter(
        fontSize: 16,
        color: AppColors.onSurface,
      ),
      decoration: InputDecoration(
        prefixIcon: const Padding(
          padding: EdgeInsets.symmetric(horizontal: 10),
          child: Icon(
            Icons.location_on,
            color: AppColors.onSurfaceVariant,
          ),
        ),
        prefixIconConstraints: const BoxConstraints(minWidth: 40),
        filled: true,
        fillColor: AppColors.surfaceBright,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
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
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
      ),
      items: const [
        DropdownMenuItem(
          value: 'All Locations',
          child: Text('All Locations', overflow: TextOverflow.ellipsis),
        ),
        DropdownMenuItem(
          value: 'Bangalore APMC',
          child: Text('Bangalore APMC', overflow: TextOverflow.ellipsis),
        ),
        DropdownMenuItem(
          value: 'Mysore Mandi',
          child: Text('Mysore Mandi', overflow: TextOverflow.ellipsis),
        ),
        DropdownMenuItem(
          value: 'Hubli Market',
          child: Text('Hubli Market', overflow: TextOverflow.ellipsis),
        ),
      ],
      onChanged: (_) {},
    );
  }
}

class _FilterButton extends StatelessWidget {
  const _FilterButton();

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isDesktop = width >= 768;

    return SizedBox(
      height: 56,
      child: Material(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(8),
        elevation: 1,
        shadowColor: const Color(0x0D059669),
        child: InkWell(
          onTap: () {},
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: isDesktop ? 24 : 16,
              vertical: 8,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.filter_list,
                  color: AppColors.onPrimary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Filter',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.onPrimary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _InsightCard extends StatelessWidget {
  const _InsightCard();

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isDesktop = width >= 768;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primaryContainer,
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.insights,
                color: AppColors.onPrimaryContainer,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Price Insight: Tomatoes',
                  style: GoogleFonts.inter(
                    fontSize: 24,
                    height: 32 / 24,
                    fontWeight: FontWeight.w600,
                    color: AppColors.onPrimaryContainer,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (isDesktop)
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(flex: 2, child: _InsightBar()),
                const SizedBox(width: 16),
                const _InsightButton(),
              ],
            )
          else ...[
            const _InsightBar(),
            const SizedBox(height: 8),
            const _InsightButton(),
          ],
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class _InsightBar extends StatelessWidget {
  const _InsightBar();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Flexible(
              child: Text(
                'Your Expected Price: ₹2,500/Q',
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: AppColors.onPrimaryContainer,
                ),
              ),
            ),
            const Spacer(),
            Flexible(
              child: Text(
                'Market Avg: ₹2,850/Q',
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.onPrimaryContainer,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: SizedBox(
            height: 16,
            child: Stack(
              children: [
                Container(color: AppColors.surfaceContainerHigh),
                FractionallySizedBox(
                  widthFactor: 0.7,
                  alignment: Alignment.centerLeft,
                  child: Container(color: AppColors.inversePrimary),
                ),
                Align(
                  alignment: const Alignment(0.2, 0),
                  child: Container(
                    width: 4,
                    height: 24,
                    decoration: BoxDecoration(
                      color: AppColors.onPrimaryContainer,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text.rich(
          TextSpan(
            text: 'Market average is currently ',
            style: GoogleFonts.inter(
              fontSize: 14,
              color: AppColors.onPrimaryContainer,
            ),
            children: [
              TextSpan(
                text: '+₹350',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.inversePrimary,
                ),
              ),
              TextSpan(
                text: ' above your expectation.',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: AppColors.onPrimaryContainer,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _InsightButton extends StatelessWidget {
  const _InsightButton();

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isDesktop = width >= 768;

    return SizedBox(
      height: 56,
      child: Material(
        color: AppColors.onPrimaryContainer,
        borderRadius: BorderRadius.circular(8),
        elevation: 1,
        shadowColor: const Color(0x0D059669),
        child: InkWell(
          onTap: () {},
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: isDesktop ? 24 : 16,
              vertical: 8,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  child: Text(
                    'List for Sale Now',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primaryContainer,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(
                  Icons.arrow_forward,
                  color: AppColors.primaryContainer,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PriceGrid extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isDesktop = width >= 1024;

    final cards = const [
      _PriceCard(
        name: 'Tomato (Hybrid)',
        location: 'Bangalore APMC',
        change: 2.5,
        price: '₹2,900',
        time: 'Today, 10:30 AM',
        source: 'APMC Board',
      ),
      _PriceCard(
        name: 'Onion (Red)',
        location: 'Hubli Market',
        change: -1.2,
        price: '₹1,850',
        time: 'Today, 09:15 AM',
        source: 'Agmarknet',
      ),
      _PriceCard(
        name: 'Wheat (Sona)',
        location: 'Mysore Mandi',
        change: 0.0,
        price: '₹2,400',
        time: 'Yesterday, 4:00 PM',
        source: 'Direct Buyer',
      ),
    ];

    if (isDesktop) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (var i = 0; i < cards.length; i++) ...[
            if (i > 0) const SizedBox(width: 16),
            Expanded(child: cards[i]),
          ],
        ],
      );
    }
    return Column(
      children: [
        for (var i = 0; i < cards.length; i++) ...[
          if (i > 0) const SizedBox(height: 16),
          cards[i],
        ],
      ],
    );
  }
}

class _PriceCard extends StatelessWidget {
  const _PriceCard({
    required this.name,
    required this.location,
    required this.change,
    required this.price,
    required this.time,
    required this.source,
  });

  final String name;
  final String location;
  final double change;
  final String price;
  final String time;
  final String source;

  @override
  Widget build(BuildContext context) {
    final up = change > 0;
    final flat = change == 0;

    final trendBg = up
        ? AppColors.surfaceContainerHigh
        : AppColors.errorContainer;
    final trendColor = up ? AppColors.primary : AppColors.onErrorContainer;
    final trendIcon = up
        ? Icons.arrow_upward
        : (flat ? Icons.horizontal_rule : Icons.arrow_downward);
    final trendText =
        flat ? '0.0%' : '${up ? '' : ''}${change.toStringAsFixed(1)}%';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: GoogleFonts.inter(
                        fontSize: 24,
                        height: 32 / 24,
                        fontWeight: FontWeight.w600,
                        color: AppColors.onBackground,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.location_on,
                          size: 16,
                          color: AppColors.onSurfaceVariant,
                        ),
                        const SizedBox(width: 2),
                        Flexible(
                          child: Text(
                            location,
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              color: AppColors.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: trendBg,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(trendIcon, size: 14, color: trendColor),
                    const SizedBox(width: 2),
                    Text(
                      trendText,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: trendColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            price,
            style: GoogleFonts.inter(
              fontSize: 48,
              height: 56 / 48,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.02,
              color: up ? AppColors.primary : AppColors.onBackground,
            ),
          ),
          Text(
            'per Quintal',
            style: GoogleFonts.inter(
              fontSize: 14,
              color: AppColors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 16),
          Divider(
            height: 1,
            thickness: 1,
            color: AppColors.surfaceVariant,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Flexible(
                flex: 1,
                child: Row(
                  children: [
                    const Icon(
                      Icons.schedule,
                      size: 16,
                      color: AppColors.onSurfaceVariant,
                    ),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        time,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Flexible(
                flex: 1,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.verified,
                      size: 16,
                      color: AppColors.onSurfaceVariant,
                    ),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        source,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
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

