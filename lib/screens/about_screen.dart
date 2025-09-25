import 'package:flutter/material.dart';
import 'package:glassmorphism/glassmorphism.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pezshkyar/config/constants.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;

class AboutScreen extends StatefulWidget {
  const AboutScreen({Key? key}) : super(key: key);

  @override
  _AboutScreenState createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutQuad));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'درباره ما',
            style: GoogleFonts.vazirmatn(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
          elevation: 0,
          backgroundColor: Colors.transparent,
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
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  // Developer avatar with animation
                  SlideTransition(
                    position: _slideAnimation,
                    child: GlassmorphicContainer(
                      width: 200,
                      height: 200,
                      borderRadius: 100,
                      blur: 20,
                      alignment: Alignment.center,
                      border: 2,
                      linearGradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          AppConstants.primaryColor.withOpacity(0.3),
                          AppConstants.secondaryColor.withOpacity(0.2),
                        ],
                      ),
                      borderGradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          AppConstants.primaryColor.withOpacity(0.7),
                          AppConstants.secondaryColor.withOpacity(0.7),
                        ],
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isDarkMode ? Colors.white12 : Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 15,
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                        child: ClipOval(
                          child: Image.asset(
                            'assets/images/ehsan.png',
                            width: 180,
                            height: 180,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Icon(
                                Icons.person,
                                color: AppConstants.primaryColor,
                                size: 80,
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Developer name with animation
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: Text(
                      'احسان فضلی',
                      style: GoogleFonts.vazirmatn(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: isDarkMode ? Colors.white : Colors.black87,
                      ),
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Developer title with animation
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: Text(
                      'توسعه‌دهنده اپلیکیشن',
                      style: GoogleFonts.vazirmatn(
                        fontSize: 16,
                        color: isDarkMode ? Colors.white70 : Colors.black54,
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),

                  // Contact information with animation
                  SlideTransition(
                    position: _slideAnimation,
                    child: GlassmorphicContainer(
                      width: double.infinity,
                      height: size.height * 0.18,
                      borderRadius: 24,
                      blur: 15,
                      alignment: Alignment.center,
                      border: 1,
                      linearGradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: isDarkMode
                            ? [
                                Colors.white.withOpacity(0.1),
                                Colors.white.withOpacity(0.05),
                              ]
                            : [
                                Colors.white.withOpacity(0.2),
                                Colors.white.withOpacity(0.1),
                              ],
                      ),
                      borderGradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          AppConstants.primaryColor.withOpacity(0.4),
                          AppConstants.secondaryColor.withOpacity(0.4),
                        ],
                      ),
                      child: Container(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _buildContactItem(
                              icon: Icons.email,
                              title: 'ایمیل',
                              value: 'ehsanfazlinejad@gmail.com',
                              isDarkMode: isDarkMode,
                              onTap: () => _launchURL(
                                'mailto:ehsanfazlinejad@gmail.com',
                              ),
                            ),
                            const SizedBox(height: 16),
                            _buildContactItem(
                              icon: Icons.language,
                              title: 'وب‌سایت',
                              value: 'ehsanjs.ir',
                              isDarkMode: isDarkMode,
                              onTap: () => _launchURL('https://ehsanjs.ir'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),

                  // App information with animation
                  SlideTransition(
                    position: _slideAnimation,
                    child: GlassmorphicContainer(
                      width: double.infinity,
                      height: 200,
                      borderRadius: 24,
                      blur: 15,
                      alignment: Alignment.center,
                      border: 1,
                      linearGradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: isDarkMode
                            ? [
                                Colors.white.withOpacity(0.1),
                                Colors.white.withOpacity(0.05),
                              ]
                            : [
                                Colors.white.withOpacity(0.2),
                                Colors.white.withOpacity(0.1),
                              ],
                      ),
                      borderGradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          AppConstants.primaryColor.withOpacity(0.4),
                          AppConstants.secondaryColor.withOpacity(0.4),
                        ],
                      ),
                      child: Container(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'درباره اپلیکیشن',
                              style: GoogleFonts.vazirmatn(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: isDarkMode
                                    ? Colors.white
                                    : Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Expanded(
                              child: Text(
                                'پزشکیار یک دستیار پزشکی هوشمند است که به شما کمک می‌کند تا به سوالات پزشکی خود پاسخ دهید. این اپلیکیشن با استفاده از هوش مصنوعی، پاسخ‌های دقیق و قابل اعتمادی را در اختیار شما قرار می‌دهد.',
                                style: GoogleFonts.vazirmatn(
                                  fontSize: 14,
                                  height: 1.6,
                                  color: isDarkMode
                                      ? Colors.white70
                                      : Colors.black54,
                                ),
                                textAlign: TextAlign.justify,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'نسخه: 1.0.0',
                              style: GoogleFonts.vazirmatn(
                                fontSize: 14,
                                color: isDarkMode
                                    ? Colors.white70
                                    : Colors.black54,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),

                  // Feedback button with animation
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: Container(
                      width: double.infinity,
                      height: 50,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30),
                        gradient: LinearGradient(
                          colors: [
                            AppConstants.primaryColor,
                            AppConstants.secondaryColor,
                          ],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppConstants.primaryColor.withOpacity(0.3),
                            blurRadius: 10,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: MaterialButton(
                        onPressed: () {
                          _showFeedbackDialog(context);
                        },
                        child: Text(
                          'ارسال بازخورد',
                          style: GoogleFonts.vazirmatn(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),

                  // Footer with animation
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: Text(
                      '© ۱۴۰۴ - تمامی حقوق محفوظ است',
                      style: GoogleFonts.vazirmatn(
                        fontSize: 12,
                        color: isDarkMode ? Colors.white54 : Colors.black38,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContactItem({
    required IconData icon,
    required String title,
    required String value,
    required bool isDarkMode,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: AppConstants.primaryColor.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: AppConstants.primaryColor, size: 22),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.vazirmatn(
                    fontSize: 14,
                    color: isDarkMode ? Colors.white70 : Colors.black54,
                  ),
                ),
                Text(
                  value,
                  style: GoogleFonts.vazirmatn(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: isDarkMode ? Colors.white : Colors.black87,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showFeedbackDialog(BuildContext context) {
    final TextEditingController _feedbackController = TextEditingController();
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (context) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          title: Text(
            'ارسال بازخورد',
            style: GoogleFonts.vazirmatn(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDarkMode ? Colors.white : Colors.black87,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'نظرات و پیشنهادات خود را با ما در میان بگذارید:',
                style: GoogleFonts.vazirmatn(
                  fontSize: 14,
                  color: isDarkMode ? Colors.white70 : Colors.black54,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _feedbackController,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: 'متن بازخورد خود را اینجا بنویسید...',
                  hintStyle: GoogleFonts.vazirmatn(
                    fontSize: 14,
                    color: isDarkMode ? Colors.white38 : Colors.black38,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: AppConstants.primaryColor,
                      width: 2,
                    ),
                  ),
                ),
                style: GoogleFonts.vazirmatn(
                  fontSize: 14,
                  color: isDarkMode ? Colors.white : Colors.black87,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'انصراف',
                style: GoogleFonts.vazirmatn(
                  fontSize: 14,
                  color: AppConstants.primaryColor,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                if (_feedbackController.text.isNotEmpty) {
                  await _sendFeedbackToTelegram(_feedbackController.text);
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'بازخورد شما با موفقیت ارسال شد!',
                        style: GoogleFonts.vazirmatn(fontSize: 14),
                      ),
                      backgroundColor: AppConstants.primaryColor,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppConstants.primaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                'ارسال',
                style: GoogleFonts.vazirmatn(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ],
          backgroundColor: isDarkMode ? const Color(0xFF2E2E2E) : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }

  Future<void> _sendFeedbackToTelegram(String message) async {
    const chatId = '-1002980426809';

    final url = 'https://mssagerr.vercel.app/sendMessage';

    try {
      await http.post(
        Uri.parse(url),
        body: {
          'chat_id': chatId,
          'text': 'بازخورد جدید از اپلیکیشن پزشکیار:\n\n$message',
        },
      );
    } catch (e) {
      debugPrint('Error sending feedback to Telegram: $e');
    }
  }

  Future<void> _launchURL(String url) async {
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'خطا در باز کردن لینک',
            style: GoogleFonts.vazirmatn(fontSize: 14),
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}


