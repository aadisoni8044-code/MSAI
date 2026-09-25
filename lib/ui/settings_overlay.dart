import 'package:flutter/material.dart';
import 'package:enchanted_forest_adventure/core/game_colors.dart';
import 'package:enchanted_forest_adventure/core/settings_controller.dart';

class SettingsOverlay extends StatelessWidget {
  const SettingsOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = SettingsController.instance;
    final Size screenSize = MediaQuery.of(context).size;

    return ListenableBuilder(
      listenable: settings,
      builder: (context, _) {
        return Material(
          color: Colors.black.withValues(alpha: 0.75),
          child: Center(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: 400,
                maxHeight: screenSize.height * 0.92,
              ),
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: GameColors.uiPanelBg,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: GameColors.uiGlassBorder, width: 1.5),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black54,
                    blurRadius: 24,
                    spreadRadius: 4,
                  ),
                ],
              ),
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.settings_rounded, color: GameColors.uiTextGold, size: 24),
                        SizedBox(width: 8),
                        Text(
                          'SETTINGS',
                          style: TextStyle(
                            color: GameColors.uiTextLight,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.8,
                            shadows: [
                              Shadow(color: GameColors.playerGlow, blurRadius: 10),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Sound Switch
                    _buildSwitchRow(
                      icon: Icons.volume_up_rounded,
                      label: 'Sound Effects',
                      value: settings.soundEnabled,
                      onChanged: (val) => settings.setSoundEnabled(val),
                    ),
                    const Divider(color: Colors.white12, height: 16),

                    // Music Switch
                    _buildSwitchRow(
                      icon: Icons.music_note_rounded,
                      label: 'Background Music',
                      value: settings.musicEnabled,
                      onChanged: (val) => settings.setMusicEnabled(val),
                    ),
                    const Divider(color: Colors.white12, height: 16),

                    // Screen Orientation
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: const [
                            Icon(Icons.screen_rotation_rounded, color: GameColors.mistBlue, size: 18),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Screen Orientation',
                                style: TextStyle(
                                  color: GameColors.uiTextLight,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
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
                            const SizedBox(width: 10),
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
                    const Divider(color: Colors.white12, height: 16),

                    // Controls Section
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: const [
                            Icon(Icons.sports_esports_rounded, color: GameColors.uiTextGold, size: 18),
                            SizedBox(width: 8),
                            Text(
                              'CONTROLS',
                              style: TextStyle(
                                color: GameColors.uiTextLight,
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.0,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.black38,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: GameColors.uiGlassBorder),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Mobile info
                              Row(
                                children: const [
                                  Icon(Icons.smartphone_rounded, color: GameColors.foliageGlow, size: 14),
                                  SizedBox(width: 6),
                                  Text(
                                    'Mobile:',
                                    style: TextStyle(
                                      color: GameColors.foliageGlow,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                  SizedBox(width: 6),
                                  Expanded(
                                    child: Text(
                                      'Touch Controls',
                                      style: TextStyle(color: Colors.white70, fontSize: 11),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              const Divider(color: Colors.white10, height: 1),
                              const SizedBox(height: 8),
                              // Laptop info
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Icon(Icons.laptop_mac_rounded, color: GameColors.mistBlue, size: 14),
                                  const SizedBox(width: 6),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: const [
                                      Text(
                                        'Laptop:',
                                        style: TextStyle(
                                          color: GameColors.mistBlue,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: const [
                                        Text('W / A / S / D', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600)),
                                        SizedBox(height: 1),
                                        Text('SPACE — Jump', style: TextStyle(color: Colors.white70, fontSize: 10.5)),
                                        SizedBox(height: 1),
                                        Text('J — Attack', style: TextStyle(color: Colors.white70, fontSize: 10.5)),
                                        SizedBox(height: 1),
                                        Text('ESC — Pause', style: TextStyle(color: Colors.white70, fontSize: 10.5)),
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
                    const SizedBox(height: 20),

                    // Back / Close Button
                    SizedBox(
                      width: double.infinity,
                      height: 42,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: GameColors.mossyGreenBright,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          elevation: 4,
                        ),
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.check_circle_outline_rounded, size: 18),
                        label: const Text(
                          'SAVE & BACK',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.0,
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
        Icon(icon, color: GameColors.mistBlue, size: 18),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              color: GameColors.uiTextLight,
              fontSize: 13,
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
      borderRadius: BorderRadius.circular(14),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
        decoration: BoxDecoration(
          color: isSelected ? GameColors.deepForestTeal : Colors.black26,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? GameColors.playerGlow : GameColors.uiGlassBorder,
            width: isSelected ? 1.8 : 1.0,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? GameColors.foliageGlow : Colors.white60,
              size: 20,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.white60,
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
