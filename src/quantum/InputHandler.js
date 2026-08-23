/**
 * InputHandler - Unified input manager for Keyboard, Mouse, and Touch events.
 * Supports action remapping, key status tracking, mouse/touch position calculations, and axis polling.
 */
export class InputHandler {
  /**
   * @param {HTMLElement|HTMLCanvasElement} [targetElement=window]
   */
  constructor(targetElement = window) {
    this.target = targetElement;

    // Direct key state mapping (Code -> boolean)
    this.keys = new Map();
    // Key press frame detection (Code -> boolean)
    this.keysPressed = new Map();
    this.keysReleased = new Map();

    // Action mappings (Action Name -> Array of key codes)
    this.bindings = new Map([
      ['move_up', ['KeyW', 'ArrowUp']],
      ['move_down', ['KeyS', 'ArrowDown']],
      ['move_left', ['KeyA', 'ArrowLeft']],
      ['move_right', ['KeyD', 'ArrowRight']],
      ['dash', ['Space', 'ShiftLeft', 'ShiftRight']],
      ['pause', ['KeyP', 'Escape']],
      ['restart', ['KeyR']],
      ['action', ['Enter', 'KeyE', 'Space']]
    ]);

    // Pointer (Mouse / Touch) state
    this.mouse = {
      x: 0,
      y: 0,
      canvasX: 0,
      canvasY: 0,
      isDown: false,
      isPressed: false,
      isReleased: false,
      button: -1
    };

    this.touches = [];

    // Bind listener methods
    this._onKeyDown = this._onKeyDown.bind(this);
    this._onKeyUp = this._onKeyUp.bind(this);
    this._onMouseMove = this._onMouseMove.bind(this);
    this._onMouseDown = this._onMouseDown.bind(this);
    this._onMouseUp = this._onMouseUp.bind(this);
    this._onTouchStart = this._onTouchStart.bind(this);
    this._onTouchMove = this._onTouchMove.bind(this);
    this._onTouchEnd = this._onTouchEnd.bind(this);

    this.attach();
  }

  /**
   * Attach event listeners to DOM target.
   */
  attach() {
    window.addEventListener('keydown', this._onKeyDown);
    window.addEventListener('keyup', this._onKeyUp);

    const elem = this.target;
    elem.addEventListener('mousemove', this._onMouseMove);
    elem.addEventListener('mousedown', this._onMouseDown);
    elem.addEventListener('mouseup', this._onMouseUp);
    elem.addEventListener('touchstart', this._onTouchStart, { passive: false });
    elem.addEventListener('touchmove', this._onTouchMove, { passive: false });
    elem.addEventListener('touchend', this._onTouchEnd);
    elem.addEventListener('touchcancel', this._onTouchEnd);
  }

  /**
   * Detach event listeners.
   */
  detach() {
    window.removeEventListener('keydown', this._onKeyDown);
    window.removeEventListener('keyup', this._onKeyUp);

    const elem = this.target;
    elem.removeEventListener('mousemove', this._onMouseMove);
    elem.removeEventListener('mousedown', this._onMouseDown);
    elem.removeEventListener('mouseup', this._onMouseUp);
    elem.removeEventListener('touchstart', this._onTouchStart);
    elem.removeEventListener('touchmove', this._onTouchMove);
    elem.removeEventListener('touchend', this._onTouchEnd);
    elem.removeEventListener('touchcancel', this._onTouchEnd);
  }

  /**
   * Reset single-frame press/release flags. Should be called at the end of each game tick.
   */
  update() {
    this.keysPressed.clear();
    this.keysReleased.clear();
    this.mouse.isPressed = false;
    this.mouse.isReleased = false;
  }

  /**
   * Remap action to a list of key codes.
   * @param {string} actionName
   * @param {string[]} keyCodes
   */
  bindAction(actionName, keyCodes) {
    this.bindings.set(actionName, keyCodes);
  }

  /**
   * Check if action is currently held down.
   * @param {string} actionName
   * @returns {boolean}
   */
  isActionActive(actionName) {
    const codes = this.bindings.get(actionName);
    if (!codes) return false;
    return codes.some((code) => this.keys.get(code) === true);
  }

  /**
   * Check if action was just pressed this frame.
   * @param {string} actionName
   * @returns {boolean}
   */
  isActionJustPressed(actionName) {
    const codes = this.bindings.get(actionName);
    if (!codes) return false;
    return codes.some((code) => this.keysPressed.get(code) === true);
  }

  /**
   * Check if specific raw key code is held.
   * @param {string} code
   */
  isKeyDown(code) {
    return this.keys.get(code) === true;
  }

  /**
   * Get 2D axis vector [-1..1] for movement directions.
   * @returns {{x: number, y: number}}
   */
  getAxis() {
    let x = 0;
    let y = 0;

    if (this.isActionActive('move_left')) x -= 1;
    if (this.isActionActive('move_right')) x += 1;
    if (this.isActionActive('move_up')) y -= 1;
    if (this.isActionActive('move_down')) y += 1;

    // Normalize diagonal movement
    if (x !== 0 && y !== 0) {
      const length = Math.sqrt(x * x + y * y);
      x /= length;
      y /= length;
    }

    return { x, y };
  }

  _onKeyDown(e) {
    // Prevent scrolling for game controls
    if (['Space', 'ArrowUp', 'ArrowDown', 'ArrowLeft', 'ArrowRight'].includes(e.code)) {
      if (e.target === document.body || e.target.tagName === 'CANVAS') {
        e.preventDefault();
      }
    }

    if (!this.keys.get(e.code)) {
      this.keysPressed.set(e.code, true);
    }
    this.keys.set(e.code, true);
  }

  _onKeyUp(e) {
    this.keys.set(e.code, false);
    this.keysReleased.set(e.code, true);
  }

  _updateMousePosition(e) {
    const rect = this.target.getBoundingClientRect ? this.target.getBoundingClientRect() : { left: 0, top: 0 };
    this.mouse.x = e.clientX;
    this.mouse.y = e.clientY;
    this.mouse.canvasX = e.clientX - rect.left;
    this.mouse.canvasY = e.clientY - rect.top;
  }

  _onMouseMove(e) {
    this._updateMousePosition(e);
  }

  _onMouseDown(e) {
    this._updateMousePosition(e);
    this.mouse.isDown = true;
    this.mouse.isPressed = true;
    this.mouse.button = e.button;
  }

  _onMouseUp(e) {
    this._updateMousePosition(e);
    this.mouse.isDown = false;
    this.mouse.isReleased = true;
  }

  _onTouchStart(e) {
    if (e.touches.length > 0) {
      const touch = e.touches[0];
      this._updateMousePosition(touch);
      this.mouse.isDown = true;
      this.mouse.isPressed = true;
    }
    this.touches = Array.from(e.touches);
  }

  _onTouchMove(e) {
    if (e.touches.length > 0) {
      const touch = e.touches[0];
      this._updateMousePosition(touch);
    }
    this.touches = Array.from(e.touches);
  }

  _onTouchEnd(e) {
    if (e.touches.length === 0) {
      this.mouse.isDown = false;
      this.mouse.isReleased = true;
    }
    this.touches = Array.from(e.touches);
  }
}
