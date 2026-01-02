import 'package:flutter/material.dart';
import 'dart:ui';

enum DropPosition { top, bottom }

enum DropShape { pill, squared }

class Drops {
  static void show(
    BuildContext context, {
    required String title,
    Color? backgroundColor,
    Duration duration = const Duration(seconds: 3),
    Duration? transitionDuration = const Duration(milliseconds: 700),
    TextStyle? textStyle,
    Curve curve = Curves.easeOutExpo,
    Curve? reverseCurve,
    String? subtitle,
    IconData? icon,
    Color? iconColor,
    bool? isDestructive,
    TextStyle? titleTextStyle,
    TextStyle? subtitleTextStyle,
    DropPosition? position = DropPosition.top,
    EdgeInsets? padding,
    DropShape? shape,
    bool? highContrastText,
  }) {
    OverlayEntry? currentOverlay;
    currentOverlay = OverlayEntry(
      builder:
          (context) => _DropsWidget(
            title: title,
            backgroundColor: backgroundColor,
            duration: duration,
            transitionDuration: transitionDuration,
            curve: curve,
            reverseCurve: reverseCurve,
            isDestructive: isDestructive ?? false,
            subtitle: subtitle,
            titleTextStyle: titleTextStyle,
            subtitleTextStyle: subtitleTextStyle,
            position: position,
            padding: padding,
            shape: shape,
            highContrastText: highContrastText ?? true,
            icon: icon,
            iconColor: iconColor,
            onDismiss: () {
              currentOverlay?.remove();
              currentOverlay = null;
            },
          ),
    );
    Overlay.of(context).insert(currentOverlay!);
  }
}

class _DropsWidget extends StatefulWidget {
  final String title;
  final Color? backgroundColor;
  final Duration duration;
  final Duration? transitionDuration;
  final Curve curve;
  final Curve? reverseCurve;
  final VoidCallback onDismiss;
  final IconData? icon;
  final Color? iconColor;
  final String? subtitle;
  final bool isDestructive;
  final TextStyle? titleTextStyle;
  final TextStyle? subtitleTextStyle;
  final DropPosition? position;
  final EdgeInsets? padding;
  final DropShape? shape;
  final bool highContrastText;

  const _DropsWidget({
    required this.title,
    this.backgroundColor,
    required this.duration,
    this.curve = Curves.fastEaseInToSlowEaseOut,
    this.reverseCurve,
    required this.onDismiss,
    this.icon,
    this.iconColor,
    this.subtitle,
    this.transitionDuration,
    this.isDestructive = false,
    this.titleTextStyle,
    this.subtitleTextStyle,
    this.position,
    this.padding,
    this.shape = DropShape.pill,
    this.highContrastText = true,
  });

  @override
  _DropsWidgetState createState() => _DropsWidgetState();
}

class _DropsWidgetState extends State<_DropsWidget>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<Offset> _offsetAnimation;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: widget.transitionDuration,
      vsync: this,
    );

    _offsetAnimation = Tween<Offset>(
      begin: Offset(0, widget.position == DropPosition.top ? -1 : 1),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: widget.curve,
        reverseCurve: widget.reverseCurve ?? widget.curve.flipped,
      ),
    );

    _animationController.forward();

    Future.delayed(widget.duration, () {
      if (mounted) _dismissAlert();
    });

    _scrollController.addListener(() {
      if (_scrollController.offset > 30 &&
          widget.position == DropPosition.top) {
        _dismissAlert();
      }

      if (_scrollController.offset < -30 &&
          widget.position == DropPosition.bottom) {
        _dismissAlert();
      }
    });
  }

  void _dismissAlert() {
    _animationController.reverse().then((_) {
      if (mounted) widget.onDismiss();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Positioned(
      left: 0,
      top: widget.position == DropPosition.top ? 0 : null,
      bottom: widget.position == DropPosition.bottom ? 0 : null,
      right: 0,
      child: SlideTransition(
        position: _offsetAnimation,
        child: SingleChildScrollView(
          clipBehavior: Clip.none,
          controller: _scrollController,
          hitTestBehavior: HitTestBehavior.deferToChild,
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          child: SafeArea(
            child: Padding(
              padding: EdgeInsets.only(
                top: widget.position == DropPosition.top ? 12 : 0,
                bottom: widget.position == DropPosition.bottom ? 64 : 0,
              ),
              child: Center(
                child: Container(
                  clipBehavior:
                      widget.shape == DropShape.squared
                          ? Clip.none
                          : Clip.antiAlias,
                  decoration: ShapeDecoration(
                    shape: StadiumBorder(),
                    shadows: [
                      BoxShadow(
                        color: Colors.black.withAlpha(20),
                        blurRadius: 8,
                        spreadRadius: 0,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius:
                        widget.shape == DropShape.squared
                            ? BorderRadius.zero
                            : BorderRadius.circular(50),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                      child: Material(
                        color:
                            widget.backgroundColor ??
                            theme.primaryColor.withOpacity(0.6),
                        elevation: 0,
                        child: Padding(
                          padding:
                              widget.padding ??
                              EdgeInsets.only(
                                left:
                                    widget.subtitle != null &&
                                            widget.icon == null
                                        ? 30
                                        : 20,
                                right:
                                    widget.icon != null
                                        ? 28
                                        : widget.subtitle != null
                                        ? 30
                                        : 20,
                                top: widget.subtitle != null ? 10 : 16,
                                bottom: widget.subtitle != null ? 10 : 16,
                              ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              if (widget.icon != null)
                                Icon(
                                  widget.icon,
                                  color:
                                      widget.iconColor ??
                                      (widget.isDestructive
                                          ? theme.colorScheme.error
                                          : (widget.titleTextStyle?.color ??
                                              (widget.highContrastText
                                                  ? theme
                                                      .textTheme
                                                      .bodyLarge
                                                      ?.color
                                                  : theme
                                                      .textTheme
                                                      .bodyMedium
                                                      ?.color
                                                      ?.withOpacity(0.6)))),
                                ),
                              if (widget.icon != null)
                                const SizedBox(width: 11),
                              Flexible(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      widget.title,
                                      style:
                                          widget.titleTextStyle ??
                                          TextStyle(
                                            color:
                                                widget.highContrastText
                                                    ? theme
                                                        .textTheme
                                                        .bodyLarge
                                                        ?.color
                                                    : theme
                                                        .textTheme
                                                        .bodyMedium
                                                        ?.color
                                                        ?.withOpacity(0.6),
                                            fontSize: 15,
                                            fontWeight: FontWeight.w600,
                                          ),
                                      textAlign: TextAlign.center,
                                    ),
                                    if (widget.subtitle != null)
                                      Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const SizedBox(height: 3),
                                          Text(
                                            widget.subtitle!,
                                            style:
                                                widget.subtitleTextStyle ??
                                                TextStyle(
                                                  color:
                                                      widget.highContrastText
                                                          ? theme
                                                              .textTheme
                                                              .bodyMedium
                                                              ?.color
                                                              ?.withOpacity(0.6)
                                                          : theme
                                                              .textTheme
                                                              .bodyMedium
                                                              ?.color
                                                              ?.withOpacity(
                                                                0.4,
                                                              ),
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                            textAlign: TextAlign.center,
                                          ),
                                        ],
                                      ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
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
