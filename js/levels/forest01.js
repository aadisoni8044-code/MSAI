/* Level 01: Ancient Forest */
class Level01 {
    constructor() {
        this.name = "Ancient Forest";
        this.objective = "Traverse the dark woods and reach the Ruins entrance";
        this.tileSize = 32;
        this.cols = 100;
        this.rows = 20;
        this.width = this.cols * this.tileSize;
        this.height = this.rows * this.tileSize;

        this.spawnX = 100;
        this.spawnY = 450;

        this.parallax = new window.ParallaxBackground('forest');

        this.tiles = [];
        this.enemies = [];
        this.collectibles = [];
        this.checkpoints = [];
        this.portals = [];

        this.totalCrystals = 5;
        this.collectedCrystals = 0;
        this.collectedCoins = 0;

        this.buildMap();
    }

    getTile(x, y) {
        if (x < 0 || x >= this.cols || y < 0 || y >= this.rows) return null;
        return this.tiles[y * this.cols + x];
    }

    setTile(x, y, tile) {
        if (x >= 0 && x < this.cols && y >= 0 && y < this.rows) {
            this.tiles[y * this.cols + x] = tile;
        }
    }

    buildMap() {
        // Initialize blank map
        for (let i = 0; i < this.cols * this.rows; i++) {
            this.tiles.push({ solid: false });
        }

        // Ground floor with platforms
        for (let x = 0; x < this.cols; x++) {
            // Gap pits at x: 30..33 and 65..68
            if ((x >= 30 && x <= 33) || (x >= 65 && x <= 68)) continue;

            for (let y = 16; y < this.rows; y++) {
                this.setTile(x, y, { solid: true, type: 'grass' });
            }
        }

        // Floating Platforms
        const platforms = [
            { x: 12, y: 13, w: 5 },
            { x: 22, y: 11, w: 4 },
            { x: 29, y: 12, w: 6 },
            { x: 38, y: 13, w: 5 },
            { x: 48, y: 11, w: 6 },
            { x: 58, y: 13, w: 4 },
            { x: 64, y: 12, w: 6 },
            { x: 75, y: 12, w: 6 },
            { x: 86, y: 10, w: 5 }
        ];

        platforms.forEach(p => {
            for (let i = 0; i < p.w; i++) {
                this.setTile(p.x + i, p.y, { solid: true, type: 'platform' });
            }
        });

        // Hazards (Thorns)
        this.setTile(20, 15, { hazard: true });
        this.setTile(21, 15, { hazard: true });
        this.setTile(52, 15, { hazard: true });
        this.setTile(53, 15, { hazard: true });
    }

    initLevel(player, particles) {
        // Spawn Enemies
        this.enemies = [
            new window.ForestSlime(400, 480),
            new window.ForestSlime(700, 480),
            new window.ThornCreature(1000, 480),
            new window.FlyingSpirit(1300, 300),
            new window.ThornCreature(1800, 480),
            new window.ShadowBeast(2400, 480)
        ];

        // Spawn Collectibles
        this.collectibles = [
            new window.Collectible(200, 480, 'coin'),
            new window.Collectible(250, 480, 'coin'),
            new window.Collectible(420, 380, 'crystal'),
            new window.Collectible(720, 320, 'crystal'),
            new window.Collectible(1000, 360, 'health'),
            new window.Collectible(1560, 350, 'crystal'),
            new window.Collectible(2100, 360, 'crystal'),
            new window.Collectible(2760, 290, 'crystal'),
            new window.HiddenChest(1500, 480)
        ];

        // Checkpoints & Exit Door
        this.checkpoints = [
            new window.Checkpoint(1200, 464, 'cp1_1')
        ];

        this.portals = [
            new window.DoorPortal(3080, 448, 2)
        ];
    }

    update(dt, player) {
        // Ambient Fireflies
        if (Math.random() < 0.2) {
            window.game.particles.emit({
                x: window.game.camera.x + Math.random() * window.game.viewportWidth,
                y: window.game.camera.y + Math.random() * window.game.viewportHeight,
                vx: (Math.random() - 0.5) * 15,
                vy: (Math.random() - 0.5) * 15,
                color: '#3fe0d0',
                size: 2,
                maxLife: 3,
                shape: 'firefly'
            });
        }

        this.enemies.forEach(e => e.update(dt, player, this));
        this.collectibles.forEach(c => c.update(dt, player, this));
        this.checkpoints.forEach(cp => cp.update(dt, player, this));
        this.portals.forEach(p => p.update(dt, player, this));
    }

    renderBackground(ctx, offset, viewW, viewH) {
        this.parallax.render(ctx, offset, viewW, viewH, this.width, this.height);
    }

    renderWorld(ctx, offset) {
        // Tilemap Rendering
        const tileSize = this.tileSize;
        const startX = Math.max(0, Math.floor(offset.x / tileSize));
        const endX = Math.min(this.cols, Math.ceil((offset.x + window.game.viewportWidth) / tileSize));
        const startY = Math.max(0, Math.floor(offset.y / tileSize));
        const endY = Math.min(this.rows, Math.ceil((offset.y + window.game.viewportHeight) / tileSize));

        ctx.save();
        for (let y = startY; y < endY; y++) {
            for (let x = startX; x < endX; x++) {
                const tile = this.getTile(x, y);
                if (!tile) continue;

                const rx = Math.round(x * tileSize - offset.x);
                const ry = Math.round(y * tileSize - offset.y);

                if (tile.solid) {
                    // Mossy Ground
                    ctx.fillStyle = '#0f383e';
                    ctx.fillRect(rx, ry, tileSize, tileSize);

                    // Top Grass Blade detail
                    if (y === 0 || !this.getTile(x, y - 1)?.solid) {
                        ctx.fillStyle = '#3a7d44';
                        ctx.fillRect(rx, ry, tileSize, 6);
                        ctx.fillStyle = '#82d973';
                        ctx.fillRect(rx, ry, tileSize, 2);
                    }
                } else if (tile.hazard) {
                    ctx.fillStyle = '#e74c3c';
                    ctx.beginPath();
                    ctx.moveTo(rx, ry + tileSize);
                    ctx.lineTo(rx + tileSize / 2, ry);
                    ctx.lineTo(rx + tileSize, ry + tileSize);
                    ctx.fill();
                }
            }
        }
        ctx.restore();

        // Render Entities
        this.checkpoints.forEach(cp => cp.render(ctx, offset));
        this.portals.forEach(p => p.render(ctx, offset));
        this.collectibles.forEach(c => c.render(ctx, offset));
        this.enemies.forEach(e => e.render(ctx, offset));
    }

    renderForeground(ctx, offset, viewW, viewH) {
        this.parallax.renderForeground(ctx, offset, viewW, viewH);
    }
}

window.Level01 = Level01;
