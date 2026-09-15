import 'package:flutter/material.dart';

class CipherTokens {
  static const Color darkTerminal = Color(0xFF0F141C);
  static const Color cyberCard = Color(0xFF1B2330);
  static const Color neonEmerald = Color(0xFF2A9D8F);
  static const Color textBright = Color(0xFFECEFF1);
  static const Color warningAmber = Color(0xFFFFB703);

  static ThemeData get theme => ThemeData(
        useMaterial3: true,
        fontFamily: 'AppFont',
        brightness: Brightness.dark,
        scaffoldBackgroundColor: darkTerminal,
        colorScheme: const ColorScheme.dark(
          primary: neonEmerald,
          secondary: warningAmber,
          surface: cyberCard,
          onSurface: textBright,
        ),
      );
}
