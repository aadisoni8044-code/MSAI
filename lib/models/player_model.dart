enum PlayerState {
  idle,
  walk,
  run,
  jump,
  fall,
  attack,
  dash,
  hurt,
  death,
}

class PlayerModel {
  double x;
  double y;
  double vx;
  double vy;
  double width;
  double height;

  int health;
  int maxHealth;
  double energy;
  double maxEnergy;

  bool facingRight;
  bool isGrounded;
  int jumpCount;
  int maxJumps;

  bool isDashing;
  double dashTimer;
  double dashCooldown;

  bool isAttacking;
  double attackTimer;
  double attackCooldown;

  bool isHurt;
  double hurtTimer;
  double invulnerableTimer;

  bool isDead;
  double deathTimer;

  PlayerState state;

  // Upgrades & Stats
  int healthUpgrades;
  int energyUpgrades;
  int damageUpgrades;
  int coins;
  int crystals;

  PlayerModel({
    this.x = 100.0,
    this.y = 300.0,
    this.vx = 0.0,
    this.vy = 0.0,
    this.width = 40.0,
    this.height = 54.0,
    this.health = 100,
    this.maxHealth = 100,
    this.energy = 100.0,
    this.maxEnergy = 100.0,
    this.facingRight = true,
    this.isGrounded = false,
    this.jumpCount = 0,
    this.maxJumps = 2,
    this.isDashing = false,
    this.dashTimer = 0.0,
    this.dashCooldown = 0.0,
    this.isAttacking = false,
    this.attackTimer = 0.0,
    this.attackCooldown = 0.0,
    this.isHurt = false,
    this.hurtTimer = 0.0,
    this.invulnerableTimer = 0.0,
    this.isDead = false,
    this.deathTimer = 0.0,
    this.state = PlayerState.idle,
    this.healthUpgrades = 0,
    this.energyUpgrades = 0,
    this.damageUpgrades = 0,
    this.coins = 0,
    this.crystals = 0,
  });

  void reset(double spawnX, double spawnY) {
    x = spawnX;
    y = spawnY;
    vx = 0.0;
    vy = 0.0;
    health = maxHealth;
    energy = maxEnergy;
    facingRight = true;
    isGrounded = false;
    jumpCount = 0;
    isDashing = false;
    dashTimer = 0.0;
    dashCooldown = 0.0;
    isAttacking = false;
    attackTimer = 0.0;
    attackCooldown = 0.0;
    isHurt = false;
    hurtTimer = 0.0;
    invulnerableTimer = 0.0;
    isDead = false;
    deathTimer = 0.0;
    state = PlayerState.idle;
  }

  void updateState() {
    if (isDead) {
      state = PlayerState.death;
      return;
    }
    if (isHurt) {
      state = PlayerState.hurt;
      return;
    }
    if (isDashing) {
      state = PlayerState.dash;
      return;
    }
    if (isAttacking) {
      state = PlayerState.attack;
      return;
    }
    if (!isGrounded) {
      if (vy < 0) {
        state = PlayerState.jump;
      } else {
        state = PlayerState.fall;
      }
      return;
    }
    if (vx.abs() > 180) {
      state = PlayerState.run;
    } else if (vx.abs() > 10) {
      state = PlayerState.walk;
    } else {
      state = PlayerState.idle;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'healthUpgrades': healthUpgrades,
      'energyUpgrades': energyUpgrades,
      'damageUpgrades': damageUpgrades,
      'coins': coins,
      'crystals': crystals,
    };
  }

  void loadFromJson(Map<String, dynamic> json) {
    healthUpgrades = json['healthUpgrades'] ?? 0;
    energyUpgrades = json['energyUpgrades'] ?? 0;
    damageUpgrades = json['damageUpgrades'] ?? 0;
    coins = json['coins'] ?? 0;
    crystals = json['crystals'] ?? 0;

    maxHealth = 100 + (healthUpgrades * 20);
    maxEnergy = 100.0 + (energyUpgrades * 20.0);
    health = maxHealth;
    energy = maxEnergy;
  }
}
