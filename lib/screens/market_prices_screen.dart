import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../main.dart';
import '../models/models.dart';
import '../services/api_scope.dart';
import '../widgets/app_bars.dart';

/// Market Prices screen. Uses the shared top bar and bottom navigation so the
/// chrome is identical everywhere; only the body content differs.
class MarketPricesScreen extends StatefulWidget {
  const MarketPricesScreen({super.key});

  static const double maxContentWidth = 1280;

  @override
  State<MarketPricesScreen> createState() => _MarketPricesScreenState();
}

class _MarketPricesScreenState extends State<MarketPricesScreen> {
  late Future<List<MarketPrice>> _pricesFuture;

  @override
  void initState() {
    super.initState();
    _pricesFuture = ApiScope.of(context).fetchMarketPrices();
  }

  void _reload() {
    setState(() {
      _pricesFuture = ApiScope.of(context).fetchMarketPrices();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppTopBar(showBack: false),
      bottomNavigationBar: const AppBottomNav(activeIndex: 1),
      backgroundColor: AppColors.background,
      body: SafeArea(
        top: false,
        bottom: false,
        child: _MarketBody(
          pricesFuture: _pricesFuture,
          onRetry: _reload,
        ),
      ),
    );
  }
}

class _MarketBody extends StatefulWidget {
  const _MarketBody({required this.pricesFuture, required this.onRetry});

  final Future<List<MarketPrice>> pricesFuture;
  final VoidCallback onRetry;

  @override
  State<_MarketBody> createState() => _MarketBodyState();
}

/// How many price cards to render at most. Rendering thousands of live
/// records at once is what caused the crash, so we cap the visible set.
const int _maxCards = 50;

class _MarketBodyState extends State<_MarketBody> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedState = 'All States';
  List<MarketPrice>? _all;
  bool _loading = true;
  bool _error = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void didUpdateWidget(covariant _MarketBody oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!identical(oldWidget.pricesFuture, widget.pricesFuture)) {
      _load();
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = false;
    });
    try {
      final prices = await widget.pricesFuture;
      if (!mounted) return;
      setState(() {
        _all = prices;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _error = true;
        _loading = false;
      });
    }
  }

  List<String> get _states {
    final all = _all ?? const <MarketPrice>[];
    final states = <String>{};
    for (final p in all) {
      if (p.state?.isNotEmpty == true) states.add(p.state!);
    }
    final list = states.toList()..sort();
    return list;
  }

  List<MarketPrice> get _visible {
    final all = _all ?? const <MarketPrice>[];
    final query = _searchController.text.trim().toLowerCase();
    Iterable<MarketPrice> result = all;
    if (query.isNotEmpty) {
      result = result.where((p) => p.commodity.toLowerCase().contains(query));
    }
    if (_selectedState != 'All States') {
      result = result.where((p) => p.state == _selectedState);
    }
    return result.take(_maxCards).toList();
  }

  void _clearFilters() {
    _searchController.clear();
    setState(() => _selectedState = 'All States');
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isDesktop = width >= 768;

    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.only(top: 32),
          sliver: SliverToBoxAdapter(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: MarketPricesScreen.maxContentWidth,
                ),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: isDesktop ? 64 : 16,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _PageHeader(
                        searchController: _searchController,
                        selectedState: _selectedState,
                        states: _states,
                        onStateChanged: (v) {
                          setState(() => _selectedState = v ?? 'All States');
                        },
                        onFilterChanged: (_) => setState(() {}),
                        onClear: _clearFilters,
                      ),
                      const SizedBox(height: 16),
                      const _InsightCard(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        ..._priceSlivers(width, isDesktop),
        SliverToBoxAdapter(
          child: SizedBox(height: isDesktop ? 48 : 24),
        ),
      ],
    );
  }

  List<Widget> _priceSlivers(double width, bool isDesktop) {
    if (_loading) {
      return [
        SliverFillRemaining(
          hasScrollBody: false,
          child: Center(
            child:
                CircularProgressIndicator(color: AppColors.primary),
          ),
        ),
      ];
    }
    if (_error) {
      return [
        SliverFillRemaining(
          hasScrollBody: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.cloud_off,
                size: 40,
                color: AppColors.onSurfaceVariant,
              ),
              const SizedBox(height: 12),
              Text(
                'Could not load market prices',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  color: AppColors.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () {
                  widget.onRetry();
                },
                child: Text(
                  'Retry',
                  style: GoogleFonts.inter(color: AppColors.primary),
                ),
              ),
            ],
          ),
        ),
      ];
    }

    final all = _all ?? const <MarketPrice>[];
    if (all.isEmpty) {
      return [
        const SliverFillRemaining(
          hasScrollBody: false,
          child: Center(
            child: Text(
              'No price data available.',
            ),
          ),
        ),
      ];
    }

    final prices = _visible;
    final horizontal = isDesktop ? 64.0 : 16.0;
    final cols = width >= 1200 ? 3 : (width >= 700 ? 2 : 1);
    final rows = (prices.length / cols).ceil();

    return [
      SliverPadding(
        padding: EdgeInsets.only(
          left: horizontal,
          right: horizontal,
          top: 24,
        ),
        sliver: SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, rowIndex) {
              final start = rowIndex * cols;
              final slice = prices.skip(start).take(cols).toList();
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (var i = 0; i < cols; i++) ...[
                      if (i > 0) const SizedBox(width: 16),
                      Expanded(
                        child: i < slice.length
                            ? _PriceCard(
                                name: slice[i].commodity,
                                location: slice[i].state?.isNotEmpty == true
                                    ? slice[i].state!
                                    : 'India',
                                change: 0.0,
                                price: '₹${_num(slice[i].modalPrice)}',
                                time: slice[i].arrivalDate?.isNotEmpty == true
                                    ? slice[i].arrivalDate!
                                    : 'Today',
                                source: 'Verified',
                                unit: 'Quintal',
                              )
                            : const SizedBox.shrink(),
                      ),
                    ],
                  ],
                ),
              );
            },
            childCount: rows,
          ),
        ),
      ),
    ];
  }
}

