import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../main.dart';
import '../models/models.dart';
import '../services/api_scope.dart';
import '../services/session.dart';
import 'my_requests_screen.dart';

/// "Buyer Request Form" — a task-focused transactional sub-page where a buyer
/// finalizes an offer to a farmer. Matches the agritrust form design. The
/// navigation shell (bottom nav) is suppressed so the canvas stays focused.
/// When [product] is provided the form is pre-filled from that listing.
class BuyerRequestFormScreen extends StatelessWidget {
  const BuyerRequestFormScreen({super.key, this.product});

  static const double maxContentWidth = 768; // matches Tailwind's max-w-3xl

  /// The product being requested. Optional so the form can still be opened
  /// without a specific listing.
  final Product? product;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isDesktop = width >= 768;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        top: false,
        bottom: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(0, 24, 0, 24),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: maxContentWidth,
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: isDesktop ? 0 : 16,
                ),
                child: _RequestForm(
                  isDesktop: isDesktop,
                  product: product,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _RequestForm extends StatelessWidget {
  const _RequestForm({required this.isDesktop, this.product});

  final bool isDesktop;
  final Product? product;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const _BackBar(),
        const SizedBox(height: 24),
        Text(
          'Submit Request',
          style: GoogleFonts.inter(
            fontSize: 48,
            height: 56 / 48,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.02,
            color: AppColors.onBackground,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Review the details and finalize your offer to the farmer.',
          style: GoogleFonts.inter(
            fontSize: 16,
            height: 24 / 16,
            color: AppColors.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 32),
        _FormCard(isDesktop: isDesktop, product: product),
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
                'Back',
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

/// Level-1 elevation container holding the whole form. Owns the form state
/// (quantity/price/delivery) and submits the buyer request via the API.
class _FormCard extends StatefulWidget {
  const _FormCard({required this.isDesktop, this.product});

  final bool isDesktop;
  final Product? product;

  @override
  State<_FormCard> createState() => _FormCardState();
}

class _FormCardState extends State<_FormCard> {
  late final TextEditingController _quantityController;
  late final TextEditingController _priceController;
  final _dateController = TextEditingController();
  final _notesController = TextEditingController();

  late String _unit;
  String _deliveryPref = 'pickup';
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    final product = widget.product;
    _quantityController = TextEditingController(
      text: product == null ? '' : _num(product.quantity),
    );
    _priceController = TextEditingController(
      text: product == null ? '' : _num(product.price),
    );
    _unit = _normalizeUnit(product?.unit);
  }

  @override
  void dispose() {
    _quantityController.dispose();
    _priceController.dispose();
    _dateController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final product = widget.product;
    if (product == null) return;
    final user = AppSession.currentUser;
    if (user == null) return;

    final quantity = double.tryParse(_quantityController.text.trim());
    if (quantity == null || quantity <= 0) {
      _showMessage(context, 'Please enter a valid quantity.');
      return;
    }
    final offered = double.tryParse(_priceController.text.trim());

    setState(() => _submitting = true);
    try {
      await ApiScope.of(context).createRequest(
        buyerId: user.id,
        productId: product.id,
        quantity: quantity,
        offeredPrice: offered,
      );
      if (!mounted) return;
      _showMessage(context, 'Buyer request submitted.');
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const MyRequestsScreen()),
      );
    } catch (_) {
      if (mounted) {
        setState(() => _submitting = false);
        _showMessage(context, 'Could not submit the request. Please try again.');
      }
    }
  }

  void _showMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = widget.isDesktop;
    return Container(
      padding: EdgeInsets.all(isDesktop ? 24 : 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
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
          _PrefilledSection(isDesktop: isDesktop, product: widget.product),
          const SizedBox(height: 24),
          _InputSection(
            isDesktop: isDesktop,
            quantityController: _quantityController,
            priceController: _priceController,
            dateController: _dateController,
            unit: _unit,
            onUnitChanged: (v) => setState(() => _unit = v),
            deliveryPref: _deliveryPref,
            onDeliveryChanged: (v) => setState(() => _deliveryPref = v),
            notesController: _notesController,
          ),
          const SizedBox(height: 24),
          _SubmitButton(submitting: _submitting, onTap: _submit),
        ],
      ),
    );
  }
}

/// The pre-filled Selected Farmer + Product cards.
class _PrefilledSection extends StatelessWidget {
  const _PrefilledSection({required this.isDesktop, this.product});

  final bool isDesktop;
  final Product? product;

