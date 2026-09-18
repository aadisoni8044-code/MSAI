import 'package:flutter/material.dart';
import '../game/forest_game.dart';

class OnScreenControls extends StatelessWidget {
  final ForestGame game;

  const OnScreenControls({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 24,
      left: 20,
      right: 20,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Directional Buttons (Left & Right)
          Row(
            children: [
              _buildControlButton(
                icon: Icons.arrow_back_ios_new_rounded,
                onTapDown: (_) => game.player.moveLeft(),
                onTapUp: (_) => game.player.stopMoving(),
                onTapCancel: () => game.player.stopMoving(),
              ),
              const SizedBox(width: 16),
              _buildControlButton(
                icon: Icons.arrow_forward_ios_rounded,
                onTapDown: (_) => game.player.moveRight(),
                onTapUp: (_) => game.player.stopMoving(),
                onTapCancel: () => game.player.stopMoving(),
              ),
            ],
          ),

          // Action Buttons (Attack & Jump)
          Row(
            children: [
              _buildControlButton(
                icon: Icons.colorize,
                color: const Color(0xFFEF4444),
                onTapDown: (_) => game.player.attack(),
              ),
              const SizedBox(width: 16),
              _buildControlButton(
                icon: Icons.arrow_upward_rounded,
                color: const Color(0xFF10B981),
                onTapDown: (_) => game.player.jump(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    Color color = const Color(0xFF38BDF8),
    Function(TapDownDetails)? onTapDown,
    Function(TapUpDetails)? onTapUp,
    VoidCallback? onTapCancel,
  }) {
    return GestureDetector(
      onTapDown: onTapDown,
      onTapUp: onTapUp,
      onTapCancel: onTapCancel,
      child: Container(
        width: 64,
        height: 64,
        decoration: BoxDecoration(
          color: const Color(0xFF0F172A).withValues(alpha: 0.65),
          shape: BoxShape.circle,
          border: Border.all(color: color.withValues(alpha: 0.8), width: 2),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.25),
              blurRadius: 10,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Icon(icon, color: color, size: 28),
      ),
    );
  }
}
