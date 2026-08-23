import { UserStats } from '../types';
import { getIconSvg } from './icons';

export interface GameModesCallbacks {
  onBack: () => void;
  onSelectClassic: () => void;
  onSelectEndless: () => void;
  onSelectRace: () => void;
}

export class GameModes {
  public element: HTMLDivElement;
  private stats: UserStats;
  private callbacks: GameModesCallbacks;

  constructor(stats: UserStats, callbacks: GameModesCallbacks) {
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
    this.element.innerHTML = `
      <!-- Top Header -->
      <header class="w-full h-16 sm:h-20 flex-shrink-0 flex items-center justify-between px-4 sm:px-8 bg-black/40 border-b border-cyan-500/30 backdrop-blur-md z-10">
        <div class="flex items-center gap-3 sm:gap-4">
          <button
            id="modes-back-btn"
            class="w-10 h-10 sm:w-12 sm:h-12 flex items-center justify-center rounded-xl bg-slate-800 border border-slate-700 hover:border-cyan-400 transition-colors cursor-pointer text-slate-200 hover:text-cyan-400 shadow-md"
          >
            ${getIconSvg('arrow-left', 'w-5 h-5 sm:w-6 sm:h-6')}
          </button>
          <div>
            <h1 class="text-xl sm:text-2xl font-black tracking-tighter uppercase italic text-cyan-400 font-['Orbitron']">
              Game Modes
            </h1>
            <p class="text-[10px] sm:text-xs text-slate-400 font-bold uppercase tracking-widest">
              Select Your Run Type
            </p>
          </div>
        </div>

        <div class="text-right hidden sm:block">
          <span class="text-[10px] uppercase tracking-widest text-slate-400 font-bold">
            Total Crashes: <span class="text-rose-400 font-mono">${this.stats.totalCrashes}</span>
          </span>
        </div>
      </header>

      <!-- Mode Cards Container -->
      <div class="w-full max-w-5xl grid grid-cols-1 md:grid-cols-3 gap-4 sm:gap-6 my-auto z-10 p-4 sm:p-6">
        <!-- Classic Mode -->
        <div
          id="mode-classic-card"
          class="relative flex flex-col justify-between p-6 sm:p-8 rounded-3xl bg-white/5 hover:bg-white/10 border border-white/10 hover:border-emerald-500/50 text-center transition-all duration-300 hover:-translate-y-2 hover:shadow-[0_0_30px_rgba(16,185,129,0.25)] cursor-pointer group backdrop-blur-md"
        >
          <div>
            <div class="w-16 h-16 mx-auto mb-4 rounded-2xl bg-emerald-500/10 border border-emerald-500/30 flex items-center justify-center text-emerald-400 group-hover:scale-110 transition-transform shadow-[0_0_15px_rgba(16,185,129,0.3)]">
              ${getIconSvg('trophy', 'w-8 h-8')}
            </div>
            <h3 class="font-['Orbitron'] text-xl sm:text-2xl font-black text-slate-100 uppercase italic tracking-wider mb-2">
              Classic
            </h3>
            <p class="text-xs sm:text-sm text-slate-400 leading-relaxed">
              Survive 100 thematic levels across 5 biomes with increasing speed and obstacle difficulty.
            </p>
          </div>

          <div class="mt-6 pt-4 border-t border-white/5">
            <span class="text-xs font-bold text-emerald-400 bg-emerald-500/10 px-3 py-1 rounded-full border border-emerald-500/20 font-['Orbitron']">
              100 CAMPAIGN MAPS
            </span>
          </div>
        </div>

        <!-- Endless Mode -->
        <div
          id="mode-endless-card"
          class="relative flex flex-col justify-between p-6 sm:p-8 rounded-3xl bg-white/5 hover:bg-white/10 border border-white/10 hover:border-cyan-500/50 text-center transition-all duration-300 hover:-translate-y-2 hover:shadow-[0_0_30px_rgba(34,211,238,0.25)] cursor-pointer group backdrop-blur-md"
        >
          <div>
            <div class="w-16 h-16 mx-auto mb-4 rounded-2xl bg-cyan-500/10 border border-cyan-500/30 flex items-center justify-center text-cyan-400 group-hover:scale-110 transition-transform shadow-[0_0_15px_rgba(34,211,238,0.3)]">
              ${getIconSvg('zap', 'w-8 h-8')}
            </div>
            <h3 class="font-['Orbitron'] text-xl sm:text-2xl font-black text-slate-100 uppercase italic tracking-wider mb-2">
              Endless
            </h3>
            <p class="text-xs sm:text-sm text-slate-400 leading-relaxed">
              Procedurally generated survival. Speed increases infinitely. Collect Speedy Coins as you fly!
            </p>
          </div>

          <div class="mt-6 pt-4 border-t border-white/5">
            <span class="text-xs font-bold text-cyan-400 bg-cyan-500/10 px-3 py-1 rounded-full border border-cyan-500/20 font-['Orbitron']">
              HIGH SCORE: ${this.stats.endlessHighScore}m
            </span>
          </div>
        </div>

        <!-- Race Mode -->
        <div
          id="mode-race-card"
          class="relative flex flex-col justify-between p-6 sm:p-8 rounded-3xl bg-white/5 hover:bg-white/10 border border-white/10 hover:border-purple-500/50 text-center transition-all duration-300 hover:-translate-y-2 hover:shadow-[0_0_30px_rgba(168,85,247,0.25)] cursor-pointer group backdrop-blur-md"
        >
          <div>
            <div class="w-16 h-16 mx-auto mb-4 rounded-2xl bg-purple-500/10 border border-purple-500/30 flex items-center justify-center text-purple-400 group-hover:scale-110 transition-transform shadow-[0_0_15px_rgba(168,85,247,0.3)]">
              ${getIconSvg('flag', 'w-8 h-8')}
            </div>
            <h3 class="font-['Orbitron'] text-xl sm:text-2xl font-black text-slate-100 uppercase italic tracking-wider mb-2">
              Race
            </h3>
            <p class="text-xs sm:text-sm text-slate-400 leading-relaxed">
              Face off in real-time speedways against 4 intelligent geometry competitor drones.
            </p>
          </div>

          <div class="mt-6 pt-4 border-t border-white/5">
            <span class="text-xs font-bold text-purple-400 bg-purple-500/10 px-3 py-1 rounded-full border border-purple-500/20 font-['Orbitron']">
              TOURNAMENT WINS: ${this.stats.raceWins}
            </span>
          </div>
        </div>
      </div>

      <!-- Footer -->
      <footer class="w-full h-10 px-4 sm:px-8 flex items-center justify-between bg-black/60 border-t border-white/5 flex-shrink-0 text-[10px] text-slate-500 font-bold uppercase z-10 font-['Orbitron']">
        <span>Choose Your Challenge</span>
        <span class="hidden sm:inline font-mono">Speedy Arrow Engine</span>
      </footer>
    `;

    // Attach Event Listeners
    this.element.querySelector('#modes-back-btn')?.addEventListener('click', () => this.callbacks.onBack());
    this.element.querySelector('#mode-classic-card')?.addEventListener('click', () => this.callbacks.onSelectClassic());
    this.element.querySelector('#mode-endless-card')?.addEventListener('click', () => this.callbacks.onSelectEndless());
    this.element.querySelector('#mode-race-card')?.addEventListener('click', () => this.callbacks.onSelectRace());
  }
}
