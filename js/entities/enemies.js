/* Enemy Classes & AI Behaviors */
class BaseEnemy {
    constructor(x, y, width, height, type) {
        this.x = x;
        this.y = y;
        this.width = width;
        this.height = height;
        this.type = type;

        this.vx = 0;
        this.vy = 0;
        this.grounded = false;
        this.facing = 'left';

        this.maxHealth = 40;
        this.health = 40;
        this.damage = 15;
        this.detectionRange = 250;

        this.hurtTimer = 0;
        this.isDead = false;
    }

    getBounds() {
        return { x: this.x, y: this.y, width: this.width, height: this.height };
    }

    takeDamage(amount) {
        if (this.isDead) return;

        this.health -= amount;
        this.hurtTimer = 0.2;

        window.audioManager.playHit();
        window.game.particles.emitBurst({
            x: this.x + this.width / 2,
            y: this.y + this.height / 2,
            color: '#3fe0d0'
        }, 10);

        if (this.health <= 0) {
            this.isDead = true;
            window.audioManager.playCollect('coin'); // Kill reward sound
            window.game.particles.emitBurst({
                x: this.x + this.width / 2,
                y: this.y + this.height / 2,
                color: '#2ca5a1',
                size: 5
            }, 20);
        }
    }

    checkPlayerCollision(player) {
        if (this.isDead || player.isDead) return;
        const eBounds = this.getBounds();
        const pBounds = player.getBounds();

        if (window.CollisionSystem.rectsOverlap(eBounds, pBounds)) {
            const dir = (pBounds.x + pBounds.width / 2) > (eBounds.x + eBounds.width / 2) ? 1 : -1;
            player.takeDamage(this.damage, dir);
        }
    }

    update(dt, player, level) {
        if (this.isDead) return;
        if (this.hurtTimer > 0) this.hurtTimer -= dt;
        this.checkPlayerCollision(player);
    }
}

/* 1. Forest Slime */
class ForestSlime extends BaseEnemy {
    constructor(x, y) {
        super(x, y, 32, 24, 'slime');
        this.maxHealth = 30;
        this.health = 30;
        this.jumpTimer = 0;
    }

    update(dt, player, level) {
        super.update(dt, player, level);
        if (this.isDead) return;

        const dist = Math.abs(player.x - this.x);
        if (dist < this.detectionRange && this.grounded) {
            this.facing = player.x > this.x ? 'right' : 'left';
            this.jumpTimer += dt;
            if (this.jumpTimer > 1.5) {
                this.jumpTimer = 0;
                this.vy = -300;
                this.vx = (this.facing === 'right' ? 1 : -1) * 120;
            }
        }

        window.Physics.applyGravity(this, dt);
        window.Physics.applyFriction(this);
        window.CollisionSystem.resolveTilemapCollision(this, level, dt);
    }

    render(ctx, offset) {
        if (this.isDead) return;
        const rx = Math.round(this.x - offset.x);
        const ry = Math.round(this.y - offset.y);

        ctx.save();
        ctx.fillStyle = this.hurtTimer > 0 ? '#ffffff' : '#3a7d44';
        ctx.beginPath();
        ctx.ellipse(rx + 16, ry + 16, 16, 12, 0, 0, Math.PI * 2);
        ctx.fill();

        // Eyes
        ctx.fillStyle = '#f0be4d';
        ctx.beginPath();
        const eyeOffset = this.facing === 'right' ? 4 : -4;
        ctx.arc(rx + 16 + eyeOffset, ry + 12, 3, 0, Math.PI * 2);
        ctx.fill();
        ctx.restore();
    }
}

/* 2. Thorn Creature */
class ThornCreature extends BaseEnemy {
    constructor(x, y) {
        super(x, y, 36, 36, 'thorn');
        this.maxHealth = 50;
        this.health = 50;
        this.patrolDir = 1;
        this.moveSpeed = 60;
    }

    update(dt, player, level) {
        super.update(dt, player, level);
        if (this.isDead) return;

        this.vx = this.patrolDir * this.moveSpeed;
        window.Physics.applyGravity(this, dt);

        const oldX = this.x;
        window.CollisionSystem.resolveTilemapCollision(this, level, dt);

        if (Math.abs(this.x - oldX) < 0.1) {
            this.patrolDir *= -1; // Reverse direction on wall hit
        }
    }

    render(ctx, offset) {
        if (this.isDead) return;
        const rx = Math.round(this.x - offset.x);
        const ry = Math.round(this.y - offset.y);

        ctx.save();
        ctx.fillStyle = this.hurtTimer > 0 ? '#ffffff' : '#1f4e38';
        ctx.fillRect(rx, ry, 36, 36);

        // Spikes
        ctx.fillStyle = '#82d973';
        for (let i = 0; i < 4; i++) {
            ctx.beginPath();
            ctx.moveTo(rx + i * 9, ry);
            ctx.lineTo(rx + i * 9 + 4.5, ry - 8);
            ctx.lineTo(rx + (i + 1) * 9, ry);
            ctx.fill();
        }
        ctx.restore();
    }
}

/* 3. Flying Spirit */
class FlyingSpirit extends BaseEnemy {
    constructor(x, y) {
        super(x, y, 28, 28, 'spirit');
        this.maxHealth = 25;
        this.health = 25;
        this.baseY = y;
        this.time = Math.random() * 10;
    }

