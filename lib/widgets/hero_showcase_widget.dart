import 'package:flutter/material.dart';
import 'package:enchanted_forest_adventure/models/player_state.dart';
import 'package:enchanted_forest_adventure/rendering/character_painter.dart';

class HeroShowcaseWidget extends StatelessWidget {
  final double time;

  const HeroShowcaseWidget({
    super.key,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    final player = PlayerState(x: 0, y: 0)
      ..actionState = PlayerActionState.idle
      ..facingRight = true;

    return Center(
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Magical Aura Glow Behind Hero
          Container(
            width: 140,
            height: 140,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF80FFDB).withValues(alpha: 0.18),
              boxShadow: const [
                BoxShadow(
                  color: Color(0xFF80FFDB),
                  blurRadius: 40,
                  spreadRadius: 10,
                ),
              ],
            ),
          ),

          // Render Character using CustomPainter
          SizedBox(
            width: 120,
            height: 120,
            child: CustomPaint(
              painter: CharacterPainter(
                player: player,
                cameraX: -38,
                cameraY: -32,
                time: time,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
