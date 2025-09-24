import 'package:flutter/material.dart';
import 'package:pezshkyar/services/storage_service.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pezshkyar/config/constants.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsScreen extends StatefulWidget {
  final StorageService storageService;

  const SettingsScreen({Key? key, required this.storageService})
    : super(key: key);

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late StorageService _storageService;
  bool _notificationsEnabled = true;
  bool _soundEnabled = true;
  bool _vibrationEnabled = true;
  String _appVersion = '1.0.0';

  @override
  void initState() {
    super.initState();
    _storageService = widget.storageService;
    _loadSettings();
    _loadPackageInfo();
  }

  Future<void> _loadSettings() async {
    try {
      final settings = await _storageService.getSettings();
      setState(() {
        _notificationsEnabled = settings['notificationsEnabled'] ?? true;
        _soundEnabled = settings['soundEnabled'] ?? true;
        _vibrationEnabled = settings['vibrationEnabled'] ?? true;
      });
    } catch (e) {
      debugPrint('Error loading settings: $e');
    }
  }

  Future<void> _loadPackageInfo() async {
    try {
      setState(() {
        _appVersion = '1.0.0';
      });
    } catch (e) {
      debugPrint('Error loading package info: $e');
      setState(() {
        _appVersion = '1.0.0';
      });
    }
  }

  Future<void> _saveSettings() async {
    try {
      await _storageService.saveSettings({
        'notificationsEnabled': _notificationsEnabled,
        'soundEnabled': _soundEnabled,
        'vibrationEnabled': _vibrationEnabled,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'تنظیمات با موفقیت ذخیره شد.',
            style: GoogleFonts.vazirmatn(),
          ),
          backgroundColor: AppConstants.primaryColor,
        ),
      );
    } catch (e) {
      debugPrint('Error saving settings: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'خطا در ذخیره تنظیمات.',
            style: GoogleFonts.vazirmatn(),
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<bool> _showConfirmationDialog({
    required String title,
    required String content,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          title: Text(
            title,
            style: GoogleFonts.vazirmatn(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppConstants.primaryColor,
            ),
          ),
          content: Text(content, style: GoogleFonts.vazirmatn(fontSize: 16)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(
                'خیر',
                style: GoogleFonts.vazirmatn(
                  fontSize: 16,
                  color: AppConstants.primaryColor,
                ),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(
                'بله',
                style: GoogleFonts.vazirmatn(fontSize: 16, color: Colors.red),
              ),
            ),
          ],
        ),
      ),
    );

    return result ?? false;
  }

  Future<void> _shareApp() async {
    await Share.share(
      'برنامه پزشکیار را دانلود کنید!\n\nبرای دریافت اطلاعات پزشکی دقیق و سریع.',
      subject: 'معرفی برنامه پزشکیار',
    );
  }

  Future<void> _contactSupport() async {
    final emailUrl = Uri.parse(
      'mailto:ehsanfazlinejad@gmail.com?subject=پشتیبانی برنامه پزشکیار&body=مشکل یا پیشنهاد من:',
    );
    if (await canLaunchUrl(emailUrl)) {
      await launchUrl(emailUrl);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'تنظیمات',
          style: GoogleFonts.vazirmatn(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(icon: const Icon(Icons.save), onPressed: _saveSettings),
        ],
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDarkMode
                ? [const Color(0xFF1E1E1E), const Color(0xFF121212)]
                : [
                    AppConstants.primaryColor.withOpacity(0.1),
                    AppConstants.secondaryColor.withOpacity(0.1),
                  ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // تنظیمات اعلان‌ها
              _buildSectionTitle('تنظیمات اعلان‌ها', isDarkMode),
              _buildSettingsCard([
                _buildSwitchTile(
                  title: 'اعلان‌ها',
                  subtitle: 'دریافت اعلان‌های برنامه',
                  value: _notificationsEnabled,
                  onChanged: (value) {
                    setState(() {
                      _notificationsEnabled = value;
                    });
                  },
                  icon: Icons.notifications,
                ),
                _buildDivider(),
                _buildSwitchTile(
                  title: 'صدا',
                  subtitle: 'پخش صدا در اعلان‌ها',
                  value: _soundEnabled,
                  onChanged: (value) {
                    setState(() {
                      _soundEnabled = value;
                    });
                  },
                  icon: Icons.volume_up,
                ),
                _buildDivider(),
                _buildSwitchTile(
                  title: 'لرزش',
                  subtitle: 'لرزش در اعلان‌ها',
                  value: _vibrationEnabled,
                  onChanged: (value) {
                    setState(() {
                      _vibrationEnabled = value;
                    });
                  },
                  icon: Icons.vibration,
                ),
              ], isDarkMode),

              const SizedBox(height: 24),

              // اطلاعات برنامه
              _buildSectionTitle('اطلاعات برنامه', isDarkMode),
              _buildSettingsCard([
                _buildInfoTile(
                  title: 'نسخه برنامه',
                  value: _appVersion,
                  icon: Icons.info,
                ),
                _buildDivider(),
                _buildInfoTile(
                  title: 'توسعه‌دهنده',
                  value: 'احسان فضلی',
                  icon: Icons.person,
                ),
                _buildDivider(),
                _buildNavigationTile(
                  title: 'تماس با پشتیبانی',
                  subtitle: 'ارسال ایمیل به تیم پشتیبانی',
                  icon: Icons.support_agent,
                  onTap: _contactSupport,
                ),
                _buildDivider(),
                _buildNavigationTile(
                  title: 'اشتراک گذاری برنامه',
                  subtitle: 'معرفی برنامه به دوستان',
                  icon: Icons.share,
                  onTap: _shareApp,
                ),
              ], isDarkMode),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, bool isDarkMode) {
    return Text(
      title,
      style: GoogleFonts.vazirmatn(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: isDarkMode ? Colors.white : Colors.black87,
      ),
    );
  }

  Widget _buildSettingsCard(List<Widget> children, bool isDarkMode) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: isDarkMode ? const Color(0xFF2E2E2E) : Colors.white,
      child: Column(children: children),
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
    required IconData icon,
  }) {
    return SwitchListTile(
      secondary: Icon(icon, color: AppConstants.primaryColor),
      title: Text(
        title,
        style: GoogleFonts.vazirmatn(fontSize: 16, fontWeight: FontWeight.w500),
      ),
      subtitle: Text(
        subtitle,
        style: GoogleFonts.vazirmatn(fontSize: 14, color: Colors.grey),
      ),
      value: value,
      onChanged: onChanged,
      activeColor: AppConstants.primaryColor,
    );
  }

  Widget _buildNavigationTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: AppConstants.primaryColor),
      title: Text(
        title,
        style: GoogleFonts.vazirmatn(fontSize: 16, fontWeight: FontWeight.w500),
      ),
      subtitle: Text(
        subtitle,
        style: GoogleFonts.vazirmatn(fontSize: 14, color: Colors.grey),
      ),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }

  Widget _buildInfoTile({
    required String title,
    required String value,
    required IconData icon,
  }) {
    return ListTile(
      leading: Icon(icon, color: AppConstants.primaryColor),
      title: Text(
        title,
        style: GoogleFonts.vazirmatn(fontSize: 16, fontWeight: FontWeight.w500),
      ),
      subtitle: Text(
        value,
        style: GoogleFonts.vazirmatn(fontSize: 14, color: Colors.grey),
      ),
    );
  }

  Widget _buildDivider() {
    return const Divider(height: 1, indent: 16, endIndent: 16);
  }
}
