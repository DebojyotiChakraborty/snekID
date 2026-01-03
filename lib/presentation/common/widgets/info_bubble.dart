import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:ming_cute_icons/ming_cute_icons.dart';

/// A reusable info bubble with frosted glass effect and an arrow pointer.
class InfoBubble extends StatelessWidget {
  final String title;
  final String content;
  final VoidCallback? onClose;
  final bool isVisible;

  const InfoBubble({
    super.key,
    required this.title,
    required this.content,
    this.onClose,
    this.isVisible = false,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      scale: isVisible ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutBack,
      alignment: Alignment.topLeft,
      child: AnimatedOpacity(
        opacity: isVisible ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        child: IgnorePointer(
          ignoring: !isVisible,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // The Arrow (Triangle)
              Padding(
                padding: const EdgeInsets.only(left: 12),
                child: ClipPath(
                  clipper: _TriangleClipper(),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                    child: Container(
                      width: 16,
                      height: 12,
                      decoration: BoxDecoration(
                        color: _getBackgroundColor(context),
                      ),
                    ),
                  ),
                ),
              ),
              // The Bubble Body
              Container(
                constraints: const BoxConstraints(maxWidth: 280),
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(30),
                      blurRadius: 16,
                      spreadRadius: 0,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                    child: Container(
                      padding: const EdgeInsets.fromLTRB(16, 12, 12, 16),
                      decoration: BoxDecoration(
                        color: _getBackgroundColor(context),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                title,
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: _getTextColor(context),
                                ),
                              ),
                              GestureDetector(
                                onTap: onClose,
                                child: Icon(
                                  MingCuteIcons.mgc_close_circle_line,
                                  size: 20,
                                  color: _getTextColor(
                                    context,
                                  ).withOpacity(0.6),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            content,
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 13,
                              fontWeight: FontWeight.w400,
                              color: _getTextColor(context).withOpacity(0.8),
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getBackgroundColor(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark
        ? const Color(0xFF1C1C1E).withOpacity(0.85)
        : const Color(0xFFE5E5EA).withOpacity(0.85);
  }

  Color _getTextColor(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? Colors.white : Colors.black;
  }
}

class _TriangleClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.moveTo(size.width / 2, 0); // Top center (tip)
    path.lineTo(0, size.height); // Bottom left
    path.lineTo(size.width, size.height); // Bottom right
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}
