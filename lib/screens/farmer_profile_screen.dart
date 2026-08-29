import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../main.dart';
import '../models/models.dart';
import '../screens/role_selection_screen.dart';
import '../services/api_scope.dart';
import '../services/session.dart';
import '../widgets/app_bars.dart';

/// Farmer Profile edit screen. Loads the logged-in farmer's details from the
/// backend, lets them edit the fields, saves changes back to the database, and
/// provides a logout action that returns to the role switcher.
class FarmerProfileScreen extends StatefulWidget {
  const FarmerProfileScreen({super.key});

  static const double maxContentWidth = 896; // matches Tailwind's max-w-4xl

  @override
  State<FarmerProfileScreen> createState() => _FarmerProfileScreenState();
}

class _FarmerProfileScreenState extends State<FarmerProfileScreen> {
  static const List<String> _languages = ['English', 'Kannada (ಕನ್ನಡ)'];
  static const List<String> _soilTypes = [
    'Red Soil',
    'Black Cotton Soil',
    'Alluvial Soil',
  ];
  static const List<String> _irrigationSources = [
    'Borewell',
    'Canal',
    'Rainfed',
  ];
  static const List<String> _landUnits = ['Acres', 'Guntas'];
  static const List<String> _settlementMethods = [
    'Direct Bank Transfer (NEFT/RTGS)',
    'UPI',
  ];

  late final Map<String, TextEditingController> _controllers = {
    for (final f in [
      'name',
      'phone',
      'address',
      'landArea',
      'bankAccount',
      'ifsc',
      'latitude',
      'longitude',
    ])
      f: TextEditingController(),
  };

  String _language = _languages.first;
  String _soilType = _soilTypes.first;
  String _irrigation = _irrigationSources.first;
  String _landUnit = _landUnits.first;
  String _settlementMethod = _settlementMethods.first;
  List<String> _crops = [];
  bool _loading = true;
  bool _saving = false;
  Object? _error;

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
    final id = AppSession.currentUser?.id ?? 1;
    try {
      final profile = await ApiScope.of(context).fetchFarmerProfile(id);
      _apply(profile);
      if (mounted) {
        setState(() => _loading = false);
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

  void _apply(FarmerProfile p) {
    _controllers['name']!.text = p.name;
    _controllers['phone']!.text = p.phone ?? '';
    _controllers['address']!.text = p.address ?? '';
    _controllers['landArea']!.text = p.landArea ?? '';
    _controllers['bankAccount']!.text = p.bankAccount ?? '';
    _controllers['ifsc']!.text = p.ifsc ?? '';
    _controllers['latitude']!.text = p.latitude ?? '';
    _controllers['longitude']!.text = p.longitude ?? '';
    _language = _firstOr(p.language, _languages, _languages.first);
    _soilType = _firstOr(p.soilType, _soilTypes, _soilTypes.first);
    _irrigation = _firstOr(p.irrigation, _irrigationSources, _irrigationSources.first);
    _landUnit = _firstOr(p.landUnit, _landUnits, _landUnits.first);
    _settlementMethod = _firstOr(p.settlementMethod, _settlementMethods, _settlementMethods.first);
    _crops = List.of(p.crops);
  }

  String _firstOr(String? value, List<String> options, String fallback) {
    if (value == null) return fallback;
    for (final o in options) {
      if (o.toLowerCase() == value.toLowerCase()) return o;
    }
    return fallback;
  }

  void _addCrop() {
    final controller = TextEditingController();
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Add Crop'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: _inputDecoration().copyWith(hintText: 'e.g. Wheat'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              final value = controller.text.trim();
              if (value.isNotEmpty && !_crops.contains(value)) {
                setState(() => _crops = [..._crops, value]);
              }
              Navigator.of(dialogContext).pop();
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _removeCrop(String crop) {
    setState(() => _crops.remove(crop));
  }

  Future<void> _save() async {
    final id = AppSession.currentUser?.id;
    if (id == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You must be logged in to save changes.')),
      );
      return;
    }
    setState(() => _saving = true);
    final profile = FarmerProfile(
      id: id,
      name: _controllers['name']!.text.trim(),
      email: '',
      phone: _controllers['phone']!.text.trim().isEmpty
          ? null
          : _controllers['phone']!.text.trim(),
      language: _language,
      address: _controllers['address']!.text.trim().isEmpty
          ? null
          : _controllers['address']!.text.trim(),
      landArea: _controllers['landArea']!.text.trim().isEmpty
          ? null
          : _controllers['landArea']!.text.trim(),
      landUnit: _landUnit,
      soilType: _soilType,
      crops: _crops,
      irrigation: _irrigation,
      latitude: _controllers['latitude']!.text.trim().isEmpty
          ? null
          : _controllers['latitude']!.text.trim(),
      longitude: _controllers['longitude']!.text.trim().isEmpty
          ? null
          : _controllers['longitude']!.text.trim(),
      bankAccount: _controllers['bankAccount']!.text.trim().isEmpty
          ? null
          : _controllers['bankAccount']!.text.trim(),
      ifsc: _controllers['ifsc']!.text.trim().isEmpty
          ? null
          : _controllers['ifsc']!.text.trim(),
      settlementMethod: _settlementMethod,
    );
    try {
      final updated = await ApiScope.of(context).updateFarmerProfile(id, profile);
      if (mounted) {
        setState(() {
          _saving = false;
          _apply(updated);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile changes saved.')),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _saving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not save: $e')),
        );
      }
    }
  }

  void _logout() {
    AppSession.clear();
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute<void>(builder: (_) => const RoleSelectionScreen()),
      (route) => false,
    );
  }

