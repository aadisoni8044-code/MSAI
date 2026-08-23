import { UserStats } from '../types';
import { getSkinById } from '../data/shapes';
import { ShapeCanvasPreview } from './ShapeCanvasPreview';
import { getIconSvg } from './icons';

export interface MainMenuCallbacks {
  onOpenGameModes: () => void;
  onOpenShop: () => void;
  onOpenSettings: () => void;
  onOpenProfile: () => void;
  onOpenDailyRewards: () => void;
}

export class MainMenu {
  public element: HTMLDivElement;
  private stats: UserStats;
  private callbacks: MainMenuCallbacks;
  private canvasPreview: ShapeCanvasPreview | null = null;

  constructor(stats: UserStats, callbacks: MainMenuCallbacks) {
    this.stats = stats;
    this.callbacks = callbacks;

    this.element = document.createElement('div');
    this.element.className = "absolute inset-0 z-10 flex flex-col justify-between items-center bg-[#050508] text-slate-100 select-none overflow-hidden";
    this.element.style.backgroundImage = 'radial-gradient(circle at 50% 50%, #1a1a2e 0%, #050508 100%)';

    this.render();
  }

  public updateStats(stats: UserStats) {
    this.stats = stats;
    this.render();
  }

  public destroy() {
    if (this.canvasPreview) {
      this.canvasPreview.destroy();
      this.canvasPreview = null;
    }
  }

