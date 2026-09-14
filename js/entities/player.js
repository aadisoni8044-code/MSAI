/* Player Entity Class with State Machine, Movement & Abilities */
class Player {
    constructor(x, y) {
        this.x = x;
        this.y = y;
        this.width = 28;
        this.height = 42;

        this.vx = 0;
        this.vy = 0;
        this.moveSpeed = 220;
        this.jumpForce = 440;

        this.grounded = false;
        this.facing = 'right';

        // Stats
        this.maxHealth = 100;
        this.health = 100;
        this.maxStamina = 100;
        this.stamina = 100;
        this.staminaRegenRate = 35; // per second

        // Action States
        this.isCrouching = false;
        this.canDoubleJump = true;
        this.isDashing = false;
        this.dashTimer = 0;
        this.dashDuration = 0.2;
        this.dashCooldown = 0;
        this.dashSpeed = 600;

        this.isAttacking = false;
        this.attackTimer = 0;
        this.attackDuration = 0.25;
        this.attackCooldown = 0;
        this.attackDamage = 25;

        this.hurtTimer = 0;
        this.invulnerableTimer = 0;
        this.isDead = false;

        this.boundsOffset = { x: 0, y: 0 };
    }

    getBounds() {
        if (this.isCrouching) {
            return { x: this.x, y: this.y + 16, width: this.width, height: this.height - 16 };
        }
        return { x: this.x, y: this.y, width: this.width, height: this.height };
    }

    getAttackHurtbox() {
        if (!this.isAttacking) return null;
        const reach = 36;
        const height = 40;
        const x = this.facing === 'right' ? this.x + this.width : this.x - reach;
        return { x, y: this.y, width: reach, height };
    }

    update(dt, level) {
        if (this.isDead) return;

        // Cooldown Timers
        if (this.dashCooldown > 0) this.dashCooldown -= dt;
        if (this.attackCooldown > 0) this.attackCooldown -= dt;
        if (this.hurtTimer > 0) this.hurtTimer -= dt;
        if (this.invulnerableTimer > 0) this.invulnerableTimer -= dt;

        // Regenerate Stamina
        if (!this.isDashing && this.stamina < this.maxStamina) {
            this.stamina = Math.min(this.maxStamina, this.stamina + this.staminaRegenRate * dt);
        }

        // Handle Dash State
        if (this.isDashing) {
            this.dashTimer -= dt;
            this.vx = (this.facing === 'right' ? 1 : -1) * this.dashSpeed;
            this.vy = 0;

            // Spawn Dash Trail Particles
            if (Math.random() < 0.6) {
                window.game.particles.emit({
                    x: this.x + this.width / 2,
                    y: this.y + this.height / 2,
                    vx: (Math.random() - 0.5) * 40,
                    vy: (Math.random() - 0.5) * 40,
                    color: '#3fe0d0',
                    size: 3,
                    maxLife: 0.3
                });
            }

            if (this.dashTimer <= 0) {
                this.isDashing = false;
            }

            window.CollisionSystem.resolveTilemapCollision(this, level, dt);
            return;
        }

        // Handle Attack State
        if (this.isAttacking) {
            this.attackTimer -= dt;
            if (this.attackTimer <= 0) {
                this.isAttacking = false;
            }
        }

        // Horizontal Movement Input
        const input = window.inputHandler;
        let moveDir = 0;
        if (input.isPressed('left')) moveDir -= 1;
        if (input.isPressed('right')) moveDir += 1;

        if (moveDir !== 0) {
            this.facing = moveDir > 0 ? 'right' : 'left';
            this.vx = moveDir * this.moveSpeed;
            this.isMoving = true;
        } else {
            this.vx = 0;
            this.isMoving = false;
        }

        // Crouch Input
        this.isCrouching = input.isPressed('down') && this.grounded;

        // Jump Input
        if (input.isJustPressed('jump')) {
            if (this.grounded) {
                this.vy = -this.jumpForce;
                this.grounded = false;
                this.canDoubleJump = true;
                window.audioManager.playJump();
                window.game.particles.emitBurst({ x: this.x + this.width / 2, y: this.y + this.height, color: '#e2f1f8' }, 6);
            } else if (this.canDoubleJump && this.stamina >= 20) {
                this.vy = -this.jumpForce * 0.9;
                this.canDoubleJump = false;
                this.stamina -= 20;
                window.audioManager.playJump();
                window.game.particles.emitBurst({ x: this.x + this.width / 2, y: this.y + this.height / 2, color: '#3fe0d0' }, 8);
            }
        }

        // Dash Trigger Input
        if (input.isJustPressed('dash') && this.dashCooldown <= 0 && this.stamina >= 25) {
            this.isDashing = true;
            this.dashTimer = this.dashDuration;
            this.dashCooldown = 0.6;
            this.stamina -= 25;
            window.audioManager.playDash();
        }

        // Attack Trigger Input
        if (input.isJustPressed('attack') && this.attackCooldown <= 0) {
            this.isAttacking = true;
            this.attackTimer = this.attackDuration;
            this.attackCooldown = 0.35;
            window.audioManager.playAttack();
        }

        // Physics & Gravity
        window.Physics.applyGravity(this, dt);
        window.CollisionSystem.resolveTilemapCollision(this, level, dt);

        // Reset double jump when grounded
        if (this.grounded) {
            this.canDoubleJump = true;
        }

        // Check level boundary death
        if (this.y > level.height + 100) {
            this.takeDamage(100, 0);
        }
    }

    takeDamage(amount, knockbackDir = 0) {
        if (this.invulnerableTimer > 0 || this.isDead || this.isDashing) return;

        this.health = Math.max(0, this.health - amount);
        this.hurtTimer = 0.3;
        this.invulnerableTimer = 1.0;

        window.audioManager.playHit();
        window.game.camera.shake(10, 0.3);

        if (knockbackDir !== 0) {
            this.vx = knockbackDir * 250;
            this.vy = -200;
        }

        window.game.particles.emitBurst({
            x: this.x + this.width / 2,
            y: this.y + this.height / 2,
            color: '#e74c3c'
        }, 12);

        if (this.health <= 0) {
            this.isDead = true;
            window.game.triggerGameOver();
        }
    }

    heal(amount) {
        this.health = Math.min(this.maxHealth, this.health + amount);
    }

    restoreStamina(amount) {
        this.stamina = Math.min(this.maxStamina, this.stamina + amount);
    }

    render(ctx, offset) {
        if (this.isDead) return;
        window.CharacterRenderer.drawPlayer(ctx, this, offset);
    }
}

window.Player = Player;
