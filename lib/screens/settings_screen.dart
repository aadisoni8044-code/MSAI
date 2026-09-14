import 'package:flutter/material.dart';

import '../services/game_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final gameService = GameService();

  @override
  Widget build(BuildContext context) {
    final settings = gameService.settings;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF030D18),
              Color(0xFF0F3B3E),
              Color(0xFF082224),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header Navigation
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Color(0xFF80FFDB)),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'SETTINGS',
                      style: TextStyle(
                        color: Color(0xFF80FFDB),
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2.0,
                      ),
                    ),
                  ],
                ),
              ),

              // Settings Options List
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(24),
                  children: [
                    _buildSwitchTile(
                      title: 'Background Music',
                      subtitle: 'Atmospheric dark forest soundtrack',
                      icon: Icons.music_note,
                      value: settings.musicEnabled,
                      onChanged: (val) {
                        setState(() {
                          settings.musicEnabled = val;
                        });
                        gameService.saveGameData();
                      },
                    ),
                    const SizedBox(height: 16),

                    _buildSwitchTile(
                      title: 'Sound Effects',
                      subtitle: 'Jump, attack, and impact sound feedback',
                      icon: Icons.volume_up,
                      value: settings.soundEnabled,
                      onChanged: (val) {
                        setState(() {
                          settings.soundEnabled = val;
                        });
                        gameService.saveGameData();
                      },
                    ),
                    const SizedBox(height: 16),

                    _buildSwitchTile(
                      title: 'Haptic Vibration',
                      subtitle: 'Haptic feedback on player hit and damage',
                      icon: Icons.vibration,
                      value: settings.vibrationEnabled,
                      onChanged: (val) {
                        setState(() {
                          settings.vibrationEnabled = val;
                        });
                        gameService.saveGameData();
                      },
                    ),
                    const SizedBox(height: 24),

                    // Graphics Quality Selector
                    _buildSectionHeader('Graphics Quality'),
                    const SizedBox(height: 12),
                    SegmentedButton<String>(
                      segments: const [
                        ButtonSegment(value: 'low', label: Text('Low')),
                        ButtonSegment(value: 'medium', label: Text('Medium')),
                        ButtonSegment(value: 'high', label: Text('High')),
                      ],
                      selected: {settings.graphicsQuality},
                      onSelectionChanged: (newVal) {
                        setState(() {
                          settings.graphicsQuality = newVal.first;
                        });
                        gameService.saveGameData();
                      },
                      style: SegmentedButton.styleFrom(
                        selectedBackgroundColor: const Color(0xFF80FFDB),
                        selectedForegroundColor: const Color(0xFF030D18),
                        foregroundColor: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Control Layout Selector
                    _buildSectionHeader('Mobile Touch Controls'),
                    const SizedBox(height: 12),
                    SegmentedButton<String>(
                      segments: const [
                        ButtonSegment(value: 'default', label: Text('Default')),
                        ButtonSegment(value: 'compact', label: Text('Compact')),
                        ButtonSegment(value: 'leftHanded', label: Text('Left Hand')),
                      ],
                      selected: {settings.controlLayout},
                      onSelectionChanged: (newVal) {
                        setState(() {
                          settings.controlLayout = newVal.first;
                        });
                        gameService.saveGameData();
                      },
                      style: SegmentedButton.styleFrom(
                        selectedBackgroundColor: const Color(0xFF64DFDF),
                        selectedForegroundColor: const Color(0xFF030D18),
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: Color(0xFF80FFDB),
        fontSize: 16,
        fontWeight: FontWeight.bold,
        letterSpacing: 1.2,
      ),
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xCC081F2C),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0x3364DFDF)),
      ),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF80FFDB), size: 28),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: Colors.white60,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            activeColor: const Color(0xFF80FFDB),
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}
