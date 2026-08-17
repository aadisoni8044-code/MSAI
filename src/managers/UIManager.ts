import { GameState, MapThemeConfig, MapThemeId } from '../types/game';
import { THEMES } from '../engine/ParallaxBackground';

export class UIManager {
  private startScreen: HTMLElement;
  private mapSelectScreen: HTMLElement;
  private pauseOverlay: HTMLElement;
  private gameOverOverlay: HTMLElement;
  private hudOverlay: HTMLElement;

  private scoreValEl: HTMLElement;
  private highScoreValEl: HTMLElement;
  private speedValEl: HTMLElement;
  private heartsContainer: HTMLElement;

  private finalScoreEl: HTMLElement;
  private bestScoreEl: HTMLElement;

  private mapCardTitle: HTMLElement;
  private mapCardDesc: HTMLElement;
  private mapCardBadge: HTMLElement;
  private mapPreviewBox: HTMLElement;

  private themeList: MapThemeConfig[];
  private currentThemeIndex: number = 0;

  private audioCtx: AudioContext | null = null;

  constructor() {
    this.startScreen = document.getElementById('start-screen')!;
    this.mapSelectScreen = document.getElementById('map-select-screen')!;
    this.pauseOverlay = document.getElementById('pause-overlay')!;
    this.gameOverOverlay = document.getElementById('gameover-overlay')!;
    this.hudOverlay = document.getElementById('hud-overlay')!;

    this.scoreValEl = document.getElementById('score-val')!;
    this.highScoreValEl = document.getElementById('highscore-val')!;
    this.speedValEl = document.getElementById('speed-val')!;
    this.heartsContainer = document.getElementById('hearts-container')!;

    this.finalScoreEl = document.getElementById('final-score-val')!;
    this.bestScoreEl = document.getElementById('best-score-val')!;

    this.mapCardTitle = document.getElementById('map-card-title')!;
    this.mapCardDesc = document.getElementById('map-card-desc')!;
    this.mapCardBadge = document.getElementById('map-card-badge')!;
    this.mapPreviewBox = document.getElementById('map-preview-box')!;

    this.themeList = Object.values(THEMES);
  }

  public setScreenState(state: GameState): void {
    this.startScreen.classList.add('hidden');
    this.mapSelectScreen.classList.add('hidden');
    this.pauseOverlay.classList.add('hidden');
    this.gameOverOverlay.classList.add('hidden');
    this.hudOverlay.classList.add('hidden');

    switch (state) {
      case 'START':
        this.startScreen.classList.remove('hidden');
        break;
      case 'MAP_SELECT':
        this.mapSelectScreen.classList.remove('hidden');
        this.updateMapCarousel();
        break;
      case 'PLAYING':
        this.hudOverlay.classList.remove('hidden');
        break;
      case 'PAUSED':
        this.hudOverlay.classList.remove('hidden');
        this.pauseOverlay.classList.remove('hidden');
        break;
      case 'GAMEOVER':
        this.hudOverlay.classList.remove('hidden');
        this.gameOverOverlay.classList.remove('hidden');
        break;
    }
  }

  public getSelectedThemeId(): MapThemeId {
    return this.themeList[this.currentThemeIndex].id;
  }

  public nextMap(): void {
    this.currentThemeIndex = (this.currentThemeIndex + 1) % this.themeList.length;
    this.updateMapCarousel();
    this.playSfx('click');
  }

  public prevMap(): void {
    this.currentThemeIndex = (this.currentThemeIndex - 1 + this.themeList.length) % this.themeList.length;
    this.updateMapCarousel();
    this.playSfx('click');
  }

  private updateMapCarousel(): void {
    const theme = this.themeList[this.currentThemeIndex];
    this.mapCardTitle.innerText = theme.name;
    this.mapCardDesc.innerText = theme.description;
    this.mapCardBadge.innerText = `SPEED: ${theme.bgSpeedMultiplier}x | HAZARDS: ${theme.hazardTypes.join(', ').toUpperCase()}`;

    // Apply preview gradient
    this.mapPreviewBox.style.background = `linear-gradient(135deg, ${theme.skyColor}, ${theme.groundColor})`;
    this.mapPreviewBox.style.borderColor = theme.accentColor;
  }

