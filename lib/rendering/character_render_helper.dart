import 'dart:math';
import 'package:flutter/material.dart';
import 'package:enchanted_forest_adventure/models/character_data.dart';

class CharacterRenderHelper {
  static void drawCharacter({
    required Canvas canvas,
    required CharacterData character,
    required double w,
    required double h,
    required double topY,
    required double time,
    required double armAngle,
    required double legAngle1,
    required double legAngle2,
    bool isGrounded = true,
    bool isAttacking = false,
    double attackTimer = 0.0,
  }) {
    // 0. Aura Particle Effect
    _drawAuraParticles(canvas, character, w, h, topY, time);

    // Shadow on Ground
    if (isGrounded) {
      final Paint shadowPaint = Paint()..color = const Color(0x55000000);
      canvas.drawOval(
        Rect.fromCenter(center: Offset(0, h / 2 - 2), width: w * 0.8, height: 8),
        shadowPaint,
      );
    }

    // 1. Cloak / Back Cape
    final Paint cloakPaint = Paint()..color = character.cloakColor;
    final Path cloakPath = Path()
      ..moveTo(-12, topY + 22)
      ..quadraticBezierTo(-22 - sin(time * 8) * 4, topY + 36, -16, topY + 46)
      ..lineTo(10, topY + 46)
      ..quadraticBezierTo(2, topY + 32, -8, topY + 22)
      ..close();
    canvas.drawPath(cloakPath, cloakPaint);

    // 2. Legs / Boots
    final Paint legPaint = Paint()..color = character.bodyColor.withValues(alpha: 0.8);

    // Back Leg
    canvas.save();
    canvas.translate(-6, topY + 38);
    canvas.rotate(legAngle2);
    canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(-4, 0, 8, 14), const Radius.circular(3)), legPaint);
    canvas.restore();

    // Front Leg
    canvas.save();
    canvas.translate(6, topY + 38);
    canvas.rotate(legAngle1);
    canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(-4, 0, 8, 14), const Radius.circular(3)), legPaint);
    canvas.restore();

    // 3. Torso / Outfit
    final Paint bodyPaint = Paint()..color = character.bodyColor;
    final Rect bodyRect = Rect.fromLTWH(-w * 0.35, topY + 20, w * 0.7, 22);
    canvas.drawRRect(RRect.fromRectAndRadius(bodyRect, const Radius.circular(6)), bodyPaint);

    // Belt / Accent
    final Paint beltPaint = Paint()..color = character.accentColor;
    canvas.drawRect(Rect.fromLTWH(-w * 0.36, topY + 32, w * 0.72, 4), beltPaint);

    // 4. Head / Mask / Hair / Helmet
    final Paint maskPaint = Paint()..color = character.maskColor;
    final Rect headRect = Rect.fromLTWH(-w * 0.42, topY - 2, w * 0.84, w * 0.84);
    canvas.drawRRect(RRect.fromRectAndRadius(headRect, const Radius.circular(16)), maskPaint);

    // Hair / Headgear Details based on character.hairStyle
    _drawHeadgear(canvas, character, w, topY, time);

    // Eyes
    final Paint eyeGlow = Paint()..color = character.eyeGlowColor;
    final Paint eyePupil = Paint()..color = character.eyeColor;

    final Offset frontEyeCenter = Offset(w * 0.12, topY + 10);
    final Offset backEyeCenter = Offset(-w * 0.12, topY + 10);

    canvas.drawCircle(frontEyeCenter, 6, eyeGlow);
    canvas.drawCircle(backEyeCenter, 5, eyeGlow);

    canvas.drawCircle(Offset(frontEyeCenter.dx + 1.5, frontEyeCenter.dy), 3, eyePupil);
    canvas.drawCircle(Offset(backEyeCenter.dx + 1.5, backEyeCenter.dy), 2.5, eyePupil);

    // 5. Weapon
    canvas.save();
    canvas.translate(8, topY + 26);
    canvas.rotate(armAngle);
    _drawWeapon(canvas, character);
    canvas.restore();

    // Attack Arc Effect
    if (isAttacking) {
      final double progress = (0.28 - attackTimer) / 0.28;
      final Paint arcPaint = Paint()
        ..color = character.eyeGlowColor.withValues(alpha: 0.8 - progress * 0.5)
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeWidth = 6;

      final Path arcPath = Path()
        ..addArc(
          Rect.fromCircle(center: Offset(10, topY + 15), radius: 36),
          -1.0 + progress * 0.5,
          1.8,
        );
      canvas.drawPath(arcPath, arcPaint);
    }
  }

  static void _drawHeadgear(Canvas canvas, CharacterData character, double w, double topY, double time) {
    final Paint hairPaint = Paint()..color = character.hairColor;
    final Paint accentPaint = Paint()..color = character.accentColor;

    switch (character.hairStyle) {
      case CharacterHairStyle.defaultMask:
        final Path hornPath = Path()
          ..moveTo(w * 0.3, topY + 12)
          ..lineTo(w * 0.52, topY + 14)
          ..lineTo(w * 0.28, topY + 20)
          ..close();
        canvas.drawPath(hornPath, Paint()..color = character.maskColor);
        break;

      case CharacterHairStyle.spikyShort:
        final Path hairPath = Path()
          ..moveTo(-w * 0.44, topY + 4)
          ..lineTo(-w * 0.3, topY - 10)
          ..lineTo(-w * 0.1, topY - 2)
          ..lineTo(0, topY - 12)
          ..lineTo(w * 0.2, topY - 4)
          ..lineTo(w * 0.35, topY - 10)
          ..lineTo(w * 0.44, topY + 6)
          ..lineTo(-w * 0.44, topY + 6)
          ..close();
        canvas.drawPath(hairPath, hairPaint);
        break;

      case CharacterHairStyle.longPonytail:
        final Path bangs = Path()
          ..moveTo(-w * 0.44, topY + 6)
          ..quadraticBezierTo(-w * 0.1, topY - 10, w * 0.44, topY + 6)
          ..lineTo(w * 0.44, topY - 2)
          ..lineTo(-w * 0.44, topY - 2)
          ..close();
        canvas.drawPath(bangs, hairPaint);

        final double swing = sin(time * 6) * 6;
        final Path ponytail = Path()
          ..moveTo(-w * 0.35, topY + 2)
          ..quadraticBezierTo(-w * 0.7 + swing, topY + 14, -w * 0.6 + swing, topY + 34)
          ..quadraticBezierTo(-w * 0.4 + swing, topY + 20, -w * 0.25, topY + 8)
          ..close();
        canvas.drawPath(ponytail, hairPaint);
        canvas.drawCircle(Offset(-w * 0.32, topY + 4), 3, accentPaint);
        break;

      case CharacterHairStyle.rangerCap:
        final Path cap = Path()
          ..moveTo(-w * 0.46, topY + 2)
          ..lineTo(-w * 0.2, topY - 10)
          ..lineTo(w * 0.3, topY - 8)
          ..lineTo(w * 0.55, topY + 2)
          ..lineTo(-w * 0.46, topY + 2)
          ..close();
        canvas.drawPath(cap, accentPaint);
        final Path feather = Path()
          ..moveTo(-w * 0.2, topY - 10)
          ..quadraticBezierTo(-w * 0.4, topY - 24, -w * 0.1, topY - 22)
          ..close();
        canvas.drawPath(feather, hairPaint);
        break;

      case CharacterHairStyle.mageHood:
        final Path hood = Path()
          ..moveTo(-w * 0.48, topY + 18)
          ..quadraticBezierTo(-w * 0.5, topY - 12, 0, topY - 16)
          ..quadraticBezierTo(w * 0.5, topY - 12, w * 0.48, topY + 18)
          ..lineTo(w * 0.38, topY - 4)
          ..quadraticBezierTo(0, topY - 8, -w * 0.38, topY - 4)
          ..close();
        canvas.drawPath(hood, hairPaint);
        break;

      case CharacterHairStyle.frostBraid:
        final Path braid = Path()
          ..moveTo(-w * 0.4, topY + 6)
          ..quadraticBezierTo(-w * 0.5, topY + 22, -w * 0.3, topY + 38)
          ..quadraticBezierTo(-w * 0.2, topY + 22, -w * 0.25, topY + 6)
          ..close();
        canvas.drawPath(braid, hairPaint);
        canvas.drawCircle(Offset(-w * 0.3, topY + 36), 3, accentPaint);
        break;

      case CharacterHairStyle.knightHelmet:
        final Path visor = Path()
          ..moveTo(-w * 0.44, topY + 8)
          ..lineTo(w * 0.44, topY + 8)
          ..lineTo(w * 0.4, topY + 14)
          ..lineTo(-w * 0.4, topY + 14)
          ..close();
        canvas.drawPath(visor, Paint()..color = const Color(0xFF09090B));
        break;

      case CharacterHairStyle.darkHorns:
        final Path leftHorn = Path()
          ..moveTo(-w * 0.2, topY - 2)
          ..quadraticBezierTo(-w * 0.6, topY - 18, -w * 0.45, topY - 26)
          ..quadraticBezierTo(-w * 0.25, topY - 12, -w * 0.1, topY - 2)
          ..close();
        canvas.drawPath(leftHorn, hairPaint);
        break;

      case CharacterHairStyle.stormWings:
        final Path wing = Path()
          ..moveTo(w * 0.2, topY - 2)
          ..lineTo(w * 0.6, topY - 20)
          ..lineTo(w * 0.45, topY - 10)
          ..lineTo(w * 0.55, topY - 2)
          ..close();
        canvas.drawPath(wing, accentPaint);
        break;

      case CharacterHairStyle.celestialCrown:
        final Path crown = Path()
          ..moveTo(-w * 0.35, topY - 2)
          ..lineTo(-w * 0.35, topY - 12)
          ..lineTo(-w * 0.18, topY - 6)
          ..lineTo(0, topY - 16)
          ..lineTo(w * 0.18, topY - 6)
          ..lineTo(w * 0.35, topY - 12)
          ..lineTo(w * 0.35, topY - 2)
          ..close();
        canvas.drawPath(crown, accentPaint);
        canvas.drawCircle(Offset(0, topY - 16), 3, Paint()..color = character.eyeGlowColor);
        break;

      case CharacterHairStyle.cyberGoggles:
        // Futuristic Cyber Goggles & Neon Visor
        final Rect goggleRect = Rect.fromLTWH(-w * 0.4, topY + 6, w * 0.8, 8);
        canvas.drawRRect(RRect.fromRectAndRadius(goggleRect, const Radius.circular(4)), Paint()..color = character.eyeGlowColor);
        canvas.drawRect(Rect.fromLTWH(-w * 0.42, topY + 8, w * 0.84, 2), accentPaint);
        break;

      case CharacterHairStyle.steampunkHat:
        // Brass Steampunk Top Hat & Goggles
        final Path topHat = Path()
          ..moveTo(-w * 0.5, topY + 2)
          ..lineTo(w * 0.5, topY + 2)
          ..lineTo(w * 0.35, topY - 18)
          ..lineTo(-w * 0.35, topY - 18)
          ..close();
        canvas.drawPath(topHat, hairPaint);
        canvas.drawCircle(Offset(-w * 0.15, topY - 4), 4, accentPaint);
        canvas.drawCircle(Offset(w * 0.15, topY - 4), 4, accentPaint);
        break;

      case CharacterHairStyle.ninjaBandana:
        // Ninja Headband with Trailing Cloth Ribbons
        final Path headband = Path()
          ..moveTo(-w * 0.45, topY + 4)
          ..lineTo(w * 0.45, topY + 4)
          ..lineTo(w * 0.45, topY + 10)
          ..lineTo(-w * 0.45, topY + 10)
          ..close();
        canvas.drawPath(headband, accentPaint);
        final double swing = sin(time * 8) * 5;
        final Path ribbon = Path()
          ..moveTo(-w * 0.4, topY + 8)
          ..quadraticBezierTo(-w * 0.75 + swing, topY + 18, -w * 0.65 + swing, topY + 28)
          ..lineTo(-w * 0.5 + swing, topY + 26)
          ..close();
        canvas.drawPath(ribbon, accentPaint);
        break;

      case CharacterHairStyle.pirateTricorn:
        // Pirate Tricorn Hat
        final Path tricorn = Path()
          ..moveTo(0, topY - 18)
          ..lineTo(w * 0.55, topY + 2)
          ..lineTo(-w * 0.55, topY + 2)
          ..close();
        canvas.drawPath(tricorn, hairPaint);
        canvas.drawCircle(Offset(0, topY - 8), 3, accentPaint);
        break;

      case CharacterHairStyle.samuraiTopknot:
        // Samurai Topknot Hair Crest
        canvas.drawCircle(Offset(0, topY - 8), 7, hairPaint);
        canvas.drawRect(Rect.fromLTWH(-3, topY - 4, 6, 6), accentPaint);
        break;

      case CharacterHairStyle.wildAfro:
        // Wild Curly Hair Canopy
        canvas.drawCircle(Offset(0, topY - 2), w * 0.48, hairPaint);
        canvas.drawCircle(Offset(-w * 0.3, topY + 2), w * 0.25, hairPaint);
        canvas.drawCircle(Offset(w * 0.3, topY + 2), w * 0.25, hairPaint);
        break;

      case CharacterHairStyle.scoutBeret:
        // Military Beret Cap
        final Path beret = Path()
          ..moveTo(-w * 0.42, topY + 4)
          ..quadraticBezierTo(0, topY - 14, w * 0.52, topY)
          ..lineTo(-w * 0.42, topY + 4)
          ..close();
        canvas.drawPath(beret, accentPaint);
        break;

      case CharacterHairStyle.vampireCollar:
        // High Vampire Collar & Sleek Hair
        final Path collar = Path()
          ..moveTo(-w * 0.45, topY + 18)
          ..lineTo(-w * 0.6, topY - 6)
          ..lineTo(-w * 0.3, topY + 12)
          ..close();
        canvas.drawPath(collar, accentPaint);
        break;

      case CharacterHairStyle.solarHalo:
        // Floating Solar Ring Halo
        final Paint haloPaint = Paint()
          ..color = character.eyeGlowColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3;
        canvas.drawOval(Rect.fromCenter(center: Offset(0, topY - 14), width: w * 0.7, height: 10), haloPaint);
        break;

      case CharacterHairStyle.dragonHorns:
        // Curved Draconic Horns
        final Path leftHorn = Path()
          ..moveTo(-w * 0.2, topY - 2)
          ..quadraticBezierTo(-w * 0.6, topY - 22, -w * 0.4, topY - 28)
          ..quadraticBezierTo(-w * 0.25, topY - 14, -w * 0.1, topY - 2)
          ..close();
        final Path rightHorn = Path()
          ..moveTo(w * 0.2, topY - 2)
          ..quadraticBezierTo(w * 0.6, topY - 22, w * 0.4, topY - 28)
          ..quadraticBezierTo(w * 0.25, topY - 14, w * 0.1, topY - 2)
          ..close();
        canvas.drawPath(leftHorn, hairPaint);
        canvas.drawPath(rightHorn, hairPaint);
        break;
    }
  }

  static void _drawWeapon(Canvas canvas, CharacterData character) {
    final Paint weaponPaint = Paint()..color = character.weaponColor;
    final Paint hiltPaint = Paint()..color = character.accentColor;

    switch (character.weaponStyle) {
      case CharacterWeaponStyle.shortSword:
        final Path sword = Path()
          ..moveTo(0, -2)
          ..lineTo(22, -4)
          ..lineTo(26, 0)
          ..lineTo(22, 4)
          ..lineTo(0, 2)
          ..close();
        canvas.drawPath(sword, weaponPaint);
        canvas.drawRect(const Rect.fromLTWH(-3, -6, 4, 12), hiltPaint);
        break;

      case CharacterWeaponStyle.rangerDagger:
        final Path dagger = Path()
          ..moveTo(0, -2)
          ..lineTo(18, -3)
          ..lineTo(22, 0)
          ..lineTo(18, 3)
          ..lineTo(0, 2)
          ..close();
        canvas.drawPath(dagger, weaponPaint);
        canvas.drawCircle(const Offset(-2, 0), 3, hiltPaint);
        break;

      case CharacterWeaponStyle.arcaneStaff:
        canvas.drawRect(const Rect.fromLTWH(0, -2, 28, 4), hiltPaint);
        canvas.drawCircle(const Offset(28, 0), 7, weaponPaint);
        canvas.drawCircle(const Offset(28, 0), 4, Paint()..color = character.eyeGlowColor);
        break;

      case CharacterWeaponStyle.iceBlade:
        final Path ice = Path()
          ..moveTo(0, -3)
          ..lineTo(16, -6)
          ..lineTo(28, 0)
          ..lineTo(16, 6)
          ..lineTo(0, 3)
          ..close();
        canvas.drawPath(ice, weaponPaint);
        break;

      case CharacterWeaponStyle.darkClaymore:
        final Path claymore = Path()
          ..moveTo(0, -4)
          ..lineTo(28, -5)
          ..lineTo(32, 0)
          ..lineTo(28, 5)
          ..lineTo(0, 4)
          ..close();
        canvas.drawPath(claymore, weaponPaint);
        canvas.drawRect(const Rect.fromLTWH(-4, -8, 5, 16), hiltPaint);
        break;

      case CharacterWeaponStyle.stormSpear:
        canvas.drawRect(const Rect.fromLTWH(0, -2, 30, 4), hiltPaint);
        final Path spearHead = Path()
          ..moveTo(30, -6)
          ..lineTo(40, 0)
          ..lineTo(30, 6)
          ..close();
        canvas.drawPath(spearHead, weaponPaint);
        break;

      case CharacterWeaponStyle.celestialScepter:
        canvas.drawRect(const Rect.fromLTWH(0, -2, 26, 4), hiltPaint);
        canvas.drawCircle(const Offset(26, 0), 8, weaponPaint);
        canvas.drawCircle(const Offset(26, 0), 5, Paint()..color = Colors.white);
        break;

      case CharacterWeaponStyle.dualKatana:
        final Path katana1 = Path()
          ..moveTo(0, -4)
          ..lineTo(24, -6)
          ..lineTo(26, -2)
          ..close();
        final Path katana2 = Path()
          ..moveTo(0, 2)
          ..lineTo(24, 0)
          ..lineTo(26, 4)
          ..close();
        canvas.drawPath(katana1, weaponPaint);
        canvas.drawPath(katana2, weaponPaint);
        break;

      case CharacterWeaponStyle.shadowScythe:
        canvas.drawRect(const Rect.fromLTWH(0, -2, 28, 4), hiltPaint);
        final Path blade = Path()
          ..moveTo(28, -14)
          ..quadraticBezierTo(40, -4, 28, 14)
          ..quadraticBezierTo(32, 0, 28, -14)
          ..close();
        canvas.drawPath(blade, weaponPaint);
        break;

      case CharacterWeaponStyle.fireAxe:
        canvas.drawRect(const Rect.fromLTWH(0, -2, 24, 4), hiltPaint);
        final Path head = Path()
          ..moveTo(20, -12)
          ..lineTo(28, -14)
          ..lineTo(26, 14)
          ..lineTo(20, 12)
          ..close();
        canvas.drawPath(head, weaponPaint);
        break;

      case CharacterWeaponStyle.plasmaBlaster:
        canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(0, -4, 22, 8), const Radius.circular(3)), weaponPaint);
        canvas.drawCircle(const Offset(22, 0), 4, Paint()..color = character.eyeGlowColor);
        break;

      case CharacterWeaponStyle.goldenBow:
        final Path bow = Path()
          ..moveTo(6, -16)
          ..quadraticBezierTo(20, 0, 6, 16)
          ..quadraticBezierTo(14, 0, 6, -16)
          ..close();
        canvas.drawPath(bow, weaponPaint);
        canvas.drawLine(const Offset(6, -16), const Offset(6, 16), Paint()..color = Colors.white70..strokeWidth = 1.0);
        break;

      case CharacterWeaponStyle.elementalOrb:
        canvas.drawCircle(const Offset(18, 0), 9, weaponPaint);
        canvas.drawCircle(const Offset(18, 0), 5, Paint()..color = character.eyeGlowColor);
        break;

      case CharacterWeaponStyle.runicMace:
        canvas.drawRect(const Rect.fromLTWH(0, -2, 22, 4), hiltPaint);
        canvas.drawRect(const Rect.fromLTWH(20, -8, 10, 16), weaponPaint);
        break;
    }
  }

  static void _drawAuraParticles(
    Canvas canvas,
    CharacterData character,
    double w,
    double h,
    double topY,
    double time,
  ) {
    if (character.auraStyle == CharacterAuraStyle.none) return;

    final Paint auraPaint = Paint()..color = character.eyeGlowColor.withValues(alpha: 0.6);

    for (int i = 0; i < 6; i++) {
      final double angle = time * 2.5 + i * (pi / 3);
      final double radius = 26.0 + sin(time * 3 + i) * 6;
      final double px = cos(angle) * radius;
      final double py = topY + 15 + sin(angle) * (radius * 0.6);

      canvas.drawCircle(Offset(px, py), 2.5, auraPaint);
    }
  }
}
