import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'dart:ui' as ui;

enum TypingIndicatorAnimation {
  scale,
  fade,
  slide,
  bounce,
  pulse,
  elastic,
  wave,
  flip,
  rotate,
  spiral,
  heartbeat,
  shake,
  glow,
  morph,
}

enum TypingIndicatorDirection {
  leftToRight,
  rightToLeft,
  centerOut,
  topToBottom,
  bottomToTop,
  diagonal,
}

enum DotShape { circle, square, triangle, diamond, star, heart }

class TypingIndicator extends StatefulWidget {
  final Color? backgroundColor;
  final Color? dotColor;
  final double dotSize;
  final double dotSpacing;
  final Duration animationDuration;
  final TypingIndicatorAnimation animationType;
  final String? label;
  final TextStyle? labelStyle;
  final int dotCount;
  final double borderRadius;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry margin;
  final BoxShadow? shadow;
  final bool showLabel;
  final TypingIndicatorDirection direction;
  final bool reverseAnimation;
  final bool showBackground;
  final Gradient? backgroundGradient;
  final double? backgroundOpacity;
  final List<Color>? dotColors;
  final bool enableInteractiveFeedback;
  final VoidCallback? onTap;
  final DotShape dotShape;
  final bool enableGradientDots;
  final List<Color>? dotGradientColors;
  final bool enableDynamicSizing;
  final double minDotSize;
  final double maxDotSize;
  final bool enableDynamicSpacing;
  final double minDotSpacing;
  final double maxDotSpacing;
  final bool enableGlowEffect;
  final Color? glowColor;
  final double glowRadius;
  final bool enableTrailEffect;
  final Color? trailColor;
  final double trailLength;
  final bool enableMorphing;
  final Duration morphDuration;

  const TypingIndicator({
    Key? key,
    this.backgroundColor,
    this.dotColor,
    this.dotSize = 10.0, // افزایش اندازه پیش‌فرض
    this.dotSpacing = 8.0,
    this.animationDuration = const Duration(milliseconds: 1200),
    this.animationType = TypingIndicatorAnimation.scale,
    this.label,
    this.labelStyle,
    this.dotCount = 3,
    this.borderRadius = 24.0,
    this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    this.margin = const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
    this.shadow,
    this.showLabel = false,
    this.direction = TypingIndicatorDirection.leftToRight,
    this.reverseAnimation = false,
    this.showBackground = true,
    this.backgroundGradient,
    this.backgroundOpacity,
    this.dotColors,
    this.enableInteractiveFeedback = false,
    this.onTap,
    this.dotShape = DotShape.circle,
    this.enableGradientDots = false,
    this.dotGradientColors,
    this.enableDynamicSizing = false,
    this.minDotSize = 8.0, // افزایش اندازه حداقل
    this.maxDotSize = 14.0, // افزایش اندازه حداکثر
    this.enableDynamicSpacing = false,
    this.minDotSpacing = 4.0,
    this.maxDotSpacing = 12.0,
    this.enableGlowEffect = false,
    this.glowColor,
    this.glowRadius = 10.0,
    this.enableTrailEffect = false,
    this.trailColor,
    this.trailLength = 0.5,
    this.enableMorphing = false,
    this.morphDuration = const Duration(milliseconds: 1000),
  }) : super(key: key);

