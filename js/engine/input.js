/* Keyboard & Input Management System */
class InputHandler {
    constructor() {
        this.keys = {};
        this.actions = {
            left: false,
            right: false,
            up: false,
            down: false,
            jump: false,
            dash: false,
            attack: false,
            interact: false,
            pause: false
        };

        this.keyJustPressed = {};
        this.prevActions = {};

        this.initListeners();
    }

    initListeners() {
        window.addEventListener('keydown', (e) => {
            if (e.repeat) return;
            this.handleKey(e.code, true);
        });

        window.addEventListener('keyup', (e) => {
            this.handleKey(e.code, false);
        });

        // Click to attack on Canvas
        window.addEventListener('mousedown', (e) => {
            if (e.target.tagName === 'CANVAS' && e.button === 0) {
                this.setVirtualAction('attack', true);
            }
        });

        window.addEventListener('mouseup', (e) => {
            if (e.button === 0) {
                this.setVirtualAction('attack', false);
            }
        });
    }

    handleKey(code, isPressed) {
        switch (code) {
            case 'KeyA':
            case 'ArrowLeft':
                this.actions.left = isPressed;
                break;
            case 'KeyD':
            case 'ArrowRight':
                this.actions.right = isPressed;
                break;
            case 'KeyW':
            case 'ArrowUp':
            case 'Space':
                this.actions.jump = isPressed;
                this.actions.up = isPressed;
                break;
            case 'KeyS':
            case 'ArrowDown':
                this.actions.down = isPressed;
                break;
            case 'ShiftLeft':
            case 'ShiftRight':
                this.actions.dash = isPressed;
                break;
            case 'KeyJ':
                this.actions.attack = isPressed;
                break;
            case 'KeyE':
                this.actions.interact = isPressed;
                break;
            case 'Escape':
                if (isPressed) this.actions.pause = true;
                break;
        }
    }

    setVirtualAction(action, isPressed) {
        if (this.actions.hasOwnProperty(action)) {
            this.actions[action] = isPressed;
        }
    }

    update() {
        // Detect single frame press events
        for (const action in this.actions) {
            this.keyJustPressed[action] = this.actions[action] && !this.prevActions[action];
            this.prevActions[action] = this.actions[action];
        }
    }

    isPressed(action) {
        return !!this.actions[action];
    }

    isJustPressed(action) {
        return !!this.keyJustPressed[action];
    }
}

window.inputHandler = new InputHandler();
