import { UserStats } from '../types';
import { getSkinById } from '../data/shapes';
import { ShapeCanvasPreview } from './ShapeCanvasPreview';
import { audioEngine } from '../engine/audioEngine';
import { getIconSvg } from './icons';

export interface ModalsCallbacks {
  onClose: () => void;
  onResume: () => void;
  onRestart: () => void;
  onMainMenu: () => void;
  onNextLevel: () => void;
  onUpdateStats: (newStats: Partial<UserStats>) => void;
  onShowToast: (msg: string, type: 'info' | 'success' | 'error' | 'warning') => void;
}

export type ModalType = 'pause' | 'gameover' | 'victory' | 'daily' | 'settings' | 'profile' | null;

export class Modals {
  public element: HTMLDivElement;
  private activeModal: ModalType = null;
  private stats: UserStats;
  private callbacks: ModalsCallbacks;

  private gameOverProgress: number = 0;
  private gameOverScoreText: string = '';
  private victoryLevel: number = 1;
  private victoryAttempts: number = 1;
  private victoryIsPerfect: boolean = false;

  private usernameInput: string;
  private countryInput: string;
  private bioInput: string;
  private searchUidInput: string = '';
  private searchResult: string | null = null;

  private profilePreviewCanvas: ShapeCanvasPreview | null = null;
  private ownedSkinPreviews: Map<string, ShapeCanvasPreview> = new Map();

  constructor(stats: UserStats, callbacks: ModalsCallbacks) {
    this.stats = stats;
    this.callbacks = callbacks;

    this.usernameInput = stats.username;
    this.countryInput = stats.country;
    this.bioInput = stats.bio;

    this.element = document.createElement('div');
    this.element.className = "absolute inset-0 z-50 flex items-center justify-center p-4 bg-[#050508]/85 backdrop-blur-md font-['Rajdhani'] select-none hidden";

    this.render();
  }

  public updateState(data: {
    activeModal?: ModalType;
    stats?: UserStats;
    gameOverProgress?: number;
    gameOverScoreText?: string;
    victoryLevel?: number;
    victoryAttempts?: number;
    victoryIsPerfect?: boolean;
  }) {
    if (data.activeModal !== undefined) this.activeModal = data.activeModal;
    if (data.stats !== undefined) {
      this.stats = data.stats;
      this.usernameInput = this.stats.username;
      this.countryInput = this.stats.country;
      this.bioInput = this.stats.bio;
    }
    if (data.gameOverProgress !== undefined) this.gameOverProgress = data.gameOverProgress;
    if (data.gameOverScoreText !== undefined) this.gameOverScoreText = data.gameOverScoreText;
    if (data.victoryLevel !== undefined) this.victoryLevel = data.victoryLevel;
    if (data.victoryAttempts !== undefined) this.victoryAttempts = data.victoryAttempts;
    if (data.victoryIsPerfect !== undefined) this.victoryIsPerfect = data.victoryIsPerfect;

    this.render();
  }

  public destroy() {
    this.clearPreviews();
  }

  private clearPreviews() {
    if (this.profilePreviewCanvas) {
      this.profilePreviewCanvas.destroy();
      this.profilePreviewCanvas = null;
    }
    this.ownedSkinPreviews.forEach(p => p.destroy());
    this.ownedSkinPreviews.clear();
  }

  private toggleAudio() {
    const isMuted = audioEngine.toggleMute();
    this.callbacks.onUpdateStats({ isMuted });
    this.callbacks.onShowToast(isMuted ? 'Audio Muted' : 'Audio Enabled', 'info');
  }

  private toggleFullscreen() {
    if (!document.fullscreenElement) {
      document.documentElement.requestFullscreen().catch(() => {});
      this.callbacks.onShowToast('Entered Fullscreen Mode', 'info');
    } else {
      document.exitFullscreen().catch(() => {});
      this.callbacks.onShowToast('Exited Fullscreen Mode', 'info');
    }
  }

