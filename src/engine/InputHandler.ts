import { InputState } from '../types/game';

export class InputHandler {
  public state: InputState = {
    left: false,
    right: false,
    jump: false,
    attack: false,
    pause: false,
    restart: false,
    jumpPressed: false,
    attackPressed: false,
    pausePressed: false,
    restartPressed: false,
  };

  private prevJump = false;
  private prevAttack = false;
  private prevPause = false;
  private prevRestart = false;

  constructor() {
    this.initKeyboardListeners();
    this.initTouchListeners();
  }

  private initKeyboardListeners(): void {
    window.addEventListener('keydown', (e: KeyboardEvent) => {
      // Prevent default scrolling for game controls
      if (['Space', 'ArrowUp', 'ArrowDown', 'ArrowLeft', 'ArrowRight', 'KeyW', 'KeyA', 'KeyS', 'KeyD', 'KeyJ', 'KeyX', 'KeyF'].includes(e.code)) {
        e.preventDefault();
      }

      switch (e.code) {
        case 'ArrowLeft':
        case 'KeyA':
          this.state.left = true;
          break;
        case 'ArrowRight':
        case 'KeyD':
          this.state.right = true;
          break;
        case 'ArrowUp':
        case 'KeyW':
        case 'Space':
          this.state.jump = true;
          break;
        case 'KeyJ':
        case 'KeyX':
        case 'KeyF':
          this.state.attack = true;
          break;
        case 'KeyP':
        case 'Escape':
          this.state.pause = true;
          break;
        case 'KeyR':
          this.state.restart = true;
          break;
      }
    });

    window.addEventListener('keyup', (e: KeyboardEvent) => {
      switch (e.code) {
        case 'ArrowLeft':
        case 'KeyA':
          this.state.left = false;
          break;
        case 'ArrowRight':
        case 'KeyD':
          this.state.right = false;
          break;
        case 'ArrowUp':
        case 'KeyW':
        case 'Space':
          this.state.jump = false;
          break;
        case 'KeyJ':
        case 'KeyX':
        case 'KeyF':
          this.state.attack = false;
          break;
        case 'KeyP':
        case 'Escape':
          this.state.pause = false;
          break;
        case 'KeyR':
          this.state.restart = false;
          break;
      }
    });
  }

  private initTouchListeners(): void {
    const bindBtn = (id: string, action: keyof InputState) => {
      const btn = document.getElementById(id);
      if (!btn) return;

      const setAction = (val: boolean) => {
        (this.state[action] as boolean) = val;
      };

      btn.addEventListener('touchstart', (e) => {
        e.preventDefault();
        setAction(true);
      }, { passive: false });

      btn.addEventListener('touchend', (e) => {
        e.preventDefault();
        setAction(false);
      }, { passive: false });

      btn.addEventListener('mousedown', () => setAction(true));
      btn.addEventListener('mouseup', () => setAction(false));
      btn.addEventListener('mouseleave', () => setAction(false));
    };

    bindBtn('btn-left', 'left');
    bindBtn('btn-right', 'right');
    bindBtn('btn-jump', 'jump');
    bindBtn('btn-attack', 'attack');
  }

  public update(): void {
    // Edge detection for triggers
    this.state.jumpPressed = this.state.jump && !this.prevJump;
    this.state.attackPressed = this.state.attack && !this.prevAttack;
    this.state.pausePressed = this.state.pause && !this.prevPause;
    this.state.restartPressed = this.state.restart && !this.prevRestart;

    this.prevJump = this.state.jump;
    this.prevAttack = this.state.attack;
    this.prevPause = this.state.pause;
    this.prevRestart = this.state.restart;
  }

  public reset(): void {
    this.state.left = false;
    this.state.right = false;
    this.state.jump = false;
    this.state.attack = false;
    this.state.pause = false;
    this.state.restart = false;
    this.state.jumpPressed = false;
    this.state.attackPressed = false;
    this.state.pausePressed = false;
    this.state.restartPressed = false;
    this.prevJump = false;
    this.prevAttack = false;
    this.prevPause = false;
    this.prevRestart = false;
  }
}
