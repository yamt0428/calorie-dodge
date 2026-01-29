import 'package:flutter/material.dart';

/// GitHubライクなシンプルで洗練されたテーマ
class AppTheme {
  // GitHub風の色
  static const Color primaryGreen = Color(0xFF238636);
  static const Color lightGreen1 = Color(0xFF9be9a8);
  static const Color lightGreen2 = Color(0xFF40c463);
  static const Color lightGreen3 = Color(0xFF30a14e);
  static const Color darkGreen = Color(0xFF216e39);
  static const Color todayBorderColor = Color.fromARGB(255, 255, 94, 94);
  static const Color weightAndFatIconColor = Color.fromARGB(255, 156, 170, 30);

  static const Color backgroundColor = Color(0xFFF6F8FA);
  static const Color cardColor = Colors.white;
  static const Color textPrimary = Color(0xFF24292F);
  static const Color textSecondary = Color(0xFF57606A);
  static const Color borderColor = Color(0xFFD0D7DE);
  static const Color grayLight = Color(0xFFEBEDF0);

  /// ヒートマップの色（カロリー量に応じた緑の濃淡）
  static Color getHeatmapColor(int calories) {
    if (calories == 0) {
      return grayLight;
    } else if (calories <= 300) {
      return lightGreen1;
    } else if (calories <= 600) {
      return lightGreen2;
    } else if (calories <= 1000) {
      return lightGreen3;
    } else {
      return darkGreen;
    }
  }

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryGreen,
        brightness: Brightness.light,
        primary: primaryGreen,
        surface: backgroundColor,
      ),
      scaffoldBackgroundColor: backgroundColor,
      cardTheme: CardThemeData(
        color: cardColor,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: borderColor),
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: cardColor,
        foregroundColor: textPrimary,
        elevation: 0,
        centerTitle: true,
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: primaryGreen,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryGreen,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: borderColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: borderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: primaryGreen, width: 2),
        ),
        filled: true,
        fillColor: cardColor,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: cardColor,
        selectedItemColor: primaryGreen,
        unselectedItemColor: textSecondary,
      ),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          color: textPrimary,
          fontWeight: FontWeight.bold,
        ),
        headlineMedium: TextStyle(
          color: textPrimary,
          fontWeight: FontWeight.bold,
        ),
        titleLarge: TextStyle(
          color: textPrimary,
          fontWeight: FontWeight.w600,
        ),
        bodyLarge: TextStyle(color: textPrimary),
        bodyMedium: TextStyle(color: textSecondary),
      ),
    );
  }
}
