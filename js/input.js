/* SYLVAN WHISPERS - UNIFIED INPUT CONTROLLER */
window.InputController = (function() {
    const keys = {};
    const touchState = {
        left: false,
        right: false,
        up: false,
        down: false,
        attack: false,
        interact: false,
        jump: false
    };

    let touchEnabled = false;

    function init() {
        // Keyboard event listeners
        window.addEventListener('keydown', (e) => {
            keys[e.code] = true;

            // Handle pause toggle hotkey directly if ESC or P is pressed
            if ((e.code === 'Escape' || e.code === 'KeyP') && window.GameEngine) {
                window.GameEngine.togglePause();
            }
        });

        window.addEventListener('keyup', (e) => {
            keys[e.code] = false;
        });

        // Touch control setup
        bindTouchControls();
    }

    function setTouchEnabled(enabled) {
        touchEnabled = enabled;
        const touchOverlay = document.getElementById('touch-controls');
        if (touchOverlay) {
            if (touchEnabled) {
                touchOverlay.classList.add('active');
            } else {
                touchOverlay.classList.remove('active');
            }
        }
    }

    function bindTouchControls() {
        const buttons = [
            { id: 'touch-left', key: 'left' },
            { id: 'touch-right', key: 'right' },
            { id: 'touch-crouch', key: 'down' },
            { id: 'touch-attack', key: 'attack' },
            { id: 'touch-jump', key: 'jump' },
            { id: 'touch-interact', key: 'interact' }
        ];

        buttons.forEach(btnInfo => {
            const btn = document.getElementById(btnInfo.id);
            if (!btn) return;

            const startAction = (e) => {
                e.preventDefault();
                touchState[btnInfo.key] = true;
            };

            const endAction = (e) => {
                e.preventDefault();
                touchState[btnInfo.key] = false;
            };

            btn.addEventListener('touchstart', startAction, { passive: false });
            btn.addEventListener('touchend', endAction, { passive: false });
            btn.addEventListener('mousedown', startAction);
            btn.addEventListener('mouseup', endAction);
            btn.addEventListener('mouseleave', endAction);
        });
    }

    // Input getters
    function isLeft() {
        return !!(keys['KeyA'] || keys['ArrowLeft'] || touchState.left);
    }

    function isRight() {
        return !!(keys['KeyD'] || keys['ArrowRight'] || touchState.right);
    }

    function isUp() {
        return !!(keys['KeyW'] || keys['ArrowUp'] || keys['Space'] || touchState.up || touchState.jump);
    }

    function isDown() {
        return !!(keys['KeyS'] || keys['ArrowDown'] || touchState.down);
    }

    function isRun() {
        return !!(keys['ShiftLeft'] || keys['ShiftRight']);
    }

    function isAttack() {
        return !!(keys['KeyJ'] || keys['KeyZ'] || touchState.attack);
    }

    function isInteract() {
        return !!(keys['KeyE'] || keys['KeyX'] || touchState.interact);
    }

    function isJumpPressed() {
        return !!(keys['Space'] || keys['KeyW'] || keys['ArrowUp'] || touchState.jump);
    }

    // Consume single frame press flags for actions like Jump or Attack
    const consumedKeys = {};

    function isKeyJustPressed(code, touchKey) {
        const pressed = keys[code] || (touchKey && touchState[touchKey]);
        if (pressed && !consumedKeys[code]) {
            consumedKeys[code] = true;
            return true;
        }
        if (!pressed) {
            consumedKeys[code] = false;
        }
        return false;
    }

    return {
        init,
        setTouchEnabled,
        isLeft,
        isRight,
        isUp,
        isDown,
        isRun,
        isAttack,
        isInteract,
        isJumpPressed,
        isKeyJustPressed
    };
})();
