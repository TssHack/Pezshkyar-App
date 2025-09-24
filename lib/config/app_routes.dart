import 'package:flutter/material.dart';
import 'package:pezshkyar/screens/about_screen.dart';
import 'package:pezshkyar/screens/chat_screen.dart';
import 'package:pezshkyar/screens/settings_screen.dart';
import 'package:pezshkyar/services/storage_service.dart';

class AppRoutes {
  static const String chatScreen = '/chat';
  static const String aboutScreen = '/about';
  static const String settingsScreen = '/settings';

  static Map<String, WidgetBuilder> routes(StorageService storageService) {
    return {
      chatScreen: (context) => ChatScreen(storageService: storageService),
      aboutScreen: (context) => const AboutScreen(),
      settingsScreen: (context) =>
          SettingsScreen(storageService: storageService),
    };
  }
}
