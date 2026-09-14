/* Camera Tracking & Screen Shake System */
class Camera {
    constructor(viewportWidth, viewportHeight) {
        this.x = 0;
        this.y = 0;
        this.width = viewportWidth;
        this.height = viewportHeight;

        this.levelWidth = viewportWidth;
        this.levelHeight = viewportHeight;

        this.smoothness = 0.08;
        this.deadzone = { x: 40, y: 30 };

        this.shakeDuration = 0;
        this.shakeIntensity = 0;
        this.shakeOffset = { x: 0, y: 0 };
    }

    resize(viewportWidth, viewportHeight) {
        this.width = viewportWidth;
        this.height = viewportHeight;
    }

    setLevelBounds(levelWidth, levelHeight) {
        this.levelWidth = Math.max(levelWidth, this.width);
        this.levelHeight = Math.max(levelHeight, this.height);
    }

    follow(target, dt) {
        if (!target) return;

        // Center on target
        const targetX = target.x + target.width / 2 - this.width / 2;
        const targetY = target.y + target.height / 2 - this.height / 2;

        // Smooth Lerp
        this.x += (targetX - this.x) * (this.smoothness * (dt * 60));
        this.y += (targetY - this.y) * (this.smoothness * (dt * 60));

        // Clamp camera bounds within level dimensions
        this.x = Math.max(0, Math.min(this.x, this.levelWidth - this.width));
        this.y = Math.max(0, Math.min(this.y, this.levelHeight - this.height));

        // Update Screen Shake
        if (this.shakeDuration > 0) {
            this.shakeDuration -= dt;
            this.shakeOffset.x = (Math.random() - 0.5) * 2 * this.shakeIntensity;
            this.shakeOffset.y = (Math.random() - 0.5) * 2 * this.shakeIntensity;
        } else {
            this.shakeOffset.x = 0;
            this.shakeOffset.y = 0;
        }
    }

    shake(intensity = 8, duration = 0.3) {
        this.shakeIntensity = intensity;
        this.shakeDuration = duration;
    }

    getRenderOffset() {
        return {
            x: Math.round(this.x + this.shakeOffset.x),
            y: Math.round(this.y + this.shakeOffset.y)
        };
    }
}

window.Camera = Camera;
