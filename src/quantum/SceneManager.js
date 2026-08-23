/**
 * SceneManager - Finite State Machine (FSM) for registering, switching, and updating game scenes.
 */
export class SceneManager {
  /**
   * @param {import('./QuantumEngine.js').QuantumEngine} engine
   */
  constructor(engine) {
    this.engine = engine;
    this.scenes = new Map();
    this.currentScene = null;
    this.currentSceneName = null;
  }

  /**
   * Register a new scene in the manager.
   * @param {string} name
   * @param {import('./Scene.js').Scene} sceneInstance
   */
  addScene(name, sceneInstance) {
    sceneInstance.engine = this.engine;
    sceneInstance.name = name;
    this.scenes.set(name, sceneInstance);
  }

  /**
   * Transition to a registered scene by name.
   * @param {string} name
   * @param {Object} [data={}] - Data passed to new scene's onEnter
   */
  switchScene(name, data = {}) {
    const nextScene = this.scenes.get(name);
    if (!nextScene) {
      console.error(`[SceneManager] Scene "${name}" not found!`);
      return;
    }

    if (this.currentScene) {
      this.currentScene.onExit();
    }

    this.currentScene = nextScene;
    this.currentSceneName = name;
    this.currentScene.onEnter(data);
  }

  /**
   * Delegates update to active scene.
   * @param {number} dt
   */
  update(dt) {
    if (this.currentScene) {
      this.currentScene.update(dt);
    }
  }

  /**
   * Delegates render to active scene.
   * @param {CanvasRenderingContext2D} ctx
   * @param {number} alpha
   */
  render(ctx, alpha) {
    if (this.currentScene) {
      this.currentScene.render(ctx, alpha);
    }
  }
}
