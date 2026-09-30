import 'package:flutter/material.dart';

enum ZipgramLogoStyle {
  iconOnly,
  wordmark,
  iconAndWordmark,
}

class ZipgramLogo extends StatelessWidget {
  final double size;
  final ZipgramLogoStyle style;
  final Color? color;
  final bool showTagline;

  const ZipgramLogo({
    super.key,
    this.size = 36.0,
    this.style = ZipgramLogoStyle.iconAndWordmark,
    this.color,
    this.showTagline = false,
  });

  @override
  Widget build(BuildContext meContext) {
    final theme = Theme.of(meContext);
    final isDark = theme.brightness == Brightness.dark;

    final primaryColor = color ?? const Color(0xFF0088CC);
    final textColor = color ?? (isDark ? Colors.white : const Color(0xFF0F172A));

    Widget iconWidget = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: primaryColor,
        borderRadius: BorderRadius.circular(size * 0.28),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withValues(alpha: 0.35),
            blurRadius: size * 0.25,
            offset: Offset(0, size * 0.1),
          ),
        ],
      ),
      child: Center(
        child: CustomPaint(
          size: Size(size * 0.65, size * 0.65),
          painter: _ZipgramIconPainter(color: Colors.white),
        ),
      ),
    );

    if (style == ZipgramLogoStyle.iconOnly) {
      return iconWidget;
    }

    Widget wordmarkWidget = Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAlignment.center,
      children: [
        Text(
          'ZIP',
          style: TextStyle(
            fontSize: size * 0.62,
            fontWeight: FontWeight.extrabold,
            color: textColor,
            letterSpacing: 0.5,
            fontFamily: 'Roboto',
          ),
        ),
        Text(
          'gram',
          style: TextStyle(
            fontSize: size * 0.62,
            fontWeight: FontWeight.w400,
            color: primaryColor,
            letterSpacing: 0.2,
            fontFamily: 'Roboto',
          ),
        ),
      ],
    );

    if (style == ZipgramLogoStyle.wordmark) {
      return wordmarkWidget;
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAlignment.center,
      children: [
        iconWidget,
        SizedBox(width: size * 0.35),
        Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            wordmarkWidget,
            if (showTagline)
              Padding(
                padding: const EdgeInsets.only(top: 2.0),
                child: Text(
                  'Chat nearby. Connect directly.',
                  style: TextStyle(
                    fontSize: size * 0.28,
                    fontWeight: FontWeight.w500,
                    color: primaryColor.withValues(alpha: 0.85),
                    letterSpacing: 0.3,
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}

class _ZipgramIconPainter extends CustomPainter {
  final Color color;

  _ZipgramIconPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final w = size.width;
    final h = size.height;

    // Outer rounded chat bubble shape
    final bubbleRect = RRect.fromLTRBR(
      0,
      0,
      w,
      h * 0.82,
      Radius.circular(w * 0.25),
    );

    // Tail on bottom-left
    final tailPath = Path()
      ..moveTo(w * 0.2, h * 0.8)
      ..lineTo(w * 0.08, h)
      ..lineTo(w * 0.35, h * 0.82)
      ..close();

    final combinedBubble = Path()
      ..addRRect(bubbleRect)
      ..addPath(tailPath, Offset.zero);

    canvas.drawPath(combinedBubble, paint);

    // Inner Cutout Symbol: Lightning/Zip link waves in dark contrast
    final cutoutPaint = Paint()
      ..color = const Color(0xFF0088CC)
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.12
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final zipPath = Path()
      ..moveTo(w * 0.32, h * 0.28)
      ..lineTo(w * 0.68, h * 0.28)
      ..lineTo(w * 0.38, h * 0.44)
      ..lineTo(w * 0.68, h * 0.44)
      ..lineTo(w * 0.38, h * 0.60)
      ..lineTo(w * 0.68, h * 0.60);

    canvas.drawPath(zipPath, cutoutPaint);
  }

  @override
  bool shouldRepaint(covariant _ZipgramIconPainter oldDelegate) =>
      oldDelegate.color != color;
}
