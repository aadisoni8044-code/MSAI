/* Boss Class: Forest Guardian with 3 Phase Transitions */
class ForestBoss {
    constructor(x, y) {
        this.x = x;
        this.y = y;
        this.width = 90;
        this.height = 110;

        this.vx = 0;
        this.vy = 0;
        this.grounded = false;
        this.facing = 'left';

        this.maxHealth = 400;
        this.health = 400;
        this.damage = 25;

        this.phase = 1; // Phase 1, 2, or 3
        this.hurtTimer = 0;
        this.isDead = false;

        this.attackTimer = 0;
        this.attackInterval = 2.5;

        this.projectiles = [];
    }

    getBounds() {
        return { x: this.x, y: this.y, width: this.width, height: this.height };
    }

    takeDamage(amount) {
        if (this.isDead) return;

        this.health -= amount;
        this.hurtTimer = 0.25;

        window.audioManager.playHit();
        window.game.camera.shake(6, 0.2);

        window.game.particles.emitBurst({
            x: this.x + this.width / 2,
            y: this.y + this.height / 2,
            color: '#f0be4d',
            size: 4
        }, 12);

        // Phase Transitions
        const healthPct = this.health / this.maxHealth;
        if (healthPct <= 0.35 && this.phase < 3) {
            this.phase = 3;
            this.attackInterval = 1.2;
            window.audioManager.playBossRoar();
            window.hudManager.updateBossPhase('PHASE 3: FOREST RAGE');
            window.game.camera.shake(15, 0.8);
        } else if (healthPct <= 0.70 && this.phase < 2) {
            this.phase = 2;
            this.attackInterval = 1.8;
            window.audioManager.playBossRoar();
            window.hudManager.updateBossPhase('PHASE 2: ANCIENT SUMMONS');
        }

        if (this.health <= 0) {
            this.health = 0;
            this.isDead = true;
            window.audioManager.playBossRoar();
            window.game.particles.emitBurst({
                x: this.x + this.width / 2,
                y: this.y + this.height / 2,
                color: '#3fe0d0',
                size: 8
            }, 50);

            setTimeout(() => {
                window.game.triggerVictory();
            }, 1500);
        }

        window.hudManager.updateBossHealth(this.health, this.maxHealth);
    }

    update(dt, player, level) {
        if (this.isDead) return;

        if (this.hurtTimer > 0) this.hurtTimer -= dt;

        this.facing = player.x > this.x ? 'right' : 'left';

        // Attack Cycle
        this.attackTimer += dt;
        if (this.attackTimer >= this.attackInterval) {
            this.attackTimer = 0;
            this.performAttack(player, level);
        }

        // Update Projectiles
        for (let i = this.projectiles.length - 1; i >= 0; i--) {
            const proj = this.projectiles[i];
            proj.x += proj.vx * dt;
            proj.y += proj.vy * dt;
            proj.life -= dt;

            // Check hit player
            if (window.CollisionSystem.rectsOverlap(proj, player.getBounds())) {
                player.takeDamage(20, proj.vx > 0 ? 1 : -1);
                this.projectiles.splice(i, 1);
                continue;
            }

            if (proj.life <= 0) {
                this.projectiles.splice(i, 1);
            }
        }

        // Movement AI
        const dist = Math.abs(player.x - this.x);
        if (dist > 80) {
            const speed = this.phase === 3 ? 120 : (this.phase === 2 ? 80 : 50);
            this.vx = (this.facing === 'right' ? 1 : -1) * speed;
        } else {
            this.vx = 0;
        }

        window.Physics.applyGravity(this, dt);
        window.CollisionSystem.resolveTilemapCollision(this, level, dt);

        // Player Contact Damage
        if (window.CollisionSystem.rectsOverlap(this.getBounds(), player.getBounds())) {
            const dir = player.x > this.x ? 1 : -1;
            player.takeDamage(this.damage, dir);
        }
    }

    performAttack(player, level) {
        if (this.phase === 1) {
            // Ground Slam
            this.vy = -300;
            window.audioManager.playAttack();
            window.game.camera.shake(8, 0.4);
        } else if (this.phase === 2) {
            // Projectile Spores
            for (let i = -1; i <= 1; i++) {
                const angle = Math.atan2(player.y - this.y, player.x - this.x) + i * 0.2;
                this.projectiles.push({
                    x: this.x + this.width / 2,
                    y: this.y + 30,
                    width: 14,
                    height: 14,
                    vx: Math.cos(angle) * 220,
                    vy: Math.sin(angle) * 220,
                    life: 3.0
                });
            }
            window.audioManager.playAttack();
        } else if (this.phase === 3) {
            // Rage Leap Attack
            this.vy = -450;
            this.vx = (this.facing === 'right' ? 1 : -1) * 250;
            window.game.camera.shake(12, 0.5);
            window.audioManager.playBossRoar();
        }
    }

    render(ctx, offset) {
        if (this.isDead) return;

        const rx = Math.round(this.x - offset.x);
        const ry = Math.round(this.y - offset.y);

        ctx.save();

        // Projectiles
        ctx.fillStyle = '#e74c3c';
        for (let proj of this.projectiles) {
            const px = Math.round(proj.x - offset.x);
            const py = Math.round(proj.y - offset.y);
            ctx.beginPath();
            ctx.arc(px + 7, py + 7, 7, 0, Math.PI * 2);
            ctx.fill();
        }

        // Phase Aura
        if (this.phase === 3) {
            ctx.fillStyle = 'rgba(231, 76, 60, 0.2)';
            ctx.beginPath();
            ctx.arc(rx + 45, ry + 55, 75, 0, Math.PI * 2);
            ctx.fill();
        }

        // Boss Body
        ctx.fillStyle = this.hurtTimer > 0 ? '#ffffff' : (this.phase === 3 ? '#902316' : '#0f383e');
        ctx.fillRect(rx, ry, this.width, this.height);

        // Ancient Tree Horns
        ctx.fillStyle = '#4a2e1d';
        ctx.beginPath();
        ctx.moveTo(rx + 10, ry);
        ctx.lineTo(rx - 15, ry - 30);
        ctx.lineTo(rx + 25, ry);
        ctx.fill();

        ctx.beginPath();
        ctx.moveTo(rx + 80, ry);
        ctx.lineTo(rx + 105, ry - 30);
        ctx.lineTo(rx + 65, ry);
        ctx.fill();

        // Glowing Core
        ctx.fillStyle = this.phase === 3 ? '#ff7675' : '#3fe0d0';
        ctx.beginPath();
        ctx.arc(rx + 45, ry + 40, 16, 0, Math.PI * 2);
        ctx.fill();

        ctx.restore();
    }
}

window.ForestBoss = ForestBoss;
