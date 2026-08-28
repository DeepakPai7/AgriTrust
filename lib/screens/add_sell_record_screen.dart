import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../main.dart';

/// "Add Sell Record" form sub-page, matching the design:
/// sticky app bar, sectioned form cards, and a sticky bottom action bar.
class AddSellRecordScreen extends StatelessWidget {
  const AddSellRecordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _TopBar(),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 32, 16, 24),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _CropDetailsSection(),
              SizedBox(height: 32),
              _LogisticsSection(),
              SizedBox(height: 32),
              _PhotosSection(),
              SizedBox(height: 32),
              _NotesSection(),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const _BottomActionBar(),
    );
  }
}

class _TopBar extends StatelessWidget implements PreferredSizeWidget {
  @override
  Size get preferredSize => const Size.fromHeight(64);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      toolbarHeight: 64,
      backgroundColor: AppColors.surface,
      elevation: 0,
      scrolledUnderElevation: 0,
      surfaceTintColor: Colors.transparent,
      flexibleSpace: const DecoratedBox(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Color(0x0D059669),
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
      ),
      leadingWidth: 64,
      leading: IconButton(
        icon: const Icon(
          Icons.arrow_back,
          color: AppColors.onSurface,
        ),
        onPressed: () => Navigator.of(context).maybePop(),
      ),
      title: Text(
        'Add Sell Record',
        style: GoogleFonts.inter(
          fontSize: 24,
          height: 32 / 24,
          fontWeight: FontWeight.w600,
          color: AppColors.onSurface,
        ),
      ),
    );
  }
}

/// A white rounded section card.
class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
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
          Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 14,
              height: 20 / 14,
              fontWeight: FontWeight.w500,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 8),
          for (var i = 0; i < children.length; i++) ...[
            if (i > 0) const SizedBox(height: 16),
            children[i],
          ],
        ],
      ),
    );
  }
}

/// Shared label for a form field.
class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Text(
        text,
        style: GoogleFonts.inter(
          fontSize: 14,
          height: 20 / 14,
          fontWeight: FontWeight.w500,
          color: AppColors.onSurfaceVariant,
        ),
      ),
    );
  }
}

/// Base input decoration for the 56px-tall text fields.
InputDecoration _inputDecoration({String? hint, String? prefix}) {
  return InputDecoration(
    hintText: hint,
    hintStyle: GoogleFonts.inter(
      fontSize: 16,
      color: const Color(0xFF6D7A72),
    ),
    prefixText: prefix,
    prefixStyle: GoogleFonts.inter(
      fontSize: 16,
      color: AppColors.onSurfaceVariant,
    ),
    prefixIconColor: AppColors.onSurfaceVariant,
    filled: true,
    fillColor: AppColors.surface,
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
  );
}

/// A dropdown styled like the design selects (chevron on the right).
class _SelectField extends StatelessWidget {
  const _SelectField({
    required this.label,
    required this.hint,
    required this.items,
  });

  final String label;
  final String hint;
  final List<String> items;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _FieldLabel(label),
        DropdownButtonFormField<String>(
          isExpanded: true,
          decoration: _inputDecoration(hint: hint),
          hint: Text(
            hint,
            style: GoogleFonts.inter(
              fontSize: 16,
              color: const Color(0xFF6D7A72),
            ),
          ),
          icon: const Icon(
            Icons.expand_more,
            color: AppColors.outlineVariant,
          ),
          borderRadius: BorderRadius.circular(8),
          style: GoogleFonts.inter(
            fontSize: 16,
            color: AppColors.onSurface,
          ),
          items: [
            for (final item in items)
              DropdownMenuItem(
                value: item,
                child: Text(item, overflow: TextOverflow.ellipsis),
              ),
          ],
          onChanged: (_) {},
        ),
      ],
    );
  }
}

/// A plain text field.
class _TextField extends StatelessWidget {
  const _TextField({
    required this.label,
    this.hint,
    this.prefix,
    this.keyboardType,
    this.suffix,
    this.maxLines = 1,
  });

  final String label;
  final String? hint;
  final String? prefix;
  final TextInputType? keyboardType;
  final Widget? suffix;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    final deco = _inputDecoration(hint: hint, prefix: prefix);
    final border = deco.border;
    final enabledBorder = deco.enabledBorder;
    final focusedBorder = deco.focusedBorder;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _FieldLabel(label),
        TextField(
          keyboardType: keyboardType,
          maxLines: maxLines,
          style: GoogleFonts.inter(
            fontSize: 16,
            color: AppColors.onSurface,
          ),
          decoration: deco.copyWith(
            suffixIcon: suffix,
            border: border,
            enabledBorder: enabledBorder,
            focusedBorder: focusedBorder,
            contentPadding: maxLines > 1
                ? const EdgeInsets.all(16)
                : const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
      ],
    );
  }
}

