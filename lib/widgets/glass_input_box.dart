import 'package:flutter/material.dart';
import 'package:glassmorphism/glassmorphism.dart';
import 'package:pezshkyar/config/constants.dart';
import 'package:flutter/services.dart';

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
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late AnimationController _hintAnimationController;
  late AnimationController _focusAnimationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _hintOpacityAnimation;
  late Animation<double> _focusAnimation;
  late FocusNode _focusNode;
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _hintAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _focusAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _hintOpacityAnimation = Tween<double>(begin: 0.7, end: 0.3).animate(
      CurvedAnimation(
        parent: _hintAnimationController,
        curve: Curves.easeInOut,
      ),
    );

    _focusAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(
        parent: _focusAnimationController,
        curve: Curves.easeInOut,
      ),
    );

    _animationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _animationController.reverse();
      }
    });

    _hintAnimationController.repeat(reverse: true);

    _focusNode.addListener(() {
      if (_focusNode.hasFocus) {
        _focusAnimationController.forward();
        HapticFeedback.lightImpact();
      } else {
        _focusAnimationController.reverse();
      }
    });

    // Check if there's text initially
    _hasText = widget.controller.text.trim().isNotEmpty;
  }

  @override
  void dispose() {
    _animationController.dispose();
    _hintAnimationController.dispose();
    _focusAnimationController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _handleSend() {
    if (widget.controller.text.trim().isNotEmpty && !widget.isLoading) {
      _animationController.forward();
      HapticFeedback.lightImpact();
      widget.onSend();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final hasText = widget.controller.text.trim().isNotEmpty;

    // Update text state
    if (hasText != _hasText) {
      setState(() {
        _hasText = hasText;
      });
    }

    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 15,
            spreadRadius: 0,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: AppConstants.primaryColor.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 0,
            offset: const Offset(0, 0),
          ),
        ],
      ),
      child: AnimatedBuilder(
        animation: _focusAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _focusAnimation.value,
            child: GlassmorphicContainer(
              width: double.infinity,
              height: 65,
              borderRadius: 32,
              blur: 20,
              alignment: Alignment.center,
              border: 2,
              linearGradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isDarkMode
                    ? [
                        Colors.white.withOpacity(0.15),
                        Colors.white.withOpacity(0.05),
                      ]
                    : [
                        Colors.white.withOpacity(0.25),
                        Colors.white.withOpacity(0.1),
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
              child: child,
            ),
          );
        },
        child: Row(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: TextField(
                  controller: widget.controller,
                  focusNode: _focusNode,
                  decoration: InputDecoration(
                    hintText: 'پیام خود را اینجا بنویسید...',
                    hintStyle: TextStyle(
                      color: isDarkMode ? Colors.white54 : Colors.black54,
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                    ),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                  ),
                  style: TextStyle(
                    color: isDarkMode ? Colors.white : Colors.black87,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                  textDirection: TextDirection.rtl,
                  onSubmitted: (_) => _handleSend(),
                  onChanged: (text) {
                    setState(() {
                      _hasText = text.trim().isNotEmpty;
                    });
                  },
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
                        strokeWidth: 2.5,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppConstants.primaryColor,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(20),
                        onTap: widget.onStop,
                        splashColor: Colors.red.withOpacity(0.3),
                        highlightColor: Colors.red.withOpacity(0.1),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: isDarkMode
                                ? Colors.white.withOpacity(0.1)
                                : Colors.black.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.red.withOpacity(0.2),
                                blurRadius: 8,
                                offset: const Offset(0, 0),
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.stop_circle,
                            color: Colors.red,
                            size: 24,
                          ),
                        ),
                      ),
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
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(20),
                        onTap: _hasText ? _handleSend : null,
                        splashColor: AppConstants.primaryColor.withOpacity(0.3),
                        highlightColor: AppConstants.primaryColor.withOpacity(
                          0.1,
                        ),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          margin: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            gradient: _hasText
                                ? LinearGradient(
                                    colors: [
                                      AppConstants.primaryColor.withOpacity(
                                        0.8,
                                      ),
                                      AppConstants.secondaryColor.withOpacity(
                                        0.8,
                                      ),
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  )
                                : null,
                            color: _hasText
                                ? null
                                : isDarkMode
                                ? Colors.white.withOpacity(0.1)
                                : Colors.black.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: _hasText
                                ? [
                                    BoxShadow(
                                      color: AppConstants.primaryColor
                                          .withOpacity(0.4),
                                      blurRadius: 12,
                                      offset: const Offset(0, 4),
                                    ),
                                    BoxShadow(
                                      color: AppConstants.secondaryColor
                                          .withOpacity(0.3),
                                      blurRadius: 8,
                                      offset: const Offset(0, 0),
                                    ),
                                  ]
                                : [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                          ),
                          child: Icon(
                            Icons.send,
                            color: _hasText
                                ? Colors.white
                                : (isDarkMode
                                      ? Colors.white30
                                      : Colors.black26),
                            size: 22,
                          ),
                        ),
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


