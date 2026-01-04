import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/app_strings.dart';
import '../../common/widgets/cupertino_card.dart';

/// iOS-style confirmation dialog shown after capturing/selecting an image
/// with slide-up animation similar to Drops
class CaptureConfirmationDialog extends StatefulWidget {
  final VoidCallback onRetake;
  final VoidCallback onIdentify;
  final bool isVisible;

  const CaptureConfirmationDialog({
    super.key,
    required this.onRetake,
    required this.onIdentify,
    this.isVisible = false,
  });

  @override
  State<CaptureConfirmationDialog> createState() =>
      _CaptureConfirmationDialogState();
}

class _CaptureConfirmationDialogState extends State<CaptureConfirmationDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<Offset> _offsetAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _offsetAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutExpo,
        reverseCurve: Curves.easeInExpo,
      ),
    );

    if (widget.isVisible) {
      _animationController.forward();
    }
  }

  @override
  void didUpdateWidget(CaptureConfirmationDialog oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isVisible != oldWidget.isVisible) {
      if (widget.isVisible) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _offsetAnimation,
      child: Container(
        margin: const EdgeInsets.all(24),
        child: Material(
          type: MaterialType.transparency,
          shape: const SquircleBorder(
            radius: BorderRadius.all(
              Radius.circular(AppConstants.alertBorderRadius),
            ),
          ),
          clipBehavior: Clip.antiAlias,
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color:
                    context.isDarkMode
                        ? const Color(0xFF1C1C1E).withOpacity(0.85)
                        : const Color(0xFFE5E5EA).withOpacity(0.85),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Question text
                  Text(
                    AppStrings.identifyQuestion,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: context.textPrimaryColor,
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Buttons row
                  Row(
                    children: [
                      // Retake button
                      Expanded(
                        child: _DialogButton(
                          label: AppStrings.retake,
                          onPressed: widget.onRetake,
                          isPrimary: false,
                        ),
                      ),

                      const SizedBox(width: 12),

                      // Identify button
                      Expanded(
                        child: _DialogButton(
                          label: AppStrings.identify,
                          onPressed: widget.onIdentify,
                          isPrimary: true,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DialogButton extends StatefulWidget {
  final String label;
  final VoidCallback onPressed;
  final bool isPrimary;

  const _DialogButton({
    required this.label,
    required this.onPressed,
    required this.isPrimary,
  });

  @override
  State<_DialogButton> createState() => _DialogButtonState();
}

class _DialogButtonState extends State<_DialogButton> {
  double _scale = 1.0;

  void _onTapDown(TapDownDetails details) {
    HapticFeedback.lightImpact();
    setState(() => _scale = 0.95);
  }

  void _onTapUp(TapUpDetails details) {
    HapticFeedback.mediumImpact();
    setState(() => _scale = 1.0);
    widget.onPressed();
  }

  void _onTapCancel() {
    setState(() => _scale = 1.0);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: AnimatedScale(
        scale: _scale,
        duration: const Duration(milliseconds: 100),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
          decoration: BoxDecoration(
            color:
                widget.isPrimary
                    ? AppColors.primary
                    : (context.isDarkMode
                        ? const Color(0xFF3A3A3C)
                        : Colors.white),
            borderRadius: BorderRadius.circular(100), // Pill shape
          ),
          child: Center(
            child: Text(
              widget.label,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color:
                    widget.isPrimary ? Colors.black : context.textPrimaryColor,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