  private render() {
    if (this.canvasPreview) {
      this.canvasPreview.destroy();
      this.canvasPreview = null;
    }

    const equippedSkin = getSkinById(this.stats.equippedShape);

    this.element.innerHTML = `
      <!-- Top Header Row with Immersive UI styling -->
      <header class="w-full h-16 sm:h-20 flex-shrink-0 flex items-center justify-between px-4 sm:px-8 bg-black/40 border-b border-cyan-500/30 backdrop-blur-md z-10">
        <!-- Profile Card Mini -->
        <button
          id="menu-profile-btn"
          class="flex items-center gap-3 px-3 sm:px-4 py-2 rounded-xl bg-white/5 hover:bg-white/10 border border-white/10 hover:border-cyan-500/50 text-left transition-all duration-200 cursor-pointer shadow-md group"
        >
          <div class="w-8 h-8 sm:w-9 sm:h-9 rounded-lg bg-cyan-500/10 border border-cyan-500/30 flex items-center justify-center text-white font-bold text-sm shadow-[0_0_10px_rgba(34,211,238,0.3)] group-hover:scale-105 transition-transform">
            👤
          </div>
          <div>
            <div class="font-['Orbitron'] font-bold text-xs sm:text-sm text-slate-100 uppercase italic tracking-wider">
              ${this.stats.username}
            </div>
            <div class="text-[10px] sm:text-[11px] font-bold text-cyan-400">
              RATING: ${this.stats.eloRating}
            </div>
          </div>
        </button>

        <!-- Economy Widgets -->
        <div class="flex items-center gap-2.5 sm:gap-4">
          <button
            id="menu-daily-btn"
            class="flex items-center gap-2 px-3 sm:px-4 py-2 rounded-xl bg-rose-500/10 hover:bg-rose-500/20 border border-rose-500/30 hover:border-rose-400 text-rose-300 font-bold text-xs sm:text-sm tracking-wider transition-all duration-200 cursor-pointer shadow-md hover:shadow-rose-500/20"
          >
            <span class="text-rose-400 animate-bounce">${getIconSvg('flame', 'w-4 h-4')}</span>
            <span class="font-['Orbitron']">${this.stats.streakDays}D Streak</span>
          </button>

          <button
            id="menu-shop-coins-btn"
            class="flex items-center gap-2 px-3.5 sm:px-4 py-2 rounded-xl bg-amber-500/10 hover:bg-amber-500/20 border border-amber-500/40 hover:border-amber-400 text-amber-300 font-bold text-xs sm:text-sm tracking-wider transition-all duration-200 cursor-pointer shadow-md hover:shadow-amber-500/20"
          >
            <div class="w-3.5 h-3.5 bg-amber-400 rounded-full shadow-[0_0_8px_rgba(251,191,36,0.6)] animate-pulse flex items-center justify-center">
              ${getIconSvg('coins', 'w-2.5 h-2.5 text-slate-950 stroke-[2.5]')}
            </div>
            <span class="font-['Orbitron'] font-black">${this.stats.coins.toLocaleString()}</span>
          </button>
        </div>
      </header>

      <!-- Central Branding & Equipped Shape Preview -->
      <div class="flex flex-col items-center text-center my-auto z-10 p-4">
        <div class="relative mb-4 flex items-center justify-center">
          <div id="canvas-preview-container" class="w-28 h-28 sm:w-36 sm:h-36 rounded-3xl bg-gradient-to-b from-white/10 to-transparent border border-white/10 flex items-center justify-center shadow-[0_0_30px_rgba(34,211,238,0.2)]">
            <!-- Canvas inserted dynamically -->
          </div>
          <button
            id="menu-change-skin-btn"
            class="absolute -bottom-3 px-3.5 py-1 rounded-full bg-cyan-500 text-slate-950 font-['Orbitron'] font-black text-[10px] uppercase italic tracking-wider shadow-[0_0_15px_rgba(34,211,238,0.5)] hover:scale-105 hover:bg-cyan-400 transition-all cursor-pointer"
          >
            Change Skin
          </button>
        </div>

        <h1 class="font-['Orbitron'] text-4xl sm:text-6xl font-black uppercase italic tracking-tight text-white drop-shadow-[0_0_30px_rgba(34,211,238,0.4)]">
          Speedy<span class="text-cyan-400"> Arrow</span>
        </h1>
        <p class="text-xs sm:text-sm text-slate-400 uppercase tracking-[0.25em] font-semibold mt-1.5 font-['Orbitron']">
          Neon Geometry Wave Runner
        </p>
      </div>

      <!-- Main Buttons Menu -->
      <div class="w-full max-w-xs sm:max-w-sm flex flex-col gap-3 z-10 mb-6 p-4">
        <button
          id="menu-start-game-btn"
          class="w-full py-3.5 sm:py-4 px-6 rounded-xl bg-cyan-500 hover:bg-cyan-400 text-black font-['Orbitron'] font-black text-sm sm:text-base tracking-widest uppercase italic flex items-center justify-center gap-3 transition-all duration-200 shadow-[0_0_25px_rgba(34,211,238,0.4)] hover:shadow-[0_0_35px_rgba(34,211,238,0.6)] hover:-translate-y-0.5 cursor-pointer"
        >
          ${getIconSvg('play', 'w-5 h-5 fill-current')}
          <span>START GAME</span>
        </button>

        <button
          id="menu-shape-shop-btn"
          class="w-full py-3 sm:py-3.5 px-6 rounded-xl bg-white/5 hover:bg-white/10 border border-white/10 hover:border-cyan-500/50 text-cyan-300 font-['Orbitron'] font-bold text-xs sm:text-sm tracking-widest uppercase italic flex items-center justify-center gap-3 transition-all duration-200 shadow-md hover:-translate-y-0.5 cursor-pointer"
        >
          ${getIconSvg('shopping-bag', 'w-4 h-4')}
          <span>SHAPE SHOP</span>
        </button>

        <button
          id="menu-settings-btn"
          class="w-full py-3 sm:py-3.5 px-6 rounded-xl bg-white/5 hover:bg-white/10 border border-white/10 hover:border-purple-500/50 text-purple-300 font-['Orbitron'] font-bold text-xs sm:text-sm tracking-widest uppercase italic flex items-center justify-center gap-3 transition-all duration-200 shadow-md hover:-translate-y-0.5 cursor-pointer"
        >
          ${getIconSvg('settings', 'w-4 h-4')}
          <span>SETTINGS</span>
        </button>
      </div>

      <!-- Footer Branding -->
      <footer class="w-full h-10 px-4 sm:px-8 flex items-center justify-center sm:justify-between bg-black/60 border-t border-white/5 flex-shrink-0 text-[10px] text-slate-500 font-bold uppercase z-10 font-['Orbitron']">
        <span>Developed by Speedy Games</span>
        <span class="hidden sm:inline font-mono">Immersive UI Edition</span>
      </footer>
    `;

    // Append preview canvas
    const previewContainer = this.element.querySelector('#canvas-preview-container');
    if (previewContainer) {
      this.canvasPreview = new ShapeCanvasPreview(equippedSkin, 130, 120, 50);
      previewContainer.appendChild(this.canvasPreview.element);
    }

    // Attach Event Listeners
    this.element.querySelector('#menu-profile-btn')?.addEventListener('click', () => this.callbacks.onOpenProfile());
    this.element.querySelector('#menu-daily-btn')?.addEventListener('click', () => this.callbacks.onOpenDailyRewards());
    this.element.querySelector('#menu-shop-coins-btn')?.addEventListener('click', () => this.callbacks.onOpenShop());
    this.element.querySelector('#menu-change-skin-btn')?.addEventListener('click', () => this.callbacks.onOpenShop());
    this.element.querySelector('#menu-start-game-btn')?.addEventListener('click', () => this.callbacks.onOpenGameModes());
    this.element.querySelector('#menu-shape-shop-btn')?.addEventListener('click', () => this.callbacks.onOpenShop());
    this.element.querySelector('#menu-settings-btn')?.addEventListener('click', () => this.callbacks.onOpenSettings());
  }
}
