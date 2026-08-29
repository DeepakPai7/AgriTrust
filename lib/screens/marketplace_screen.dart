import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../main.dart';
import '../models/models.dart';
import '../services/api_scope.dart';
import '../widgets/app_bars.dart';
import 'buyer_request_form_screen.dart';
import 'product_details_screen.dart';

/// The Marketplace (Browse Produce) screen: a header with search/filters and
/// a responsive grid of farmer produce listings.
class MarketplaceScreen extends StatelessWidget {
  const MarketplaceScreen({super.key});

  static const double maxContentWidth = 1280; // matches Tailwind's max-w-7xl

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
              constraints: const BoxConstraints(
                maxWidth: maxContentWidth,
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: isDesktop ? 64 : 16,
                ),
                child: const _MarketplaceBody(),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _MarketplaceBody extends StatefulWidget {
  const _MarketplaceBody();

  @override
  State<_MarketplaceBody> createState() => _MarketplaceBodyState();
}

class _MarketplaceBodyState extends State<_MarketplaceBody> {
  List<Product>? _products;
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
      final products = await ApiScope.of(context).fetchProducts();
      if (mounted) {
        setState(() {
          _products = products;
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const _HeaderSection(),
        const SizedBox(height: 12),
        const _SearchSection(),
        const SizedBox(height: 20),
        _buildBody(),
      ],
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
              'Could not load produce',
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

    final products = _products ?? const <Product>[];
    if (products.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 48),
        child: Column(
          children: const [
            Icon(
              Icons.inventory_2_outlined,
              size: 40,
              color: AppColors.onSurfaceVariant,
            ),
            SizedBox(height: 12),
            Text(
              'No produce listed yet',
              style: TextStyle(
                fontSize: 16,
                color: AppColors.onSurfaceVariant,
              ),
            ),
          ],
        ),
      );
    }
    return _ListingsGrid(products: products);
  }
}

class _HeaderSection extends StatelessWidget {
  const _HeaderSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        Text(
          'Available Produce',
          style: TextStyle(
            fontSize: 32,
            height: 40 / 32,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.02,
            color: AppColors.onSurface,
          ),
        ),
        SizedBox(height: 6),
        Text(
          'Browse verified farmers and quality crops.',
          style: TextStyle(
            fontSize: 15,
            height: 22 / 15,
            color: AppColors.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class _SearchSection extends StatelessWidget {
  const _SearchSection();

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isDesktop = width >= 768;

    final searchBar = Container(
      height: 56,
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.outlineVariant),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D059669),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: const TextField(
        decoration: InputDecoration(
          hintText: 'Search crops, farmers, locations...',
          hintStyle: TextStyle(
            fontSize: 16,
            height: 24 / 16,
            color: AppColors.onSurfaceVariant,
          ),
          prefixIcon: Icon(Icons.search, color: AppColors.outline),
          border: InputBorder.none,
        ),
      ),
    );

    final filtersButton = Container(
      height: 56,
      constraints: const BoxConstraints(minWidth: 96),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.outlineVariant),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D059669),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.tune, size: 20, color: AppColors.onSurfaceVariant),
          SizedBox(width: 8),
          Text('Filters'),
        ],
      ),
    );

    if (!isDesktop) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          searchBar,
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerLeft,
            child: filtersButton,
          ),
        ],
      );
    }

    return Row(
      children: [
        Expanded(child: searchBar),
        const SizedBox(width: 8),
        filtersButton,
        const SizedBox(width: 8),
        const _SortSelector(),
      ],
    );
  }
}

class _SortSelector extends StatelessWidget {
  const _SortSelector();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Sort by:',
          style: TextStyle(
            fontSize: 14,
            height: 20 / 14,
            fontWeight: FontWeight.w500,
            color: AppColors.onSurfaceVariant,
          ),
        ),
        SizedBox(width: 8),
        SizedBox(
          height: 56,
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: 'Recommended',
              borderRadius: BorderRadius.all(Radius.circular(8)),
              dropdownColor: AppColors.surfaceContainerLowest,
              items: [
                DropdownMenuItem(value: 'Recommended', child: _SortText('Recommended')),
                DropdownMenuItem(value: 'Low to High', child: _SortText('Price: Low to High')),
                DropdownMenuItem(value: 'Nearest', child: _SortText('Distance: Nearest')),
                DropdownMenuItem(value: 'Highest', child: _SortText('Quality: Highest')),
              ],
              onChanged: (_) {},
            ),
          ),
        ),
      ],
    );
  }
}

