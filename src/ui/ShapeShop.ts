import { ShapeSkin, ShapeCategory, ShapeRarity, UserStats } from '../types';
import { SHAPE_SKINS, getSkinById } from '../data/shapes';
import { ShapeCanvasPreview } from './ShapeCanvasPreview';
import { audioEngine } from '../engine/audioEngine';
import { getIconSvg } from './icons';

export interface ShapeShopCallbacks {
  onBack: () => void;
  onEquipShape: (shapeId: string) => void;
  onBuyShape: (shape: ShapeSkin) => boolean;
  onShowToast: (msg: string, type: 'info' | 'success' | 'error' | 'warning') => void;
}

const CATEGORIES: { id: ShapeCategory; label: string; icon: string }[] = [
  { id: 'all', label: 'All Shapes', icon: '🌌' },
  { id: 'basic', label: 'Basic Shapes', icon: '📐' },
  { id: 'geometric', label: 'Geometric', icon: '🔷' },
  { id: 'premium', label: 'Premium', icon: '💎' },
  { id: 'animated', label: 'Animated', icon: '⚡' },
  { id: 'special', label: 'Special / Event', icon: '🔥' },
];

const RARITY_STYLES: Record<ShapeRarity, { text: string; border: string; bg: string; shadow: string }> = {
  common: {
    text: 'text-slate-300',
    border: 'border-slate-700',
    bg: 'bg-slate-800/80',
    shadow: 'shadow-slate-500/20'
  },
  rare: {
    text: 'text-cyan-400',
    border: 'border-cyan-500/40',
    bg: 'bg-cyan-950/60',
    shadow: 'shadow-cyan-500/30'
  },
  epic: {
    text: 'text-purple-400',
    border: 'border-purple-500/50',
    bg: 'bg-purple-950/60',
    shadow: 'shadow-purple-500/30'
  },
  legendary: {
    text: 'text-amber-400',
    border: 'border-amber-500/50',
    bg: 'bg-amber-950/60',
    shadow: 'shadow-amber-500/30'
  },
  mythic: {
    text: 'text-rose-400',
    border: 'border-rose-500/50',
    bg: 'bg-rose-950/60',
    shadow: 'shadow-rose-500/40'
  }
};

export class ShapeShop {
  public element: HTMLDivElement;
  private stats: UserStats;
  private callbacks: ShapeShopCallbacks;

  private selectedCategory: ShapeCategory = 'all';
  private searchQuery: string = '';
  private ownershipFilter: 'all' | 'owned' | 'unowned' = 'all';
  private inspectedShapeId: string;
  private isProcessingPurchase: boolean = false;

  private previewInstances: Map<string, ShapeCanvasPreview> = new Map();
  private inspectorPreview: ShapeCanvasPreview | null = null;

  constructor(stats: UserStats, callbacks: ShapeShopCallbacks) {
    this.stats = stats;
    this.callbacks = callbacks;
    this.inspectedShapeId = stats.equippedShape || 'arrow';

    this.element = document.createElement('div');
    this.element.className = "absolute inset-0 z-20 flex flex-col bg-[#050508] text-slate-100 overflow-hidden select-none font-['Rajdhani',sans-serif]";
    this.element.style.backgroundImage = 'radial-gradient(circle at 50% 50%, #1a1a2e 0%, #050508 100%)';

    this.render();
  }

  public updateStats(stats: UserStats) {
    this.stats = stats;
    if (!this.stats.ownedShapes.includes(this.inspectedShapeId)) {
      // keep current inspected or update if needed
    }
    this.render();
  }

  public destroy() {
    this.clearPreviews();
  }

  private clearPreviews() {
    this.previewInstances.forEach(p => p.destroy());
    this.previewInstances.clear();
    if (this.inspectorPreview) {
      this.inspectorPreview.destroy();
      this.inspectorPreview = null;
    }
  }

