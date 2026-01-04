import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../common/widgets/cupertino_card.dart';

/// First-launch intro prompt alert with slide-up animation
class IntroPromptAlert extends StatefulWidget {
  final VoidCallback onContinue;
  final bool isVisible;

  const IntroPromptAlert({
    super.key,
    required this.onContinue,
    this.isVisible = false,
  });

  @override
  State<IntroPromptAlert> createState() => _IntroPromptAlertState();
}

class _IntroPromptAlertState extends State<IntroPromptAlert>
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
  void didUpdateWidget(IntroPromptAlert oldWidget) {
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
                  // Prompt text
                  Text(
                    'Take a photo of a snake and I\'ll help you identify it.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: context.textPrimaryColor,
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Continue button (centered)
                  _ContinueButton(onPressed: widget.onContinue),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ContinueButton extends StatefulWidget {
  final VoidCallback onPressed;

  const _ContinueButton({required this.onPressed});

  @override
  State<_ContinueButton> createState() => _ContinueButtonState();
}

class _ContinueButtonState extends State<_ContinueButton> {
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
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 48),
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(100), // Pill shape
          ),
          child: const Text(
            'Continue',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
        ),
      ),
    );
  }
}
