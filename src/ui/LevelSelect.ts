import { BiomeType, UserStats } from '../types';
import { getIconSvg } from './icons';

export interface LevelSelectCallbacks {
  onBack: () => void;
  onLaunchLevel: (level: number) => void;
  onUnlockLevelEarly: (level: number, cost: number) => void;
}

const BIOMES: { id: BiomeType; name: string; icon: string; range: [number, number]; color: string; border: string; glow: string }[] = [
  { id: 'forest', name: 'Forest', icon: '🌳', range: [1, 20], color: 'text-emerald-400', border: 'border-emerald-500/50', glow: 'shadow-[0_0_15px_rgba(16,185,129,0.3)]' },
  { id: 'haunted', name: 'Haunted', icon: '🔮', range: [21, 40], color: 'text-purple-400', border: 'border-purple-500/50', glow: 'shadow-[0_0_15px_rgba(168,85,247,0.3)]' },
  { id: 'space', name: 'Space', icon: '🚀', range: [41, 60], color: 'text-cyan-400', border: 'border-cyan-500/50', glow: 'shadow-[0_0_15px_rgba(6,182,212,0.3)]' },
  { id: 'water', name: 'Water', icon: '🌊', range: [61, 80], color: 'text-rose-400', border: 'border-rose-500/50', glow: 'shadow-[0_0_15px_rgba(244,63,94,0.3)]' },
  { id: 'ancient', name: 'Ancient', icon: '🏛️', range: [81, 100], color: 'text-amber-400', border: 'border-amber-500/50', glow: 'shadow-[0_0_15px_rgba(245,158,11,0.3)]' },
];

export class LevelSelect {
  public element: HTMLDivElement;
  private stats: UserStats;
  private callbacks: LevelSelectCallbacks;
  private activeBiome: BiomeType = 'forest';

  constructor(stats: UserStats, callbacks: LevelSelectCallbacks) {
    this.stats = stats;
    this.callbacks = callbacks;

    this.element = document.createElement('div');
    this.element.className = "absolute inset-0 z-10 flex flex-col justify-between items-center bg-[#050508] text-slate-100 select-none overflow-hidden font-['Rajdhani']";
    this.element.style.backgroundImage = 'radial-gradient(circle at 50% 50%, #1a1a2e 0%, #050508 100%)';

    this.render();
  }

  public updateStats(stats: UserStats) {
    this.stats = stats;
    this.render();
  }