  @override
  Widget build(BuildContext context) {
    final p = product;
    final farmerName = (p != null && (p.farmerName?.isNotEmpty ?? false))
        ? p.farmerName!
        : 'Farmer';
    final farmerLocation = (p != null && (p.location?.isNotEmpty ?? false))
        ? p.location!
        : 'Location not set';
    final productName = (p != null && (p.productName.isNotEmpty))
        ? p.productName
        : 'Farm Produce';
    final productSubtitle = p == null
        ? 'Grade A • Organic'
        : '${p.unit} • ${_num(p.quantity)} ${p.unit}';

    final farmerTile = _PrefilledTile(
      icon: Icons.person,
      iconBoxColor: AppColors.secondaryContainer,
      iconColor: AppColors.onSecondaryContainer,
      iconRadius: 999,
      title: farmerName,
      subtitle: farmerLocation,
    );
    final productTile = _PrefilledTile(
      icon: Icons.spa,
      iconBoxColor: AppColors.tertiaryContainer,
      iconColor: AppColors.onTertiaryContainer,
      iconRadius: 8,
      title: productName,
      subtitle: productSubtitle,
    );

    if (isDesktop) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: _PrefilledField(label: 'Selected Farmer', child: farmerTile)),
          const SizedBox(width: 24),
          Expanded(child: _PrefilledField(label: 'Product', child: productTile)),
        ],
      );
    }
    return Column(
      children: [
        _PrefilledField(label: 'Selected Farmer', child: farmerTile),
        const SizedBox(height: 16),
        _PrefilledField(label: 'Product', child: productTile),
      ],
    );
  }
}

class _PrefilledField extends StatelessWidget {
  const _PrefilledField({required this.label, required this.child});

  final String label;
  final Widget child;

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
            color: AppColors.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 4),
        child,
      ],
    );
  }
}

class _PrefilledTile extends StatelessWidget {
  const _PrefilledTile({
    required this.icon,
    required this.iconBoxColor,
    required this.iconColor,
    required this.iconRadius,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final Color iconBoxColor;
  final Color iconColor;
  final double iconRadius;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: iconBoxColor,
              shape: iconRadius == 999
                  ? BoxShape.circle
                  : BoxShape.rectangle,
              borderRadius: iconRadius == 999
                  ? null
                  : BorderRadius.circular(iconRadius),
            ),
            child: Icon(icon, size: 22, color: iconColor),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    height: 24 / 16,
                    fontWeight: FontWeight.w500,
                    color: AppColors.onSurface,
                  ),
                ),
                Text(
                  subtitle,
                  maxLines: 1,
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
      ),
    );
  }
}

/// The interactive input fields section.
class _InputSection extends StatelessWidget {
  const _InputSection({
    required this.isDesktop,
    required this.quantityController,
    required this.priceController,
    required this.dateController,
    required this.unit,
    required this.onUnitChanged,
    required this.deliveryPref,
    required this.onDeliveryChanged,
    required this.notesController,
  });

  final bool isDesktop;
  final TextEditingController quantityController;
  final TextEditingController priceController;
  final TextEditingController dateController;
  final String unit;
  final ValueChanged<String> onUnitChanged;
  final String deliveryPref;
  final ValueChanged<String> onDeliveryChanged;
  final TextEditingController notesController;

  @override
  Widget build(BuildContext context) {
    final quantity = _QuantityField(
      controller: quantityController,
      unit: unit,
      onUnitChanged: onUnitChanged,
    );
    final price = _PriceField(controller: priceController);
    final date = _DateField(controller: dateController);
    final delivery = _DeliveryPreference(
      value: deliveryPref,
      onChanged: onDeliveryChanged,
    );
    final notes = _NotesField(controller: notesController);

    if (isDesktop) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: quantity),
              const SizedBox(width: 24),
              Expanded(child: price),
            ],
          ),
          const SizedBox(height: 24),
          date,
          const SizedBox(height: 24),
          delivery,
          const SizedBox(height: 24),
          notes,
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        quantity,
        const SizedBox(height: 16),
        price,
        const SizedBox(height: 16),
        date,
        const SizedBox(height: 16),
        delivery,
        const SizedBox(height: 16),
        notes,
      ],
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Text(
        label,
        style: GoogleFonts.inter(
          fontSize: 14,
          height: 20 / 14,
          fontWeight: FontWeight.w500,
          color: AppColors.onBackground,
        ),
      ),
    );
  }
}

class _QuantityField extends StatelessWidget {
  const _QuantityField({
    required this.controller,
    required this.unit,
    required this.onUnitChanged,
  });

  final TextEditingController controller;
  final String unit;
  final ValueChanged<String> onUnitChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _FieldLabel('Required Quantity'),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: _inputDecoration(hint: '0.00'),
              ),
            ),
            const SizedBox(width: 8),
            DropdownButton<String>(
              value: unit,
              isDense: true,
              underline: const SizedBox.shrink(),
              style: GoogleFonts.inter(
                fontSize: 14,
                height: 20 / 14,
                color: AppColors.onSurfaceVariant,
              ),
              items: const [
                DropdownMenuItem(value: 'Quintals', child: Text('Quintals')),
                DropdownMenuItem(value: 'Tons', child: Text('Tons')),
                DropdownMenuItem(value: 'KG', child: Text('KG')),
              ],
              onChanged: (v) {
                if (v != null) onUnitChanged(v);
              },
            ),
          ],
        ),
      ],
    );
  }
}

