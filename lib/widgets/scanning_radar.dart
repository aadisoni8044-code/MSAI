import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';

class ScanningRadar extends StatefulWidget {
  final bool isScanning;
  final double size;

  const ScanningRadar({
    super.key,
    required this.isScanning,
    this.size = 180,
  });

  @override
  State<ScanningRadar> createState() => _ScanningRadarState();
}

class _ScanningRadarState extends State<ScanningRadar>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    if (widget.isScanning) {
      _controller.repeat();
    }
  }

  @override
  void didUpdateWidget(covariant ScanningRadar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isScanning && !_controller.isAnimating) {
      _controller.repeat();
    } else if (!widget.isScanning && _controller.isAnimating) {
      _controller.stop();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return CustomPaint(
            painter: _RadarPainter(
              progress: _controller.value,
              isScanning: widget.isScanning,
            ),
            child: Center(
              child: Container(
                width: 48,
                height: 48,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primary,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary,
                      blurRadius: 12,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Icon(
                  widget.isScanning
                      ? Icons.bluetooth_searching
                      : Icons.bluetooth,
                  color: Colors.white,
                  size: 26,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _RadarPainter extends CustomPainter {
  final double progress;
  final bool isScanning;

  _RadarPainter({required this.progress, required this.isScanning});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final maxRadius = size.width / 2;

    final circlePaint = Paint()
      ..color = AppColors.primary.withValues(alpha: 0.15)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    // Draw concentric radar circles
    canvas.drawCircle(center, maxRadius * 0.4, circlePaint);
    canvas.drawCircle(center, maxRadius * 0.7, circlePaint);
    canvas.drawCircle(center, maxRadius, circlePaint);

    if (isScanning) {
      final pulseRadius = maxRadius * progress;
      final pulsePaint = Paint()
        ..color = AppColors.primary.withValues(alpha: (1 - progress) * 0.5)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3;

      canvas.drawCircle(center, pulseRadius, pulsePaint);
    }
  }

  @override
  bool shouldRepaint(covariant _RadarPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.isScanning != isScanning;
  }
}
