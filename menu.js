/**
 * Speedy Arrow - Menu & UI Manager
 * Handles screen transitions, tab selection, inventory purchases, fake IAP list,
 * Daily gift claiming and timer countdowns, settings persistence, and modals.
 */

const DEFAULT_STATE = {
  gems: 40,
  premiumGems: 0,
  unlockedShips: ["classic", "teardrop"],
  unlockedTrails: ["solid"],
  unlockedThemes: ["purple"],
  equippedShip: "classic",
  equippedTrail: "solid",
  equippedTheme: "purple",

  endlessHighscore: 0,
  levelProgress: {}, // { levelIndex: starsCount (0 to 3) }
  raceDifficulty: "MEDIUM", // EASY, MEDIUM, HARD

  lastDailyGiftClaimed: 0, // epoch milliseconds
  sfxEnabled: true,
  reduceMotionEnabled: false
};

class StateManager {
  constructor() {
    this.state = { ...DEFAULT_STATE };
    this.load();
  }

  load() {
    try {
      const stored = localStorage.getItem("speedy_arrow_state");
      if (stored) {
        const parsed = JSON.parse(stored);
        this.state = { ...DEFAULT_STATE, ...parsed };
      }
    } catch (e) {
      console.error("Failed to load state:", e);
    }
  }

  save() {
    try {
      localStorage.setItem("speedy_arrow_state", JSON.stringify(this.state));
    } catch (e) {
      console.error("Failed to save state:", e);
    }
    this.updateUIs();
  }

  reset() {
    this.state = JSON.parse(JSON.stringify(DEFAULT_STATE));
    this.save();
    window.location.reload();
  }

  updateUIs() {
    // Top headers balances
    const gemHeaders = ["header-gems-count", "shop-gems-count"];
    const premiumHeaders = ["header-premium-gems-count", "shop-premium-gems-count"];

    gemHeaders.forEach(id => {
      const el = document.getElementById(id);
      if (el) el.textContent = this.state.gems;
    });

    premiumHeaders.forEach(id => {
      const el = document.getElementById(id);
      if (el) el.textContent = this.state.premiumGems;
    });

    // Highscore text
    const hsEl = document.getElementById("endless-highscore-text");
    if (hsEl) hsEl.textContent = this.state.endlessHighscore;

    // Difficulty selector
    const diffLabel = document.getElementById("race-diff-label");
    if (diffLabel) diffLabel.textContent = this.state.raceDifficulty;

    // Settings inputs
    const sfxInput = document.getElementById("toggle-sfx");
    if (sfxInput) sfxInput.checked = this.state.sfxEnabled;

    const motionInput = document.getElementById("toggle-reduce-motion");
    if (motionInput) motionInput.checked = this.state.reduceMotionEnabled;
  }
}

// Global active instances
window.stateMgr = new StateManager();

// --- Screen Router ---
const SCREENS = ["screen-menu", "screen-shop", "screen-skins", "screen-levels", "screen-settings", "screen-gameplay"];

function showScreen(screenId) {
  SCREENS.forEach(id => {
    const el = document.getElementById(id);
    if (el) {
      if (id === screenId) {
        el.classList.add("active");
      } else {
        el.classList.remove("active");
      }
    }
  });

  // Apply current Theme styling properties on screen transitions
  applyThemeColors(window.stateMgr.state.equippedTheme);

  // Trigger content population based on destination
  if (screenId === "screen-shop") {
    populateShopGrid();
    updateShopPreview();
  } else if (screenId === "screen-skins") {
    populateSkinsGrid();
    updateSkinsPreview();
  } else if (screenId === "screen-levels") {
    populateLevelsGrid();
  }
}

// --- Dynamic theme applicator ---
function applyThemeColors(themeId) {
  const theme = window.THEMES[themeId] || window.THEMES["purple"];
  const root = document.documentElement;

  root.style.setProperty("--primary-color", theme.primary);
  root.style.setProperty("--secondary-color", theme.secondary);
  root.style.setProperty("--bg-color", theme.background);
  root.style.setProperty("--accent-color", theme.accent);
  root.style.setProperty("--text-muted", theme.secondary);
}