class _PriceField extends StatelessWidget {
  const _PriceField({required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _FieldLabel('Offered Price (per unit)'),
        TextField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: _inputDecoration(
            hint: '0.00',
            prefix: const Padding(
              padding: EdgeInsets.only(right: 4),
              child: Text(
                '₹',
                style: TextStyle(
                  fontSize: 16,
                  height: 24 / 16,
                  color: AppColors.onSurfaceVariant,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _DateField extends StatelessWidget {
  const _DateField({required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _FieldLabel('Required By Date'),
        TextField(
          controller: controller,
          readOnly: true,
          onTap: () => _pickDate(context),
          decoration: _inputDecoration(
            hint: 'Select a date',
            prefixIcon: const Icon(
              Icons.calendar_month,
              color: AppColors.onSurfaceVariant,
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _pickDate(BuildContext context) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now.add(const Duration(days: 7)),
      firstDate: now,
      lastDate: now.add(const Duration(days: 365 * 2)),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(primary: AppColors.primary),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      controller.text =
          '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
    }
  }
}

class _DeliveryPreference extends StatelessWidget {
  const _DeliveryPreference({required this.value, required this.onChanged});

  final String value;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(bottom: 8),
          child: _FieldLabel('Delivery/Pickup Preference'),
        ),
        Row(
          children: [
            Expanded(
              child: _PrefCard(
                icon: Icons.local_shipping,
                label: 'I will arrange pickup',
                selected: value == 'pickup',
                onTap: () => onChanged('pickup'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _PrefCard(
                icon: Icons.location_on,
                label: 'Deliver to my location',
                selected: value == 'delivery',
                onTap: () => onChanged('delivery'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _PrefCard extends StatelessWidget {
  const _PrefCard({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? AppColors.primaryFixedDim : AppColors.surface,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: selected ? AppColors.primary : AppColors.outlineVariant,
            ),
          ),
          child: Column(
            children: [
              Icon(icon, size: 24, color: selected ? AppColors.primary : AppColors.onSurfaceVariant),
              const SizedBox(height: 8),
              Text(
                label,
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  height: 20 / 14,
                  fontWeight: FontWeight.w500,
                  color: selected ? AppColors.onSurface : AppColors.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NotesField extends StatelessWidget {
  const _NotesField({required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _FieldLabel('Additional Notes (Optional)'),
        TextField(
          controller: controller,
          maxLines: 4,
          decoration: _inputDecoration(
            hint: 'Any specific requirements regarding quality, packaging, etc.',
          ),
        ),
      ],
    );
  }
}

InputDecoration _inputDecoration({
  String? hint,
  Widget? prefix,
  Widget? prefixIcon,
}) {
  return InputDecoration(
    hintText: hint,
    hintStyle: GoogleFonts.inter(
      fontSize: 16,
      height: 24 / 16,
      color: AppColors.onSurfaceVariant,
    ),
    prefixIcon: prefixIcon,
    prefix: prefix,
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    filled: true,
    fillColor: AppColors.surface,
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
  );
}

class _SubmitButton extends StatelessWidget {
  const _SubmitButton({required this.submitting, required this.onTap});

  final bool submitting;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: SizedBox(
        width: double.infinity,
        child: FilledButton.icon(
          onPressed: submitting ? null : onTap,
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.onPrimary,
            minimumSize: const Size.fromHeight(56),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(999),
            ),
            shadowColor: const Color(0x0D059669),
            elevation: 1,
          ),
          icon: submitting
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.onPrimary,
                  ),
                )
              : const Icon(Icons.send, size: 20),
          label: Text(
            submitting ? 'Submitting...' : 'Submit Request',
            style: GoogleFonts.inter(
              fontSize: 14,
              height: 20 / 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}

/// Formats a number for display, dropping trailing decimals on whole numbers.
String _num(num value) {
  if (value == value.roundToDouble()) {
    return value.toStringAsFixed(0);
  }
  return value.toString();
}

/// Maps a free-form product unit onto one of the dropdown options
/// (Quintals / Tons / KG), defaulting to Quintals when unknown.
String _normalizeUnit(String? unit) {
  if (unit == null || unit.isEmpty) return 'Quintals';
  final u = unit.toLowerCase();
  if (u == 'kg' || u == 'kgs' || u == 'kilograms') return 'KG';
  if (u == 'ton' || u == 'tons' || u == 'tonnes') return 'Tons';
  if (u.startsWith('q')) return 'Quintals';
  return 'Quintals';
}
