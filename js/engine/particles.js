/* Performance Particle System with Object Pooling */
class Particle {
    constructor() {
        this.reset();
    }

    reset() {
        this.active = false;
        this.x = 0;
        this.y = 0;
        this.vx = 0;
        this.vy = 0;
        this.size = 2;
        this.color = '#ffffff';
        this.alpha = 1;
        this.life = 1;
        this.maxLife = 1;
        this.gravity = 0;
        this.shape = 'circle'; // 'circle', 'square', 'spark', 'firefly', 'mist'
    }

    spawn(opts) {
        this.active = true;
        this.x = opts.x || 0;
        this.y = opts.y || 0;
        this.vx = opts.vx || 0;
        this.vy = opts.vy || 0;
        this.size = opts.size || 2;
        this.color = opts.color || '#3fe0d0';
        this.alpha = opts.alpha !== undefined ? opts.alpha : 1;
        this.maxLife = opts.maxLife || 1;
        this.life = this.maxLife;
        this.gravity = opts.gravity || 0;
        this.shape = opts.shape || 'circle';
    }

    update(dt) {
        if (!this.active) return;

        this.life -= dt;
        if (this.life <= 0) {
            this.active = false;
            return;
        }

        this.vy += this.gravity * dt;
        this.x += this.vx * dt;
        this.y += this.vy * dt;
    }

    render(ctx, cameraOffset) {
        if (!this.active) return;

        const renderX = this.x - cameraOffset.x;
        const renderY = this.y - cameraOffset.y;

        const progress = this.life / this.maxLife;
        const currentAlpha = this.alpha * progress;

        ctx.save();
        ctx.globalAlpha = Math.max(0, currentAlpha);

        if (this.shape === 'firefly') {
            const glow = ctx.createRadialGradient(renderX, renderY, 0, renderX, renderY, this.size * 2);
            glow.addColorStop(0, '#ffffff');
            glow.addColorStop(0.4, this.color);
            glow.addColorStop(1, 'transparent');
            ctx.fillStyle = glow;
            ctx.beginPath();
            ctx.arc(renderX, renderY, this.size * 2, 0, Math.PI * 2);
            ctx.fill();
        } else if (this.shape === 'spark') {
            ctx.strokeStyle = this.color;
            ctx.lineWidth = this.size;
            ctx.beginPath();
            ctx.moveTo(renderX, renderY);
            ctx.lineTo(renderX - this.vx * 0.05, renderY - this.vy * 0.05);
            ctx.stroke();
        } else {
            ctx.fillStyle = this.color;
            ctx.beginPath();
            ctx.arc(renderX, renderY, this.size, 0, Math.PI * 2);
            ctx.fill();
        }

        ctx.restore();
    }
}

class ParticleSystem {
    constructor(poolSize = 400) {
        this.pool = Array.from({ length: poolSize }, () => new Particle());
    }

    getParticle() {
        for (let p of this.pool) {
            if (!p.active) return p;
        }
        return null;
    }

    emit(opts) {
        const p = this.getParticle();
        if (p) p.spawn(opts);
    }

    emitBurst(opts, count = 10) {
        for (let i = 0; i < count; i++) {
            const angle = Math.random() * Math.PI * 2;
            const speed = (opts.speed || 100) * (0.3 + Math.random() * 0.7);
            this.emit({
                x: opts.x,
                y: opts.y,
                vx: Math.cos(angle) * speed,
                vy: Math.sin(angle) * speed,
                color: opts.color || '#3fe0d0',
                size: (opts.size || 3) * (0.5 + Math.random() * 0.5),
                maxLife: (opts.maxLife || 0.6) * (0.6 + Math.random() * 0.8),
                shape: opts.shape || 'circle',
                gravity: opts.gravity || 0
            });
        }
    }

    update(dt) {
        for (let p of this.pool) {
            if (p.active) p.update(dt);
        }
    }

    render(ctx, cameraOffset) {
        for (let p of this.pool) {
            if (p.active) p.render(ctx, cameraOffset);
        }
    }
}

window.ParticleSystem = ParticleSystem;
