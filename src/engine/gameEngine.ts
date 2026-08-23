import {
  GameMode,
  BiomeType,
  Obstacle,
  Particle,
  PlayerState,
  BotState,
  ShapeSkin,
  RenderShapeType
} from '../types';
import { getSkinById } from '../data/shapes';
import { drawShape } from './shapeRenderer';
import { audioEngine } from './audioEngine';

export interface GameEngineCallbacks {
  onProgressUpdate: (progress: number, distanceMeters: number, currentLevel: number, biome: BiomeType) => void;
  onGameOver: (progress: number, finalScoreText: string) => void;
  onVictory: (level: number, attempts: number, isPerfect: boolean) => void;
  onCoinEarned: (newTotal: number) => void;
  onLeaderboardUpdate: (racers: { name: string; x: number; isDead: boolean; color: string }[]) => void;
}

export class GameEngine {
  private canvas: HTMLCanvasElement;
  private ctx: CanvasRenderingContext2D;
  private callbacks: GameEngineCallbacks;

  // Viewport & Scale
  public width: number = 1200;
  public height: number = 675;
  public scale: number = 1;
  public offsetX: number = 0;
  public offsetY: number = 0;

  // Game Mode & Level
  public mode: GameMode = 'classic';
  public currentLevel: number = 1;
  public activeBiome: BiomeType = 'forest';
  public attemptCount: number = 1;
  public isRunning: boolean = false;
  public isPaused: boolean = false;
  public isPracticeMode: boolean = false;

  // Player & Practice checkpoint
  public player: PlayerState;
  public currentShapeId: string = 'arrow';
  private practiceCheckpoint: { x: number; y: number; vy: number; attempt: number } | null = null;

  // Level & Obstacles
  public obstacles: Obstacle[] = [];
  public levelLength: number = 6000;
  public levelProgress: number = 0;
  public endlessDistance: number = 0;

  // Camera & Inputs
  public camera = { x: 0, y: 0, targetY: 0 };
  private currentHorizontalOffset: number = 180;
  private targetHorizontalOffset: number = 180;
  public inputActive: boolean = false;
  public inputLeft: boolean = false;
  public inputRight: boolean = false;

  // Background pattern canvas
  private hexPatternCanvas: HTMLCanvasElement | null = null;
  private hexPatternWidth: number = 256;
  private hexPatternHeight: number = 256;
  private bgScrollX: number = 0;
  private bgScrollY: number = 0;

  // Ambient & Race Bots
  private ambientParticles: any[] = [];
  private bots: BotState[] = [];

  // Loop timing
  private lastTime: number = 0;
  private animFrameId: number | null = null;

  constructor(canvas: HTMLCanvasElement, callbacks: GameEngineCallbacks) {
    this.canvas = canvas;
    this.ctx = canvas.getContext('2d')!;
    this.callbacks = callbacks;

    this.player = this.createDefaultPlayer();
    this.createHexagonPattern();
    this.resize();
  }

  public setEquippedShape(shapeId: string) {
    this.currentShapeId = shapeId;
  }

  private createDefaultPlayer(): PlayerState {
    return {
      x: 150,
      y: 337.5,
      width: 34,
      height: 26,
      vy: 0,
      targetVy: 0,
      angle: 0,
      baseSpeed: 380,
      speedMultiplier: 1,
      isDead: false,
      trail: [],
      particles: [],
      hasCrashedThisRun: false,
      lastCoinPayout: 0,
      animTimer: 0
    };
  }

  public resize() {
    const container = this.canvas.parentElement;
    if (!container) return;
    const rect = container.getBoundingClientRect();

    this.canvas.width = rect.width;
    this.canvas.height = rect.height;

    const targetAspect = this.width / this.height;
    const currentAspect = rect.width / rect.height;

    if (currentAspect > targetAspect) {
      this.scale = rect.height / this.height;
      this.offsetX = (rect.width - this.width * this.scale) / 2;
      this.offsetY = 0;
    } else {
      this.scale = rect.width / this.width;
      this.offsetX = 0;
      this.offsetY = (rect.height - this.height * this.scale) / 2;
    }
  }

  private createHexagonPattern() {
    this.hexPatternCanvas = document.createElement('canvas');
    this.hexPatternCanvas.width = this.hexPatternWidth;
    this.hexPatternCanvas.height = this.hexPatternHeight;
    const hCtx = this.hexPatternCanvas.getContext('2d');
    if (!hCtx) return;

    hCtx.fillStyle = '#020508';
    hCtx.fillRect(0, 0, this.hexPatternWidth, this.hexPatternHeight);

    const r = 24;
    const h = r * Math.sqrt(3);
    const w = r * 1.5;

    hCtx.strokeStyle = 'rgba(0, 243, 255, 0.08)';
    hCtx.lineWidth = 1.2;

    for (let x = -r; x < this.hexPatternWidth + r * 2; x += r * 3) {
      for (let y = -r; y < this.hexPatternHeight + r * 2; y += h) {
        this.drawHexagonPath(hCtx, x, y, r);
        hCtx.stroke();

        this.drawHexagonPath(hCtx, x + w, y + h / 2, r);
        hCtx.stroke();
      }
    }
  }

  private drawHexagonPath(context: CanvasRenderingContext2D, x: number, y: number, radius: number) {
    context.beginPath();
    for (let i = 0; i < 6; i++) {
      const angle = (i * Math.PI) / 3;
      const px = x + radius * Math.cos(angle);
      const py = y + radius * Math.sin(angle);
      if (i === 0) context.moveTo(px, py);
      else context.lineTo(px, py);
    }
    context.closePath();
  }

  public getBiomeForLevel(lvl: number): BiomeType {
    if (this.mode !== 'classic') {
      return this.activeBiome;
    }
    if (lvl <= 20) return 'forest';
    if (lvl <= 40) return 'haunted';
    if (lvl <= 60) return 'space';
    if (lvl <= 80) return 'water';
    return 'ancient';
  }

  public startClassicLevel(levelNum: number) {
    this.mode = 'classic';
    this.currentLevel = levelNum;
    this.activeBiome = this.getBiomeForLevel(levelNum);
    this.attemptCount = 1;
    this.initGameElements();
    this.startLoop();
  }