// --- Daily Reward Logic ---
const DAILY_REWARD_COOLDOWN = 24 * 60 * 60 * 1000; // 24 hours
const DAILY_GEM_REWARD = 250;

function updateDailyGiftTimer() {
  const now = Date.now();
  const lastClaim = window.stateMgr.state.lastDailyGiftClaimed || 0;
  const elapsed = now - lastClaim;
  const claimBtn = document.getElementById("daily-claim-btn");
  const timerText = document.getElementById("daily-timer-text");

  if (elapsed >= DAILY_REWARD_COOLDOWN) {
    if (claimBtn) claimBtn.style.display = "block";
    if (timerText) timerText.textContent = "CLAIM NOW!";
  } else {
    if (claimBtn) claimBtn.style.display = "none";
    const remaining = DAILY_REWARD_COOLDOWN - elapsed;
    const hours = Math.floor(remaining / (3600 * 1000));
    const mins = Math.floor((remaining % (3600 * 1000)) / (60 * 1000));
    const secs = Math.floor((remaining % (60 * 1000)) / 1000);

    const pad = (n) => String(n).padStart(2, '0');
    if (timerText) {
      timerText.textContent = `${pad(hours)}:${pad(mins)}:${pad(secs)}`;
    }
  }
}

// --- Shop Items Management ---
let shopActiveCategory = "ship";

function populateShopGrid() {
  const grid = document.getElementById("shop-items-grid");
  if (!grid) return;
  grid.innerHTML = "";

  const state = window.stateMgr.state;

  if (shopActiveCategory === "ship") {
    window.SHIPS.forEach(ship => {
      const isOwned = state.unlockedShips.includes(ship.id);
      const isEquipped = state.equippedShip === ship.id;
      createShopTile(grid, ship.id, ship.name, ship.svg, ship.price, ship.currency, ship.isPremium, isOwned, isEquipped, "ship");
    });
  } else if (shopActiveCategory === "trail") {
    window.TRAILS.forEach(trail => {
      const isOwned = state.unlockedTrails.includes(trail.id);
      const isEquipped = state.equippedTrail === trail.id;

      // Simple preview representations
      const visual = `<svg viewBox="0 0 100 100" width="100%" height="100%">
        <path d="M 15,25 L 85,25" stroke="${trail.color === 'rainbow' ? 'magenta' : (trail.color === 'fire' ? 'orange' : trail.color)}" stroke-width="12" stroke-linecap="round"/>
        <path d="M 15,50 L 85,50" stroke="${trail.color === 'rainbow' ? 'cyan' : (trail.color === 'fire' ? 'red' : trail.color)}" stroke-width="8" stroke-linecap="round" opacity="0.7"/>
        <path d="M 15,75 L 85,75" stroke="${trail.color === 'rainbow' ? 'yellow' : (trail.color === 'fire' ? 'yellow' : trail.color)}" stroke-width="4" stroke-linecap="round" opacity="0.4"/>
      </svg>`;

      createShopTile(grid, trail.id, trail.name, visual, trail.price, trail.isPremium ? "premium" : "gem", trail.isPremium, isOwned, isEquipped, "trail");
    });
  } else if (shopActiveCategory === "theme") {
    Object.values(window.THEMES).forEach(theme => {
      const isOwned = state.unlockedThemes.includes(theme.id);
      const isEquipped = state.equippedTheme === theme.id;

      const visual = `<svg viewBox="0 0 100 100" width="100%" height="100%">
        <rect x="10" y="10" width="80" height="80" rx="10" fill="${theme.background}" stroke="${theme.primary}" stroke-width="6"/>
        <circle cx="50" cy="50" r="15" fill="${theme.accent}"/>
      </svg>`;

      createShopTile(grid, theme.id, theme.name, visual, 200, "gem", false, isOwned, isEquipped, "theme");
    });
  }
}

