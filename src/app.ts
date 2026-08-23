import { GameEngine } from './engine/gameEngine';
import { audioEngine } from './engine/audioEngine';
import { GameState, UserStats, BiomeType, ShapeSkin } from './types';
import { loadUserStats, saveUserStats, checkDailyStreak, calculateElo } from './data/storage';

import { ToastManager } from './ui/Toast';
import { MainMenu } from './ui/MainMenu';
import { GameModes } from './ui/GameModes';
import { LevelSelect } from './ui/LevelSelect';
import { ShapeShop } from './ui/ShapeShop';
import { HUD } from './ui/HUD';
import { Modals, ModalType } from './ui/Modals';

export class AppController {
  private rootElement: HTMLElement;
  private canvasElement: HTMLCanvasElement;
  private pointerOverlay: HTMLDivElement;

  private engine: GameEngine;
  private toastManager: ToastManager;

  // UI Components
  private mainMenuUI: MainMenu;
  private gameModesUI: GameModes;
  private levelSelectUI: LevelSelect;
  private shapeShopUI: ShapeShop;
  private hudUI: HUD;
  private modalsUI: Modals;

  // App & Screen Navigation States
  private gameState: GameState = 'menu';
  private activeModal: ModalType = null;

  // Game Metrics
  private progress: number = 0;
  private distanceMeters: number = 0;
  private currentLevel: number = 1;
  private currentBiome: BiomeType = 'forest';
  private isPracticeMode: boolean = false;
  private leaderboard: { name: string; x: number; isDead: boolean; color: string }[] = [];

  // Modal Specific
  private gameOverScoreText: string = '';
  private victoryLevel: number = 1;
  private victoryAttempts: number = 1;
  private victoryIsPerfect: boolean = false;

  // User Statistics & Persistence
  private stats: UserStats;