  public startEndlessMode(biome: BiomeType = 'space') {
    this.mode = 'endless';
    this.activeBiome = biome;
    this.attemptCount = 1;
    this.initGameElements();
    this.startLoop();
  }

  public startRaceMode() {
    this.mode = 'race';
    this.activeBiome = 'space';
    this.attemptCount = 1;
    this.initGameElements();
    this.startLoop();
  }

  public initGameElements() {
    this.targetHorizontalOffset = 180;
    this.currentHorizontalOffset = 180;
    this.player = this.createDefaultPlayer();

    // Scale speed with level (380 up to 600 max at level 100)
    this.player.baseSpeed = 380 + (this.currentLevel * 2.2);

    const activeBiome = this.getBiomeForLevel(this.currentLevel);
    if (this.mode === 'classic' && activeBiome === 'water') {
      this.player.baseSpeed *= 0.85; // buoyant water drag feel
    }

    this.camera.x = 0;
    this.camera.y = 0;
    this.camera.targetY = 0;

    this.generateLevelObstacles();
    this.initRaceCompetitors();
    this.initAmbientParticles();

    if (this.isPracticeMode && this.practiceCheckpoint) {
      this.player.x = this.practiceCheckpoint.x;
      this.player.y = this.practiceCheckpoint.y;
      this.player.vy = this.practiceCheckpoint.vy;
      this.attemptCount = this.practiceCheckpoint.attempt;
      this.camera.x = this.player.x - 180;
      this.camera.y = this.player.y - this.height / 2;
    }
  }

  public restart() {
    this.attemptCount++;
    this.initGameElements();
    this.isRunning = true;
    this.isPaused = false;
    audioEngine.startMusic();
  }

  public setPracticeMode(enabled: boolean) {
    this.isPracticeMode = enabled;
    if (!enabled) {
      this.practiceCheckpoint = null;
    }
  }

  public placeCheckpoint() {
    if (this.player.isDead) return;
    audioEngine.playCheckpoint();
    this.practiceCheckpoint = {
      x: this.player.x,
      y: this.player.y,
      vy: this.player.vy,
      attempt: this.attemptCount
    };

    // Burst particles
    for (let i = 0; i < 14; i++) {
      const angle = (i / 14) * Math.PI * 2;
      this.player.particles.push({
        x: this.player.x,
        y: this.player.y,
        vx: Math.cos(angle) * 120,
        vy: Math.sin(angle) * 120,
        size: 3.5,
        color: '#00f3ff',
        alpha: 1,
        life: 0.5
      });
    }
  }

  public clearCheckpoints() {
    this.practiceCheckpoint = null;
  }

  private generateLevelObstacles() {
    this.obstacles = [];
    this.levelProgress = 0;
    const biome = this.getBiomeForLevel(this.currentLevel);

    const colors: Record<BiomeType, string> = {
      forest: 'rgba(0, 255, 102, 0.85)',
      haunted: 'rgba(176, 38, 255, 0.85)',
      space: 'rgba(0, 243, 255, 0.85)',
      water: 'rgba(255, 0, 127, 0.85)',
      ancient: 'rgba(255, 170, 0, 0.85)'
    };
    const obsColor = colors[biome];

    if (this.mode === 'classic') {
      this.levelLength = 5000 + (this.currentLevel * 100);

      // Start gate
      this.obstacles.push({
        type: 'gate',
        x: 400,
        y: 40,
        width: 15,
        height: this.height - 80,
        color: '#ffffff'
      });

      let cursorX = 700;
      const seed = this.currentLevel * 888 + 123;
      let randomVal = Math.sin(seed) * 10000;
      const getRand = () => {
        randomVal = Math.sin(randomVal) * 10000;
        return randomVal - Math.floor(randomVal);
      };

      while (cursorX < this.levelLength - 800) {
        const roll = getRand();
        const difficultyScale = this.currentLevel / 100;
        const gapSpacing = Math.max(160, 320 - (difficultyScale * 120));

        if (roll < 0.3) {
          // Spike clusters
          const isCeiling = getRand() < 0.5;
          const spikeCount = Math.floor(getRand() * 3) + 1 + Math.floor(difficultyScale * 2);
          const itemSpacing = 44;

          for (let i = 0; i < spikeCount; i++) {
            this.obstacles.push({
              type: 'spike',
              x: cursorX + i * itemSpacing,
              y: isCeiling ? 40 : this.height - 40,
              width: 40,
              height: 50,
              dir: isCeiling ? 1 : -1,
              color: obsColor
            });
          }
          cursorX += (spikeCount * itemSpacing) + gapSpacing;
        } else if (roll < 0.65) {
          // Blockade corridor columns
          const gapY = 180 + getRand() * 220;
          const minGap = Math.max(130, 240 - (difficultyScale * 90));

          this.obstacles.push({
            type: 'block',
            x: cursorX,
            y: 40,
            width: 70 + getRand() * 60,
            height: gapY - minGap / 2 - 40,
            color: obsColor
          });

          this.obstacles.push({
            type: 'block',
            x: cursorX,
            y: gapY + minGap / 2,
            width: 70 + getRand() * 60,
            height: (this.height - 40) - (gapY + minGap / 2),
            color: obsColor
          });

          if (getRand() < 0.4 && this.currentLevel > 15) {
            this.obstacles.push({
              type: 'spike',
              x: cursorX + 15,
              y: gapY + minGap / 2 - 2,
              width: 32,
              height: 34,
              dir: -1,
              color: biome === 'haunted' ? '#ff007f' : obsColor
            });
          }
          cursorX += 150 + gapSpacing;
        } else if (roll < 0.85) {
          // Floating blockades
          const blockY = 180 + getRand() * 200;
          const blockW = 80 + getRand() * 100;
          const blockH = 60 + getRand() * 80;

          this.obstacles.push({
            type: 'block',
            x: cursorX,
            y: blockY,
            width: blockW,
            height: blockH,
            color: obsColor
          });

          if (difficultyScale > 0.3) {
            const topSpike = getRand() < 0.5;
            this.obstacles.push({
              type: 'spike',
              x: cursorX + blockW / 2 - 18,
              y: topSpike ? blockY : blockY + blockH,
              width: 36,
              height: 36,
              dir: topSpike ? 1 : -1,
              color: '#ffffff'
            });
          }
          cursorX += blockW + gapSpacing;
        } else {
          // Slalom gate
          const centerGapY = 220 + getRand() * 140;
          this.obstacles.push({
            type: 'block',
            x: cursorX,
            y: 40,
            width: 150,
            height: centerGapY - 95,
            color: obsColor
          });
          this.obstacles.push({
            type: 'block',
            x: cursorX + 220,
            y: centerGapY + 95,
            width: 150,
            height: (this.height - 40) - (centerGapY + 95),
            color: obsColor
          });
          cursorX += 450 + gapSpacing;
        }
      }
    } else {
      // Endless
      this.levelLength = 99999999;
      this.generateEndlessBuffer(0, 40000, biome);
    }
  }

