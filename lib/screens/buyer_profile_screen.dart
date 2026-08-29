import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../main.dart';
import '../models/models.dart';
import '../screens/role_selection_screen.dart';
import '../services/api_scope.dart';
import '../services/session.dart';
import '../widgets/app_bars.dart';

/// Buyer Profile edit screen. Loads the logged-in buyer's details from the
/// backend, lets them edit the fields, saves changes back to the database, and
/// provides a logout action that returns to the role switcher.
class BuyerProfileScreen extends StatefulWidget {
  const BuyerProfileScreen({super.key});

  static const double maxContentWidth = 1200; // matches Tailwind's max-w-6xl

  @override
  State<BuyerProfileScreen> createState() => _BuyerProfileScreenState();
}

class _BuyerProfileScreenState extends State<BuyerProfileScreen> {
  static const List<String> _paymentMethods = [
    'bank_transfer',
    'upi',
  ];

  late final Map<String, TextEditingController> _controllers = {
    for (final f in [
      'name',
      'companyName',
      'gstPan',
      'companyAddress',
      'preferredLocations',
      'contactPhone',
      'email',
      'bankAccount',
      'ifsc',
    ])
      f: TextEditingController(),
  };

  String _paymentMethod = _paymentMethods.first;
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
      final profile = await ApiScope.of(context).fetchBuyerProfile(id);
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

  void _apply(BuyerProfile p) {
    _controllers['name']!.text = p.name;
    _controllers['companyName']!.text = p.companyName ?? '';
    _controllers['gstPan']!.text = p.gstPan ?? '';
    _controllers['companyAddress']!.text = p.companyAddress ?? '';
    _controllers['preferredLocations']!.text = p.preferredLocations ?? '';
    _controllers['contactPhone']!.text = p.contactPhone ?? '';
    _controllers['email']!.text = p.email;
    _controllers['bankAccount']!.text = p.bankAccount ?? '';
    _controllers['ifsc']!.text = p.ifsc ?? '';
    _paymentMethod = _firstOr(p.paymentMethod, _paymentMethods, _paymentMethods.first);
    _crops = List.of(p.cropsInterested);
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
          decoration: _inputDecoration().copyWith(hintText: 'e.g. Soybean'),
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

  String get _paymentMethodLabel =>
      _paymentMethod == 'upi' ? 'UPI' : 'Bank Transfer';

  Future<void> _save() async {
    final id = AppSession.currentUser?.id;
    if (id == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You must be logged in to save changes.')),
      );
      return;
    }
    setState(() => _saving = true);
    final profile = BuyerProfile(
      id: id,
      name: _controllers['name']!.text.trim(),
      email: _controllers['email']!.text.trim(),
      companyName: _controllers['companyName']!.text.trim().isEmpty
          ? null
          : _controllers['companyName']!.text.trim(),
      gstPan: _controllers['gstPan']!.text.trim().isEmpty
          ? null
          : _controllers['gstPan']!.text.trim(),
      companyAddress: _controllers['companyAddress']!.text.trim().isEmpty
          ? null
          : _controllers['companyAddress']!.text.trim(),
      cropsInterested: _crops,
      preferredLocations: _controllers['preferredLocations']!.text.trim().isEmpty
          ? null
          : _controllers['preferredLocations']!.text.trim(),
      contactPhone: _controllers['contactPhone']!.text.trim().isEmpty
          ? null
          : _controllers['contactPhone']!.text.trim(),
      paymentMethod: _paymentMethod,
      bankAccount: _controllers['bankAccount']!.text.trim().isEmpty
          ? null
          : _controllers['bankAccount']!.text.trim(),
      ifsc: _controllers['ifsc']!.text.trim().isEmpty
          ? null
          : _controllers['ifsc']!.text.trim(),
    );
    try {
      final updated = await ApiScope.of(context).updateBuyerProfile(id, profile);
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
                maxWidth: BuyerProfileScreen.maxContentWidth,
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
        : 'Buyer';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _ProfileHeader(
          name: name,
          company: _controllers['companyName']!.text,
        ),
        const SizedBox(height: 24),
        if (isDesktop)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _buildLeft()),
              const SizedBox(width: 24),
              Expanded(child: _buildRight()),
            ],
          )
        else ...[
          _buildLeft(),
          const SizedBox(height: 24),
          _buildRight(),
        ],
        const SizedBox(height: 24),
        const _DocumentsCard(),
        const SizedBox(height: 24),
        _SaveButton(saving: _saving, onPressed: _saving ? null : _save),
        const SizedBox(height: 16),
        _LogoutButton(onPressed: _logout),
      ],
    );
  }

  Widget _buildLeft() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _CompanyDetails(),
        const SizedBox(height: 24),
        _PurchasingInterests(
          crops: _crops,
          controller: _controllers['preferredLocations']!,
          onRemove: _removeCrop,
          onAdd: _addCrop,
        ),
      ],
    );
  }

  Widget _buildRight() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _Contact(
          phone: _controllers['contactPhone']!,
          email: _controllers['email']!,
        ),
        const SizedBox(height: 24),
        _Payment(
          bankAccount: _controllers['bankAccount']!,
          ifsc: _controllers['ifsc']!,
          paymentMethod: _paymentMethod,
          paymentMethodLabel: _paymentMethodLabel,
          onPaymentChanged: (v) => setState(() => _paymentMethod = v),
        ),
      ],
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({required this.name, required this.company});

  final String name;
  final String company;

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
                Expanded(child: _HeaderText(name: name, company: company)),
              ],
            )
          : Column(
              children: [
                const _Avatar(),
                const SizedBox(height: 16),
                _HeaderText(name: name, company: company),
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
          colors: [Color(0xFF4A90C9), Color(0xFF2C3E6B)],
        ),
      ),
      child: const Center(
        child: Icon(Icons.person, size: 48, color: Colors.white),
      ),
    );
  }
}

