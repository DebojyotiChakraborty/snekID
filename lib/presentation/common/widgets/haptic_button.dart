import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:springster/springster.dart';

/// A button with haptic feedback and spring animation
class HapticButton extends StatefulWidget {
  final Widget child;
  final VoidCallback onPressed;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double borderRadius;
  final Size minimumSize;
  final EdgeInsets padding;
  final bool enabled;
  final Spring? spring;

  const HapticButton({
    super.key,
    required this.child,
    required this.onPressed,
    this.backgroundColor,
    this.foregroundColor,
    this.borderRadius = 30.0,
    this.minimumSize = const Size(double.infinity, 56),
    this.padding = const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
    this.enabled = true,
    this.spring,
  });

  @override
  State<HapticButton> createState() => _HapticButtonState();
}

class _HapticButtonState extends State<HapticButton> {
  double _pressProgress = 0.0;

  void _handleTapDown(TapDownDetails details) {
    if (widget.enabled) {
      HapticFeedback.lightImpact();
      setState(() => _pressProgress = 1.0);
    }
  }

  void _handleTapUp(TapUpDetails details) {
    if (widget.enabled) {
      HapticFeedback.mediumImpact();
      setState(() => _pressProgress = 0.0);
      widget.onPressed();
    }
  }

  void _handleTapCancel() {
    if (widget.enabled) {
      setState(() => _pressProgress = 0.0);
    }
  }

  @override
  Widget build(BuildContext context) {
    final spring = widget.spring ?? Spring.bouncy;

    // Default colors based on theme
    final backgroundColor = widget.backgroundColor ?? Colors.white;
    final foregroundColor = widget.foregroundColor ?? Colors.black;

    return Opacity(
      opacity: widget.enabled ? 1.0 : 0.5,
      child: SpringBuilder(
        spring: spring,
        value: _pressProgress,
        builder: (context, progress, child) {
          final scale = 1.0 - (0.05 * progress);

          return GestureDetector(
            onTapDown: _handleTapDown,
            onTapUp: _handleTapUp,
            onTapCancel: _handleTapCancel,
            child: Transform.scale(
              scale: scale,
              child: Container(
                padding: widget.padding,
                constraints: BoxConstraints(
                  minWidth: widget.minimumSize.width,
                  minHeight: widget.minimumSize.height,
                ),
                decoration: BoxDecoration(
                  color: widget.enabled ? backgroundColor : _disabledColor(),
                  borderRadius: BorderRadius.circular(widget.borderRadius),
                ),
                child: Center(child: child),
              ),
            ),
          );
        },
        child: DefaultTextStyle(
          style: TextStyle(
            color: foregroundColor,
            fontFamily: 'Inter',
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
          child: widget.child,
        ),
      ),
    );
  }

  Color _disabledColor() {
    return Colors.grey.shade400;
  }
}
