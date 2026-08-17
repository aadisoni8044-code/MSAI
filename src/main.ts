import { GameMetrics, GameState } from './types/game';
import { InputHandler } from './engine/InputHandler';
import { ParallaxBackground } from './engine/ParallaxBackground';
import { Player } from './entities/Player';
import { Enemy } from './entities/Enemy';
import { UIManager } from './managers/UIManager';

export class GameEngine {
  private canvas: HTMLCanvasElement;
  private ctx: CanvasRenderingContext2D;

  private state: GameState = 'START';
  private input: InputHandler;
  private bgManager: ParallaxBackground;
  private uiManager: UIManager;
  private player: Player;

  private enemies: Enemy[] = [];
  private metrics: GameMetrics = {
    score: 0,
    highScore: 0,
    speedMultiplier: 1.0,
    distance: 0,
    coins: 0,
  };

  private groundY: number = 460;
  private lastTime: number = 0;
  private spawnTimer: number = 0;

  constructor() {
    this.canvas = document.getElementById('game-canvas') as HTMLCanvasElement;
    this.ctx = this.canvas.getContext('2d')!;

    this.input = new InputHandler();
    this.bgManager = new ParallaxBackground('lakeside_meadow');
    this.uiManager = new UIManager();
    this.player = new Player(100, this.groundY);

    this.bindUIEvents();
    this.init();
  }

  private bindUIEvents(): void {
    // Start Menu
    document.getElementById('btn-start')?.addEventListener('click', () => {
      this.uiManager.playSfx('click');
      this.changeState('MAP_SELECT');
    });

    // Map Selector Buttons
    document.getElementById('btn-prev-map')?.addEventListener('click', () => {
      this.uiManager.prevMap();
      this.bgManager.setTheme(this.uiManager.getSelectedThemeId());
    });

    document.getElementById('btn-next-map')?.addEventListener('click', () => {
      this.uiManager.nextMap();
      this.bgManager.setTheme(this.uiManager.getSelectedThemeId());
    });

    document.getElementById('btn-back-start')?.addEventListener('click', () => {
      this.uiManager.playSfx('click');
      this.changeState('START');
    });

    document.getElementById('btn-confirm-map')?.addEventListener('click', () => {
      this.uiManager.playSfx('click');
      this.startNewGame();
    });

    // Pause Controls
    document.getElementById('btn-resume')?.addEventListener('click', () => {
      this.uiManager.playSfx('click');
      this.changeState('PLAYING');
    });

    document.getElementById('btn-quit')?.addEventListener('click', () => {
      this.uiManager.playSfx('click');
      this.changeState('START');
    });

    // Game Over Controls
    document.getElementById('btn-restart')?.addEventListener('click', () => {
      this.uiManager.playSfx('click');
      this.startNewGame();
    });

    document.getElementById('btn-gameover-menu')?.addEventListener('click', () => {
      this.uiManager.playSfx('click');
      this.changeState('MAP_SELECT');
    });
  }

  private init(): void {
    this.uiManager.setScreenState('START');
    requestAnimationFrame((timestamp) => this.gameLoop(timestamp));
  }

  public changeState(newState: GameState): void {
    this.state = newState;
    this.uiManager.setScreenState(newState);
  }

  public startNewGame(): void {
    const selectedTheme = this.uiManager.getSelectedThemeId();
    this.bgManager.setTheme(selectedTheme);

    this.player.reset(this.groundY);
    this.enemies = [];
    this.spawnTimer = 0;

    this.metrics = {
      score: 0,
      highScore: this.uiManager.getHighScore(selectedTheme),
      speedMultiplier: 1.0,
      distance: 0,
      coins: 0,
    };

    this.changeState('PLAYING');
  }

  private gameLoop(timestamp: number): void {
    const dt = (timestamp - this.lastTime) / 1000;
    this.lastTime = timestamp;

    this.input.update();

    // Pause Toggle Handler
    if (this.input.state.pausePressed) {
      if (this.state === 'PLAYING') {
        this.changeState('PAUSED');
      } else if (this.state === 'PAUSED') {
        this.changeState('PLAYING');
      }
    }

    // Restart Handler
    if (this.input.state.restartPressed && this.state === 'GAMEOVER') {
      this.startNewGame();
    }

    if (this.state === 'PLAYING') {
      this.update(dt);
    }

    this.render();

    requestAnimationFrame((t) => this.gameLoop(t));
  }