  @override
  void dispose() {
    for (final c in _controllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isDesktop = width >= 768;

    return Scaffold(
      appBar: const AppTopBar(showBack: false),
      bottomNavigationBar: const AppBottomNav(activeIndex: 3),
      backgroundColor: AppColors.background,
      body: SafeArea(
        top: false,
        bottom: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 32),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: FarmerProfileScreen.maxContentWidth,
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: isDesktop ? 64 : 16,
                ),
                child: _buildBody(isDesktop),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBody(bool isDesktop) {
    if (_loading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 64),
        child: Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );
    }
    if (_error != null) {
      return _ErrorState(message: 'Could not load profile', onRetry: _load);
    }

    final name = _controllers['name']!.text.isNotEmpty
        ? _controllers['name']!.text
        : 'Farmer';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _ProfileHeader(name: name),
        const SizedBox(height: 24),
        if (isDesktop)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _buildPersonal()),
              const SizedBox(width: 24),
              Expanded(child: _buildFarming()),
            ],
          )
        else ...[
          _buildPersonal(),
          const SizedBox(height: 24),
          _buildFarming(),
        ],
        const SizedBox(height: 24),
        if (isDesktop)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: SizedBox(
                  height: 440,
                  child: _buildFarmLocation(),
                ),
              ),
              const SizedBox(width: 24),
              Expanded(
                flex: 2,
                child: _buildPayment(),
              ),
            ],
          )
        else ...[
          SizedBox(height: 440, child: _buildFarmLocation()),
          const SizedBox(height: 24),
          _buildPayment(),
        ],
        const SizedBox(height: 24),
        const SizedBox(height: 24),
        _SaveButton(
          saving: _saving,
          onPressed: _saving ? null : _save,
        ),
        const SizedBox(height: 16),
        _LogoutButton(onPressed: _logout),
      ],
    );
  }

  Widget _buildPersonal() {
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const _SectionTitle(icon: Icons.person, text: 'Personal Details'),
          const SizedBox(height: 16),
          _DetailTextField(
            label: 'Full Name',
            controller: _controllers['name']!,
          ),
          const SizedBox(height: 16),
          _DetailTextField(
            label: 'Phone Number',
            controller: _controllers['phone']!,
          ),
          const SizedBox(height: 16),
          _DetailSelect(
            label: 'Primary Language',
            items: _languages,
            value: _language,
            onChanged: (v) => setState(() => _language = v),
          ),
          const SizedBox(height: 16),
          _DetailTextArea(
            label: 'Address',
            controller: _controllers['address']!,
          ),
        ],
      ),
    );
  }

  Widget _buildFarming() {
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const _SectionTitle(
            icon: Icons.spa,
            text: 'Farming Details',
            iconColor: AppColors.secondary,
          ),
          const SizedBox(height: 16),
          _LandAreaField(
            controller: _controllers['landArea']!,
            unit: _landUnit,
            units: _landUnits,
            onUnitChanged: (v) => setState(() => _landUnit = v),
          ),
          const SizedBox(height: 16),
          _DetailSelect(
            label: 'Soil Type',
            items: _soilTypes,
            value: _soilType,
            onChanged: (v) => setState(() => _soilType = v),
          ),
          const SizedBox(height: 16),
          _CropsField(
            crops: _crops,
            onRemove: _removeCrop,
            onAdd: _addCrop,
          ),
          const SizedBox(height: 16),
          _DetailSelect(
            label: 'Irrigation Source',
            items: _irrigationSources,
            value: _irrigation,
            onChanged: (v) => setState(() => _irrigation = v),
          ),
        ],
      ),
    );
  }

  Widget _buildFarmLocation() {
    return _Card(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const _SectionTitle(
            icon: Icons.location_on,
            text: 'Farm Location',
            iconColor: AppColors.tertiaryContainer,
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFFBFD8B8),
                    Color(0xFF8FB47F),
                    Color(0xFFD2E6E8),
                  ],
                ),
              ),
              child: const Center(
                child: Icon(
                  Icons.location_pin,
                  size: 28,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _controllers['latitude']!.text.isNotEmpty
                ? '${_controllers['latitude']!.text}° N, ${_controllers['longitude']!.text}° E'
                : 'Lat/Lng not set',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 14,
              height: 20 / 14,
              fontWeight: FontWeight.w500,
              color: AppColors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          _DetailTextField(
            label: 'Latitude',
            controller: _controllers['latitude']!,
          ),
          const SizedBox(height: 8),
          _DetailTextField(
            label: 'Longitude',
            controller: _controllers['longitude']!,
          ),
        ],
      ),
    );
  }

  Widget _buildPayment() {
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const _SectionTitle(
            icon: Icons.account_balance,
            text: 'Payment & Settlement',
          ),
          const SizedBox(height: 16),
          _DetailTextField(
            label: 'Bank Account Number',
            controller: _controllers['bankAccount']!,
          ),
          const SizedBox(height: 16),
          _DetailTextField(
            label: 'IFSC Code',
            controller: _controllers['ifsc']!,
            uppercase: true,
          ),
          const SizedBox(height: 16),
          _DetailSelect(
            label: 'Preferred Settlement Method',
            items: _settlementMethods,
            value: _settlementMethod,
            onChanged: (v) => setState(() => _settlementMethod = v),
          ),
        ],
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({required this.name});

  final String name;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isDesktop = width >= 768;

    return _Card(
      child: isDesktop
          ? Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _Avatar(),
                const SizedBox(width: 24),
                Expanded(child: _HeaderText(name: name)),
              ],
            )
          : Column(
              children: [
                const _Avatar(),
                const SizedBox(height: 16),
                _HeaderText(name: name),
              ],
            ),
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 96,
      height: 96,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.surface, width: 4),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFC96A2E), Color(0xFF7A4A2B)],
        ),
      ),
      child: const Center(
        child: Icon(Icons.person, size: 48, color: Colors.white),
      ),
    );
  }
}

