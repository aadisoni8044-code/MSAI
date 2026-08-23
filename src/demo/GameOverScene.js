import { Scene, Entity, Transform, Script } from '../quantum/QuantumEngine.js';

/**
 * GameOverScene - Screen shown upon stage victory or defeat.
 */
export class GameOverScene extends Scene {
  constructor() {
    super('GameOver');
    this.score = 0;
    this.isWin = true;
  }

  onEnter(data = {}) {
    this.score = data.score || 0;
    this.isWin = data.isWin !== undefined ? data.isWin : true;
    this.clearEntities();

    const uiEntity = new Entity('GameOverUI');
    uiEntity.layer = 'ui';
    uiEntity.addComponent(new Transform());
    uiEntity.addComponent(
      new Script((dt) => {
        if (
          this.engine.input.isActionJustPressed('action') ||
          this.engine.input.isActionJustPressed('restart') ||
          this.engine.input.mouse.isPressed
        ) {
          this.engine.assets.playSynthesizedSound('coin');
          this.engine.switchScene('Gameplay');
        }
      })
    );

    uiEntity.addComponent({
      render: (ctx) => {
        const w = ctx.canvas.width;
        const h = ctx.canvas.height;

        // Background
        ctx.fillStyle = '#0f172a';
        ctx.fillRect(0, 0, w, h);

        ctx.save();
        ctx.textAlign = 'center';

        if (this.isWin) {
          ctx.shadowColor = '#4ade80';
          ctx.shadowBlur = 25;
          ctx.font = 'bold 54px "Segoe UI", sans-serif';
          ctx.fillStyle = '#4ade80';
          ctx.fillText('STAGE CLEARED!', w / 2, h / 2 - 60);
        } else {
          ctx.shadowColor = '#f87171';
          ctx.shadowBlur = 25;
          ctx.font = 'bold 54px "Segoe UI", sans-serif';
          ctx.fillStyle = '#f87171';
          ctx.fillText('GAME OVER', w / 2, h / 2 - 60);
        }

        ctx.shadowBlur = 0;
        ctx.font = 'bold 28px "Segoe UI", sans-serif';
        ctx.fillStyle = '#f8fafc';
        ctx.fillText(`FINAL SCORE: ${this.score}`, w / 2, h / 2 + 10);

        ctx.font = '20px "Segoe UI", sans-serif';
        ctx.fillStyle = '#818cf8';
        ctx.fillText('Press SPACE, R, ENTER, or Click to Play Again', w / 2, h / 2 + 80);

        ctx.restore();
      }
    });

    this.addEntity(uiEntity);
  }
}
