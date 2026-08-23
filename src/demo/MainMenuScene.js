import { Scene, Entity, Transform, Script } from '../quantum/QuantumEngine.js';

/**
 * MainMenuScene - Displays start menu with options to launch game.
 */
export class MainMenuScene extends Scene {
  constructor() {
    super('MainMenu');
    this.blinkTimer = 0;
  }

  onEnter() {
    this.clearEntities();

    // UI Menu Entity
    const uiMenu = new Entity('MainMenuUI');
    uiMenu.layer = 'ui';
    uiMenu.addComponent(new Transform());
    uiMenu.addComponent(
      new Script((dt) => {
        this.blinkTimer += dt * 3;

        // Check input for game start
        if (
          this.engine.input.isActionJustPressed('action') ||
          this.engine.input.mouse.isPressed
        ) {
          this.engine.assets.playSynthesizedSound('coin');
          this.engine.switchScene('Gameplay');
        }
      })
    );

    // Dynamic custom UI rendering logic attached to entity component
    uiMenu.addComponent({
      render: (ctx) => {
        const w = ctx.canvas.width;
        const h = ctx.canvas.height;

        // Dark background gradient
        const grad = ctx.createLinearGradient(0, 0, w, h);
        grad.addColorStop(0, '#0f172a');
        grad.addColorStop(1, '#1e1b4b');
        ctx.fillStyle = grad;
        ctx.fillRect(0, 0, w, h);

        // Title text with glow
        ctx.save();
        ctx.textAlign = 'center';
        ctx.shadowColor = '#6366f1';
        ctx.shadowBlur = 20;
        ctx.font = 'bold 52px "Segoe UI", sans-serif';
        ctx.fillStyle = '#f8fafc';
        ctx.fillText('QUANTUM ENGINE 2D', w / 2, h / 2 - 60);

        ctx.shadowBlur = 0;
        ctx.font = '20px "Segoe UI", sans-serif';
        ctx.fillStyle = '#94a3b8';
        ctx.fillText('A Modular, High-Performance 2D Web Engine', w / 2, h / 2 - 10);

        // Press start blinking prompt
        const alpha = Math.abs(Math.sin(this.blinkTimer));
        ctx.fillStyle = `rgba(99, 102, 241, ${alpha})`;
        ctx.font = 'bold 24px "Segoe UI", sans-serif';
        ctx.fillText('PRESS SPACE, ENTER OR CLICK TO START', w / 2, h / 2 + 70);

        // Controls info box
        ctx.fillStyle = '#1e293b';
        ctx.lineWidth = 1;
        ctx.strokeStyle = '#334155';
        ctx.roundRect ? ctx.roundRect(w / 2 - 250, h / 2 + 120, 500, 90, 8) : ctx.fillRect(w / 2 - 250, h / 2 + 120, 500, 90);
        ctx.fill();
        ctx.stroke();

        ctx.fillStyle = '#cbd5e1';
        ctx.font = '14px "Segoe UI", sans-serif';
        ctx.fillText('Controls:', w / 2, h / 2 + 145);
        ctx.fillText('WASD / Arrows: Move  |  Space: Dash  |  P / Esc: Pause', w / 2, h / 2 + 175);

        ctx.restore();
      }
    });

    this.addEntity(uiMenu);
  }
}