class _HeaderText extends StatelessWidget {
  const _HeaderText({required this.name});

  final String name;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isDesktop = width >= 768;

    return Column(
      crossAxisAlignment:
          isDesktop ? CrossAxisAlignment.start : CrossAxisAlignment.center,
      children: [
        Text(
          name,
          textAlign: isDesktop ? TextAlign.left : TextAlign.center,
          style: GoogleFonts.inter(
            fontSize: 32,
            height: 40 / 32,
            letterSpacing: -0.01,
            fontWeight: FontWeight.w600,
            color: AppColors.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        Align(
          alignment: isDesktop ? Alignment.centerLeft : Alignment.center,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: AppColors.primaryContainer.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(999),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.verified, size: 16, color: AppColors.primary),
                SizedBox(width: 2),
                Text(
                  'Verified Farmer',
                  style: TextStyle(
                    fontSize: 12,
                    height: 16 / 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// Shared elevated card container.
class _Card extends StatelessWidget {
  const _Card({required this.child, this.padding = const EdgeInsets.all(16)});

  final Widget child;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
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
      child: child,
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.icon, required this.text, this.iconColor});

  final IconData icon;
  final String text;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(bottom: 8),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.surfaceVariant)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 22, color: iconColor ?? AppColors.primary),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
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
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.text, {this.marginBottom = 4});

  final String text;
  final double marginBottom;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: marginBottom),
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

InputDecoration _inputDecoration() {
  return InputDecoration(
    filled: true,
    fillColor: AppColors.surfaceContainerLowest,
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
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

class _DetailTextField extends StatelessWidget {
  const _DetailTextField({
    required this.label,
    required this.controller,
    this.uppercase = false,
  });

  final String label;
  final TextEditingController controller;
  final bool uppercase;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _FieldLabel(label),
        TextField(
          controller: controller,
          textCapitalization:
              uppercase ? TextCapitalization.characters : TextCapitalization.none,
          style: GoogleFonts.inter(fontSize: 16, color: AppColors.onSurface),
          decoration: _inputDecoration(),
        ),
      ],
    );
  }
}

class _DetailTextArea extends StatelessWidget {
  const _DetailTextArea({required this.label, required this.controller});

