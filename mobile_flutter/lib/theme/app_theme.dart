import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Dark Palette
  static const Color backgroundColor = Color(0xFF0F172A);
  static const Color cardColor = Color(0xFF1E293B);
  static const Color accentColor = Color(0xFF8B5CF6);
  static const Color textColor = Color(0xFFF1F5F9);
  static const Color secondaryTextColor = Color(0xFF94A3B8);
  static const Color mutedTextColor = Color(0xFF64748B);
  static const Color borderColor = Color(0xFF334155);

  // Light Palette
  static const Color lightBackgroundColor = Color(0xFFF8FAFC);
  static const Color lightCardColor = Colors.white;
  static const Color lightTextColor = Color(0xFF0F172A);
  static const Color lightSecondaryTextColor = Color(0xFF475569);
  static const Color lightBorderColor = Color(0xFFE2E8F0);

  static ThemeData darkTheme = _buildTheme(Brightness.dark);
  static ThemeData lightTheme = _buildTheme(Brightness.light);

  static ThemeData _buildTheme(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    final bg = isDark ? backgroundColor : lightBackgroundColor;
    final card = isDark ? cardColor : lightCardColor;
    final txt = isDark ? textColor : lightTextColor;
    final secTxt = isDark ? secondaryTextColor : lightSecondaryTextColor;
    final border = isDark ? borderColor : lightBorderColor;

    return ThemeData(
      brightness: brightness,
      scaffoldBackgroundColor: bg,
      colorScheme: ColorScheme(
        brightness: brightness,
        primary: accentColor,
        onPrimary: Colors.white,
        secondary: accentColor,
        onSecondary: Colors.white,
        error: Colors.red,
        onError: Colors.white,
        background: bg,
        onBackground: txt,
        surface: card,
        onSurface: txt,
      ),
      textTheme: GoogleFonts.interTextTheme(
        TextTheme(
          headlineMedium: TextStyle(color: txt, fontWeight: FontWeight.w800, fontSize: 24),
          titleLarge: TextStyle(color: txt, fontWeight: FontWeight.w700, fontSize: 18),
          bodyMedium: TextStyle(color: txt, fontSize: 16),
          bodySmall: TextStyle(color: secTxt, fontSize: 14),
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: card,
        elevation: 0,
        iconTheme: IconThemeData(color: txt),
        titleTextStyle: TextStyle(color: txt, fontSize: 20, fontWeight: FontWeight.w700),
      ),
      cardTheme: CardThemeData(
        color: card,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: border),
        ),
        elevation: 0,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark ? backgroundColor : Colors.white,
        hintStyle: const TextStyle(color: mutedTextColor),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: border),
        ),
        prefixIconColor: secTxt,
      ),
      dividerTheme: DividerThemeData(color: border, thickness: 1),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: card,
        selectedItemColor: accentColor,
        unselectedItemColor: secTxt,
      ),
    );
  }
}
