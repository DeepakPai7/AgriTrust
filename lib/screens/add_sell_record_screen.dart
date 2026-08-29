import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

import '../main.dart';
import '../services/api_scope.dart';
import '../services/api_service.dart';
import '../services/session.dart';

/// "Add Sell Record" form sub-page, matching the design:
/// sticky app bar, sectioned form cards, and a sticky bottom action bar.
/// Wire the form fields (including a date picker and a photo picker) to the
/// backend [ApiService.createProduct] call.
class AddSellRecordScreen extends StatefulWidget {
  const AddSellRecordScreen({super.key});

  @override
  State<AddSellRecordScreen> createState() => _AddSellRecordScreenState();
}

class _AddSellRecordScreenState extends State<AddSellRecordScreen> {
  static const int _maxPhotos = 4;

  final _cropController = TextEditingController();
  final _quantityController = TextEditingController();
  final _priceController = TextEditingController();
  final _locationController = TextEditingController();
  final _notesController = TextEditingController();
  final _dateController = TextEditingController();

  final List<Uint8List> _photos = [];

  String? _unit;
  String? _grade;
  DateTime? _harvestDate;
  bool _submitting = false;

  @override
  void dispose() {
    _cropController.dispose();
    _quantityController.dispose();
    _priceController.dispose();
    _locationController.dispose();
    _notesController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  static String _two(int v) => v.toString().padLeft(2, '0');

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _harvestDate ?? now,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 5),
    );
    if (picked != null) {
      setState(() {
        _harvestDate = picked;
        _dateController.text =
            '${_two(picked.day)} / ${_two(picked.month)} / ${picked.year}';
      });
    }
  }

  Future<void> _pickPhoto() async {
    try {
      final file = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        maxWidth: 1600,
        imageQuality: 80,
      );
      if (file == null) return;
      final bytes = await file.readAsBytes();
      if (!mounted) return;
      setState(() {
        if (_photos.length < _maxPhotos) _photos.add(bytes);
      });
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not pick a photo')),
        );
      }
    }
  }

  void _removePhoto(int index) {
    setState(() => _photos.removeAt(index));
  }

  Future<void> _submit() async {
    final crop = _cropController.text.trim();
    final quantity = double.tryParse(_quantityController.text.trim());
    final unit = _unit;
    final price = double.tryParse(_priceController.text.trim());

    if (crop.isEmpty || quantity == null || unit == null || price == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill in crop name, quantity, unit and price'),
        ),
      );
      return;
    }

    setState(() => _submitting = true);
    try {
      await ApiScope.of(context).createProduct(
            farmerId: AppSession.currentUser?.id ?? 0,
            productName: crop,
            quantity: quantity,
            unit: unit,
            price: price,
            location: _locationController.text.trim().isNotEmpty
                ? _locationController.text.trim()
                : null,
            harvestDate: _harvestDate?.toIso8601String(),
            notes: _notesController.text.trim().isNotEmpty
                ? _notesController.text.trim()
                : null,
            photo: _photos.isNotEmpty ? base64Encode(_photos.first) : null,
          );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Product listed successfully')),
      );
      Navigator.of(context).pop();
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _submitting = false);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.message)));
    } catch (_) {
      if (!mounted) return;
      setState(() => _submitting = false);
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Could not list product')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const _TopBar(),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 32, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _CropDetailsSection(
                cropController: _cropController,
                quantityController: _quantityController,
                priceController: _priceController,
                unit: _unit,
                grade: _grade,
                onUnitChanged: (v) => setState(() => _unit = v),
                onGradeChanged: (v) => setState(() => _grade = v),
              ),
              const SizedBox(height: 32),
              _LogisticsSection(
                dateController: _dateController,
                locationController: _locationController,
                onPickDate: _pickDate,
              ),
              const SizedBox(height: 32),
              _PhotosSection(
                photos: _photos,
                onPickPhoto: _pickPhoto,
                onRemove: _removePhoto,
              ),
              const SizedBox(height: 32),
              _NotesSection(notesController: _notesController),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _BottomActionBar(
        submitting: _submitting,
        onTap: _submit,
      ),
    );
  }
}

class _TopBar extends StatelessWidget implements PreferredSizeWidget {
  const _TopBar();

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
    this.value,
    this.onChanged,
  });

  final String label;
  final String hint;
  final List<String> items;
  final String? value;
  final ValueChanged<String?>? onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _FieldLabel(label),
        DropdownButtonFormField<String>(
          isExpanded: true,
          initialValue: value,
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
          onChanged: onChanged,
        ),
      ],
    );
  }
}

/// A plain text field.
class _TextField extends StatelessWidget {
  const _TextField({
    required this.label,
    this.controller,
    this.hint,
    this.prefix,
    this.keyboardType,
    this.maxLines = 1,
  });

