import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:pezshkyar/config/app_routes.dart';
import 'package:pezshkyar/config/theme.dart';
import 'package:pezshkyar/screens/splash_screen.dart';
import 'package:pezshkyar/screens/chat_screen.dart';
import 'package:pezshkyar/screens/settings_screen.dart';
import 'package:provider/provider.dart';
import 'package:pezshkyar/services/storage_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize storage service and wait for it to complete
  final storageService = StorageService();
  await storageService.init();

  runApp(
    ChangeNotifierProvider(
      create: (context) => ThemeProvider(),
      child: pezshkyarApp(storageService: storageService),
    ),
  );
}

class pezshkyarApp extends StatelessWidget {
  final StorageService storageService;

  const pezshkyarApp({Key? key, required this.storageService})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          title: 'پزشکیار',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: themeProvider.themeMode,
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [Locale('fa', 'IR')],
          locale: const Locale('fa', 'IR'),
          home: SplashScreen(storageService: storageService),
          routes: AppRoutes.routes(storageService),
          onGenerateRoute: (settings) {
            // Handle routes that require parameters
            if (settings.name == AppRoutes.chatScreen) {
              return MaterialPageRoute(
                builder: (context) =>
                    ChatScreen(storageService: storageService),
                settings: settings,
              );
            } else if (settings.name == AppRoutes.settingsScreen) {
              return MaterialPageRoute(
                builder: (context) =>
                    SettingsScreen(storageService: storageService),
                settings: settings,
              );
            }
            return null;
          },
        );
      },
    );
  }
}
