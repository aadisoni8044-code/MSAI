class WeaponData {
  final String id;
  final String name;
  final String description;
  final String iconSymbol;
  final double damageMultiplier;
  final double fireRate; // Attacks per second or cooldown factor
  final double range;
  final int unlockWave;
  final int unlockZombies;

  const WeaponData({
    required this.id,
    required this.name,
    required this.description,
    required this.iconSymbol,
    required this.damageMultiplier,
    required this.fireRate,
    required this.range,
    required this.unlockWave,
    required this.unlockZombies,
  });

  static const WeaponData basic = WeaponData(
    id: 'basic',
    name: 'Basic Magic Staff',
    description: 'Standard magical forest blast. Reliable and balanced.',
    iconSymbol: '🪄',
    damageMultiplier: 1.0,
    fireRate: 1.0,
    range: 220.0,
    unlockWave: 1,
    unlockZombies: 0,
  );

  static const WeaponData ak47 = WeaponData(
    id: 'ak47',
    name: 'AK-47 Rifle',
    description: 'Rapid-fire zombie shredder. High damage and rapid projectiles.',
    iconSymbol: '🔫',
    damageMultiplier: 1.8,
    fireRate: 2.2,
    range: 450.0,
    unlockWave: 2,
    unlockZombies: 20,
  );

  static List<WeaponData> get allWeapons => [basic, ak47];

  static WeaponData getById(String id) {
    return allWeapons.firstWhere((w) => w.id == id, orElse: () => basic);
  }
}
