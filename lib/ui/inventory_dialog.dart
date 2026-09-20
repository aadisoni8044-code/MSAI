import 'package:flutter/material.dart';
import '../game/game_controller.dart';
import '../models/weapon.dart';

class InventoryDialog extends StatelessWidget {
  final GameController controller;

  const InventoryDialog({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final player = controller.player;

    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF0F172A).withValues(alpha: 0.95),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.amberAccent.withValues(alpha: 0.8), width: 2),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Icon(Icons.backpack, color: Colors.amberAccent, size: 28),
                    SizedBox(width: 10),
                    Text(
                      'SURVIVAL INVENTORY',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.black,
                        fontSize: 18,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close, color: Colors.white70),
                ),
              ],
            ),
            const Divider(color: Colors.amberAccent),
            const SizedBox(height: 12),

            // Weapons List
            const Text(
              'EQUIPPED WEAPONS',
              style: TextStyle(color: Colors.amberAccent, fontWeight: FontWeight.bold, fontSize: 13),
            ),
            const SizedBox(height: 8),

            Column(
              children: player.weapons.asMap().entries.map((entry) {
                final idx = entry.key;
                final weapon = entry.value;
                final isSelected = idx == player.activeWeaponIndex;

                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.amber.shade900.withValues(alpha: 0.4) : Colors.black26,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isSelected ? Colors.amberAccent : Colors.grey.shade800,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(
                            weapon.type == WeaponType.sword
                                ? Icons.hardware
                                : weapon.type == WeaponType.ak47
                                    ? Icons.military_tech
                                    : Icons.adjust,
                            color: isSelected ? Colors.amberAccent : Colors.white70,
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                weapon.name,
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                              ),
                              Text(
                                weapon.isMelee ? 'Melee • Damage: 100' : 'Ammo: ${weapon.ammoInClip} / ${weapon.reserveAmmo}',
                                style: TextStyle(color: Colors.grey.shade400, fontSize: 12),
                              ),
                            ],
                          ),
                        ],
                      ),
                      if (isSelected)
                        const Chip(
                          label: Text('ACTIVE', style: TextStyle(color: Colors.black, fontWeight: FontWeight.black, fontSize: 10)),
                          backgroundColor: Colors.amberAccent,
                        )
                      else
                        ElevatedButton(
                          onPressed: () {
                            player.activeWeaponIndex = idx;
                            controller.notifyListeners();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey.shade800,
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('EQUIP'),
                        ),
                    ],
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 16),

            // Health Kits Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.medical_services, color: Colors.emeraldAccent, size: 22),
                    const SizedBox(width: 8),
                    Text(
                      'MEDICAL KITS: ${player.healthKits}',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                ElevatedButton(
                  onPressed: player.healthKits > 0
                      ? () {
                          controller.handleUseHealthPack();
                          Navigator.of(context).pop();
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.emerald,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('USE (+40 HP)'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
