import 'dart:io';

import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';

/// Loading state while analyzing the image with animated snake
class AnalysisLoading extends StatefulWidget {
  final File? imageFile;

  const AnalysisLoading({
    super.key,
    this.imageFile,
  });

  @override
  State<AnalysisLoading> createState() => _AnalysisLoadingState();
}

class _AnalysisLoadingState extends State<AnalysisLoading>
    with TickerProviderStateMixin {
  late AnimationController _scanLineController;
  late Animation<double> _scanLineAnimation;

  @override
  void initState() {
    super.initState();

    // Scanning line animation that moves up and down
    _scanLineController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat(reverse: true);

    _scanLineAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _scanLineController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _scanLineController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: context.backgroundColor,
      child: SafeArea(
        child: Column(
          children: [
            const Spacer(flex: 2),

            // Image with scanning animation
            _buildImageWithScanning(),

            const SizedBox(height: 48),

            // Loading text
            Text(
              AppStrings.analyzing,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 24,
                fontWeight: FontWeight.w900,
                color: context.textPrimaryColor,
              ),
            ),

            const SizedBox(height: 12),

            Text(
              'Our AI is identifying the snake species and pulling information...',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: context.textSecondaryColor,
              ),
            ),

            const Spacer(flex: 3),
          ],
        ),
      ),
    );
  }

  Widget _buildImageWithScanning() {
    const double imageSize = 280.0;
    const double cornerBracketLength = 24.0;
    const double cornerBracketWidth = 2.0;
    const double cornerBracketGap = 8.0;
    final double containerSize = imageSize + (cornerBracketLength * 2);
    final double imageOffset = cornerBracketLength;

    return SizedBox(
      width: containerSize,
      height: containerSize,
      child: Stack(
        children: [
          // Image container
          Positioned(
            top: imageOffset,
            left: imageOffset,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: SizedBox(
                width: imageSize,
                height: imageSize,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    // Captured image
                    if (widget.imageFile != null)
                      Image.file(
                        widget.imageFile!,
                        fit: BoxFit.cover,
                      )
                    else
                      Container(
                        color: AppColors.backgroundSecondaryDark,
                        child: const Center(
                          child: Icon(
                            Icons.image_outlined,
                            color: AppColors.textSecondaryDark,
                            size: 48,
                          ),
                        ),
                      ),

                    // Green gradient overlay
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            AppColors.primary.withValues(alpha: 0.3),
                            AppColors.primary.withValues(alpha: 0.2),
                            AppColors.primary.withValues(alpha: 0.3),
                          ],
                          stops: const [0.0, 0.5, 1.0],
                        ),
                      ),
                    ),

                    // Scanning line
                    AnimatedBuilder(
                      animation: _scanLineAnimation,
                      builder: (context, child) {
                        final linePosition = _scanLineAnimation.value;
                        final lineY = linePosition * imageSize;

                        return Positioned(
                          top: lineY,
                          left: 0,
                          right: 0,
                          child: Container(
                            height: 2,
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primary.withValues(alpha: 0.5),
                                  blurRadius: 4,
                                  spreadRadius: 1,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Corner brackets (white dashed L-shapes) - positioned at image corners
          // Top-left corner
          Positioned(
            top: imageOffset - cornerBracketGap,
            left: imageOffset - cornerBracketGap,
            child: CustomPaint(
              size: Size(cornerBracketLength, cornerBracketLength),
              painter: CornerBracketPainter(
                color: AppColors.white,
                strokeWidth: cornerBracketWidth,
                corner: Corner.topLeft,
                gap: cornerBracketGap,
              ),
            ),
          ),
          // Top-right corner
          Positioned(
            top: imageOffset - cornerBracketGap,
            right: imageOffset - cornerBracketGap,
            child: CustomPaint(
              size: Size(cornerBracketLength, cornerBracketLength),
              painter: CornerBracketPainter(
                color: AppColors.white,
                strokeWidth: cornerBracketWidth,
                corner: Corner.topRight,
                gap: cornerBracketGap,
              ),
            ),
          ),
          // Bottom-left corner
          Positioned(
            bottom: imageOffset - cornerBracketGap,
            left: imageOffset - cornerBracketGap,
            child: CustomPaint(
              size: Size(cornerBracketLength, cornerBracketLength),
              painter: CornerBracketPainter(
                color: AppColors.white,
                strokeWidth: cornerBracketWidth,
                corner: Corner.bottomLeft,
                gap: cornerBracketGap,
              ),
            ),
          ),
          // Bottom-right corner
          Positioned(
            bottom: imageOffset - cornerBracketGap,
            right: imageOffset - cornerBracketGap,
            child: CustomPaint(
              size: Size(cornerBracketLength, cornerBracketLength),
              painter: CornerBracketPainter(
                color: AppColors.white,
                strokeWidth: cornerBracketWidth,
                corner: Corner.bottomRight,
                gap: cornerBracketGap,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Custom painter for corner brackets (L-shapes)
enum Corner { topLeft, topRight, bottomLeft, bottomRight }

class CornerBracketPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final Corner corner;
  final double gap;

  CornerBracketPainter({
    required this.color,
    required this.strokeWidth,
    required this.corner,
    required this.gap,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    // Dashed pattern
    paint.strokeWidth = strokeWidth;
    final dashWidth = 4.0;
    final dashSpace = 2.0;

    switch (corner) {
      case Corner.topLeft:
        _drawDashedLine(
          canvas,
          paint,
          Offset(gap, gap),
          Offset(gap, size.height),
          dashWidth,
          dashSpace,
        );
        _drawDashedLine(
          canvas,
          paint,
          Offset(gap, gap),
          Offset(size.width, gap),
          dashWidth,
          dashSpace,
        );
        break;
      case Corner.topRight:
        _drawDashedLine(
          canvas,
          paint,
          Offset(size.width - gap, gap),
          Offset(size.width - gap, size.height),
          dashWidth,
          dashSpace,
        );
        _drawDashedLine(
          canvas,
          paint,
          Offset(size.width - gap, gap),
          Offset(0, gap),
          dashWidth,
          dashSpace,
        );
        break;
      case Corner.bottomLeft:
        _drawDashedLine(
          canvas,
          paint,
          Offset(gap, size.height - gap),
          Offset(gap, 0),
          dashWidth,
          dashSpace,
        );
        _drawDashedLine(
          canvas,
          paint,
          Offset(gap, size.height - gap),
          Offset(size.width, size.height - gap),
          dashWidth,
          dashSpace,
        );
        break;
      case Corner.bottomRight:
        _drawDashedLine(
          canvas,
          paint,
          Offset(size.width - gap, size.height - gap),
          Offset(size.width - gap, 0),
          dashWidth,
          dashSpace,
        );
        _drawDashedLine(
          canvas,
          paint,
          Offset(size.width - gap, size.height - gap),
          Offset(0, size.height - gap),
          dashWidth,
          dashSpace,
        );
        break;
    }
  }

  void _drawDashedLine(
    Canvas canvas,
    Paint paint,
    Offset start,
    Offset end,
    double dashWidth,
    double dashSpace,
  ) {
    final path = Path();
    path.moveTo(start.dx, start.dy);

    final distance = (end - start).distance;
    final direction = (end - start) / distance;
    double currentDistance = 0;

    while (currentDistance < distance) {
      final dashEnd = start + direction * (currentDistance + dashWidth).clamp(0.0, distance);
      path.lineTo(dashEnd.dx, dashEnd.dy);
      currentDistance += dashWidth + dashSpace;
      if (currentDistance < distance) {
        path.moveTo((start + direction * currentDistance).dx, (start + direction * currentDistance).dy);
      }
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
