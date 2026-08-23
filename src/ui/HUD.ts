import { BiomeType, GameMode } from '../types';
import { getIconSvg } from './icons';

export interface HUDCallbacks {
  onPause: () => void;
  onTogglePractice: (enabled: boolean) => void;
  onPlaceCheckpoint: () => void;
  onClearCheckpoint: () => void;
}

export class HUD {
  public element: HTMLDivElement;
  private callbacks: HUDCallbacks;

  private mode: GameMode = 'classic';
  private progress: number = 0;
  private distanceMeters: number = 0;
  private currentLevel: number = 1;
  private biome: BiomeType = 'forest';
  private isPracticeMode: boolean = false;
  private leaderboard: { name: string; x: number; isDead: boolean; color: string }[] = [];

  constructor(callbacks: HUDCallbacks) {
    this.callbacks = callbacks;
    this.element = document.createElement('div');
    this.element.className = "absolute inset-0 pointer-events-none z-10 flex flex-col justify-between p-4 sm:p-6 font-['Rajdhani'] select-none";
  }

  public updateState(state: {
    mode?: GameMode;
    progress?: number;
    distanceMeters?: number;
    currentLevel?: number;
    biome?: BiomeType;
    isPracticeMode?: boolean;
    leaderboard?: { name: string; x: number; isDead: boolean; color: string }[];
  }) {
    if (state.mode !== undefined) this.mode = state.mode;
    if (state.progress !== undefined) this.progress = state.progress;
    if (state.distanceMeters !== undefined) this.distanceMeters = state.distanceMeters;
    if (state.currentLevel !== undefined) this.currentLevel = state.currentLevel;
    if (state.biome !== undefined) this.biome = state.biome;
    if (state.isPracticeMode !== undefined) this.isPracticeMode = state.isPracticeMode;
    if (state.leaderboard !== undefined) this.leaderboard = state.leaderboard;

    this.render();
  }

