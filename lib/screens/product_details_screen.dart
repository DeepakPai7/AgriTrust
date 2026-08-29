import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../main.dart';
import '../models/models.dart';
import 'buyer_request_form_screen.dart';

/// Product (Listing) Details screen: a task-focused sub-page showing a single
/// consignment with the produce photo, full listing details and the farmer
/// profile. Data comes from the [product] passed in (from the marketplace).
class ProductDetailsScreen extends StatelessWidget {
  const ProductDetailsScreen({super.key, required this.product});

  /// The product whose listing is being viewed.
  final Product product;

  static const double maxContentWidth = 1280; // matches Tailwind's max-w-7xl

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isDesktop = width >= 768;

    return Scaffold(
      backgroundColor: AppColors.background,
      // Mobile-only fixed action bar (md:hidden in the design).
      bottomNavigationBar: isDesktop ? null : _MobileActionBar(product: product),
      body: SafeArea(
        top: false,
        bottom: false,
        child: SingleChildScrollView(
          padding: EdgeInsets.only(
            top: 24,
            bottom: isDesktop ? 64 : 96,
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: maxContentWidth,
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: isDesktop ? 64 : 16,
                ),
                child: _DetailsBody(product: product),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Decodes a base64 image payload into bytes, or null when absent/invalid.
Uint8List? _decodePhoto(String? data) {
  if (data == null || data.isEmpty) return null;
  try {
    return base64Decode(data);
  } catch (_) {
    return null;
  }
}

/// Formats an ISO date string into a friendly "12 Oct 2023" style label,
/// returning the raw input when it cannot be parsed.
String _formatDate(String? value) {
  if (value == null || value.isEmpty) return '—';
  final parsed = DateTime.tryParse(value);
  if (parsed == null) return value;
  const months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];
  return '${parsed.day} ${months[parsed.month - 1]} ${parsed.year}';
}

/// Formats a number with thousands separators, dropping trailing decimals when
/// the value is a whole number.
String _formatNumber(num value) {
  final text = value.toStringAsFixed(value % 1 == 0 ? 0 : 2);
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

class _DetailsBody extends StatelessWidget {
  const _DetailsBody({required this.product});

  final Product product;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isDesktop = width >= 768;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const _ContextualHeader(),
        const SizedBox(height: 16),
        _HeroImage(photoData: _decodePhoto(product.photo)),
        const SizedBox(height: 16),
        _HeaderInfo(product: product),
        const SizedBox(height: 32),
        if (isDesktop)
          _DesktopSplit(product: product)
        else
          _MobileStack(product: product),
      ],
    );
  }
}

/// Back + title + bookmark/share sub-page header.
class _ContextualHeader extends StatelessWidget {
  const _ContextualHeader();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        InkWell(
          onTap: () => Navigator.of(context).maybePop(),
          borderRadius: BorderRadius.circular(999),
          child: const Padding(
            padding: EdgeInsets.all(8),
            child: Icon(
              Icons.arrow_back,
              color: AppColors.onSurface,
            ),
          ),
        ),
        const SizedBox(width: 16),
        Flexible(
          child: Text(
            'Listing Details',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.inter(
              fontSize: 24,
              height: 32 / 24,
              fontWeight: FontWeight.w600,
              color: AppColors.onSurface,
            ),
          ),
        ),
        const Spacer(),
        IconButton(
          onPressed: () {},
          icon: const Icon(Icons.bookmark_border, color: AppColors.primary),
        ),
        IconButton(
          onPressed: () {},
          icon: const Icon(
            Icons.share,
            color: AppColors.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class _HeroImage extends StatelessWidget {
  const _HeroImage({required this.photoData});

  final Uint8List? photoData;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isDesktop = width >= 768;

    return Container(
      height: isDesktop ? 384 : 256,
      clipBehavior: Clip.antiAlias,
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
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (photoData != null)
            Image.memory(photoData!, fit: BoxFit.cover)
          else ...[
            // Decorative gradient placeholder in place of the produce photo.
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF7A4A2B),
                    Color(0xFFC96A2E),
                    Color(0xFFF2B880),
                  ],
                ),
              ),
            ),
            const Align(
              alignment: Alignment.center,
              child: Icon(
                Icons.inventory_2,
                size: 96,
                color: Colors.white70,
              ),
            ),
          ],
          Positioned(
            top: 16,
            left: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.secondaryContainer,
                borderRadius: BorderRadius.circular(999),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x0F000000),
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                'Grade A',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  height: 16 / 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.onSecondaryContainer,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HeaderInfo extends StatelessWidget {
  const _HeaderInfo({required this.product});

  final Product product;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isDesktop = width >= 768;

    final location = (product.location ?? '').isNotEmpty
        ? product.location!
        : 'Location not set';
    final title = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          product.productName,
          style: GoogleFonts.inter(
            fontSize: 32,
            height: 40 / 32,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.01,
            color: AppColors.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            const Icon(
              Icons.location_on,
              size: 18,
              color: AppColors.onSurfaceVariant,
            ),
            const SizedBox(width: 8),
            Text(
              location,
              style: const TextStyle(
                fontSize: 16,
                height: 24 / 16,
                color: AppColors.onSurfaceVariant,
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                '•',
                style: TextStyle(color: AppColors.onSurfaceVariant),
              ),
            ),
            Text(
              'ID: PRD-${product.id}',
              style: const TextStyle(
                fontSize: 16,
                height: 24 / 16,
                color: AppColors.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ],
    );

    final totalValue = product.price * product.quantity;
    final priceBlock = Column(
      crossAxisAlignment: isDesktop
          ? CrossAxisAlignment.end
          : CrossAxisAlignment.start,
      children: [
        Wrap(
          alignment: isDesktop
              ? WrapAlignment.end
              : WrapAlignment.start,
          crossAxisAlignment: WrapCrossAlignment.end,
          children: [
            Text(
              '₹ ${_formatNumber(product.price)}',
              style: GoogleFonts.inter(
                fontSize: 32,
                height: 40 / 32,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.01,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(width: 4),
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text(
                '/ ${product.unit}',
                style: const TextStyle(
                  fontSize: 16,
                  height: 24 / 16,
                  color: AppColors.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'Est. Total Value: ₹ ${_formatNumber(totalValue)}',
          style: GoogleFonts.inter(
            fontSize: 14,
            height: 20 / 14,
            fontWeight: FontWeight.w500,
            color: AppColors.tertiaryContainer,
          ),
        ),
      ],
    );

    if (!isDesktop) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          title,
          const SizedBox(height: 16),
          priceBlock,
        ],
      );
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(child: title),
        priceBlock,
      ],
    );
  }
}

/// Desktop: content (2/3) beside farmer panel (1/3).
class _DesktopSplit extends StatelessWidget {
  const _DesktopSplit({required this.product});

  final Product product;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 8,
          child: _LeftColumn(product: product),
        ),
        const SizedBox(width: 24),
        Expanded(
          flex: 4,
          child: _FarmerPanel(
            product: product,
            farmerName: product.farmerName,
            showBuyButton: true,
          ),
        ),
      ],
    );
  }
}