class _PageHeader extends StatelessWidget {
  const _PageHeader({
    required this.searchController,
    required this.selectedState,
    required this.states,
    required this.onStateChanged,
    required this.onFilterChanged,
    required this.onClear,
  });

  final TextEditingController searchController;
  final String selectedState;
  final List<String> states;
  final ValueChanged<String?> onStateChanged;
  final ValueChanged<String> onFilterChanged;
  final VoidCallback onClear;

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
                ? _SearchRow(
                    searchController: searchController,
                    selectedState: selectedState,
                    states: states,
                    onStateChanged: onStateChanged,
                    onFilterChanged: onFilterChanged,
                    onClear: onClear,
                  )
                : _SearchColumn(
                    searchController: searchController,
                    selectedState: selectedState,
                    states: states,
                    onStateChanged: onStateChanged,
                    onFilterChanged: onFilterChanged,
                    onClear: onClear,
                  ),
          ),
        ),
      ],
    );
  }
}

class _SearchRow extends StatelessWidget {
  const _SearchRow({
    required this.searchController,
    required this.selectedState,
    required this.states,
    required this.onStateChanged,
    required this.onFilterChanged,
    required this.onClear,
  });

  final TextEditingController searchController;
  final String selectedState;
  final List<String> states;
  final ValueChanged<String?> onStateChanged;
  final ValueChanged<String> onFilterChanged;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _SearchField(
            controller: searchController,
            onChanged: onFilterChanged,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _LocationDropdown(
            selectedState: selectedState,
            states: states,
            onChanged: onStateChanged,
          ),
        ),
        const SizedBox(width: 16),
        _FilterButton(onTap: onClear),
      ],
    );
  }
}

class _SearchColumn extends StatelessWidget {
  const _SearchColumn({
    required this.searchController,
    required this.selectedState,
    required this.states,
    required this.onStateChanged,
    required this.onFilterChanged,
    required this.onClear,
  });

  final TextEditingController searchController;
  final String selectedState;
  final List<String> states;
  final ValueChanged<String?> onStateChanged;
  final ValueChanged<String> onFilterChanged;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _SearchField(
          controller: searchController,
          onChanged: onFilterChanged,
        ),
        const SizedBox(height: 16),
        _LocationDropdown(
          selectedState: selectedState,
          states: states,
          onChanged: onStateChanged,
        ),
        const SizedBox(height: 16),
        _FilterButton(onTap: onClear),
      ],
    );
  }
}

class _SearchField extends StatelessWidget {
  const _SearchField({required this.controller, required this.onChanged});

  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
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
  const _LocationDropdown({
    required this.selectedState,
    required this.states,
    required this.onChanged,
  });

  final String selectedState;
  final List<String> states;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      isExpanded: true,
      initialValue: selectedState,
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
      items: [
        const DropdownMenuItem(
          value: 'All States',
          child: Text('All States', overflow: TextOverflow.ellipsis),
        ),
        for (final s in states)
          DropdownMenuItem(
            value: s,
            child: Text(s, overflow: TextOverflow.ellipsis),
          ),
      ],
      onChanged: onChanged,
    );
  }
}

class _FilterButton extends StatelessWidget {
  const _FilterButton({required this.onTap});

  final VoidCallback onTap;

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
          onTap: onTap,
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
                  Icons.filter_alt_off,
                  color: AppColors.onPrimary,
                ),
                const SizedBox(width: 8),
                Text(
                  isDesktop ? 'Clear Filters' : 'Clear',
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

class _PriceCard extends StatelessWidget {
  const _PriceCard({
    required this.name,
    required this.location,
    required this.change,
    required this.price,
    required this.time,
    required this.source,
    required this.unit,
  });

  final String name;
  final String location;
  final double change;
  final String price;
  final String time;
  final String source;
  final String unit;

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
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
            'per ${unit.isEmpty ? 'unit' : unit}',
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

String _num(num value) {
  if (value == value.roundToDouble()) {
    return value.toStringAsFixed(0).replaceAllMapped(
          RegExp(r'\B(?=(\d{3})+(?!\d))'),
          (_) => ',',
        );
  }
  return value.toString();
}
