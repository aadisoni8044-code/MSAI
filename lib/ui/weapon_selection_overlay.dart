import 'package:flutter/material.dart';
import 'package:enchanted_forest_adventure/core/zombie_progress_controller.dart';
import 'package:enchanted_forest_adventure/models/weapon_data.dart';

class WeaponSelectionOverlay extends StatelessWidget {
  final VoidCallback onStartWave;

  const WeaponSelectionOverlay({
    super.key,
    required this.onStartWave,
  });

  @override
  Widget build(BuildContext context) {
    final controller = ZombieProgressController.instance;

    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final unlocked = controller.unlockedWeapons;
        final selected = controller.selectedWeapon;

        return Center(
          child: Material(
            color: Colors.transparent,
            child: Container(
              width: 380,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xEE0B0F19),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFF10B981), width: 2),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x6610B981),
                    blurRadius: 18,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.shield_outlined, color: Color(0xFF10B981), size: 26),
                      SizedBox(width: 8),
                      Text(
                        'WEAPON SELECTION',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Choose your arsenal before entering the wave',
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                  const SizedBox(height: 16),
                  Column(
                    children: WeaponData.allWeapons.map((weapon) {
                      final isUnlocked = unlocked.contains(weapon.id);
                      final isSelected = selected == weapon.id;

                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? const Color(0x3310B981)
                              : const Color(0x22FFFFFF),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected
                                ? const Color(0xFF10B981)
                                : isUnlocked
                                    ? Colors.white30
                                    : Colors.white10,
                            width: isSelected ? 2 : 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Text(
                              weapon.iconSymbol,
                              style: const TextStyle(fontSize: 32),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    weapon.name,
                                    style: TextStyle(
                                      color: isUnlocked ? Colors.white : Colors.grey,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    isUnlocked
                                        ? weapon.description
                                        : '🔒 Complete Wave ${weapon.unlockWave} to unlock',
                                    style: TextStyle(
                                      color: isUnlocked ? Colors.white70 : Colors.orangeAccent,
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            if (isUnlocked)
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: isSelected
                                      ? const Color(0xFF10B981)
                                      : Colors.white12,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                onPressed: () {
                                  controller.selectWeapon(weapon.id);
                                },
                                child: Text(isSelected ? 'EQUIPPED' : 'EQUIP'),
                              )
                            else
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                decoration: BoxDecoration(
                                  color: Colors.black45,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.lock, color: Colors.grey, size: 14),
                                    SizedBox(width: 4),
                                    Text(
                                      'LOCKED',
                                      style: TextStyle(color: Colors.grey, fontSize: 11),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF10B981),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 4,
                      ),
                      onPressed: onStartWave,
                      icon: const Icon(Icons.play_arrow_rounded, size: 24),
                      label: const Text(
                        'READY FOR WAVE',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
