/* SYLVAN WHISPERS - PHYSICS & COLLISION SYSTEM */
window.CollisionSystem = (function() {

    function checkAABB(rect1, rect2) {
        return (
            rect1.x < rect2.x + rect2.width &&
            rect1.x + rect1.width > rect2.x &&
            rect1.y < rect2.y + rect2.height &&
            rect1.y + rect1.height > rect2.y
        );
    }

    function resolvePlayerPlatforms(player, platforms) {
        player.isGrounded = false;

        for (let i = 0; i < platforms.length; i++) {
            const plat = platforms[i];

            // Platform box vs Player box check
            if (
                player.x < plat.x + plat.width &&
                player.x + player.width > plat.x &&
                player.y < plat.y + plat.height &&
                player.y + player.height > plat.y
            ) {
                // One-way platform check
                if (plat.isOneWay) {
                    // Only land if moving downward and player's feet were above or near top of platform
                    if (player.vy >= 0 && (player.y + player.height - player.vy) <= plat.y + 10) {
                        player.y = plat.y - player.height;
                        player.vy = 0;
                        player.isGrounded = true;
                    }
                    continue;
                }

                // Standard solid platform collision resolution
                const overlapX1 = (player.x + player.width) - plat.x;
                const overlapX2 = (plat.x + plat.width) - player.x;
                const overlapY1 = (player.y + player.height) - plat.y;
                const overlapY2 = (plat.y + plat.height) - player.y;

                const minOverlapX = Math.min(overlapX1, overlapX2);
                const minOverlapY = Math.min(overlapY1, overlapY2);

                if (minOverlapY < minOverlapX) {
                    if (overlapY1 < overlapY2 && player.vy >= 0) {
                        // Collision from top
                        player.y = plat.y - player.height;
                        player.vy = 0;
                        player.isGrounded = true;
                    } else if (overlapY2 < overlapY1 && player.vy < 0) {
                        // Collision from bottom
                        player.y = plat.y + plat.height;
                        player.vy = 0;
                    }
                } else {
                    if (overlapX1 < overlapX2 && player.vx > 0) {
                        // Collision from left
                        player.x = plat.x - player.width;
                        player.vx = 0;
                    } else if (overlapX2 < overlapX1 && player.vx < 0) {
                        // Collision from right
                        player.x = plat.x + plat.width;
                        player.vx = 0;
                    }
                }
            }
        }
    }

    function resolveEnemyPlatforms(enemy, platforms) {
        enemy.isGrounded = false;
        for (let i = 0; i < platforms.length; i++) {
            const plat = platforms[i];

            if (
                enemy.x < plat.x + plat.width &&
                enemy.x + enemy.width > plat.x &&
                enemy.y < plat.y + plat.height &&
                enemy.y + enemy.height > plat.y
            ) {
                if (plat.isOneWay) {
                    if (enemy.vy >= 0 && (enemy.y + enemy.height - enemy.vy) <= plat.y + 8) {
                        enemy.y = plat.y - enemy.height;
                        enemy.vy = 0;
                        enemy.isGrounded = true;
                    }
                    continue;
                }

                const overlapY1 = (enemy.y + enemy.height) - plat.y;
                const overlapY2 = (plat.y + plat.height) - enemy.y;

                if (overlapY1 < overlapY2 && enemy.vy >= 0) {
                    enemy.y = plat.y - enemy.height;
                    enemy.vy = 0;
                    enemy.isGrounded = true;
                }
            }
        }
    }

    return {
        checkAABB,
        resolvePlayerPlatforms,
        resolveEnemyPlatforms
    };
})();
