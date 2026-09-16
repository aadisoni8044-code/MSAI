import 'package:flutter/material.dart';
import '../services/game_service.dart';

class MobileControls extends StatelessWidget {
  final GameService gameService;

  const MobileControls({
    super.key,
    required this.gameService,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 16,
      right: 16,
      bottom: 24,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Directional D-Pad Buttons (Left / Right)
          Row(
            children: [
              _buildControlButton(
                icon: Icons.arrow_back_ios_new_rounded,
                onTapDown: () => gameService.setMoveLeft(true),
                onTapUp: () => gameService.setMoveLeft(false),
              ),
              const SizedBox(width: 16),
              _buildControlButton(
                icon: Icons.arrow_forward_ios_rounded,
                onTapDown: () => gameService.setMoveRight(true),
                onTapUp: () => gameService.setMoveRight(false),
              ),
            ],
          ),

          // Action Buttons (Jump / Attack)
          Row(
            children: [
              _buildActionButton(
                label: "ATTACK",
                icon: Icons.colorize_rounded,
                color: const Color(0xFFEF4444),
                onPressed: gameService.handleAttack,
              ),
              const SizedBox(width: 16),
              _buildActionButton(
                label: "JUMP",
                icon: Icons.arrow_upward_rounded,
                color: const Color(0xFF10B981),
                onPressed: gameService.handleJump,
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
    required VoidCallback onTapDown,
    required VoidCallback onTapUp,
  }) {
    return GestureDetector(
      onTapDown: (_) => onTapDown(),
      onTapUp: (_) => onTapUp(),
      onTapCancel: () => onTapUp(),
      child: Container(
        width: 62,
        height: 62,
        decoration: BoxDecoration(
          color: const Color(0xAA0F172A),
          shape: BoxShape.circle,
          border: Border.all(color: const Color(0xFF334155), width: 2),
          boxShadow: const [
            BoxShadow(
              color: Color(0x44000000),
              blurRadius: 6,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Icon(
          icon,
          color: Colors.white,
          size: 28,
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
    double size = 62,
  }) {
    return GestureDetector(
      onTapDown: (_) => onPressed(),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: color.withOpacity(0.85),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white.withOpacity(0.4), width: 2),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.4),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: Colors.white,
              size: size * 0.42,
            ),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                fontSize: 9,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
