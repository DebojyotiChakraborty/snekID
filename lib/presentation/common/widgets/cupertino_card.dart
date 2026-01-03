import 'package:flutter/material.dart';

/// Generates a squircle (superellipse) path for the given rectangle and optional border radius.
///
/// A squircle is a shape that interpolates between a square and a circle,
/// providing a more organic, iOS-like rounded rectangle appearance.
Path squirclePath(Rect rect, BorderRadius? radius) {
  final c = rect.center;
  double startX = rect.left;
  double endX = rect.right;
  double startY = rect.top;
  double endY = rect.bottom;

  double midX = c.dx;
  double midY = c.dy;

  if (radius == null) {
    return Path()
      ..moveTo(startX, midY)
      ..cubicTo(startX, startY, startX, startY, midX, startY)
      ..cubicTo(endX, startY, endX, startY, endX, midY)
      ..cubicTo(endX, endY, endX, endY, midX, endY)
      ..cubicTo(startX, endY, startX, endY, startX, midY)
      ..close();
  }

  return Path()
    // Start position
    ..moveTo(startX, startY + radius.topLeft.y)
    // Top left corner
    ..cubicTo(startX, startY, startX, startY, startX + radius.topLeft.x, startY)
    // Top line
    ..lineTo(endX - radius.topRight.x, startY)
    // Top right corner
    ..cubicTo(endX, startY, endX, startY, endX, startY + radius.topRight.y)
    // Right line
    ..lineTo(endX, endY - radius.bottomRight.y)
    // Bottom right corner
    ..cubicTo(endX, endY, endX, endY, endX - radius.bottomRight.x, endY)
    // Bottom line
    ..lineTo(startX + radius.bottomLeft.x, endY)
    // Bottom left corner
    ..cubicTo(startX, endY, startX, endY, startX, endY - radius.bottomLeft.y)
    ..close();
}

/// A [ShapeBorder] that draws a squircle (superellipse) shape.
///
/// This provides a more organic, iOS-like rounded rectangle appearance
/// compared to the standard [RoundedRectangleBorder].
class SquircleBorder extends ShapeBorder {
  final BorderSide side;
  final BorderRadius? radius;

  const SquircleBorder({this.side = BorderSide.none, this.radius});

  @override
  EdgeInsetsGeometry get dimensions => EdgeInsets.all(side.width);

  @override
  ShapeBorder scale(double t) {
    return SquircleBorder(side: side.scale(t), radius: radius);
  }

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) {
    return squirclePath(rect.deflate(side.width), radius);
  }

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) {
    return squirclePath(rect, radius);
  }

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {
    switch (side.style) {
      case BorderStyle.none:
        break;
      case BorderStyle.solid:
        var path = getOuterPath(
          rect.deflate(side.width / 2.0),
          textDirection: textDirection,
        );
        canvas.drawPath(path, side.toPaint());
    }
  }
}

/// A Material card widget with squircle (superellipse) border.
///
/// This widget provides an iOS-like card appearance with smooth,
/// organic rounded corners. It supports elevation, custom colors,
/// and tap interactions.
class CupertinoCard extends StatelessWidget {
  /// The margin around the card.
  final EdgeInsets margin;

  /// The padding inside the card.
  final EdgeInsets padding;

  /// The child widget to display inside the card.
  final Widget? child;

  /// The elevation of the card shadow.
  final double elevation;

  /// The background color of the card.
  final Color color;

  /// The splash color when the card is tapped.
  final Color? splashColor;

  /// The border radius of the squircle corners.
  final BorderRadius radius;

  /// Optional decoration for the card.
  final Decoration? decoration;

  /// Callback when the card is tapped.
  final VoidCallback? onPressed;

  const CupertinoCard({
    super.key,
    this.child,
    this.elevation = 0.0,
    this.margin = const EdgeInsets.all(0.0),
    this.padding = const EdgeInsets.all(0.0),
    this.color = Colors.white,
    this.splashColor,
    this.decoration,
    this.radius = const BorderRadius.all(Radius.circular(20.0)),
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final shapeBorder = SquircleBorder(radius: radius);

    return Padding(
      padding: margin,
      child: Material(
        elevation: elevation,
        shape: shapeBorder,
        color: Colors.transparent,
        child: ClipPath.shape(
          shape: shapeBorder,
          child: Material(
            color: color,
            child: Ink(
              decoration: decoration,
              child: InkWell(
                customBorder: shapeBorder,
                onTap: onPressed,
                splashColor: splashColor,
                child: Padding(padding: padding, child: child),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
