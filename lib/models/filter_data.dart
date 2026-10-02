import 'package:flutter/material.dart';
import 'filter_model.dart';

class FilterData {
  static const List<double> matrixIdentity = [
    1, 0, 0, 0, 0,
    0, 1, 0, 0, 0,
    0, 0, 1, 0, 0,
    0, 0, 0, 1, 0,
  ];

  static const List<double> matrixCyberpunk = [
    1.2, 0.0, 0.2, 0, 10,
    0.0, 0.8, 0.4, 0, 0,
    0.3, 0.1, 1.5, 0, 20,
    0.0, 0.0, 0.0, 1, 0,
  ];

  static const List<double> matrixNeonCyan = [
    0.4, 0.2, 0.8, 0, 0,
    0.0, 1.3, 0.5, 0, 15,
    0.2, 0.8, 1.6, 0, 30,
    0.0, 0.0, 0.0, 1, 0,
  ];

  static const List<double> matrixVintageSepia = [
    0.393, 0.769, 0.189, 0, 0,
    0.349, 0.686, 0.168, 0, 0,
    0.272, 0.534, 0.131, 0, 0,
    0,     0,     0,     1, 0,
  ];

  static const List<double> matrixMonochromeBW = [
    0.33, 0.59, 0.11, 0, 0,
    0.33, 0.59, 0.11, 0, 0,
    0.33, 0.59, 0.11, 0, 0,
    0,    0,    0,    1, 0,
  ];

  static const List<double> matrixHighContrastBW = [
    0.5, 0.5, 0.5, 0, -30,
    0.5, 0.5, 0.5, 0, -30,
    0.5, 0.5, 0.5, 0, -30,
    0,   0,   0,   1, 0,
  ];

  static const List<double> matrixTealAndOrange = [
    1.3, 0.0, 0.0, 0, 15,
    0.1, 0.9, 0.2, 0, 0,
    0.0, 0.3, 1.4, 0, 20,
    0,   0,   0,   1, 0,
  ];

  static const List<double> matrixGoldenHour = [
    1.3, 0.2, 0.0, 0, 20,
    0.1, 1.1, 0.0, 0, 10,
    0.0, 0.0, 0.7, 0, -10,
    0,   0,   0,   1, 0,
  ];

  static const List<double> matrixElectricPurple = [
    0.9, 0.1, 0.6, 0, 15,
    0.1, 0.5, 0.4, 0, 0,
    0.4, 0.2, 1.5, 0, 30,
    0,   0,   0,   1, 0,
  ];

  static const List<double> matrixGlitchGreen = [
    0.5, 0.0, 0.2, 0, -20,
    0.2, 1.5, 0.3, 0, 30,
    0.1, 0.2, 0.6, 0, -10,
    0,   0,   0,   1, 0,
  ];

  static const List<double> matrixMidnightBlue = [
    0.4, 0.1, 0.3, 0, -20,
    0.1, 0.5, 0.4, 0, -10,
    0.2, 0.5, 1.4, 0, 25,
    0,   0,   0,   1, 0,
  ];

  static const List<double> matrixWarmSunburst = [
    1.4, 0.1, 0.0, 0, 25,
    0.2, 1.2, 0.1, 0, 15,
    0.0, 0.1, 0.8, 0, -15,
    0,   0,   0,   1, 0,
  ];

  static const List<double> matrixEmeraldGlow = [
    0.4, 0.2, 0.1, 0, -10,
    0.1, 1.4, 0.3, 0, 25,
    0.1, 0.4, 0.8, 0, 0,
    0,   0,   0,   1, 0,
  ];

  static const List<double> matrixCrimsonDark = [
    1.5, 0.1, 0.1, 0, 30,
    0.1, 0.4, 0.1, 0, -20,
    0.1, 0.1, 0.4, 0, -20,
    0,   0,   0,   1, 0,
  ];

  static const List<double> matrixVaporwave = [
    1.1, 0.2, 0.7, 0, 15,
    0.1, 0.8, 0.6, 0, 5,
    0.3, 0.4, 1.4, 0, 25,
    0,   0,   0,   1, 0,
  ];

  static const List<double> matrixFadedFilm = [
    0.9, 0.1, 0.1, 0, 20,
    0.1, 0.9, 0.1, 0, 20,
    0.1, 0.1, 0.8, 0, 30,
    0,   0,   0,   1, 0,
  ];

  static const List<double> matrixPolaroid1980 = [
    1.1, 0.1, 0.1, 0, 10,
    0.1, 1.0, 0.1, 0, 5,
    0.1, 0.2, 0.8, 0, 15,
    0,   0,   0,   1, 0,
  ];

