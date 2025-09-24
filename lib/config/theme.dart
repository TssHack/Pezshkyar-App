import 'package:flutter/material.dart';
import 'package:pezshkyar/config/constants.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;

  ThemeMode get themeMode => _themeMode;

  ThemeProvider() {
    _loadTheme();
  }

  void _loadTheme() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final themeIndex = prefs.getInt(AppConstants.themeModeKey) ?? 0;

      if (themeIndex == 0) {
        _themeMode = ThemeMode.system;
      } else if (themeIndex == 1) {
        _themeMode = ThemeMode.light;
      } else {
        _themeMode = ThemeMode.dark;
      }

      notifyListeners();
    } catch (e) {
      // If there's an error loading theme, default to system
      _themeMode = ThemeMode.system;
      notifyListeners();
    }
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (mode == ThemeMode.system) {
        await prefs.setInt(AppConstants.themeModeKey, 0);
      } else if (mode == ThemeMode.light) {
        await prefs.setInt(AppConstants.themeModeKey, 1);
      } else {
        await prefs.setInt(AppConstants.themeModeKey, 2);
      }

      _themeMode = mode;
      notifyListeners();
    } catch (e) {
      // If there's an error saving theme, don't update the state
      debugPrint('Error saving theme: $e');
    }
  }

  void toggleThemeMode() {
    if (_themeMode == ThemeMode.system) {
      setThemeMode(ThemeMode.light);
    } else if (_themeMode == ThemeMode.light) {
      setThemeMode(ThemeMode.dark);
    } else {
      setThemeMode(ThemeMode.system);
    }
  }
}

class AppTheme {
  static final lightTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppConstants.primaryColor,
      brightness: Brightness.light,
      primary: AppConstants.primaryColor,
      secondary: AppConstants.secondaryColor,
    ),
    scaffoldBackgroundColor: Colors.white,
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.white,
      elevation: 0,
      foregroundColor: AppConstants.primaryColor,
      centerTitle: true,
      titleTextStyle: GoogleFonts.vazirmatn(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: AppConstants.primaryColor,
      ),
    ),
    textTheme: TextTheme(
      bodyLarge: GoogleFonts.vazirmatn(fontSize: 16, color: Colors.black87),
      bodyMedium: GoogleFonts.vazirmatn(fontSize: 14, color: Colors.black87),
      titleLarge: GoogleFonts.vazirmatn(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: AppConstants.primaryColor,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppConstants.primaryColor,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        elevation: 4,
      ),
    ),
    cardTheme: CardThemeData(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: Colors.white,
    ),
  );

  static final darkTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppConstants.primaryColor,
      brightness: Brightness.dark,
      primary: AppConstants.primaryColor,
      secondary: AppConstants.secondaryColor,
    ),
    scaffoldBackgroundColor: const Color(0xFF121212),
    appBarTheme: AppBarTheme(
      backgroundColor: const Color(0xFF1E1E1E),
      elevation: 0,
      foregroundColor: AppConstants.primaryColor,
      centerTitle: true,
      titleTextStyle: GoogleFonts.vazirmatn(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: AppConstants.primaryColor,
      ),
    ),
    textTheme: TextTheme(
      bodyLarge: GoogleFonts.vazirmatn(fontSize: 16, color: Colors.white),
      bodyMedium: GoogleFonts.vazirmatn(fontSize: 14, color: Colors.white70),
      titleLarge: GoogleFonts.vazirmatn(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: AppConstants.primaryColor,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppConstants.primaryColor,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        elevation: 4,
      ),
    ),
    cardTheme: CardThemeData(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: const Color(0xFF2E2E2E),
    ),
  );
}
