/**
 * Base Scene class representing an isolated state in the game engine.
 */
export class Scene {
  /**
   * @param {string} name
   */
  constructor(name = 'Scene') {
    this.name = name;
    /** @type {import('./QuantumEngine.js').QuantumEngine|null} */
    this.engine = null;
    /** @type {import('./Entity.js').Entity[]} */
    this.entities = [];
  }

  /**
   * Called when entering the scene.
   * @param {Object} [data] - Parameters passed during scene transition
   */
  onEnter(data = {}) {}

  /**
   * Called when exiting the scene.
   */
  onExit() {}

  /**
   * Add entity to scene container.
   * @param {import('./Entity.js').Entity} entity
   * @returns {import('./Entity.js').Entity}
   */
  addEntity(entity) {
    this.entities.push(entity);
    return entity;
  }

  /**
   * Remove entity from scene container.
   * @param {import('./Entity.js').Entity} entity
   */
  removeEntity(entity) {
    const idx = this.entities.indexOf(entity);
    if (idx !== -1) {
      this.entities.splice(idx, 1);
    }
  }

  /**
   * Clear all entities in scene.
   */
  clearEntities() {
    this.entities = [];
  }

  /**
   * Scene logic update callback.
   * @param {number} dt - Delta time in seconds
   */
  update(dt) {
    // Update physics system
    if (this.engine && this.engine.physics) {
      this.engine.physics.update(this.entities);
    }

    // Update entity components
    for (let i = 0; i < this.entities.length; i++) {
      const entity = this.entities[i];
      if (entity && entity.active) {
        entity.update(dt);
      }
    }
  }

  /**
   * Scene render callback.
   * @param {CanvasRenderingContext2D} ctx
   * @param {number} alpha - Interpolation factor
   */
  render(ctx, alpha = 1) {
    if (this.engine && this.engine.renderer) {
      this.engine.renderer.render(this.entities, alpha, this.engine.gameLoop ? this.engine.gameLoop.fps : 0);
    }
  }
}
