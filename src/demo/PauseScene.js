import { Scene, Entity, Transform, Script } from '../quantum/QuantumEngine.js';

/**
 * PauseScene - Overlay scene shown when game is paused.
 */
export class PauseScene extends Scene {
  constructor() {
    super('Pause');
  }

  onEnter(data = {}) {
    this.returnScene = data.returnScene || 'Gameplay';
    this.clearEntities();

    const uiEntity = new Entity('PauseUI');
    uiEntity.layer = 'ui';
    uiEntity.addComponent(new Transform());
    uiEntity.addComponent(
      new Script((dt) => {
        if (this.engine.input.isActionJustPressed('pause')) {
          this.engine.switchScene(this.returnScene);
        }
      })
    );

    uiEntity.addComponent({
      render: (ctx) => {
        const w = ctx.canvas.width;
        const h = ctx.canvas.height;

        // Semi-transparent backdrop overlay
        ctx.fillStyle = 'rgba(15, 23, 42, 0.75)';
        ctx.fillRect(0, 0, w, h);

        // Pause Panel Card
        ctx.save();
        ctx.textAlign = 'center';
        ctx.fillStyle = '#1e293b';
        ctx.strokeStyle = '#6366f1';
        ctx.lineWidth = 2;
        ctx.roundRect ? ctx.roundRect(w / 2 - 180, h / 2 - 100, 360, 200, 12) : ctx.fillRect(w / 2 - 180, h / 2 - 100, 360, 200);
        ctx.fill();
        ctx.stroke();

        ctx.fillStyle = '#f8fafc';
        ctx.font = 'bold 36px "Segoe UI", sans-serif';
        ctx.fillText('GAME PAUSED', w / 2, h / 2 - 30);

        ctx.fillStyle = '#94a3b8';
        ctx.font = '18px "Segoe UI", sans-serif';
        ctx.fillText('Press P or ESC to Resume', w / 2, h / 2 + 30);
        ctx.restore();
      }
    });

    this.addEntity(uiEntity);
  }
}