  @override
  _TypingIndicatorState createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<TypingIndicator>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  List<Animation<double>> _animations = [];
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  late AnimationController _glowController;
  late Animation<double> _glowAnimation;
  late AnimationController _morphController;
  late Animation<double> _morphAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.animationDuration,
    );

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _glowAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );

    _morphController = AnimationController(
      vsync: this,
      duration: widget.morphDuration,
    );

    _morphAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _morphController, curve: Curves.easeInOut),
    );

    // Create animations for each dot based on direction
    for (int i = 0; i < widget.dotCount; i++) {
      double start, end;

      switch (widget.direction) {
        case TypingIndicatorDirection.leftToRight:
          start = i / widget.dotCount;
          end = (i + 1) / widget.dotCount;
          break;
        case TypingIndicatorDirection.rightToLeft:
          start = (widget.dotCount - i - 1) / widget.dotCount;
          end = (widget.dotCount - i) / widget.dotCount;
          break;
        case TypingIndicatorDirection.centerOut:
          final middle = widget.dotCount / 2;
          final distance = (i - middle).abs();
          start = distance / widget.dotCount;
          end = (distance + 1) / widget.dotCount;
          break;
        case TypingIndicatorDirection.topToBottom:
          start = i / widget.dotCount;
          end = (i + 1) / widget.dotCount;
          break;
        case TypingIndicatorDirection.bottomToTop:
          start = (widget.dotCount - i - 1) / widget.dotCount;
          end = (widget.dotCount - i) / widget.dotCount;
          break;
        case TypingIndicatorDirection.diagonal:
          start = i / widget.dotCount;
          end = (i + 1) / widget.dotCount;
          break;
      }

      if (widget.reverseAnimation) {
        final temp = start;
        start = end;
        end = temp;
      }

      _animations.add(
        Tween<double>(begin: 0.0, end: 1.0).animate(
          CurvedAnimation(
            parent: _controller,
            curve: Interval(start, end, curve: Curves.easeInOut),
          ),
        ),
      );
    }

    _controller.repeat();
    _pulseController.repeat(reverse: true);
    _glowController.repeat(reverse: true);

    if (widget.enableMorphing) {
      _morphController.repeat();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _pulseController.dispose();
    _glowController.dispose();
    _morphController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    Widget content = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Build dots
        ...List.generate(widget.dotCount, (index) {
          return _buildDot(_animations[index], index);
        }),

        // Add label if enabled
        if (widget.showLabel && widget.label != null) ...[
          SizedBox(width: widget.dotSpacing),
          Text(
            widget.label!,
            style:
                widget.labelStyle ??
                TextStyle(
                  color: isDarkMode
                      ? Colors.white
                      : Colors.black87, // بهبود کنتراست متن
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
          ),
        ],
      ],
    );

    // Apply interactive feedback if enabled
    if (widget.enableInteractiveFeedback) {
      content = Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: widget.onTap,
          borderRadius: BorderRadius.circular(widget.borderRadius),
          splashColor: Colors.white.withOpacity(0.3),
          highlightColor: Colors.white.withOpacity(0.1),
          child: content,
        ),
      );
    }

    // Apply background if enabled
    if (widget.showBackground) {
      return Container(
        margin: widget.margin,
        padding: widget.padding,
        decoration: BoxDecoration(
          color: widget.backgroundGradient == null
              ? (widget.backgroundColor ??
                    (isDarkMode
                        ? const Color(
                            0xFF2E2E2E,
                          ).withOpacity(widget.backgroundOpacity ?? 1.0)
                        : Colors.white.withOpacity(
                            widget.backgroundOpacity ?? 1.0,
                          )))
              : null,
          gradient: widget.backgroundGradient,
          borderRadius: BorderRadius.circular(widget.borderRadius),
          boxShadow: widget.shadow != null
              ? [widget.shadow!]
              : [
                  BoxShadow(
                    color: Colors.black.withOpacity(
                      0.15,
                    ), // افزایش کنتراست سایه
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                  BoxShadow(
                    color: Colors.black.withOpacity(
                      0.08,
                    ), // افزایش کنتراست سایه
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  ),
                ],
        ),
        child: AnimatedBuilder(
          animation: _pulseAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: widget.animationType == TypingIndicatorAnimation.pulse
                  ? _pulseAnimation.value
                  : 1.0,
              child: child ?? content,
            );
          },
          child: content,
        ),
      );
    }

    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: widget.animationType == TypingIndicatorAnimation.pulse
              ? _pulseAnimation.value
              : 1.0,
          child: child ?? content,
        );
      },
      child: content,
    );
  }

  Widget _buildDot(Animation<double> animation, int index) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    // Determine dot color with better contrast
    Color dotColor;
    if (widget.dotColors != null && index < widget.dotColors!.length) {
      dotColor = widget.dotColors![index];
    } else {
      dotColor =
          widget.dotColor ??
          (isDarkMode ? Colors.white : Colors.black87); // بهبود کنتراست نقاط
    }

    // Calculate dynamic size if enabled
    final dynamicSize = widget.enableDynamicSizing
        ? widget.minDotSize +
              (widget.maxDotSize - widget.minDotSize) * animation.value
        : widget.dotSize;

    // Calculate dynamic spacing if enabled
    final dynamicSpacing = widget.enableDynamicSpacing
        ? widget.minDotSpacing +
              (widget.maxDotSpacing - widget.minDotSpacing) * animation.value
        : widget.dotSpacing;

    // Create the dot shape
    Widget dot = _createDotShape(dotColor, dynamicSize, isDarkMode);

    // Apply gradient if enabled
    if (widget.enableGradientDots && widget.dotGradientColors != null) {
      dot = ShaderMask(
        shaderCallback: (bounds) {
          return LinearGradient(
            colors: widget.dotGradientColors!,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ).createShader(bounds);
        },
        child: dot,
      );
    }

    // Apply glow effect if enabled
    if (widget.enableGlowEffect) {
      dot = AnimatedBuilder(
        animation: _glowAnimation,
        builder: (context, child) {
          return Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: (widget.glowColor ?? dotColor).withOpacity(
                    0.5 * _glowAnimation.value,
                  ),
                  blurRadius: widget.glowRadius * _glowAnimation.value,
                  spreadRadius: 2 * _glowAnimation.value,
                ),
              ],
            ),
            child: child,
          );
        },
        child: dot,
      );
    }

    // Apply trail effect if enabled
    if (widget.enableTrailEffect) {
      dot = AnimatedBuilder(
        animation: animation,
        builder: (context, child) {
          return Stack(
            children: [
              // Trail
              for (int i = 1; i <= 5; i++)
                Opacity(
                  opacity: (1 - i * 0.2) * animation.value * widget.trailLength,
                  child: Transform.translate(
                    offset: _getTrailOffset(animation, i),
                    child: Transform.scale(
                      scale: 1 - i * 0.1,
                      child: Container(
                        width: dynamicSize,
                        height: dynamicSize,
                        decoration: BoxDecoration(
                          color:
                              widget.trailColor ??
                              dotColor.withOpacity(
                                0.7,
                              ), // افزایش کنتراست دنباله
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ),
                ),
              // Main dot
              child!,
            ],
          );
        },
        child: dot,
      );
    }

    // Apply morphing if enabled
    if (widget.enableMorphing) {
      dot = AnimatedBuilder(
        animation: _morphAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: 0.8 + 0.4 * math.sin(_morphAnimation.value * math.pi * 2),
            child: Transform.rotate(
              angle: _morphAnimation.value * math.pi * 2,
              child: child,
            ),
          );
        },
        child: dot,
      );
    }

    // Apply animation based on the selected type
    switch (widget.animationType) {
      case TypingIndicatorAnimation.scale:
        dot = Transform.scale(scale: animation.value, child: dot);
        break;
      case TypingIndicatorAnimation.fade:
        dot = Opacity(opacity: animation.value, child: dot);
        break;
      case TypingIndicatorAnimation.slide:
        final direction = widget.reverseAnimation ? -1 : 1;
        final offset = _getSlideOffset(direction, animation);
        dot = Transform.translate(offset: offset, child: dot);
        break;
      case TypingIndicatorAnimation.bounce:
        dot = Transform.translate(
          offset: Offset(0, -math.sin(animation.value * math.pi) * 10),
          child: dot,
        );
        break;
      case TypingIndicatorAnimation.pulse:
        // Handled in the parent widget
        break;
      case TypingIndicatorAnimation.elastic:
        final elasticValue = animation.value < 0.5
            ? 2 * animation.value
            : 2 * (1 - animation.value);
        dot = Transform.scale(scale: 0.7 + elasticValue * 0.6, child: dot);
        break;
      case TypingIndicatorAnimation.wave:
        final waveOffset = math.sin(animation.value * math.pi * 2) * 5;
        dot = Transform.translate(offset: Offset(waveOffset, 0), child: dot);
        break;
      case TypingIndicatorAnimation.flip:
        dot = Transform(
          alignment: Alignment.center,
          transform: Matrix4.identity()..rotateY(animation.value * math.pi),
          child: dot,
        );
        break;
      case TypingIndicatorAnimation.rotate:
        dot = Transform.rotate(
          angle: animation.value * math.pi * 2,
          child: dot,
        );
        break;
      case TypingIndicatorAnimation.spiral:
        final spiralRadius = animation.value * 10;
        final spiralAngle = animation.value * math.pi * 4;
        dot = Transform.translate(
          offset: Offset(
            math.cos(spiralAngle) * spiralRadius,
            math.sin(spiralAngle) * spiralRadius,
          ),
          child: Transform.rotate(angle: spiralAngle, child: dot),
        );
        break;
      case TypingIndicatorAnimation.heartbeat:
        final heartbeatValue =
            math.sin(animation.value * math.pi * 8) * 0.1 + 0.9;
        dot = Transform.scale(scale: heartbeatValue, child: dot);
        break;
      case TypingIndicatorAnimation.shake:
        final shakeOffset = math.sin(animation.value * math.pi * 16) * 3;
        dot = Transform.translate(offset: Offset(shakeOffset, 0), child: dot);
        break;
      case TypingIndicatorAnimation.glow:
        // Handled in the glow effect
        break;
      case TypingIndicatorAnimation.morph:
        // Handled in the morphing effect
        break;
    }

    // Add spacing between dots
    if (index < widget.dotCount - 1) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          dot,
          SizedBox(width: dynamicSpacing),
        ],
      );
    }

    return dot;
  }

  Widget _createDotShape(Color color, double size, bool isDarkMode) {
    switch (widget.dotShape) {
      case DotShape.circle:
        return Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: isDarkMode
                ? null
                : Border.all(
                    color: Colors.black12,
                    width: 1,
                  ), // افزودن حاشیه در تم روشن
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.4), // افزایش کنتراست سایه
                blurRadius: 6, // افزایش شفافیت سایه
                spreadRadius: 1,
              ),
            ],
          ),
        );
      case DotShape.square:
        return Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(size * 0.2),
            border: isDarkMode
                ? null
                : Border.all(
                    color: Colors.black12,
                    width: 1,
                  ), // افزودن حاشیه در تم روشن
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.4), // افزایش کنتراست سایه
                blurRadius: 6, // افزایش شفافیت سایه
                spreadRadius: 1,
              ),
            ],
          ),
        );
      case DotShape.triangle:
        return CustomPaint(
          size: Size(size, size),
          painter: TrianglePainter(color: color, isDarkMode: isDarkMode),
        );
      case DotShape.diamond:
        return Transform.rotate(
          angle: math.pi / 4,
          child: Container(
            width: size * 0.7,
            height: size * 0.7,
            decoration: BoxDecoration(
              color: color,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.4), // افزایش کنتراست سایه
                  blurRadius: 6, // افزایش شفافیت سایه
                  spreadRadius: 1,
                ),
              ],
            ),
          ),
        );
      case DotShape.star:
        return CustomPaint(
          size: Size(size, size),
          painter: StarPainter(color: color, isDarkMode: isDarkMode),
        );
      case DotShape.heart:
        return CustomPaint(
          size: Size(size, size),
          painter: HeartPainter(color: color, isDarkMode: isDarkMode),
        );
    }
  }

  Offset _getSlideOffset(int direction, Animation<double> animation) {
    switch (widget.direction) {
      case TypingIndicatorDirection.leftToRight:
      case TypingIndicatorDirection.rightToLeft:
        return Offset(direction * (1 - animation.value) * 10, 0);
      case TypingIndicatorDirection.topToBottom:
      case TypingIndicatorDirection.bottomToTop:
        return Offset(0, direction * (1 - animation.value) * 10);
      case TypingIndicatorDirection.diagonal:
        return Offset(
          direction * (1 - animation.value) * 7,
          direction * (1 - animation.value) * 7,
        );
      case TypingIndicatorDirection.centerOut:
        return Offset(0, direction * (1 - animation.value) * 10);
    }
  }

  Offset _getTrailOffset(Animation<double> animation, int trailIndex) {
    switch (widget.direction) {
      case TypingIndicatorDirection.leftToRight:
        return Offset(-trailIndex * 5.0 * (1 - animation.value), 0);
      case TypingIndicatorDirection.rightToLeft:
        return Offset(trailIndex * 5.0 * (1 - animation.value), 0);
      case TypingIndicatorDirection.topToBottom:
        return Offset(0, -trailIndex * 5.0 * (1 - animation.value));
      case TypingIndicatorDirection.bottomToTop:
        return Offset(0, trailIndex * 5.0 * (1 - animation.value));
      case TypingIndicatorDirection.diagonal:
        return Offset(
          -trailIndex * 3.5 * (1 - animation.value),
          -trailIndex * 3.5 * (1 - animation.value),
        );
      case TypingIndicatorDirection.centerOut:
        return Offset(0, -trailIndex * 5.0 * (1 - animation.value));
    }
  }
}

