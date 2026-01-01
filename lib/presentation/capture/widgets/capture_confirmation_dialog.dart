import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';

/// iOS-style confirmation dialog shown after capturing/selecting an image
class CaptureConfirmationDialog extends StatelessWidget {
  final VoidCallback onRetake;
  final VoidCallback onIdentify;

  const CaptureConfirmationDialog({
    super.key,
    required this.onRetake,
    required this.onIdentify,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(24),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFFE5E5EA), // iOS-style light grey
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Question text
          const Text(
            AppStrings.identifyQuestion,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.black,
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
                  onPressed: onRetake,
                  isPrimary: false,
                ),
              ),

              const SizedBox(width: 12),

              // Identify button
              Expanded(
                child: _DialogButton(
                  label: AppStrings.identify,
                  onPressed: onIdentify,
                  isPrimary: true,
                ),
              ),
            ],
          ),
        ],
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
            color: widget.isPrimary
                ? AppColors.primary
                : const Color(0xFFB4B4B8), // iOS-style grey
            borderRadius: BorderRadius.circular(100), // Pill shape
          ),
          child: Center(
            child: Text(
              widget.label,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: widget.isPrimary ? Colors.black : Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
