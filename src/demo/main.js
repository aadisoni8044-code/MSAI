import { QuantumEngine } from '../quantum/QuantumEngine.js';
import { MainMenuScene } from './MainMenuScene.js';
import { GameplayScene } from './GameplayScene.js';
import { PauseScene } from './PauseScene.js';
import { GameOverScene } from './GameOverScene.js';

window.addEventListener('DOMContentLoaded', () => {
  // Initialize Quantum Engine
  const engine = new QuantumEngine({
    canvas: '#game-canvas',
    targetFps: 60
  });

  // Register Game Scenes
  engine.addScene('MainMenu', new MainMenuScene());
  engine.addScene('Gameplay', new GameplayScene());
  engine.addScene('Pause', new PauseScene());
  engine.addScene('GameOver', new GameOverScene());

  // Start in Main Menu scene
  engine.switchScene('MainMenu');

  // Start engine loop
  engine.start();

  // Expose engine instance on window object for testing/debugging
  window.QuantumEngineInstance = engine;
});