function createShopTile(grid, id, name, svgMarkup, price, currency, isPremium, isOwned, isEquipped, category) {
  const tile = document.createElement("div");
  tile.className = `item-tile ${isOwned ? 'owned' : ''} ${isEquipped ? 'equipped' : ''}`;

  if (isPremium) {
    const ribbon = document.createElement("div");
    ribbon.className = "premium-ribbon";
    tile.appendChild(ribbon);
  }

  const iconContainer = document.createElement("div");
  iconContainer.className = "item-tile-icon";
  iconContainer.innerHTML = svgMarkup;
  tile.appendChild(iconContainer);

  const priceContainer = document.createElement("div");
  priceContainer.className = "item-tile-price";

  if (isEquipped) {
    priceContainer.textContent = "EQUIPPED";
    priceContainer.style.color = "var(--accent-color)";
  } else if (isOwned) {
    priceContainer.textContent = "EQUIP";
  } else {
    // Currency icon
    const iconSpan = document.createElement("span");
    iconSpan.style.display = "inline-flex";
    iconSpan.style.alignItems = "center";
    if (currency === "premium") {
      iconSpan.innerHTML = `<svg viewBox="0 0 24 24" width="12" height="12" fill="gold"><polygon points="12,2 22,8.5 12,22 2,8.5"></polygon></svg>`;
    } else {
      iconSpan.innerHTML = `<svg viewBox="0 0 24 24" width="12" height="12" fill="var(--accent-color)"><polygon points="12,2 22,9 17,22 7,22 2,9"></polygon></svg>`;
    }
    priceContainer.appendChild(iconSpan);
    priceContainer.append(` ${price}`);
  }

  tile.appendChild(priceContainer);

  tile.addEventListener("click", () => {
    window.audioSynth.playClick();
    if (isEquipped) return;

    if (isOwned) {
      // Equip directly
      equipItem(category, id);
    } else {
      // Purchase dialogue
      openPurchaseModal(category, id, name, price, currency, svgMarkup);
    }
  });

  grid.appendChild(tile);
}

function equipItem(category, id) {
  const state = window.stateMgr.state;
  if (category === "ship") {
    state.equippedShip = id;
    updateShopPreview();
  } else if (category === "trail") {
    state.equippedTrail = id;
    updateShopPreview();
  } else if (category === "theme") {
    state.equippedTheme = id;
    applyThemeColors(id);
    updateShopPreview();
  }
  window.stateMgr.save();
  populateShopGrid();
}

function updateShopPreview() {
  const state = window.stateMgr.state;
  const container = document.getElementById("shop-preview-svg-container");
  if (!container) return;

  const equippedShipData = window.SHIPS.find(s => s.id === state.equippedShip);
  if (equippedShipData) {
    container.innerHTML = equippedShipData.svg;
  }

  // Visual trail line preview coloring
  const streak = document.getElementById("shop-preview-streak");
  if (streak) {
    const trailData = window.TRAILS.find(t => t.id === state.equippedTrail);
    if (trailData) {
      if (trailData.color === "rainbow") {
        streak.style.background = "linear-gradient(90deg, red, orange, yellow, green, blue, purple)";
      } else if (trailData.color === "fire") {
        streak.style.background = "linear-gradient(90deg, red, orange, yellow)";
      } else {
        streak.style.background = `linear-gradient(90deg, transparent, ${trailData.color}, transparent)`;
      }
    }
  }

  // Random tip bubble content
  const bubble = document.getElementById("shop-chat-bubble");
  if (bubble) {
    const tips = [
      "Click skins category tabs to explore custom visual trails and game themes!",
      "Tip: Tap & hold the screen to fly upward, release to fall under gravity.",
      "Unlock high-tier ships by gathering Gems in the levels of Classic mode!",
      "Race Mode speed rewards the player with quick gem boosts upon a 1st place run!",
      "Collect floating green crystals during gameplay to boost your score!",
    ];
    bubble.textContent = tips[Math.floor(Math.random() * tips.length)];
  }
}

