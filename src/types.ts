export type ShapeCategory = 'all' | 'basic' | 'geometric' | 'premium' | 'animated' | 'special';

export type ShapeRarity = 'common' | 'rare' | 'epic' | 'legendary' | 'mythic';

export type TrailType =
  | 'wave'
  | 'particles'
  | 'shadow'
  | 'rainbow'
  | 'cyber-dash'
  | 'plasma-stream'
  | 'cosmic-vortex';

export type RenderShapeType =
  | 'arrow'
  | 'triangle'
  | 'circle'
  | 'square'
  | 'rounded-square'
  | 'rectangle'
  | 'diamond'
  | 'hexagon'
  | 'octagon'
  | 'star'
  | 'pentagon'
  | 'heart'
  | 'capsule'
  | 'ring'
  | 'cross'
  | 'lightning'
  | 'plus'
  | 'cyber-shard'
  | 'quantum-stealth'
  | 'plasma-core'
  | 'supernova'
  | 'phantom-blade'
  | 'void-warp'
  | 'solar-aegis'
  | 'chrono-dial';

export type AnimationType =
  | 'streamline'
  | 'spin'
  | 'pulse'
  | 'orbit'
  | 'wobble'
  | 'shimmer'
  | 'vortex';

export interface ShapeSkin {
  id: string;
  name: string;
  category: 'basic' | 'geometric' | 'premium' | 'animated' | 'special';
  price: number;
  description: string;
  rarity: ShapeRarity;
  color: string;
  secondaryColor: string;
  trailColor: string;
  particleColor: string;
  trailType: TrailType;
  renderType: RenderShapeType;
  animationType: AnimationType;
  features: string[];
  stats: {
    aerodynamics: number;
    glowIntensity: number;
    trailLength: number;
  };
}

export type GameState =
  | 'menu'
  | 'modes'
  | 'level_select'
  | 'shop'
  | 'profile'
  | 'playing'
  | 'paused'
  | 'gameover'
  | 'victory';

export type GameMode = 'classic' | 'endless' | 'race';

export type BiomeType = 'forest' | 'haunted' | 'space' | 'water' | 'ancient';

export interface Obstacle {
  type: 'spike' | 'block' | 'gate';
  x: number;
  y: number;
  width: number;
  height: number;
  dir?: number; // 1 = ceiling downward, -1 = floor upward
  color: string;
}

export interface Particle {
  x: number;
  y: number;
  vx: number;
  vy: number;
  size: number;
  color: string;
  alpha: number;
  life: number;
}

export interface TrailPoint {
  x: number;
  y: number;
  time: number;
}

export interface PlayerState {
  x: number;
  y: number;
  width: number;
  height: number;
  vy: number;
  targetVy: number;
  angle: number;
  baseSpeed: number;
  speedMultiplier: number;
  isDead: boolean;
  trail: TrailPoint[];
  particles: Particle[];
  hasCrashedThisRun: boolean;
  lastCoinPayout?: number;
  animTimer: number;
}

export interface BotState {
  id: string;
  name: string;
  x: number;
  y: number;
  vy: number;
  width: number;
  height: number;
  angle: number;
  color: string;
  baseSpeed: number;
  isDead: boolean;
  lastDecisionTime: number;
  decisionInterval: number;
  trail: TrailPoint[];
  targetVy: number;
  shapeType: RenderShapeType;
}

export interface UserStats {
  coins: number;
  streakDays: number;
  lastLoginDate: string;
  username: string;
  country: string;
  bio: string;
  unlockedLevels: Record<number, number>; // levelNumber -> percent (0-100)
  equippedShape: string;
  ownedShapes: string[];
  eloRating: number;
  totalCrashes: number;
  totalPerfectRuns: number;
  endlessHighScore: number;
  raceWins: number;
  isMuted: boolean;
}
