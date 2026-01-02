import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ming_cute_icons/ming_cute_icons.dart';

import '../../../core/constants/app_colors.dart';

/// A reusable animated dialog with iOS-style design, frosted glass effect,
/// and slide-up animation similar to CaptureConfirmationDialog.
class AnimatedDialog extends StatefulWidget {
  final String title;
  final String? subtitle;
  final Widget? content;
  final String confirmLabel;
  final String cancelLabel;
  final VoidCallback onConfirm;
  final VoidCallback onCancel;
  final bool isDestructive;

  const AnimatedDialog({
    super.key,
    required this.title,
    this.subtitle,
    this.content,
    required this.confirmLabel,
    required this.cancelLabel,
    required this.onConfirm,
    required this.onCancel,
    this.isDestructive = false,
  });

  /// Show the animated dialog with a modal barrier
  static Future<void> show(
    BuildContext context, {
    required String title,
    String? subtitle,
    Widget? content,
    required String confirmLabel,
    required String cancelLabel,
    required VoidCallback onConfirm,
    VoidCallback? onCancel,
    bool isDestructive = false,
  }) {
    return showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Dismiss',
      barrierColor: Colors.black.withValues(alpha: 0.4),
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, animation, secondaryAnimation) {
        return AnimatedDialog(
          title: title,
          subtitle: subtitle,
          content: content,
          confirmLabel: confirmLabel,
          cancelLabel: cancelLabel,
          onConfirm: onConfirm,
          onCancel: onCancel ?? () => Navigator.of(context).pop(),
          isDestructive: isDestructive,
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        final curvedAnimation = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutExpo,
          reverseCurve: Curves.easeInExpo,
        );
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 1),
            end: Offset.zero,
          ).animate(curvedAnimation),
          child: child,
        );
      },
    );
  }

  @override
  State<AnimatedDialog> createState() => _AnimatedDialogState();
}

class _AnimatedDialogState extends State<AnimatedDialog> {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Align(
      alignment: Alignment.bottomCenter,
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          24,
          24,
          24,
          MediaQuery.of(context).padding.bottom + 24,
        ),
        child: Container(
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(30),
                blurRadius: 16,
                spreadRadius: 0,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color:
                      isDark
                          ? const Color(0xFF2C2C2E).withValues(alpha: 0.85)
                          : const Color(0xFFE5E5EA).withValues(alpha: 0.85),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Material(
                  type: MaterialType.transparency,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Title
                      Text(
                        widget.title,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.white : Colors.black,
                        ),
                      ),

                      // Subtitle
                      if (widget.subtitle != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          widget.subtitle!,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: isDark ? Colors.white70 : Colors.black54,
                          ),
                        ),
                      ],

                      // Custom content
                      if (widget.content != null) ...[
                        const SizedBox(height: 16),
                        widget.content!,
                      ],

                      const SizedBox(height: 20),

                      // Buttons row
                      Row(
                        children: [
                          // Cancel button
                          Expanded(
                            child: _DialogButton(
                              label: widget.cancelLabel,
                              onPressed: widget.onCancel,
                              isPrimary: false,
                              isDark: isDark,
                            ),
                          ),

                          const SizedBox(width: 12),

                          // Confirm button
                          Expanded(
                            child: _DialogButton(
                              label: widget.confirmLabel,
                              onPressed: widget.onConfirm,
                              isPrimary: true,
                              isDestructive: widget.isDestructive,
                              isDark: isDark,
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
        ),
      ),
    );
  }
}

class _DialogButton extends StatefulWidget {
  final String label;
  final VoidCallback onPressed;
  final bool isPrimary;
  final bool isDestructive;
  final bool isDark;

  const _DialogButton({
    required this.label,
    required this.onPressed,
    required this.isPrimary,
    this.isDestructive = false,
    required this.isDark,
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

  Color _getButtonColor() {
    if (!widget.isPrimary) {
      return widget.isDark ? const Color(0xFF636366) : const Color(0xFFB4B4B8);
    }
    if (widget.isDestructive) {
      return AppColors.error;
    }
    return AppColors.primary;
  }

  Color _getTextColor() {
    if (!widget.isPrimary) {
      return Colors.white;
    }
    if (widget.isDestructive) {
      return Colors.white;
    }
    return Colors.black;
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
            color: _getButtonColor(),
            borderRadius: BorderRadius.circular(100),
          ),
          child: Center(
            child: Text(
              widget.label,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: _getTextColor(),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Theme picker dialog specifically for settings
class ThemePickerDialog extends StatefulWidget {
  final List<String> options;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  const ThemePickerDialog({
    super.key,
    required this.options,
    required this.selectedIndex,
    required this.onSelected,
  });

  static Future<void> show(
    BuildContext context, {
    required List<String> options,
    required int selectedIndex,
    required ValueChanged<int> onSelected,
  }) {
    return showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Dismiss',
      barrierColor: Colors.black.withValues(alpha: 0.4),
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, animation, secondaryAnimation) {
        return ThemePickerDialog(
          options: options,
          selectedIndex: selectedIndex,
          onSelected: onSelected,
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        final curvedAnimation = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutExpo,
          reverseCurve: Curves.easeInExpo,
        );
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 1),
            end: Offset.zero,
          ).animate(curvedAnimation),
          child: child,
        );
      },
    );
  }

  @override
  State<ThemePickerDialog> createState() => _ThemePickerDialogState();
}

class _ThemePickerDialogState extends State<ThemePickerDialog> {
  late int _selectedIndex;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.selectedIndex;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Align(
      alignment: Alignment.bottomCenter,
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          24,
          24,
          24,
          MediaQuery.of(context).padding.bottom + 24,
        ),
        child: Container(
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(30),
                blurRadius: 16,
                spreadRadius: 0,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color:
                      isDark
                          ? const Color(0xFF2C2C2E).withValues(alpha: 0.85)
                          : const Color(0xFFE5E5EA).withValues(alpha: 0.85),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Material(
                  type: MaterialType.transparency,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Options
                      ...List.generate(widget.options.length, (index) {
                        final isSelected = index == _selectedIndex;
                        return GestureDetector(
                          onTap: () {
                            HapticFeedback.lightImpact();
                            setState(() => _selectedIndex = index);
                            widget.onSelected(index);
                            Navigator.of(context).pop();
                          },
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                              vertical: 16,
                              horizontal: 16,
                            ),
                            margin: EdgeInsets.only(
                              bottom: index < widget.options.length - 1 ? 8 : 0,
                            ),
                            decoration: BoxDecoration(
                              color:
                                  isSelected
                                      ? AppColors.primary.withValues(alpha: 0.2)
                                      : (isDark
                                          ? Colors.white.withValues(alpha: 0.05)
                                          : Colors.black.withValues(
                                            alpha: 0.05,
                                          )),
                              borderRadius: BorderRadius.circular(12),
                              border:
                                  isSelected
                                      ? Border.all(
                                        color: AppColors.primary.withValues(
                                          alpha: 0.5,
                                        ),
                                        width: 1.5,
                                      )
                                      : null,
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    widget.options[index],
                                    style: TextStyle(
                                      fontFamily: 'Inter',
                                      fontSize: 16,
                                      fontWeight:
                                          isSelected
                                              ? FontWeight.w600
                                              : FontWeight.w500,
                                      color:
                                          isDark ? Colors.white : Colors.black,
                                    ),
                                  ),
                                ),
                                if (isSelected)
                                  Icon(
                                    MingCuteIcons.mgc_check_circle_fill,
                                    color: AppColors.primary,
                                    size: 22,
                                  ),
                              ],
                            ),
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