  private generateEndlessBuffer(startX: number, length: number, biome: BiomeType) {
    let cursorX = Math.max(startX, 600);
    const endX = startX + length;

    const colors: Record<BiomeType, string> = {
      forest: 'rgba(0, 255, 102, 0.85)',
      haunted: 'rgba(176, 38, 255, 0.85)',
      space: 'rgba(0, 243, 255, 0.85)',
      water: 'rgba(255, 0, 127, 0.85)',
      ancient: 'rgba(255, 170, 0, 0.85)'
    };
    const obsColor = colors[biome];

    while (cursorX < endX) {
      const roll = Math.random();
      const distanceScale = Math.min(1.0, cursorX / 30000);
      const gapSpacing = Math.max(160, 300 - (distanceScale * 110));

      if (roll < 0.25) {
        const isCeiling = Math.random() < 0.5;
        const spikeCount = Math.floor(Math.random() * 3) + 1 + Math.floor(distanceScale * 2);
        const itemSpacing = 44;

        for (let i = 0; i < spikeCount; i++) {
          this.obstacles.push({
            type: 'spike',
            x: cursorX + i * itemSpacing,
            y: isCeiling ? 40 : this.height - 40,
            width: 40,
            height: 50,
            dir: isCeiling ? 1 : -1,
            color: obsColor
          });
        }
        cursorX += (spikeCount * itemSpacing) + gapSpacing;
      } else if (roll < 0.6) {
        const gapY = 180 + Math.random() * 220;
        const minGap = Math.max(140, 220 - (distanceScale * 80));

        this.obstacles.push({
          type: 'block',
          x: cursorX,
          y: 40,
          width: 80 + Math.random() * 80,
          height: gapY - minGap / 2 - 40,
          color: obsColor
        });

        this.obstacles.push({
          type: 'block',
          x: cursorX,
          y: gapY + minGap / 2,
          width: 80 + Math.random() * 80,
          height: (this.height - 40) - (gapY + minGap / 2),
          color: obsColor
        });
        cursorX += 160 + gapSpacing;
      } else if (roll < 0.8) {
        const blockY = 180 + Math.random() * 200;
        const blockW = 80 + Math.random() * 100;
        const blockH = 70 + Math.random() * 80;

        this.obstacles.push({
          type: 'block',
          x: cursorX,
          y: blockY,
          width: blockW,
          height: blockH,
          color: obsColor
        });
        cursorX += blockW + gapSpacing;
      } else {
        const centerGapY = 220 + Math.random() * 140;
        this.obstacles.push({
          type: 'block',
          x: cursorX,
          y: 40,
          width: 150,
          height: centerGapY - 100,
          color: obsColor
        });
        this.obstacles.push({
          type: 'block',
          x: cursorX + 220,
          y: centerGapY + 100,
          width: 150,
          height: (this.height - 40) - (centerGapY + 100),
          color: obsColor
        });
        cursorX += 450 + gapSpacing;
      }
    }
  }

  private initAmbientParticles() {
    this.ambientParticles = [];
    const count = 35;
    const biome = this.getBiomeForLevel(this.currentLevel);

    for (let i = 0; i < count; i++) {
      this.ambientParticles.push(this.createAmbientParticle(Math.random() * this.width, biome));
    }
  }

  private createAmbientParticle(forceX: number | null = null, biome: BiomeType = 'forest') {
    const pX = forceX !== null ? forceX : this.camera.x + this.width + Math.random() * 100;
    const pY = 40 + Math.random() * (this.height - 80);

    let p = {
      x: pX,
      y: pY,
      vx: -120,
      vy: 20,
      size: 6,
      color: '#00ff66',
      alpha: 0.1 + Math.random() * 0.35,
      type: biome,
      angle: Math.random() * Math.PI,
      spinSpeed: (Math.random() - 0.5) * 1.5
    };

    if (biome === 'forest') {
      p.vx = -120 - Math.random() * 40;
      p.vy = 20 + Math.random() * 30;
      p.size = 6 + Math.random() * 6;
      p.color = Math.random() < 0.5 ? '#00ff66' : '#88ff00';
    } else if (biome === 'haunted') {
      p.vx = -40 - Math.random() * 30;
      p.vy = (Math.random() - 0.5) * 15;
      p.size = 25 + Math.random() * 30;
      p.color = 'rgba(176, 38, 255, 0.15)';
    } else if (biome === 'space') {
      p.vx = -15 - Math.random() * 15;
      p.vy = 0;
      p.size = 1.5 + Math.random() * 2.5;
      p.color = Math.random() < 0.5 ? '#00f3ff' : '#ffffff';
    } else if (biome === 'water') {
      p.vx = -80 - Math.random() * 30;
      p.vy = -35 - Math.random() * 30;
      p.size = 3 + Math.random() * 5;
      p.color = 'rgba(255, 255, 255, 0.45)';
    } else if (biome === 'ancient') {
      p.vx = -60 - Math.random() * 40;
      p.vy = (Math.random() - 0.5) * 40;
      p.size = 4 + Math.random() * 4;
      p.color = '#ffaa00';
    }

    return p;
  }

