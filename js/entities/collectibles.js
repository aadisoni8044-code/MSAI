/* Collectibles & Item Entities */
class Collectible {
    constructor(x, y, type) {
        this.x = x;
        this.y = y;
        this.width = 20;
        this.height = 20;
        this.type = type; // 'coin', 'crystal', 'health', 'energy', 'key'

        this.floatOffset = Math.random() * Math.PI * 2;
        this.collected = false;
    }

    getBounds() {
        return { x: this.x, y: this.y, width: this.width, height: this.height };
    }

    update(dt, player, level) {
        if (this.collected) return;

        this.floatOffset += dt * 3;

        // Check collection
        if (window.CollisionSystem.rectsOverlap(this.getBounds(), player.getBounds())) {
            this.collected = true;

            if (this.type === 'coin') {
                player.heal(0);
                level.collectedCoins = (level.collectedCoins || 0) + 1;
                window.saveSystem.addCollectibles(1, 0, 0);
                window.audioManager.playCollect('coin');
            } else if (this.type === 'crystal') {
                level.collectedCrystals = (level.collectedCrystals || 0) + 1;
                window.saveSystem.addCollectibles(0, 1, 0);
                window.audioManager.playCollect('crystal');
            } else if (this.type === 'health') {
                player.heal(30);
                window.audioManager.playCollect('crystal');
                window.hudManager.showToast('+30 HEALTH');
            } else if (this.type === 'energy') {
                player.restoreStamina(50);
                window.audioManager.playCollect('crystal');
                window.hudManager.showToast('+50 STAMINA');
            } else if (this.type === 'key') {
                level.collectedKeys = (level.collectedKeys || 0) + 1;
                window.saveSystem.addCollectibles(0, 0, 1);
                window.audioManager.playCollect('key');
                window.hudManager.showToast('ANCIENT KEY OBTAINED');
            }

            window.game.particles.emitBurst({
                x: this.x + 10,
                y: this.y + 10,
                color: this.type === 'crystal' ? '#3fe0d0' : '#f0be4d',
                size: 3
            }, 8);
        }
    }

    render(ctx, offset) {
        if (this.collected) return;

        const rx = Math.round(this.x - offset.x);
        const ry = Math.round(this.y + Math.sin(this.floatOffset) * 4 - offset.y);

        ctx.save();
        if (this.type === 'coin') {
            ctx.fillStyle = '#f0be4d';
            ctx.beginPath();
            ctx.arc(rx + 10, ry + 10, 8, 0, Math.PI * 2);
            ctx.fill();
            ctx.strokeStyle = '#fff';
            ctx.lineWidth = 1;
            ctx.stroke();
        } else if (this.type === 'crystal') {
            ctx.fillStyle = '#3fe0d0';
            ctx.beginPath();
            ctx.moveTo(rx + 10, ry);
            ctx.lineTo(rx + 18, ry + 10);
            ctx.lineTo(rx + 10, ry + 20);
            ctx.lineTo(rx + 2, ry + 10);
            ctx.closePath();
            ctx.fill();
        } else if (this.type === 'health') {
            ctx.fillStyle = '#e74c3c';
            ctx.beginPath();
            ctx.arc(rx + 10, ry + 10, 8, 0, Math.PI * 2);
            ctx.fill();
        } else if (this.type === 'energy') {
            ctx.fillStyle = '#f39c12';
            ctx.beginPath();
            ctx.arc(rx + 10, ry + 10, 8, 0, Math.PI * 2);
            ctx.fill();
        } else if (this.type === 'key') {
            ctx.fillStyle = '#f0be4d';
            ctx.fillRect(rx + 4, ry + 8, 12, 4);
            ctx.fillRect(rx + 14, ry + 4, 4, 12);
        }
        ctx.restore();
    }
}

class HiddenChest {
    constructor(x, y) {
        this.x = x;
        this.y = y;
        this.width = 36;
        this.height = 28;
        this.opened = false;
    }

    getBounds() {
        return { x: this.x, y: this.y, width: this.width, height: this.height };
    }

    update(dt, player, level) {
        if (this.opened) return;

        // Open if player interacts or attacks chest
        const attackHurtbox = player.getAttackHurtbox();
        const playerNear = window.CollisionSystem.rectsOverlap(this.getBounds(), player.getBounds());
        const isAttacked = attackHurtbox && window.CollisionSystem.rectsOverlap(this.getBounds(), attackHurtbox);
        const isInteracted = playerNear && window.inputHandler.isJustPressed('interact');

        if (isAttacked || isInteracted) {
            this.opened = true;
            window.audioManager.playVictory();
            window.hudManager.showToast('TREASURE CHEST OPENED!');

            // Spawn loot
            level.collectibles.push(new Collectible(this.x - 10, this.y - 20, 'crystal'));
            level.collectibles.push(new Collectible(this.x + 10, this.y - 20, 'coin'));
            level.collectibles.push(new Collectible(this.x + 30, this.y - 20, 'coin'));

            window.game.particles.emitBurst({
                x: this.x + 18,
                y: this.y + 14,
                color: '#f0be4d',
                size: 5
            }, 25);
        }
    }

    render(ctx, offset) {
        const rx = Math.round(this.x - offset.x);
        const ry = Math.round(this.y - offset.y);

        ctx.save();
        ctx.fillStyle = '#4a2e1d';
        ctx.fillRect(rx, ry + 8, 36, 20);

        // Chest Lid
        ctx.fillStyle = this.opened ? '#8a5a3c' : '#5a3a2c';
        if (this.opened) {
            ctx.fillRect(rx - 2, ry - 4, 40, 10);
        } else {
            ctx.fillRect(rx, ry, 36, 10);
            ctx.fillStyle = '#f0be4d';
            ctx.fillRect(rx + 16, ry + 8, 4, 6);
        }
        ctx.restore();
    }
}

window.Collectible = Collectible;
window.HiddenChest = HiddenChest;
