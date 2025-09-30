import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pezshkyar/config/constants.dart';
import 'package:pezshkyar/models/message_model.dart';
import 'package:pezshkyar/services/api_service.dart';
import 'package:pezshkyar/services/notification_service.dart';
import 'package:pezshkyar/services/storage_service.dart';
import 'package:pezshkyar/widgets/chat_bubble.dart';
import 'package:pezshkyar/widgets/custom_drawer.dart';
import 'package:pezshkyar/widgets/glass_input_box.dart';
import 'package:pezshkyar/widgets/typing_indicator.dart';
import 'package:lottie/lottie.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter/scheduler.dart' show timeDilation;
import 'package:shimmer/shimmer.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:animations/animations.dart';
import 'package:share_plus/share_plus.dart';

class ChatScreen extends StatefulWidget {
  final StorageService storageService;

  const ChatScreen({Key? key, required this.storageService}) : super(key: key);

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> with TickerProviderStateMixin {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final ApiService _apiService = ApiService();
  final NotificationService _notificationService = NotificationService();

  late StorageService _storageService;
  List<Message> _messages = [];
  bool _isLoading = false;
  bool _showTypingIndicator = false;

  // Track expanded state for each message
  final Map<int, bool> _expandedMessages = {};

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;
  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;
  late AnimationController _shimmerController;
  late Animation<double> _shimmerAnimation;
  late AnimationController _quickRepliesController;
  late Animation<double> _quickRepliesAnimation;
  late AnimationController _bubbleController;
  late Animation<double> _bubbleAnimation;
  late AnimationController _expandButtonController;
  late Animation<double> _expandButtonAnimation;

  // Expanded list of quick replies
  final List<String> _allQuickReplies = [
    'علت سردرد چیست؟',
    'علائم دیابت چیست؟',
    'چگونه فشار خون را پایین بیاوریم؟',
    'درمان سرماخوردگی چیست؟',
    'علت کم‌خونی چیست؟',
    'علائم کرونا چیست؟',
    'چگونه وزن کم کنیم؟',
    'درمان سوءهاضمه چیست؟',
    'علت بی‌خوابی چیست؟',
    'چگونه استرس را کنترل کنیم؟',
    'علائم آلرژی چیست؟',
    'درمان گلودرد چیست؟',
    'علائم یبوست چیست؟',
    'درمان سرفه خشک چیست؟',
    'علت درد قفسه سینه چیست؟',
    'چگونه کلسترول را پایین بیاوریم؟',
    'علائم سوءتغذیه چیست؟',
    'درمان درد معده چیست؟',
    'چگونه قند خون را کنترل کنیم؟',
    'علائم کم‌آبی بدن چیست؟',
  ];

  // Randomly selected quick replies
  late List<String> _quickReplies;

  @override
  void initState() {
    super.initState();
    _storageService = widget.storageService;
    _loadMessages();
    _notificationService.init();
    timeDilation = 1.0;

    // Randomly select 4 quick replies
    _randomizeQuickReplies();

    // Initialize animations
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.elasticOut),
    );

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOut));

    _shimmerController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _shimmerAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _shimmerController, curve: Curves.ease));

    _quickRepliesController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _quickRepliesAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _quickRepliesController,
        curve: Curves.easeOutBack,
      ),
    );

    _bubbleController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _bubbleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _bubbleController, curve: Curves.elasticOut),
    );

    _expandButtonController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _expandButtonAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _expandButtonController, curve: Curves.easeInOut),
    );

    _animationController.forward();
    _shimmerController.repeat();
    _quickRepliesController.forward();
    _bubbleController.forward();
    _expandButtonController.forward();
  }

  void _randomizeQuickReplies() {
    final random = Random();
    final List<String> shuffled = List.from(_allQuickReplies)..shuffle(random);
    setState(() {
      _quickReplies = shuffled.take(4).toList();
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _apiService.cancelRequest();

    // Safe disposal of animation controllers
    try {
      if (_animationController.isAnimating) _animationController.stop();
      _animationController.dispose();
    } catch (e) {
      debugPrint('Error disposing animation controller: $e');
    }

    try {
      if (_scaleController.isAnimating) _scaleController.stop();
      _scaleController.dispose();
    } catch (e) {
      debugPrint('Error disposing scale controller: $e');
    }

    try {
      if (_slideController.isAnimating) _slideController.stop();
      _slideController.dispose();
    } catch (e) {
      debugPrint('Error disposing slide controller: $e');
    }

    try {
      if (_shimmerController.isAnimating) _shimmerController.stop();
      _shimmerController.dispose();
    } catch (e) {
      debugPrint('Error disposing shimmer controller: $e');
    }

    try {
      if (_quickRepliesController.isAnimating) _quickRepliesController.stop();
      _quickRepliesController.dispose();
    } catch (e) {
      debugPrint('Error disposing quick replies controller: $e');
    }

    try {
      if (_bubbleController.isAnimating) _bubbleController.stop();
      _bubbleController.dispose();
    } catch (e) {
      debugPrint('Error disposing bubble controller: $e');
    }

    try {
      if (_expandButtonController.isAnimating) _expandButtonController.stop();
      _expandButtonController.dispose();
    } catch (e) {
      debugPrint('Error disposing expand button controller: $e');
    }

    super.dispose();
  }

  Future<void> _loadMessages() async {
    try {
      final messages = _storageService.getMessages();
      setState(() {
        _messages = messages;
        // Initialize expanded states
        for (int i = 0; i < _messages.length; i++) {
          _expandedMessages[i] = false;
        }
      });
      _scrollToBottom();
    } catch (e) {
      debugPrint('Error loading messages: $e');
      _showErrorSnackBar(
        'خطا در بارگیری پیام‌ها. لطفاً برنامه را مجدداً باز کنید.',
      );
    }
  }

  Future<void> _saveMessages() async {
    try {
      await _storageService.saveMessages(_messages);
    } catch (e) {
      debugPrint('Error saving messages: $e');
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _sendMessage() async {
    if (_messageController.text.trim().isEmpty) return;

    _apiService.cancelRequest();

    final userMessage = Message(
      text: _messageController.text,
      isUser: true,
      timestamp: DateTime.now(),
    );

    _scaleController.reset();
    _scaleController.forward();

    setState(() {
      _messages.add(userMessage);
      _isLoading = true;
      _showTypingIndicator = true;
    });

    _messageController.clear();
    _scrollToBottom();

    try {
      await _saveMessages();
    } catch (e) {
      debugPrint('Error saving messages: $e');
    }

    try {
      final response = await _apiService.sendMessage(userMessage.text);

      if (!mounted) return;

      setState(() {
        _showTypingIndicator = false;
        _messages.add(response);
        _isLoading = false;
      });

      _scrollToBottom();

      try {
        await _saveMessages();
      } catch (e) {
        debugPrint('Error saving messages: $e');
      }

      if (response.text.length > 100) {
        try {
          await _notificationService.showNotification(
            title: 'پزشکیار',
            body:
                'پیام جدید!',
          );
        } catch (e) {
          debugPrint('Error showing notification: $e');
        }
      }
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _showTypingIndicator = false;
        _isLoading = false;
      });

      if (e.toString().contains('Request cancelled')) {
        return;
      }

      _showErrorSnackBar('خطا در ارسال پیام: ${e.toString()}');
    }
  }

  void _stopRequest() {
    _apiService.cancelRequest();
    setState(() {
      _isLoading = false;
      _showTypingIndicator = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.info_outline, color: Colors.blue),
            const SizedBox(width: 8),
            Expanded(
              child: Text('درخواست لغو شد', style: GoogleFonts.vazirmatn()),
            ),
          ],
        ),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        backgroundColor: Theme.of(context).primaryColor,
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.error_outline, color: Colors.red),
            const SizedBox(width: 8),
            Expanded(child: Text(message, style: GoogleFonts.vazirmatn())),
          ],
        ),
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        backgroundColor: Theme.of(context).colorScheme.error,
      ),
    );
  }

  void _copyToClipboard(String text, BuildContext context) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green),
            const SizedBox(width: 8),
            Text('متن با موفقیت کپی شد', style: GoogleFonts.vazirmatn()),
          ],
        ),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        backgroundColor: Theme.of(context).primaryColor,
      ),
    );
  }

  void _shareContent(String text) {
    Share.share(text, subject: 'اطلاعات از پزشکیار');
  }

  void _sendQuickReply(String reply) {
    _messageController.text = reply;
    _sendMessage();
  }

  void _toggleMessageExpansion(int index) {
    setState(() {
      _expandedMessages[index] = !(_expandedMessages[index] ?? false);
    });
    _expandButtonController.reset();
    _expandButtonController.forward();
  }

  // Convert Gregorian date to Persian (Jalali) date
  Map<String, int> _gregorianToJalali(int year, int month, int day) {
    int gy = year;
    int gm = month;
    int gd = day;

    List<int> g_d_m = [0, 31, 59, 90, 120, 151, 181, 212, 243, 273, 304, 334];
    int jy;
    if (gy > 1600) {
      jy = 979;
      gy -= 1600;
    } else {
      jy = 0;
      gy -= 621;
    }

    int gy2;
    if (gm > 2) {
      gy2 = gy + 1;
    } else {
      gy2 = gy;
    }

    int days =
        (365 * gy) +
        ((gy2 + 3) ~/ 4) -
        ((gy2 + 99) ~/ 100) +
        ((gy2 + 399) ~/ 400) -
        80 +
        gd +
        g_d_m[gm - 1];
    jy += 33 * (days ~/ 12053);
    days %= 12053;
    jy += 4 * (days ~/ 1461);
    days %= 1461;
    if (days > 365) {
      jy += (days - 1) ~/ 365;
      days = (days - 1) % 365;
    }

    int jm;
    int jd;
    if (days < 186) {
      jm = 1 + (days ~/ 31);
      jd = 1 + (days % 31);
    } else {
      jm = 7 + ((days - 186) ~/ 30);
      jd = 1 + ((days - 186) % 30);
    }

    return {'year': jy, 'month': jm, 'day': jd};
  }

  // Convert numbers to Persian
  String _toPersianNumber(String number) {
    const english = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
    const persian = ['۰', '۱', '۲', '۳', '۴', '۵', '۶', '۷', '۸', '۹'];

    for (int i = 0; i < english.length; i++) {
      number = number.replaceAll(english[i], persian[i]);
    }

    return number;
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = DateTime(now.year, now.month, now.day - 1);
    final messageDate = DateTime(date.year, date.month, date.day);

    // Compare only date parts (year, month, day)
    if (messageDate.year == today.year &&
        messageDate.month == today.month &&
        messageDate.day == today.day) {
      return 'امروز';
    } else if (messageDate.year == yesterday.year &&
        messageDate.month == yesterday.month &&
        messageDate.day == yesterday.day) {
      return 'دیروز';
    } else {
      // Convert to Persian (Jalali) date
      try {
        final persianDate = _gregorianToJalali(date.year, date.month, date.day);
        final year = _toPersianNumber(persianDate['year'].toString());
        final month = _toPersianNumber(
          persianDate['month'].toString().padLeft(2, '0'),
        );
        final day = _toPersianNumber(
          persianDate['day'].toString().padLeft(2, '0'),
        );
        return '$year/$month/$day';
      } catch (e) {
        debugPrint('Error converting date: $e');
        // Fallback to Gregorian date if conversion fails
        final year = _toPersianNumber(date.year.toString());
        final month = _toPersianNumber(date.month.toString().padLeft(2, '0'));
        final day = _toPersianNumber(date.day.toString().padLeft(2, '0'));
        return '$year/$month/$day';
      }
    }
  }

  String _formatTime(DateTime date) {
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    return _toPersianNumber('$hour:$minute');
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;

    // Responsive adjustments
    final horizontalPadding = size.width > 600 ? 24.0 : 16.0;
    final bubbleMaxWidth = size.width > 600
        ? size.width * 0.7
        : size.width * 0.8;

    return Scaffold(
      appBar: AppBar(
        title: Hero(
          tag: 'chat_logo',
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                    BoxShadow(
                      color: AppConstants.primaryColor.withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 0),
                    ),
                  ],
                ),
                child: ClipOval(
                  child: Image.asset(
                    'assets/icons/app_icon.png',
                    width: 36,
                    height: 36,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      // Fallback to icon if image fails to load
                      return Icon(
                        Icons.medical_services,
                        color: AppConstants.primaryColor,
                        size: 20,
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                AppConstants.appName,
                style: GoogleFonts.vazirmatn(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        centerTitle: true,
        elevation: 0,
        actions: [
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              color: isDarkMode
                  ? Colors.white.withOpacity(0.1)
                  : Colors.black.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: Icon(
                Icons.delete_sweep,
                color: isDarkMode ? Colors.white70 : Colors.black54,
              ),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    title: Text(
                      'پاک کردن تاریخچه',
                      style: GoogleFonts.vazirmatn(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    content: Text(
                      'آیا از پاک کردن تمام پیام‌ها اطمینان دارید؟',
                      style: GoogleFonts.vazirmatn(fontSize: 16),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text(
                          'انصراف',
                          style: GoogleFonts.vazirmatn(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          setState(() {
                            _messages.clear();
                            _expandedMessages.clear();
                          });
                          _saveMessages();
                          Navigator.pop(context);
                        },
                        child: Text(
                          'پاک کردن',
                          style: GoogleFonts.vazirmatn(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Colors.red,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
      drawer: CustomDrawer(storageService: _storageService),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDarkMode
                ? [const Color(0xFF1E1E1E), const Color(0xFF121212)]
                : [Colors.grey[50]!, Colors.grey[100]!],
          ),
        ),
        child: Column(
          children: [
            // Chat messages
            if (_messages.isEmpty)
              Expanded(
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: Center(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.symmetric(
                        horizontal: horizontalPadding,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildAnimationWidget(),
                          const SizedBox(height: 32),
                          Shimmer.fromColors(
                            baseColor: isDarkMode
                                ? Colors.white.withOpacity(0.1)
                                : Colors.black.withOpacity(0.1),
                            highlightColor: isDarkMode
                                ? Colors.white.withOpacity(0.2)
                                : Colors.black.withOpacity(0.2),
                            child: Text(
                              'به پزشکیار خوش آمدید',
                              style: GoogleFonts.vazirmatn(
                                fontSize: size.width > 600 ? 32 : 28,
                                fontWeight: FontWeight.bold,
                                color: isDarkMode
                                    ? Colors.white
                                    : Colors.black87,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'سوال پزشکی خود را بپرسید',
                            style: GoogleFonts.vazirmatn(
                              fontSize: size.width > 600 ? 20 : 18,
                              color: isDarkMode
                                  ? Colors.white70
                                  : Colors.black54,
                            ),
                          ),
                          const SizedBox(height: 40),
                          // Quick replies section
                          _buildQuickRepliesSection(isDarkMode, size),
                        ],
                      ),
                    ),
                  ),
                ),
              )
            else
              Expanded(
                child: AnimationLimiter(
                  child: ListView.builder(
                    controller: _scrollController,
                    padding: EdgeInsets.only(
                      bottom: 16,
                      left: horizontalPadding,
                      right: horizontalPadding,
                    ),
                    itemCount:
                        _messages.length + (_showTypingIndicator ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index < _messages.length) {
                        final message = _messages[index];
                        final showDate =
                            index == 0 ||
                            _formatDate(message.timestamp) !=
                                _formatDate(_messages[index - 1].timestamp);

                        return AnimationConfiguration.staggeredList(
                          position: index,
                          duration: const Duration(milliseconds: 375),
                          child: SlideAnimation(
                            verticalOffset: 50.0,
                            child: FadeInAnimation(
                              child: message.isUser
                                  ? ChatBubble(
                                      message: message,
                                      showDate: showDate,
                                      maxWidth: bubbleMaxWidth,
                                    )
                                  : _buildMarkdownBubble(
                                      message,
                                      showDate,
                                      isDarkMode,
                                      bubbleMaxWidth,
                                      index,
                                    ),
                            ),
                          ),
                        );
                      } else {
                        return _buildTypingIndicator(isDarkMode);
                      }
                    },
                  ),
                ),
              ),

            // Input box
            Container(
              margin: EdgeInsets.all(horizontalPadding),
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: GlassInputBox(
                  controller: _messageController,
                  onSend: _sendMessage,
                  onStop: _stopRequest,
                  isLoading: _isLoading,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickRepliesSection(bool isDarkMode, Size size) {
    return FadeTransition(
      opacity: _quickRepliesAnimation,
      child: ScaleTransition(
        scale: _quickRepliesAnimation,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isDarkMode
                  ? [
                      Colors.white.withOpacity(0.12),
                      Colors.white.withOpacity(0.06),
                    ]
                  : [
                      AppConstants.primaryColor.withOpacity(0.15),
                      AppConstants.secondaryColor.withOpacity(0.08),
                    ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
              BoxShadow(
                color: AppConstants.primaryColor.withOpacity(0.2),
                blurRadius: 25,
                offset: const Offset(0, 5),
              ),
            ],
            border: Border.all(
              color: isDarkMode
                  ? Colors.white.withOpacity(0.15)
                  : AppConstants.primaryColor.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: AppConstants.primaryColor,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AppConstants.primaryColor.withOpacity(0.5),
                              blurRadius: 8,
                              offset: const Offset(0, 0),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.flash_on,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'پاسخ‌های سریع',
                        style: GoogleFonts.vazirmatn(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: isDarkMode ? Colors.white : Colors.black87,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.refresh,
                      color: isDarkMode ? Colors.white70 : Colors.black54,
                      size: 22,
                    ),
                    onPressed: _randomizeQuickReplies,
                    splashRadius: 24,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: _quickReplies.map((reply) {
                  return _buildQuickReplyChip(reply, isDarkMode);
                }).toList(),
              ),
              const SizedBox(height: 16),
              Text(
                'برای سوالات دیگر، می‌توانید مستقیماً تایپ کنید',
                style: GoogleFonts.vazirmatn(
                  fontSize: 14,
                  color: isDarkMode ? Colors.white54 : Colors.black38,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickReplyChip(String reply, bool isDarkMode) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _sendQuickReply(reply),
        borderRadius: BorderRadius.circular(20),
        splashColor: AppConstants.primaryColor.withOpacity(0.3),
        highlightColor: AppConstants.primaryColor.withOpacity(0.1),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isDarkMode
                  ? [
                      Colors.white.withOpacity(0.15),
                      Colors.white.withOpacity(0.08),
                    ]
                  : [
                      AppConstants.primaryColor.withOpacity(0.12),
                      AppConstants.secondaryColor.withOpacity(0.06),
                    ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isDarkMode
                  ? Colors.white.withOpacity(0.25)
                  : AppConstants.primaryColor.withOpacity(0.25),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 6,
                offset: const Offset(0, 3),
              ),
              BoxShadow(
                color: AppConstants.primaryColor.withOpacity(0.15),
                blurRadius: 10,
                offset: const Offset(0, 0),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.question_answer_outlined,
                size: 16,
                color: isDarkMode ? Colors.white70 : Colors.black54,
              ),
              const SizedBox(width: 8),
              Text(
                reply,
                style: GoogleFonts.vazirmatn(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: isDarkMode ? Colors.white : Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTypingIndicator(bool isDarkMode) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDarkMode
              ? [Colors.white.withOpacity(0.08), Colors.white.withOpacity(0.04)]
              : [Colors.white.withOpacity(0.8), Colors.white.withOpacity(0.6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
          BoxShadow(
            color: AppConstants.primaryColor.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 0),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: AppConstants.primaryColor,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppConstants.primaryColor.withOpacity(0.5),
                  blurRadius: 4,
                  offset: const Offset(0, 0),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            'پزشکیار در حال تایپ است',
            style: GoogleFonts.vazirmatn(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: isDarkMode ? Colors.white70 : Colors.black54,
            ),
          ),
          const SizedBox(width: 8),
          const TypingIndicator(
            dotSize: 6.0,
            dotSpacing: 4.0,
            animationType: TypingIndicatorAnimation.bounce,
          ),
        ],
      ),
    );
  }

  Widget _buildMarkdownBubble(
    Message message,
    bool showDate,
    bool isDarkMode,
    double maxWidth,
    int index,
  ) {
    final isExpanded = _expandedMessages[index] ?? false;
    final text = message.text;
    final isLongText = text.length > 500;
    final displayText = isLongText && !isExpanded
        ? '${text.substring(0, 500)}...'
        : text;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showDate)
          Container(
            margin: const EdgeInsets.symmetric(vertical: 12),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: isDarkMode
                  ? Colors.white.withOpacity(0.1)
                  : Colors.black.withOpacity(0.05),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Text(
              _formatDate(message.timestamp),
              style: GoogleFonts.vazirmatn(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: isDarkMode ? Colors.white70 : Colors.black54,
              ),
            ),
          ),
        Container(
          constraints: BoxConstraints(maxWidth: maxWidth),
          margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isDarkMode
                  ? [
                      Colors.white.withOpacity(0.08),
                      Colors.white.withOpacity(0.04),
                    ]
                  : [
                      Colors.white.withOpacity(0.9),
                      Colors.white.withOpacity(0.7),
                    ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
              BoxShadow(
                color: AppConstants.primaryColor.withOpacity(0.15),
                blurRadius: 20,
                offset: const Offset(0, 0),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header with copy button
              Container(
                padding: const EdgeInsets.only(right: 16, top: 12, left: 12),
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                  color: isDarkMode
                      ? Colors.white.withOpacity(0.05)
                      : Colors.black.withOpacity(0.03),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            color: AppConstants.primaryColor,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: AppConstants.primaryColor.withOpacity(
                                  0.5,
                                ),
                                blurRadius: 8,
                                offset: const Offset(0, 0),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 10),
                        AnimatedBuilder(
                          animation: _shimmerAnimation,
                          builder: (context, child) {
                            return ShaderMask(
                              blendMode: BlendMode.srcIn,
                              shaderCallback: (bounds) {
                                return LinearGradient(
                                  colors: [
                                    AppConstants.primaryColor,
                                    Colors.blue.shade300,
                                    AppConstants.primaryColor,
                                  ],
                                  stops: [0.0, _shimmerAnimation.value, 1.0],
                                  tileMode: TileMode.mirror,
                                ).createShader(bounds);
                              },
                              child: Text(
                                'پزشکیار',
                                style: GoogleFonts.vazirmatn(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: AppConstants.primaryColor,
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        // Copy button
                        Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(20),
                            onTap: () =>
                                _copyToClipboard(message.text, context),
                            splashColor: AppConstants.primaryColor.withOpacity(
                              0.3,
                            ),
                            highlightColor: AppConstants.primaryColor
                                .withOpacity(0.1),
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: isDarkMode
                                    ? Colors.white.withOpacity(0.1)
                                    : Colors.black.withOpacity(0.05),
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Icon(
                                Icons.copy,
                                size: 20,
                                color: isDarkMode
                                    ? Colors.white70
                                    : Colors.black54,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Share button
                        Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(20),
                            onTap: () => _shareContent(message.text),
                            splashColor: AppConstants.primaryColor.withOpacity(
                              0.3,
                            ),
                            highlightColor: AppConstants.primaryColor
                                .withOpacity(0.1),
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: isDarkMode
                                    ? Colors.white.withOpacity(0.1)
                                    : Colors.black.withOpacity(0.05),
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Icon(
                                Icons.share,
                                size: 20,
                                color: isDarkMode
                                    ? Colors.white70
                                    : Colors.black54,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Markdown content
              Padding(
                padding: const EdgeInsets.all(16),
                child: SingleChildScrollView(
                  child: MarkdownBody(
                    data: displayText,
                    softLineBreak: true,
                    shrinkWrap: true,
                    styleSheet: MarkdownStyleSheet.fromTheme(Theme.of(context))
                        .copyWith(
                          p: GoogleFonts.vazirmatn(
                            fontSize: 16,
                            height: 1.6,
                            color: isDarkMode ? Colors.white : Colors.black87,
                          ),
                          h1: GoogleFonts.vazirmatn(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: isDarkMode ? Colors.white : Colors.black87,
                          ),
                          h2: GoogleFonts.vazirmatn(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: isDarkMode ? Colors.white : Colors.black87,
                          ),
                          h3: GoogleFonts.vazirmatn(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: isDarkMode ? Colors.white : Colors.black87,
                          ),
                          h4: GoogleFonts.vazirmatn(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: isDarkMode ? Colors.white : Colors.black87,
                          ),
                          h5: GoogleFonts.vazirmatn(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: isDarkMode ? Colors.white : Colors.black87,
                          ),
                          h6: GoogleFonts.vazirmatn(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: isDarkMode ? Colors.white : Colors.black87,
                          ),
                          listBullet: GoogleFonts.vazirmatn(
                            fontSize: 16,
                            color: isDarkMode ? Colors.white : Colors.black87,
                          ),
                          code: GoogleFonts.vazirmatn(
                            fontSize: 14,
                            color: isDarkMode
                                ? Color(0xFF4FC3F7) // Light blue for dark mode
                                : Color(0xFFD32F2F), // Red for light mode
                            backgroundColor: isDarkMode
                                ? Color(0xFF1E1E1E) // Dark gray for dark mode
                                : Color(
                                    0xFFF5F5F5,
                                  ), // Light gray for light mode
                          ),
                          codeblockDecoration: BoxDecoration(
                            color: isDarkMode
                                ? Color(0xFF1E1E1E) // Dark gray for dark mode
                                : Color(
                                    0xFFF5F5F5,
                                  ), // Light gray for light mode
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isDarkMode
                                  ? Colors.white.withOpacity(0.24)
                                  : Colors.black.withOpacity(0.12),
                              width: 1,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          blockquoteDecoration: BoxDecoration(
                            border: Border(
                              left: BorderSide(
                                color: AppConstants.primaryColor,
                                width: 4,
                              ),
                            ),
                            color: isDarkMode
                                ? Colors.black26
                                : Colors.grey[100],
                            borderRadius: const BorderRadius.only(
                              topRight: Radius.circular(12),
                              bottomRight: Radius.circular(12),
                            ),
                          ),
                          blockquote: GoogleFonts.vazirmatn(
                            fontSize: 16,
                            color: isDarkMode ? Colors.white70 : Colors.black54,
                            fontStyle: FontStyle.italic,
                          ),
                          a: GoogleFonts.vazirmatn(
                            fontSize: 16,
                            color: Colors.blue,
                            decoration: TextDecoration.underline,
                          ),
                          tableHead: GoogleFonts.vazirmatn(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: isDarkMode ? Colors.white : Colors.black87,
                          ),
                          tableBody: GoogleFonts.vazirmatn(
                            fontSize: 16,
                            color: isDarkMode ? Colors.white : Colors.black87,
                          ),
                          tableBorder: TableBorder.all(
                            color: isDarkMode
                                ? Colors.white.withOpacity(0.24)
                                : Colors.black.withOpacity(0.12),
                          ),
                          tableColumnWidth: const FlexColumnWidth(),
                        ),
                    onTapLink: (text, href, title) {
                      if (href != null) {
                        // launchUrl(Uri.parse(href));
                      }
                    },
                  ),
                ),
              ),

              // Professional show more/less button
              if (isLongText)
                Padding(
                  padding: const EdgeInsets.only(
                    bottom: 12,
                    left: 16,
                    right: 16,
                  ),
                  child: ScaleTransition(
                    scale: _expandButtonAnimation,
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () => _toggleMessageExpansion(index),
                        borderRadius: BorderRadius.circular(12),
                        splashColor: AppConstants.primaryColor.withOpacity(0.3),
                        highlightColor: AppConstants.primaryColor.withOpacity(
                          0.1,
                        ),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: isDarkMode
                                  ? [
                                      Colors.white.withOpacity(0.1),
                                      Colors.white.withOpacity(0.05),
                                    ]
                                  : [
                                      AppConstants.primaryColor.withOpacity(
                                        0.1,
                                      ),
                                      AppConstants.secondaryColor.withOpacity(
                                        0.05,
                                      ),
                                    ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: AppConstants.primaryColor.withOpacity(0.3),
                              width: 1.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                              BoxShadow(
                                color: AppConstants.primaryColor.withOpacity(
                                  0.2,
                                ),
                                blurRadius: 12,
                                offset: const Offset(0, 0),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              AnimatedSwitcher(
                                duration: const Duration(milliseconds: 300),
                                transitionBuilder:
                                    (
                                      Widget child,
                                      Animation<double> animation,
                                    ) {
                                      return ScaleTransition(
                                        scale: animation,
                                        child: child,
                                      );
                                    },
                                child: Icon(
                                  isExpanded
                                      ? Icons.expand_less
                                      : Icons.expand_more,
                                  key: ValueKey<bool>(isExpanded),
                                  color: AppConstants.primaryColor,
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: 8),
                              AnimatedSwitcher(
                                duration: const Duration(milliseconds: 300),
                                transitionBuilder:
                                    (
                                      Widget child,
                                      Animation<double> animation,
                                    ) {
                                      return FadeTransition(
                                        opacity: animation,
                                        child: child,
                                      );
                                    },
                                child: Text(
                                  isExpanded ? 'نمایش کمتر' : 'نمایش کامل',
                                  key: ValueKey<bool>(isExpanded),
                                  style: GoogleFonts.vazirmatn(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: AppConstants.primaryColor,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

              // Footer with timestamp
              Container(
                padding: const EdgeInsets.only(left: 16, right: 16, bottom: 12),
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(20),
                    bottomRight: Radius.circular(20),
                  ),
                  color: isDarkMode
                      ? Colors.white.withOpacity(0.05)
                      : Colors.black.withOpacity(0.03),
                ),
                child: Text(
                  _formatTime(message.timestamp),
                  style: GoogleFonts.vazirmatn(
                    fontSize: 12,
                    color: isDarkMode ? Colors.white54 : Colors.black38,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAnimationWidget() {
    return SizedBox(
      width: 200,
      height: 200,
      child: Lottie.asset(
        AppConstants.loadingAnimationPath,
        repeat: true,
        reverse: true,
        errorBuilder: (context, error, stackTrace) {
          debugPrint('Error loading Lottie animation: $error');
          return _buildFallbackAnimation();
        },
      ),
    );
  }

  Widget _buildFallbackAnimation() {
    return Container(
      width: 160,
      height: 160,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppConstants.primaryColor.withOpacity(0.1),
            AppConstants.primaryColor.withOpacity(0.3),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: AppConstants.primaryColor.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 0),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipOval(
        child: Image.asset(
          'assets/icons/app_icon.png',
          width: 160,
          height: 160,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            // Fallback to icon if image fails to load
            return Icon(
              Icons.medical_services,
              color: AppConstants.primaryColor,
              size: 80,
            );
          },
        ),
      ),
    );
  }
}