class TrianglePainter extends CustomPainter {
  final Color color;
  final bool isDarkMode;

  TrianglePainter({required this.color, required this.isDarkMode});

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path();
    path.moveTo(size.width / 2, 0);
    path.lineTo(0, size.height);
    path.lineTo(size.width, size.height);
    path.close();

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    // افزایش کنتراست سایه
    canvas.drawShadow(path, Colors.black.withOpacity(0.4), 6, false);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}

class StarPainter extends CustomPainter {
  final Color color;
  final bool isDarkMode;

  StarPainter({required this.color, required this.isDarkMode});

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path();
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    const points = 5;

    for (int i = 0; i < points * 2; i++) {
      final angle = i * math.pi / points - math.pi / 2;
      final r = i % 2 == 0 ? radius : radius * 0.5;
      final x = center.dx + r * math.cos(angle);
      final y = center.dy + r * math.sin(angle);

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    path.close();

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    // افزایش کنتراست سایه
    canvas.drawShadow(path, Colors.black.withOpacity(0.4), 6, false);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}

class HeartPainter extends CustomPainter {
  final Color color;
  final bool isDarkMode;

  HeartPainter({required this.color, required this.isDarkMode});

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path();
    final width = size.width;
    final height = size.height;

    path.moveTo(width * 0.5, height * 0.35);
    path.cubicTo(
      width * 0.5,
      height * 0.25,
      width * 0.35,
      height * 0.1,
      width * 0.2,
      height * 0.1,
    );
    path.cubicTo(width * 0.05, height * 0.1, 0, height * 0.25, 0, height * 0.4);
    path.cubicTo(
      0,
      height * 0.55,
      width * 0.1,
      height * 0.7,
      width * 0.5,
      height * 0.9,
    );
    path.cubicTo(
      width * 0.9,
      height * 0.7,
      width,
      height * 0.55,
      width,
      height * 0.4,
    );
    path.cubicTo(
      width,
      height * 0.25,
      width * 0.95,
      height * 0.1,
      width * 0.8,
      height * 0.1,
    );
    path.cubicTo(
      width * 0.65,
      height * 0.1,
      width * 0.5,
      height * 0.25,
      width * 0.5,
      height * 0.35,
    );

    path.close();

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    // افزایش کنتراست سایه
    canvas.drawShadow(path, Colors.black.withOpacity(0.4), 6, false);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