  private update(_dt: number): void {
    // 1. Difficulty Scaling & Distance Score
    this.metrics.distance += 1;
    this.metrics.score = Math.floor(this.metrics.distance / 5);
    this.metrics.speedMultiplier = 1.0 + Math.floor(this.metrics.score / 150) * 0.15;

    // SFX for Jump and Attack
    if (this.input.state.jumpPressed) {
      this.uiManager.playSfx('jump');
    }
    if (this.input.state.attackPressed) {
      this.uiManager.playSfx('attack');
    }

    // 2. Update Background Parallax
    const scrollSpeed = 3.5 * this.metrics.speedMultiplier;
    this.bgManager.update(scrollSpeed, this.canvas.width, this.canvas.height);

    // 3. Update Player
    this.player.update(this.input.state, this.canvas.width);

    // 4. Enemy Spawner Logic
    this.spawnTimer += 1;
    const currentTheme = this.bgManager.getTheme();
    const spawnThreshold = Math.max(70, 160 - Math.floor(this.metrics.score / 50) * 10);

    if (this.spawnTimer >= spawnThreshold) {
      this.spawnTimer = 0;
      const allowedHazards = currentTheme.hazardTypes;
      const randomType = allowedHazards[Math.floor(Math.random() * allowedHazards.length)];
      this.enemies.push(new Enemy(randomType, this.canvas.width + 50, this.groundY));
    }

    // 5. Update & Collision Check Enemies
    for (let i = this.enemies.length - 1; i >= 0; i--) {
      const enemy = this.enemies[i];
      enemy.update(scrollSpeed);

      // Check Sword Attack Collisions
      if (this.player.isAttacking) {
        if (this.checkAABB(this.player.attackBox, enemy)) {
          this.uiManager.playSfx('score');
          this.metrics.distance += 100; // Bonus points
          this.enemies.splice(i, 1);
          continue;
        }
      }

      // Check Player Body Collision with Enemy
      if (this.checkAABB(this.player, enemy)) {
        if (this.player.takeDamage(1)) {
          this.uiManager.playSfx('hit');
          if (this.player.health <= 0) {
            this.handleGameOver();
            return;
          }
        }
      }

      // Remove offscreen enemies
      if (enemy.x + enemy.width < -100) {
        this.enemies.splice(i, 1);
      }
    }

    // 6. Update HUD
    this.uiManager.updateHUD(
      this.metrics.score,
      Math.max(this.metrics.score, this.metrics.highScore),
      this.metrics.speedMultiplier,
      this.player.health,
      this.player.maxHealth
    );
  }

  private handleGameOver(): void {
    this.uiManager.playSfx('gameover');
    const selectedTheme = this.uiManager.getSelectedThemeId();
    this.uiManager.updateGameOverScreen(this.metrics.score, selectedTheme);
    this.changeState('GAMEOVER');
  }

  private checkAABB(
    a: { x: number; y: number; width: number; height: number },
    b: { x: number; y: number; width: number; height: number }
  ): boolean {
    return (
      a.x < b.x + b.width &&
      a.x + a.width > b.x &&
      a.y < b.y + b.height &&
      a.y + a.height > b.y
    );
  }

  private render(): void {
    this.ctx.clearRect(0, 0, this.canvas.width, this.canvas.height);

    // 1. Render Parallax Background
    this.bgManager.render(this.ctx, this.canvas.width, this.canvas.height);

    // 2. Render Ground Platform Line
    const theme = this.bgManager.getTheme();
    this.ctx.fillStyle = theme.groundColor;
    this.ctx.fillRect(0, this.groundY, this.canvas.width, this.canvas.height - this.groundY);

    this.ctx.fillStyle = theme.accentColor;
    this.ctx.fillRect(0, this.groundY, this.canvas.width, 6);

    // 3. Render Entities
    this.enemies.forEach((enemy) => enemy.render(this.ctx));
    this.player.render(this.ctx);
  }
}

// Bootstrap Engine on DOM ready
window.addEventListener('DOMContentLoaded', () => {
  new GameEngine();
});