  private initRaceCompetitors() {
    this.bots = [];
    if (this.mode !== 'race') return;

    const names = ["AeroBot", "HexRunner", "NeonDash", "GridCrasher"];
    const colors = ["#ff007f", "#ffaa00", "#b026ff", "#00f3ff"];
    const shapes: RenderShapeType[] = ['arrow', 'hexagon', 'lightning', 'diamond'];

    for (let i = 0; i < 4; i++) {
      this.bots.push({
        id: `bot_${i}`,
        name: names[i],
        x: 150,
        y: 200 + i * 80,
        vy: 0,
        width: 28,
        height: 20,
        angle: 0,
        color: colors[i],
        baseSpeed: 380 + Math.random() * 25,
        isDead: false,
        lastDecisionTime: 0,
        decisionInterval: 0.12 + Math.random() * 0.1,
        trail: [],
        targetVy: 390,
        shapeType: shapes[i]
      });
    }
  }

  public startLoop() {
    this.isRunning = true;
    this.isPaused = false;
    this.lastTime = performance.now();
    audioEngine.startMusic();

    if (this.animFrameId) {
      cancelAnimationFrame(this.animFrameId);
    }
    this.loop = this.loop.bind(this);
    this.animFrameId = requestAnimationFrame(this.loop);
  }

  public stopLoop() {
    this.isRunning = false;
    audioEngine.stopMusic();
    if (this.animFrameId) {
      cancelAnimationFrame(this.animFrameId);
      this.animFrameId = null;
    }
  }

  public pause() {
    this.isPaused = true;
    audioEngine.stopMusic();
  }

  public resume() {
    this.isPaused = false;
    audioEngine.startMusic();
  }

  private loop(time: number) {
    if (!this.isRunning) return;

    const dt = Math.min((time - this.lastTime) / 1000, 0.1);
    this.lastTime = time;

    if (!this.isPaused) {
      this.update(dt);
    }
    this.render();

    this.animFrameId = requestAnimationFrame(this.loop);
  }

  private update(dt: number) {
    this.updatePlayerPhysics(dt);
    this.updateBots(dt);
    this.updateLevelAndCollisions();
    this.updateCamera(dt);
    this.updateAmbientParticles(dt);

    this.bgScrollX = this.camera.x;
    this.bgScrollY = this.camera.y;
  }

  private updatePlayerPhysics(dt: number) {
    if (this.player.isDead) {
      this.updatePlayerParticles(dt);
      return;
    }

    this.player.animTimer += dt;
    const activeBiome = this.getBiomeForLevel(this.currentLevel);

    let fallSpeed = 390;
    let floatSpeed = -390;

    if (activeBiome === 'water') {
      fallSpeed = 240;
      floatSpeed = -310;
    }

    // 1. Horizontal progression
    this.player.x += this.player.baseSpeed * this.player.speedMultiplier * dt;

    if (this.inputLeft) {
      this.targetHorizontalOffset = 100;
    } else if (this.inputRight) {
      this.targetHorizontalOffset = 380;
    } else {
      this.targetHorizontalOffset = 180;
    }

    // 2. Direct vertical input
    if (this.inputActive) {
      this.player.targetVy = floatSpeed;
    } else {
      this.player.targetVy = fallSpeed;
    }

    const lerpAcc = activeBiome === 'water' ? 9.0 : 16.0;
    this.player.vy += (this.player.targetVy - this.player.vy) * lerpAcc * dt;
    this.player.y += this.player.vy * dt;

    // Boundaries
    const borderTop = 40;
    const borderBottom = this.height - 40;
    if (this.player.y < borderTop + this.player.height / 2) {
      this.player.y = borderTop + this.player.height / 2;
      this.player.vy = 0;
    }
    if (this.player.y > borderBottom - this.player.height / 2) {
      this.player.y = borderBottom - this.player.height / 2;
      this.player.vy = 0;
    }

    this.player.angle = Math.atan2(this.player.vy, this.player.baseSpeed) * 0.8;

    // Trail updates
    const skin = getSkinById(this.currentShapeId);
    const backAngle = this.player.angle + Math.PI;
    const backX = this.player.x + Math.cos(backAngle) * (this.player.width / 2);
    const backY = this.player.y + Math.sin(backAngle) * (this.player.width / 2);

    this.player.trail.push({
      x: backX,
      y: backY,
      time: Date.now()
    });

    const now = Date.now();
    const trailLifetime = 900;
    this.player.trail = this.player.trail.filter(pt => now - pt.time < trailLifetime);

    if (Math.random() < 0.45) {
      this.createSpark(backX, backY, -this.player.vy * 0.25, skin);
    }

    this.updatePlayerParticles(dt);
  }

  private createSpark(x: number, y: number, vyOffset: number, skin: ShapeSkin) {
    this.player.particles.push({
      x: x,
      y: y,
      vx: -this.player.baseSpeed * 0.35 + (Math.random() - 0.5) * 60,
      vy: vyOffset + (Math.random() - 0.5) * 80,
      size: Math.random() * 3 + 1.2,
      color: skin.particleColor,
      alpha: 1.0,
      life: 0.5 + Math.random() * 0.3
    });
  }

  private updatePlayerParticles(dt: number) {
    for (let i = this.player.particles.length - 1; i >= 0; i--) {
      const p = this.player.particles[i];
      p.x += p.vx * dt;
      p.y += p.vy * dt;
      p.life -= dt;
      p.alpha = Math.max(0, p.life);

      if (p.life <= 0) {
        this.player.particles.splice(i, 1);
      }
    }
  }

  private triggerCrash() {
    this.player.isDead = true;
    this.player.vy = 0;
    this.player.hasCrashedThisRun = true;

    audioEngine.stopMusic();
    audioEngine.playCrash();

    const skin = getSkinById(this.currentShapeId);
    const burstCount = 45;
    for (let i = 0; i < burstCount; i++) {
      const angle = Math.random() * Math.PI * 2;
      const spd = Math.random() * 260 + 80;
      this.player.particles.push({
        x: this.player.x,
        y: this.player.y,
        vx: Math.cos(angle) * spd,
        vy: Math.sin(angle) * spd,
        size: Math.random() * 6 + 2,
        color: skin.color,
        alpha: 1.0,
        life: 1.0 + Math.random() * 0.8
      });
    }

    setTimeout(() => {
      if (this.isRunning) {
        const scoreText = this.mode === 'classic'
          ? `Level ${this.currentLevel}`
          : `${Math.floor(this.levelProgress)}m`;
        this.callbacks.onGameOver(this.levelProgress, scoreText);
      }
    }, 1200);
  }