  constructor(rootElement: HTMLElement) {
    this.rootElement = rootElement;
    this.stats = loadUserStats();

    // Container styling
    this.rootElement.className = "relative w-screen h-screen overflow-hidden bg-[#010404] flex items-center justify-center select-none font-['Rajdhani']";

    // 1. Create HTML5 Canvas
    this.canvasElement = document.createElement('canvas');
    this.canvasElement.className = "absolute inset-0 w-full h-full block z-0";
    this.rootElement.appendChild(this.canvasElement);

    // 2. Create Transparent Input Capture Overlay
    this.pointerOverlay = document.createElement('div');
    this.pointerOverlay.className = "absolute inset-0 z-1 cursor-pointer touch-none select-none hidden";
    this.setupPointerEvents();
    this.rootElement.appendChild(this.pointerOverlay);

    // 3. Create Toast Manager
    this.toastManager = new ToastManager();
    this.rootElement.appendChild(this.toastManager.element);

    // 4. Initialize Game Engine
    this.engine = new GameEngine(this.canvasElement, {
      onProgressUpdate: (prog, dist, lvl, bio) => {
        this.progress = prog;
        this.distanceMeters = dist;
        this.currentLevel = lvl;
        this.currentBiome = bio;
        this.hudUI.updateState({
          progress: this.progress,
          distanceMeters: this.distanceMeters,
          currentLevel: this.currentLevel,
          biome: this.currentBiome
        });
      },
      onGameOver: (prog, scoreText) => {
        this.gameOverScoreText = scoreText;
        this.setActiveModal('gameover');
        this.updateStats({
          totalCrashes: this.stats.totalCrashes + 1,
          endlessHighScore: Math.max(this.stats.endlessHighScore, Math.floor(prog))
        });
      },
      onVictory: (lvl, attempts, isPerfect) => {
        this.victoryLevel = lvl;
        this.victoryAttempts = attempts;
        this.victoryIsPerfect = isPerfect;
        this.setActiveModal('victory');

        const nextLvl = lvl + 1;
        const newUnlocked = { ...this.stats.unlockedLevels, [lvl]: 100 };
        if (nextLvl <= 100 && newUnlocked[nextLvl] === undefined) {
          newUnlocked[nextLvl] = 0;
        }

        const bonusCoins = isPerfect ? 150 : 100;
        this.updateStats({
          coins: this.stats.coins + bonusCoins,
          totalPerfectRuns: isPerfect ? this.stats.totalPerfectRuns + 1 : this.stats.totalPerfectRuns,
          unlockedLevels: newUnlocked,
          raceWins: this.engine.mode === 'race' ? this.stats.raceWins + 1 : this.stats.raceWins
        });
      },
      onCoinEarned: (amount) => {
        this.updateStats({ coins: this.stats.coins + amount });
      },
      onLeaderboardUpdate: (racers) => {
        this.leaderboard = racers;
        this.hudUI.updateState({ leaderboard: this.leaderboard });
      }
    });

    this.engine.setEquippedShape(this.stats.equippedShape);

    // 5. Create UI Components
    this.mainMenuUI = new MainMenu(this.stats, {
      onOpenGameModes: () => this.setGameState('modes'),
      onOpenShop: () => this.setGameState('shop'),
      onOpenSettings: () => this.setActiveModal('settings'),
      onOpenProfile: () => this.setActiveModal('profile'),
      onOpenDailyRewards: () => this.setActiveModal('daily')
    });

    this.gameModesUI = new GameModes(this.stats, {
      onBack: () => this.setGameState('menu'),
      onSelectClassic: () => this.setGameState('level_select'),
      onSelectEndless: () => this.handleLaunchEndless(),
      onSelectRace: () => this.handleLaunchRace()
    });

    this.levelSelectUI = new LevelSelect(this.stats, {
      onBack: () => this.setGameState('modes'),
      onLaunchLevel: (lvl) => this.handleLaunchLevel(lvl),
      onUnlockLevelEarly: (lvl, cost) => this.handleUnlockLevelEarly(lvl, cost)
    });

    this.shapeShopUI = new ShapeShop(this.stats, {
      onBack: () => this.setGameState('menu'),
      onEquipShape: (shapeId) => this.handleEquipShape(shapeId),
      onBuyShape: (skin) => this.handleBuyShape(skin),
      onShowToast: (msg, type) => this.showToast(msg, type)
    });

    this.hudUI = new HUD({
      onPause: () => this.handlePause(),
      onTogglePractice: (enabled) => {
        this.isPracticeMode = enabled;
        this.engine.setPracticeMode(enabled);
        this.hudUI.updateState({ isPracticeMode: enabled });
      },
      onPlaceCheckpoint: () => this.engine.placeCheckpoint(),
      onClearCheckpoint: () => this.engine.clearCheckpoints()
    });

    this.modalsUI = new Modals(this.stats, {
      onClose: () => this.setActiveModal(null),
      onResume: () => this.handleResume(),
      onRestart: () => this.handleRestart(),
      onMainMenu: () => this.handleMainMenu(),
      onNextLevel: () => this.handleNextLevel(),
      onUpdateStats: (partial) => this.updateStats(partial),
      onShowToast: (msg, type) => this.showToast(msg, type)
    });

    // Append UI elements to Root
    this.rootElement.appendChild(this.mainMenuUI.element);
    this.rootElement.appendChild(this.gameModesUI.element);
    this.rootElement.appendChild(this.levelSelectUI.element);
    this.rootElement.appendChild(this.shapeShopUI.element);
    this.rootElement.appendChild(this.hudUI.element);
    this.rootElement.appendChild(this.modalsUI.element);

    // Window Resize Handler
    window.addEventListener('resize', () => this.engine.resize());

    // Setup Global Keyboard Listeners
    this.setupKeyboardEvents();

    // Check Daily Login Streak
    const streakResult = checkDailyStreak(this.stats);
    if (streakResult.isNewDay) {
      this.updateStats(streakResult.updatedStats);
      this.setActiveModal('daily');
      this.showToast(`Daily Login Bonus: +🪙${streakResult.reward} Coins!`, 'success');
    }

    // Initial Screen Visibility Sync
    this.setGameState('menu');
  }

  private showToast(message: string, type: 'info' | 'success' | 'error' | 'warning' = 'info') {
    this.toastManager.showToast(message, type);
  }

  private updateStats(partial: Partial<UserStats>) {
    this.stats = { ...this.stats, ...partial };
    this.stats.eloRating = calculateElo(this.stats);
    saveUserStats(this.stats);

    this.mainMenuUI.updateStats(this.stats);
    this.gameModesUI.updateStats(this.stats);
    this.levelSelectUI.updateStats(this.stats);
    this.shapeShopUI.updateStats(this.stats);
    this.modalsUI.updateState({ stats: this.stats });

    this.engine.setEquippedShape(this.stats.equippedShape);
  }

  private setGameState(state: GameState) {
    this.gameState = state;

    // Toggle Screen Visibility
    this.mainMenuUI.element.style.display = state === 'menu' ? 'flex' : 'none';
    this.gameModesUI.element.style.display = state === 'modes' ? 'flex' : 'none';
    this.levelSelectUI.element.style.display = state === 'level_select' ? 'flex' : 'none';
    this.shapeShopUI.element.style.display = state === 'shop' ? 'flex' : 'none';
    this.hudUI.element.style.display = state === 'playing' ? 'flex' : 'none';

    if (state === 'playing') {
      this.pointerOverlay.classList.remove('hidden');
    } else {
      this.pointerOverlay.classList.add('hidden');
    }
  }

  private setActiveModal(modal: ModalType) {
    this.activeModal = modal;
    this.modalsUI.updateState({
      activeModal: modal,
      gameOverProgress: this.progress,
      gameOverScoreText: this.gameOverScoreText,
      victoryLevel: this.victoryLevel,
      victoryAttempts: this.victoryAttempts,
      victoryIsPerfect: this.victoryIsPerfect
    });
  }

