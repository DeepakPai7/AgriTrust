import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../main.dart';

enum AuthTab { login, signup }

/// The centered card containing the hero illustration, the Login/Sign Up
/// tabs and the two corresponding forms.
class AuthCard extends StatefulWidget {
  const AuthCard({super.key});

  @override
  State<AuthCard> createState() => _AuthCardState();
}

class _AuthCardState extends State<AuthCard> {
  AuthTab _tab = AuthTab.login;

  void _switchTab(AuthTab tab) {
    if (_tab == tab) return;
    setState(() => _tab = tab);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Color(0x26000000),
            blurRadius: 25,
            offset: Offset(0, 20),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const _HeroIllustration(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24).copyWith(
              top: 8,
              bottom: 24,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _Tabs(active: _tab, onChanged: _switchTab),
                const SizedBox(height: 32),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  switchInCurve: Curves.easeOut,
                  switchOutCurve: Curves.easeIn,
                  child: _tab == AuthTab.login
                      ? LoginForm(
                          key: const ValueKey('login'),
                          onSwitchToSignup: () => _switchTab(AuthTab.signup),
                        )
                      : SignupForm(
                          key: const ValueKey('signup'),
                          onSwitchToLogin: () => _switchTab(AuthTab.login),
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

/// The top illustration area: a photo backed by a painted "image" (a
/// gradient that evokes the original's agriculture + tech look), the brand
/// row and a fade into the card surface.
class _HeroIllustration extends StatelessWidget {
  const _HeroIllustration();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 180,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Simulated decorative image (in the shipped code you would
          // replace this with an actual asset/network image).
          const _AgriFinanceBackdrop(),
          // Gradient to blend the image into the card.
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.transparent, AppColors.surface],
              ),
            ),
          ),
          // Brand row.
          Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.agriculture,
                  size: 32,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'DealCheck',
                  style: GoogleFonts.inter(
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                    letterSpacing: -0.01,
                    color: AppColors.primary,
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

/// Paints an abstract "terraced fields + data streams" backdrop used in the
/// hero area. Replace with a real Image widget for a photographic asset.
class _AgriFinanceBackdrop extends StatelessWidget {
  const _AgriFinanceBackdrop();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: const _AgriFinancePainter(),
      child: const SizedBox.expand(),
    );
  }
}

class _AgriFinancePainter extends CustomPainter {
  const _AgriFinancePainter();

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Base: deep emerald gradient.
    final base = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF0E5C42), Color(0xFF3A9B6E)],
      ).createShader(Offset.zero & size);
    canvas.drawRect(Offset.zero & size, base);

    // Terraced field bands.
    final fieldFill = Paint()..color = const Color(0x2E2E7D55);
    for (var i = 0; i < 7; i++) {
      final y = h - 10 - i * 26.0;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(-w * 0.25, y, w * 1.5, 16),
          const Radius.circular(8),
        ),
        fieldFill,
      );
    }

    // Glowing "data" streams / chart lines.
    final line = Paint()
      ..color = AppColors.primaryFixedDim
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);
    final path = Path()
      ..moveTo(-10, h * 0.55)
      ..cubicTo(w * 0.25, h * 0.35, w * 0.45, h * 0.75, w * 0.75, h * 0.42)
      ..cubicTo(w * 0.9, h * 0.25, w * 1.05, h * 0.3, w + 10, h * 0.18);
    canvas.drawPath(path, line);

    // Subtle chart "bars".
    final bar = Paint()..color = const Color(0x8085F8C4);
    const bars = [0.4, 0.55, 0.48, 0.68, 0.6];
    for (var i = 0; i < bars.length; i++) {
      final x = w * 0.5 + i * 34.0;
      final bh = h * bars[i];
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(x, h - bh, 12, bh),
          const Radius.circular(4),
        ),
        bar,
      );
    }

    // Top light wash.
    final wash = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xFFFFF8F1),
          Color(0x44FFF8F1),
          Colors.transparent,
        ],
      ).createShader(Offset.zero & size);
    canvas.drawRect(Offset.zero & size, wash);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// The Log In / Sign Up segmented tabs.
class _Tabs extends StatelessWidget {
  const _Tabs({required this.active, required this.onChanged});

  final AuthTab active;
  final ValueChanged<AuthTab> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _TabButton(
          label: 'Log In',
          active: active == AuthTab.login,
          onTap: () => onChanged(AuthTab.login),
        ),
        _TabButton(
          label: 'Sign Up',
          active: active == AuthTab.signup,
          onTap: () => onChanged(AuthTab.signup),
        ),
      ],
    );
  }
}

class _TabButton extends StatelessWidget {
  const _TabButton({
    required this.label,
    required this.active,
    required this.onTap,
  });

  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = active ? AppColors.primary : AppColors.onSurfaceVariant;
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: active ? AppColors.primary : Colors.transparent,
                width: 2,
              ),
            ),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 14,
              height: 20 / 14,
              fontWeight: FontWeight.w500,
              color: color,
            ),
          ),
        ),
      ),
    );
  }
}

/// Reusable labeled text field.
class _FormField extends StatelessWidget {
  const _FormField({
    required this.label,
    required this.hint,
    required this.controller,
    this.obscure = false,
    this.isPassword = false,
    this.keyboardType,
    this.textInputAction,
  });

