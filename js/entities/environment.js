/* Environmental Interactive Objects & Hazards */
class Checkpoint {
    constructor(x, y, id) {
        this.x = x;
        this.y = y;
        this.width = 32;
        this.height = 48;
        this.id = id;
        this.active = false;
    }

    getBounds() {
        return { x: this.x, y: this.y, width: this.width, height: this.height };
    }

    update(dt, player, level) {
        if (window.CollisionSystem.rectsOverlap(this.getBounds(), player.getBounds())) {
            if (!this.active) {
                this.active = true;
                player.heal(100); // Fully heal on checkpoint
                window.saveSystem.saveCheckpoint(this.id);
                window.audioManager.playVictory();
                window.hudManager.showToast('CHECKPOINT ACTIVATED');

                window.game.particles.emitBurst({
                    x: this.x + 16,
                    y: this.y + 24,
                    color: '#3fe0d0',
                    size: 4
                }, 20);
            }
        }
    }

    render(ctx, offset) {
        const rx = Math.round(this.x - offset.x);
        const ry = Math.round(this.y - offset.y);

        ctx.save();
        // Stone Pillar
        ctx.fillStyle = '#1f383e';
        ctx.fillRect(rx + 8, ry + 12, 16, 36);

        // Glowing Runes
        ctx.fillStyle = this.active ? '#3fe0d0' : '#0a1a1e';
        ctx.fillRect(rx + 12, ry + 20, 8, 8);
        ctx.fillRect(rx + 12, ry + 32, 8, 8);

        if (this.active) {
            ctx.shadowColor = '#3fe0d0';
            ctx.shadowBlur = 12;
            ctx.fillStyle = '#ffffff';
            ctx.beginPath();
            ctx.arc(rx + 16, ry + 8, 6, 0, Math.PI * 2);
            ctx.fill();
        }

        ctx.restore();
    }
}

class DoorPortal {
    constructor(x, y, targetLevelIndex) {
        this.x = x;
        this.y = y;
        this.width = 40;
        this.height = 64;
        this.targetLevelIndex = targetLevelIndex;
    }

    getBounds() {
        return { x: this.x, y: this.y, width: this.width, height: this.height };
    }

    update(dt, player, level) {
        const playerBounds = player.getBounds();
        const doorBounds = this.getBounds();

        if (window.CollisionSystem.rectsOverlap(doorBounds, playerBounds)) {
            window.hudManager.showInteractPrompt('PRESS E / TAP USE TO ENTER');

            if (window.inputHandler.isJustPressed('interact')) {
                // Check if level transition requires keys
                if (level.requiredKeys && (level.collectedKeys || 0) < level.requiredKeys) {
                    window.hudManager.showToast(`LOCKED! REQUIRED KEYS: ${level.collectedKeys || 0}/${level.requiredKeys}`);
                    window.audioManager.playHit();
                    return;
                }

                window.audioManager.playVictory();
                window.game.triggerVictory();
            }
        }
    }

    render(ctx, offset) {
        const rx = Math.round(this.x - offset.x);
        const ry = Math.round(this.y - offset.y);

        ctx.save();
        // Archway
        ctx.fillStyle = '#0f383e';
        ctx.fillRect(rx, ry, 40, 64);

        // Portal Swirl
        const time = Date.now() * 0.003;
        const portalGlow = ctx.createRadialGradient(rx + 20, ry + 32, 2, rx + 20, ry + 32, 24);
        portalGlow.addColorStop(0, '#ffffff');
        portalGlow.addColorStop(0.5, '#3fe0d0');
        portalGlow.addColorStop(1, '#195b63');

        ctx.fillStyle = portalGlow;
        ctx.beginPath();
        ctx.ellipse(rx + 20, ry + 32, 14 + Math.sin(time) * 2, 24 + Math.cos(time) * 2, 0, 0, Math.PI * 2);
        ctx.fill();

        ctx.restore();
    }
}

window.Checkpoint = Checkpoint;
window.DoorPortal = DoorPortal;