class _SortText extends StatelessWidget {
  const _SortText(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 16,
        height: 24 / 16,
        color: AppColors.onSurface,
      ),
    );
  }
}

class _ListingsGrid extends StatelessWidget {
  const _ListingsGrid({required this.products});

  final List<Product> products;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    // grid-cols-1 -> md:2 -> lg:3
    final columns = width >= 1024 ? 3 : (width >= 768 ? 2 : 1);

    final listings = products.map(_Produce.fromProduct).toList();

    return LayoutBuilder(
      builder: (context, constraints) {
        final gap = 24.0;
        final tileWidth = (constraints.maxWidth - gap * (columns - 1)) / columns;
        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: [
            for (final l in listings)
              SizedBox(
                width: tileWidth,
                child: _ProduceCard(produce: l),
              ),
          ],
        );
      },
    );
  }
}

class _Produce {
  const _Produce({
    required this.avatarLetter,
    required this.avatarColor,
    required this.avatarTextColor,
    required this.names,
    required this.location,
    required this.grade,
    required this.gradeVerified,
    required this.product,
    required this.quantity,
    required this.price,
    required this.marketRef,
    required this.premium,
    required this.source,
  });

  /// Maps a farmer-listed [Product] into a marketplace listing. Fields the
  /// backend does not model (grade, premium, market ref) use static preview
  /// values so the card layout stays intact.
  factory _Produce.fromProduct(Product p) {
    final name = p.farmerName?.isNotEmpty == true ? p.farmerName! : 'Farmer';
    const avatarColors = [
      (AppColors.primaryContainer, AppColors.onPrimaryContainer),
      (AppColors.secondaryContainer, AppColors.onSecondaryContainer),
      (AppColors.tertiaryContainer, AppColors.onTertiaryContainer),
    ];
    final chosen = avatarColors[name.hashCode.abs() % avatarColors.length];
    final price = '₹${_formatNumber(p.price)}/${p.unit}';
    return _Produce(
      avatarLetter: name[0].toUpperCase(),
      avatarColor: chosen.$1,
      avatarTextColor: chosen.$2,
      names: [name],
      location: p.location == null || p.location!.isEmpty
          ? 'Location not set'
          : p.location!,
      grade: 'Grade A',
      gradeVerified: false,
      product: p.productName,
      quantity: '${_formatNumber(p.quantity)} ${p.unit}',
      price: price,
      marketRef: 'Listed',
      premium: false,
      source: p,
    );
  }

  final String avatarLetter;
  final Color avatarColor;
  final Color avatarTextColor;
  final List<String> names;
  final String location;
  final String grade;
  final bool gradeVerified;
  final String product;
  final String quantity;
  final String price;
  final String marketRef;
  final bool premium;

  /// The backing [Product] this listing was built from, used to open the
  /// full product details screen.
  final Product source;
}

/// Formats a number without trailing decimals (2400 -> "2,400", 122.5 -> "122.5").
String _formatNumber(num value) {
  final text = value.toStringAsFixed(
    value % 1 == 0 ? 0 : 2,
  );
  final parts = text.split('.');
  final buffer = StringBuffer();
  final digits = parts[0];
  for (var i = 0; i < digits.length; i++) {
    if (i > 0 && (digits.length - i) % 3 == 0) buffer.write(',');
    buffer.write(digits[i]);
  }
  if (parts.length > 1) {
    buffer.write('.');
    buffer.write(parts[1]);
  }
  return buffer.toString();
}

class _ProduceCard extends StatelessWidget {
  const _ProduceCard({required this.produce});

