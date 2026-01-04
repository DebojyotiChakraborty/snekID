import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// A widget that handles page transitions for PageView navigation (e.g., onboarding).
/// This animates when the page becomes active.
class PageTransition extends StatelessWidget {
  final Widget child;
  final bool isActive;
  final Duration duration;

  const PageTransition({
    super.key,
    required this.child,
    required this.isActive,
    this.duration = const Duration(milliseconds: 1000),
  });

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      ignoring: !isActive,
      child:
          isActive
              ? child
                  .animate()
                  .blur(
                    begin: const Offset(90, 90),
                    end: const Offset(0, 0),
                    curve: Curves.easeOutExpo,
                    duration: duration,
                  )
                  .fadeIn(duration: duration, curve: Curves.ease)
                  .moveY(begin: 15, end: 0)
              : const SizedBox.shrink(),
    );
  }
}

/// A widget that animates screen content on entry with blur, fade, and vertical movement.
/// This is designed for screen-level transitions when navigating to a new screen.
class ScreenPageTransition extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final Duration delay;
  final double blurAmount;
  final double moveYAmount;

  const ScreenPageTransition({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 800),
    this.delay = Duration.zero,
    this.blurAmount = 60,
    this.moveYAmount = 20,
  });

  @override
  State<ScreenPageTransition> createState() => _ScreenPageTransitionState();
}

class _ScreenPageTransitionState extends State<ScreenPageTransition> {
  bool _hasAnimated = false;

  @override
  void initState() {
    super.initState();
    // Trigger animation after the first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() {
          _hasAnimated = true;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_hasAnimated) {
      // Return invisible widget on first frame to avoid flash
      return Opacity(opacity: 0, child: widget.child);
    }

    return widget.child
        .animate()
        .blur(
          begin: Offset(widget.blurAmount, widget.blurAmount),
          end: const Offset(0, 0),
          curve: Curves.easeOutExpo,
          duration: widget.duration,
          delay: widget.delay,
        )
        .fadeIn(
          duration: widget.duration,
          curve: Curves.easeOut,
          delay: widget.delay,
        )
        .moveY(
          begin: widget.moveYAmount,
          end: 0,
          curve: Curves.easeOutExpo,
          duration: widget.duration,
          delay: widget.delay,
        );
  }
}
