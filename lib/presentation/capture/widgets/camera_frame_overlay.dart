import 'package:flutter/material.dart';
import 'package:ming_cute_icons/ming_cute_icons.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';

/// Camera frame overlay with snake placement guide
class CameraFrameOverlay extends StatelessWidget {
  final bool showCrosshair;

  const CameraFrameOverlay({
    super.key,
    this.showCrosshair = true,
  });

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: SafeArea(
        child: Column(
          children: [
            // Spacer to push content down
            const Spacer(),

            // Helper text positioned exactly above the frame
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Text(
                AppStrings.placeSnakeIntoFocus,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 16,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),

            // Centered frame
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: AspectRatio(
                aspectRatio: 4 / 3,
                child: Stack(
                  children: [
                    // Main frame with corners
                    Positioned.fill(
                      child: CustomPaint(
                        painter: FrameWithCornersPainter(
                          color: AppColors.textPrimary,
                          cornerLength: 30,
                          strokeWidth: 3,
                        ),
                      ),
                    ),

                    // Center crosshair
                    if (showCrosshair)
                      Center(
                        child: Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppColors.textPrimary,
                              width: 2,
                            ),
                          ),
                          child: const Icon(
                            MingCuteIcons.mgc_add_line,
                            color: AppColors.textPrimary,
                            size: 28,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),

            // Space for bottom controls
            const Spacer(),
          ],
        ),
      ),
    );
  }
}

/// Custom painter for frame with corner accents
class FrameWithCornersPainter extends CustomPainter {
  final Color color;
  final double cornerLength;
  final double strokeWidth;

  FrameWithCornersPainter({
    required this.color,
    this.cornerLength = 30,
    this.strokeWidth = 3,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final borderPaint = Paint()
      ..color = color.withValues(alpha: 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    // Draw thin border
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      borderPaint,
    );

    // Top-left corner
    canvas.drawLine(
      const Offset(0, 0),
      Offset(cornerLength, 0),
      paint,
    );
    canvas.drawLine(
      const Offset(0, 0),
      Offset(0, cornerLength),
      paint,
    );

    // Top-right corner
    canvas.drawLine(
      Offset(size.width - cornerLength, 0),
      Offset(size.width, 0),
      paint,
    );
    canvas.drawLine(
      Offset(size.width, 0),
      Offset(size.width, cornerLength),
      paint,
    );

    // Bottom-left corner
    canvas.drawLine(
      Offset(0, size.height - cornerLength),
      Offset(0, size.height),
      paint,
    );
    canvas.drawLine(
      Offset(0, size.height),
      Offset(cornerLength, size.height),
      paint,
    );

    // Bottom-right corner
    canvas.drawLine(
      Offset(size.width - cornerLength, size.height),
      Offset(size.width, size.height),
      paint,
    );
    canvas.drawLine(
      Offset(size.width, size.height - cornerLength),
      Offset(size.width, size.height),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