class _HeaderText extends StatelessWidget {
  const _HeaderText({required this.name, required this.company});

  final String name;
  final String company;

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
        if (company.isNotEmpty) ...[
          const SizedBox(height: 2),
          Text(
            company,
            textAlign: isDesktop ? TextAlign.left : TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 16,
              height: 24 / 16,
              color: AppColors.onSurfaceVariant,
            ),
          ),
        ],
        const SizedBox(height: 12),
        Align(
          alignment: isDesktop ? Alignment.centerLeft : Alignment.center,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.primaryContainer.withValues(alpha: 0.25),
              borderRadius: BorderRadius.circular(999),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.check_circle, size: 16, color: AppColors.primary),
                SizedBox(width: 4),
                Text(
                  'Verified Buyer',
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

class _Card extends StatelessWidget {
  const _Card({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
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
  const _SectionTitle({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(bottom: 8),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.surfaceVariant)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 22, color: AppColors.secondary),
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

class _CompanyDetails extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return _FieldBuilder(
      title: const _SectionTitle(icon: Icons.business, text: 'Company Details'),
      children: (controllers) => [
        _DetailTextField(label: 'Full Name', controller: controllers['name']!),
        const SizedBox(height: 16),
        _DetailTextField(
            label: 'Company Name', controller: controllers['companyName']!),
        const SizedBox(height: 16),
        _DetailTextField(
          label: 'Business Registration Number (GST/PAN)',
          controller: controllers['gstPan']!,
          uppercase: true,
        ),
        const SizedBox(height: 16),
        _DetailTextArea(
            label: 'Business Address', controller: controllers['companyAddress']!),
      ],
    );
  }
}

class _PurchasingInterests extends StatelessWidget {
  const _PurchasingInterests({
    required this.crops,
    required this.controller,
    required this.onRemove,
    required this.onAdd,
  });

  final List<String> crops;
  final TextEditingController controller;
  final ValueChanged<String> onRemove;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const _SectionTitle(
              icon: Icons.psychology, text: 'Purchasing Interests'),
          const SizedBox(height: 16),
          _InterestsChips(
            crops: crops,
            onRemove: onRemove,
            onAdd: onAdd,
          ),
          const SizedBox(height: 16),
          _DetailTextField(
            label: 'Preferred Buying Locations',
            controller: controller,
          ),
        ],
      ),
    );
  }
}

class _InterestsChips extends StatelessWidget {
  const _InterestsChips({
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
        const _FieldLabel('Major Crops Interested In', marginBottom: 8),
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
        borderRadius: BorderRadius.circular(8),
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
        borderRadius: BorderRadius.circular(8),
        side: const BorderSide(color: AppColors.outlineVariant, width: 1),
      ),
      child: InkWell(
        onTap: onTap,
        customBorder: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
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

class _Contact extends StatelessWidget {
  const _Contact({
    required this.phone,
    required this.email,
  });

  final TextEditingController phone;
  final TextEditingController email;

  @override
  Widget build(BuildContext context) {
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const _SectionTitle(icon: Icons.contacts, text: 'Contact Information'),
          const SizedBox(height: 16),
          _PhoneField(controller: phone),
          const SizedBox(height: 16),
          _DetailTextField(label: 'Email Address', controller: email),
        ],
      ),
    );
  }
}

class _PhoneField extends StatelessWidget {
  const _PhoneField({required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _FieldLabel('Phone Number'),
        TextField(
          controller: controller,
          keyboardType: TextInputType.phone,
          style: GoogleFonts.inter(fontSize: 16, color: AppColors.onSurface),
          decoration: _inputDecoration().copyWith(
            prefixText: '+91 ',
            prefixStyle: GoogleFonts.inter(
              fontSize: 16,
              color: AppColors.onSurfaceVariant,
            ),
          ),
        ),
      ],
    );
  }
}