/// Mobile: stacked content then farmer panel.
class _MobileStack extends StatelessWidget {
  const _MobileStack({required this.product});

  final Product product;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _LeftColumn(product: product),
        const SizedBox(height: 24),
        _FarmerPanel(
          product: product,
          farmerName: product.farmerName,
          showBuyButton: false,
        ),
      ],
    );
  }
}

class _LeftColumn extends StatelessWidget {
  const _LeftColumn({required this.product});

  final Product product;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _ConsignmentDetailsCard(product: product),
        const SizedBox(height: 24),
        const _MarketInsightCard(),
      ],
    );
  }
}

class _ConsignmentDetailsCard extends StatelessWidget {
  const _ConsignmentDetailsCard({required this.product});

  final Product product;

  @override
  Widget build(BuildContext context) {
    final details = [
      (
        label: 'Available Qty',
        value: '${_formatNumber(product.quantity)} ${product.unit}',
      ),
      (label: 'Unit Price', value: '₹ ${_formatNumber(product.price)}'),
      (label: 'Listed', value: _formatDate(product.createdAt)),
      (
        label: 'Minimum Order',
        value: '1 ${product.unit}',
      ),
    ];

    final notes = (product.notes ?? '').isNotEmpty
        ? product.notes!
        : 'No additional description provided for this listing.';

    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const _SectionTitle(icon: Icons.inventory_2, title: 'Consignment Details'),
          const SizedBox(height: 16),
          LayoutBuilder(
            builder: (context, constraints) {
              final wide = constraints.maxWidth >= 640;
              final columns = wide ? 4 : 2;
              final gap = 16.0;
              final cellWidth =
                  (constraints.maxWidth - gap * (columns - 1)) / columns;
              return Wrap(
                spacing: gap,
                runSpacing: 16,
                children: [
                  for (final d in details)
                    SizedBox(
                      width: cellWidth,
                      child: _DetailItem(label: d.label, value: d.value),
                    ),
                ],
              );
            },
          ),
          const Divider(
            height: 32,
            color: AppColors.surfaceContainerHigh,
          ),
          Text(
            notes,
            style: const TextStyle(
              fontSize: 16,
              height: 24 / 16,
              color: AppColors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailItem extends StatelessWidget {
  const _DetailItem({required this.label, required this.value});

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
            color: AppColors.secondary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: GoogleFonts.inter(
            fontSize: 18,
            height: 28 / 18,
            fontWeight: FontWeight.w500,
            color: AppColors.onSurface,
          ),
        ),
      ],
    );
  }
}

