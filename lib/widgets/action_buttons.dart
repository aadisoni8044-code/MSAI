import 'package:flutter/material.dart';
import 'package:enchanted_forest_adventure/core/game_colors.dart';

class ActionButtons extends StatelessWidget {
  final VoidCallback onJump;
  final VoidCallback? onJumpRelease;
  final VoidCallback onAttack;

  const ActionButtons({
    super.key,
    required this.onJump,
    this.onJumpRelease,
    required this.onAttack,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Attack Button
        _ActionButton(
          icon: Icons.flash_on,
          label: 'ATTACK',
          glowColor: GameColors.shadowEnemyGlow,
          buttonSize: 64,
          onPressed: onAttack,
        ),
        const SizedBox(width: 16),
        // Jump Button
        _ActionButton(
          icon: Icons.keyboard_arrow_up,
          label: 'JUMP',
          glowColor: GameColors.playerGlow,
          buttonSize: 74,
          onPressed: onJump,
          onReleased: onJumpRelease,
        ),
      ],
    );
  }
}

class _ActionButton extends StatefulWidget {
  final IconData icon;
  final String label;
  final Color glowColor;
  final double buttonSize;
  final VoidCallback onPressed;
  final VoidCallback? onReleased;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.glowColor,
    required this.buttonSize,
    required this.onPressed,
    this.onReleased,
  });

  @override
  State<_ActionButton> createState() => _ActionButtonState();
}

class _ActionButtonState extends State<_ActionButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) {
        setState(() => _isPressed = true);
        widget.onPressed();
      },
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onReleased?.call();
      },
      onTapCancel: () {
        setState(() => _isPressed = false);
        widget.onReleased?.call();
      },
      child: AnimatedScale(
        scale: _isPressed ? 0.92 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: Container(
          width: widget.buttonSize,
          height: widget.buttonSize,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: _isPressed ? GameColors.uiButtonActive : GameColors.uiButtonBg,
            border: Border.all(
              color: _isPressed ? widget.glowColor : GameColors.uiGlassBorder,
              width: 2.5,
            ),
            boxShadow: [
              BoxShadow(
                color: _isPressed ? widget.glowColor.withValues(alpha: 0.6) : Colors.black45,
                blurRadius: _isPressed ? 14 : 8,
                spreadRadius: _isPressed ? 1 : 0,
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(widget.icon, color: widget.glowColor, size: widget.buttonSize * 0.45),
              Text(
                widget.label,
                style: TextStyle(
                  color: GameColors.uiTextLight,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.8,
                  shadows: [
                    Shadow(color: widget.glowColor, blurRadius: 4),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