class _CropDetailsSection extends StatelessWidget {
  const _CropDetailsSection();

  @override
  Widget build(BuildContext context) {
    return const _SectionCard(
      title: 'CROP DETAILS',
      children: [
        _SelectField(
          label: 'Product / Crop Name',
          hint: 'Select a crop...',
          items: [
            'Wheat',
            'Rice (Paddy)',
            'Cotton',
            'Jalapeño Peppers',
          ],
        ),
        _QuantityUnitRow(),
        _TextField(
          label: 'Expected Price (per unit)',
          hint: '0.00',
          prefix: '₹',
          keyboardType: TextInputType.number,
        ),
        _SelectField(
          label: 'Quality / Grade',
          hint: 'Select grade...',
          items: [
            'Grade A+ (Export Quality)',
            'Grade A (Premium)',
            'Grade B (Standard)',
            'Grade C (Processing)',
          ],
        ),
      ],
    );
  }
}

class _QuantityUnitRow extends StatelessWidget {
  const _QuantityUnitRow();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _TextField(
            label: 'Quantity',
            hint: 'e.g. 50',
            keyboardType: TextInputType.number,
          ),
        ),
        const SizedBox(width: 8),
        SizedBox(
          width: 100,
          child: _SelectField(
            label: 'Unit',
            hint: 'Unit',
            items: const ['Quintal', 'KG', 'Tons'],
          ),
        ),
      ],
    );
  }
}

class _LogisticsSection extends StatelessWidget {
  const _LogisticsSection();

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: 'LOGISTICS',
      children: [
        _TextField(
          label: 'Harvest / Availability Date',
          keyboardType: TextInputType.datetime,
          suffix: const Icon(
            Icons.calendar_month,
            color: AppColors.outline,
          ),
        ),
        _LocationField(),
      ],
    );
  }
}

class _LocationField extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _FieldLabel('Pickup Location'),
        TextField(
          style: GoogleFonts.inter(
            fontSize: 16,
            color: AppColors.onSurface,
          ),
          decoration: _inputDecoration(
            hint: 'Enter farm or warehouse address',
          ).copyWith(
            suffixIcon: IconButton(
              icon: const Icon(
                Icons.my_location,
                color: AppColors.primary,
              ),
              onPressed: () {},
            ),
          ),
        ),
      ],
    );
  }
}

class _PhotosSection extends StatelessWidget {
  const _PhotosSection();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
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
          Row(
            children: [
              Text(
                'CROP PHOTOS',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.primary,
                ),
              ),
              const Spacer(),
              Flexible(
                child: Text(
                  '1/4 Uploaded',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Expanded(child: _PhotoPreview()),
              const SizedBox(width: 8),
              Expanded(child: _UploadTile()),
            ],
          ),
        ],
      ),
    );
  }
}

class _PhotoPreview extends StatelessWidget {
  const _PhotoPreview();

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.outlineVariant),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF7FCB8F), Color(0xFF3A8F6A)],
          ),
        ),
        child: Stack(
          children: [
            const Center(
              child: Icon(
                Icons.eco,
                size: 44,
                color: Colors.white70,
              ),
            ),
            Positioned(
              top: 8,
              right: 8,
              child: GestureDetector(
                onTap: () {},
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: const BoxDecoration(
                    color: AppColors.error,
                    shape: BoxShape.circle,
                    boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 4)],
                  ),
                  child: const Icon(
                    Icons.close,
                    size: 18,
                    color: AppColors.onError,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _UploadTile extends StatelessWidget {
  const _UploadTile();

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {},
          borderRadius: BorderRadius.circular(8),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: AppColors.outlineVariant,
                width: 2,
              ),
            ),
            child: const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.add_a_photo,
                  size: 48,
                  color: AppColors.outline,
                ),
                SizedBox(height: 8),
                Text(
                  'Upload Photo',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.onSurfaceVariant,
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

class _NotesSection extends StatelessWidget {
  const _NotesSection();

  @override
  Widget build(BuildContext context) {
    return const _SectionCard(
      title: 'ADDITIONAL DETAILS',
      children: [
        _TextField(
          label: 'Notes (Optional)',
          hint: 'Add any specific details about crop condition, packaging, or payment terms...',
          maxLines: 3,
        ),
      ],
    );
  }
}

class _BottomActionBar extends StatelessWidget {
  const _BottomActionBar();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.surfaceContainerHigh)),
        boxShadow: [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 20,
            offset: Offset(0, -10),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: SizedBox(
            height: 56,
            child: Material(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(12),
              elevation: 4,
              child: InkWell(
                onTap: () {},
                borderRadius: BorderRadius.circular(12),
                child: Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.check_circle,
                        color: AppColors.onPrimary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'List for Sale',
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          height: 24 / 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.onPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