    update(dt, player, level) {
        super.update(dt, player, level);
        if (this.isDead) return;

        this.time += dt;
        const dist = Math.hypot(player.x - this.x, player.y - this.y);

        if (dist < this.detectionRange) {
            const angle = Math.atan2(player.y - this.y, player.x - this.x);
            this.vx = Math.cos(angle) * 90;
            this.vy = Math.sin(angle) * 90;
        } else {
            this.vx = 0;
            this.vy = Math.sin(this.time * 3) * 30;
        }

        this.x += this.vx * dt;
        this.y += this.vy * dt;
    }

    render(ctx, offset) {
        if (this.isDead) return;
        const rx = Math.round(this.x - offset.x);
        const ry = Math.round(this.y - offset.y);

        ctx.save();
        const glow = ctx.createRadialGradient(rx + 14, ry + 14, 2, rx + 14, ry + 14, 18);
        glow.addColorStop(0, '#ffffff');
        glow.addColorStop(0.5, '#3fe0d0');
        glow.addColorStop(1, 'transparent');

        ctx.fillStyle = glow;
        ctx.beginPath();
        ctx.arc(rx + 14, ry + 14, 18, 0, Math.PI * 2);
        ctx.fill();
        ctx.restore();
    }
}

/* 4. Shadow Beast */
class ShadowBeast extends BaseEnemy {
    constructor(x, y) {
        super(x, y, 44, 32, 'shadow_beast');
        this.maxHealth = 70;
        this.health = 70;
        this.damage = 25;
        this.chargeSpeed = 220;
    }

    update(dt, player, level) {
        super.update(dt, player, level);
        if (this.isDead) return;

        const dist = Math.abs(player.x - this.x);
        if (dist < this.detectionRange) {
            this.facing = player.x > this.x ? 'right' : 'left';
            this.vx = (this.facing === 'right' ? 1 : -1) * this.chargeSpeed;
        } else {
            this.vx = 0;
        }

        window.Physics.applyGravity(this, dt);
        window.CollisionSystem.resolveTilemapCollision(this, level, dt);
    }

    render(ctx, offset) {
        if (this.isDead) return;
        const rx = Math.round(this.x - offset.x);
        const ry = Math.round(this.y - offset.y);

        ctx.save();
        ctx.fillStyle = this.hurtTimer > 0 ? '#ffffff' : '#071015';
        ctx.beginPath();
        ctx.roundRect(rx, ry, 44, 32, 8);
        ctx.fill();

        // Glowing Red Eyes
        ctx.fillStyle = '#e74c3c';
        const eyeX = this.facing === 'right' ? rx + 32 : rx + 8;
        ctx.beginPath();
        ctx.arc(eyeX, ry + 10, 4, 0, Math.PI * 2);
        ctx.fill();
        ctx.restore();
    }
}

/* 5. Giant Spider */
class GiantSpider extends BaseEnemy {
    constructor(x, y) {
        super(x, y, 40, 36, 'spider');
        this.maxHealth = 45;
        this.health = 45;
        this.anchorY = y;
        this.descended = false;
    }

    update(dt, player, level) {
        super.update(dt, player, level);
        if (this.isDead) return;

        if (Math.abs(player.x - this.x) < 80 && !this.descended) {
            this.descended = true;
        }

        if (this.descended && this.y < this.anchorY + 120) {
            this.y += 150 * dt;
        }

        this.checkPlayerCollision(player);
    }

    render(ctx, offset) {
        if (this.isDead) return;
        const rx = Math.round(this.x - offset.x);
        const ry = Math.round(this.y - offset.y);

        ctx.save();
        // Web strand
        ctx.strokeStyle = 'rgba(255, 255, 255, 0.4)';
        ctx.beginPath();
        ctx.moveTo(rx + 20, this.anchorY - offset.y);
        ctx.lineTo(rx + 20, ry);
        ctx.stroke();

        // Spider Body
        ctx.fillStyle = this.hurtTimer > 0 ? '#ffffff' : '#2c3e50';
        ctx.beginPath();
        ctx.arc(rx + 20, ry + 18, 16, 0, Math.PI * 2);
        ctx.fill();
        ctx.restore();
    }
}

/* 6. Ancient Guardian */
class AncientGuardian extends BaseEnemy {
    constructor(x, y) {
        super(x, y, 48, 64, 'guardian');
        this.maxHealth = 120;
        this.health = 120;
        this.damage = 30;
    }

    update(dt, player, level) {
        super.update(dt, player, level);
        if (this.isDead) return;

        const dist = Math.abs(player.x - this.x);
        if (dist < 200) {
            this.facing = player.x > this.x ? 'right' : 'left';
            this.vx = (this.facing === 'right' ? 1 : -1) * 40;
        }

        window.Physics.applyGravity(this, dt);
        window.CollisionSystem.resolveTilemapCollision(this, level, dt);
    }

    render(ctx, offset) {
        if (this.isDead) return;
        const rx = Math.round(this.x - offset.x);
        const ry = Math.round(this.y - offset.y);

        ctx.save();
        ctx.fillStyle = this.hurtTimer > 0 ? '#ffffff' : '#195b63';
        ctx.fillRect(rx, ry, 48, 64);

        // Core Gem
        ctx.fillStyle = '#f0be4d';
        ctx.fillRect(rx + 18, ry + 20, 12, 12);
        ctx.restore();
    }
}

window.ForestSlime = ForestSlime;
window.ThornCreature = ThornCreature;
window.FlyingSpirit = FlyingSpirit;
window.ShadowBeast = ShadowBeast;
window.GiantSpider = GiantSpider;
window.AncientGuardian = AncientGuardian;