  private getFilteredSkins(): ShapeSkin[] {
    return SHAPE_SKINS.filter(skin => {
      if (this.selectedCategory !== 'all' && skin.category !== this.selectedCategory) {
        return false;
      }
      const isOwned = this.stats.ownedShapes.includes(skin.id);
      if (this.ownershipFilter === 'owned' && !isOwned) return false;
      if (this.ownershipFilter === 'unowned' && isOwned) return false;

      if (this.searchQuery.trim()) {
        const q = this.searchQuery.toLowerCase().trim();
        const matchesName = skin.name.toLowerCase().includes(q);
        const matchesDesc = skin.description.toLowerCase().includes(q);
        const matchesShape = skin.renderType.toLowerCase().includes(q);
        const matchesRarity = skin.rarity.toLowerCase().includes(q);
        if (!matchesName && !matchesDesc && !matchesShape && !matchesRarity) {
          return false;
        }
      }
      return true;
    });
  }

  private handleAction(skin: ShapeSkin) {
    if (this.isProcessingPurchase) return;

    const isOwned = this.stats.ownedShapes.includes(skin.id);
    const isEquipped = this.stats.equippedShape === skin.id;

    if (isEquipped) {
      this.callbacks.onShowToast(`${skin.name} is already equipped in gameplay!`, 'info');
      return;
    }

    if (isOwned) {
      this.callbacks.onEquipShape(skin.id);
      audioEngine.playEquipSound();
      this.callbacks.onShowToast(`Equipped ${skin.name}!`, 'success');
    } else {
      if (this.stats.coins < skin.price) {
        this.callbacks.onShowToast(`Not enough coins! Need 🪙 ${skin.price - this.stats.coins} more.`, 'error');
        return;
      }

      this.isProcessingPurchase = true;
      try {
        const success = this.callbacks.onBuyShape(skin);
        if (success) {
          audioEngine.playBuySuccess();
          this.callbacks.onShowToast(`Unlocked & equipped ${skin.name}!`, 'success');
        }
      } finally {
        setTimeout(() => {
          this.isProcessingPurchase = false;
        }, 300);
      }
    }
  }

