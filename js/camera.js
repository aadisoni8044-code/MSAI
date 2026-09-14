/* SYLVAN WHISPERS - SMOOTH CAMERA & 5-LAYER PARALLAX CONTROLLER */
window.Camera = (function() {
    let x = 0;
    let y = 0;
    let targetX = 0;
    let targetY = 0;

    let viewportWidth = 1280;
    let viewportHeight = 720;
    let worldWidth = 3200;
    let worldHeight = 900;

    let lerpSpeed = 0.08;

    // Screen Shake state
    let shakeDuration = 0;
    let shakeIntensity = 0;
    let shakeOffsetX = 0;
    let shakeOffsetY = 0;

    function init(vw, vh, ww, wh) {
        viewportWidth = vw;
        viewportHeight = vh;
        worldWidth = ww;
        worldHeight = wh;
        x = 0;
        y = 0;
    }

    function setWorldSize(ww, wh) {
        worldWidth = ww;
        worldHeight = wh;
    }

    function setViewportSize(vw, vh) {
        viewportWidth = vw;
        viewportHeight = vh;
    }

    function follow(player, deltaTime = 1) {
        // Center on player with lookahead
        const lookahead = player.facingRight ? 60 : -60;
        targetX = player.x + player.width / 2 - viewportWidth / 2 + lookahead;
        targetY = player.y + player.height / 2 - viewportHeight / 2 - 40;

        // Clamp target position to world bounds
        targetX = Math.max(0, Math.min(worldWidth - viewportWidth, targetX));
        targetY = Math.max(0, Math.min(worldHeight - viewportHeight, targetY));

        // Smooth Lerp
        x += (targetX - x) * lerpSpeed;
        y += (targetY - y) * lerpSpeed;

        // Screen Shake calculation
        if (shakeDuration > 0) {
            shakeOffsetX = (Math.random() - 0.5) * shakeIntensity;
            shakeOffsetY = (Math.random() - 0.5) * shakeIntensity;
            shakeDuration--;
        } else {
            shakeOffsetX = 0;
            shakeOffsetY = 0;
        }
    }

    function triggerShake(intensity = 8, duration = 12) {
        shakeIntensity = intensity;
        shakeDuration = duration;
    }

    function getRenderX() {
        return Math.floor(x + shakeOffsetX);
    }

    function getRenderY() {
        return Math.floor(y + shakeOffsetY);
    }

    return {
        init,
        setWorldSize,
        setViewportSize,
        follow,
        triggerShake,
        getRenderX,
        getRenderY,
        get x() { return x; },
        get y() { return y; },
        get viewportWidth() { return viewportWidth; },
        get viewportHeight() { return viewportHeight; },
        get worldWidth() { return worldWidth; },
        get worldHeight() { return worldHeight; }
    };
})();
