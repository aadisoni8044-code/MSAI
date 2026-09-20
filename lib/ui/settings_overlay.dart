import 'package:flutter/material.dart';
import 'package:enchanted_forest_adventure/core/game_colors.dart';
import 'package:enchanted_forest_adventure/core/settings_controller.dart';

class SettingsOverlay extends StatelessWidget {
  const SettingsOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = SettingsController.instance;

    return ListenableBuilder(
      listenable: settings,
      builder: (context, _) {
        return Material(
          color: Colors.black.withValues(alpha: 0.75),
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Container(
                constraints: const BoxConstraints(maxWidth: 400),
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: GameColors.uiPanelBg,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: GameColors.uiGlassBorder, width: 1.5),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black54,
                      blurRadius: 30,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.settings_rounded, color: GameColors.uiTextGold, size: 28),
                        SizedBox(width: 10),
                        Text(
                          'SETTINGS',
                          style: TextStyle(
                            color: GameColors.uiTextLight,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 2,
                            shadows: [
                              Shadow(color: GameColors.playerGlow, blurRadius: 10),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Sound Switch
                    _buildSwitchRow(
                      icon: Icons.volume_up_rounded,
                      label: 'Sound Effects',
                      value: settings.soundEnabled,
                      onChanged: (val) => settings.setSoundEnabled(val),
                    ),
                    const Divider(color: Colors.white12, height: 24),

                    // Music Switch
                    _buildSwitchRow(
                      icon: Icons.music_note_rounded,
                      label: 'Background Music',
                      value: settings.musicEnabled,
                      onChanged: (val) => settings.setMusicEnabled(val),
                    ),
                    const Divider(color: Colors.white12, height: 24),

                    // Screen Orientation
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: const [
                            Icon(Icons.screen_rotation_rounded, color: GameColors.mistBlue, size: 20),
                            SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'Screen Orientation',
                                style: TextStyle(
                                  color: GameColors.uiTextLight,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: _buildOrientationOption(
                                context: context,
                                mode: GameOrientationMode.portrait,
                                icon: Icons.stay_current_portrait_rounded,
                                label: 'Portrait',
                                isSelected: settings.orientationMode == GameOrientationMode.portrait,
                                onTap: () => settings.setOrientationMode(GameOrientationMode.portrait),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildOrientationOption(
                                context: context,
                                mode: GameOrientationMode.landscape,
                                icon: Icons.stay_current_landscape_rounded,
                                label: 'Landscape',
                                isSelected: settings.orientationMode == GameOrientationMode.landscape,
                                onTap: () => settings.setOrientationMode(GameOrientationMode.landscape),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const Divider(color: Colors.white12, height: 24),

                    // Controls Section
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: const [
                            Icon(Icons.sports_esports_rounded, color: GameColors.uiTextGold, size: 20),
                            SizedBox(width: 10),
                            Text(
                              'CONTROLS',
                              style: TextStyle(
                                color: GameColors.uiTextLight,
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.2,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Colors.black38,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: GameColors.uiGlassBorder),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Mobile info
                              Row(
                                children: const [
                                  Icon(Icons.smartphone_rounded, color: GameColors.foliageGlow, size: 16),
                                  SizedBox(width: 8),
                                  Text(
                                    'Mobile:',
                                    style: TextStyle(
                                      color: GameColors.foliageGlow,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                    ),
                                  ),
                                  SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      'Touch Controls',
                                      style: TextStyle(color: Colors.white70, fontSize: 13),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              const Divider(color: Colors.white10, height: 1),
                              const SizedBox(height: 10),
                              // Laptop info
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Icon(Icons.laptop_mac_rounded, color: GameColors.mistBlue, size: 16),
                                  const SizedBox(width: 8),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: const [
                                      Text(
                                        'Laptop:',
                                        style: TextStyle(
                                          color: GameColors.mistBlue,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: const [
                                        Text('W / A / S / D', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
                                        SizedBox(height: 2),
                                        Text('SPACE — Jump', style: TextStyle(color: Colors.white70, fontSize: 12)),
                                        SizedBox(height: 2),
                                        Text('J — Attack', style: TextStyle(color: Colors.white70, fontSize: 12)),
                                        SizedBox(height: 2),
                                        Text('ESC — Pause', style: TextStyle(color: Colors.white70, fontSize: 12)),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 28),

                    // Back / Close Button
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: GameColors.mossyGreenBright,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                          elevation: 4,
                        ),
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.check_circle_outline_rounded, size: 22),
                        label: const Text(
                          'SAVE & BACK',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSwitchRow({
    required IconData icon,
    required String label,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Row(
      children: [
        Icon(icon, color: GameColors.mistBlue, size: 22),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              color: GameColors.uiTextLight,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Switch.adaptive(
          value: value,
          activeTrackColor: GameColors.deepForestTeal,
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _buildOrientationOption({
    required BuildContext context,
    required GameOrientationMode mode,
    required IconData icon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: isSelected ? GameColors.deepForestTeal : Colors.black26,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? GameColors.playerGlow : GameColors.uiGlassBorder,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: GameColors.playerGlow.withValues(alpha: 0.3),
                    blurRadius: 10,
                    spreadRadius: -2,
                  ),
                ]
              : null,
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? GameColors.foliageGlow : Colors.white60,
              size: 26,
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.white60,
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
