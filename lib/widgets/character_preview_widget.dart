import 'dart:math';
import 'package:flutter/material.dart';
import 'package:enchanted_forest_adventure/models/character_data.dart';
import 'package:enchanted_forest_adventure/rendering/character_render_helper.dart';

class CharacterPreviewWidget extends StatelessWidget {
  final CharacterData character;
  final double width;
  final double height;
  final double time;

  const CharacterPreviewWidget({
    super.key,
    required this.character,
    this.width = 120,
    this.height = 120,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: CustomPaint(
        painter: _PreviewPainter(
          character: character,
          time: time,
        ),
      ),
    );
  }
}

class _PreviewPainter extends CustomPainter {
  final CharacterData character;
  final double time;

  _PreviewPainter({
    required this.character,
    required this.time,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final double cx = size.width / 2;
    final double cy = size.height / 2 + 10;

    canvas.save();
    canvas.translate(cx, cy);

    // Scale character to fit canvas nicely
    final double scaleFactor = (size.height / 110.0).clamp(0.6, 2.2);
    canvas.scale(scaleFactor, scaleFactor);

    final double bodyYOffset = sin(time * 3.5) * 2.5;
    final double topY = -28.0 + bodyYOffset;

    CharacterRenderHelper.drawCharacter(
      canvas: canvas,
      character: character,
      w: 42,
      h: 56,
      topY: topY,
      time: time,
      armAngle: sin(time * 3) * 0.1,
      legAngle1: 0,
      legAngle2: 0,
      isGrounded: true,
      isAttacking: false,
    );

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _PreviewPainter oldDelegate) =>
      oldDelegate.time != time || oldDelegate.character.id != character.id;
}
