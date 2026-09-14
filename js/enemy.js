/* SYLVAN WHISPERS - ENEMY AI & PROCEDURAL RENDERER */
window.Enemy = function(type, x, y, options = {}) {
    this.type = type; // 'patrol', 'flyer', 'shadow'
    this.x = x;
    this.y = y;

    if (type === 'patrol') {
        this.width = 38;
        this.height = 36;
        this.health = 40;
        this.maxHealth = 40;
        this.speed = 1.8;
        this.damage = 15;
        this.patrolMin = options.patrolMin || x - 150;
        this.patrolMax = options.patrolMax || x + 150;
        this.vx = this.speed;
        this.vy = 0;
    } else if (type === 'flyer') {
        this.width = 32;
        this.height = 30;
        this.health = 25;
        this.maxHealth = 25;
        this.speed = 2.2;
        this.damage = 10;
        this.minY = options.minY || y - 60;
        this.maxY = options.maxY || y + 60;
        this.vx = 1.2;
        this.vy = 1.0;
        this.baseY = y;
    } else if (type === 'shadow') {
        this.width = 44;
        this.height = 50;
        this.health = 65;
        this.maxHealth = 65;
        this.speed = 2.8;
        this.damage = 25;
        this.patrolMin = options.patrolMin || x - 120;
        this.patrolMax = options.patrolMax || x + 120;
        this.vx = this.speed;
        this.vy = 0;
        this.isAggro = false;
    }

    this.isDead = false;
    this.animFrame = Math.random() * 10;
    this.facingRight = true;
    this.invulnerableTimer = 0;

    this.update = function(player, collisionSystem, platforms) {
        if (this.isDead) return;
        this.animFrame += 0.15;
        if (this.invulnerableTimer > 0) this.invulnerableTimer--;

        if (this.type === 'patrol') {
            this.x += this.vx;
            if (this.x <= this.patrolMin) {
                this.x = this.patrolMin;
                this.vx = this.speed;
                this.facingRight = true;
            } else if (this.x >= this.patrolMax) {
                this.x = this.patrolMax;
                this.vx = -this.speed;
                this.facingRight = false;
            }

            this.vy += 0.5; // gravity
            this.y += this.vy;
            if (collisionSystem) collisionSystem.resolveEnemyPlatforms(this, platforms);
        } else if (this.type === 'flyer') {
            // Sinusoidal floating movement + player tracking
            this.y = this.baseY + Math.sin(this.animFrame) * 40;

            const distToPlayer = Math.hypot(player.x - this.x, player.y - this.y);
            if (distToPlayer < 280) {
                const angle = Math.atan2(player.y - this.y, player.x - this.x);
                this.x += Math.cos(angle) * this.speed;
                this.baseY += Math.sin(angle) * (this.speed * 0.5);
                this.facingRight = player.x > this.x;
            } else {
                this.x += this.vx;
                if (this.x <= options.patrolMin || this.x >= options.patrolMax) {
                    this.vx = -this.vx;
                    this.facingRight = this.vx > 0;
                }
            }
        } else if (this.type === 'shadow') {
            const distToPlayer = Math.abs(player.x - this.x);
            if (distToPlayer < 240 && Math.abs(player.y - this.y) < 100) {
                this.isAggro = true;
                this.facingRight = player.x > this.x;
                this.vx = this.facingRight ? this.speed : -this.speed;
            } else {
                this.isAggro = false;
                if (this.x <= this.patrolMin) {
                    this.x = this.patrolMin;
                    this.vx = this.speed;
                    this.facingRight = true;
                } else if (this.x >= this.patrolMax) {
                    this.x = this.patrolMax;
                    this.vx = -this.speed;
                    this.facingRight = false;
                }
            }

            this.x += this.vx;
            this.vy += 0.5;
            this.y += this.vy;
            if (collisionSystem) collisionSystem.resolveEnemyPlatforms(this, platforms);
        }
    };

    this.takeDamage = function(amount) {
        if (this.invulnerableTimer > 0) return false;
        this.health -= amount;
        this.invulnerableTimer = 15;
        if (window.AudioManager) window.AudioManager.playHit();
        if (window.ParticleSystem) window.ParticleSystem.spawnSparks(this.x + this.width / 2, this.y + this.height / 2, 8, '#f59e0b');

        if (this.health <= 0) {
            this.isDead = true;
            if (window.ParticleSystem) window.ParticleSystem.spawnSparks(this.x + this.width / 2, this.y + this.height / 2, 16, '#4efce4');
        }
        return true;
    };

    this.draw = function(ctx, camera) {
        if (this.isDead) return;

        const screenX = this.x - camera.x;
        const screenY = this.y - camera.y;

        // Culling
        if (screenX < -100 || screenX > camera.viewportWidth + 100) return;

        ctx.save();
        ctx.translate(screenX + this.width / 2, screenY + this.height);

        if (!this.facingRight) ctx.scale(-1, 1);

        if (this.invulnerableTimer > 0) ctx.globalAlpha = 0.5;

        if (this.type === 'patrol') {
            // Forest Moss Creature
            ctx.fillStyle = '#14532d';
            ctx.beginPath();
            ctx.ellipse(0, -18, 18, 16, 0, 0, Math.PI * 2);
            ctx.fill();

            // Spikes on back
            ctx.fillStyle = '#22c55e';
            ctx.beginPath();
            ctx.moveTo(-10, -32);
            ctx.lineTo(-4, -40);
            ctx.lineTo(2, -32);
            ctx.fill();

            // Eyes
            ctx.fillStyle = '#f59e0b';
            ctx.beginPath();
            ctx.arc(8, -20, 3.5, 0, Math.PI * 2);
            ctx.fill();
        } else if (this.type === 'flyer') {
            // Canopy Moth / Bat
            ctx.fillStyle = '#0284c7';
            ctx.beginPath();
            ctx.arc(0, -15, 10, 0, Math.PI * 2);
            ctx.fill();

            // Translucent Wings
            const wingAngle = Math.sin(this.animFrame * 3) * 0.4;
            ctx.fillStyle = 'rgba(56, 189, 248, 0.6)';

            ctx.save();
            ctx.rotate(-wingAngle);
            ctx.beginPath();
            ctx.ellipse(-14, -22, 16, 8, -0.4, 0, Math.PI * 2);
            ctx.fill();
            ctx.restore();

            ctx.save();
            ctx.rotate(wingAngle);
            ctx.beginPath();
            ctx.ellipse(14, -22, 16, 8, 0.4, 0, Math.PI * 2);
            ctx.fill();
            ctx.restore();

            // Glowing Eye
            ctx.fillStyle = '#38bdf8';
            ctx.shadowColor = '#38bdf8';
            ctx.shadowBlur = 8;
            ctx.beginPath();
            ctx.arc(4, -15, 3, 0, Math.PI * 2);
            ctx.fill();
        } else if (this.type === 'shadow') {
            // Shadow Stalker
            ctx.fillStyle = this.isAggro ? '#881337' : '#0f172a';
            ctx.beginPath();
            ctx.moveTo(-16, 0);
            ctx.lineTo(-12, -45);
            ctx.lineTo(0, -50);
            ctx.lineTo(12, -45);
            ctx.lineTo(16, 0);
            ctx.fill();

            // Red Fiery Eyes
            ctx.fillStyle = '#f43f5e';
            ctx.shadowColor = '#f43f5e';
            ctx.shadowBlur = 12;
            ctx.beginPath();
            ctx.arc(6, -38, 4, 0, Math.PI * 2);
            ctx.fill();
        }

        ctx.restore();
    };
};
