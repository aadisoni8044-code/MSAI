import { MapThemeConfig, MapThemeId, Particle } from '../types/game';

export const THEMES: Record<MapThemeId, MapThemeConfig> = {
  lakeside_meadow: {
    id: 'lakeside_meadow',
    name: 'Lakeside Meadow',
    description: 'Serene lakeside with rolling green hills, blooming flowers, and gentle breezes.',
    skyColor: '#52b7d8',
    groundColor: '#3a7d44',
    accentColor: '#8ee4af',
    parallaxColors: ['#1f4257', '#2e6f40', '#48a960', '#7fd88d'],
    particleType: 'butterflies',
    particleColor: '#ffea79',
    musicMood: 'cheerful',
    hazardTypes: ['slime', 'spike'],
    bgSpeedMultiplier: 1.0,
  },
  countryside: {
    id: 'countryside',
    name: 'Sunny Countryside',
    description: 'Open golden pastures, distant windmills, and warm amber sunbeams.',
    skyColor: '#f7b05b',
    groundColor: '#c68b59',
    accentColor: '#f3c68f',
    parallaxColors: ['#884a39', '#ab6b51', '#d49b6a', '#f5cb88'],
    particleType: 'pollen',
    particleColor: '#ffffff',
    musicMood: 'breezy',
    hazardTypes: ['slime', 'goblin', 'spike'],
    bgSpeedMultiplier: 1.1,
  },
  deep_forest: {
    id: 'deep_forest',
    name: 'Deep Forest',
    description: 'Lush ancient woods with towering canopy trees and mystical glowing flora.',
    skyColor: '#1d3557',
    groundColor: '#2d6a4f',
    accentColor: '#52b788',
    parallaxColors: ['#0b1d1d', '#133c32', '#1b5e4b', '#2d8a68'],
    particleType: 'leaves',
    particleColor: '#74c69d',
    musicMood: 'mystical',
    hazardTypes: ['bat', 'goblin', 'spike'],
    bgSpeedMultiplier: 1.2,
  },
  moonlit_graveyard: {
    id: 'moonlit_graveyard',
    name: 'Moonlit Graveyard',
    description: 'Eerie gothic cemetery under a massive luminescent moon and misty fog.',
    skyColor: '#0d1b2a',
    groundColor: '#2b2d42',
    accentColor: '#8d99ae',
    parallaxColors: ['#050811', '#121829', '#1d263b', '#2e3a59'],
    particleType: 'wisps',
    particleColor: '#90e0ef',
    musicMood: 'spooky',
    hazardTypes: ['bat', 'fireball', 'spike'],
    bgSpeedMultiplier: 1.25,
  },
  desert: {
    id: 'desert',
    name: 'Scorching Desert',
    description: 'Sweeping sand dunes, ancient ruins, and shimmering heatwaves.',
    skyColor: '#e07a5f',
    groundColor: '#d4a373',
    accentColor: '#f4a261',
    parallaxColors: ['#6b2d22', '#8d4133', '#bd6b47', '#e89f6d'],
    particleType: 'sand',
    particleColor: '#fefae0',
    musicMood: 'harsh',
    hazardTypes: ['slime', 'bat', 'spike'],
    bgSpeedMultiplier: 1.3,
  },
  underground_cave: {
    id: 'underground_cave',
    name: 'Underground Cave',
    description: 'Subterranean cavern filled with stalactites, bioluminescent crystals, and abyss depths.',
    skyColor: '#080811',
    groundColor: '#22223b',
    accentColor: '#7209b7',
    parallaxColors: ['#030308', '#0c0c1b', '#181830', '#2d2d50'],
    particleType: 'dust',
    particleColor: '#b5179e',
    musicMood: 'echoey',
    hazardTypes: ['bat', 'spike', 'lava'],
    bgSpeedMultiplier: 1.4,
  },
  lava_fortress: {
    id: 'lava_fortress',
    name: 'Lava Fortress',
    description: 'Hellish volcanic citadel with rivers of molten magma and searing fiery embers.',
    skyColor: '#200005',
    groundColor: '#370617',
    accentColor: '#ffb703',
    parallaxColors: ['#120002', '#2c0006', '#540804', '#9d0208'],
    particleType: 'embers',
    particleColor: '#ff4d00',
    musicMood: 'intense',
    hazardTypes: ['dragon', 'fireball', 'lava', 'spike'],
    bgSpeedMultiplier: 1.5,
  },
};