  public updateHUD(score: number, highScore: number, speedMultiplier: number, health: number, maxHealth: number): void {
    this.scoreValEl.innerText = score.toString();
    this.highScoreValEl.innerText = highScore.toString();
    this.speedValEl.innerText = `${speedMultiplier.toFixed(1)}x`;

    // Render health hearts
    this.heartsContainer.innerHTML = '';
    for (let i = 0; i < maxHealth; i++) {
      const heart = document.createElement('span');
      heart.className = `heart ${i < health ? 'full' : 'empty'}`;
      heart.innerText = i < health ? '❤️' : '🖤';
      this.heartsContainer.appendChild(heart);
    }
  }

  public updateGameOverScreen(score: number, themeId: MapThemeId): void {
    this.finalScoreEl.innerText = score.toString();
    const currentHigh = this.getHighScore(themeId);
    if (score > currentHigh) {
      this.saveHighScore(themeId, score);
      this.bestScoreEl.innerText = `${score} (NEW BEST!)`;
    } else {
      this.bestScoreEl.innerText = currentHigh.toString();
    }
  }

  public getHighScore(themeId: MapThemeId): number {
    const stored = localStorage.getItem(`speedy_games_hs_${themeId}`);
    return stored ? parseInt(stored, 10) : 0;
  }

  public saveHighScore(themeId: MapThemeId, score: number): void {
    localStorage.setItem(`speedy_games_hs_${themeId}`, score.toString());
  }

  // Synthesized Sound Effects Engine using Web Audio API
  public playSfx(type: 'jump' | 'attack' | 'hit' | 'score' | 'gameover' | 'click'): void {
    try {
      if (!this.audioCtx) {
        this.audioCtx = new (window.AudioContext || (window as any).webkitAudioContext)();
      }
      if (this.audioCtx.state === 'suspended') {
        this.audioCtx.resume();
      }

      const osc = this.audioCtx.createOscillator();
      const gain = this.audioCtx.createGain();
      osc.connect(gain);
      gain.connect(this.audioCtx.destination);

      const now = this.audioCtx.currentTime;

      if (type === 'jump') {
        osc.type = 'sine';
        osc.frequency.setValueAtTime(180, now);
        osc.frequency.exponentialRampToValueAtTime(450, now + 0.15);
        gain.gain.setValueAtTime(0.2, now);
        gain.gain.linearRampToValueAtTime(0.01, now + 0.15);
        osc.start(now);
        osc.stop(now + 0.15);
      } else if (type === 'attack') {
        osc.type = 'sawtooth';
        osc.frequency.setValueAtTime(300, now);
        osc.frequency.linearRampToValueAtTime(100, now + 0.1);
        gain.gain.setValueAtTime(0.3, now);
        gain.gain.linearRampToValueAtTime(0.01, now + 0.1);
        osc.start(now);
        osc.stop(now + 0.1);
      } else if (type === 'hit') {
        osc.type = 'square';
        osc.frequency.setValueAtTime(120, now);
        osc.frequency.linearRampToValueAtTime(40, now + 0.2);
        gain.gain.setValueAtTime(0.4, now);
        gain.gain.linearRampToValueAtTime(0.01, now + 0.2);
        osc.start(now);
        osc.stop(now + 0.2);
      } else if (type === 'score') {
        osc.type = 'triangle';
        osc.frequency.setValueAtTime(523.25, now);
        osc.frequency.setValueAtTime(659.25, now + 0.08);
        gain.gain.setValueAtTime(0.15, now);
        gain.gain.linearRampToValueAtTime(0.01, now + 0.16);
        osc.start(now);
        osc.stop(now + 0.16);
      } else if (type === 'click') {
        osc.type = 'sine';
        osc.frequency.setValueAtTime(400, now);
        gain.gain.setValueAtTime(0.1, now);
        gain.gain.linearRampToValueAtTime(0.01, now + 0.05);
        osc.start(now);
        osc.stop(now + 0.05);
      } else if (type === 'gameover') {
        osc.type = 'sawtooth';
        osc.frequency.setValueAtTime(250, now);
        osc.frequency.linearRampToValueAtTime(60, now + 0.5);
        gain.gain.setValueAtTime(0.3, now);
        gain.gain.linearRampToValueAtTime(0.01, now + 0.5);
        osc.start(now);
        osc.stop(now + 0.5);
      }
    } catch (e) {
      // Audio fallback silent
    }
  }
}
