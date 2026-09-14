enum EnemyType {
  forestBug,
  shadowCreature,
  flyingCreature,
  guardian,
}

enum EnemyState {
  idle,
  patrol,
  chase,
  attack,
  hurt,
  death,
}

class EnemyModel {
  final String id;
  final EnemyType type;
  double x;
  double y;
  double vx;
  double vy;
  double width;
  double height;

  double startX;
  double endX;

  int health;
  int maxHealth;
  int damage;
  double speed;
  double attackRange;
  double detectionRange;

  bool facingRight;
  EnemyState state;

  double stateTimer;
  double attackCooldown;
  double hurtTimer;
  double deathTimer;
  bool isDead;

  EnemyModel({
    required this.id,
    required this.type,
    required this.x,
    required this.y,
    required this.startX,
    required this.endX,
    this.width = 36.0,
    this.height = 36.0,
    this.vx = 0.0,
    this.vy = 0.0,
    this.health = 30,
    this.maxHealth = 30,
    this.damage = 10,
    this.speed = 60.0,
    this.attackRange = 40.0,
    this.detectionRange = 180.0,
    this.facingRight = false,
    this.state = EnemyState.patrol,
    this.stateTimer = 0.0,
    this.attackCooldown = 0.0,
    this.hurtTimer = 0.0,
    this.deathTimer = 0.0,
    this.isDead = false,
  });

  factory EnemyModel.create({
    required String id,
    required EnemyType type,
    required double x,
    required double y,
    required double patrolDist,
  }) {
    switch (type) {
      case EnemyType.forestBug:
        return EnemyModel(
          id: id,
          type: type,
          x: x,
          y: y,
          startX: x - patrolDist,
          endX: x + patrolDist,
          width: 38.0,
          height: 30.0,
          health: 25,
          maxHealth: 25,
          damage: 10,
          speed: 50.0,
          attackRange: 35.0,
          detectionRange: 120.0,
        );
      case EnemyType.shadowCreature:
        return EnemyModel(
          id: id,
          type: type,
          x: x,
          y: y,
          startX: x - patrolDist,
          endX: x + patrolDist,
          width: 44.0,
          height: 48.0,
          health: 50,
          maxHealth: 50,
          damage: 18,
          speed: 80.0,
          attackRange: 45.0,
          detectionRange: 220.0,
        );
      case EnemyType.flyingCreature:
        return EnemyModel(
          id: id,
          type: type,
          x: x,
          y: y,
          startX: x - patrolDist,
          endX: x + patrolDist,
          width: 40.0,
          height: 36.0,
          health: 35,
          maxHealth: 35,
          damage: 12,
          speed: 95.0,
          attackRange: 40.0,
          detectionRange: 200.0,
        );
      case EnemyType.guardian:
        return EnemyModel(
          id: id,
          type: type,
          x: x,
          y: y,
          startX: x - patrolDist,
          endX: x + patrolDist,
          width: 64.0,
          height: 72.0,
          health: 120,
          maxHealth: 120,
          damage: 30,
          speed: 40.0,
          attackRange: 60.0,
          detectionRange: 250.0,
        );
    }
  }

  void takeDamage(int amount) {
    if (isDead) return;
    health -= amount;
    hurtTimer = 0.3;
    state = EnemyState.hurt;
    if (health <= 0) {
      health = 0;
      isDead = true;
      state = EnemyState.death;
      deathTimer = 0.8;
    }
  }
}
