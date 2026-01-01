import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ming_cute_icons/ming_cute_icons.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/services/sound_service.dart';

/// Bottom capture controls (gallery, shutter, history, flash)
class CaptureControls extends StatelessWidget {
  final VoidCallback onCapture;
  final VoidCallback onGallery;
  final VoidCallback? onHistory;
  final VoidCallback? onFlash;
  final bool isFlashOn;
  final bool isCapturing;

  const CaptureControls({
    super.key,
    required this.onCapture,
    required this.onGallery,
    this.onHistory,
    this.onFlash,
    this.isFlashOn = false,
    this.isCapturing = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 48),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Flash button above controls
            if (onFlash != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _FlashButton(
                      onPressed: onFlash!,
                      isOn: isFlashOn,
                    ),
                  ],
                ),
              ),

            // Bottom controls row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Gallery button
                _ControlButton(
                  icon: MingCuteIcons.mgc_pic_line,
                  onPressed: onGallery,
                  size: 48,
                ),

                // Capture button
                _CaptureButton(
                  onPressed: onCapture,
                  isCapturing: isCapturing,
                ),

                // History button
                _ControlButton(
                  icon: MingCuteIcons.mgc_time_line,
                  onPressed: onHistory,
                  size: 48,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ControlButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final double size;

  const _ControlButton({
    required this.icon,
    this.onPressed,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed != null
          ? () {
              HapticFeedback.lightImpact();
              onPressed!();
            }
          : null,
      child: SizedBox(
        width: size,
        height: size,
        child: Center(
          child: Icon(
            icon,
            size: 28,
            color: onPressed != null
                ? AppColors.textPrimary
                : AppColors.textMuted,
          ),
        ),
      ),
    );
  }
}

class _FlashButton extends StatelessWidget {
  final VoidCallback onPressed;
  final bool isOn;

  const _FlashButton({
    required this.onPressed,
    required this.isOn,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onPressed();
      },
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: isOn ? AppColors.primary.withValues(alpha: 0.2) : Colors.transparent,
          shape: BoxShape.circle,
        ),
        child: Center(
          child: Icon(
            isOn ? MingCuteIcons.mgc_flashlight_fill : MingCuteIcons.mgc_flashlight_line,
            size: 28,
            color: isOn ? AppColors.primary : AppColors.textPrimary,
          ),
        ),
      ),
    );
  }
}

class _CaptureButton extends StatefulWidget {
  final VoidCallback onPressed;
  final bool isCapturing;

  const _CaptureButton({
    required this.onPressed,
    required this.isCapturing,
  });

  @override
  State<_CaptureButton> createState() => _CaptureButtonState();
}

class _CaptureButtonState extends State<_CaptureButton> {
  double _scale = 1.0;

  void _onTapDown(TapDownDetails details) {
    if (!widget.isCapturing) {
      HapticFeedback.lightImpact();
      setState(() => _scale = 0.92);
    }
  }

  void _onTapUp(TapUpDetails details) {
    if (!widget.isCapturing) {
      HapticFeedback.mediumImpact();
      // Play camera shutter sound
      SoundService.instance.playShutterSound();
      setState(() => _scale = 1.0);
      widget.onPressed();
    }
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
          width: 72,
          height: 72,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.textPrimary,
          ),
          child: Center(
            child: widget.isCapturing
                ? const SizedBox(
                    width: 28,
                    height: 28,
                    child: CircularProgressIndicator(
                      color: AppColors.background,
                      strokeWidth: 2.5,
                    ),
                  )
                : const Icon(
                    MingCuteIcons.mgc_camera_2_ai_line,
                    color: AppColors.background,
                    size: 32,
                  ),
          ),
        ),
      ),
    );
  }
}
