/**
 * GameLoop - Core loop with fixed timestep update and decoupled render loop using requestAnimationFrame.
 */
export class GameLoop {
  /**
   * @param {Object} options
   * @param {number} [options.targetFps=60] - Target updates per second (e.g. 60)
   * @param {Function} [options.update] - Fixed timestep update callback (dt in seconds)
   * @param {Function} [options.render] - Variable render callback (alpha interpolation factor 0..1)
   */
  constructor({ targetFps = 60, update = null, render = null } = {}) {
    this.targetFps = targetFps;
    this.fixedDelta = 1 / targetFps; // e.g. 0.016666s
    this.maxAccumulator = 0.25; // Prevents spiral of death if tab loses focus or lags

    this.onUpdate = update;
    this.onRender = render;

    this.isRunning = false;
    this.isPaused = false;
    this.lastTime = 0;
    this.accumulator = 0;
    this.rafId = null;

    // Performance metrics
    this.fps = 0;
    this.frameCount = 0;
    this.fpsTimer = 0;

    this.loop = this.loop.bind(this);
  }

  /**
   * Starts the game loop.
   */
  start() {
    if (this.isRunning) return;
    this.isRunning = true;
    this.isPaused = false;
    this.lastTime = performance.now();
    this.accumulator = 0;
    this.rafId = requestAnimationFrame(this.loop);
  }

  /**
   * Stops/pauses the game loop.
   */
  stop() {
    if (!this.isRunning) return;
    this.isRunning = false;
    if (this.rafId !== null) {
      cancelAnimationFrame(this.rafId);
      this.rafId = null;
    }
  }

  /**
   * Pause or resume the update cycle without cancelling frame ticks.
   */
  setPaused(paused) {
    this.isPaused = paused;
  }

  /**
   * Main animation frame callback.
   * @param {number} currentTime - Timestamp from requestAnimationFrame
   */
  loop(currentTime) {
    if (!this.isRunning) return;

    // Calculate frame time in seconds
    let frameTime = (currentTime - this.lastTime) / 1000;
    this.lastTime = currentTime;

    // Clamp frame time to prevent accumulator spiral of death
    if (frameTime > this.maxAccumulator) {
      frameTime = this.maxAccumulator;
    }

    // Accumulate time for fixed updates
    this.accumulator += frameTime;

    // FPS calculation
    this.fpsTimer += frameTime;
    this.frameCount++;
    if (this.fpsTimer >= 1.0) {
      this.fps = this.frameCount;
      this.frameCount = 0;
      this.fpsTimer -= 1.0;
    }

    // Process fixed timestep updates
    if (!this.isPaused) {
      while (this.accumulator >= this.fixedDelta) {
        if (this.onUpdate) {
          this.onUpdate(this.fixedDelta);
        }
        this.accumulator -= this.fixedDelta;
      }
    } else {
      // Clear accumulator during pause so updates don't catch up all at once on resume
      this.accumulator = 0;
    }

    // Alpha interpolation parameter for render smoothing: alpha = accumulator / fixedDelta
    const alpha = this.fixedDelta > 0 ? this.accumulator / this.fixedDelta : 1;

    if (this.onRender) {
      this.onRender(alpha, this.fps);
    }

    this.rafId = requestAnimationFrame(this.loop);
  }
}