  private render() {
    const currentBiomeConfig = BIOMES.find(b => b.id === this.activeBiome) || BIOMES[0];

    const levels: number[] = [];
    for (let i = currentBiomeConfig.range[0]; i <= currentBiomeConfig.range[1]; i++) {
      levels.push(i);
    }

    this.element.innerHTML = `
      <!-- Top Header -->
      <header class="w-full h-16 sm:h-20 flex-shrink-0 flex items-center justify-between px-4 sm:px-8 bg-black/40 border-b border-cyan-500/30 backdrop-blur-md z-10">
        <div class="flex items-center gap-3 sm:gap-4">
          <button
            id="lvl-select-back-btn"
            class="w-10 h-10 sm:w-12 sm:h-12 flex items-center justify-center rounded-xl bg-slate-800 border border-slate-700 hover:border-cyan-400 transition-colors cursor-pointer text-slate-200 hover:text-cyan-400 shadow-md"
          >
            ${getIconSvg('arrow-left', 'w-5 h-5 sm:w-6 sm:h-6')}
          </button>
          <div>
            <h1 class="text-xl sm:text-2xl font-black tracking-tighter uppercase italic text-cyan-400 font-['Orbitron']">
              Level Select
            </h1>
            <p class="text-[10px] sm:text-xs text-slate-400 font-bold uppercase tracking-widest">
              100 Classic Geometry Campaigns
            </p>
          </div>
        </div>

        <div class="flex items-center gap-2 px-3.5 sm:px-4 py-2 rounded-xl bg-amber-500/10 border border-amber-500/30 text-amber-300 shadow-sm">
          <div class="w-3.5 h-3.5 bg-amber-400 rounded-full shadow-[0_0_8px_rgba(251,191,36,0.6)] animate-pulse flex items-center justify-center">
            ${getIconSvg('coins', 'w-2.5 h-2.5 text-slate-950 stroke-[2.5]')}
          </div>
          <span class="font-['Orbitron'] font-bold text-sm sm:text-base">${this.stats.coins.toLocaleString()}</span>
        </div>
      </header>

      <!-- Biome Category Tabs -->
      <div class="w-full max-w-4xl flex justify-center gap-2 sm:gap-3 px-4 my-2 z-10 overflow-x-auto pb-1">
        ${BIOMES.map(b => {
          const isActive = this.activeBiome === b.id;
          return `
            <button
              data-biome="${b.id}"
              class="biome-tab-btn flex-1 min-w-[95px] py-2 sm:py-2.5 px-2 rounded-xl font-['Orbitron'] text-xs sm:text-sm font-bold uppercase tracking-wider transition-all duration-200 cursor-pointer text-center ${
                isActive
                  ? `bg-white/10 border ${b.border} ${b.color} ${b.glow}`
                  : 'bg-white/5 border border-white/10 text-slate-400 hover:border-white/20 hover:text-slate-200'
              }"
            >
              <span class="mr-1.5">${b.icon}</span>
              <span>${b.name}</span>
            </button>
          `;
        }).join('')}
      </div>

      <!-- Level Grid (20 levels per biome) -->
      <div class="w-full max-w-4xl flex-1 overflow-y-auto px-4 my-2 grid grid-cols-4 sm:grid-cols-5 md:grid-cols-5 gap-3 auto-rows-max z-10 scrollbar-thin content-start">
        ${levels.map(lvl => {
          const progress = this.stats.unlockedLevels[lvl];
          const isUnlocked = progress !== undefined;
          const isCompleted = progress >= 100;

          if (isUnlocked) {
            return `
              <button
                data-launch-lvl="${lvl}"
                class="launch-lvl-btn relative aspect-square flex flex-col items-center justify-center p-3 rounded-2xl border transition-all duration-200 cursor-pointer ${
                  isCompleted
                    ? 'bg-emerald-950/30 border-emerald-500/50 hover:border-emerald-400 text-emerald-300 shadow-[0_0_15px_rgba(16,185,129,0.2)] hover:scale-105'
                    : 'bg-white/5 border-white/10 hover:border-cyan-400 text-cyan-300 shadow-md hover:scale-105 hover:bg-white/10'
                }"
              >
                <span class="font-['Orbitron'] font-black text-2xl sm:text-3xl text-slate-100">
                  ${lvl}
                </span>
                <span class="text-[10px] font-bold mt-1 text-cyan-400 font-mono">
                  ${isCompleted ? '100% CLEAR' : `${progress || 0}%`}
                </span>
                ${isCompleted ? `<span class="absolute top-2 right-2 text-emerald-400">${getIconSvg('check-circle2', 'w-3.5 h-3.5')}</span>` : ''}
              </button>
            `;
          } else {
            return `
              <div
                class="relative aspect-square flex flex-col items-center justify-center p-3 rounded-2xl bg-black/40 border border-white/5 text-slate-600"
              >
                ${getIconSvg('lock', 'w-5 h-5 text-slate-600 mb-1')}
                <span class="font-['Orbitron'] font-bold text-lg text-slate-600">
                  ${lvl}
                </span>
                <button
                  data-unlock-lvl="${lvl}"
                  class="unlock-lvl-btn mt-1 flex items-center gap-1 px-2 py-0.5 rounded-md bg-amber-500/10 hover:bg-amber-500/20 border border-amber-500/40 text-amber-300 text-[10px] font-bold font-['Orbitron'] cursor-pointer transition-all"
                >
                  ${getIconSvg('coins', 'w-2.5 h-2.5')}
                  <span>100</span>
                </button>
              </div>
            `;
          }
        }).join('')}
      </div>

      <!-- Footer -->
      <footer class="w-full h-10 px-4 sm:px-8 flex items-center justify-between bg-black/60 border-t border-white/5 flex-shrink-0 text-[10px] text-slate-500 font-bold uppercase z-10 font-['Orbitron']">
        <span>Levels 1-100 across 5 unique visual realms</span>
        <span class="hidden sm:inline font-mono">Clear to Unlock</span>
      </footer>
    `;

    // Attach Event Listeners
    this.element.querySelector('#lvl-select-back-btn')?.addEventListener('click', () => this.callbacks.onBack());

    this.element.querySelectorAll('.biome-tab-btn').forEach(btn => {
      btn.addEventListener('click', (e) => {
        const biome = (e.currentTarget as HTMLElement).getAttribute('data-biome') as BiomeType;
        if (biome) {
          this.activeBiome = biome;
          this.render();
        }
      });
    });

    this.element.querySelectorAll('.launch-lvl-btn').forEach(btn => {
      btn.addEventListener('click', (e) => {
        const lvlStr = (e.currentTarget as HTMLElement).getAttribute('data-launch-lvl');
        if (lvlStr) {
          this.callbacks.onLaunchLevel(parseInt(lvlStr, 10));
        }
      });
    });

    this.element.querySelectorAll('.unlock-lvl-btn').forEach(btn => {
      btn.addEventListener('click', (e) => {
        const lvlStr = (e.currentTarget as HTMLElement).getAttribute('data-unlock-lvl');
        if (lvlStr) {
          this.callbacks.onUnlockLevelEarly(parseInt(lvlStr, 10), 100);
        }
      });
    });
  }
}
