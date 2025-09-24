import 'package:flutter/material.dart';

class AppConstants {
  static const String appName = 'پزشکیار';
  static const String apiBaseUrl =
      'https://docter-api.vercel.app/api/doctor-chat';

  // Asset paths
  static const String logoPath = 'assets/images/logo.png';
  static const String doctorAvatarPath = 'assets/images/doctor_avatar.png';
  static const String loadingAnimationPath =
      'assets/animations/doctor_thinking.json';
  static const String splashAnimationPath =
      'assets/animations/heart_pulse.json';

  // Colors
  static const Color primaryColor = Color(0xFF26A69A);
  static const Color secondaryColor = Color(0xFF4FC3F7);
  static const Color accentColor = Color(0xFF80CBC4);
  static const Color lightGreen = Color(0xFFA5D6A7);
  static const Color lightBlue = Color(0xFF81D4FA);

  // SharedPreferences keys
  static const String chatHistoryKey = 'chat_history';
  static const String themeModeKey = 'theme_mode';
}
