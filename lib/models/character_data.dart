import 'package:flutter/material.dart';

enum CharacterHairStyle {
  defaultMask,
  spikyShort,
  longPonytail,
  rangerCap,
  mageHood,
  frostBraid,
  knightHelmet,
  darkHorns,
  stormWings,
  celestialCrown,
}

enum CharacterWeaponStyle {
  shortSword,
  rangerDagger,
  arcaneStaff,
  iceBlade,
  darkClaymore,
  stormSpear,
  celestialScepter,
}

enum CharacterAuraStyle {
  none,
  greenLeaves,
  shadowMist,
  arcaneGlow,
  frostFlakes,
  darkFlames,
  lightningSparks,
  celestialGold,
}

class CharacterData {
  final String id;
  final String name;
  final String gender; // 'Boy' or 'Girl'
  final String outfitTitle;
  final String description;
  final int price;
  final CharacterHairStyle hairStyle;
  final CharacterWeaponStyle weaponStyle;
  final CharacterAuraStyle auraStyle;

  final Color bodyColor;
  final Color cloakColor;
  final Color maskColor;
  final Color hairColor;
  final Color eyeColor;
  final Color eyeGlowColor;
  final Color weaponColor;
  final Color accentColor;

  const CharacterData({
    required this.id,
    required this.name,
    required this.gender,
    required this.outfitTitle,
    required this.description,
    required this.price,
    required this.hairStyle,
    required this.weaponStyle,
    required this.auraStyle,
    required this.bodyColor,
    required this.cloakColor,
    required this.maskColor,
    required this.hairColor,
    required this.eyeColor,
    required this.eyeGlowColor,
    required this.weaponColor,
    required this.accentColor,
  });