  final String label;
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _FieldLabel(label),
        TextField(
          controller: controller,
          maxLines: 2,
          style: GoogleFonts.inter(fontSize: 16, color: AppColors.onSurface),
          decoration: _inputDecoration().copyWith(
            contentPadding: const EdgeInsets.all(16),
          ),
        ),
      ],
    );
  }
}

class _DetailSelect extends StatelessWidget {
  const _DetailSelect({
    required this.label,
    required this.items,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final List<String> items;
  final String value;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _FieldLabel(label),
        _DropSelect(items: items, value: value, onChanged: onChanged),
      ],
    );
  }
}

class _DropSelect extends StatelessWidget {
  const _DropSelect({
    required this.items,
    required this.value,
    required this.onChanged,
  });

  final List<String> items;
  final String value;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      initialValue: value,
      isExpanded: true,
      decoration: _inputDecoration(),
      icon: const Icon(Icons.expand_more, color: AppColors.outlineVariant),
      borderRadius: BorderRadius.circular(8),
      style: GoogleFonts.inter(fontSize: 16, color: AppColors.onSurface),
      items: [
        for (final item in items)
          DropdownMenuItem(
            value: item,
            child: Text(item, overflow: TextOverflow.ellipsis),
          ),
      ],
      onChanged: (v) {
        if (v != null) onChanged(v);
      },
    );
  }
}

class _LandAreaField extends StatelessWidget {
  const _LandAreaField({
    required this.controller,
    required this.unit,
    required this.units,
    required this.onUnitChanged,
  });

