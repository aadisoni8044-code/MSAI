/* Mobile Touch Controls Integration */
class MobileControls {
    constructor() {
        this.container = document.getElementById('mobile-controls');
        this.touchLeft = document.getElementById('touch-left');
        this.touchRight = document.getElementById('touch-right');
        this.touchCrouch = document.getElementById('touch-crouch');
        this.touchJump = document.getElementById('touch-jump');
        this.touchAttack = document.getElementById('touch-attack');
        this.touchDash = document.getElementById('touch-dash');
        this.touchInteract = document.getElementById('touch-interact');

        this.isTouchDevice = 'ontouchstart' in window || navigator.maxTouchPoints > 0;
        this.init();
    }

    init() {
        this.bindTouchButton(this.touchLeft, 'left');
        this.bindTouchButton(this.touchRight, 'right');
        this.bindTouchButton(this.touchCrouch, 'down');
        this.bindTouchButton(this.touchJump, 'jump');
        this.bindTouchButton(this.touchAttack, 'attack');
        this.bindTouchButton(this.touchDash, 'dash');
        this.bindTouchButton(this.touchInteract, 'interact');

        this.updateVisibility();
    }

    bindTouchButton(btn, action) {
        if (!btn) return;

        const startAction = (e) => {
            e.preventDefault();
            window.inputHandler.setVirtualAction(action, true);
        };

        const endAction = (e) => {
            e.preventDefault();
            window.inputHandler.setVirtualAction(action, false);
        };

        btn.addEventListener('touchstart', startAction, { passive: false });
        btn.addEventListener('touchend', endAction, { passive: false });
        btn.addEventListener('touchcancel', endAction, { passive: false });

        btn.addEventListener('mousedown', startAction);
        btn.addEventListener('mouseup', endAction);
        btn.addEventListener('mouseleave', endAction);
    }

    updateVisibility() {
        const forceMobile = window.saveSystem.data.settings.forceMobileControls;
        if (this.isTouchDevice || forceMobile) {
            this.container.classList.remove('hidden', 'desktop-hidden');
        } else {
            this.container.classList.add('desktop-hidden');
        }
    }
}

window.mobileControls = new MobileControls();