  static const List<double> matrixNoirNoir = [
    0.25, 0.50, 0.10, 0, -40,
    0.25, 0.50, 0.10, 0, -40,
    0.25, 0.50, 0.10, 0, -40,
    0,    0,    0,    1, 0,
  ];

  static const List<double> matrixPastelDream = [
    1.0, 0.2, 0.2, 0, 30,
    0.2, 1.0, 0.2, 0, 30,
    0.2, 0.2, 1.1, 0, 40,
    0,   0,   0,   1, 0,
  ];

  static const List<double> matrixUltraViolet = [
    0.8, 0.1, 0.9, 0, 20,
    0.1, 0.4, 0.5, 0, -10,
    0.5, 0.2, 1.6, 0, 35,
    0,   0,   0,   1, 0,
  ];

  static const List<double> matrixCyberGlow = [
    0.6, 0.2, 0.8, 0, 10,
    0.0, 1.4, 0.6, 0, 20,
    0.3, 0.6, 1.5, 0, 30,
    0,   0,   0,   1, 0,
  ];

  static const List<double> matrixSunsetBliss = [
    1.4, 0.2, 0.1, 0, 25,
    0.2, 0.8, 0.2, 0, 0,
    0.1, 0.2, 0.9, 0, 10,
    0,   0,   0,   1, 0,
  ];

  static const List<double> matrixDeepOcean = [
    0.2, 0.2, 0.5, 0, -20,
    0.1, 0.8, 0.7, 0, 10,
    0.2, 0.6, 1.5, 0, 30,
    0,   0,   0,   1, 0,
  ];

  static const List<double> matrixInvertNegative = [
    -1,  0,  0, 0, 255,
     0, -1,  0, 0, 255,
     0,  0, -1, 0, 255,
     0,  0,  0, 1, 0,
  ];

