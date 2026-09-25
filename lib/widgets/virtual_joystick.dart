import 'package:flutter/material.dart';
import 'package:enchanted_forest_adventure/core/game_colors.dart';

class VirtualJoystick extends StatefulWidget {
  final ValueChanged<double> onChanged;
  final VoidCallback? onReleased;

  const VirtualJoystick({
    super.key,
    required this.onChanged,
    this.onReleased,
  });

  @override
  State<VirtualJoystick> createState() => _VirtualJoystickState();
}

class _VirtualJoystickState extends State<VirtualJoystick> {
  Offset _dragOffset = Offset.zero;
  static const double _radius = 55.0;

  void _updatePosition(Offset localPos) {
    final double dx = localPos.dx - _radius;
    final double normalizedX = (dx / _radius).clamp(-1.0, 1.0);

    setState(() {
      _dragOffset = Offset(normalizedX * _radius, 0);
    });

    widget.onChanged(normalizedX);
  }

  void _reset() {
    setState(() {
      _dragOffset = Offset.zero;
    });
    widget.onChanged(0.0);
    widget.onReleased?.call();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanStart: (details) => _updatePosition(details.localPosition),
      onPanUpdate: (details) => _updatePosition(details.localPosition),
      onPanEnd: (_) => _reset(),
      onPanCancel: () => _reset(),
      child: Container(
        width: _radius * 2,
        height: _radius * 2,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: GameColors.uiButtonBg,
          border: Border.all(color: GameColors.uiGlassBorder, width: 2.5),
          boxShadow: const [
            BoxShadow(
              color: Colors.black38,
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Direction arrows indicator
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Padding(
                  padding: EdgeInsets.only(left: 8.0),
                  child: Icon(Icons.arrow_left, color: GameColors.mistBlue, size: 24),
                ),
                Padding(
                  padding: EdgeInsets.only(right: 8.0),
                  child: Icon(Icons.arrow_right, color: GameColors.mistBlue, size: 24),
                ),
              ],
            ),
            // Thumb knob
            Transform.translate(
              offset: _dragOffset,
              child: Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: GameColors.uiButtonActive,
                  border: Border.all(color: GameColors.playerGlow, width: 2),
                  boxShadow: const [
                    BoxShadow(
                      color: GameColors.playerGlow,
                      blurRadius: 8,
                      spreadRadius: -2,
                    ),
                  ],
                ),
                child: const Icon(Icons.drag_handle, color: Colors.white, size: 22),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