// --- Skin Picker Inventory ---
let skinsActiveCategory = "ship";

function populateSkinsGrid() {
  const grid = document.getElementById("skins-items-grid");
  if (!grid) return;
  grid.innerHTML = "";

  const state = window.stateMgr.state;

  if (skinsActiveCategory === "ship") {
    window.SHIPS.forEach(ship => {
      const isOwned = state.unlockedShips.includes(ship.id);
      const isEquipped = state.equippedShip === ship.id;
      createSkinTile(grid, ship.id, ship.name, ship.svg, isOwned, isEquipped, "ship");
    });
  } else if (skinsActiveCategory === "trail") {
    window.TRAILS.forEach(trail => {
      const isOwned = state.unlockedTrails.includes(trail.id);
      const isEquipped = state.equippedTrail === trail.id;
      const visual = `<svg viewBox="0 0 100 100" width="100%" height="100%">
        <path d="M 15,25 L 85,25" stroke="${trail.color === 'rainbow' ? 'magenta' : (trail.color === 'fire' ? 'orange' : trail.color)}" stroke-width="12" stroke-linecap="round"/>
        <path d="M 15,50 L 85,50" stroke="${trail.color === 'rainbow' ? 'cyan' : (trail.color === 'fire' ? 'red' : trail.color)}" stroke-width="8" stroke-linecap="round" opacity="0.7"/>
        <path d="M 15,75 L 85,75" stroke="${trail.color === 'rainbow' ? 'yellow' : (trail.color === 'fire' ? 'yellow' : trail.color)}" stroke-width="4" stroke-linecap="round" opacity="0.4"/>
      </svg>`;
      createSkinTile(grid, trail.id, trail.name, visual, isOwned, isEquipped, "trail");
    });
  } else if (skinsActiveCategory === "theme") {
    Object.values(window.THEMES).forEach(theme => {
      const isOwned = state.unlockedThemes.includes(theme.id);
      const isEquipped = state.equippedTheme === theme.id;
      const visual = `<svg viewBox="0 0 100 100" width="100%" height="100%">
        <rect x="10" y="10" width="80" height="80" rx="10" fill="${theme.background}" stroke="${theme.primary}" stroke-width="6"/>
        <circle cx="50" cy="50" r="15" fill="${theme.accent}"/>
      </svg>`;
      createSkinTile(grid, theme.id, theme.name, visual, isOwned, isEquipped, "theme");
    });
  }
}

function createSkinTile(grid, id, name, svgMarkup, isOwned, isEquipped, category) {
  const tile = document.createElement("div");
  tile.className = `item-tile ${isOwned ? 'owned' : 'locked'} ${isEquipped ? 'equipped' : ''}`;

  const iconContainer = document.createElement("div");
  iconContainer.className = "item-tile-icon";
  iconContainer.innerHTML = svgMarkup;
  tile.appendChild(iconContainer);

  const label = document.createElement("div");
  label.className = "item-tile-price";

  if (isEquipped) {
    label.textContent = "EQUIPPED";
    label.style.color = "var(--accent-color)";
  } else if (isOwned) {
    label.textContent = "EQUIP";
  } else {
    // Locked pad lock symbol
    label.innerHTML = `<svg viewBox="0 0 24 24" width="12" height="12" fill="none" stroke="currentColor" stroke-width="2"><rect x="3" y="11" width="18" height="11" rx="2" ry="2"></rect><path d="M7 11V7a5 5 0 0 1 10 0v4"></path></svg>`;
  }

  tile.appendChild(label);

  tile.addEventListener("click", () => {
    window.audioSynth.playClick();
    if (!isOwned) {
      // Shake animation to represent locked tile
      tile.classList.add("shake-it");
      setTimeout(() => tile.classList.remove("shake-it"), 400);
      return;
    }
    if (isEquipped) return;

    // Equip
    if (category === "ship") {
      stateMgr.state.equippedShip = id;
    } else if (category === "trail") {
      stateMgr.state.equippedTrail = id;
    } else if (category === "theme") {
      stateMgr.state.equippedTheme = id;
      applyThemeColors(id);
    }
    stateMgr.save();
    populateSkinsGrid();
    updateSkinsPreview();
  });

  grid.appendChild(tile);
}

