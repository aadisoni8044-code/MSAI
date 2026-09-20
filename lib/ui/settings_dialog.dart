import 'package:flutter/material.dart';
import '../game/game_controller.dart';

class SettingsDialog extends StatefulWidget {
  final GameController controller;

  const SettingsDialog({super.key, required this.controller});

  @override
  State<SettingsDialog> createState() => _SettingsDialogState();
}

class _SettingsDialogState extends State<SettingsDialog> {
  @override
  Widget build(BuildContext context) {
    final controller = widget.controller;

    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: const Color(0xFF0F172A).withValues(alpha: 0.95),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.indigoAccent.withValues(alpha: 0.8), width: 2),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.settings, color: Colors.indigoAccent, size: 28),
                SizedBox(width: 10),
                Text(
                  'PAUSE & SETTINGS',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.black,
                    fontSize: 20,
                    letterSpacing: 1.2,
                  ),
                ),
              ],
            ),
            const Divider(color: Colors.indigoAccent),
            const SizedBox(height: 16),

            // Camera Sensitivity
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Camera Sensitivity', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    Text('${(controller.cameraSensitivity * 100).round()}%', style: const TextStyle(color: Colors.indigoAccent)),
                  ],
                ),
                Slider(
                  value: controller.cameraSensitivity,
                  min: 0.2,
                  max: 2.5,
                  activeColor: Colors.indigoAccent,
                  onChanged: (val) {
                    setState(() {
                      controller.cameraSensitivity = val;
                    });
                  },
                ),
              ],
            ),

            // Audio SFX Toggle
            SwitchListTile(
              title: const Text('Sound Effects (SFX)', style: TextStyle(color: Colors.white)),
              value: controller.soundEffectsEnabled,
              activeColor: Colors.indigoAccent,
              onChanged: (val) {
                setState(() {
                  controller.soundEffectsEnabled = val;
                });
              },
            ),

            // Music Toggle
            SwitchListTile(
              title: const Text('Background Music', style: TextStyle(color: Colors.white)),
              value: controller.musicEnabled,
              activeColor: Colors.indigoAccent,
              onChanged: (val) {
                setState(() {
                  controller.musicEnabled = val;
                });
              },
            ),

            const SizedBox(height: 20),

            // Action Buttons (Resume, Restart)
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      controller.restartGame();
                      Navigator.of(context).pop();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red.shade900,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text('RESTART'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      controller.togglePause();
                      Navigator.of(context).pop();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.indigoAccent,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text('RESUME'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