  private updateCamera(dt: number) {
    this.currentHorizontalOffset += (this.targetHorizontalOffset - this.currentHorizontalOffset) * 6 * dt;
    this.camera.x = this.player.x - this.currentHorizontalOffset;

    this.camera.targetY = this.player.y - this.height / 2;
    const limit = 110;
    if (this.camera.targetY < -limit) this.camera.targetY = -limit;
    if (this.camera.targetY > limit) this.camera.targetY = limit;

    this.camera.y += (this.camera.targetY - this.camera.y) * 8 * dt;
  }

  private updateLevelAndCollisions() {
    if (this.player.isDead) return;

    if (this.mode === 'classic') {
      const startX = 150;
      const totalDist = this.levelLength - 800 - startX;
      const currentDist = this.player.x - startX;
      this.levelProgress = Math.max(0, Math.min(100, (currentDist / totalDist) * 100));

      this.callbacks.onProgressUpdate(
        this.levelProgress,
        Math.floor(currentDist / 10),
        this.currentLevel,
        this.getBiomeForLevel(this.currentLevel)
      );

      if (this.player.x >= this.levelLength - 800) {
        this.triggerVictory();
      }
    } else if (this.mode === 'endless') {
      const startX = 150;
      const mDist = Math.floor((this.player.x - startX) / 10);
      this.levelProgress = mDist;

      this.callbacks.onProgressUpdate(
        100,
        mDist,
        1,
        this.activeBiome
      );

      if (this.obstacles.length > 0 && this.obstacles[0].x < this.player.x - 1200) {
        this.obstacles = this.obstacles.filter(o => o.x >= this.player.x - 1200);
      }

      const lastObsX = this.obstacles.length > 0 ? this.obstacles[this.obstacles.length - 1].x : this.player.x;
      if (lastObsX < this.player.x + 3500) {
        this.generateEndlessBuffer(lastObsX + 300, 10000, this.activeBiome);
      }

      // Coin rewards every 20m survived
      if (mDist > 0 && mDist % 20 === 0) {
        if (!this.player.lastCoinPayout || this.player.lastCoinPayout < mDist) {
          this.player.lastCoinPayout = mDist;
          this.callbacks.onCoinEarned(1);
        }
      }
    } else if (this.mode === 'race') {
      const startX = 150;
      const mDist = Math.floor((this.player.x - startX) / 10);
      this.levelProgress = mDist;

      this.callbacks.onProgressUpdate(
        50,
        mDist,
        1,
        'space'
      );
    }

    // Collision metrics
    const pW = this.player.width * 0.55;
    const pH = this.player.height * 0.55;
    const pX = this.player.x - pW / 2;
    const pY = this.player.y - pH / 2;

    for (const obs of this.obstacles) {
      if (obs.x < this.player.x - 100) continue;
      if (obs.x > this.player.x + 250) continue;

      if (obs.type === 'spike') {
        const spikeY = obs.dir === 1 ? obs.y : obs.y - obs.height;
        if (this.rectsIntersect(pX, pY, pW, pH, obs.x, spikeY, obs.width, obs.height)) {
          if (this.playerSpikeCollision(obs)) {
            this.triggerCrash();
            break;
          }
        }
      } else if (obs.type === 'block') {
        if (this.rectsIntersect(pX, pY, pW, pH, obs.x, obs.y, obs.width, obs.height)) {
          this.triggerCrash();
          break;
        }
      }
    }

    // Ceiling / floor crashing
    if (this.player.y - pH / 2 <= 42 || this.player.y + pH / 2 >= this.height - 42) {
      this.triggerCrash();
    }
  }

  private triggerVictory() {
    audioEngine.stopMusic();
    audioEngine.playCleared();

    const isPerfect = this.attemptCount === 1 && !this.player.hasCrashedThisRun;
    this.callbacks.onVictory(this.currentLevel, this.attemptCount, isPerfect);
  }

  private rectsIntersect(x1: number, y1: number, w1: number, h1: number, x2: number, y2: number, w2: number, h2: number): boolean {
    return x1 < x2 + w2 && x1 + w1 > x2 && y1 < y2 + h2 && y1 + h1 > y2;
  }

  private playerSpikeCollision(spike: Obstacle): boolean {
    const tipY = spike.dir === 1 ? spike.y + spike.height : spike.y - spike.height;
    const tipX = spike.x + spike.width / 2;
    const baseX1 = spike.x;
    const baseY1 = spike.y;
    const baseX2 = spike.x + spike.width;
    const baseY2 = spike.y;

    const corners = [
      { x: this.player.x, y: this.player.y },
      { x: this.player.x + this.player.width * 0.22, y: this.player.y },
      { x: this.player.x - this.player.width * 0.22, y: this.player.y }
    ];

    for (const p of corners) {
      if (this.pointInTriangle(p.x, p.y, baseX1, baseY1, baseX2, baseY2, tipX, tipY)) {
        return true;
      }
    }
    return false;
  }

  private pointInTriangle(px: number, py: number, x1: number, y1: number, x2: number, y2: number, x3: number, y3: number): boolean {
    const areaOrig = Math.abs((x1 * (y2 - y3) + x2 * (y3 - y1) + x3 * (y1 - y2)) / 2);
    const area1 = Math.abs((px * (y2 - y3) + x2 * (y3 - py) + x3 * (py - y2)) / 2);
    const area2 = Math.abs((x1 * (py - y3) + px * (y3 - y1) + x3 * (y1 - py)) / 2);
    const area3 = Math.abs((x1 * (y2 - py) + x2 * (py - y1) + px * (y1 - y2)) / 2);
    return Math.abs(areaOrig - (area1 + area2 + area3)) < 0.1;
  }

