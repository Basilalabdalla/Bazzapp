import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'colors.dart';

class AppTheme {
  static ThemeData get light {
    final base = ThemeData(
      useMaterial3: true,
      colorScheme: const ColorScheme(
        brightness: Brightness.light,
        primary: BazzColors.primary,
        onPrimary: Colors.white,
        secondary: BazzColors.accent,
        onSecondary: BazzColors.primary,
        error: BazzColors.error,
        onError: Colors.white,
        surface: BazzColors.surface,
        onSurface: BazzColors.textPrimary,
        // M3 surface container for cards
        surfaceContainerHighest: Color(0xFFE8EDF5),
      ),
    );

    return base.copyWith(
      scaffoldBackgroundColor: BazzColors.surface,
      textTheme: GoogleFonts.interTextTheme(base.textTheme),
      // M3 AppBar — surface-colored, no shadow, border bottom only on scroll
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.white,
        foregroundColor: BazzColors.textPrimary,
        elevation: 0,
        scrolledUnderElevation: 1,
        shadowColor: BazzColors.divider,
        surfaceTintColor: Colors.transparent,
        centerTitle: true,
        titleTextStyle: GoogleFonts.inter(
          fontSize: 17,
          fontWeight: FontWeight.w700,
          color: BazzColors.textPrimary,
        ),
      ),
      // M3 Cards — elevation 1 via tonal surface, no drop-shadow border
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 1,
        surfaceTintColor: Colors.transparent,
        shadowColor: const Color(0x0A000000),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      // ElevatedButton used for accent/golden CTA
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: BazzColors.accent,
          foregroundColor: BazzColors.primary,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          padding: const EdgeInsets.symmetric(vertical: 14),
          textStyle: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 15),
        ),
      ),
      // FilledButton — primary (navy) for standard actions
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: BazzColors.primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          padding: const EdgeInsets.symmetric(vertical: 14),
          textStyle: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 15),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: BazzColors.textPrimary,
          side: const BorderSide(color: BazzColors.divider),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          padding: const EdgeInsets.symmetric(vertical: 14),
        ),
      ),
      // M3 OutlinedTextField
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: BazzColors.divider),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: BazzColors.divider),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: BazzColors.primary, width: 2),
        ),
        hintStyle: const TextStyle(color: BazzColors.textHint, fontSize: 14),
      ),
      // M3 NavigationBar — white bg, navy indicator pill
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: Colors.white,
        elevation: 8,
        shadowColor: const Color(0x14000000),
        surfaceTintColor: Colors.transparent,
        indicatorColor: BazzColors.primary.withOpacity(0.12),
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: BazzColors.primary, size: 24);
          }
          return const IconThemeData(color: BazzColors.textHint, size: 24);
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w700, color: BazzColors.primary);
          }
          return GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w500, color: BazzColors.textHint);
        }),
      ),
      // M3 FilterChip / InputChip
      chipTheme: ChipThemeData(
        backgroundColor: Colors.white,
        selectedColor: BazzColors.primary,
        side: const BorderSide(color: BazzColors.divider),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        labelStyle: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600),
        padding: const EdgeInsets.symmetric(horizontal: 4),
      ),
      // M3 FAB — golden/accent
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: BazzColors.accent,
        foregroundColor: BazzColors.primary,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
      ),
      // M3 SnackBar
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        contentTextStyle: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 14),
      ),
      dividerTheme: const DividerThemeData(color: BazzColors.divider, space: 1),
      // M3 Switch active track color = accent
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((s) => s.contains(WidgetState.selected) ? BazzColors.primary : null),
        trackColor: WidgetStateProperty.resolveWith((s) => s.contains(WidgetState.selected) ? BazzColors.accent : null),
      ),
    );
  }
}