function updateSkinsPreview() {
  const state = window.stateMgr.state;
  const container = document.getElementById("skins-preview-svg-container");
  const nameLabel = document.getElementById("skins-preview-name");

  if (!container || !nameLabel) return;

  const equippedShipData = window.SHIPS.find(s => s.id === state.equippedShip);
  if (equippedShipData) {
    container.innerHTML = equippedShipData.svg;
    nameLabel.textContent = equippedShipData.name.toUpperCase();
  }

  // Streak update
  const streak = document.getElementById("skins-preview-streak");
  if (streak) {
    const trailData = window.TRAILS.find(t => t.id === state.equippedTrail);
    if (trailData) {
      if (trailData.color === "rainbow") {
        streak.style.background = "linear-gradient(90deg, red, orange, yellow, green, blue, purple)";
      } else if (trailData.color === "fire") {
        streak.style.background = "linear-gradient(90deg, red, orange, yellow)";
      } else {
        streak.style.background = `linear-gradient(90deg, transparent, ${trailData.color}, transparent)`;
      }
    }
  }
}

// --- Classic Mode Levels selector grid ---
function populateLevelsGrid() {
  const container = document.getElementById("level-grid-container");
  if (!container) return;
  container.innerHTML = "";

  const state = window.stateMgr.state;

  for (let i = 0; i < 10; i++) {
    const isCompleted = state.levelProgress[i] !== undefined;
    const isUnlocked = i === 0 || state.levelProgress[i - 1] !== undefined;
    const stars = state.levelProgress[i] || 0;

    const tile = document.createElement("div");
    tile.className = `level-tile ${isUnlocked ? 'active' : 'locked'}`;

    if (isUnlocked) {
      tile.textContent = i + 1;

      // Star rating display
      const starsDiv = document.createElement("div");
      starsDiv.className = "level-stars";
      for (let s = 1; s <= 3; s++) {
        const star = document.createElement("span");
        star.className = `level-star ${s <= stars ? 'filled' : ''}`;
        star.textContent = "★";
        starsDiv.appendChild(star);
      }
      tile.appendChild(starsDiv);

      tile.addEventListener("click", () => {
        window.audioSynth.playClick();
        // Start Classic Level Game Run!
        startGameRun("classic", i);
      });
    } else {
      // Padlock icon
      tile.innerHTML = `<svg viewBox="0 0 24 24" width="24" height="24" fill="none" stroke="currentColor" stroke-width="2">
        <rect x="3" y="11" width="18" height="11" rx="2" ry="2"></rect>
        <path d="M7 11V7a5 5 0 0 1 10 0v4"></path>
      </svg>`;
    }

    container.appendChild(tile);
  }
}

// --- Purchase and Notification Modal Dialogs ---
function openModal(contentHtml) {
  const container = document.getElementById("modal-container");
  const wrapper = document.getElementById("modal-content-wrapper");
  if (!container || !wrapper) return;

  wrapper.innerHTML = contentHtml;
  container.classList.add("active");
}

function closeModal() {
  const container = document.getElementById("modal-container");
  if (container) container.classList.remove("active");
}