  private updateAmbientParticles(dt: number) {
    const biome = this.getBiomeForLevel(this.currentLevel);

    for (let i = this.ambientParticles.length - 1; i >= 0; i--) {
      const p = this.ambientParticles[i];
      p.x += p.vx * dt;
      p.y += p.vy * dt;
      p.angle += p.spinSpeed * dt;

      if (p.x < this.camera.x - 100) {
        this.ambientParticles.splice(i, 1);
        this.ambientParticles.push(this.createAmbientParticle(null, biome));
      }
    }
  }

  private updateBots(dt: number) {
    if (this.mode !== 'race') return;

    const now = Date.now();

    for (const bot of this.bots) {
      if (bot.isDead) continue;

      bot.x += bot.baseSpeed * dt;

      if (now - bot.lastDecisionTime > bot.decisionInterval * 1000) {
        bot.lastDecisionTime = now;
        this.makeAIBotDecision(bot);
      }

      bot.vy += (bot.targetVy - bot.vy) * 14 * dt;
      bot.y += bot.vy * dt;

      const borderTop = 40;
      const borderBottom = this.height - 40;
      if (bot.y < borderTop + bot.height / 2) {
        bot.y = borderTop + bot.height / 2;
        bot.vy = 0;
      }
      if (bot.y > borderBottom - bot.height / 2) {
        bot.y = borderBottom - bot.height / 2;
        bot.vy = 0;
      }

      bot.angle = Math.atan2(bot.vy, bot.baseSpeed) * 0.8;

      bot.trail.push({ x: bot.x, y: bot.y, time: now });
      bot.trail = bot.trail.filter(pt => now - pt.time < 500);

      this.checkBotCollisions(bot);
    }

    const racers = [
      { name: "YOU", x: this.player.x, isDead: this.player.isDead, color: '#00ff66' },
      ...this.bots.map(b => ({ name: b.name, x: b.x, isDead: b.isDead, color: b.color }))
    ];
    racers.sort((a, b) => b.x - a.x);
    this.callbacks.onLeaderboardUpdate(racers);

    // Check race finish
    if (!this.player.isDead && this.player.x >= this.levelLength - 800) {
      const isWinner = racers[0].name === 'YOU';
      if (isWinner) {
        this.triggerVictory();
      } else {
        this.triggerCrash();
      }
    }
  }

  private makeAIBotDecision(bot: BotState) {
    const lookahead = 240;
    let obstacleInPath: Obstacle | null = null;

    for (const obs of this.obstacles) {
      if (obs.x > bot.x && obs.x < bot.x + lookahead) {
        if (obs.type === 'block') {
          if (bot.y > obs.y - 40 && bot.y < obs.y + obs.height + 40) {
            obstacleInPath = obs;
            break;
          }
        } else if (obs.type === 'spike') {
          const isCeiling = obs.dir === 1;
          if (isCeiling && bot.y < 180) {
            obstacleInPath = obs;
            break;
          }
          if (!isCeiling && bot.y > this.height - 180) {
            obstacleInPath = obs;
            break;
          }
        }
      }
    }

    if (obstacleInPath) {
      if (obstacleInPath.type === 'block') {
        const ceilingDist = obstacleInPath.y - 40;
        const floorDist = (this.height - 40) - (obstacleInPath.y + obstacleInPath.height);
        bot.targetVy = ceilingDist > floorDist ? -390 : 390;
      } else {
        bot.targetVy = obstacleInPath.dir === 1 ? 390 : -390;
      }
    } else {
      if (bot.y < 160) {
        bot.targetVy = 390;
      } else if (bot.y > this.height - 160) {
        bot.targetVy = -390;
      } else {
        if (Math.random() < 0.15) {
          bot.targetVy = -bot.targetVy;
        }
      }
    }
  }

  private checkBotCollisions(bot: BotState) {
    const bW = bot.width * 0.6;
    const bH = bot.height * 0.6;
    const bX = bot.x - bW / 2;
    const bY = bot.y - bH / 2;

    for (const obs of this.obstacles) {
      if (obs.x < bot.x - 50 || obs.x > bot.x + 150) continue;

      if (obs.type === 'block') {
        if (this.rectsIntersect(bX, bY, bW, bH, obs.x, obs.y, obs.width, obs.height)) {
          bot.isDead = true;
          break;
        }
      } else if (obs.type === 'spike') {
        const sY = obs.dir === 1 ? obs.y : obs.y - obs.height;
        if (this.rectsIntersect(bX, bY, bW, bH, obs.x, sY, obs.width, obs.height)) {
          bot.isDead = true;
          break;
        }
      }
    }

    if (bot.y - bH / 2 <= 42 || bot.y + bH / 2 >= this.height - 42) {
      bot.isDead = true;
    }
  }