export class ParallaxBackground {
  private currentTheme: MapThemeConfig;
  private particles: Particle[] = [];
  private scrollOffset: number = 0;

  constructor(themeId: MapThemeId = 'lakeside_meadow') {
    this.currentTheme = THEMES[themeId];
  }

  public setTheme(themeId: MapThemeId): void {
    this.currentTheme = THEMES[themeId];
    this.particles = [];
  }

  public getTheme(): MapThemeConfig {
    return this.currentTheme;
  }

  public update(speed: number, width: number, height: number): void {
    this.scrollOffset += speed * this.currentTheme.bgSpeedMultiplier;

    // Spawn theme ambient particles
    if (this.particles.length < 35 && Math.random() < 0.4) {
      this.particles.push(this.createParticle(width, height));
    }

    // Update existing particles
    for (let i = this.particles.length - 1; i >= 0; i--) {
      const p = this.particles[i];
      p.x += p.vx - speed * 0.2;
      p.y += p.vy;
      p.life += 1;

      if (p.life >= p.maxLife || p.x < -20 || p.x > width + 20 || p.y < -20 || p.y > height + 20) {
        this.particles.splice(i, 1);
      }
    }
  }

  private createParticle(width: number, height: number): Particle {
    const pType = this.currentTheme.particleType;
    const color = this.currentTheme.particleColor;

    let vx = (Math.random() - 0.5) * 1.5;
    let vy = (Math.random() - 0.5) * 1.2;
    let size = Math.random() * 4 + 2;
    let maxLife = Math.floor(Math.random() * 200 + 100);

    if (pType === 'embers') {
      vy = -Math.random() * 2 - 0.5;
      vx = (Math.random() - 0.5) * 2;
      size = Math.random() * 5 + 2;
    } else if (pType === 'sand') {
      vx = -Math.random() * 4 - 2;
      vy = (Math.random() - 0.5) * 0.8;
      size = Math.random() * 3 + 1;
    } else if (pType === 'leaves') {
      vy = Math.random() * 1 + 0.5;
      vx = Math.sin(Math.random() * Math.PI) * 1.5 - 1;
    } else if (pType === 'wisps') {
      size = Math.random() * 8 + 4;
      maxLife = Math.floor(Math.random() * 300 + 150);
    }

    return {
      x: Math.random() * width + (pType === 'sand' ? width : 0),
      y: pType === 'embers' ? height - 50 : Math.random() * height,
      vx,
      vy,
      size,
      color,
      alpha: Math.random() * 0.7 + 0.3,
      life: 0,
      maxLife,
      rotation: Math.random() * Math.PI * 2,
    };
  }