function openPurchaseModal(category, id, name, price, currency, svgMarkup) {
  const state = window.stateMgr.state;
  const balance = currency === "premium" ? state.premiumGems : state.gems;
  const color = currency === "premium" ? "gold" : "var(--accent-color)";

  let canAfford = balance >= price;

  let html = `
    <h2>PURCHASE SKIN</h2>
    <div style="width: 80px; height: 80px; margin: 10px auto; border-radius: 50%; border: 2px dashed ${color}; padding: 10px; color:${color};">
      ${svgMarkup}
    </div>
    <p>Unlock <strong>${name}</strong> for:</p>
    <div style="font-size: 1.4rem; font-weight:700; color: ${color}; display:flex; align-items:center; justify-content:center; gap: 6px; margin: 10px 0;">
      <svg viewBox="0 0 24 24" width="20" height="20" fill="${color}">
        ${currency === 'premium' ? '<polygon points="12,2 22,8.5 12,22 2,8.5"></polygon>' : '<polygon points="12,2 22,9 17,22 7,22 2,9"></polygon>'}
      </svg>
      ${price}
    </div>
  `;

  if (!canAfford) {
    html += `
      <p style="color:#ff1744; font-weight:600;">NOT ENOUGH GEMS!</p>
      <div style="display:flex; gap:10px; margin-top:10px;">
        <button id="modal-buy-get-gems" class="primary btn" style="flex:1;">GET MORE GEMS</button>
        <button id="modal-buy-close" class="btn" style="flex:1;">CLOSE</button>
      </div>
    `;
  } else {
    html += `
      <div style="display:flex; gap:10px; margin-top:10px;">
        <button id="modal-buy-confirm" class="primary btn" style="flex:1;">CONFIRM</button>
        <button id="modal-buy-close" class="btn" style="flex:1;">CANCEL</button>
      </div>
    `;
  }

  openModal(html);

  // Wire modal buttons
  const closeBtn = document.getElementById("modal-buy-close");
  if (closeBtn) {
    closeBtn.addEventListener("click", () => {
      window.audioSynth.playClick();
      closeModal();
    });
  }

  const getGemsBtn = document.getElementById("modal-buy-get-gems");
  if (getGemsBtn) {
    getGemsBtn.addEventListener("click", () => {
      window.audioSynth.playClick();
      closeModal();
      openIAPModal();
    });
  }

  const confirmBtn = document.getElementById("modal-buy-confirm");
  if (confirmBtn) {
    confirmBtn.addEventListener("click", () => {
      window.audioSynth.playClick();
      // Execute Purchase
      if (currency === "premium") {
        state.premiumGems -= price;
      } else {
        state.gems -= price;
      }

      if (category === "ship") {
        state.unlockedShips.push(id);
        state.equippedShip = id;
      } else if (category === "trail") {
        state.unlockedTrails.push(id);
        state.equippedTrail = id;
      } else if (category === "theme") {
        state.unlockedThemes.push(id);
        state.equippedTheme = id;
        applyThemeColors(id);
      }

      window.stateMgr.save();
      closeModal();
      populateShopGrid();
      updateShopPreview();
    });
  }
}