  final _Produce produce;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: produce.premium
              ? AppColors.primaryFixedDim
              : AppColors.surfaceContainerHigh,
          width: produce.premium ? 2 : 1,
        ),
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
          if (produce.premium) ...[
            Align(
              alignment: Alignment.centerRight,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: const BoxDecoration(
                  color: AppColors.primaryFixedDim,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(8),
                  ),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.star, size: 14, color: AppColors.onPrimaryFixed),
                    SizedBox(width: 2),
                    Text(
                      'Premium',
                      style: TextStyle(
                        fontSize: 12,
                        height: 16 / 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.onPrimaryFixed,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
          ],
          _HeaderRow(produce: produce),
          const SizedBox(height: 16),
          const Divider(
            height: 1,
            thickness: 1,
            color: AppColors.surfaceContainerHigh,
          ),
          const SizedBox(height: 16),
          _DetailGrid(produce: produce),
          const SizedBox(height: 16),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _CardButton(
                  label: 'View Details',
                  filled: false,
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) =>
                          ProductDetailsScreen(product: produce.source),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _CardButton(
                  label: 'Request to Buy',
                  filled: true,
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) =>
                          BuyerRequestFormScreen(product: produce.source),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HeaderRow extends StatelessWidget {
  const _HeaderRow({required this.produce});

  final _Produce produce;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: produce.avatarColor,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  produce.avatarLetter,
                  style: TextStyle(
                    fontSize: 24,
                    height: 32 / 24,
                    fontWeight: FontWeight.w600,
                    color: produce.avatarTextColor,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      produce.names[0],
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 18,
                        height: 28 / 18,
                        fontWeight: FontWeight.w500,
                        color: AppColors.onSurface,
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
                            produce.location,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
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
            ],
          ),
        ),
        const SizedBox(width: 8),
        _GradeBadge(produce: produce),
      ],
    );
  }
}

class _GradeBadge extends StatelessWidget {
  const _GradeBadge({required this.produce});

  final _Produce produce;

  @override
  Widget build(BuildContext context) {
    final showIcon = produce.gradeVerified;
    final Color bg = produce.gradeVerified
        ? AppColors.primaryContainer
        : AppColors.surfaceContainerHigh;
    final Color fg = produce.gradeVerified
        ? AppColors.onPrimaryContainer
        : AppColors.onSurface;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showIcon) ...[
            const Icon(Icons.verified, size: 14, color: AppColors.onPrimaryContainer),
            const SizedBox(width: 2),
          ],
          Text(
            produce.grade,
            style: TextStyle(
              fontSize: 12,
              height: 16 / 12,
              fontWeight: FontWeight.w600,
              color: fg,
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailGrid extends StatelessWidget {
  const _DetailGrid({required this.produce});

  final _Produce produce;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _DetailCell(label: 'Product', value: produce.product),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _DetailCell(label: 'Quantity', value: produce.quantity),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _DetailCell(
                label: 'Asking Price',
                value: produce.price,
                emphasize: true,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _DetailCell(
                label: 'Market Ref',
                value: produce.marketRef,
                valueColor: AppColors.primary,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _DetailCell extends StatelessWidget {
  const _DetailCell({
    required this.label,
    required this.value,
    this.emphasize = false,
    this.valueColor,
  });

  final String label;
  final String value;
  final bool emphasize;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            height: 16 / 12,
            fontWeight: FontWeight.w500,
            color: AppColors.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: emphasize ? 20 : 16,
            height: emphasize ? 28 / 20 : 24 / 16,
            fontWeight: emphasize ? FontWeight.w600 : FontWeight.w500,
            color: valueColor ??
                (emphasize ? AppColors.secondary : AppColors.onSurface),
          ),
        ),
      ],
    );
  }
}

class _CardButton extends StatelessWidget {
  const _CardButton({
    required this.label,
    required this.filled,
    this.onTap,
  });

  final String label;
  final bool filled;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final Color bg = filled ? AppColors.primary : AppColors.surfaceContainer;
    final Color fg = filled ? AppColors.onPrimary : AppColors.primary;

    return Material(
      color: bg,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          height: 56,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: filled ? null : Border.all(color: AppColors.primary),
          ),
          child: Text(
            label,
            style: TextStyle(
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