  private setupPointerEvents() {
    this.pointerOverlay.addEventListener('pointerdown', (e: PointerEvent) => {
      if (this.gameState !== 'playing') return;
      const rect = this.pointerOverlay.getBoundingClientRect();
      const px = e.clientX - rect.left;

      this.engine.inputActive = true;
      if (px < rect.width * 0.3) {
        this.engine.inputLeft = true;
      } else if (px > rect.width * 0.7) {
        this.engine.inputRight = true;
      }
    });

    const handlePointerUp = () => {
      this.engine.inputActive = false;
      this.engine.inputLeft = false;
      this.engine.inputRight = false;
    };

    this.pointerOverlay.addEventListener('pointerup', handlePointerUp);
    this.pointerOverlay.addEventListener('pointerleave', handlePointerUp);
    this.pointerOverlay.addEventListener('contextmenu', (e) => e.preventDefault());
  }

  private setupKeyboardEvents() {
    window.addEventListener('keydown', (e: KeyboardEvent) => {
      if (e.code === 'Space' || e.code === 'KeyW' || e.code === 'ArrowUp') {
        this.engine.inputActive = true;
        e.preventDefault();
      }
      if (e.code === 'KeyA' || e.code === 'ArrowLeft') {
        this.engine.inputLeft = true;
      }
      if (e.code === 'KeyD' || e.code === 'ArrowRight') {
        this.engine.inputRight = true;
      }
      if (e.code === 'Escape') {
        if (this.gameState === 'playing') {
          if (this.activeModal === 'pause') {
            this.engine.resume();
            this.setActiveModal(null);
          } else {
            this.engine.pause();
            this.setActiveModal('pause');
          }
        }
      }
    });

    window.addEventListener('keyup', (e: KeyboardEvent) => {
      if (e.code === 'Space' || e.code === 'KeyW' || e.code === 'ArrowUp') {
        this.engine.inputActive = false;
      }
      if (e.code === 'KeyA' || e.code === 'ArrowLeft') {
        this.engine.inputLeft = false;
      }
      if (e.code === 'KeyD' || e.code === 'ArrowRight') {
        this.engine.inputRight = false;
      }
    });
  }

  // Gameplay Actions
  private handleLaunchLevel(lvl: number) {
    this.setActiveModal(null);
    this.setGameState('playing');
    this.engine.startClassicLevel(lvl);
    this.hudUI.updateState({ mode: 'classic', isPracticeMode: false });
  }

  private handleLaunchEndless() {
    this.setActiveModal(null);
    this.setGameState('playing');
    this.engine.startEndlessMode();
    this.hudUI.updateState({ mode: 'endless', isPracticeMode: false });
  }

  private handleLaunchRace() {
    this.setActiveModal(null);
    this.setGameState('playing');
    this.engine.startRaceMode();
    this.hudUI.updateState({ mode: 'race', isPracticeMode: false });
  }

  private handlePause() {
    this.engine.pause();
    this.setActiveModal('pause');
  }

  private handleResume() {
    this.engine.resume();
    this.setActiveModal(null);
  }

  private handleRestart() {
    this.setActiveModal(null);
    this.engine.restart();
  }

  private handleMainMenu() {
    this.setActiveModal(null);
    this.setGameState('menu');
    this.engine.stopLoop();
  }

  private handleNextLevel() {
    this.setActiveModal(null);
    if (this.victoryLevel < 100) {
      this.handleLaunchLevel(this.victoryLevel + 1);
    } else {
      this.setGameState('level_select');
    }
  }

  private handleEquipShape(shapeId: string) {
    this.updateStats({ equippedShape: shapeId });
    this.engine.setEquippedShape(shapeId);
  }

  private handleBuyShape(skin: ShapeSkin): boolean {
    if (this.stats.coins < skin.price) {
      this.showToast("Insufficient Speedy Coins! Keep playing to earn more.", "error");
      return false;
    }

    const updatedCoins = this.stats.coins - skin.price;
    const updatedOwned = Array.from(new Set([...this.stats.ownedShapes, skin.id]));

    this.updateStats({
      coins: updatedCoins,
      ownedShapes: updatedOwned,
      equippedShape: skin.id
    });

    this.engine.setEquippedShape(skin.id);
    return true;
  }

  private handleUnlockLevelEarly(level: number, cost: number) {
    if (this.stats.coins < cost) {
      this.showToast(`Need 🪙 ${cost} coins to unlock Level ${level}!`, 'error');
      return;
    }
    const updatedCoins = this.stats.coins - cost;
    const newUnlocked = { ...this.stats.unlockedLevels, [level]: 0 };
    this.updateStats({
      coins: updatedCoins,
      unlockedLevels: newUnlocked
    });
    audioEngine.playBuySuccess();
    this.showToast(`Unlocked Level ${level}!`, 'success');
  }
}
