import 'package:flutter/material.dart';
import 'package:pezshkyar/config/app_routes.dart';
import 'package:pezshkyar/config/constants.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:pezshkyar/config/theme.dart';
import 'package:pezshkyar/services/storage_service.dart';
import 'package:pezshkyar/screens/chat_screen.dart';
import 'package:pezshkyar/screens/settings_screen.dart';

class CustomDrawer extends StatelessWidget {
  final StorageService storageService;

  const CustomDrawer({Key? key, required this.storageService})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Drawer(
      elevation: 8,
      child: Container(
        color: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
        child: Column(
          children: [
            // Drawer header with logo
            Container(
              height: 180,
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppConstants.primaryColor,
                    AppConstants.secondaryColor,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Hero(
                    tag: 'drawer_logo',
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: ClipOval(
                        child: Image.asset(
                          'icons/app_icon.png',
                          width: 80,
                          height: 80,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            // Fallback to icon if image fails to load
                            return Icon(
                              Icons.medical_services,
                              color: AppConstants.primaryColor,
                              size: 40,
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    AppConstants.appName,
                    style: GoogleFonts.vazirmatn(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      shadows: [
                        Shadow(
                          color: Colors.black.withOpacity(0.2),
                          offset: const Offset(0, 2),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Drawer items
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  _buildDrawerItem(
                    context: context,
                    icon: Icons.home,
                    title: 'خانه',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              ChatScreen(storageService: storageService),
                        ),
                      );
                    },
                  ),
                  _buildDrawerItem(
                    context: context,
                    icon: Icons.info,
                    title: 'درباره ما',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, AppRoutes.aboutScreen);
                    },
                  ),
                  _buildDrawerItem(
                    context: context,
                    icon: Icons.help,
                    title: 'راهنما',
                    onTap: () {
                      Navigator.pop(context);
                      _showGuideDialog(context);
                    },
                  ),
                  _buildDrawerItem(
                    context: context,
                    icon: Icons.settings,
                    title: 'تنظیمات',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              SettingsScreen(storageService: storageService),
                        ),
                      );
                    },
                  ),
                  const Divider(height: 1, thickness: 1),
                  _buildDrawerItem(
                    context: context,
                    icon: isDarkMode ? Icons.light_mode : Icons.dark_mode,
                    title: isDarkMode ? 'حالت روشن' : 'حالت تاریک',
                    onTap: () {
                      themeProvider.setThemeMode(
                        isDarkMode ? ThemeMode.light : ThemeMode.dark,
                      );
                      Navigator.pop(context);
                    },
                  ),
                  _buildDrawerItem(
                    context: context,
                    icon: Icons.exit_to_app,
                    title: 'خروج',
                    onTap: () {
                      Navigator.pop(context);
                      _showExitDialog(context);
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerItem({
    required BuildContext context,
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        splashColor: AppConstants.primaryColor.withOpacity(0.2),
        highlightColor: AppConstants.primaryColor.withOpacity(0.1),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppConstants.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: AppConstants.primaryColor, size: 22),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.vazirmatn(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: isDarkMode ? Colors.white : Colors.black87,
                  ),
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: isDarkMode ? Colors.white54 : Colors.black54,
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showGuideDialog(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (context) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppConstants.primaryColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.help,
                  color: AppConstants.primaryColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'راهنمای استفاده',
                style: GoogleFonts.vazirmatn(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppConstants.primaryColor,
                ),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildGuideStep(
                  number: '۱',
                  text: 'در کادر پایین صفحه، سوال پزشکی خود را وارد کنید.',
                  isDarkMode: isDarkMode,
                ),
                _buildGuideStep(
                  number: '۲',
                  text:
                      'برای ارسال پیام، روی دکمه ارسال (آیکون هواپیما) کلیک کنید.',
                  isDarkMode: isDarkMode,
                ),
                _buildGuideStep(
                  number: '۳',
                  text: 'پس از مدت کوتاهی، پاسخ پزشک هوشمند نمایش داده می‌شود.',
                  isDarkMode: isDarkMode,
                ),
                _buildGuideStep(
                  number: '۴',
                  text: 'تاریخچه گفتگوها در برنامه ذخیره می‌شود.',
                  isDarkMode: isDarkMode,
                ),
                _buildGuideStep(
                  number: '۵',
                  text: 'برای پاک کردن تاریخچه، به بخش تنظیمات مراجعه کنید.',
                  isDarkMode: isDarkMode,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              style: TextButton.styleFrom(
                foregroundColor: AppConstants.primaryColor,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
              ),
              child: Text(
                'متوجه شدم',
                style: GoogleFonts.vazirmatn(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGuideStep({
    required String number,
    required String text,
    required bool isDarkMode,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: AppConstants.primaryColor,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                number,
                style: GoogleFonts.vazirmatn(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.vazirmatn(
                fontSize: 14,
                color: isDarkMode ? Colors.white : Colors.black87,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showExitDialog(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (context) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.exit_to_app, color: Colors.red, size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                'خروج از برنامه',
                style: GoogleFonts.vazirmatn(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),
            ],
          ),
          content: Text(
            'آیا از خروج از برنامه مطمئن هستید؟',
            style: GoogleFonts.vazirmatn(
              fontSize: 16,
              color: isDarkMode ? Colors.white : Colors.black87,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              style: TextButton.styleFrom(
                foregroundColor: AppConstants.primaryColor,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
              ),
              child: Text(
                'خیر',
                style: GoogleFonts.vazirmatn(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                'بله',
                style: GoogleFonts.vazirmatn(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