  final TextEditingController controller;
  final String unit;
  final List<String> units;
  final ValueChanged<String> onUnitChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _FieldLabel('Total Land Area'),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                keyboardType: TextInputType.number,
                style: GoogleFonts.inter(fontSize: 16, color: AppColors.onSurface),
                decoration: _inputDecoration(),
              ),
            ),
            const SizedBox(width: 8),
            SizedBox(
              width: 120,
              child: _DropSelect(
                items: units,
                value: unit,
                onChanged: onUnitChanged,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _CropsField extends StatelessWidget {
  const _CropsField({
    required this.crops,
    required this.onRemove,
    required this.onAdd,
  });

  final List<String> crops;
  final ValueChanged<String> onRemove;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _FieldLabel('Major Crops Grown', marginBottom: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final crop in crops)
              _CropChip(label: crop, onRemove: () => onRemove(crop)),
            _AddCropChip(onTap: onAdd),
          ],
        ),
      ],
    );
  }
}

class _CropChip extends StatelessWidget {
  const _CropChip({required this.label, required this.onRemove});

  final String label;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 14,
              height: 20 / 14,
              fontWeight: FontWeight.w500,
              color: AppColors.onSurface,
            ),
          ),
          const SizedBox(width: 4),
          InkWell(
            onTap: onRemove,
            child: const Icon(
              Icons.close,
              size: 16,
              color: AppColors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _AddCropChip extends StatelessWidget {
  const _AddCropChip({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surfaceContainer,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(999),
        side: const BorderSide(color: AppColors.primary, width: 1),
      ),
      child: InkWell(
        onTap: onTap,
        customBorder:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
        child: const Padding(
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.add, size: 16, color: AppColors.primary),
              SizedBox(width: 4),
              Text(
                'Add Crop',
                style: TextStyle(
                  fontSize: 14,
                  height: 20 / 14,
                  fontWeight: FontWeight.w500,
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

class _SaveButton extends StatelessWidget {
  const _SaveButton({required this.saving, required this.onPressed});

  final bool saving;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isDesktop = width >= 768;

    return Align(
      alignment: Alignment.centerRight,
      child: SizedBox(
        width: isDesktop ? null : double.infinity,
        child: Material(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(12),
          elevation: 2,
          child: InkWell(
            onTap: onPressed,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: isDesktop
                  ? const EdgeInsets.symmetric(horizontal: 32, vertical: 14)
                  : const EdgeInsets.symmetric(vertical: 14),
              child: saving
                  ? const Center(
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: AppColors.onPrimary),
                      ),
                    )
                  : const Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.save, color: AppColors.onPrimary),
                        SizedBox(width: 8),
                        Text(
                          'Save Changes',
                          style: TextStyle(
                            fontSize: 18,
                            height: 28 / 18,
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
    );
  }
}

class _LogoutButton extends StatelessWidget {
  const _LogoutButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isDesktop = width >= 768;

    return Align(
      alignment: Alignment.centerRight,
      child: SizedBox(
        width: isDesktop ? null : double.infinity,
        child: OutlinedButton.icon(
          onPressed: onPressed,
          icon: const Icon(Icons.logout, size: 18, color: AppColors.error),
          label: const Text(
            'Logout',
            style: TextStyle(
              fontSize: 16,
              height: 24 / 16,
              fontWeight: FontWeight.w600,
              color: AppColors.error,
            ),
          ),
          style: OutlinedButton.styleFrom(
            padding: isDesktop
                ? const EdgeInsets.symmetric(horizontal: 32, vertical: 14)
                : const EdgeInsets.symmetric(vertical: 14),
            side: const BorderSide(color: AppColors.error, width: 1.5),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 48),
      child: Column(
        children: [
          const Icon(Icons.cloud_off, size: 40, color: AppColors.onSurfaceVariant),
          const SizedBox(height: 12),
          Text(
            message,
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 16,
              height: 24 / 16,
              color: AppColors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 16),
          TextButton(
            onPressed: onRetry,
            child: Text(
              'Retry',
              style: GoogleFonts.inter(fontSize: 14, color: AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }
}
