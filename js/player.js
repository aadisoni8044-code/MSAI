/* SYLVAN WHISPERS - PLAYER CHARACTER ENGINE */
window.Player = function(x, y) {
    this.x = x;
    this.y = y;
    this.width = 36;
    this.height = 56;

    this.vx = 0;
    this.vy = 0;
    this.walkSpeed = 3.5;
    this.runSpeed = 5.8;
    this.jumpForce = -11.5;
    this.gravity = 0.55;

    this.isGrounded = false;
    this.canDoubleJump = true;
    this.facingRight = true;
    this.isCrouching = false;
    this.isAttacking = false;
    this.attackTimer = 0;
    this.attackDuration = 18; // frames
    this.attackHitbox = null;

    this.health = 100;
    this.maxHealth = 100;
    this.stamina = 100;
    this.maxStamina = 100;

    this.invulnerableTimer = 0;
    this.animFrame = 0;
    this.state = 'idle'; // 'idle', 'walk', 'run', 'jump', 'fall', 'crouch', 'attack', 'hurt'

    this.update = function(input, levelManager) {
        if (this.invulnerableTimer > 0) this.invulnerableTimer--;

        // Regenerate stamina when not sprinting
        if (!input.isRun() || Math.abs(this.vx) < 0.1) {
            this.stamina = Math.min(this.maxStamina, this.stamina + 0.4);
        }

        // Crouch Check
        if (input.isDown() && this.isGrounded) {
            this.isCrouching = true;
            this.height = 38;
            this.vx *= 0.7;
        } else {
            this.isCrouching = false;
            this.height = 56;
        }

        // Movement Speed determination
        let speed = this.walkSpeed;
        if (input.isRun() && this.stamina > 5 && !this.isCrouching) {
            speed = this.runSpeed;
            if (Math.abs(this.vx) > 0.5 && this.isGrounded) {
                this.stamina -= 0.6;
            }
        }

        // Horizontal input
        if (input.isLeft()) {
            this.vx = -speed;
            this.facingRight = false;
        } else if (input.isRight()) {
            this.vx = speed;
            this.facingRight = true;
        } else {
            this.vx *= 0.7; // Friction
        }

        // Jump & Double Jump
        if (input.isKeyJustPressed('Space', 'jump') || input.isKeyJustPressed('KeyW', 'up') || input.isKeyJustPressed('ArrowUp', 'up')) {
            if (this.isGrounded) {
                this.vy = this.jumpForce;
                this.isGrounded = false;
                this.canDoubleJump = true;
                if (window.AudioManager) window.AudioManager.playJump();
                if (window.ParticleSystem) window.ParticleSystem.spawnDust(this.x + this.width / 2, this.y + this.height);
            } else if (this.canDoubleJump) {
                this.vy = this.jumpForce * 0.9;
                this.canDoubleJump = false;
                if (window.AudioManager) window.AudioManager.playJump();
                if (window.ParticleSystem) window.ParticleSystem.spawnSparks(this.x + this.width / 2, this.y + this.height, 8, '#4efce4');
            }
        }

        // Attack Logic
        if ((input.isKeyJustPressed('KeyJ', 'attack') || input.isKeyJustPressed('KeyZ', 'attack')) && !this.isAttacking) {
            this.isAttacking = true;
            this.attackTimer = this.attackDuration;
            if (window.AudioManager) window.AudioManager.playSlash();

            const attackW = 50;
            const attackH = 40;
            const attackX = this.facingRight ? this.x + this.width : this.x - attackW;
            const attackY = this.y + 10;
            this.attackHitbox = { x: attackX, y: attackY, width: attackW, height: attackH };
        }

        if (this.isAttacking) {
            this.attackTimer--;
            if (this.attackTimer <= 0) {
                this.isAttacking = false;
                this.attackHitbox = null;
            }
        }

        // Apply Gravity
        this.vy += this.gravity;
        if (this.vy > 14) this.vy = 14; // Terminal velocity

        // Update positions
        this.x += this.vx;
        this.y += this.vy;

        // Reset grounded reset for collision pass
        if (this.isGrounded) {
            this.canDoubleJump = true;
        }

        // State Determination
        this.animFrame += 0.15;
        if (this.isAttacking) this.state = 'attack';
        else if (!this.isGrounded && this.vy < 0) this.state = 'jump';
        else if (!this.isGrounded && this.vy >= 0) this.state = 'fall';
        else if (this.isCrouching) this.state = 'crouch';
        else if (Math.abs(this.vx) > 3.8) this.state = 'run';
        else if (Math.abs(this.vx) > 0.5) this.state = 'walk';
        else this.state = 'idle';
    };

    this.takeDamage = function(amount) {
        if (this.invulnerableTimer > 0) return false;
        this.health = Math.max(0, this.health - amount);
        this.invulnerableTimer = 45; // ~0.75s invulnerability
        if (window.AudioManager) window.AudioManager.playDamage();
        if (window.Camera) window.Camera.triggerShake(10, 15);
        if (window.ParticleSystem) window.ParticleSystem.spawnSparks(this.x + this.width / 2, this.y + this.height / 2, 12, '#f43f5e');
        return true;
    };

    this.draw = function(ctx, camera) {
        const screenX = this.x - camera.x;
        const screenY = this.y - camera.y;

        ctx.save();
        ctx.translate(screenX + this.width / 2, screenY + this.height);

        // Flashing when hurt
        if (this.invulnerableTimer % 6 > 3) {
            ctx.globalAlpha = 0.4;
        }

        if (!this.facingRight) {
            ctx.scale(-1, 1);
        }

        // Draw character procedural graphics based on the reference masked explorer
        // Body / Cloak
        ctx.fillStyle = '#1b3238';
        ctx.fillRect(-12, -42, 24, 34);

        // Legs animation
        const legOffset = (this.state === 'walk' || this.state === 'run') ? Math.sin(this.animFrame * 2) * 8 : 0;
        ctx.fillStyle = '#0d282e';
        ctx.fillRect(-10, -12, 8, 12 + legOffset);
        ctx.fillRect(2, -12, 8, 12 - legOffset);

        // Explorer Mask / Skull Head (Matches reference visual style)
        ctx.fillStyle = '#e2e8f0';
        ctx.beginPath();
        ctx.ellipse(0, -44, 13, 15, 0, 0, Math.PI * 2);
        ctx.fill();

        // Beak / Mask snout
        ctx.beginPath();
        ctx.moveTo(4, -44);
        ctx.lineTo(18, -40);
        ctx.lineTo(4, -36);
        ctx.fill();

        // Mask Eye Hole
        ctx.fillStyle = '#0f172a';
        ctx.beginPath();
        ctx.arc(4, -45, 3.5, 0, Math.PI * 2);
        ctx.fill();

        // Glowing Eye Dot
        ctx.fillStyle = '#4efce4';
        ctx.beginPath();
        ctx.arc(5, -45, 1.5, 0, Math.PI * 2);
        ctx.fill();

        // Spirit Blade / Sword
        ctx.save();
        if (this.isAttacking) {
            ctx.rotate(-0.8 + Math.sin(this.attackTimer * 0.3) * 1.5);
        }
        ctx.fillStyle = '#cbd5e1';
        ctx.fillRect(8, -32, 22, 5);
        ctx.fillStyle = '#4efce4';
        ctx.shadowColor = '#4efce4';
        ctx.shadowBlur = 10;
        ctx.fillRect(8, -31, 22, 3);
        ctx.restore();

        // Slash Trail Effect when attacking
        if (this.isAttacking) {
            ctx.save();
            ctx.fillStyle = 'rgba(78, 252, 228, 0.4)';
            ctx.shadowColor = '#4efce4';
            ctx.shadowBlur = 15;
            ctx.beginPath();
            ctx.arc(10, -25, 38, -0.6, 0.8);
            ctx.lineTo(10, -25);
            ctx.fill();
            ctx.restore();
        }

        ctx.restore();
    };
};
