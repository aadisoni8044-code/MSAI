/* Canvas Vector Character Renderer for Player Adventurer */
class CharacterRenderer {
    static drawPlayer(ctx, player, offset) {
        const x = Math.round(player.x - offset.x);
        const y = Math.round(player.y - offset.y);
        const width = player.width;
        const height = player.height;
        const facingLeft = player.facing === 'left';

        ctx.save();
        ctx.translate(x + width / 2, y + height / 2);

        if (facingLeft) {
            ctx.scale(-1, 1);
        }

        const animTime = Date.now() * 0.008;

        // Flash red when hurt
        if (player.hurtTimer > 0 && Math.floor(Date.now() / 50) % 2 === 0) {
            ctx.filter = 'brightness(2) sepia(1) hue-rotate(-50deg) saturate(5)';
        }

        // Ghost trail when dashing
        if (player.isDashing) {
            ctx.globalAlpha = 0.5;
            ctx.fillStyle = '#3fe0d0';
            ctx.beginPath();
            ctx.ellipse(0, 0, width / 2 + 6, height / 2 + 4, 0, 0, Math.PI * 2);
            ctx.fill();
            ctx.globalAlpha = 1.0;
        }

        // Draw Cape / Hood
        ctx.fillStyle = '#114b5f';
        ctx.beginPath();
        const capeWave = player.isMoving ? Math.sin(animTime * 2) * 6 : Math.sin(animTime) * 2;
        ctx.moveTo(-6, -10);
        ctx.quadraticCurveTo(-18 - capeWave, 0, -12 - capeWave, height / 2 - 2);
        ctx.lineTo(-4, height / 2 - 6);
        ctx.fill();

        // Draw Tunic Body
        ctx.fillStyle = '#e8d8c8'; // Creamy adventurer tunic
        ctx.beginPath();
        ctx.roundRect(-8, -6, 16, 20, 4);
        ctx.fill();

        // Draw Belt
        ctx.fillStyle = '#4a2e1d';
        ctx.fillRect(-8, 4, 16, 3);
        ctx.fillStyle = '#f0be4d';
        ctx.fillRect(-2, 3, 4, 5);

        // Legs & Boots
        const legAnim = player.isMoving ? Math.sin(animTime * 3) * 6 : 0;
        ctx.fillStyle = '#2c3e50';
        // Left Leg
        ctx.fillRect(-6, 14, 4, 8 + legAnim);
        // Right Leg
        ctx.fillRect(2, 14, 4, 8 - legAnim);

        // Cute Bone/Skull Mask Head (matching image reference)
        const headY = -14 + (player.isCrouching ? 4 : Math.sin(animTime) * 1.5);
        ctx.fillStyle = '#f4efea'; // Off-white mask color
        ctx.beginPath();
        ctx.ellipse(0, headY, 12, 10, 0, 0, Math.PI * 2);
        ctx.fill();

        // Mask Beak / Horn details
        ctx.beginPath();
        ctx.moveTo(4, headY - 2);
        ctx.lineTo(16, headY + 2);
        ctx.lineTo(6, headY + 6);
        ctx.closePath();
        ctx.fill();

        // Eye socket (dark teal glow)
        ctx.fillStyle = '#071015';
        ctx.beginPath();
        ctx.ellipse(4, headY - 2, 3, 4, 0.2, 0, Math.PI * 2);
        ctx.fill();

        // Ethereal Eye Glowing Pupil
        ctx.fillStyle = '#3fe0d0';
        ctx.beginPath();
        ctx.arc(5, headY - 2, 1.5, 0, Math.PI * 2);
        ctx.fill();

        // Draw Sword Attack / Arm
        const armX = 2;
        const armY = headY + 8;

        if (player.isAttacking) {
            ctx.save();
            ctx.translate(armX, armY);
            const attackAngle = (1 - player.attackTimer / player.attackDuration) * Math.PI - Math.PI / 4;
            ctx.rotate(attackAngle);

            // Arm
            ctx.fillStyle = '#e8d8c8';
            ctx.fillRect(0, -2, 10, 4);

            // Sword Blade
            ctx.fillStyle = '#e2f1f8';
            ctx.beginPath();
            ctx.moveTo(8, -3);
            ctx.lineTo(28, 0);
            ctx.lineTo(8, 3);
            ctx.closePath();
            ctx.fill();

            // Sword Hilt & Guard
            ctx.fillStyle = '#f0be4d';
            ctx.fillRect(6, -5, 3, 10);

            // Slash Effect Arc
            ctx.strokeStyle = 'rgba(63, 224, 208, 0.8)';
            ctx.lineWidth = 3;
            ctx.beginPath();
            ctx.arc(0, 0, 32, -Math.PI / 3, Math.PI / 3);
            ctx.stroke();

            ctx.restore();
        } else {
            // Idle Arm holding sword down
            ctx.fillStyle = '#e8d8c8';
            ctx.fillRect(armX - 2, armY - 2, 6, 8);
            ctx.fillStyle = '#95a5a6';
            ctx.fillRect(armX + 2, armY + 2, 2, 12);
        }

        ctx.restore();
    }
}

window.CharacterRenderer = CharacterRenderer;