  public render(ctx: CanvasRenderingContext2D, width: number, height: number): void {
    // 1. Sky Gradient Background
    const skyGradient = ctx.createLinearGradient(0, 0, 0, height);
    skyGradient.addColorStop(0, this.currentTheme.skyColor);
    skyGradient.addColorStop(1, this.currentTheme.groundColor);
    ctx.fillStyle = skyGradient;
    ctx.fillRect(0, 0, width, height);

    // 2. Celestial / Biome Background Details (Sun, Moon, Volcanic Glow)
    this.renderCelestialBody(ctx, width, height);

    // 3. Parallax Mountain / Hill / Cavern Silhouettes
    const layers = this.currentTheme.parallaxColors;
    layers.forEach((color, index) => {
      const speedFactor = (index + 1) * 0.15;
      const layerOffset = (this.scrollOffset * speedFactor) % width;
      const baseHeight = height * (0.4 + index * 0.12);

      ctx.fillStyle = color;

      // Draw double width loop for seamless parallax scrolling
      for (let pass = 0; pass < 2; pass++) {
        const xStart = pass * width - layerOffset;

        ctx.beginPath();
        ctx.moveTo(xStart, height);

        // Generate layered mountain / organic silhouette curves
        for (let x = 0; x <= width; x += 40) {
          const globalX = x + pass * width + layerOffset * index;
          const hillY = Math.sin((globalX + index * 100) * 0.005) * (30 + index * 20) +
                        Math.cos(globalX * 0.015) * 15;
          ctx.lineTo(xStart + x, baseHeight - hillY);
        }

        ctx.lineTo(xStart + width, height);
        ctx.closePath();
        ctx.fill();
      }
    });

    // 4. Render Ambient Theme Particles
    this.particles.forEach((p) => {
      ctx.save();
      ctx.globalAlpha = p.alpha * (1 - p.life / p.maxLife);
      ctx.fillStyle = p.color;

      if (this.currentTheme.particleType === 'wisps') {
        const radG = ctx.createRadialGradient(p.x, p.y, 0, p.x, p.y, p.size);
        radG.addColorStop(0, p.color);
        radG.addColorStop(1, 'transparent');
        ctx.fillStyle = radG;
        ctx.beginPath();
        ctx.arc(p.x, p.y, p.size, 0, Math.PI * 2);
        ctx.fill();
      } else {
        ctx.beginPath();
        ctx.arc(p.x, p.y, p.size, 0, Math.PI * 2);
        ctx.fill();
      }
      ctx.restore();
    });
  }

  private renderCelestialBody(ctx: CanvasRenderingContext2D, width: number, height: number): void {
    const themeId = this.currentTheme.id;

    if (themeId === 'moonlit_graveyard' || themeId === 'underground_cave') {
      // Glow Moon
      const moonX = width * 0.75;
      const moonY = height * 0.25;
      const moonGlow = ctx.createRadialGradient(moonX, moonY, 15, moonX, moonY, 90);
      moonGlow.addColorStop(0, 'rgba(230, 240, 255, 0.9)');
      moonGlow.addColorStop(0.4, 'rgba(180, 210, 255, 0.3)');
      moonGlow.addColorStop(1, 'rgba(180, 210, 255, 0)');

      ctx.fillStyle = moonGlow;
      ctx.beginPath();
      ctx.arc(moonX, moonY, 90, 0, Math.PI * 2);
      ctx.fill();

      ctx.fillStyle = '#f0f5ff';
      ctx.beginPath();
      ctx.arc(moonX, moonY, 32, 0, Math.PI * 2);
      ctx.fill();
    } else if (themeId === 'lava_fortress') {
      // Volcanic Heat Aura
      const lavaGlow = ctx.createLinearGradient(0, height - 100, 0, height);
      lavaGlow.addColorStop(0, 'rgba(255, 60, 0, 0)');
      lavaGlow.addColorStop(1, 'rgba(255, 80, 0, 0.4)');
      ctx.fillStyle = lavaGlow;
      ctx.fillRect(0, height - 100, width, 100);
    } else {
      // Sun
      const sunX = width * 0.8;
      const sunY = height * 0.2;
      const sunGlow = ctx.createRadialGradient(sunX, sunY, 10, sunX, sunY, 70);
      sunGlow.addColorStop(0, 'rgba(255, 240, 180, 0.9)');
      sunGlow.addColorStop(0.5, 'rgba(255, 200, 100, 0.25)');
      sunGlow.addColorStop(1, 'rgba(255, 200, 100, 0)');

      ctx.fillStyle = sunGlow;
      ctx.beginPath();
      ctx.arc(sunX, sunY, 70, 0, Math.PI * 2);
      ctx.fill();

      ctx.fillStyle = '#fff4cc';
      ctx.beginPath();
      ctx.arc(sunX, sunY, 26, 0, Math.PI * 2);
      ctx.fill();
    }
  }
}