  // --- RENDERING ---
  public render() {
    const ctx = this.ctx;
    ctx.clearRect(0, 0, this.canvas.width, this.canvas.height);

    // 1. Procedural Hexagon Background
    if (this.hexPatternCanvas) {
      ctx.save();
      const left = -(this.bgScrollX * 0.3) % this.hexPatternWidth;
      const top = -(this.bgScrollY * 0.3) % this.hexPatternHeight;
      ctx.fillStyle = ctx.createPattern(this.hexPatternCanvas, 'repeat')!;
      ctx.translate(left, top);
      ctx.fillRect(-left, -top, this.canvas.width, this.canvas.height);
      ctx.restore();
    }

    // 2. Scaled Gameplay Arena
    ctx.save();
    ctx.translate(this.offsetX, this.offsetY);
    ctx.scale(this.scale, this.scale);

    ctx.save();
    ctx.beginPath();
    ctx.rect(0, 0, this.width, this.height);
    ctx.clip();

    this.drawBiomeWeatherGlow(ctx);
    this.drawAmbientDecorations(ctx);

    // Lanes Boundary lines
    ctx.save();
    ctx.translate(-this.camera.x, -this.camera.y);

    const biome = this.getBiomeForLevel(this.currentLevel);
    const borderColors: Record<BiomeType, string> = {
      forest: 'rgba(0, 255, 102, 0.4)',
      haunted: 'rgba(176, 38, 255, 0.4)',
      space: 'rgba(0, 243, 255, 0.4)',
      water: 'rgba(255, 0, 127, 0.4)',
      ancient: 'rgba(255, 170, 0, 0.4)'
    };
    const boundCol = borderColors[biome];

    ctx.strokeStyle = boundCol;
    ctx.lineWidth = 4;
    ctx.shadowBlur = 12;
    ctx.shadowColor = boundCol;

    ctx.beginPath();
    ctx.moveTo(this.camera.x - 200, 40);
    ctx.lineTo(this.camera.x + this.width + 200, 40);
    ctx.stroke();

    ctx.beginPath();
    ctx.moveTo(this.camera.x - 200, this.height - 40);
    ctx.lineTo(this.camera.x + this.width + 200, this.height - 40);
    ctx.stroke();

    ctx.restore();

    // In-game dynamic elements
    ctx.save();
    ctx.translate(-this.camera.x, -this.camera.y);

    this.drawObstacles(ctx);
    this.drawBots(ctx);
    this.drawPlayer(ctx);

    ctx.restore();
    ctx.restore(); // end clip
    ctx.restore(); // end scale
  }

  private drawBiomeWeatherGlow(ctx: CanvasRenderingContext2D) {
    const biome = this.getBiomeForLevel(this.currentLevel);
    ctx.save();

    if (biome === 'forest') {
      const grad = ctx.createLinearGradient(0, 0, 0, this.height);
      grad.addColorStop(0, 'rgba(0, 255, 102, 0.04)');
      grad.addColorStop(1, 'transparent');
      ctx.fillStyle = grad;
      ctx.fillRect(0, 0, this.width, this.height);
    } else if (biome === 'haunted') {
      const grad = ctx.createRadialGradient(this.width / 2, this.height / 2, 200, this.width / 2, this.height / 2, this.width / 2 + 200);
      grad.addColorStop(0, 'transparent');
      grad.addColorStop(1, 'rgba(176, 38, 255, 0.12)');
      ctx.fillStyle = grad;
      ctx.fillRect(0, 0, this.width, this.height);
    } else if (biome === 'space') {
      ctx.fillStyle = 'rgba(0, 243, 255, 0.015)';
      ctx.fillRect(0, 0, this.width, this.height);
    } else if (biome === 'water') {
      const grad = ctx.createLinearGradient(0, 0, 0, this.height);
      grad.addColorStop(0, 'rgba(0, 59, 255, 0.1)');
      grad.addColorStop(1, 'rgba(0, 243, 255, 0.15)');
      ctx.fillStyle = grad;
      ctx.fillRect(0, 0, this.width, this.height);
    } else if (biome === 'ancient') {
      ctx.fillStyle = 'rgba(255, 170, 0, 0.03)';
      ctx.fillRect(0, 0, this.width, this.height);
    }

    ctx.restore();
  }

  private drawAmbientDecorations(ctx: CanvasRenderingContext2D) {
    ctx.save();
    this.ambientParticles.forEach(p => {
      ctx.globalAlpha = p.alpha;
      ctx.fillStyle = p.color;

      if (p.type === 'forest') {
        ctx.save();
        ctx.translate(p.x, p.y);
        ctx.rotate(p.angle);
        ctx.beginPath();
        ctx.ellipse(0, 0, p.size, p.size * 0.5, 0, 0, Math.PI * 2);
        ctx.fill();
        ctx.restore();
      } else if (p.type === 'water') {
        ctx.strokeStyle = p.color;
        ctx.lineWidth = 1.2;
        ctx.beginPath();
        ctx.arc(p.x, p.y, p.size, 0, Math.PI * 2);
        ctx.stroke();
      } else {
        ctx.beginPath();
        ctx.arc(p.x, p.y, p.size, 0, Math.PI * 2);
        ctx.fill();
      }
    });
    ctx.restore();
  }

  private drawObstacles(ctx: CanvasRenderingContext2D) {
    ctx.save();
    for (const obs of this.obstacles) {
      if (obs.x < this.camera.x - 120 || obs.x > this.camera.x + this.width + 120) continue;

      ctx.shadowBlur = 10;
      ctx.shadowColor = obs.color;

      if (obs.type === 'spike') {
        ctx.strokeStyle = '#ffffff';
        ctx.lineWidth = 2.4;
        ctx.fillStyle = obs.color;

        ctx.beginPath();
        if (obs.dir === 1) {
          ctx.moveTo(obs.x, obs.y);
          ctx.lineTo(obs.x + obs.width, obs.y);
          ctx.lineTo(obs.x + obs.width / 2, obs.y + obs.height);
        } else {
          ctx.moveTo(obs.x, obs.y);
          ctx.lineTo(obs.x + obs.width, obs.y);
          ctx.lineTo(obs.x + obs.width / 2, obs.y - obs.height);
        }
        ctx.closePath();
        ctx.fill();
        ctx.stroke();
      } else if (obs.type === 'block') {
        ctx.strokeStyle = '#ffffff';
        ctx.lineWidth = 2.4;
        ctx.fillStyle = 'rgba(2, 6, 10, 0.95)';

        ctx.fillRect(obs.x, obs.y, obs.width, obs.height);
        ctx.strokeRect(obs.x, obs.y, obs.width, obs.height);

        ctx.strokeStyle = obs.color;
        ctx.lineWidth = 1.4;
        ctx.strokeRect(obs.x + 4, obs.y + 4, obs.width - 8, obs.height - 8);
      } else if (obs.type === 'gate') {
        ctx.strokeStyle = '#ffffff';
        ctx.lineWidth = 4;
        ctx.fillStyle = 'rgba(0, 243, 255, 0.35)';
        ctx.fillRect(obs.x, obs.y, obs.width, obs.height);
        ctx.strokeRect(obs.x, obs.y, obs.width, obs.height);
      }
    }
    ctx.restore();
  }