function openIAPModal() {
  const html = `
    <h2>GET MORE GEMS</h2>
    <p style="font-size:0.85rem; opacity:0.8;">Instantly boost your balances with fake IAP packages!</p>
    <div class="iap-grid" style="margin: 15px 0;">
      <div class="iap-tile" data-gems="500" data-premium="0" data-price="$0.99">
        <div class="iap-tile-left">
          <div class="iap-tile-gems">
            <svg viewBox="0 0 24 24" width="16" height="16" fill="var(--accent-color)"><polygon points="12,2 22,9 17,22 7,22 2,9"></polygon></svg>
            500 Gems
          </div>
        </div>
        <div class="iap-tile-price">$0.99</div>
      </div>
      <div class="iap-tile" data-gems="2500" data-premium="5" data-price="$4.99">
        <div class="iap-tile-left">
          <div class="iap-tile-gems">
            <svg viewBox="0 0 24 24" width="16" height="16" fill="var(--accent-color)"><polygon points="12,2 22,9 17,22 7,22 2,9"></polygon></svg>
            2.5k Gems + <span style="color:gold;">5 Premium</span>
          </div>
        </div>
        <div class="iap-tile-price">$4.99</div>
      </div>
      <div class="iap-tile" data-gems="10000" data-premium="30" data-price="$9.99">
        <div class="iap-tile-left">
          <div class="iap-tile-gems">
            <svg viewBox="0 0 24 24" width="16" height="16" fill="var(--accent-color)"><polygon points="12,2 22,9 17,22 7,22 2,9"></polygon></svg>
            10k Gems + <span style="color:gold;">30 Premium</span>
          </div>
        </div>
        <div class="iap-tile-price">$9.99</div>
      </div>
    </div>
    <button id="modal-iap-close" class="btn" style="width:100%;">CLOSE</button>
  `;

  openModal(html);

  const closeBtn = document.getElementById("modal-iap-close");
  if (closeBtn) {
    closeBtn.addEventListener("click", () => {
      window.audioSynth.playClick();
      closeModal();
    });
  }

  // Click handler on fake purchase rows
  document.querySelectorAll(".iap-tile").forEach(tile => {
    tile.addEventListener("click", () => {
      window.audioSynth.playCoin();
      const gems = parseInt(tile.getAttribute("data-gems"));
      const prem = parseInt(tile.getAttribute("data-premium"));

      window.stateMgr.state.gems += gems;
      window.stateMgr.state.premiumGems += prem;
      window.stateMgr.save();

      closeModal();
    });
  });
}

function openResetConfirmModal() {
  const html = `
    <h2 style="color:#ff1744;">RESET ALL PROGRESS?</h2>
    <p>This will erase your level stars, gems, highscores, and unlocked skins forever!</p>
    <div style="display:flex; gap:10px; margin-top:20px;">
      <button id="modal-reset-confirm" class="danger btn" style="flex:1;">YES, RESET</button>
      <button id="modal-reset-cancel" class="btn" style="flex:1;">CANCEL</button>
    </div>
  `;

  openModal(html);

  const cancelBtn = document.getElementById("modal-reset-cancel");
  if (cancelBtn) {
    cancelBtn.addEventListener("click", () => {
      window.audioSynth.playClick();
      closeModal();
    });
  }

  const confirmBtn = document.getElementById("modal-reset-confirm");
  if (confirmBtn) {
    confirmBtn.addEventListener("click", () => {
      window.audioSynth.playClick();
      window.stateMgr.reset();
    });
  }
}