class _MarketInsightCard extends StatelessWidget {
  const _MarketInsightCard();

  @override
  Widget build(BuildContext context) {
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const _SectionTitle(icon: Icons.insights, title: 'Market Insight'),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Expanded(
                child: Text(
                  'Regional Average Price',
                  style: TextStyle(
                    fontSize: 16,
                    height: 24 / 16,
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ),
              SizedBox(width: 12),
              Text(
                '₹ 1,920 / qtl',
                style: TextStyle(
                  fontSize: 16,
                  height: 24 / 16,
                  fontWeight: FontWeight.w500,
                  color: AppColors.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: const SizedBox(
              height: 4,
              child: Row(
                children: [
                  Expanded(
                    flex: 85,
                    child: ColoredBox(color: AppColors.primary),
                  ),
                  Expanded(
                    flex: 15,
                    child: ColoredBox(
                      color: AppColors.tertiaryContainer,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Expanded(
                child: Text(
                  'Listing: ₹ 1,850 (Below Avg)',
                  style: TextStyle(
                    fontSize: 14,
                    height: 20 / 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              ),
              SizedBox(width: 8),
              Text(
                'Market: ₹ 1,920',
                style: TextStyle(
                  fontSize: 14,
                  height: 20 / 14,
                  color: AppColors.tertiaryContainer,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLow,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: AppColors.outlineVariant.withValues(alpha: 0.2),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.lightbulb,
                  size: 20,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'This listing is priced approximately 3.6% below the current regional 7-day moving average, presenting a favorable buying opportunity.',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      height: 24 / 16,
                      color: AppColors.onSurfaceVariant,
                    ),
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

class _FarmerPanel extends StatelessWidget {
  const _FarmerPanel({
    required this.product,
    required this.farmerName,
    required this.showBuyButton,
  });

  final Product product;
  final String? farmerName;
  final bool showBuyButton;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _FarmerProfileCard(farmerName: farmerName),
        if (showBuyButton) ...[
          const SizedBox(height: 16),
          _CreateRequestButton(product: product),
        ],
        const SizedBox(height: 16),
        const _SecurityNote(),
      ],
    );
  }
}

class _FarmerProfileCard extends StatelessWidget {
  const _FarmerProfileCard({required this.farmerName});

  final String? farmerName;

  @override
  Widget build(BuildContext context) {
    final name = (farmerName ?? '').isNotEmpty ? farmerName! : 'Farmer';

    return _Card(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 96,
            height: 96,
            decoration: BoxDecoration(
              color: AppColors.surfaceContainer,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.surface, width: 2),
            ),
            alignment: Alignment.center,
            child: const Icon(
              Icons.person,
              size: 48,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            name,
            style: GoogleFonts.inter(
              fontSize: 24,
              height: 32 / 24,
              fontWeight: FontWeight.w600,
              color: AppColors.onSurface,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Verified Supplier',
            style: GoogleFonts.inter(
              fontSize: 16,
              height: 24 / 16,
              color: AppColors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 16),
          const Wrap(
            alignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 16,
            runSpacing: 8,
            children: [
              _ProfileStat(value: '—', label: 'Quality Rating'),
              SizedBox(
                height: 32,
                child: VerticalDivider(
                  width: 32,
                  color: AppColors.outlineVariant,
                  thickness: 1,
                ),
              ),
              _ProfileStat(value: '—', label: 'Successful Deals'),
            ],
          ),
          const SizedBox(height: 24),
          OutlinedButton.icon(
            onPressed: () {},
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(48),
              side: const BorderSide(color: AppColors.outline),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              foregroundColor: AppColors.primary,
            ),
            icon: const Icon(Icons.forum, size: 20),
            label: Text(
              'Contact Farmer',
              style: GoogleFonts.inter(
                fontSize: 14,
                height: 20 / 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileStat extends StatelessWidget {
  const _ProfileStat({
    required this.value,
    required this.label,
  });

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: GoogleFonts.inter(
            fontSize: 24,
            height: 32 / 24,
            fontWeight: FontWeight.w600,
            color: AppColors.onSurface,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 14,
            height: 20 / 14,
            color: AppColors.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class _CreateRequestButton extends StatelessWidget {
  const _CreateRequestButton({required this.product});

  final Product product;

  @override
  Widget build(BuildContext context) {
    return FilledButton.icon(
      onPressed: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => BuyerRequestFormScreen(product: product),
          ),
        );
      },
      style: FilledButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.onPrimary,
        minimumSize: const Size.fromHeight(56),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      icon: const Icon(Icons.add_shopping_cart, size: 20),
      label: Text(
        'Create Buyer Request',
        style: GoogleFonts.inter(
          fontSize: 14,
          height: 20 / 14,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

class _SecurityNote extends StatelessWidget {
  const _SecurityNote();

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(
          Icons.verified_user,
          size: 16,
          color: AppColors.onSurfaceVariant,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            'All transactions are secured by agritrust Escrow. Quality assessment reports available upon request initiation.',
            style: GoogleFonts.inter(
              fontSize: 12,
              height: 16 / 12,
              color: AppColors.onSurfaceVariant,
            ),
          ),
        ),
      ],
    );
  }
}

/// The mobile-only fixed bottom action bar.
class _MobileActionBar extends StatelessWidget {
  const _MobileActionBar({required this.product});

  final Product product;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: AppColors.surface,
          border: Border(top: BorderSide(color: AppColors.outlineVariant)),
          boxShadow: [
            BoxShadow(
              color: Color(0x0D000000),
              blurRadius: 10,
              offset: Offset(0, -4),
            ),
          ],
        ),
        child: _CreateRequestButton(product: product),
      ),
    );
  }
}

class _Card extends StatelessWidget {
  const _Card({required this.child, this.padding = const EdgeInsets.all(24)});

  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.surfaceContainerHigh),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D059669),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({
    required this.icon,
    required this.title,
  });

  final IconData icon;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 24, color: AppColors.primary),
        const SizedBox(width: 8),
        Flexible(
          child: Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.inter(
              fontSize: 24,
              height: 32 / 24,
              fontWeight: FontWeight.w600,
              color: AppColors.onSurface,
            ),
          ),
        ),
      ],
    );
  }
}
