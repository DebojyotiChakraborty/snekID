import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ming_cute_icons/ming_cute_icons.dart';
import 'haptic_button.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import 'cupertino_card.dart';

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
                    isDark
                        ? const Color(0xFF2C2C2E).withValues(alpha: 0.85)
                        : const Color(0xFFE5E5EA).withValues(alpha: 0.85),
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
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  const ThemePickerDialog({
    super.key,
    required this.selectedIndex,
    required this.onSelected,
  });

  static Future<void> show(
    BuildContext context, {
    required List<String> options, // Kept for API compatibility but ignored
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

  // Manual list of options to match the design
  final List<Map<String, dynamic>> _themeOptions = [
    {'label': 'Light mode', 'icon': MingCuteIcons.mgc_sun_line},
    {'label': 'Dark mode', 'icon': MingCuteIcons.mgc_moon_line},
    {'label': 'System', 'icon': MingCuteIcons.mgc_cellphone_line},
  ];

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
        padding: const EdgeInsets.all(24),
        child: SafeArea(
          child: Material(
            color: Colors.transparent,
            shape: const SquircleBorder(
              radius: BorderRadius.all(
                Radius.circular(AppConstants.alertBorderRadius),
              ),
            ),
            clipBehavior: Clip.antiAlias,
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
                decoration: BoxDecoration(
                  color:
                      isDark
                          ? const Color(0xFF1C1C1E).withOpacity(0.85)
                          : const Color(0xFFE5E5EA).withOpacity(0.85),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    Text(
                      'App Theme',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: isDark ? Colors.white : Colors.black,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Options
                    ...List.generate(_themeOptions.length, (index) {
                      final option = _themeOptions[index];
                      final isSelected = index == _selectedIndex;

                      return GestureDetector(
                        onTap: () {
                          HapticFeedback.lightImpact();
                          setState(() => _selectedIndex = index);
                        },
                        behavior: HitTestBehavior.opaque,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          child: Row(
                            children: [
                              Icon(
                                option['icon'] as IconData,
                                size: 24,
                                color: isDark ? Colors.white : Colors.black,
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Text(
                                  option['label'] as String,
                                  style: TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color:
                                        isDark
                                            ? Colors.white.withOpacity(0.9)
                                            : Colors.black.withOpacity(0.8),
                                  ),
                                ),
                              ),
                              if (isSelected)
                                Container(
                                  width: 24,
                                  height: 24,
                                  decoration: BoxDecoration(
                                    color: isDark ? Colors.white : Colors.black,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.check,
                                    size: 16,
                                    color: isDark ? Colors.black : Colors.white,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      );
                    }),

                    const SizedBox(height: 32),

                    // Continue Button
                    SizedBox(
                      width: double.infinity,
                      child: HapticButton(
                        onPressed: () {
                          widget.onSelected(_selectedIndex);
                          Navigator.of(context).pop();
                        },
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.black,
                        borderRadius: 100,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        child: const Text(
                          'Continue',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
