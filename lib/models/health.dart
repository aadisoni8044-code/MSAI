/// Manages health state for Player and Zombie entities.
class Health {
  final double maxHealth;
  double _currentHealth;

  Health({required this.maxHealth}) : _currentHealth = maxHealth;

  double get current => _currentHealth;
  double get percentage => (_currentHealth / maxHealth).clamp(0.0, 1.0);
  bool get isDead => _currentHealth <= 0.0;
  bool get isAlive => _currentHealth > 0.0;

  void takeDamage(double amount) {
    if (isDead) return;
    _currentHealth = (_currentHealth - amount).clamp(0.0, maxHealth);
  }

  void heal(double amount) {
    if (isDead) return;
    _currentHealth = (_currentHealth + amount).clamp(0.0, maxHealth);
  }

  void reset() {
    _currentHealth = maxHealth;
  }
}
