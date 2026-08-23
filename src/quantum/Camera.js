/**
 * Camera - World viewport camera supporting target tracking, damping/smoothing, bounds clamping, and zooming.
 */
export class Camera {
  /**
   * @param {number} width - Viewport width
   * @param {number} height - Viewport height
   */
  constructor(width, height) {
    this.x = 0;
    this.y = 0;
    this.viewportWidth = width;
    this.viewportHeight = height;
    this.zoom = 1.0;
    this.target = null; // Entity or Transform to follow
    this.lerpSpeed = 0.1; // Smooth camera movement (0..1)

    // World boundaries clamping (optional)
    this.bounds = null; // { left, top, right, bottom }
  }

  /**
   * Set world bounds for camera clamping.
   */
  setBounds(left, top, right, bottom) {
    this.bounds = { left, top, right, bottom };
  }

  /**
   * Set target object with x, y properties to follow.
   */
  follow(target) {
    this.target = target;
  }

  /**
   * Update camera position to follow target with smoothing.
   */
  update(dt) {
    if (!this.target) return;

    let targetX = this.target.x;
    let targetY = this.target.y;

    // Center camera on target
    let desiredX = targetX - (this.viewportWidth / 2) / this.zoom;
    let desiredY = targetY - (this.viewportHeight / 2) / this.zoom;

    // Linear interpolation for smooth follow
    this.x += (desiredX - this.x) * (this.lerpSpeed * (dt * 60));
    this.y += (desiredY - this.y) * (this.lerpSpeed * (dt * 60));

    // Clamp camera position within world bounds
    if (this.bounds) {
      const halfViewportW = (this.viewportWidth / 2) / this.zoom;
      const halfViewportH = (this.viewportHeight / 2) / this.zoom;

      const minX = this.bounds.left;
      const maxX = this.bounds.right - (this.viewportWidth / this.zoom);
      const minY = this.bounds.top;
      const maxY = this.bounds.bottom - (this.viewportHeight / this.zoom);

      if (maxX >= minX) {
        this.x = Math.max(minX, Math.min(this.x, maxX));
      } else {
        this.x = (this.bounds.left + this.bounds.right) / 2 - halfViewportW;
      }

      if (maxY >= minY) {
        this.y = Math.max(minY, Math.min(this.y, maxY));
      } else {
        this.y = (this.bounds.top + this.bounds.bottom) / 2 - halfViewportH;
      }
    }
  }

  /**
   * Convert world coordinates to screen viewport coordinates.
   */
  worldToScreen(worldX, worldY) {
    return {
      x: (worldX - this.x) * this.zoom,
      y: (worldY - this.y) * this.zoom
    };
  }

  /**
   * Convert screen viewport coordinates to world coordinates.
   */
  screenToWorld(screenX, screenY) {
    return {
      x: (screenX / this.zoom) + this.x,
      y: (screenY / this.zoom) + this.y
    };
  }
}