  final String label;
  final String hint;
  final TextEditingController controller;
  final bool obscure;
  final bool isPassword;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;

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
            color: AppColors.onSurface,
          ),
        ),
        const SizedBox(height: 4),
        _PasswordField(controller: controller, obscure: obscure, isPassword: isPassword, hint: hint, keyboardType: keyboardType, textInputAction: textInputAction),
      ],
    );
  }
}

class _PasswordField extends StatefulWidget {
  const _PasswordField({
    required this.controller,
    required this.obscure,
    required this.isPassword,
    required this.hint,
    this.keyboardType,
    this.textInputAction,
  });

  final TextEditingController controller;
  final bool obscure;
  final bool isPassword;
  final String hint;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;

  @override
  State<_PasswordField> createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<_PasswordField> {
  late bool _obscure = widget.obscure;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: widget.controller,
      obscureText: widget.isPassword ? _obscure : false,
      keyboardType: widget.keyboardType,
      textInputAction: widget.textInputAction,
      style: GoogleFonts.inter(
        fontSize: 18,
        height: 28 / 18,
        color: AppColors.onSurface,
      ),
      decoration: InputDecoration(
        hintText: widget.hint,
        hintStyle: GoogleFonts.inter(
          fontSize: 18,
          color: const Color(0x803D4A42),
        ),
        filled: true,
        fillColor: AppColors.surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        suffixIcon: widget.isPassword
            ? IconButton(
                onPressed: () => setState(() => _obscure = !_obscure),
                icon: Icon(
                  _obscure
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  color: AppColors.onSurfaceVariant,
                ),
              )
            : null,
      ),
    );
  }
}

/// Primary filled action button (56px tall, matching the design).
class _PrimaryButton extends StatelessWidget {
  const _PrimaryButton({required this.label, this.onPressed});

  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 56,
      child: FilledButton(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.onPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          elevation: 4,
          textStyle: GoogleFonts.inter(
            fontSize: 14,
            height: 20 / 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        child: Text(label),
      ),
    );
  }
}

/// The Log In form.
class LoginForm extends StatefulWidget {
  const LoginForm({super.key, required this.onSwitchToSignup});

  final VoidCallback onSwitchToSignup;

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _email = TextEditingController();
  final _password = TextEditingController();

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  void _login() {
    // Wire up to your auth / API layer here.
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      key: const ValueKey('login'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _FormField(
          label: 'Email or Phone',
          hint: 'Enter your email or phone number',
          controller: _email,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
        ),
        const SizedBox(height: 16),
        _FormField(
          label: 'Password',
          hint: 'Enter your password',
          controller: _password,
          obscure: true,
          isPassword: true,
          textInputAction: TextInputAction.done,
        ),
        const SizedBox(height: 4),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: () {},
            style: TextButton.styleFrom(
              padding: EdgeInsets.zero,
              foregroundColor: AppColors.primary,
            ),
            child: Text(
              'Forgot Password?',
              style: GoogleFonts.inter(
                fontSize: 14,
                height: 20 / 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        _PrimaryButton(
          label: 'Log In',
          onPressed: _login,
        ),
        const SizedBox(height: 8),
        Center(
          child: Text.rich(
            TextSpan(
              text: "Don't have an account? ",
              style: GoogleFonts.inter(
                fontSize: 16,
                height: 24 / 16,
                color: AppColors.onSurfaceVariant,
              ),
              children: [
                WidgetSpan(
                  alignment: PlaceholderAlignment.middle,
                  child: GestureDetector(
                    onTap: widget.onSwitchToSignup,
                    child: Text(
                      'Sign Up',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        height: 20 / 14,
                        fontWeight: FontWeight.w500,
                        color: AppColors.primary,
                        decoration: TextDecoration.underline,
                        decorationColor: AppColors.primary,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }
}

/// The Sign Up form.
class SignupForm extends StatefulWidget {
  const SignupForm({super.key, required this.onSwitchToLogin});

  final VoidCallback onSwitchToLogin;

  @override
  State<SignupForm> createState() => _SignupFormState();
}

class _SignupFormState extends State<SignupForm> {
  final _name = TextEditingController();
  final _contact = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();

  @override
  void dispose() {
    _name.dispose();
    _contact.dispose();
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  void _submit() {
    // Wire up to your auth / API layer here.
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      key: const ValueKey('signup'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _FormField(
          label: 'Full Name',
          hint: 'Enter your full name',
          controller: _name,
          textInputAction: TextInputAction.next,
        ),
        const SizedBox(height: 16),
        _FormField(
          label: 'Email or Phone',
          hint: 'Enter your email or phone number',
          controller: _contact,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
        ),
        const SizedBox(height: 16),
        _FormField(
          label: 'Password',
          hint: 'Create a strong password',
          controller: _password,
          obscure: true,
          isPassword: true,
          textInputAction: TextInputAction.next,
        ),
        const SizedBox(height: 16),
        _FormField(
          label: 'Confirm Password',
          hint: 'Confirm your password',
          controller: _confirm,
          obscure: true,
          isPassword: true,
          textInputAction: TextInputAction.done,
        ),
        const SizedBox(height: 8),
        _PrimaryButton(
          label: 'Create Account',
          onPressed: _submit,
        ),
      ],
    );
  }
}
