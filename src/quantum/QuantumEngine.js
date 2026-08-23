import { GameLoop } from './GameLoop.js';
import { AssetManager } from './AssetManager.js';
import { SceneManager } from './SceneManager.js';
import { Scene } from './Scene.js';
import { InputHandler } from './InputHandler.js';
import { Entity } from './Entity.js';
import { Transform, Sprite, Rigidbody, Collider, Script } from './Components.js';
import { PhysicsSystem } from './PhysicsSystem.js';
import { RenderPipeline } from './RenderPipeline.js';
import { Camera } from './Camera.js';

/**
 * QuantumEngine - Unified Game Engine Facade.
 */
export class QuantumEngine {
  /**
   * @param {Object} options
   * @param {HTMLCanvasElement|string} options.canvas - Canvas element or DOM query selector
   * @param {number} [options.targetFps=60]
   */
  constructor({ canvas, targetFps = 60 }) {
    if (typeof canvas === 'string') {
      this.canvas = document.querySelector(canvas);
    } else {
      this.canvas = canvas;
    }

    if (!this.canvas) {
      throw new Error('[QuantumEngine] Canvas element not found');
    }

    this.ctx = this.canvas.getContext('2d');

    // Engine Core Modules
    this.assets = new AssetManager();
    this.input = new InputHandler(this.canvas);
    this.sceneManager = new SceneManager(this);
    this.physics = new PhysicsSystem();
    this.renderer = new RenderPipeline(this.canvas);

    // Core Game Loop
    this.gameLoop = new GameLoop({
      targetFps,
      update: (dt) => this._update(dt),
      render: (alpha, fps) => this._render(alpha, fps)
    });
  }

  /**
   * Access camera helper directly.
   */
  get camera() {
    return this.renderer.camera;
  }

  /**
   * Start the engine game loop.
   */
  start() {
    this.gameLoop.start();
  }

  /**
   * Stop/Pause engine execution.
   */
  stop() {
    this.gameLoop.stop();
  }

  /**
   * Register a scene in scene manager.
   */
  addScene(name, scene) {
    this.sceneManager.addScene(name, scene);
  }

  /**
   * Switch to scene.
   */
  switchScene(name, data = {}) {
    this.sceneManager.switchScene(name, data);
  }

  /**
   * Internal engine update cycle.
   */
  _update(dt) {
    // Update camera follow
    this.camera.update(dt);

    // Update active scene
    this.sceneManager.update(dt);

    // Reset input single-frame press flags after scene update
    this.input.update();
  }

  /**
   * Internal engine render cycle.
   */
  _render(alpha, fps) {
    this.sceneManager.render(this.ctx, alpha);
  }
}

// Re-export core building blocks for convenient single-import usage
export {
  GameLoop,
  AssetManager,
  SceneManager,
  Scene,
  InputHandler,
  Entity,
  Transform,
  Sprite,
  Rigidbody,
  Collider,
  Script,
  PhysicsSystem,
  RenderPipeline,
  Camera
};
