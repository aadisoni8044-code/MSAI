import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../game/game_controller.dart';

class ControlsOverlay extends StatefulWidget {
  final GameController controller;

  const ControlsOverlay({super.key, required this.controller});

  @override
  State<ControlsOverlay> createState() => _ControlsOverlayState();
}

class _ControlsOverlayState extends State<ControlsOverlay> {
  // Joystick state
  Offset? _joystickCenter;
  Offset _joystickThumb = Offset.zero;
  bool _isJoystickActive = false;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Camera Look Drag Zone (Right top/middle screen)
        Positioned.fill(
          child: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onPanUpdate: (details) {
              widget.controller.handleCameraDrag(details.delta.dx, details.delta.dy);
            },
          ),
        ),

        // Left Bottom: Virtual Joystick Touch Region
        Positioned(
          left: 0,
          bottom: 0,
          width: MediaQuery.of(context).size.width * 0.45,
          height: MediaQuery.of(context).size.height * 0.6,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onPanStart: (details) {
              setState(() {
                _joystickCenter = details.localPosition;
                _joystickThumb = Offset.zero;
                _isJoystickActive = true;
              });
            },
            onPanUpdate: (details) {
              if (_joystickCenter == null) return;
              final diff = details.localPosition - _joystickCenter!;
              final dist = diff.distance;
              final maxRadius = 55.0;

              final clampedDiff = dist > maxRadius ? (diff / dist) * maxRadius : diff;

              setState(() {
                _joystickThumb = clampedDiff;
              });

              final normX = clampedDiff.dx / maxRadius;
              final normY = clampedDiff.dy / maxRadius;

              widget.controller.handleJoystickMove(normX, normY, 0.016);
            },
            onPanEnd: (_) {
              setState(() {
                _isJoystickActive = false;
                _joystickThumb = Offset.zero;
                _joystickCenter = null;
              });
              widget.controller.handleJoystickMove(0, 0, 0);
            },
            child: CustomPaint(
              painter: JoystickPainter(
                center: _joystickCenter,
                thumb: _joystickThumb,
                isActive: _isJoystickActive,
              ),
            ),
          ),
        ),

        // Right Bottom: Action Buttons (Attack, Sprint, Reload, Weapon Switch)
        Positioned(
          right: 20,
          bottom: 20,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // Column 1: Sprint & Reload
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Sprint Toggle Button
                  _ActionButton(
                    icon: Icons.directions_run,
                    label: 'SPRINT',
                    color: widget.controller.player.isSprinting ? Colors.greenAccent : Colors.grey.shade800,
                    size: 52,
                    onTapDown: () => widget.controller.handleSprint(true),
                    onTapUp: () => widget.controller.handleSprint(false),
                  ),
                  const SizedBox(height: 12),

                  // Reload Button
                  _ActionButton(
                    icon: Icons.published_with_changes,
                    label: 'RELOAD',
                    color: Colors.blueAccent,
                    size: 52,
                    onTapDown: widget.controller.handleReload,
                  ),
                ],
              ),
              const SizedBox(width: 14),

              // Column 2: Weapon Switch & Attack Button
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Switch Weapon Button
                  _ActionButton(
                    icon: Icons.swap_horizontal_circle,
                    label: 'SWITCH',
                    color: Colors.amber.shade700,
                    size: 54,
                    onTapDown: widget.controller.handleWeaponSwitch,
                  ),
                  const SizedBox(height: 12),

                  // ATTACK / SHOOT BUTTON (Large Primary)
                  _ActionButton(
                    icon: widget.controller.player.activeWeapon.isMelee ? Icons.hardware : Icons.my_location,
                    label: widget.controller.player.activeWeapon.isMelee ? 'SLASH' : 'FIRE',
                    color: Colors.redAccent,
                    size: 72,
                    onTapDown: widget.controller.handleAttack,
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final double size;
  final VoidCallback onTapDown;
  final VoidCallback? onTapUp;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.size,
    required this.onTapDown,
    this.onTapUp,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => onTapDown(),
      onTapUp: (_) => onTapUp?.call(),
      onTapCancel: () => onTapUp?.call(),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.85),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white.withValues(alpha: 0.8), width: 2),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.5),
              blurRadius: 8,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: size * 0.42),
            Text(
              label,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.black,
                fontSize: math.max(8, size * 0.16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class JoystickPainter extends CustomPainter {
  final Offset? center;
  final Offset thumb;
  final bool isActive;

  JoystickPainter({required this.center, required this.thumb, required this.isActive});

  @override
  void paint(Canvas canvas, Size size) {
    if (!isActive || center == null) return;

    final basePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.18)
      ..style = PaintingStyle.fill;

    final borderPaint = Paint()
      ..color = Colors.cyanAccent.withValues(alpha: 0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final thumbPaint = Paint()
      ..color = Colors.cyanAccent.withValues(alpha: 0.85)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(center!, 55.0, basePaint);
    canvas.drawCircle(center!, 55.0, borderPaint);
    canvas.drawCircle(center! + thumb, 24.0, thumbPaint);
  }

  @override
  bool shouldRepaint(covariant JoystickPainter oldDelegate) => true;
}
