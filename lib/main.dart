import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'screens/role_selection_screen.dart';
import 'services/api_scope.dart';
import 'services/api_service.dart';

void main() {
  runApp(const AgriTrustApp());
}

/// Central Material 3 color palette derived from the design system's
/// Tailwind config. Kept here so the whole app shares the same tokens.
class AppColors {
  static const primary = Color(0xFF006948);
  static const onPrimary = Color(0xFFFFFFFF);
  static const primaryContainer = Color(0xFF00855D);
  static const primaryFixed = Color(0xFF85F8C4);
  static const primaryFixedDim = Color(0xFF68DBA9);
  static const onPrimaryFixed = Color(0xFF002114);
  static const onPrimaryFixedVariant = Color(0xFF005137);
  static const secondary = Color(0xFF944A23);
  static const secondaryFixed = Color(0xFFFFDBCC);
  static const secondaryContainer = Color(0xFFFD9E70);
  static const onSecondaryContainer = Color(0xFF76340E);
  static const tertiaryContainer = Color(0xFF007BB9);
  static const onTertiaryContainer = Color(0xFFFDFCFF);
  static const surfaceTint = Color(0xFF006C4A);
  static const surfaceDim = Color(0xFFD1DBEC);
  static const background = Color(0xFFF8F9FF);
  static const onBackground = Color(0xFF121C28);
  static const surface = Color(0xFFF8F9FF);
  static const surfaceContainerLowest = Color(0xFFFFFFFF);
  static const surfaceContainerLow = Color(0xFFEEF4FF);
  static const surfaceContainer = Color(0xFFE5EEFF);
  static const surfaceContainerHigh = Color(0xFFDFE9FA);
  static const surfaceVariant = Color(0xFFD9E3F4);
  static const surfaceBright = Color(0xFFF8F9FF);
  static const onSurface = Color(0xFF121C28);
  static const onSurfaceVariant = Color(0xFF3D4A42);
  static const outline = Color(0xFF6D7A72);
  static const onPrimaryContainer = Color(0xFFF5FFF7);
  static const inversePrimary = Color(0xFF68DBA9);
  static const outlineVariant = Color(0xFFBCCAC0);
  static const error = Color(0xFFBA1A1A);
  static const errorContainer = Color(0xFFFFDAD6);
  static const onErrorContainer = Color(0xFF93000A);
  static const onError = Color(0xFFFFFFFF);
}

class AgriTrustApp extends StatelessWidget {
  const AgriTrustApp({super.key, this.apiService});

  /// Optional API service. When omitted a real [HttpApiService] is used; tests
  /// supply a fake to avoid hitting the network.
  final ApiService? apiService;

  @override
  Widget build(BuildContext context) {
    final base = ThemeData(
      useMaterial3: true,
      colorScheme: const ColorScheme.light(
        primary: AppColors.primary,
        onPrimary: AppColors.onPrimary,
        surface: AppColors.surface,
        onSurface: AppColors.onSurface,
        onSurfaceVariant: AppColors.onSurfaceVariant,
        outlineVariant: AppColors.outlineVariant,
        error: AppColors.error,
      ),
      scaffoldBackgroundColor: AppColors.background,
      fontFamily: 'Inter',
    );

    final theme = base.copyWith(
      textTheme: GoogleFonts.interTextTheme(base.textTheme).copyWith(
        headlineLarge: GoogleFonts.inter(
          fontSize: 32,
          height: 40 / 32,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.01,
        ),
      ),
    );

    return ApiScope(
      service: apiService ?? HttpApiService(),
      child: MaterialApp(
        title: 'agritrust',
        debugShowCheckedModeBanner: false,
        theme: theme,
        home: const RoleSelectionScreen(),
      ),
    );
  }
}