  private render() {
    this.clearPreviews();

    const inspectedSkin = getSkinById(this.inspectedShapeId);
    const equippedSkin = getSkinById(this.stats.equippedShape);
    const filteredSkins = this.getFilteredSkins();

    const totalUnlocked = this.stats.ownedShapes.length;
    const totalAvailable = SHAPE_SKINS.length;

    this.element.innerHTML = `
      <!-- SHOP HEADER BAR -->
      <header class="h-16 sm:h-20 flex-shrink-0 flex items-center justify-between px-4 sm:px-8 bg-black/40 border-b border-cyan-500/30 backdrop-blur-md">
        <div class="flex items-center gap-3 sm:gap-4">
          <button
            id="shop-back-btn"
            class="w-10 h-10 sm:w-12 sm:h-12 flex items-center justify-center rounded-xl bg-slate-800 border border-slate-700 hover:border-cyan-400 transition-colors cursor-pointer text-slate-200 hover:text-cyan-400 shadow-md"
            title="Return to Main Menu"
          >
            ${getIconSvg('arrow-left', 'w-5 h-5 sm:w-6 sm:h-6')}
          </button>
          <div>
            <h1 class="text-xl sm:text-2xl font-black tracking-tighter uppercase italic text-cyan-400 font-['Orbitron'] flex items-center gap-2">
              <span>Shape Skin Shop</span>
            </h1>
            <span class="text-[10px] text-slate-400 uppercase tracking-widest hidden sm:inline">
              Customize visual flight vectors & trail effects
            </span>
          </div>
        </div>

        <div class="flex items-center gap-4 sm:gap-8">
          <!-- Current In-Game Coin Balance -->
          <div class="flex flex-col items-end">
            <span class="text-[9px] sm:text-[10px] uppercase tracking-widest text-slate-400 font-bold">
              Speedy Coins
            </span>
            <div class="flex items-center gap-2">
              <span class="text-xl sm:text-2xl font-mono font-bold text-amber-400">
                ${this.stats.coins.toLocaleString()}
              </span>
              <div class="w-4 h-4 sm:w-5 sm:h-5 bg-amber-400 rounded-full shadow-[0_0_10px_rgba(251,191,36,0.6)] animate-pulse flex items-center justify-center">
                ${getIconSvg('coins', 'w-3 h-3 text-slate-950 stroke-[2.5]')}
              </div>
            </div>
          </div>

          <div class="w-px h-8 sm:h-10 bg-slate-700 hidden sm:block"></div>

          <!-- Currently Equipped Shape Pill -->
          <div class="hidden md:flex items-center gap-3 bg-cyan-500/10 px-4 py-2 rounded-full border border-cyan-500/30 shadow-[0_0_15px_rgba(34,211,238,0.15)]">
            <span class="text-[10px] uppercase font-bold text-cyan-300">Equipped:</span>
            <span class="font-bold uppercase tracking-tight text-white font-['Orbitron'] flex items-center gap-1.5">
              <span class="w-2 h-2 rounded-full bg-cyan-400 animate-ping inline-block"></span>
              ${equippedSkin.name}
            </span>
          </div>
        </div>
      </header>

      <!-- MOBILE HORIZONTAL CATEGORY STRIP -->
      <div class="flex sm:hidden overflow-x-auto p-2 gap-1.5 bg-black/40 border-b border-white/5 scrollbar-none flex-shrink-0">
        ${CATEGORIES.map(cat => {
          const isActive = this.selectedCategory === cat.id;
          return `
            <button
              data-cat="${cat.id}"
              class="mobile-cat-btn px-3 py-1.5 rounded-lg text-xs font-bold whitespace-nowrap transition-all flex items-center gap-1.5 cursor-pointer ${
                isActive
                  ? 'bg-cyan-500/20 border border-cyan-400 text-cyan-300'
                  : 'bg-white/5 text-slate-400 border border-transparent'
              }"
            >
              <span>${cat.icon}</span>
              <span>${cat.label}</span>
            </button>
          `;
        }).join('')}
      </div>

      <!-- MAIN AREA: SIDEBAR + GRID + INSPECTOR -->
      <main class="flex-1 flex overflow-hidden">
        <!-- Left Navigation Sidebar (Desktop/Tablet) -->
        <nav class="hidden sm:flex w-56 lg:w-64 border-r border-white/5 bg-black/20 p-4 lg:p-6 flex-col gap-4 overflow-y-auto flex-shrink-0">
          <!-- Search Box -->
          <div class="relative">
            <span class="w-4 h-4 text-slate-400 absolute left-3 top-2.5">${getIconSvg('search', 'w-4 h-4')}</span>
            <input
              type="text"
              id="shop-search-input"
              value="${this.searchQuery}"
              placeholder="Search shapes..."
              class="w-full pl-9 pr-8 py-2 rounded-xl bg-black/40 border border-white/10 text-xs text-white placeholder-slate-500 outline-none focus:border-cyan-400 transition-colors font-['Rajdhani']"
            />
            ${
              this.searchQuery
                ? `<button id="shop-clear-search-btn" class="absolute right-2.5 top-2 text-xs text-slate-400 hover:text-white">✕</button>`
                : ''
            }
          </div>

          <!-- Ownership Filter Selector -->
          <div class="grid grid-cols-3 gap-1 p-1 rounded-xl bg-black/40 border border-white/10">
            ${(['all', 'owned', 'unowned'] as const).map(filter => `
              <button
                data-own-filter="${filter}"
                class="own-filter-btn py-1 text-[10px] font-bold uppercase rounded-lg transition-all cursor-pointer ${
                  this.ownershipFilter === filter
                    ? 'bg-cyan-500 text-black font-black'
                    : 'text-slate-400 hover:text-white'
                }"
              >
                ${filter}
              </button>
            `).join('')}
          </div>

          <div class="text-[11px] uppercase tracking-[0.2em] text-slate-500 font-bold px-2 mt-1">
            Categories
          </div>

          <div class="flex flex-col gap-1.5">
            ${CATEGORIES.map(cat => {
              const count = cat.id === 'all'
                ? SHAPE_SKINS.length
                : SHAPE_SKINS.filter(s => s.category === cat.id).length;
              const isActive = this.selectedCategory === cat.id;

              return `
                <button
                  data-cat="${cat.id}"
                  class="sidebar-cat-btn flex items-center justify-between px-3.5 py-2.5 rounded-xl text-xs font-bold tracking-wide transition-all cursor-pointer ${
                    isActive
                      ? 'bg-cyan-500/10 border border-cyan-500/40 text-cyan-400 shadow-[0_0_15px_rgba(34,211,238,0.1)]'
                      : 'hover:bg-white/5 text-slate-400 font-medium border border-transparent'
                  }"
                >
                  <div class="flex items-center gap-2">
                    <span class="text-base">${cat.icon}</span>
                    <span class="truncate">${cat.label}</span>
                  </div>
                  <span class="text-[10px] px-1.5 py-0.5 rounded font-mono ${
                    isActive ? 'bg-cyan-500/20 text-cyan-300' : 'text-slate-500'
                  }">
                    ${count}
                  </span>
                </button>
              `;
            }).join('')}
          </div>

          <!-- Collection Progress Box -->
          <div class="mt-auto p-4 bg-gradient-to-br from-indigo-950/40 to-purple-950/40 rounded-2xl border border-white/10">
            <div class="text-xs font-bold text-purple-300 mb-1.5 flex items-center justify-between font-['Orbitron']">
              <span class="flex items-center gap-1">${getIconSvg('sparkles', 'w-3.5 h-3.5')} COLLECTION</span>
              <span class="text-cyan-400 font-mono">${Math.round((totalUnlocked / totalAvailable) * 100)}%</span>
            </div>
            <div class="w-full h-1.5 bg-black/60 rounded-full overflow-hidden mb-2">
              <div
                class="h-full bg-gradient-to-r from-cyan-500 to-purple-500 rounded-full transition-all duration-500"
                style="width: ${(totalUnlocked / totalAvailable) * 100}%"
              ></div>
            </div>
            <div class="text-[11px] text-slate-400">
              ${totalUnlocked} of ${totalAvailable} skins unlocked
            </div>
          </div>
        </nav>

        <!-- Center Grid Section -->
        <section class="flex-1 p-3 sm:p-6 lg:p-8 grid grid-cols-2 sm:grid-cols-2 md:grid-cols-2 lg:grid-cols-3 xl:grid-cols-3 2xl:grid-cols-4 gap-3 sm:gap-5 overflow-y-auto content-start scrollbar-thin">
          ${
            filteredSkins.length === 0
              ? `
            <div class="col-span-full py-16 text-center text-slate-500">
              <p class="text-lg font-bold font-['Orbitron']">No shapes match your filter</p>
              <p class="text-xs mt-1">Try clearing your search query or selecting a different category.</p>
            </div>
          `
              : filteredSkins
                  .map(skin => {
                    const isOwned = this.stats.ownedShapes.includes(skin.id);
                    const isEquipped = this.stats.equippedShape === skin.id;
                    const isInspected = this.inspectedShapeId === skin.id;
                    const rarityStyle = RARITY_STYLES[skin.rarity] || RARITY_STYLES.common;
                    const canAfford = this.stats.coins >= skin.price;

                    return `
                      <div
                        data-skin-id="${skin.id}"
                        class="shop-card-item rounded-2xl p-3 sm:p-4 flex flex-col items-center gap-2 sm:gap-3 group transition-all cursor-pointer relative overflow-hidden ${
                          isEquipped
                            ? 'bg-cyan-950/20 border-2 border-cyan-400 shadow-[0_0_25px_rgba(34,211,238,0.2)]'
                            : isInspected
                            ? 'bg-white/10 border border-slate-300 shadow-lg'
                            : 'bg-white/5 border border-white/10 hover:bg-white/10 hover:border-white/20'
                        }"
                      >
                        <!-- Rarity & Category Header Tags -->
                        <div class="w-full flex items-center justify-between">
                          <span class="px-2 py-0.5 ${rarityStyle.bg} ${rarityStyle.text} border ${rarityStyle.border} text-[9px] font-black uppercase rounded shadow-sm">
                            ${skin.rarity}
                          </span>
                          <span class="text-[9px] font-bold text-slate-500 uppercase tracking-wider">
                            ${skin.renderType}
                          </span>
                        </div>

                        <!-- Animated Canvas Preview Container -->
                        <div data-preview-id="${skin.id}" class="w-24 h-24 sm:w-32 sm:h-32 flex items-center justify-center drop-shadow-[0_0_15px_rgba(34,211,238,0.4)]">
                        </div>

                        <!-- Info -->
                        <div class="text-center w-full">
                          <h3 class="font-black text-sm sm:text-base leading-tight uppercase italic text-slate-100 font-['Orbitron'] truncate">
                            ${skin.name}
                          </h3>
                          <div
                            class="text-[10px] sm:text-xs font-bold tracking-widest uppercase mt-0.5 ${
                              isEquipped
                                ? 'text-cyan-400 font-mono'
                                : isOwned
                                ? 'text-emerald-400 font-mono'
                                : 'text-amber-400 font-mono'
                            }"
                          >
                            ${
                              isEquipped
                                ? '★ EQUIPPED'
                                : isOwned
                                ? '✓ UNLOCKED'
                                : skin.price === 0
                                ? 'FREE'
                                : `🪙 ${skin.price.toLocaleString()}`
                            }
                          </div>
                        </div>

                        <!-- Action Button -->
                        <div class="w-full mt-auto">
                          ${
                            isEquipped
                              ? `
                            <button
                              disabled
                              class="w-full py-1.5 sm:py-2 rounded-xl bg-cyan-500/20 text-cyan-300 font-bold text-xs uppercase border border-cyan-500/40 cursor-default flex items-center justify-center gap-1"
                            >
                              ${getIconSvg('check', 'w-3.5 h-3.5')}
                              <span>Active</span>
                            </button>
                          `
                              : isOwned
                              ? `
                            <button
                              data-action-skin="${skin.id}"
                              class="shop-card-action-btn w-full py-1.5 sm:py-2 rounded-xl bg-cyan-500 text-black font-black text-xs uppercase hover:bg-cyan-400 transition-colors shadow-[0_0_15px_rgba(34,211,238,0.4)] cursor-pointer"
                            >
                              Equip
                            </button>
                          `
                              : `
                            <button
                              data-action-skin="${skin.id}"
                              ${!canAfford || this.isProcessingPurchase ? 'disabled' : ''}
                              class="shop-card-action-btn w-full py-1.5 sm:py-2 rounded-xl font-black text-xs uppercase transition-all cursor-pointer flex items-center justify-center gap-1.5 ${
                                canAfford
                                  ? 'bg-amber-500 text-black shadow-[0_0_15px_rgba(245,158,11,0.3)] hover:bg-amber-400'
                                  : 'bg-slate-900/80 text-slate-500 border border-slate-800 cursor-not-allowed opacity-60'
                              }"
                            >
                              ${getIconSvg('coins', 'w-3.5 h-3.5')}
                              <span>Buy ${skin.price}</span>
                            </button>
                          `
                          }
                        </div>
                      </div>
                    `;
                  })
                  .join('')
          }
        </section>

        <!-- Right Preview Details Aside (Desktop/Large Screen) -->
        <aside class="hidden lg:flex w-80 xl:w-92 bg-black/40 border-l border-white/5 p-6 flex-col gap-4 overflow-y-auto flex-shrink-0">
          <div class="flex items-center justify-between">
            <span class="text-[11px] uppercase tracking-[0.2em] text-slate-500 font-bold">
              Shape Inspector
            </span>
            <span class="px-2 py-0.5 text-[9px] font-black uppercase rounded border ${RARITY_STYLES[inspectedSkin.rarity]?.bg} ${RARITY_STYLES[inspectedSkin.rarity]?.text} ${RARITY_STYLES[inspectedSkin.rarity]?.border}">
              ${inspectedSkin.rarity}
            </span>
          </div>

          <!-- Large Preview Stage -->
          <div id="inspector-preview-stage" class="aspect-[4/3] rounded-3xl bg-gradient-to-b from-white/10 to-transparent border border-white/10 flex items-center justify-center relative group p-4 overflow-hidden shadow-inner">
            <div
              class="absolute inset-0 blur-2xl opacity-20 rounded-full"
              style="background-color: ${inspectedSkin.color}"
            ></div>
          </div>

          <!-- Description & Lore -->
          <div class="flex flex-col gap-1">
            <h2 class="text-2xl font-black italic uppercase tracking-tight text-white font-['Orbitron']">
              ${inspectedSkin.name}
            </h2>
            <div class="text-[10px] uppercase font-bold text-cyan-400 tracking-wider">
              ${inspectedSkin.category} Class • ${inspectedSkin.trailType} Trail
            </div>
            <p class="text-xs text-slate-400 leading-relaxed mt-1">
              ${inspectedSkin.description}
            </p>
          </div>

          <!-- Segmented Metric Indicators -->
          <div class="grid grid-cols-2 gap-3">
            <div class="p-3 rounded-xl bg-white/5 border border-white/5">
              <div class="text-[9px] uppercase font-bold text-slate-500 mb-1 flex items-center justify-between">
                <span>Aerodynamics</span>
                <span class="text-cyan-400 font-mono">${inspectedSkin.stats.aerodynamics}%</span>
              </div>
              <div class="flex gap-1">
                ${[0, 25, 50, 75]
                  .map(
                    threshold => `
                  <div
                    class="h-1 w-full rounded-full transition-all ${
                      inspectedSkin.stats.aerodynamics > threshold
                        ? 'bg-cyan-500 shadow-[0_0_6px_rgba(6,182,212,0.6)]'
                        : 'bg-slate-800'
                    }"
                  ></div>
                `
                  )
                  .join('')}
              </div>
            </div>

            <div class="p-3 rounded-xl bg-white/5 border border-white/5">
              <div class="text-[9px] uppercase font-bold text-slate-500 mb-1 flex items-center justify-between">
                <span>Glow Intensity</span>
                <span class="text-purple-400 font-mono">${inspectedSkin.stats.glowIntensity}%</span>
              </div>
              <div class="flex gap-1">
                ${[0, 25, 50, 75]
                  .map(
                    threshold => `
                  <div
                    class="h-1 w-full rounded-full transition-all ${
                      inspectedSkin.stats.glowIntensity > threshold
                        ? 'bg-purple-500 shadow-[0_0_6px_rgba(168,85,247,0.6)]'
                        : 'bg-slate-800'
                    }"
                  ></div>
                `
                  )
                  .join('')}
              </div>
            </div>
          </div>

          <!-- Skin Features / Capabilities -->
          <div class="space-y-1.5 p-3 rounded-xl bg-white/5 border border-white/5">
            <div class="text-[10px] uppercase font-bold text-slate-400 tracking-wider">
              Visual Specs & Trail
            </div>
            ${inspectedSkin.features
              .map(
                feat => `
              <div class="flex items-center gap-2 text-xs text-slate-300">
                <div
                  class="w-1.5 h-1.5 rounded-full"
                  style="background-color: ${inspectedSkin.color}; box-shadow: 0 0 6px ${inspectedSkin.color}"
                ></div>
                <span class="truncate">${feat}</span>
              </div>
            `
              )
              .join('')}
          </div>

          <!-- Main Action CTA Button at Bottom of Inspector -->
          <div class="mt-auto flex flex-col gap-2 pt-2">
            <div class="flex items-center justify-between px-2 text-xs font-bold uppercase">
              <span class="text-slate-500">Status</span>
              <span
                class="${
                  this.stats.equippedShape === inspectedSkin.id
                    ? 'text-cyan-400 font-mono'
                    : this.stats.ownedShapes.includes(inspectedSkin.id)
                    ? 'text-emerald-400 font-mono'
                    : 'text-amber-400 font-mono'
                }"
              >
                ${
                  this.stats.equippedShape === inspectedSkin.id
                    ? 'Currently Active'
                    : this.stats.ownedShapes.includes(inspectedSkin.id)
                    ? 'Owned in Inventory'
                    : `Price: ${inspectedSkin.price} Coins`
                }
              </span>
            </div>

            ${
              this.stats.equippedShape === inspectedSkin.id
                ? `
              <button
                disabled
                class="w-full py-3.5 rounded-xl bg-white/10 text-cyan-300 font-bold text-sm uppercase tracking-widest border border-cyan-400/40 cursor-default flex items-center justify-center gap-2"
              >
                ${getIconSvg('check', 'w-4 h-4')}
                <span>Equipped</span>
              </button>
            `
                : this.stats.ownedShapes.includes(inspectedSkin.id)
                ? `
              <button
                id="inspector-action-btn"
                class="w-full py-3.5 rounded-xl bg-cyan-500 text-black font-black text-sm uppercase tracking-widest shadow-[0_0_30px_rgba(34,211,238,0.4)] hover:bg-cyan-400 transition-all cursor-pointer flex items-center justify-center gap-2"
              >
                ${getIconSvg('zap', 'w-4 h-4')}
                <span>Equip Shape</span>
              </button>
            `
                : `
              <button
                id="inspector-action-btn"
                ${this.stats.coins < inspectedSkin.price || this.isProcessingPurchase ? 'disabled' : ''}
                class="w-full py-3.5 rounded-xl font-black text-sm uppercase tracking-widest transition-all cursor-pointer flex items-center justify-center gap-2 ${
                  this.stats.coins >= inspectedSkin.price
                    ? 'bg-amber-500 text-black shadow-[0_0_30px_rgba(245,158,11,0.4)] hover:bg-amber-400'
                    : 'bg-slate-900 text-slate-500 border border-slate-800 cursor-not-allowed opacity-60'
                }"
              >
                ${getIconSvg('coins', 'w-4 h-4')}
                <span>Purchase (${inspectedSkin.price} Coins)</span>
              </button>
            `
            }
          </div>
        </aside>
      </main>

      <!-- SHOP FOOTER STATUS BAR -->
      <footer class="h-10 px-4 sm:px-8 flex items-center justify-between bg-black/60 border-t border-white/5 flex-shrink-0 text-[10px] text-slate-500 font-bold uppercase">
        <div class="flex items-center gap-4 sm:gap-6">
          <span class="flex items-center">
            <span class="text-cyan-500 mr-1.5 font-black">•</span>
            ${totalUnlocked}/${totalAvailable} Skins Unlocked
          </span>
          <span class="flex items-center hidden sm:inline-flex">
            <span class="text-amber-500 mr-1.5 font-black">•</span>
            ${this.stats.coins.toLocaleString()} Coins Balance
          </span>
        </div>
        <span class="text-slate-500 font-mono">
          Speedy Arrow • Shape Skins Engine
        </span>
      </footer>
    `;

    // Mount Canvas Previews for Grid Items
    filteredSkins.forEach(skin => {
      const container = this.element.querySelector(`[data-preview-id="${skin.id}"]`);
      if (container) {
        const preview = new ShapeCanvasPreview(skin, 110, 95, 36);
        container.appendChild(preview.element);
        this.previewInstances.set(skin.id, preview);
      }
    });

    // Mount Canvas Preview for Inspector Stage
    const inspectorStage = this.element.querySelector('#inspector-preview-stage');
    if (inspectorStage) {
      this.inspectorPreview = new ShapeCanvasPreview(inspectedSkin, 220, 170, 56);
      inspectorStage.appendChild(this.inspectorPreview.element);
    }

    // Attach Event Listeners
    this.element.querySelector('#shop-back-btn')?.addEventListener('click', () => this.callbacks.onBack());

    const searchInput = this.element.querySelector('#shop-search-input') as HTMLInputElement | null;
    if (searchInput) {
      searchInput.addEventListener('input', (e) => {
        this.searchQuery = (e.target as HTMLInputElement).value;
        this.render();
        // Restore focus to input
        const newSearch = this.element.querySelector('#shop-search-input') as HTMLInputElement | null;
        if (newSearch) {
          newSearch.focus();
          newSearch.setSelectionRange(newSearch.value.length, newSearch.value.length);
        }
      });
    }

    this.element.querySelector('#shop-clear-search-btn')?.addEventListener('click', () => {
      this.searchQuery = '';
      this.render();
    });

    this.element.querySelectorAll('.mobile-cat-btn, .sidebar-cat-btn').forEach(btn => {
      btn.addEventListener('click', (e) => {
        const cat = (e.currentTarget as HTMLElement).getAttribute('data-cat') as ShapeCategory;
        if (cat) {
          this.selectedCategory = cat;
          this.render();
        }
      });
    });

    this.element.querySelectorAll('.own-filter-btn').forEach(btn => {
      btn.addEventListener('click', (e) => {
        const filter = (e.currentTarget as HTMLElement).getAttribute('data-own-filter') as 'all' | 'owned' | 'unowned';
        if (filter) {
          this.ownershipFilter = filter;
          this.render();
        }
      });
    });

    this.element.querySelectorAll('.shop-card-item').forEach(card => {
      card.addEventListener('click', (e) => {
        const skinId = (e.currentTarget as HTMLElement).getAttribute('data-skin-id');
        if (skinId) {
          this.inspectedShapeId = skinId;
          this.render();
        }
      });
    });

    this.element.querySelectorAll('.shop-card-action-btn').forEach(btn => {
      btn.addEventListener('click', (e) => {
        e.stopPropagation();
        const skinId = (e.currentTarget as HTMLElement).getAttribute('data-action-skin');
        if (skinId) {
          const skin = getSkinById(skinId);
          this.handleAction(skin);
        }
      });
    });

    this.element.querySelector('#inspector-action-btn')?.addEventListener('click', () => {
      this.handleAction(inspectedSkin);
    });
  }
}
