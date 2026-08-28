import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../main.dart';

enum UserRole { farmer, buyer }

class RoleSelectionScreen extends StatefulWidget {
  const RoleSelectionScreen({super.key});

  @override
  State<RoleSelectionScreen> createState() => _RoleSelectionScreenState();
}

class _RoleSelectionScreenState extends State<RoleSelectionScreen> {
  UserRole? _selected;

  static const double maxWidth = 480;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: maxWidth),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const _Header(),
                  const SizedBox(height: 32),
                  _RoleCard(
                    role: UserRole.farmer,
                    icon: Icons.cloud_download,
                    title: 'I am a Farmer',
                    subtitle: 'List your crops and find buyers directly.',
                    selected: _selected == UserRole.farmer,
                    onTap: () => _select(UserRole.farmer),
                  ),
                  const SizedBox(height: 16),
                  _RoleCard(
                    role: UserRole.buyer,
                    icon: Icons.handshake,
                    title: 'I am a Buyer',
                    subtitle: 'Browse crops and manage deals efficiently.',
                    selected: _selected == UserRole.buyer,
                    onTap: () => _select(UserRole.buyer),
                  ),
                  const SizedBox(height: 32),
                  _ContinueButton(
                    enabled: _selected != null,
                    onPressed: _selected == null ? null : () {},
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _select(UserRole role) {
    setState(() => _selected = role);
  }
}

/// Brand mark + title + subtitle block.
class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: AppColors.primaryContainer,
            borderRadius: BorderRadius.circular(12),
            boxShadow: const [
              BoxShadow(
                color: Color(0x0D059669),
                blurRadius: 4,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: const Icon(
            Icons.agriculture,
            size: 28,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'DealCheck',
          style: GoogleFonts.inter(
            fontSize: 24,
            height: 32 / 24,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.01,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Tell us who you are',
          textAlign: TextAlign.center,
          style: GoogleFonts.inter(
            fontSize: 24,
            height: 32 / 24,
            fontWeight: FontWeight.w600,
            color: AppColors.onSurface,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Select your role to get started with the right tools.',
          textAlign: TextAlign.center,
          style: GoogleFonts.inter(
            fontSize: 16,
            height: 24 / 16,
            color: AppColors.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

/// A selectable role card with icon container, title, subtitle and a
/// check indicator that animates in when selected.
class _RoleCard extends StatelessWidget {
  const _RoleCard({
    required this.role,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });

  final UserRole role;
  final IconData icon;
  final String title;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? AppColors.surfaceContainerLow : Colors.white,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              width: 2,
              color: selected ? AppColors.primary : AppColors.outlineVariant,
            ),
            boxShadow: [
              BoxShadow(
                color: selected
                    ? const Color(0x1A000000)
                    : const Color(0x0D059669),
                blurRadius: selected ? 15 : 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Stack(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: selected
                          ? AppColors.primary
                          : AppColors.surfaceContainer,
                    ),
                    child: Icon(
                      icon,
                      size: 24,
                      color: selected
                          ? AppColors.onPrimary
                          : AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AnimatedDefaultTextStyle(
                          duration: const Duration(milliseconds: 200),
                          style: GoogleFonts.inter(
                            fontSize: 24,
                            height: 32 / 24,
                            fontWeight: FontWeight.w600,
                            color: selected
                                ? AppColors.primary
                                : AppColors.onSurface,
                          ),
                          child: Text(title),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          subtitle,
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            height: 24 / 16,
                            color: AppColors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: _SelectionIndicator(selected: selected),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// The circular check indicator in the top-right of a selected card.
class _SelectionIndicator extends StatelessWidget {
  const _SelectionIndicator({required this.selected});

  final bool selected;

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      scale: selected ? 1.0 : 0.5,
      duration: const Duration(milliseconds: 200),
      child: AnimatedOpacity(
        opacity: selected ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 200),
        child: Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: selected ? AppColors.primary : Colors.transparent,
            border: Border.all(
              color: selected ? AppColors.primary : AppColors.outlineVariant,
              width: 2,
            ),
          ),
          child: const Icon(
            Icons.check,
            size: 16,
            color: AppColors.onPrimary,
          ),
        ),
      ),
    );
  }
}

/// The bottom Continue button. Disabled until a role is chosen.
class _ContinueButton extends StatelessWidget {
  const _ContinueButton({required this.enabled, required this.onPressed});

  final bool enabled;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 56,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 200),
        opacity: enabled ? 1.0 : 0.5,
        child: Material(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(12),
          elevation: 1,
          child: InkWell(
            onTap: onPressed,
            borderRadius: BorderRadius.circular(12),
            child: Center(
              child: Text(
                'Continue',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  height: 20 / 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.onPrimary,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
