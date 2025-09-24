import 'package:flutter/material.dart';
import 'package:glassmorphism/glassmorphism.dart';
import 'package:pezshkyar/config/constants.dart';

class GlassInputBox extends StatefulWidget {
  final TextEditingController controller;
  final VoidCallback onSend;
  final VoidCallback onStop;
  final bool isLoading;

  const GlassInputBox({
    Key? key,
    required this.controller,
    required this.onSend,
    required this.onStop,
    this.isLoading = false,
  }) : super(key: key);

  @override
  _GlassInputBoxState createState() => _GlassInputBoxState();
}

class _GlassInputBoxState extends State<GlassInputBox>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _animationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _animationController.reverse();
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handleSend() {
    if (widget.controller.text.trim().isNotEmpty && !widget.isLoading) {
      _animationController.forward();
      widget.onSend();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final hasText = widget.controller.text.trim().isNotEmpty;

    return Container(
      margin: const EdgeInsets.all(16),
      child: GlassmorphicContainer(
        width: double.infinity,
        height: 60,
        borderRadius: 30,
        blur: 10,
        alignment: Alignment.center,
        border: 1,
        linearGradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDarkMode
              ? [Colors.white.withOpacity(0.1), Colors.white.withOpacity(0.05)]
              : [Colors.white.withOpacity(0.2), Colors.white.withOpacity(0.1)],
        ),
        borderGradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppConstants.primaryColor.withOpacity(0.5),
            AppConstants.secondaryColor.withOpacity(0.5),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: TextField(
                  controller: widget.controller,
                  decoration: InputDecoration(
                    hintText: 'پیام خود را اینجا بنویسید...',
                    hintStyle: TextStyle(
                      color: isDarkMode ? Colors.white54 : Colors.black54,
                    ),
                    border: InputBorder.none,
                  ),
                  style: TextStyle(
                    color: isDarkMode ? Colors.white : Colors.black87,
                  ),
                  textDirection: TextDirection.rtl,
                  onSubmitted: (_) => _handleSend(),
                ),
              ),
            ),
            if (widget.isLoading)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppConstants.primaryColor,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      onPressed: widget.onStop,
                      icon: Icon(Icons.stop_circle, color: Colors.red),
                    ),
                  ],
                ),
              )
            else
              AnimatedBuilder(
                animation: _scaleAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _scaleAnimation.value,
                    child: IconButton(
                      onPressed: hasText ? _handleSend : null,
                      icon: Icon(
                        Icons.send,
                        color: hasText
                            ? AppConstants.primaryColor
                            : (isDarkMode ? Colors.white24 : Colors.black26),
                      ),
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}
