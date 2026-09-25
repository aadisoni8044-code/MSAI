import 'package:flutter/material.dart';

class ZombieMilestoneOverlay extends StatelessWidget {
  final int milestone;
  final VoidCallback onContinue;

  const ZombieMilestoneOverlay({
    super.key,
    required this.milestone,
    required this.onContinue,
  });

  @override
  Widget build(BuildContext context) {
    final is100 = milestone == 100;
    final title = is100 ? '100 ZOMBIES DEFEATED!' : '50 ZOMBIES DEFEATED!';
    final rewardText = is100
        ? '🏆 UNLOCKED: Legendary Zombie Slayer Badge & Max Arsenal Upgrade!'
        : '🔫 UNLOCKED: AK-47 Heavy Rifle Unlocked in Weapon Selection!';

    return Center(
      child: Material(
        color: Colors.transparent,
        child: Container(
          width: 340,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xEE1E1B4B),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFF59E0B), width: 3),
            boxShadow: const [
              BoxShadow(
                color: Color(0x66F59E0B),
                blurRadius: 24,
                spreadRadius: 4,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('🏆', style: TextStyle(fontSize: 52)),
              const SizedBox(height: 10),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color(0xFFF59E0B),
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0x33F59E0B),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  rewardText,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 46,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF59E0B),
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: onContinue,
                  child: const Text(
                    'CLAIM REWARD',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
