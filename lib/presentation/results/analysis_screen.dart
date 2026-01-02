import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ming_cute_icons/ming_cute_icons.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/router/app_router.dart';
import '../../providers/capture_provider.dart';
import '../../providers/identification_provider.dart';
import '../../data/services/image_service.dart';

class AnalysisScreen extends ConsumerStatefulWidget {
  final File? imageFile;

  const AnalysisScreen({super.key, this.imageFile});

  @override
  ConsumerState<AnalysisScreen> createState() => _AnalysisScreenState();
}

class _AnalysisScreenState extends ConsumerState<AnalysisScreen>
    with TickerProviderStateMixin {
  late AnimationController _scanLineController;
  late Animation<double> _scanLineAnimation;
  late AnimationController _shrinkController;
  late Animation<double> _shrinkAnimation;
  final ImageService _imageService = ImageService();
  bool _hasNavigated = false;

  @override
  void initState() {
    super.initState();

    // Scanning line animation that moves up and down
    _scanLineController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat(reverse: true);

    _scanLineAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _scanLineController, curve: Curves.easeInOut),
    );

    // Image shrink animation (from fullscreen to small box)
    _shrinkController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _shrinkAnimation = CurvedAnimation(
      parent: _shrinkController,
      curve: Curves.easeOutCubic,
    );

    // Start shrink after a short delay for smooth entry
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) {
        _shrinkController.forward();
      }
    });

    // Start identification
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startIdentification();
    });
  }

  void _startIdentification() {
    final image = widget.imageFile ?? ref.read(selectedImageProvider);
    if (image != null) {
      // Ensure provider has the image
      ref.read(selectedImageProvider.notifier).state = image;
      ref.read(identificationProvider.notifier).identifySnake(image);
    } else {
      // Fallback if no image
      context.go(AppRoutes.capture);
    }
  }

  @override
  void dispose() {
    _scanLineController.dispose();
    _shrinkController.dispose();
    super.dispose();
  }

  void _handleResult() async {
    if (_hasNavigated) return;

    final state = ref.read(identificationProvider);

    if (state.hasValue && state.value != null) {
      _hasNavigated = true;

      // Navigate to results with a small delay to let animation play a bit
      // and ensure the Hero transition looks good
      await Future.delayed(const Duration(milliseconds: 500));

      if (mounted) {
        context.pushReplacement(
          AppRoutes.results,
          extra: {
            'identification': state.value,
            'imageFile': widget.imageFile ?? ref.read(selectedImageProvider),
            'isNewAnalysis': true,
          },
        );
      }
    } else if (state.hasError) {
      // Handle error state locally or navigate to error screen
      // For now stay here and show error
    }
  }

  @override
  Widget build(BuildContext context) {
    // Listen to identification changes
    ref.listen(identificationProvider, (previous, next) {
      if (next.hasValue && next.value != null) {
        _handleResult();
      }
    });

    final error = ref.watch(identificationProvider).error;

    return Scaffold(
      backgroundColor: context.backgroundColor,
      body:
          error != null
              ? _buildErrorState(error.toString())
              : SafeArea(
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

    final image = widget.imageFile ?? ref.read(selectedImageProvider);

    // Animate from slightly larger (1.15x) to normal (1.0x) for smooth entry
    return AnimatedBuilder(
      animation: _shrinkAnimation,
      builder: (context, child) {
        final scale = 1.15 - (0.15 * _shrinkAnimation.value);
        final opacity = _shrinkAnimation.value;

        return Transform.scale(
          scale: scale,
          child: Opacity(
            opacity:
                0.3 + (0.7 * opacity), // Start at 30% opacity, fade to 100%
            child: SizedBox(
              width: containerSize,
              height: containerSize,
              child: child,
            ),
          ),
        );
      },
      child: Stack(
        children: [
          // Image container
          // Image container with Hero
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
                    // Captured image (Hero)
                    Hero(
                      tag: 'snake_image',
                      child:
                          image != null
                              ? Image.file(image, fit: BoxFit.cover)
                              : Container(
                                color: AppColors.backgroundSecondaryDark,
                                child: const Center(
                                  child: Icon(
                                    Icons.image_outlined,
                                    color: AppColors.textSecondaryDark,
                                    size: 48,
                                  ),
                                ),
                              ),
                    ),

                    // Green gradient overlay (Fade in, outside Hero)
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
                  ],
                ),
              ),
            ),
          ),

          // Scanning Line (Outside Hero to avoid flying with it if we don't want it to)
          // Actually, if we want the scanning line to disappear during transition, this is fine.
          Positioned(
            top: imageOffset,
            left: imageOffset,
            width: imageSize,
            height: imageSize,
            child: AnimatedBuilder(
              animation: _scanLineAnimation,
              builder: (context, child) {
                final linePosition = _scanLineAnimation.value;
                final lineY = linePosition * imageSize;

                return Stack(
                  children: [
                    Positioned(
                      top: lineY,
                      left: 0,
                      right: 0,
                      child: Container(
                        height: 2,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                            colors: [
                              AppColors.primary.withValues(alpha: 0.0),
                              AppColors.primary,
                              AppColors.primary.withValues(alpha: 0.0),
                            ],
                            stops: const [0.0, 0.5, 1.0],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.5),
                              blurRadius: 6,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),

          // Corner brackets
          // Top-left corner
          Positioned(
            top: imageOffset - cornerBracketGap,
            left: imageOffset - cornerBracketGap,
            child: CustomPaint(
              size: const Size(cornerBracketLength, cornerBracketLength),
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
              size: const Size(cornerBracketLength, cornerBracketLength),
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
              size: const Size(cornerBracketLength, cornerBracketLength),
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
              size: const Size(cornerBracketLength, cornerBracketLength),
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

  Widget _buildErrorState(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              MingCuteIcons.mgc_warning_line,
              size: 64,
              color: AppColors.error,
            ),
            const SizedBox(height: 16),
            const Text(
              AppStrings.errorAnalysis,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                ref.read(identificationProvider.notifier).reset();
                context.go(AppRoutes.capture);
              },
              child: const Text('Try Again'),
            ),
          ],
        ),
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
    final paint =
        Paint()
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
      final dashEnd =
          start +
          direction * (currentDistance + dashWidth).clamp(0.0, distance);
      path.lineTo(dashEnd.dx, dashEnd.dy);
      currentDistance += dashWidth + dashSpace;
      if (currentDistance < distance) {
        path.moveTo(
          (start + direction * currentDistance).dx,
          (start + direction * currentDistance).dy,
        );
      }
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