  private drawBots(ctx: CanvasRenderingContext2D) {
    if (this.mode !== 'race') return;

    for (const bot of this.bots) {
      if (bot.isDead) continue;

      if (bot.trail.length >= 2) {
        ctx.save();
        ctx.shadowBlur = 8;
        ctx.shadowColor = bot.color;
        ctx.lineWidth = 2.4;
        for (let i = 1; i < bot.trail.length; i++) {
          const pt1 = bot.trail[i - 1];
          const pt2 = bot.trail[i];
          const age = Date.now() - pt2.time;
          const opacity = Math.max(0, 1 - age / 500);
          ctx.strokeStyle = bot.color;
          ctx.globalAlpha = opacity * 0.75;
          ctx.beginPath();
          ctx.moveTo(pt1.x, pt1.y);
          ctx.lineTo(pt2.x, pt2.y);
          ctx.stroke();
        }
        ctx.restore();
      }

      ctx.save();
      ctx.translate(bot.x, bot.y);
      ctx.rotate(bot.angle);

      ctx.strokeStyle = '#ffffff';
      ctx.lineWidth = 2;
      ctx.fillStyle = bot.color;
      ctx.shadowColor = bot.color;
      ctx.shadowBlur = 8;

      ctx.beginPath();
      ctx.moveTo(bot.width / 2, 0);
      ctx.lineTo(-bot.width / 2, -bot.height / 2);
      ctx.lineTo(-bot.width / 4, 0);
      ctx.lineTo(-bot.width / 2, bot.height / 2);
      ctx.closePath();
      ctx.fill();
      ctx.stroke();

      ctx.restore();
    }
  }

  private drawPlayer(ctx: CanvasRenderingContext2D) {
    if (this.player.isDead) {
      this.drawPlayerParticles(ctx);
      return;
    }

    const skin = getSkinById(this.currentShapeId);

    // 1. Trail
    this.drawPlayerTrail(ctx, skin);

    // 2. Playable Shape
    ctx.save();
    ctx.translate(this.player.x, this.player.y);
    ctx.rotate(this.player.angle);

    drawShape(ctx, skin, this.player.width, this.player.animTimer, true);

    ctx.restore();

    // 3. Engine combustion sparks
    this.drawPlayerParticles(ctx);
  }

  private drawPlayerTrail(ctx: CanvasRenderingContext2D, skin: ShapeSkin) {
    if (this.player.trail.length < 2) return;

    ctx.save();
    ctx.shadowBlur = 12;
    ctx.shadowColor = skin.trailColor;

    if (skin.trailType === 'particles') {
      this.player.trail.forEach(pt => {
        const age = Date.now() - pt.time;
        const opacity = Math.max(0, 1 - age / 900);
        ctx.fillStyle = skin.trailColor;
        ctx.globalAlpha = opacity * 0.85;
        ctx.beginPath();
        ctx.arc(pt.x, pt.y, 4, 0, Math.PI * 2);
        ctx.fill();
      });
    } else if (skin.trailType === 'shadow') {
      ctx.lineWidth = 2.0;
      for (let offset = -6; offset <= 6; offset += 6) {
        ctx.beginPath();
        for (let i = 1; i < this.player.trail.length; i++) {
          const pt1 = this.player.trail[i - 1];
          const pt2 = this.player.trail[i];
          const age = Date.now() - pt2.time;
          const opacity = Math.max(0, 1 - age / 900);
          ctx.strokeStyle = skin.trailColor;
          ctx.globalAlpha = opacity * 0.4;
          if (i === 1) ctx.moveTo(pt1.x, pt1.y + offset);
          ctx.lineTo(pt2.x, pt2.y + offset);
        }
        ctx.stroke();
      }
    } else if (skin.trailType === 'rainbow') {
      ctx.lineWidth = 4.0;
      for (let i = 1; i < this.player.trail.length; i++) {
        const pt1 = this.player.trail[i - 1];
        const pt2 = this.player.trail[i];
        const age = Date.now() - pt2.time;
        const opacity = Math.max(0, 1 - age / 900);
        const hue = (i * 12) % 360;
        ctx.strokeStyle = `hsla(${hue}, 100%, 50%, ${opacity * 0.85})`;
        ctx.beginPath();
        ctx.moveTo(pt1.x, pt1.y);
        ctx.lineTo(pt2.x, pt2.y);
        ctx.stroke();
      }
    } else if (skin.trailType === 'cosmic-vortex') {
      ctx.lineWidth = 3.5;
      for (let i = 1; i < this.player.trail.length; i++) {
        const pt1 = this.player.trail[i - 1];
        const pt2 = this.player.trail[i];
        const age = Date.now() - pt2.time;
        const opacity = Math.max(0, 1 - age / 900);
        ctx.strokeStyle = skin.trailColor;
        ctx.globalAlpha = opacity * 0.9;
        ctx.beginPath();
        ctx.moveTo(pt1.x, pt1.y + Math.sin(i * 0.4) * 4);
        ctx.lineTo(pt2.x, pt2.y + Math.sin(i * 0.4) * 4);
        ctx.stroke();
      }
    } else {
      ctx.lineWidth = 3.5;
      for (let i = 1; i < this.player.trail.length; i++) {
        const pt1 = this.player.trail[i - 1];
        const pt2 = this.player.trail[i];
        const age = Date.now() - pt2.time;
        const opacity = Math.max(0, 1 - age / 900);
        ctx.strokeStyle = skin.trailColor;
        ctx.globalAlpha = opacity * 0.85;
        ctx.beginPath();
        ctx.moveTo(pt1.x, pt1.y);
        ctx.lineTo(pt2.x, pt2.y);
        ctx.stroke();
      }
    }

    ctx.restore();
  }

  private drawPlayerParticles(ctx: CanvasRenderingContext2D) {
    ctx.save();
    for (const p of this.player.particles) {
      ctx.fillStyle = p.color;
      ctx.globalAlpha = p.alpha;
      ctx.shadowColor = p.color;
      ctx.shadowBlur = 6;
      ctx.beginPath();
      ctx.arc(p.x, p.y, p.size, 0, Math.PI * 2);
      ctx.fill();
    }
    ctx.restore();
  }
}
