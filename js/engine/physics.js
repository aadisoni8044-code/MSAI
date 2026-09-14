/* Physics Constants & Helper Utilities */
class Physics {
    static GRAVITY = 1200; // px/s^2
    static TERMINAL_VELOCITY = 800; // px/s
    static FRICTION = 0.82;
    static AIR_RESISTANCE = 0.95;

    static applyGravity(entity, dt) {
        if (!entity.grounded) {
            entity.vy += Physics.GRAVITY * dt;
            if (entity.vy > Physics.TERMINAL_VELOCITY) {
                entity.vy = Physics.TERMINAL_VELOCITY;
            }
        }
    }

    static applyFriction(entity) {
        if (entity.grounded) {
            entity.vx *= Physics.FRICTION;
        } else {
            entity.vx *= Physics.AIR_RESISTANCE;
        }

        if (Math.abs(entity.vx) < 0.1) {
            entity.vx = 0;
        }
    }
}

window.Physics = Physics;