  final String label;
  final TextEditingController? controller;
  final String? hint;
  final String? prefix;
  final TextInputType? keyboardType;
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
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          style: GoogleFonts.inter(
            fontSize: 16,
            color: AppColors.onSurface,
          ),
          decoration: deco.copyWith(
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
  const _CropDetailsSection({
    required this.cropController,
    required this.quantityController,
    required this.priceController,
    required this.unit,
    required this.grade,
    required this.onUnitChanged,
    required this.onGradeChanged,
  });

  final TextEditingController cropController;
  final TextEditingController quantityController;
  final TextEditingController priceController;
  final String? unit;
  final String? grade;
  final ValueChanged<String?> onUnitChanged;
  final ValueChanged<String?> onGradeChanged;

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: 'CROP DETAILS',
      children: [
        _SelectField(
          label: 'Product / Crop Name',
          hint: 'Select a crop...',
          value: cropController.text.isEmpty ? null : cropController.text,
          onChanged: (v) {
            if (v != null) cropController.text = v;
          },
          items: const [
            'Wheat',
            'Rice (Paddy)',
            'Cotton',
            'Jalapeño Peppers',
          ],
        ),
        _QuantityUnitRow(
          quantityController: quantityController,
          unit: unit,
          onUnitChanged: onUnitChanged,
        ),
        _TextField(
          label: 'Expected Price (per unit)',
          controller: priceController,
          hint: '0.00',
          prefix: '₹',
          keyboardType: TextInputType.number,
        ),
        _SelectField(
          label: 'Quality / Grade',
          hint: 'Select grade...',
          value: grade,
          onChanged: onGradeChanged,
          items: const [
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
  const _QuantityUnitRow({
    required this.quantityController,
    required this.unit,
    required this.onUnitChanged,
  });

  final TextEditingController quantityController;
  final String? unit;
  final ValueChanged<String?> onUnitChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _TextField(
            label: 'Quantity',
            controller: quantityController,
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
            value: unit,
            onChanged: onUnitChanged,
            items: const ['Quintal', 'KG', 'Tons'],
          ),
        ),
      ],
    );
  }
}

class _LogisticsSection extends StatelessWidget {
  const _LogisticsSection({
    required this.dateController,
    required this.locationController,
    required this.onPickDate,
  });

  final TextEditingController dateController;
  final TextEditingController locationController;
  final VoidCallback onPickDate;

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: 'LOGISTICS',
      children: [
        _DateField(
          controller: dateController,
          onTap: onPickDate,
        ),
        _LocationField(controller: locationController),
      ],
    );
  }
}

class _DateField extends StatelessWidget {
  const _DateField({
    required this.controller,
    required this.onTap,
  });

  final TextEditingController controller;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _FieldLabel('Harvest / Availability Date'),
        GestureDetector(
          onTap: onTap,
          child: AbsorbPointer(
            child: TextField(
              controller: controller,
              readOnly: true,
              style: GoogleFonts.inter(
                fontSize: 16,
                color: AppColors.onSurface,
              ),
              decoration: _inputDecoration().copyWith(
                suffixIcon: const Icon(
                  Icons.calendar_month,
                  color: AppColors.outline,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _LocationField extends StatelessWidget {
  const _LocationField({required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _FieldLabel('Pickup Location'),
        TextField(
          controller: controller,
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
  const _PhotosSection({
    required this.photos,
    required this.onPickPhoto,
    required this.onRemove,
  });

  final List<Uint8List> photos;
  final VoidCallback onPickPhoto;
  final ValueChanged<int> onRemove;

  @override
  Widget build(BuildContext context) {
    const maxPhotos = 4;
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
                  '${photos.length}/$maxPhotos Uploaded',
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
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            children: [
              for (var i = 0; i < photos.length; i++)
                _PhotoPreview(
                  bytes: photos[i],
                  onRemove: () => onRemove(i),
                ),
              if (photos.length < maxPhotos)
                _UploadTile(onTap: onPickPhoto),
            ],
          ),
        ],
      ),
    );
  }
}

class _PhotoPreview extends StatelessWidget {
  const _PhotoPreview({required this.bytes, required this.onRemove});

  final Uint8List bytes;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.memory(
              bytes,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => Container(
                color: AppColors.surfaceContainerHigh,
                child: const Icon(Icons.broken_image, color: AppColors.outline),
              ),
            ),
            Positioned(
              top: 8,
              right: 8,
              child: GestureDetector(
                onTap: onRemove,
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
  const _UploadTile({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
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
  const _NotesSection({required this.notesController});

  final TextEditingController notesController;

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: 'ADDITIONAL DETAILS',
      children: [
        _TextField(
          label: 'Notes (Optional)',
          controller: notesController,
          hint: 'Add any specific details about crop condition, packaging, or payment terms...',
          maxLines: 3,
        ),
      ],
    );
  }
}

class _BottomActionBar extends StatelessWidget {
  const _BottomActionBar({required this.submitting, required this.onTap});

  final bool submitting;
  final VoidCallback onTap;

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
                onTap: submitting ? null : onTap,
                borderRadius: BorderRadius.circular(12),
                child: Center(
                  child: submitting
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: AppColors.onPrimary,
                          ),
                        )
                      : Row(
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
