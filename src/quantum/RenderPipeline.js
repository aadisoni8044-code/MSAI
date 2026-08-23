import { Camera } from './Camera.js';

/**
 * RenderPipeline - Multi-layer rendering pipeline with camera transformation, depth sorting, and UI overlay support.
 */
export class RenderPipeline {
  /**
   * @param {HTMLCanvasElement} canvas
   */
  constructor(canvas) {
    this.canvas = canvas;
    this.ctx = canvas.getContext('2d');
    this.camera = new Camera(canvas.width, canvas.height);

    // Layer definitions in render order
    this.layers = ['background', 'gameplay', 'ui'];
  }

  /**
   * Main render execution method.
   * @param {import('./Entity.js').Entity[]} entities
   * @param {number} alpha - Interpolation factor (0..1)
   * @param {number} [fps=0] - FPS metric display option
   */
  render(entities, alpha = 1, fps = 0) {
    const ctx = this.ctx;
    const width = this.canvas.width;
    const height = this.canvas.height;

    // Clear canvas frame
    ctx.clearRect(0, 0, width, height);

    // Filter active entities
    const activeEntities = entities.filter((e) => e.active);

    // Render each layer sequentially
    for (const layerName of this.layers) {
      const layerEntities = activeEntities.filter((e) => (e.layer || 'gameplay') === layerName);

      // Sort layer entities by zIndex
      layerEntities.sort((a, b) => (a.zIndex || 0) - (b.zIndex || 0));

      if (layerName === 'ui') {
        // UI layer renders directly in screen space without camera translation
        for (const entity of layerEntities) {
          entity.render(ctx, alpha);
        }
      } else {
        // World space layers (background & gameplay) apply camera transform
        ctx.save();
        ctx.scale(this.camera.zoom, this.camera.zoom);
        ctx.translate(-this.camera.x, -this.camera.y);

        for (const entity of layerEntities) {
          entity.render(ctx, alpha);
        }

        ctx.restore();
      }
    }
  }

  /**
   * Resize canvas viewport and notify camera.
   */
  resize(width, height) {
    this.canvas.width = width;
    this.canvas.height = height;
    this.camera.viewportWidth = width;
    this.camera.viewportHeight = height;
  }
}
