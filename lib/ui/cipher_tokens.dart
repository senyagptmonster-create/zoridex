import 'package:flutter/material.dart';

/// Zoridex color palette.
class CipherPalette {
  CipherPalette._();

  static const Color kBg = Color(0xFF090A0F);
  static const Color kSurface = Color(0xFF13151F);
  static const Color kEdge = Color(0xFF1F2333);
  static const Color kAccent = Color(0xFF00E5FF);
  static const Color kAccent2 = Color(0xFF80D8FF);
  static const Color kInk = Color(0xFFE0F7FA);
}

/// Zoridex typography tokens.
class CipherTypography {
  CipherTypography._();

  static const String fontFamily = 'Orbitron';
}

/// Zoridex theme factory.
class CipherTheme {
  CipherTheme._();

  static ThemeData dark() {
    const font = CipherTypography.fontFamily;
    final base = ThemeData.dark();

    return base.copyWith(
      scaffoldBackgroundColor: CipherPalette.kBg,
      colorScheme: const ColorScheme.dark(
        surface: CipherPalette.kSurface,
        primary: CipherPalette.kAccent,
        secondary: CipherPalette.kAccent2,
        onSurface: CipherPalette.kInk,
        onPrimary: CipherPalette.kBg,
      ),
      drawerTheme: const DrawerThemeData(
        backgroundColor: CipherPalette.kSurface,
      ),
      navigationDrawerTheme: const NavigationDrawerThemeData(
        backgroundColor: CipherPalette.kSurface,
        indicatorColor: Color(0x2200E5FF),
        labelTextStyle: WidgetStatePropertyAll(
          TextStyle(
            fontFamily: font,
            fontSize: 13,
            color: CipherPalette.kInk,
            letterSpacing: 0.5,
          ),
        ),
        iconTheme: WidgetStatePropertyAll(
          IconThemeData(color: CipherPalette.kAccent),
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: CipherPalette.kSurface,
        foregroundColor: CipherPalette.kInk,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontFamily: font,
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: CipherPalette.kAccent,
          letterSpacing: 1.5,
        ),
      ),
      cardTheme: CardThemeData(
        color: CipherPalette.kSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: CipherPalette.kEdge, width: 1),
        ),
        elevation: 0,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: CipherPalette.kAccent,
          foregroundColor: CipherPalette.kBg,
          textStyle: const TextStyle(
            fontFamily: font,
            fontWeight: FontWeight.bold,
            fontSize: 13,
            letterSpacing: 1,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: CipherPalette.kAccent,
          side: const BorderSide(color: CipherPalette.kAccent),
          textStyle: const TextStyle(
            fontFamily: font,
            fontWeight: FontWeight.bold,
            fontSize: 12,
            letterSpacing: 1,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: CipherPalette.kAccent,
          textStyle: const TextStyle(fontFamily: font, fontSize: 12),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: CipherPalette.kSurface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: CipherPalette.kEdge),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: CipherPalette.kEdge),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: CipherPalette.kAccent, width: 1.5),
        ),
        labelStyle: const TextStyle(
          fontFamily: font,
          color: CipherPalette.kAccent2,
          fontSize: 12,
          letterSpacing: 0.5,
        ),
        hintStyle: const TextStyle(
          fontFamily: font,
          color: Color(0x64E0F7FA),
          fontSize: 12,
        ),
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? CipherPalette.kAccent
              : Colors.transparent,
        ),
        checkColor: const WidgetStatePropertyAll(CipherPalette.kBg),
        side: const BorderSide(color: CipherPalette.kEdge, width: 1.5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(3)),
      ),
      sliderTheme: const SliderThemeData(
        activeTrackColor: CipherPalette.kAccent,
        thumbColor: CipherPalette.kAccent,
        inactiveTrackColor: CipherPalette.kEdge,
        overlayColor: Color(0x2200E5FF),
        valueIndicatorColor: CipherPalette.kAccent,
        valueIndicatorTextStyle: TextStyle(
          fontFamily: font,
          color: CipherPalette.kBg,
          fontSize: 11,
        ),
      ),
      dividerTheme: const DividerThemeData(color: CipherPalette.kEdge, thickness: 1),
      textTheme: base.textTheme.apply(
        fontFamily: font,
        bodyColor: CipherPalette.kInk,
        displayColor: CipherPalette.kAccent,
      ),
    );
  }
}
