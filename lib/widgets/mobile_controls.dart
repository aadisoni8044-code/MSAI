import 'package:flutter/material.dart';

import '../services/game_service.dart';

class MobileControlsWidget extends StatelessWidget {
  final GameService gameService;

  const MobileControlsWidget({super.key, required this.gameService});

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    bool isLandscape = media.orientation == Orientation.landscape;

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: isLandscape ? 24.0 : 16.0,
        vertical: isLandscape ? 16.0 : 24.0,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAlignment.bottom,
        children: [
          // Left Side: D-Pad (Left / Right)
          Row(
            children: [
              _buildControlButton(
                icon: Icons.arrow_back,
                onPressedDown: () => gameService.keyLeft = true,
                onPressedUp: () => gameService.keyLeft = false,
                size: 64,
              ),
              const SizedBox(width: 12),
              _buildControlButton(
                icon: Icons.arrow_forward,
                onPressedDown: () => gameService.keyRight = true,
                onPressedUp: () => gameService.keyRight = false,
                size: 64,
              ),
            ],
          ),

          // Right Side: Action Buttons (Jump, Attack, Dash)
          Row(
            crossAxisAlignment: CrossAlignment.bottom,
            children: [
              // Dash Button
              _buildActionButton(
                label: 'DASH',
                icon: Icons.bolt,
                color: const Color(0xFF80FFDB),
                onPressed: () => gameService.triggerDash(),
                size: 52,
              ),
              const SizedBox(width: 10),

              // Attack Button
              _buildActionButton(
                label: 'ATTACK',
                icon: Icons.colorize,
                color: const Color(0xFFEF476F),
                onPressed: () => gameService.triggerAttack(),
                size: 64,
              ),
              const SizedBox(width: 10),

              // Jump Button
              _buildActionButton(
                label: 'JUMP',
                icon: Icons.arrow_upward,
                color: const Color(0xFF64DFDF),
                onPressed: () => gameService.triggerJump(),
                size: 68,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required VoidCallback onPressedDown,
    required VoidCallback onPressedUp,
    required double size,
  }) {
    return Listener(
      onPointerDown: (_) => onPressedDown(),
      onPointerUp: (_) => onPressedUp(),
      onPointerCancel: (_) => onPressedUp(),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: const Color(0x990F3B3E),
          shape: BoxShape.circle,
          border: Border.all(color: const Color(0x6664DFDF), width: 2),
          boxShadow: const [
            BoxShadow(color: Color(0x44000000), blurRadius: 8),
          ],
        ),
        child: Icon(icon, color: Colors.white, size: size * 0.5),
      ),
    );
  }

  Widget _buildActionButton({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
    required double size,
  }) {
    return GestureDetector(
      onTapDown: (_) => onPressed(),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.25),
          shape: BoxShape.circle,
          border: Border.all(color: color, width: 2.5),
          boxShadow: [
            BoxShadow(color: color.withValues(alpha: 0.4), blurRadius: 10),
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
                fontSize: size * 0.16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
