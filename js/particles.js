/* SYLVAN WHISPERS - HIGH PERFORMANCE PARTICLE SYSTEM */
window.ParticleSystem = (function() {
    let particles = [];
    let fogParticles = [];
    let quality = 'high'; // 'high', 'medium', 'low'

    function setQuality(lvl) {
        quality = lvl;
    }

    function spawnDust(x, y, count = 6) {
        if (quality === 'low') count = 2;
        for (let i = 0; i < count; i++) {
            particles.push({
                x: x + (Math.random() - 0.5) * 16,
                y: y + Math.random() * 4,
                vx: (Math.random() - 0.5) * 1.5,
                vy: -Math.random() * 1.2 - 0.5,
                size: Math.random() * 3 + 2,
                color: 'rgba(120, 160, 150, ',
                alpha: 0.8,
                decay: 0.03 + Math.random() * 0.02,
                type: 'dust'
            });
        }
    }

    function spawnSparks(x, y, count = 10, color = '#4efce4') {
        if (quality === 'low') count = 4;
        for (let i = 0; i < count; i++) {
            const angle = Math.random() * Math.PI * 2;
            const speed = Math.random() * 4 + 1.5;
            particles.push({
                x,
                y,
                vx: Math.cos(angle) * speed,
                vy: Math.sin(angle) * speed,
                size: Math.random() * 3 + 1.5,
                color,
                alpha: 1,
                decay: 0.04 + Math.random() * 0.03,
                type: 'spark'
            });
        }
    }

    function spawnFireflies(worldWidth, worldHeight, count = 40) {
        if (quality === 'medium') count = 20;
        if (quality === 'low') count = 8;
        particles = particles.filter(p => p.type !== 'firefly');

        for (let i = 0; i < count; i++) {
            particles.push({
                x: Math.random() * worldWidth,
                y: Math.random() * worldHeight,
                vx: (Math.random() - 0.5) * 0.4,
                vy: (Math.random() - 0.5) * 0.4,
                size: Math.random() * 2.5 + 1,
                color: '#4efce4',
                alpha: Math.random(),
                pulseSpeed: 0.015 + Math.random() * 0.02,
                type: 'firefly',
                worldW: worldWidth,
                worldH: worldHeight
            });
        }
    }

    function spawnFallingLeaves(worldWidth, worldHeight, count = 25) {
        if (quality === 'medium') count = 12;
        if (quality === 'low') count = 5;

        for (let i = 0; i < count; i++) {
            particles.push({
                x: Math.random() * worldWidth,
                y: Math.random() * (worldHeight * 0.6),
                vx: Math.random() * 0.8 + 0.2,
                vy: Math.random() * 0.5 + 0.4,
                sway: Math.random() * Math.PI * 2,
                swaySpeed: 0.03 + Math.random() * 0.02,
                size: Math.random() * 4 + 2,
                color: Math.random() > 0.5 ? '#14b8a6' : '#0d9488',
                alpha: 0.7,
                type: 'leaf',
                worldW: worldWidth,
                worldH: worldHeight
            });
        }
    }

    function update() {
        for (let i = particles.length - 1; i >= 0; i--) {
            const p = particles[i];

            if (p.type === 'dust' || p.type === 'spark') {
                p.x += p.vx;
                p.y += p.vy;
                p.alpha -= p.decay;
                if (p.alpha <= 0) particles.splice(i, 1);
            } else if (p.type === 'firefly') {
                p.x += p.vx;
                p.y += p.vy;
                p.alpha += p.pulseSpeed;
                if (p.alpha > 1 || p.alpha < 0.2) p.pulseSpeed = -p.pulseSpeed;

                if (p.x < 0) p.x = p.worldW;
                if (p.x > p.worldW) p.x = 0;
                if (p.y < 0) p.y = p.worldH;
                if (p.y > p.worldH) p.y = 0;
            } else if (p.type === 'leaf') {
                p.sway += p.swaySpeed;
                p.x += Math.sin(p.sway) * 0.8 + p.vx;
                p.y += p.vy;

                if (p.y > p.worldH || p.x > p.worldW) {
                    p.y = -10;
                    p.x = Math.random() * p.worldW;
                }
            }
        }
    }

    function draw(ctx, camera) {
        ctx.save();
        particles.forEach(p => {
            const screenX = p.x - camera.x;
            const screenY = p.y - camera.y;

            // Offscreen culling check
            if (screenX < -50 || screenX > camera.viewportWidth + 50 ||
                screenY < -50 || screenY > camera.viewportHeight + 50) {
                return;
            }

            if (p.type === 'dust') {
                ctx.fillStyle = p.color + p.alpha + ')';
                ctx.beginPath();
                ctx.arc(screenX, screenY, p.size, 0, Math.PI * 2);
                ctx.fill();
            } else if (p.type === 'spark') {
                ctx.fillStyle = p.color;
                ctx.globalAlpha = p.alpha;
                ctx.shadowColor = p.color;
                ctx.shadowBlur = 8;
                ctx.beginPath();
                ctx.arc(screenX, screenY, p.size, 0, Math.PI * 2);
                ctx.fill();
            } else if (p.type === 'firefly') {
                ctx.fillStyle = p.color;
                ctx.globalAlpha = Math.max(0.1, Math.min(1, p.alpha));
                ctx.shadowColor = p.color;
                ctx.shadowBlur = 10;
                ctx.beginPath();
                ctx.arc(screenX, screenY, p.size, 0, Math.PI * 2);
                ctx.fill();
            } else if (p.type === 'leaf') {
                ctx.save();
                ctx.translate(screenX, screenY);
                ctx.rotate(p.sway);
                ctx.fillStyle = p.color;
                ctx.globalAlpha = p.alpha;
                ctx.beginPath();
                ctx.ellipse(0, 0, p.size, p.size * 0.5, 0, 0, Math.PI * 2);
                ctx.fill();
                ctx.restore();
            }
        });
        ctx.restore();
    }

    function clear() {
        particles = [];
    }

    return {
        setQuality,
        spawnDust,
        spawnSparks,
        spawnFireflies,
        spawnFallingLeaves,
        update,
        draw,
        clear
    };
})();
