/* Collision System & Tilemap Physics Solver */
class CollisionSystem {
    static rectsOverlap(a, b) {
        return (
            a.x < b.x + b.width &&
            a.x + a.width > b.x &&
            a.y < b.y + b.height &&
            a.y + a.height > b.y
        );
    }

    static resolveTilemapCollision(entity, level, dt) {
        if (!level || !level.tiles) return;

        const tileSize = level.tileSize || 32;

        // Move horizontally
        entity.x += entity.vx * dt;
        let bounds = entity.getBounds ? entity.getBounds() : { x: entity.x, y: entity.y, width: entity.width, height: entity.height };

        let startTileX = Math.floor(bounds.x / tileSize);
        let endTileX = Math.floor((bounds.x + bounds.width) / tileSize);
        let startTileY = Math.floor(bounds.y / tileSize);
        let endTileY = Math.floor((bounds.y + bounds.height) / tileSize);

        for (let ty = startTileY; ty <= endTileY; ty++) {
            for (let tx = startTileX; tx <= endTileX; tx++) {
                const tile = level.getTile(tx, ty);
                if (tile && tile.solid) {
                    const tileRect = { x: tx * tileSize, y: ty * tileSize, width: tileSize, height: tileSize };
                    if (CollisionSystem.rectsOverlap(bounds, tileRect)) {
                        if (entity.vx > 0) {
                            entity.x = tileRect.x - bounds.width - (entity.boundsOffset ? entity.boundsOffset.x : 0);
                            entity.vx = 0;
                        } else if (entity.vx < 0) {
                            entity.x = tileRect.x + tileSize - (entity.boundsOffset ? entity.boundsOffset.x : 0);
                            entity.vx = 0;
                        }
                        bounds = entity.getBounds ? entity.getBounds() : { x: entity.x, y: entity.y, width: entity.width, height: entity.height };
                    }
                }
            }
        }

        // Move vertically
        entity.grounded = false;
        entity.y += entity.vy * dt;
        bounds = entity.getBounds ? entity.getBounds() : { x: entity.x, y: entity.y, width: entity.width, height: entity.height };

        startTileX = Math.floor(bounds.x / tileSize);
        endTileX = Math.floor((bounds.x + bounds.width) / tileSize);
        startTileY = Math.floor(bounds.y / tileSize);
        endTileY = Math.floor((bounds.y + bounds.height) / tileSize);

        for (let ty = startTileY; ty <= endTileY; ty++) {
            for (let tx = startTileX; tx <= endTileX; tx++) {
                const tile = level.getTile(tx, ty);
                if (tile) {
                    const tileRect = { x: tx * tileSize, y: ty * tileSize, width: tileSize, height: tileSize };

                    // Solid Block
                    if (tile.solid) {
                        if (CollisionSystem.rectsOverlap(bounds, tileRect)) {
                            if (entity.vy > 0) {
                                entity.y = tileRect.y - bounds.height - (entity.boundsOffset ? entity.boundsOffset.y : 0);
                                entity.vy = 0;
                                entity.grounded = true;
                            } else if (entity.vy < 0) {
                                entity.y = tileRect.y + tileSize - (entity.boundsOffset ? entity.boundsOffset.y : 0);
                                entity.vy = 0;
                            }
                            bounds = entity.getBounds ? entity.getBounds() : { x: entity.x, y: entity.y, width: entity.width, height: entity.height };
                        }
                    }
                    // One-Way Platform
                    else if (tile.oneWay) {
                        const previousFootY = bounds.y + bounds.height - entity.vy * dt;
                        if (
                            entity.vy >= 0 &&
                            previousFootY <= tileRect.y + 4 &&
                            CollisionSystem.rectsOverlap(bounds, tileRect)
                        ) {
                            entity.y = tileRect.y - bounds.height - (entity.boundsOffset ? entity.boundsOffset.y : 0);
                            entity.vy = 0;
                            entity.grounded = true;
                            bounds = entity.getBounds ? entity.getBounds() : { x: entity.x, y: entity.y, width: entity.width, height: entity.height };
                        }
                    }
                    // Deadly Hazard (Thorns/Spikes)
                    else if (tile.hazard && CollisionSystem.rectsOverlap(bounds, tileRect)) {
                        if (entity.takeDamage) {
                            entity.takeDamage(25, (tx * tileSize + tileSize / 2) > (bounds.x + bounds.width / 2) ? -1 : 1);
                        }
                    }
                }
            }
        }
    }
}

window.CollisionSystem = CollisionSystem;