  static const List<FilterModel> filters = [
    FilterModel(
      id: 'filter_01',
      name: 'Normal',
      category: 'Standard',
      previewColor: Colors.white,
      colorMatrix: matrixIdentity,
      description: 'Original clean lens view without visual enhancements.',
      iconData: Icons.camera_alt_outlined,
    ),
    FilterModel(
      id: 'filter_02',
      name: 'Cyberpunk',
      category: 'Cyber & Neon',
      previewColor: Color(0xFF00F0FF),
      colorMatrix: matrixCyberpunk,
      description: 'Neon cyan and magenta high-contrast sci-fi aesthetic.',
      iconData: Icons.bolt,
      arEffect: 'cyber_grid',
    ),
    FilterModel(
      id: 'filter_03',
      name: 'Neon Cyan',
      category: 'Cyber & Neon',
      previewColor: Color(0xFF00F0FF),
      colorMatrix: matrixNeonCyan,
      description: 'Electric turquoise highlight tone for futuristic scenes.',
      iconData: Icons.blur_circular,
      arEffect: 'neon_aura',
    ),
    FilterModel(
      id: 'filter_04',
      name: 'Vintage Sepia',
      category: 'Vintage',
      previewColor: Color(0xFFD97706),
      colorMatrix: matrixVintageSepia,
      description: 'Warm antique bronze and classic sepia photo finish.',
      iconData: Icons.history_edu,
    ),
    FilterModel(
      id: 'filter_05',
      name: 'Monochrome',
      category: 'B&W',
      previewColor: Colors.grey,
      colorMatrix: matrixMonochromeBW,
      description: 'Balanced silver greyscale with rich midtones.',
      iconData: Icons.filter_b_and_w,
    ),
    FilterModel(
      id: 'filter_06',
      name: 'Teal & Orange',
      category: 'Cinematic',
      previewColor: Color(0xFF0284C7),
      colorMatrix: matrixTealAndOrange,
      description: 'Blockbuster Hollywood color grade with teal shadows and warm skin tones.',
      iconData: Icons.movie_creation,
    ),
    FilterModel(
      id: 'filter_07',
      name: 'Golden Hour',
      category: 'Color Grade',
      previewColor: Color(0xFFF59E0B),
      colorMatrix: matrixGoldenHour,
      description: 'Soft warm golden sunset glow.',
      iconData: Icons.wb_sunny,
    ),
    FilterModel(
      id: 'filter_08',
      name: 'Electric Purple',
      category: 'Cyber & Neon',
      previewColor: Color(0xFFA855F7),
      colorMatrix: matrixElectricPurple,
      description: 'Vibrant violet and synthwave night tone.',
      iconData: Icons.flare,
    ),
    FilterModel(
      id: 'filter_09',
      name: 'Glitch Green',
      category: 'Glitch & FX',
      previewColor: Color(0xFF22C55E),
      colorMatrix: matrixGlitchGreen,
      description: 'Matrix green terminal glow with high contrast.',
      iconData: Icons.bug_report,
      arEffect: 'glitch_lines',
    ),
    FilterModel(
      id: 'filter_10',
      name: 'Midnight Blue',
      category: 'Color Grade',
      previewColor: Color(0xFF1E3A8A),
      colorMatrix: matrixMidnightBlue,
      description: 'Deep royal blue shadow grade for night atmospheres.',
      iconData: Icons.nightlight_round,
    ),
    FilterModel(
      id: 'filter_11',
      name: 'Warm Sunburst',
      category: 'Color Grade',
      previewColor: Color(0xFFEA580C),
      colorMatrix: matrixWarmSunburst,
      description: 'Intense tropical warmth and rich orange saturation.',
      iconData: Icons.light_mode,
    ),
    FilterModel(
      id: 'filter_12',
      name: 'Emerald Glow',
      category: 'Color Grade',
      previewColor: Color(0xFF10B981),
      colorMatrix: matrixEmeraldGlow,
      description: 'Rich forest green and jade highlights.',
      iconData: Icons.park,
    ),
    FilterModel(
      id: 'filter_13',
      name: 'Crimson Dark',
      category: 'Color Grade',
      previewColor: Color(0xFFDC2626),
      colorMatrix: matrixCrimsonDark,
      description: 'Dramatic deep red and high contrast dark mood.',
      iconData: Icons.whatshot,
    ),
    FilterModel(
      id: 'filter_14',
      name: 'Vaporwave',
      category: 'Cyber & Neon',
      previewColor: Color(0xFFEC4899),
      colorMatrix: matrixVaporwave,
      description: '80s retro pastel pink and violet nostalgia.',
      iconData: Icons.graphic_eq,
    ),
    FilterModel(
      id: 'filter_15',
      name: 'Faded Film',
      category: 'Vintage',
      previewColor: Color(0xFF9CA3AF),
      colorMatrix: matrixFadedFilm,
      description: 'Matte analog film look with lifted black levels.',
      iconData: Icons.local_movies,
    ),
    FilterModel(
      id: 'filter_16',
      name: 'Polaroid 1980',
      category: 'Vintage',
      previewColor: Color(0xFFFBBF24),
      colorMatrix: matrixPolaroid1980,
      description: 'Classic instant camera warm tint and vintage character.',
      iconData: Icons.photo_camera,
    ),
    FilterModel(
      id: 'filter_17',
      name: 'High Contrast B&W',
      category: 'B&W',
      previewColor: Colors.black,
      colorMatrix: matrixHighContrastBW,
      description: 'Deep black shadows and bright highlights.',
      iconData: Icons.contrast,
    ),
    FilterModel(
      id: 'filter_18',
      name: 'Noir Film',
      category: 'B&W',
      previewColor: Color(0xFF374151),
      colorMatrix: matrixNoirNoir,
      description: 'Moody cinematic film noir monochrome.',
      iconData: Icons.local_activity,
    ),
    FilterModel(
      id: 'filter_19',
      name: 'Pastel Dream',
      category: 'Color Grade',
      previewColor: Color(0xFFF472B6),
      colorMatrix: matrixPastelDream,
      description: 'Soft dreamy highlights with airy pastel tones.',
      iconData: Icons.cloudy_snowing,
    ),
    FilterModel(
      id: 'filter_20',
      name: 'Ultra Violet',
      category: 'Cyber & Neon',
      previewColor: Color(0xFF7C3AED),
      colorMatrix: matrixUltraViolet,
      description: 'Deep purple UV neon illumination.',
      iconData: Icons.wb_twilight,
    ),
    FilterModel(
      id: 'filter_21',
      name: 'Cyber Visor',
      category: 'AR & Glow FX',
      previewColor: Color(0xFF00F0FF),
      colorMatrix: matrixCyberGlow,
      description: 'Futuristic HUD overlay and neon eye visor AR effect.',
      iconData: Icons.visibility,
      arEffect: 'hud_visor',
    ),
    FilterModel(
      id: 'filter_22',
      name: 'Sunset Bliss',
      category: 'Color Grade',
      previewColor: Color(0xFFF97316),
      colorMatrix: matrixSunsetBliss,
      description: 'Radiant golden hour sunset with rich magenta sky tones.',
      iconData: Icons.wb_twilight,
    ),
    FilterModel(
      id: 'filter_23',
      name: 'Deep Ocean',
      category: 'Color Grade',
      previewColor: Color(0xFF0284C7),
      colorMatrix: matrixDeepOcean,
      description: 'Submerged deep aquatic blue mood.',
      iconData: Icons.water,
    ),
    FilterModel(
      id: 'filter_24',
      name: 'Negative Invert',
      category: 'Glitch & FX',
      previewColor: Colors.purple,
      colorMatrix: matrixInvertNegative,
      description: 'Color inverted photo negative effect.',
      iconData: Icons.invert_colors,
    ),
    FilterModel(
      id: 'filter_25',
      name: 'Matrix Rain',
      category: 'AR & Glow FX',
      previewColor: Color(0xFF10B981),
      colorMatrix: matrixGlitchGreen,
      description: 'Digital rain particle overlay and cyber green grade.',
      iconData: Icons.code,
      arEffect: 'matrix_rain',
    ),
    FilterModel(
      id: 'filter_26',
      name: 'Neon Halo',
      category: 'AR & Glow FX',
      previewColor: Color(0xFF00F0FF),
      colorMatrix: matrixNeonCyan,
      description: 'Angelic cyan neon ring AR face glow.',
      iconData: Icons.donut_large,
      arEffect: 'neon_halo',
    ),
    FilterModel(
      id: 'filter_27',
      name: 'Cyberpunk Red',
      category: 'Cyber & Neon',
      previewColor: Color(0xFFEF4444),
      colorMatrix: matrixCrimsonDark,
      description: 'Neon crimson night grade with high saturation.',
      iconData: Icons.local_fire_department,
    ),
    FilterModel(
      id: 'filter_28',
      name: 'Retro VHS',
      category: 'Vintage',
      previewColor: Color(0xFF8B5CF6),
      colorMatrix: matrixVaporwave,
      description: 'Analog video cassette tape artifact look.',
      iconData: Icons.videocam,
      arEffect: 'vhs_lines',
    ),
    FilterModel(
      id: 'filter_29',
      name: 'Warm Sunset',
      category: 'Color Grade',
      previewColor: Color(0xFFFB923C),
      colorMatrix: matrixGoldenHour,
      description: 'Rich amber dusk warmth.',
      iconData: Icons.wb_sunny_outlined,
    ),
    FilterModel(
      id: 'filter_30',
      name: 'Cool Breeze',
      category: 'Color Grade',
      previewColor: Color(0xFF38BDF8),
      colorMatrix: matrixDeepOcean,
      description: 'Refreshingly crisp cyan and cool blue tints.',
      iconData: Icons.ac_unit,
    ),
    FilterModel(
      id: 'filter_31',
      name: 'Neon Cyberpunk 2.0',
      category: 'Cyber & Neon',
      previewColor: Color(0xFF00F0FF),
      colorMatrix: matrixCyberpunk,
      description: 'Next-gen cyberpunk high-tech blue and pink blend.',
      iconData: Icons.auto_awesome,
    ),
    FilterModel(
      id: 'filter_32',
      name: 'B&W Vintage',
      category: 'B&W',
      previewColor: Colors.grey,
      colorMatrix: matrixMonochromeBW,
      description: '1920s silent film monochromatic style.',
      iconData: Icons.filter_b_and_w_outlined,
    ),
    FilterModel(
      id: 'filter_33',
      name: 'Glow Crown',
      category: 'AR & Glow FX',
      previewColor: Color(0xFFFBBF24),
      colorMatrix: matrixWarmSunburst,
      description: 'Luminous golden crown particle AR effect.',
      iconData: Icons.emoji_events,
      arEffect: 'glow_crown',
    ),
    FilterModel(
      id: 'filter_34',
      name: 'Infrared Red',
      category: 'Glitch & FX',
      previewColor: Color(0xFFDC2626),
      colorMatrix: matrixCrimsonDark,
      description: 'Simulated thermal infrared vision effect.',
      iconData: Icons.sensors,
    ),
    FilterModel(
      id: 'filter_35',
      name: 'Toxic Lime',
      category: 'Cyber & Neon',
      previewColor: Color(0xFF84CC16),
      colorMatrix: matrixGlitchGreen,
      description: 'Radioactive neon lime green highlight tone.',
      iconData: Icons.science,
    ),
    FilterModel(
      id: 'filter_36',
      name: 'Cinematic Blue',
      category: 'Cinematic',
      previewColor: Color(0xFF0284C7),
      colorMatrix: matrixTealAndOrange,
      description: 'Moody thrillers blue shadow grade.',
      iconData: Icons.movie_filter,
    ),
    FilterModel(
      id: 'filter_37',
      name: 'Rosy Pink',
      category: 'Color Grade',
      previewColor: Color(0xFFF472B6),
      colorMatrix: matrixPastelDream,
      description: 'Soft blushing pink highlights and rosy skin smoothing.',
      iconData: Icons.favorite_border,
    ),
    FilterModel(
      id: 'filter_38',
      name: 'Sepia Retro',
      category: 'Vintage',
      previewColor: Color(0xFFB45309),
      colorMatrix: matrixVintageSepia,
      description: 'Warm aged parchment paper tone.',
      iconData: Icons.history,
    ),
    FilterModel(
      id: 'filter_39',
      name: 'Glitch RGB',
      category: 'Glitch & FX',
      previewColor: Color(0xFF00F0FF),
      colorMatrix: matrixCyberpunk,
      description: 'Chromatic aberration and RGB splitting visual noise.',
      iconData: Icons.perm_scan_wifi,
      arEffect: 'glitch_rgb',
    ),
    FilterModel(
      id: 'filter_40',
      name: 'Cyber Mask',
      category: 'AR & Glow FX',
      previewColor: Color(0xFF00F0FF),
      colorMatrix: matrixNeonCyan,
      description: 'Hologram face mask AR filter.',
      iconData: Icons.face_retouching_natural,
      arEffect: 'cyber_mask',
    ),
    FilterModel(
      id: 'filter_41',
      name: 'Golden Glow',
      category: 'Color Grade',
      previewColor: Color(0xFFF59E0B),
      colorMatrix: matrixGoldenHour,
      description: 'Luminous sunbeam highlights.',
      iconData: Icons.wb_twilight,
    ),
    FilterModel(
      id: 'filter_42',
      name: 'Frost Byte',
      category: 'Color Grade',
      previewColor: Color(0xFF38BDF8),
      colorMatrix: matrixDeepOcean,
      description: 'Sub-zero frozen cyan tone.',
      iconData: Icons.ac_unit_outlined,
    ),
    FilterModel(
      id: 'filter_43',
      name: 'Aura Glow',
      category: 'AR & Glow FX',
      previewColor: Color(0xFFA855F7),
      colorMatrix: matrixElectricPurple,
      description: 'Vibrant surrounding body aura particle outline.',
      iconData: Icons.auto_graph,
      arEffect: 'aura_glow',
    ),
    FilterModel(
      id: 'filter_44',
      name: '80s Synthwave',
      category: 'Cyber & Neon',
      previewColor: Color(0xFFEC4899),
      colorMatrix: matrixVaporwave,
      description: 'Sunset grid and neon pink nostalgia.',
      iconData: Icons.music_note,
    ),
    FilterModel(
      id: 'filter_45',
      name: 'Silver Noir',
      category: 'B&W',
      previewColor: Colors.white70,
      colorMatrix: matrixMonochromeBW,
      description: 'Ultra clean metallic silver monochrome finish.',
      iconData: Icons.camera_roll,
    ),
    FilterModel(
      id: 'filter_46',
      name: 'Lava Glow',
      category: 'Color Grade',
      previewColor: Color(0xFFEA580C),
      colorMatrix: matrixWarmSunburst,
      description: 'Hot molten red and orange high key vibrancy.',
      iconData: Icons.local_fire_department_sharp,
    ),
    FilterModel(
      id: 'filter_47',
      name: 'Cyber Grid',
      category: 'AR & Glow FX',
      previewColor: Color(0xFF00F0FF),
      colorMatrix: matrixNeonCyan,
      description: '3D perspective neon floor grid overlay.',
      iconData: Icons.grid_on,
      arEffect: 'cyber_grid',
    ),
    FilterModel(
      id: 'filter_48',
      name: 'Vintage 1970',
      category: 'Vintage',
      previewColor: Color(0xFFD97706),
      colorMatrix: matrixPolaroid1980,
      description: 'Retro warm Kodachrome 1970s film simulation.',
      iconData: Icons.mms,
    ),
    FilterModel(
      id: 'filter_49',
      name: 'Neon Magenta',
      category: 'Cyber & Neon',
      previewColor: Color(0xFFD946EF),
      colorMatrix: matrixVaporwave,
      description: 'Deep fuchsia and neon magenta punch.',
      iconData: Icons.brush,
    ),
    FilterModel(
      id: 'filter_50',
      name: 'Zippro Ultra',
      category: 'Cyber & Neon',
      previewColor: Color(0xFF00F0FF),
      colorMatrix: matrixCyberpunk,
      description: 'Signature Zippro cyan-royal flagship filter.',
      iconData: Icons.star,
      arEffect: 'zippro_ultra',
    ),
  ];
}