class _Payment extends StatelessWidget {
  const _Payment({
    required this.bankAccount,
    required this.ifsc,
    required this.paymentMethod,
    required this.paymentMethodLabel,
    required this.onPaymentChanged,
  });

  final TextEditingController bankAccount;
  final TextEditingController ifsc;
  final String paymentMethod;
  final String paymentMethodLabel;
  final ValueChanged<String> onPaymentChanged;

  @override
  Widget build(BuildContext context) {
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const _SectionTitle(icon: Icons.account_balance, text: 'Payment & Settlement'),
          const SizedBox(height: 16),
          _DetailTextField(label: 'Bank Account Number', controller: bankAccount),
          const SizedBox(height: 16),
          _DetailTextField(
            label: 'IFSC Code',
            controller: ifsc,
            uppercase: true,
          ),
          const SizedBox(height: 16),
          _PaymentMethodOptions(
            method: paymentMethod,
            label: paymentMethodLabel,
            onChanged: onPaymentChanged,
          ),
        ],
      ),
    );
  }
}

class _PaymentMethodOptions extends StatelessWidget {
  const _PaymentMethodOptions({
    required this.method,
    required this.label,
    required this.onChanged,
  });

  final String method;
  final String label;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final narrow = width < 640;

    Widget option(String value, IconData icon, String optionLabel) {
      final selected = method == value;
      return _PaymentMethodRadio(
        selected: selected,
        icon: icon,
        label: optionLabel,
        onTap: selected ? null : () => onChanged(value),
      );
    }

    final bank = option('bank_transfer', Icons.account_balance, 'Bank Transfer');
    final upi = option('upi', Icons.qr_code_scanner, 'UPI');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _FieldLabel('Preferred Payment Method', marginBottom: 8),
        if (narrow)
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [bank, const SizedBox(height: 8), upi],
          )
        else
          Row(
            children: [
              Expanded(child: bank),
              const SizedBox(width: 16),
              Expanded(child: upi),
            ],
          ),
      ],
    );
  }
}

class _PaymentMethodRadio extends StatelessWidget {
  const _PaymentMethodRadio({
    required this.selected,
    required this.icon,
    required this.label,
    this.onTap,
  });

  final bool selected;
  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.surfaceContainerLow
              : AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.outlineVariant,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              selected ? Icons.radio_button_checked : Icons.radio_button_off,
              size: 18,
              color: selected ? AppColors.primary : AppColors.outlineVariant,
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 16,
                  height: 24 / 16,
                  color: AppColors.onSurface,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DocumentsCard extends StatelessWidget {
  const _DocumentsCard();

  @override
  Widget build(BuildContext context) {
    return const _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _SectionTitle(icon: Icons.description, text: 'Business Documents'),
          SizedBox(height: 12),
          _DocumentRow(icon: Icons.picture_as_pdf, name: 'GST_Certificate.pdf'),
          SizedBox(height: 12),
          _DocumentRow(icon: Icons.image, name: 'PAN_Card.jpg'),
        ],
      ),
    );
  }
}

class _DocumentRow extends StatelessWidget {
  const _DocumentRow({required this.icon, required this.name});

  final IconData icon;
  final String name;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.outlineVariant),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 20, color: AppColors.onSurfaceVariant),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              name,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.inter(
                fontSize: 14,
                height: 20 / 14,
                fontWeight: FontWeight.w500,
                color: AppColors.onSurface,
              ),
            ),
          ),
          const Icon(Icons.download, size: 20, color: AppColors.onSurfaceVariant),
        ],
      ),
    );
  }
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
          maxLines: 3,
          style: GoogleFonts.inter(fontSize: 16, color: AppColors.onSurface),
          decoration: _inputDecoration().copyWith(
            contentPadding: const EdgeInsets.all(16),
          ),
        ),
      ],
    );
  }
}

/// Helper that renders a card body from the parent state's controllers.
class _FieldBuilder extends StatelessWidget {
  const _FieldBuilder({required this.title, required this.children});

  final Widget title;
  final List<Widget> Function(Map<String, TextEditingController>) children;

  @override
  Widget build(BuildContext context) {
    final state = context
        .findAncestorStateOfType<_BuyerProfileScreenState>();
    if (state == null) return const SizedBox.shrink();
    return _Card(child: Column(children: [title, ...children(state._controllers)]));
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
                  ? const EdgeInsets.symmetric(horizontal: 32, vertical: 16)
                  : const EdgeInsets.symmetric(vertical: 16),
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
