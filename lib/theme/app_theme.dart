// lib/theme/app_theme.dart
import 'package:flutter/material.dart';

class AppTheme {
  // Light Theme Colors
  static const Color _primaryLight = Color(0xFF1565C0);
  static const Color _primaryVariantLight = Color(0xFF0D47A1);
  static const Color _secondaryLight = Color(0xFF00BCD4);
  static const Color _surfaceLight = Color(0xFFFFFFFF);
  static const Color _backgroundLight = Color(0xFFF8FAFF);
  static const Color _cardLight = Color(0xFFFFFFFF);
  static const Color _dividerLight = Color(0xFFE3F2FD);

  // Dark Theme Colors
  static const Color _primaryDark = Color(0xFF42A5F5);
  static const Color _primaryVariantDark = Color(0xFF1E88E5);
  static const Color _secondaryDark = Color(0xFF26C6DA);
  static const Color _surfaceDark = Color(0xFF1E1E1E);
  static const Color _backgroundDark = Color(0xFF121212);
  static const Color _cardDark = Color(0xFF2A2A2A);
  static const Color _dividerDark = Color(0xFF333333);

  // Accent Colors
  static const Color success = Color(0xFF00C853);
  static const Color warning = Color(0xFFFF9800);
  static const Color error = Color(0xFFF44336);
  static const Color info = Color(0xFF2196F3);

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: const ColorScheme.light(
      primary: _primaryLight,
      primaryContainer: Color(0xFFE3F2FD),
      secondary: _secondaryLight,
      secondaryContainer: Color(0xFFB2EBF2),
      surface: _surfaceLight,
      surfaceContainer: _cardLight,
      background: _backgroundLight,
      error: error,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: Color(0xFF1A1A1A),
      onBackground: Color(0xFF1A1A1A),
      onError: Colors.white,
      outline: _dividerLight,
    ),

    appBarTheme: const AppBarTheme(
      backgroundColor: _primaryLight,
      foregroundColor: Colors.white,
      elevation: 0,
      scrolledUnderElevation: 2,
      shadowColor: Colors.black26,
      titleTextStyle: TextStyle(
        color: Colors.white,
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
      iconTheme: IconThemeData(color: Colors.white),
      actionsIconTheme: IconThemeData(color: Colors.white),
    ),

    cardTheme: CardThemeData(
      color: _cardLight,
      elevation: 4,
      shadowColor: Colors.black.withOpacity(0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: 3,
        shadowColor: Colors.black26,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        textStyle: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
    ),

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: _surfaceLight,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: _dividerLight, width: 1.5),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: _dividerLight, width: 1.5),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: _primaryLight, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    ),

    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: _surfaceLight,
      selectedItemColor: _primaryLight,
      unselectedItemColor: Color(0xFF757575),
      elevation: 8,
      type: BottomNavigationBarType.fixed,
      selectedLabelStyle: TextStyle(fontWeight: FontWeight.w600),
    ),

    drawerTheme: const DrawerThemeData(
      backgroundColor: _surfaceLight,
      elevation: 16,
      shadowColor: Colors.black26,
    ),

    dividerTheme: const DividerThemeData(
      color: _dividerLight,
      thickness: 1,
      space: 1,
    ),

    textTheme: const TextTheme(
      headlineLarge: TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        color: Color(0xFF1A1A1A),
        letterSpacing: -0.5,
      ),
      headlineMedium: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: Color(0xFF1A1A1A),
        letterSpacing: -0.25,
      ),
      titleLarge: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: Color(0xFF1A1A1A),
      ),
      titleMedium: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: Color(0xFF424242),
      ),
      bodyLarge: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: Color(0xFF424242),
        height: 1.4,
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: Color(0xFF616161),
        height: 1.4,
      ),
      labelLarge: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: Color(0xFF424242),
        letterSpacing: 0.1,
      ),
    ),
  );

  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: const ColorScheme.dark(
      primary: _primaryDark,
      primaryContainer: Color(0xFF1A237E),
      secondary: _secondaryDark,
      secondaryContainer: Color(0xFF00838F),
      surface: _surfaceDark,
      surfaceContainer: _cardDark,
      background: _backgroundDark,
      error: error,
      onPrimary: Colors.black,
      onSecondary: Colors.black,
      onSurface: Color(0xFFE8E8E8),
      onBackground: Color(0xFFE8E8E8),
      onError: Colors.white,
      outline: _dividerDark,
    ),

    appBarTheme: const AppBarTheme(
      backgroundColor: _surfaceDark,
      foregroundColor: Color(0xFFE8E8E8),
      elevation: 0,
      scrolledUnderElevation: 2,
      shadowColor: Colors.black54,
      titleTextStyle: TextStyle(
        color: Color(0xFFE8E8E8),
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
      iconTheme: IconThemeData(color: Color(0xFFE8E8E8)),
      actionsIconTheme: IconThemeData(color: Color(0xFFE8E8E8)),
    ),

    cardTheme: CardThemeData(
      color: _cardDark,
      elevation: 6,
      shadowColor: Colors.black.withOpacity(0.3),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: 4,
        shadowColor: Colors.black45,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        textStyle: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
    ),

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: _cardDark,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: _dividerDark, width: 1.5),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: _dividerDark, width: 1.5),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: _primaryDark, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    ),

    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: _surfaceDark,
      selectedItemColor: _primaryDark,
      unselectedItemColor: Color(0xFF9E9E9E),
      elevation: 8,
      type: BottomNavigationBarType.fixed,
      selectedLabelStyle: TextStyle(fontWeight: FontWeight.w600),
    ),

    drawerTheme: const DrawerThemeData(
      backgroundColor: _surfaceDark,
      elevation: 16,
      shadowColor: Colors.black54,
    ),

    dividerTheme: const DividerThemeData(
      color: _dividerDark,
      thickness: 1,
      space: 1,
    ),

    textTheme: const TextTheme(
      headlineLarge: TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        color: Color(0xFFE8E8E8),
        letterSpacing: -0.5,
      ),
      headlineMedium: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: Color(0xFFE8E8E8),
        letterSpacing: -0.25,
      ),
      titleLarge: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: Color(0xFFE8E8E8),
      ),
      titleMedium: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: Color(0xFFBDBDBD),
      ),
      bodyLarge: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: Color(0xFFBDBDBD),
        height: 1.4,
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: Color(0xFF9E9E9E),
        height: 1.4,
      ),
      labelLarge: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: Color(0xFFBDBDBD),
        letterSpacing: 0.1,
      ),
    ),
  );

  // Custom gradient decorations
  static BoxDecoration lightGradientCard = BoxDecoration(
    gradient: const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFFF8FAFF), Color(0xFFE3F2FD)],
    ),
    borderRadius: BorderRadius.circular(16),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.05),
        blurRadius: 8,
        offset: const Offset(0, 4),
      ),
    ],
  );

  static BoxDecoration darkGradientCard = BoxDecoration(
    gradient: const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFF2A2A2A), Color(0xFF1E1E1E)],
    ),
    borderRadius: BorderRadius.circular(16),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.3),
        blurRadius: 12,
        offset: const Offset(0, 6),
      ),
    ],
  );

  static BoxDecoration lightHeaderGradient = const BoxDecoration(
    gradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFF1565C0), Color(0xFF0D47A1)],
    ),
  );

  static BoxDecoration darkHeaderGradient = const BoxDecoration(
    gradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFF1E1E1E), Color(0xFF2A2A2A)],
    ),
  );
}