// --- Wire Event Handlers ---
window.addEventListener("DOMContentLoaded", () => {
  // Init state
  window.stateMgr.updateUIs();
  applyThemeColors(window.stateMgr.state.equippedTheme);

  // Daily reward loop
  updateDailyGiftTimer();
  setInterval(updateDailyGiftTimer, 1000);

  // Shop categories
  document.querySelectorAll("#screen-shop .tab-btn").forEach(btn => {
    btn.addEventListener("click", () => {
      window.audioSynth.playClick();
      document.querySelectorAll("#screen-shop .tab-btn").forEach(b => b.classList.remove("active"));
      btn.classList.add("active");
      shopActiveCategory = btn.getAttribute("data-category");
      populateShopGrid();
    });
  });

  // Skins categories
  document.querySelectorAll("#screen-skins .tab-btn").forEach(btn => {
    btn.addEventListener("click", () => {
      window.audioSynth.playClick();
      document.querySelectorAll("#screen-skins .tab-btn").forEach(b => b.classList.remove("active"));
      btn.classList.add("active");
      skinsActiveCategory = btn.getAttribute("data-category");
      populateSkinsGrid();
    });
  });

  // Screen routing linkages
  document.getElementById("menu-btn-shop-shortcut").addEventListener("click", () => {
    window.audioSynth.playClick();
    showScreen("screen-shop");
  });
  document.getElementById("add-gems-btn").addEventListener("click", (e) => {
    e.stopPropagation();
    window.audioSynth.playClick();
    openIAPModal();
  });
  document.getElementById("menu-btn-skins").addEventListener("click", () => {
    window.audioSynth.playClick();
    showScreen("screen-skins");
  });
  document.getElementById("menu-btn-settings").addEventListener("click", () => {
    window.audioSynth.playClick();
    showScreen("screen-settings");
  });
  document.getElementById("menu-btn-classic-level").addEventListener("click", () => {
    window.audioSynth.playClick();
    showScreen("screen-levels");
  });

  // Backs
  document.getElementById("shop-btn-back").addEventListener("click", () => {
    window.audioSynth.playClick();
    showScreen("screen-menu");
  });
  document.getElementById("shop-btn-skins-shortcut").addEventListener("click", () => {
    window.audioSynth.playClick();
    showScreen("screen-skins");
  });
  document.getElementById("skins-btn-back").addEventListener("click", () => {
    window.audioSynth.playClick();
    showScreen("screen-menu");
  });
  document.getElementById("skins-btn-shop-shortcut").addEventListener("click", () => {
    window.audioSynth.playClick();
    showScreen("screen-shop");
  });
  document.getElementById("levels-btn-back").addEventListener("click", () => {
    window.audioSynth.playClick();
    showScreen("screen-menu");
  });
  document.getElementById("settings-btn-back").addEventListener("click", () => {
    window.audioSynth.playClick();
    showScreen("screen-menu");
  });

  // Claim gift
  document.getElementById("daily-claim-btn").addEventListener("click", () => {
    window.audioSynth.playCoin();
    window.stateMgr.state.lastDailyGiftClaimed = Date.now();
    window.stateMgr.state.gems += DAILY_GEM_REWARD;
    window.stateMgr.save();
    updateDailyGiftTimer();
  });

  // Difficulty selector toggles
  const difficultyLevels = ["EASY", "MEDIUM", "HARD"];
  document.getElementById("race-diff-left").addEventListener("click", () => {
    window.audioSynth.playClick();
    let idx = difficultyLevels.indexOf(window.stateMgr.state.raceDifficulty);
    idx = (idx - 1 + difficultyLevels.length) % difficultyLevels.length;
    window.stateMgr.state.raceDifficulty = difficultyLevels[idx];
    window.stateMgr.save();
  });
  document.getElementById("race-diff-right").addEventListener("click", () => {
    window.audioSynth.playClick();
    let idx = difficultyLevels.indexOf(window.stateMgr.state.raceDifficulty);
    idx = (idx + 1) % difficultyLevels.length;
    window.stateMgr.state.raceDifficulty = difficultyLevels[idx];
    window.stateMgr.save();
  });

  // Toggle controls
  document.getElementById("toggle-sfx").addEventListener("change", (e) => {
    window.stateMgr.state.sfxEnabled = e.target.checked;
    window.stateMgr.save();
  });
  document.getElementById("toggle-reduce-motion").addEventListener("change", (e) => {
    window.stateMgr.state.reduceMotionEnabled = e.target.checked;
    window.stateMgr.save();
  });
  document.getElementById("settings-reset-btn").addEventListener("click", () => {
    window.audioSynth.playClick();
    openResetConfirmModal();
  });

  // Mode click handles
  document.getElementById("mode-start-classic").addEventListener("click", () => {
    window.audioSynth.playClick();
    // Select first level available or simply highest completed
    let lastLevel = 0;
    for (let i = 0; i < 10; i++) {
      if (window.stateMgr.state.levelProgress[i] !== undefined) {
        lastLevel = i;
      }
    }
    startGameRun("classic", lastLevel);
  });

  document.getElementById("mode-start-endless").addEventListener("click", () => {
    window.audioSynth.playClick();
    startGameRun("endless");
  });

  document.getElementById("mode-start-race").addEventListener("click", () => {
    window.audioSynth.playClick();
    startGameRun("race");
  });
});
