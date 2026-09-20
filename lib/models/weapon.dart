enum WeaponType { sword, pistol, ak47 }

class Weapon {
  final String name;
  final WeaponType type;
  final double damage;
  final double range;
  final double fireRate; // Shots or swings per second
  final int clipCapacity;
  final int maxReserveAmmo;
  final double reloadDuration; // Seconds
  final bool isAuto;

  int ammoInClip;
  int reserveAmmo;
  double cooldownTimer = 0.0;
  bool isReloading = false;
  double reloadTimer = 0.0;

  Weapon({
    required this.name,
    required this.type,
    required this.damage,
    required this.range,
    required this.fireRate,
    required this.clipCapacity,
    required this.maxReserveAmmo,
    required this.reloadDuration,
    required this.isAuto,
    required int initialAmmoInClip,
    required int initialReserveAmmo,
  })  : ammoInClip = initialAmmoInClip,
        reserveAmmo = initialReserveAmmo;

  bool get isMelee => type == WeaponType.sword;
  bool get canFire => cooldownTimer <= 0.0 && !isReloading && (isMelee || ammoInClip > 0);
  bool get canReload => !isMelee && !isReloading && ammoInClip < clipCapacity && reserveAmmo > 0;

  void update(double dt) {
    if (cooldownTimer > 0.0) {
      cooldownTimer -= dt;
      if (cooldownTimer < 0.0) cooldownTimer = 0.0;
    }

    if (isReloading) {
      reloadTimer -= dt;
      if (reloadTimer <= 0.0) {
        finishReload();
      }
    }
  }

  bool tryFire() {
    if (!canFire) return false;

    cooldownTimer = 1.0 / fireRate;
    if (!isMelee) {
      ammoInClip--;
    }
    return true;
  }

  bool startReload() {
    if (!canReload) return false;
    isReloading = true;
    reloadTimer = reloadDuration;
    return true;
  }

  void finishReload() {
    isReloading = false;
    reloadTimer = 0.0;

    final needed = clipCapacity - ammoInClip;
    final toAdd = needed < reserveAmmo ? needed : reserveAmmo;
    ammoInClip += toAdd;
    reserveAmmo -= toAdd;
  }

  void addReserveAmmo(int amount) {
    reserveAmmo = (reserveAmmo + amount).clamp(0, maxReserveAmmo);
  }

  // Pre-configured weapons
  factory Weapon.sword() {
    return Weapon(
      name: 'Combat Sword',
      type: WeaponType.sword,
      damage: 100.0, // Defeats basic zombie in 1 hit as specified
      range: 2.8,
      fireRate: 1.8,
      clipCapacity: 0,
      maxReserveAmmo: 0,
      reloadDuration: 0.0,
      isAuto: false,
      initialAmmoInClip: 0,
      initialReserveAmmo: 0,
    );
  }

  factory Weapon.pistol() {
    return Weapon(
      name: 'Pistol 9mm',
      type: WeaponType.pistol,
      damage: 40.0,
      range: 35.0,
      fireRate: 3.5,
      clipCapacity: 12,
      maxReserveAmmo: 120,
      reloadDuration: 1.5,
      isAuto: false,
      initialAmmoInClip: 12,
      initialReserveAmmo: 48,
    );
  }

  factory Weapon.ak47() {
    return Weapon(
      name: 'AK-47',
      type: WeaponType.ak47,
      damage: 65.0,
      range: 55.0,
      fireRate: 8.0,
      clipCapacity: 30,
      maxReserveAmmo: 240,
      reloadDuration: 2.2,
      isAuto: true,
      initialAmmoInClip: 30,
      initialReserveAmmo: 120,
    );
  }
}
