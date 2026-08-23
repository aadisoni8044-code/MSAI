import { ShapeSkin } from '../types';
import { drawShape } from '../engine/shapeRenderer';

export class ShapeCanvasPreview {
  public element: HTMLCanvasElement;
  private ctx: CanvasRenderingContext2D;
  private animFrameId: number | null = null;
  private skin: ShapeSkin;
  private width: number;
  private height: number;
  private size: number;
  private interactive: boolean;
  private startTime: number;

  constructor(skin: ShapeSkin, width = 120, height = 90, size = 38, interactive = true) {
    this.skin = skin;
    this.width = width;
    this.height = height;
    this.size = size;
    this.interactive = interactive;
    this.startTime = performance.now();

    this.element = document.createElement('canvas');
    this.element.width = width;
    this.element.height = height;
    this.element.className = 'max-w-full pointer-events-none drop-shadow-md block';

    const context = this.element.getContext('2d');
    if (!context) throw new Error('Could not get 2d context for preview canvas');
    this.ctx = context;

    this.startAnimation();
  }

  public setSkin(skin: ShapeSkin) {
    this.skin = skin;
  }

  public startAnimation() {
    const render = (now: number) => {
      const elapsed = (now - this.startTime) / 1000;
      this.ctx.clearRect(0, 0, this.width, this.height);

      this.ctx.save();
      this.ctx.translate(this.width / 2, this.height / 2);

      // Subtle float or rotation based on animationType
      if (this.skin.animationType === 'spin') {
        this.ctx.rotate(elapsed * 1.2);
      } else if (this.skin.animationType === 'wobble') {
        this.ctx.rotate(Math.sin(elapsed * 3) * 0.15);
      } else if (this.skin.animationType === 'pulse') {
        const scale = Math.sin(elapsed * 4) * 0.05 + 1;
        this.ctx.scale(scale, scale);
      } else if (this.skin.animationType === 'streamline') {
        this.ctx.translate(0, Math.sin(elapsed * 3) * 2.5);
      }

      drawShape(this.ctx, this.skin, this.size, elapsed, false);

      this.ctx.restore();

      if (this.interactive) {
        this.animFrameId = requestAnimationFrame(render);
      }
    };

    if (this.animFrameId !== null) {
      cancelAnimationFrame(this.animFrameId);
    }
    this.animFrameId = requestAnimationFrame(render);
  }

  public destroy() {
    if (this.animFrameId !== null) {
      cancelAnimationFrame(this.animFrameId);
      this.animFrameId = null;
    }
  }
}
