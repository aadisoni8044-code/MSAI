import {
  Scene,
  Entity,
  Transform,
  Sprite,
  Rigidbody,
  Collider,
  Script
} from '../quantum/QuantumEngine.js';

/**
 * GameplayScene - Interactive demo scene with player movement, obstacle collisions,
 * collectible pickups, score UI, and dynamic camera tracking.
 */
export class GameplayScene extends Scene {
  constructor() {
    super('Gameplay');
    this.score = 0;
    this.highScore = 0;
    this.player = null;
    this.coinsRemaining = 0;
    this.dashCooldown = 0;
  }

  onEnter(data = {}) {
    this.clearEntities();
    this.score = 0;

    const worldWidth = 1600;
    const worldHeight = 1200;

    // Configure camera bounds
    this.engine.camera.setBounds(0, 0, worldWidth, worldHeight);

    // ----------------------------------------------------
    // 1. Background Grid Entity
    // ----------------------------------------------------
    const bgEntity = new Entity('Background');
    bgEntity.layer = 'background';
    bgEntity.addComponent(new Transform());
    bgEntity.addComponent({
      render: (ctx) => {
        ctx.fillStyle = '#0f172a';
        ctx.fillRect(0, 0, worldWidth, worldHeight);

        // Grid lines
        ctx.strokeStyle = '#1e293b';
        ctx.lineWidth = 1;
        const gridSize = 64;
        for (let x = 0; x < worldWidth; x += gridSize) {
          ctx.beginPath();
          ctx.moveTo(x, 0);
          ctx.lineTo(x, worldHeight);
          ctx.stroke();
        }
        for (let y = 0; y < worldHeight; y += gridSize) {
          ctx.beginPath();
          ctx.moveTo(0, y);
          ctx.lineTo(worldWidth, y);
          ctx.stroke();
        }

        // World Border
        ctx.strokeStyle = '#6366f1';
        ctx.lineWidth = 6;
        ctx.strokeRect(0, 0, worldWidth, worldHeight);
      }
    });
    this.addEntity(bgEntity);

    // ----------------------------------------------------
    // 2. Player Entity
    // ----------------------------------------------------
    const player = new Entity('Player');
    player.layer = 'gameplay';
    player.addTag('player');

    const playerTransform = new Transform({
      x: worldWidth / 2,
      y: worldHeight / 2,
      width: 40,
      height: 40
    });

    const playerRigidbody = new Rigidbody({
      mass: 1.0,
      drag: 0.85,
      useGravity: false
    });

    const playerCollider = new Collider({
      type: 'circle',
      radius: 20
    });

    // Player Movement & Action Script Component
    const playerScript = new Script((dt) => {
      // Handle Pause
      if (this.engine.input.isActionJustPressed('pause')) {
        this.engine.switchScene('Pause', { returnScene: 'Gameplay' });
        return;
      }

      // Movement Input Axis
      const axis = this.engine.input.getAxis();
      const moveSpeed = 600;

      if (axis.x !== 0 || axis.y !== 0) {
        playerRigidbody.applyForce(axis.x * moveSpeed, axis.y * moveSpeed);
        // Face movement direction
        playerTransform.rotation = Math.atan2(axis.y, axis.x);
      }

      // Dash Skill Mechanic
      if (this.dashCooldown > 0) {
        this.dashCooldown -= dt;
      } else if (this.engine.input.isActionJustPressed('dash')) {
        const dashSpeed = 12000;
        const dashX = axis.x !== 0 || axis.y !== 0 ? axis.x : Math.cos(playerTransform.rotation);
        const dashY = axis.x !== 0 || axis.y !== 0 ? axis.y : Math.sin(playerTransform.rotation);

        playerRigidbody.applyForce(dashX * dashSpeed, dashY * dashSpeed);
        this.dashCooldown = 0.6; // Cooldown seconds
        this.engine.assets.playSynthesizedSound('dash');
      }

      // World Bounds Clamp
      const r = playerCollider.radius;
      playerTransform.x = Math.max(r, Math.min(worldWidth - r, playerTransform.x));
      playerTransform.y = Math.max(r, Math.min(worldHeight - r, playerTransform.y));
    });

    player.addComponent(playerTransform);
    player.addComponent(playerRigidbody);
    player.addComponent(playerCollider);
    player.addComponent(
      new Sprite({
        color: '#38bdf8',
        shape: 'circle',
        radius: 20
      })
    );
    player.addComponent(playerScript);

    this.player = player;
    this.addEntity(player);

    // Set camera to follow player
    this.engine.camera.follow(playerTransform);

    // ----------------------------------------------------
    // 3. Static Obstacles (Walls & Boxes)
    // ----------------------------------------------------
    const obstacles = [
      { x: 400, y: 300, w: 200, h: 40 },
      { x: 1200, y: 300, w: 40, h: 250 },
      { x: 800, y: 600, w: 300, h: 50 },
      { x: 300, y: 850, w: 50, h: 220 },
      { x: 1100, y: 900, w: 240, h: 40 }
    ];

    obstacles.forEach((obs, idx) => {
      const obstacle = new Entity(`Obstacle_${idx}`);
      obstacle.addComponent(
        new Transform({
          x: obs.x,
          y: obs.y,
          width: obs.w,
          height: obs.h
        })
      );
      obstacle.addComponent(
        new Rigidbody({
          isStatic: true
        })
      );
      obstacle.addComponent(
        new Collider({
          type: 'box',
          width: obs.w,
          height: obs.h
        })
      );
      obstacle.addComponent(
        new Sprite({
          color: '#475569',
          shape: 'rectangle'
        })
      );
      this.addEntity(obstacle);
    });

    // ----------------------------------------------------
    // 4. Collectible Items (Coins / Energy Orbs)
    // ----------------------------------------------------
    const coinLocations = [
      { x: 200, y: 200 },
      { x: 600, y: 200 },
      { x: 1000, y: 200 },
      { x: 1400, y: 200 },
      { x: 200, y: 600 },
      { x: 500, y: 600 },
      { x: 1200, y: 600 },
      { x: 1400, y: 600 },
      { x: 200, y: 1000 },
      { x: 600, y: 1000 },
      { x: 1000, y: 1000 },
      { x: 1400, y: 1000 }
    ];

    this.coinsRemaining = coinLocations.length;

    coinLocations.forEach((loc, idx) => {
      const coin = new Entity(`Coin_${idx}`);
      coin.addTag('coin');

      const transform = new Transform({
        x: loc.x,
        y: loc.y,
        width: 24,
        height: 24
      });

      let bobTimer = Math.random() * Math.PI * 2;

      const collider = new Collider({
        type: 'circle',
        radius: 12,
        isTrigger: true,
        onCollision: (other) => {
          if (other.hasTag('player') && coin.active) {
            coin.active = false; // Collect
            this.score += 100;
            this.coinsRemaining--;
            this.engine.assets.playSynthesizedSound('coin');

            // Win Condition
            if (this.coinsRemaining <= 0) {
              this.engine.assets.playSynthesizedSound('win');
              this.engine.switchScene('GameOver', {
                score: this.score,
                isWin: true
              });
            }
          }
        }
      });

      const script = new Script((dt) => {
        bobTimer += dt * 4;
        transform.scaleX = 1 + Math.sin(bobTimer) * 0.15;
        transform.scaleY = 1 + Math.sin(bobTimer) * 0.15;
      });

      coin.addComponent(transform);
      coin.addComponent(collider);
      coin.addComponent(
        new Sprite({
          color: '#fbbf24',
          shape: 'circle',
          radius: 12
        })
      );
      coin.addComponent(script);

      this.addEntity(coin);
    });

    // ----------------------------------------------------
    // 5. UI HUD Entity (Score, Controls, FPS Counter)
    // ----------------------------------------------------
    const hudEntity = new Entity('HUD');
    hudEntity.layer = 'ui';
    hudEntity.addComponent(new Transform());
    hudEntity.addComponent({
      render: (ctx) => {
        const w = ctx.canvas.width;

        // Top Bar Background
        ctx.fillStyle = 'rgba(15, 23, 42, 0.85)';
        ctx.fillRect(0, 0, w, 50);
        ctx.strokeStyle = '#334155';
        ctx.lineWidth = 1;
        ctx.beginPath();
        ctx.moveTo(0, 50);
        ctx.lineTo(w, 50);
        ctx.stroke();

        // Score Text
        ctx.fillStyle = '#f8fafc';
        ctx.font = 'bold 18px "Segoe UI", sans-serif';
        ctx.textAlign = 'left';
        ctx.fillText(`SCORE: ${this.score}`, 20, 32);

        // Remaining Coins
        ctx.fillStyle = '#fbbf24';
        ctx.fillText(`ORBS REMAINING: ${this.coinsRemaining}`, 200, 32);

        // Dash Status Indicator
        ctx.textAlign = 'right';
        if (this.dashCooldown <= 0) {
          ctx.fillStyle = '#4ade80';
          ctx.fillText('DASH: READY [SPACE]', w - 120, 32);
        } else {
          ctx.fillStyle = '#f87171';
          ctx.fillText(`DASH: COOLDOWN (${this.dashCooldown.toFixed(1)}s)`, w - 120, 32);
        }

        // FPS Metric
        ctx.fillStyle = '#94a3b8';
        ctx.font = '14px monospace';
        ctx.fillText(`${this.engine.gameLoop.fps} FPS`, w - 20, 32);
      }
    });

    this.addEntity(hudEntity);
  }
}