  private render() {
    this.element.innerHTML = `
      <!-- Top Controls & Progress Info -->
      <div class="flex items-center justify-between gap-4">
        <!-- Pause Button -->
        <button
          id="hud-pause-btn"
          class="pointer-events-auto w-10 h-10 sm:w-12 sm:h-12 rounded-xl bg-black/50 hover:bg-black/70 border border-white/15 hover:border-cyan-400 text-white flex items-center justify-center transition-all duration-200 cursor-pointer shadow-lg hover:shadow-cyan-500/20 backdrop-blur-md"
        >
          ${getIconSvg('pause', 'w-5 h-5 fill-current')}
        </button>

        <!-- Central Level / Progress Header -->
        <div class="flex-1 max-w-md flex flex-col items-center gap-1.5 px-4 py-2 rounded-2xl bg-black/40 border border-white/10 backdrop-blur-md">
          <div class="font-['Orbitron'] text-[10px] sm:text-xs font-black uppercase italic tracking-widest text-slate-200 drop-shadow-md">
            ${
              this.mode === 'classic'
                ? `Level ${this.currentLevel} • ${this.biome.toUpperCase()} REALM`
                : this.mode === 'endless'
                ? `Endless Survival • ${this.biome.toUpperCase()}`
                : `Tournament Speedway`
            }
          </div>

          <div class="w-full h-3.5 bg-black/60 border border-white/10 rounded-full overflow-hidden relative shadow-inner">
            <div
              class="h-full bg-gradient-to-r from-emerald-400 via-cyan-400 to-teal-300 transition-all duration-100 shadow-[0_0_10px_#00ff66]"
              style="width: ${Math.min(100, Math.max(0, this.progress))}%"
            ></div>
            <div class="absolute inset-0 flex items-center justify-center text-[9px] font-['Orbitron'] font-black text-white drop-shadow-[0_1px_2px_rgba(0,0,0,0.9)]">
              ${this.mode === 'classic' ? `${Math.floor(this.progress)}%` : `${this.distanceMeters}m`}
            </div>
          </div>
        </div>

        <!-- Practice Mode Toggle Checkbox -->
        <div class="pointer-events-auto flex items-center gap-2 px-3 py-2 rounded-xl bg-black/50 border border-white/15 backdrop-blur-md">
          <input
            type="checkbox"
            id="practice-chk"
            ${this.isPracticeMode ? 'checked' : ''}
            class="w-4 h-4 accent-cyan-400 cursor-pointer"
          />
          <label for="practice-chk" class="font-['Orbitron'] text-xs font-bold text-cyan-300 uppercase tracking-wider cursor-pointer">
            Practice
          </label>
        </div>
      </div>

      <!-- Bottom Row: Race Leaderboard + Practice Checkpoint Actions -->
      <div class="flex justify-between items-end">
        <!-- Race Leaderboard -->
        ${
          this.mode === 'race' && this.leaderboard.length > 0
            ? `
          <div class="pointer-events-auto p-3.5 rounded-2xl bg-black/60 border border-cyan-500/30 shadow-xl w-48 backdrop-blur-md">
            <div class="font-['Orbitron'] text-[10px] font-black text-cyan-400 uppercase italic tracking-wider mb-2 pb-1 border-b border-white/10">
              Live Tournament
            </div>
            <div class="space-y-1">
              ${this.leaderboard
                .map(
                  (r, i) => `
                <div
                  class="flex justify-between text-xs font-bold ${r.name === 'YOU' ? 'text-emerald-400' : 'text-slate-300'}"
                  style="color: ${r.isDead ? '#64748b' : r.name === 'YOU' ? '#00ff66' : r.color}"
                >
                  <span class="font-['Orbitron']">${i + 1}. ${r.name}</span>
                  <span class="font-mono">${r.isDead ? 'CRASH' : `${Math.floor(r.x / 10)}m`}</span>
                </div>
              `
                )
                .join('')}
            </div>
          </div>
        `
            : `<div></div>`
        }

        <!-- Practice Mode Checkpoint Buttons -->
        ${
          this.isPracticeMode
            ? `
          <div class="pointer-events-auto flex flex-col gap-2">
            <button
              id="hud-place-cp-btn"
              class="px-4 py-2.5 rounded-xl bg-cyan-500/20 hover:bg-cyan-500/30 border border-cyan-400 text-cyan-300 font-['Orbitron'] text-xs font-bold uppercase italic tracking-wider shadow-[0_0_15px_rgba(6,182,212,0.3)] transition-all cursor-pointer backdrop-blur-md"
            >
              🟢 Place Checkpoint
            </button>
            <button
              id="hud-clear-cp-btn"
              class="px-4 py-2.5 rounded-xl bg-rose-500/20 hover:bg-rose-500/30 border border-rose-400 text-rose-300 font-['Orbitron'] text-xs font-bold uppercase italic tracking-wider shadow-[0_0_15px_rgba(244,63,94,0.3)] transition-all cursor-pointer backdrop-blur-md"
            >
              🔴 Clear Checkpoints
            </button>
          </div>
        `
            : ''
        }
      </div>
    `;

    // Attach Event Listeners
    const pauseBtn = this.element.querySelector('#hud-pause-btn');
    if (pauseBtn) pauseBtn.addEventListener('click', () => this.callbacks.onPause());

    const practiceChk = this.element.querySelector('#practice-chk') as HTMLInputElement | null;
    if (practiceChk) {
      practiceChk.addEventListener('change', (e) => {
        const checked = (e.target as HTMLInputElement).checked;
        this.callbacks.onTogglePractice(checked);
      });
    }

    const placeCpBtn = this.element.querySelector('#hud-place-cp-btn');
    if (placeCpBtn) placeCpBtn.addEventListener('click', () => this.callbacks.onPlaceCheckpoint());

    const clearCpBtn = this.element.querySelector('#hud-clear-cp-btn');
    if (clearCpBtn) clearCpBtn.addEventListener('click', () => this.callbacks.onClearCheckpoint());
  }
}