  private handleSearchUid() {
    if (!this.searchUidInput.trim()) return;
    if (this.searchUidInput.trim() === '88492019' || this.searchUidInput.trim() === this.stats.username) {
      this.searchResult = `Found Self: ${this.stats.username} (Rating: ${this.stats.eloRating}, Level ${Object.keys(this.stats.unlockedLevels).length})`;
    } else if (this.searchUidInput.trim().length >= 4) {
      this.searchResult = `Rider Record Verified: CyberVanguard (Rating: 1420, USA, 24 Skins)`;
    } else {
      this.searchResult = `Please enter a valid Rider UID or Call-sign.`;
    }
    this.render();
  }

  private handleEquipFromProfile(skinId: string) {
    this.callbacks.onUpdateStats({ equippedShape: skinId });
    audioEngine.playEquipSound();
    const skin = getSkinById(skinId);
    this.callbacks.onShowToast(`Equipped ${skin.name}!`, 'success');
  }

  private render() {
    this.clearPreviews();

    if (!this.activeModal) {
      this.element.classList.add('hidden');
      this.element.innerHTML = '';
      return;
    }

    this.element.classList.remove('hidden');
    const equippedSkin = getSkinById(this.stats.equippedShape);
    const levelsCompleted = Object.values(this.stats.unlockedLevels).filter((v: number) => v >= 100).length;

    let modalHtml = '';

    if (this.activeModal === 'pause') {
      modalHtml = `
        <div class="w-full max-w-md p-6 sm:p-8 rounded-3xl bg-[#0a0a14] border border-cyan-500/40 shadow-[0_0_50px_rgba(34,211,238,0.2)] text-center">
          <h2 class="font-['Orbitron'] text-3xl font-black text-cyan-400 uppercase italic tracking-widest mb-6">
            PAUSED
          </h2>

          <div class="space-y-3 mb-6 p-4 rounded-2xl bg-white/5 border border-white/10 text-left">
            <div class="flex justify-between text-sm font-bold">
              <span class="text-slate-400">Current Progress</span>
              <span class="text-cyan-300 font-['Orbitron']">${Math.floor(this.gameOverProgress)}%</span>
            </div>
            <div class="flex justify-between text-sm font-bold">
              <span class="text-slate-400">Speedy Coins</span>
              <span class="text-amber-400 font-['Orbitron']">🪙 ${this.stats.coins.toLocaleString()}</span>
            </div>
            <div class="flex justify-between text-sm font-bold">
              <span class="text-slate-400">Equipped Skin</span>
              <span class="text-purple-300 font-['Orbitron']">${equippedSkin.name}</span>
            </div>
          </div>

          <div class="space-y-3">
            <button
              id="modal-resume-btn"
              class="w-full py-3.5 px-6 rounded-xl bg-cyan-500 hover:bg-cyan-400 text-black font-['Orbitron'] font-black text-sm tracking-widest uppercase italic flex items-center justify-center gap-2 shadow-[0_0_20px_rgba(34,211,238,0.4)] transition-all cursor-pointer"
            >
              ${getIconSvg('play', 'w-4 h-4 fill-current')}
              <span>RESUME</span>
            </button>

            <button
              id="modal-restart-btn"
              class="w-full py-3 px-6 rounded-xl bg-white/5 hover:bg-white/10 border border-white/10 text-slate-200 font-['Orbitron'] font-bold text-xs uppercase tracking-widest flex items-center justify-center gap-2 transition-all cursor-pointer"
            >
              ${getIconSvg('rotate-ccw', 'w-4 h-4')}
              <span>RESTART RUN</span>
            </button>

            <button
              id="modal-main-menu-btn"
              class="w-full py-3 px-6 rounded-xl bg-white/5 hover:bg-white/10 border border-white/10 text-slate-200 font-['Orbitron'] font-bold text-xs uppercase tracking-widest flex items-center justify-center gap-2 transition-all cursor-pointer"
            >
              ${getIconSvg('home', 'w-4 h-4')}
              <span>MAIN MENU</span>
            </button>
          </div>
        </div>
      `;
    } else if (this.activeModal === 'gameover') {
      modalHtml = `
        <div class="w-full max-w-md p-6 sm:p-8 rounded-3xl bg-[#0a0a14] border border-rose-500/50 shadow-[0_0_50px_rgba(244,63,94,0.25)] text-center">
          <h2 class="font-['Orbitron'] text-4xl font-black text-rose-500 uppercase italic tracking-widest mb-6">
            CRASHED
          </h2>

          <div class="space-y-3 mb-6 p-4 rounded-2xl bg-white/5 border border-white/10 text-left">
            <div class="flex justify-between text-sm font-bold">
              <span class="text-slate-400">Final Metric / Progress</span>
              <span class="text-rose-400 font-['Orbitron']">${Math.floor(this.gameOverProgress)}%</span>
            </div>
            <div class="flex justify-between text-sm font-bold">
              <span class="text-slate-400">Mode Standing</span>
              <span class="text-slate-200 font-['Orbitron']">${this.gameOverScoreText}</span>
            </div>
            <div class="flex justify-between text-sm font-bold">
              <span class="text-slate-400">Total Coins</span>
              <span class="text-amber-400 font-['Orbitron']">🪙 ${this.stats.coins.toLocaleString()}</span>
            </div>
          </div>

          <div class="space-y-3">
            <button
              id="modal-restart-btn"
              class="w-full py-3.5 px-6 rounded-xl bg-rose-500 hover:bg-rose-400 text-black font-['Orbitron'] font-black text-sm tracking-widest uppercase italic flex items-center justify-center gap-2 shadow-[0_0_20px_rgba(244,63,94,0.4)] transition-all cursor-pointer"
            >
              ${getIconSvg('rotate-ccw', 'w-4 h-4')}
              <span>RETRY RUN</span>
            </button>

            <button
              id="modal-main-menu-btn"
              class="w-full py-3 px-6 rounded-xl bg-white/5 hover:bg-white/10 border border-white/10 text-slate-200 font-['Orbitron'] font-bold text-xs uppercase tracking-widest flex items-center justify-center gap-2 transition-all cursor-pointer"
            >
              ${getIconSvg('home', 'w-4 h-4')}
              <span>MAIN MENU</span>
            </button>
          </div>
        </div>
      `;
    } else if (this.activeModal === 'victory') {
      modalHtml = `
        <div class="w-full max-w-md p-6 sm:p-8 rounded-3xl bg-[#0a0a14] border border-emerald-500/50 shadow-[0_0_50px_rgba(16,185,129,0.25)] text-center">
          <div class="w-16 h-16 mx-auto mb-3 rounded-2xl bg-emerald-500/20 border border-emerald-400 flex items-center justify-center text-emerald-400 shadow-[0_0_20px_rgba(16,185,129,0.4)] animate-bounce">
            ${getIconSvg('trophy', 'w-8 h-8')}
          </div>

          <h2 class="font-['Orbitron'] text-3xl font-black text-emerald-400 uppercase italic tracking-widest mb-1">
            CLEARED!
          </h2>
          <p class="text-xs text-slate-400 font-semibold mb-5 font-['Orbitron']">
            Level ${this.victoryLevel} Campaign Completed
          </p>

          <div class="space-y-2.5 mb-6 p-4 rounded-2xl bg-white/5 border border-white/10 text-left">
            <div class="flex justify-between text-sm font-bold">
              <span class="text-slate-400">Total Attempts</span>
              <span class="text-slate-200 font-['Orbitron']">${this.victoryAttempts}</span>
            </div>
            ${
              this.victoryIsPerfect
                ? `
              <div class="flex justify-between text-sm font-bold text-amber-400">
                <span>Flawless 1st Try Bonus</span>
                <span class="font-['Orbitron']">🪙 +50 Extra</span>
              </div>
            `
                : ''
            }
            <div class="flex justify-between text-sm font-bold text-emerald-400">
              <span>Map Completion Reward</span>
              <span class="font-['Orbitron']">🪙 +100 Coins</span>
            </div>
          </div>

          <div class="space-y-3">
            ${
              this.victoryLevel < 100
                ? `
              <button
                id="modal-next-level-btn"
                class="w-full py-3.5 px-6 rounded-xl bg-emerald-500 hover:bg-emerald-400 text-black font-['Orbitron'] font-black text-sm tracking-widest uppercase italic flex items-center justify-center gap-2 shadow-[0_0_20px_rgba(16,185,129,0.4)] transition-all cursor-pointer"
              >
                <span>NEXT MAP</span>
                ${getIconSvg('arrow-right', 'w-4 h-4')}
              </button>
            `
                : ''
            }

            <button
              id="modal-main-menu-btn"
              class="w-full py-3 px-6 rounded-xl bg-white/5 hover:bg-white/10 border border-white/10 text-slate-200 font-['Orbitron'] font-bold text-xs uppercase tracking-widest flex items-center justify-center gap-2 transition-all cursor-pointer"
            >
              ${getIconSvg('home', 'w-4 h-4')}
              <span>MAIN MENU</span>
            </button>
          </div>
        </div>
      `;
    } else if (this.activeModal === 'daily') {
      modalHtml = `
        <div class="w-full max-w-md p-6 sm:p-8 rounded-3xl bg-[#0a0a14] border border-amber-500/50 shadow-[0_0_50px_rgba(245,158,11,0.25)] text-center">
          <div class="w-14 h-14 mx-auto mb-2 rounded-2xl bg-amber-500/20 border border-amber-400 flex items-center justify-center text-amber-400 shadow-[0_0_20px_rgba(245,158,11,0.4)]">
            ${getIconSvg('flame', 'w-7 h-7')}
          </div>

          <h2 class="font-['Orbitron'] text-2xl sm:text-3xl font-black text-amber-400 uppercase italic tracking-widest mb-1">
            DAILY STREAK
          </h2>
          <p class="text-xs text-slate-400 font-semibold mb-4">
            Active login streak: <span class="text-rose-400 font-bold font-['Orbitron']">${this.stats.streakDays} Days</span>
          </p>

          <!-- 5-Day Reward Track -->
          <div class="grid grid-cols-5 gap-2 my-4">
            ${[1, 2, 3, 4, 5]
              .map(day => {
                const isClaimed = day <= this.stats.streakDays;
                const isCurrent = day === this.stats.streakDays;
                const reward = day * 50;

                return `
                  <div
                    class="p-2.5 rounded-xl border flex flex-col items-center gap-1 ${
                      isCurrent
                        ? 'bg-amber-500/20 border-amber-400 shadow-[0_0_12px_rgba(245,158,11,0.4)]'
                        : isClaimed
                        ? 'bg-emerald-500/10 border-emerald-500/30'
                        : 'bg-black/40 border-white/5 opacity-60'
                    }"
                  >
                    <span class="text-[10px] font-bold text-slate-400">Day ${day}</span>
                    <span class="font-['Orbitron'] text-xs font-black text-amber-300">🪙${reward}</span>
                    ${isClaimed ? `<span class="text-emerald-400">${getIconSvg('check-circle2', 'w-3.5 h-3.5')}</span>` : ''}
                  </div>
                `;
              })
              .join('')}
          </div>

          <button
            id="modal-collect-rewards-btn"
            class="w-full mt-4 py-3.5 px-6 rounded-xl bg-amber-500 hover:bg-amber-400 text-black font-['Orbitron'] font-black text-sm tracking-widest uppercase italic transition-all shadow-[0_0_20px_rgba(245,158,11,0.4)] cursor-pointer"
          >
            COLLECT REWARDS
          </button>
        </div>
      `;
    } else if (this.activeModal === 'settings') {
      modalHtml = `
        <div class="w-full max-w-lg p-6 sm:p-8 rounded-3xl bg-[#0a0a14] border border-cyan-500/40 shadow-[0_0_50px_rgba(34,211,238,0.2)] text-left">
          <div class="flex items-center justify-between mb-6 pb-2 border-b border-white/10">
            <h2 class="font-['Orbitron'] text-2xl font-black text-cyan-400 uppercase italic tracking-widest">
              SETTINGS
            </h2>
            <button
              id="modal-close-x-btn"
              class="text-slate-400 hover:text-white text-xl font-bold cursor-pointer"
            >
              ✕
            </button>
          </div>

          <div class="space-y-4 mb-6">
            <!-- Audio Toggle -->
            <div class="flex items-center justify-between p-3.5 rounded-2xl bg-white/5 border border-white/10">
              <div>
                <div class="text-sm font-bold text-slate-200">Synthesizer Soundtrack & SFX</div>
                <div class="text-xs text-slate-400">Dynamic synthwave audio engine</div>
              </div>
              <button
                id="modal-toggle-audio-btn"
                class="p-2.5 rounded-xl border flex items-center gap-2 cursor-pointer transition-all ${
                  !this.stats.isMuted
                    ? 'bg-cyan-500/20 border-cyan-400 text-cyan-300 shadow-[0_0_10px_rgba(34,211,238,0.3)]'
                    : 'bg-black/40 border-white/10 text-slate-500'
                }"
              >
                ${!this.stats.isMuted ? getIconSvg('volume-2', 'w-5 h-5') : getIconSvg('volume-x', 'w-5 h-5')}
                <span class="text-xs font-bold font-['Orbitron']">${!this.stats.isMuted ? 'ON' : 'MUTED'}</span>
              </button>
            </div>

            <!-- Fullscreen Toggle -->
            <div class="flex items-center justify-between p-3.5 rounded-2xl bg-white/5 border border-white/10">
              <div>
                <div class="text-sm font-bold text-slate-200">Full Screen Viewport</div>
                <div class="text-xs text-slate-400">Expand across your entire display</div>
              </div>
              <button
                id="modal-toggle-fullscreen-btn"
                class="p-2.5 rounded-xl bg-white/5 hover:bg-white/10 border border-white/10 hover:border-cyan-400 text-slate-200 flex items-center gap-2 cursor-pointer transition-all"
              >
                <span class="text-xs font-bold font-['Orbitron']">TOGGLE</span>
              </button>
            </div>

            <!-- Rider Search by 8-Digit UID -->
            <div class="p-3.5 rounded-2xl bg-white/5 border border-white/10 space-y-2">
              <div class="text-xs font-bold text-slate-300 uppercase tracking-wider">
                Search Player Record (8-Digit UID)
              </div>
              <div class="flex gap-2">
                <input
                  type="text"
                  id="modal-uid-search-input"
                  value="${this.searchUidInput}"
                  placeholder="Enter 8-digit Player ID..."
                  class="flex-1 px-3 py-2 rounded-xl bg-black/40 border border-white/10 text-white font-['Orbitron'] text-xs outline-none focus:border-cyan-400"
                />
                <button
                  id="modal-uid-search-btn"
                  class="px-4 py-2 rounded-xl bg-cyan-500/20 hover:bg-cyan-500/30 border border-cyan-400 text-cyan-300 font-bold text-xs cursor-pointer"
                >
                  ${getIconSvg('search', 'w-4 h-4')}
                </button>
              </div>
              ${
                this.searchResult
                  ? `
                <div class="p-2 rounded-lg bg-black/60 text-xs text-cyan-300 font-semibold border border-cyan-500/20">
                  ${this.searchResult}
                </div>
              `
                  : ''
              }
            </div>
          </div>

          <button
            id="modal-close-settings-btn"
            class="w-full py-3 rounded-xl bg-white/10 hover:bg-white/15 text-white font-['Orbitron'] font-bold text-xs uppercase tracking-widest transition-all cursor-pointer border border-white/10"
          >
            CLOSE SETTINGS
          </button>
        </div>
      `;
    } else if (this.activeModal === 'profile') {
      modalHtml = `
        <div class="w-full max-w-xl p-6 sm:p-8 rounded-3xl bg-[#0a0a14] border border-purple-500/40 shadow-[0_0_50px_rgba(168,85,247,0.2)] text-left max-h-[90vh] overflow-y-auto scrollbar-thin">
          <div class="flex items-center justify-between mb-4 pb-2 border-b border-white/10">
            <h2 class="font-['Orbitron'] text-2xl font-black text-purple-400 uppercase italic tracking-widest flex items-center gap-2">
              ${getIconSvg('user', 'w-6 h-6')}
              <span>PLAYER PROFILE</span>
            </h2>
            <button
              id="modal-close-x-btn"
              class="text-slate-400 hover:text-white text-xl font-bold cursor-pointer"
            >
              ✕
            </button>
          </div>

          <!-- Profile Identity Card with Live Shape Preview -->
          <div class="flex flex-col sm:flex-row items-center gap-4 p-4 rounded-2xl bg-white/5 border border-white/10 mb-4">
            <div id="profile-preview-container" class="w-20 h-20 sm:w-24 sm:h-24 rounded-2xl bg-black/40 border border-purple-500/40 flex items-center justify-center relative shadow-[0_0_20px_rgba(168,85,247,0.3)] flex-shrink-0">
            </div>
            <div class="flex-1 w-full space-y-2">
              <div class="flex items-center gap-2">
                <input
                  type="text"
                  id="profile-username-input"
                  value="${this.usernameInput}"
                  placeholder="Player Call-sign"
                  class="font-['Orbitron'] font-black text-lg text-white bg-black/30 border border-white/15 focus:border-cyan-400 rounded-lg px-3 py-1 outline-none w-full"
                />
              </div>
              <div class="flex items-center justify-between text-xs">
                <span class="text-amber-400 font-bold font-['Orbitron'] flex items-center gap-1">
                  ${getIconSvg('coins', 'w-3.5 h-3.5')} 🪙 ${this.stats.coins.toLocaleString()} Coins
                </span>
                <span class="text-purple-400 font-bold font-['Orbitron']">
                  UID: #88492019
                </span>
              </div>
              <div class="text-[11px] text-cyan-300 font-semibold font-['Orbitron']">
                Active Flight Frame: ${equippedSkin.name} (${equippedSkin.rarity.toUpperCase()})
              </div>
            </div>
          </div>

          <!-- Statistics Grid -->
          <div class="grid grid-cols-2 sm:grid-cols-4 gap-2.5 mb-4">
            <div class="p-3 rounded-xl bg-white/5 border border-white/10">
              <div class="text-[10px] text-slate-400 uppercase font-bold">ELO Rating</div>
              <div class="font-['Orbitron'] text-base font-black text-cyan-300">${this.stats.eloRating}</div>
            </div>
            <div class="p-3 rounded-xl bg-white/5 border border-white/10">
              <div class="text-[10px] text-slate-400 uppercase font-bold">Endless Record</div>
              <div class="font-['Orbitron'] text-base font-black text-amber-300">${this.stats.endlessHighScore}m</div>
            </div>
            <div class="p-3 rounded-xl bg-white/5 border border-white/10">
              <div class="text-[10px] text-slate-400 uppercase font-bold">Maps Cleared</div>
              <div class="font-['Orbitron'] text-base font-black text-emerald-300">${levelsCompleted}/100</div>
            </div>
            <div class="p-3 rounded-xl bg-white/5 border border-white/10">
              <div class="text-[10px] text-slate-400 uppercase font-bold">Flawless Runs</div>
              <div class="font-['Orbitron'] text-base font-black text-purple-300">${this.stats.totalPerfectRuns}</div>
            </div>
          </div>

          <!-- Owned Skins Fast-Equip Grid -->
          <div class="p-3.5 rounded-2xl bg-white/5 border border-white/10 space-y-2 mb-4">
            <div class="flex items-center justify-between text-xs font-bold text-slate-300 uppercase tracking-wider">
              <span>Owned Shape Skins (${this.stats.ownedShapes.length})</span>
              <span class="text-cyan-400 font-mono text-[11px]">Click to fast-equip</span>
            </div>
            <div class="grid grid-cols-3 sm:grid-cols-5 gap-2 max-h-40 overflow-y-auto p-1 scrollbar-thin">
              ${this.stats.ownedShapes
                .map(shapeId => {
                  const s = getSkinById(shapeId);
                  const isEquipped = this.stats.equippedShape === shapeId;
                  return `
                    <button
                      data-equip-profile-skin="${shapeId}"
                      class="profile-skin-btn p-2 rounded-xl border flex flex-col items-center gap-1 transition-all cursor-pointer ${
                        isEquipped
                          ? 'bg-cyan-500/20 border-cyan-400 shadow-[0_0_12px_rgba(34,211,238,0.3)]'
                          : 'bg-black/40 border-white/10 hover:border-white/30'
                      }"
                    >
                      <div data-profile-skin-container="${shapeId}"></div>
                      <span class="text-[10px] font-bold text-slate-200 truncate w-full text-center">
                        ${s.name}
                      </span>
                      ${
                        isEquipped
                          ? `
                        <span class="text-[8px] px-1 bg-cyan-400 text-black font-black uppercase rounded">
                          Active
                        </span>
                      `
                          : ''
                      }
                    </button>
                  `;
                })
                .join('')}
            </div>
          </div>

          <!-- Bio Textarea -->
          <div class="space-y-1 mb-4">
            <div class="text-xs font-bold text-slate-400 uppercase tracking-wider">Call-Sign Bio & Status</div>
            <textarea
              id="profile-bio-input"
              rows="2"
              placeholder="Set your speed corridor bio..."
              class="w-full p-2.5 rounded-xl bg-black/40 border border-white/10 text-xs text-slate-200 outline-none focus:border-purple-400 resize-none font-['Rajdhani']"
            >${this.bioInput}</textarea>
          </div>

          <button
            id="modal-close-profile-btn"
            class="w-full py-3 rounded-xl bg-purple-600 hover:bg-purple-500 text-white font-['Orbitron'] font-bold text-xs uppercase tracking-widest transition-all cursor-pointer shadow-[0_0_20px_rgba(168,85,247,0.3)]"
          >
            SAVE PROFILE & CLOSE
          </button>
        </div>
      `;
    }

    this.element.innerHTML = modalHtml;

    // Insert profile previews if profile modal
    if (this.activeModal === 'profile') {
      const profilePreviewContainer = this.element.querySelector('#profile-preview-container');
      if (profilePreviewContainer) {
        this.profilePreviewCanvas = new ShapeCanvasPreview(equippedSkin, 80, 80, 34);
        profilePreviewContainer.appendChild(this.profilePreviewCanvas.element);
      }

      this.stats.ownedShapes.forEach(shapeId => {
        const container = this.element.querySelector(`[data-profile-skin-container="${shapeId}"]`);
        if (container) {
          const s = getSkinById(shapeId);
          const p = new ShapeCanvasPreview(s, 44, 40, 20);
          container.appendChild(p.element);
          this.ownedSkinPreviews.set(shapeId, p);
        }
      });
    }

    // Attach Event Listeners for controls
    this.element.querySelector('#modal-resume-btn')?.addEventListener('click', () => this.callbacks.onResume());
    this.element.querySelector('#modal-restart-btn')?.addEventListener('click', () => this.callbacks.onRestart());
    this.element.querySelector('#modal-main-menu-btn')?.addEventListener('click', () => this.callbacks.onMainMenu());
    this.element.querySelector('#modal-next-level-btn')?.addEventListener('click', () => this.callbacks.onNextLevel());
    this.element.querySelector('#modal-collect-rewards-btn')?.addEventListener('click', () => this.callbacks.onClose());
    this.element.querySelector('#modal-close-x-btn')?.addEventListener('click', () => this.callbacks.onClose());
    this.element.querySelector('#modal-close-settings-btn')?.addEventListener('click', () => this.callbacks.onClose());
    this.element.querySelector('#modal-close-profile-btn')?.addEventListener('click', () => this.callbacks.onClose());

    this.element.querySelector('#modal-toggle-audio-btn')?.addEventListener('click', () => this.toggleAudio());
    this.element.querySelector('#modal-toggle-fullscreen-btn')?.addEventListener('click', () => this.toggleFullscreen());

    const searchInput = this.element.querySelector('#modal-uid-search-input') as HTMLInputElement | null;
    if (searchInput) {
      searchInput.addEventListener('input', (e) => {
        this.searchUidInput = (e.target as HTMLInputElement).value;
      });
    }
    this.element.querySelector('#modal-uid-search-btn')?.addEventListener('click', () => this.handleSearchUid());

    const usernameInputEl = this.element.querySelector('#profile-username-input') as HTMLInputElement | null;
    if (usernameInputEl) {
      usernameInputEl.addEventListener('change', (e) => {
        const val = (e.target as HTMLInputElement).value;
        this.callbacks.onUpdateStats({ username: val });
      });
    }

    const bioInputEl = this.element.querySelector('#profile-bio-input') as HTMLTextAreaElement | null;
    if (bioInputEl) {
      bioInputEl.addEventListener('change', (e) => {
        const val = (e.target as HTMLTextAreaElement).value;
        this.callbacks.onUpdateStats({ bio: val });
      });
    }

    this.element.querySelectorAll('.profile-skin-btn').forEach(btn => {
      btn.addEventListener('click', (e) => {
        const skinId = (e.currentTarget as HTMLElement).getAttribute('data-equip-profile-skin');
        if (skinId) {
          this.handleEquipFromProfile(skinId);
        }
      });
    });
  }
}
