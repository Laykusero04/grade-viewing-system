import 'package:flutter/material.dart';

class AppTheme {
  // Main colors
  static const Color orange = Color(0xFFFF9800);
  static const Color beige = Color(0xFFF5F5DC);
  static const Color darkOrange = Color(0xFFE65100);

  // Dark mode background and text colors
  static const Color darkBackground = Color(0xFF121212);
  static const Color darkSurface = Color(0xFF1E1E1E);

  // Color assignments
  static const Color primaryColor = orange;
  static const Color backgroundColor = darkBackground;
  static const Color surfaceColor = darkSurface;
  static const Color accentColor = darkOrange;

  static const Color textPrimaryColor = Colors.white;
  static const Color textSecondaryColor = Colors.white70;

  // Text styless
  static const TextStyle headlineStyle = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: textPrimaryColor,
  );

  static const TextStyle titleStyle = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: textPrimaryColor,
  );

  static const TextStyle bodyStyle = TextStyle(
    fontSize: 16,
    color: textSecondaryColor,
  );

  // Card decoration
  static BoxDecoration cardDecoration = BoxDecoration(
    color: surfaceColor,
    borderRadius: BorderRadius.circular(12),
    border: Border.all(color: primaryColor.withOpacity(0.5), width: 10),
  );

  // Button style
  static ButtonStyle primaryButtonStyle = ElevatedButton.styleFrom(
    backgroundColor: accentColor,
    foregroundColor: textPrimaryColor,
    padding: EdgeInsets.symmetric(vertical: 16, horizontal: 24),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8),
    ),
  );

  // Dark Theme
  static final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: primaryColor,
    scaffoldBackgroundColor: backgroundColor,
    colorScheme: ColorScheme.dark(
      primary: primaryColor,
      secondary: accentColor,
      surface: surfaceColor,
      background: backgroundColor,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: surfaceColor,
      foregroundColor: textPrimaryColor,
      elevation: 0,
    ),
    cardTheme: CardTheme(
      color: surfaceColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: primaryColor.withOpacity(0.5), width: 1),
      ),
    ),
    textTheme: TextTheme(
      headlineLarge: headlineStyle,
      titleLarge: titleStyle,
      bodyLarge: bodyStyle,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: primaryButtonStyle,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: surfaceColor,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: primaryColor.withOpacity(0.5)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: primaryColor),
      ),
      labelStyle: TextStyle(color: textSecondaryColor),
      hintStyle: TextStyle(color: textSecondaryColor.withOpacity(0.7)),
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: surfaceColor,
      selectedItemColor: primaryColor,
      unselectedItemColor: textSecondaryColor,
    ),
  );
}
