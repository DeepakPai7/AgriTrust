import 'package:flutter/material.dart';

import '../main.dart';
import '../widgets/auth_card.dart';

/// Persistent circular language selector FAB, bottom-right corner.
class _LanguageFab extends StatelessWidget {
  const _LanguageFab();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: AppColors.surface,
        shape: BoxShape.circle,
        border: Border.all(
          color: AppColors.outlineVariant.withValues(alpha: 0.3),
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x26000000),
            blurRadius: 25,
            offset: Offset(0, 20),
          ),
        ],
      ),
      child: IconButton(
        onPressed: () {},
        icon: const Icon(
          Icons.language,
          size: 28,
          color: AppColors.primary,
        ),
        tooltip: 'Language',
      ),
    );
  }
}

/// Login / Sign Up screen.
///
/// Responsive: the card is centered and capped at [maxCardWidth] on larger
/// screens, while remaining full-width on mobile with cozy padding.
class AuthScreen extends StatelessWidget {
  const AuthScreen({super.key});

  static const double maxCardWidth = 480;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 24,
            ),
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: maxCardWidth,
              ),
              child: const AuthCard(),
            ),
          ),
        ),
      ),
      // Persistent language selector, matching the design's FAB.
      floatingActionButton: const _LanguageFab(),
    );
  }
}
