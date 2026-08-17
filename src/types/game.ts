export type GameState = 'START' | 'MAP_SELECT' | 'PLAYING' | 'PAUSED' | 'GAMEOVER';

export type MapThemeId =
  | 'lakeside_meadow'
  | 'countryside'
  | 'deep_forest'
  | 'moonlit_graveyard'
  | 'desert'
  | 'underground_cave'
  | 'lava_fortress';

export interface MapThemeConfig {
  id: MapThemeId;
  name: string;
  description: string;
  skyColor: string;
  groundColor: string;
  accentColor: string;
  parallaxColors: string[];
  particleType: 'butterflies' | 'pollen' | 'leaves' | 'wisps' | 'sand' | 'dust' | 'embers';
  particleColor: string;
  musicMood: 'cheerful' | 'breezy' | 'mystical' | 'spooky' | 'harsh' | 'echoey' | 'intense';
  hazardTypes: ('spike' | 'lava' | 'bat' | 'slime' | 'goblin' | 'dragon' | 'fireball')[];
  bgSpeedMultiplier: number;
}

export interface InputState {
  left: boolean;
  right: boolean;
  jump: boolean;
  attack: boolean;
  pause: boolean;
  restart: boolean;
  // Edge triggers (pressed this frame)
  jumpPressed: boolean;
  attackPressed: boolean;
  pausePressed: boolean;
  restartPressed: boolean;
}

export interface PlayerStats {
  x: number;
  y: number;
  width: number;
  height: number;
  vx: number;
  vy: number;
  isGrounded: boolean;
  isJumping: boolean;
  canDoubleJump: boolean;
  isAttacking: boolean;
  attackTimer: number;
  attackCooldown: number;
  attackBox: { x: number; y: number; width: number; height: number };
  facingRight: boolean;
  health: number;
  maxHealth: number;
  invulnerableTimer: number;
  animationFrame: number;
}

export type EnemyType = 'slime' | 'goblin' | 'bat' | 'dragon' | 'spike' | 'lava' | 'fireball';

export interface Entity {
  id: string;
  type: EnemyType;
  x: number;
  y: number;
  width: number;
  height: number;
  vx: number;
  vy: number;
  health: number;
  isHazard: boolean;
  color: string;
  sineOffset?: number;
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
  maxLife: number;
  rotation?: number;
}

export interface HighScore {
  themeId: MapThemeId;
  score: number;
  date: string;
}

export interface GameMetrics {
  score: number;
  highScore: number;
  speedMultiplier: number;
  distance: number;
  coins: number;
}