  static const List<CharacterData> allCharacters = [
    // 1. Boy — Default
    CharacterData(
      id: 'char_1',
      name: 'Forest Adventurer',
      gender: 'Boy',
      outfitTitle: 'Default Explorer',
      description: 'The standard brave spirit of the ancient woods, guided by forest magic.',
      price: 0,
      hairStyle: CharacterHairStyle.defaultMask,
      weaponStyle: CharacterWeaponStyle.shortSword,
      auraStyle: CharacterAuraStyle.none,
      bodyColor: Color(0xFFE2E8F0),
      cloakColor: Color(0xFF0EA5E9),
      maskColor: Color(0xFFFFFFFF),
      hairColor: Color(0xFF334155),
      eyeColor: Color(0xFF0F172A),
      eyeGlowColor: Color(0xFF80FFDB),
      weaponColor: Color(0xFFF1F5F9),
      accentColor: Color(0xFF0284C7),
    ),
    // 2. Boy — Verdant Warrior
    CharacterData(
      id: 'char_2',
      name: 'Verdant Warrior',
      gender: 'Boy',
      outfitTitle: 'Mossy Vanguard',
      description: 'Clad in elder bark armor, infused with emerald leaf magic.',
      price: 150,
      hairStyle: CharacterHairStyle.spikyShort,
      weaponStyle: CharacterWeaponStyle.shortSword,
      auraStyle: CharacterAuraStyle.greenLeaves,
      bodyColor: Color(0xFF15803D),
      cloakColor: Color(0xFF166534),
      maskColor: Color(0xFFDCFCE7),
      hairColor: Color(0xFF854D0E),
      eyeColor: Color(0xFF052E16),
      eyeGlowColor: Color(0xFF4ADE80),
      weaponColor: Color(0xFF22C55E),
      accentColor: Color(0xFF15803D),
    ),
    // 3. Girl — Forest Ranger
    CharacterData(
      id: 'char_3',
      name: 'Forest Ranger',
      gender: 'Girl',
      outfitTitle: 'Sylvan Scout',
      description: 'Swift and silent ranger adorned with a stylish scout cap and long ponytail.',
      price: 300,
      hairStyle: CharacterHairStyle.longPonytail,
      weaponStyle: CharacterWeaponStyle.rangerDagger,
      auraStyle: CharacterAuraStyle.greenLeaves,
      bodyColor: Color(0xFF047857),
      cloakColor: Color(0xFF065F46),
      maskColor: Color(0xFFFEF3C7),
      hairColor: Color(0xFFD97706),
      eyeColor: Color(0xFF064E3B),
      eyeGlowColor: Color(0xFF34D399),
      weaponColor: Color(0xFFF59E0B),
      accentColor: Color(0xFF10B981),
    ),
    // 4. Boy — Shadow Stalker
    CharacterData(
      id: 'char_4',
      name: 'Shadow Stalker',
      gender: 'Boy',
      outfitTitle: 'Midnight Shinobi',
      description: 'A shadowy assassin veiled in obsidian smoke and purple phantom energy.',
      price: 500,
      hairStyle: CharacterHairStyle.spikyShort,
      weaponStyle: CharacterWeaponStyle.rangerDagger,
      auraStyle: CharacterAuraStyle.shadowMist,
      bodyColor: Color(0xFF1E293B),
      cloakColor: Color(0xFF020617),
      maskColor: Color(0xFF334155),
      hairColor: Color(0xFF09090B),
      eyeColor: Color(0xFF581C87),
      eyeGlowColor: Color(0xFFA855F7),
      weaponColor: Color(0xFFC084FC),
      accentColor: Color(0xFF7E22CE),
    ),
    // 5. Girl — Arcane Mage
    CharacterData(
      id: 'char_5',
      name: 'Arcane Mage',
      gender: 'Girl',
      outfitTitle: 'Mystic Sorceress',
      description: 'Master of ancient forest incantations, donning a violet hood and magic staff.',
      price: 750,
      hairStyle: CharacterHairStyle.mageHood,
      weaponStyle: CharacterWeaponStyle.arcaneStaff,
      auraStyle: CharacterAuraStyle.arcaneGlow,
      bodyColor: Color(0xFF6B21A8),
      cloakColor: Color(0xFF4C1D95),
      maskColor: Color(0xFFEDE9FE),
      hairColor: Color(0xFFE879F9),
      eyeColor: Color(0xFF3B0764),
      eyeGlowColor: Color(0xFFF0ABFC),
      weaponColor: Color(0xFFE879F9),
      accentColor: Color(0xFF9333EA),
    ),
    // 6. Boy — Sylvan Hunter
    CharacterData(
      id: 'char_6',
      name: 'Sylvan Hunter',
      gender: 'Boy',
      outfitTitle: 'Beast Tracker',
      description: 'A hardened hunter equipped with leather vestments and amber hunting blades.',
      price: 1000,
      hairStyle: CharacterHairStyle.rangerCap,
      weaponStyle: CharacterWeaponStyle.shortSword,
      auraStyle: CharacterAuraStyle.greenLeaves,
      bodyColor: Color(0xFF92400E),
      cloakColor: Color(0xFF78350F),
      maskColor: Color(0xFFFFE4E6),
      hairColor: Color(0xFF7C2D12),
      eyeColor: Color(0xFF451A03),
      eyeGlowColor: Color(0xFFFBBF24),
      weaponColor: Color(0xFFF59E0B),
      accentColor: Color(0xFFB45309),
    ),
    // 7. Girl — Frost Sentinel
    CharacterData(
      id: 'char_7',
      name: 'Frost Sentinel',
      gender: 'Girl',
      outfitTitle: 'Glacial Valkyrie',
      description: 'Wielder of permafrost ice blades, draped in frozen blue silk and snow braids.',
      price: 1250,
      hairStyle: CharacterHairStyle.frostBraid,
      weaponStyle: CharacterWeaponStyle.iceBlade,
      auraStyle: CharacterAuraStyle.frostFlakes,
      bodyColor: Color(0xFF0284C7),
      cloakColor: Color(0xFF0369A1),
      maskColor: Color(0xFFE0F2FE),
      hairColor: Color(0xFFBAE6FD),
      eyeColor: Color(0xFF0C4A6E),
      eyeGlowColor: Color(0xFF38BDF8),
      weaponColor: Color(0xFF7DD3FC),
      accentColor: Color(0xFF0284C7),
    ),
    // 8. Boy — Dark Knight
    CharacterData(
      id: 'char_8',
      name: 'Dark Knight',
      gender: 'Boy',
      outfitTitle: 'Abyssal Paladin',
      description: 'Encased in heavy dark iron armor with glowing crimson helm visor.',
      price: 1500,
      hairStyle: CharacterHairStyle.knightHelmet,
      weaponStyle: CharacterWeaponStyle.darkClaymore,
      auraStyle: CharacterAuraStyle.darkFlames,
      bodyColor: Color(0xFF18181B),
      cloakColor: Color(0xFF881337),
      maskColor: Color(0xFF27272A),
      hairColor: Color(0xFF09090B),
      eyeColor: Color(0xFF450A0A),
      eyeGlowColor: Color(0xFFEF4444),
      weaponColor: Color(0xFFF87171),
      accentColor: Color(0xFFDC2626),
    ),
    // 9. Girl — Storm Valkyrie
    CharacterData(
      id: 'char_9',
      name: 'Storm Valkyrie',
      gender: 'Girl',
      outfitTitle: 'Thunder Sovereign',
      description: 'Winged sky warrior harnessing raw electric lightning and golden spears.',
      price: 2000,
      hairStyle: CharacterHairStyle.stormWings,
      weaponStyle: CharacterWeaponStyle.stormSpear,
      auraStyle: CharacterAuraStyle.lightningSparks,
      bodyColor: Color(0xFF1E1B4B),
      cloakColor: Color(0xFF312E81),
      maskColor: Color(0xFFEEF2FF),
      hairColor: Color(0xFFFDE047),
      eyeColor: Color(0xFF1E3A8A),
      eyeGlowColor: Color(0xFF60A5FA),
      weaponColor: Color(0xFFFACC15),
      accentColor: Color(0xFF3B82F6),
    ),
    // 10. Boy — Celestial Champion
    CharacterData(
      id: 'char_10',
      name: 'Celestial Champion',
      gender: 'Boy',
      outfitTitle: 'Astral Monarch',
      description: 'The ultimate legendary hero crowned in divine starlight and golden magic.',
      price: 2500,
      hairStyle: CharacterHairStyle.celestialCrown,
      weaponStyle: CharacterWeaponStyle.celestialScepter,
      auraStyle: CharacterAuraStyle.celestialGold,
      bodyColor: Color(0xFF713F12),
      cloakColor: Color(0xFF854D0E),
      maskColor: Color(0xFFFEF9C3),
      hairColor: Color(0xFFFEF08A),
      eyeColor: Color(0xFF422006),
      eyeGlowColor: Color(0xFFFACC15),
      weaponColor: Color(0xFFFEF08A),
      accentColor: Color(0xFFEAB308),
    ),
  ];

  static CharacterData getById(String id) {
    return allCharacters.firstWhere(
      (c) => c.id == id,
      orElse: () => allCharacters.first,
    );
  }
}
