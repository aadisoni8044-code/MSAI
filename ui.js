// --- CONSTANTS AND CONFIGURATION ---
const BIOMES = ['forest', 'haunted', 'space', 'water', 'ancient'];
const BIOME_LEVELS_COUNT = 20; // 20 maps per biome = 100 maps total!

// Skin items definition
const VEHICLE_SKINS = [
    { id: 'classic', name: 'Classic Green', cost: 0, unlocked: true, color: '#00ff66', trailColor: '#00f3ff', particleColor: '#00ff66', trailType: 'wave' },
    { id: 'neon_pink', name: 'Hot Pink', cost: 150, unlocked: false, color: '#ff007f', trailColor: '#ffaa00', particleColor: '#ff007f', trailType: 'wave' },
    { id: 'cyber_cyan', name: 'Cyber Cyan', cost: 300, unlocked: false, color: '#00f3ff', trailColor: '#b026ff', particleColor: '#00f3ff', trailType: 'wave' },
    { id: 'deep_gold', name: 'Royal Gold', cost: 500, unlocked: false, color: '#ffaa00', trailColor: '#ffffff', particleColor: '#ffaa00', trailType: 'particles' },
    { id: 'cosmic_purple', name: 'Cosmo Purple', cost: 800, unlocked: false, color: '#b026ff', trailColor: '#ff007f', particleColor: '#b026ff', trailType: 'wave' },
    { id: 'dark_shadow', name: 'Dark Shadow', cost: 1200, unlocked: false, color: '#444444', trailColor: '#ff0000', particleColor: '#333333', trailType: 'shadow' },
    { id: 'obsidian_glowing', name: 'Nether Rune', cost: 2000, unlocked: false, color: '#ffaa00', trailColor: '#ff007f', particleColor: '#ff5500', trailType: 'rainbow' }
];

// --- STATE MANAGEMENT ---
const UI_STATE = {
    activeBiome: 'forest',
    activeShopTab: 'skins', // skins, trails, colors category filtering
    ploCoins: 0,
    streakDays: 0,
    lastLoginDate: '',
    username: 'Rider_01',
    country: 'USA',
    unlockedLevels: {}, // lvlNum: percentage completed
    equippedSkin: 'classic',
    ownedSkins: ['classic'],
    eloRating: 1000,
    totalCrashes: 0,
    totalPerfectRuns: 0
};

// LocalStorage Keys
const KEYS = {
    COINS: 'plo_coins_balance',
    STREAK: 'plo_login_streak',
    LAST_LOGIN: 'plo_last_login_date',
    USERNAME: 'plo_username',
    COUNTRY: 'plo_country',
    LEVELS: 'plo_classic_progress_v2', // separate v2 version with 100 maps support
    EQUIPPED_SKIN: 'plo_equipped_skin',
    OWNED_SKINS: 'plo_owned_skins',
    RATING: 'plo_skill_rating',
    CRASHES: 'plo_total_crashes',
    PERFECT_RUNS: 'plo_total_perfect_runs'
};

// Explicitly bind state containers to window scope to enable modular access (e.g. from google.js module)
window.UI_STATE = UI_STATE;
window.KEYS = KEYS;

// --- INITIALIZE SYSTEM ---
function initUI() {
    loadSavedState();
    checkDailyStreak();
    calculateAndSaveRating();
    renderHeaderWidgets();
    renderLevelSelector();
    renderShopSkins();
    renderProfileDetails();
}

/**
 * Backwards-compatibility wrapper for opening menu screen
 */
function openMainMenu() {
    if (window.setGameState) {
        window.setGameState('menu');
    }
}
window.openMainMenu = openMainMenu;

function loadSavedState() {
    try {
        UI_STATE.ploCoins = 0;
        UI_STATE.streakDays = 0;
        UI_STATE.lastLoginDate = '';
        UI_STATE.username = 'Rider_01';
        UI_STATE.country = 'USA';
        UI_STATE.equippedSkin = 'classic';
        UI_STATE.totalCrashes = 0;
        UI_STATE.totalPerfectRuns = 0;
        UI_STATE.ownedSkins = ['classic'];
        UI_STATE.unlockedLevels = { 1: 0 }; // level 1 starts with 0%
        UI_STATE.highScore = 0;
        UI_STATE.raceWins = 0;
    } catch (e) {
        console.error('Error loading game state: ', e);
    }
}

function saveStateItem(key, val) {
    if (window.isLoggedIn && typeof window.syncUIStateToCloud === 'function') {
        window.syncUIStateToCloud();
    }
}

// --- CONSECUTIVE DAILY LOGIN STREAK SYSTEM ---
function checkDailyStreak() {
    const todayStr = new Date().toDateString();

    if (UI_STATE.lastLoginDate === '') {
        // First login ever
        UI_STATE.streakDays = 1;
        UI_STATE.ploCoins += 50; // default Day 1 reward
        UI_STATE.lastLoginDate = todayStr;
        triggerStreakPopup(1, 50);
    } else {
        const lastDate = new Date(UI_STATE.lastLoginDate);
        const todayDate = new Date(todayStr);
        const diffTime = Math.abs(todayDate - lastDate);
        const diffDays = Math.floor(diffTime / (1000 * 60 * 60 * 24));

        if (diffDays === 1) {
            // Consecutive login reward
            UI_STATE.streakDays += 1;
            // Reward scaling: 50 * streakDays capped at +500 Coins
            const reward = Math.min(500, 50 * UI_STATE.streakDays);
            UI_STATE.ploCoins += reward;
            UI_STATE.lastLoginDate = todayStr;
            triggerStreakPopup(UI_STATE.streakDays, reward);
        } else if (diffDays > 1) {
            // Streak broken
            UI_STATE.streakDays = 1;
            UI_STATE.ploCoins += 50;
            UI_STATE.lastLoginDate = todayStr;
            triggerStreakPopup(1, 50);
        }
        // If diffDays === 0, same day, no action
    }

    saveStateItem(KEYS.COINS, UI_STATE.ploCoins);
    saveStateItem(KEYS.STREAK, UI_STATE.streakDays);
    saveStateItem(KEYS.LAST_LOGIN, UI_STATE.lastLoginDate);
}

function triggerStreakPopup(days, coinsWon) {
    // Dynamically show visual modal/toast highlighting the consecutive days rewards
    setTimeout(() => {
        const modal = document.getElementById('daily-rewards-modal');
        if (modal) {
            document.getElementById('reward-popup-streak').innerText = days;
            document.getElementById('reward-popup-coins').innerText = coinsWon;

            // Highlight claimed days
            for (let d = 1; d <= 5; d++) {
                const dayBox = document.getElementById(`reward-day-${d}`);
                if (dayBox) {
                    dayBox.classList.remove('claimed', 'active');
                    if (d < days) {
                        dayBox.classList.add('claimed');
                    } else if (d === days) {
                        dayBox.classList.add('active');
                    }
                }
            }
            modal.classList.add('active');
        }
    }, 800);
}

// --- PLAYER PROFILE & SKILL RATING (ELO) CALCULATION ---
function calculateAndSaveRating() {
    // ELO calculated based on:
    // Base 1000 + (levelsCompleted * 25) + perfectRuns * 40 - (crashes * 5)
    let completedCount = 0;
    let totalProgress = 0;

    Object.keys(UI_STATE.unlockedLevels).forEach(lvl => {
        const progress = UI_STATE.unlockedLevels[lvl];
        totalProgress += progress;
        if (progress >= 100) {
            completedCount++;
        }
    });

    const calculatedRating = Math.max(200, 1000 + (completedCount * 30) + (UI_STATE.totalPerfectRuns * 50) - (UI_STATE.totalCrashes * 4));
    UI_STATE.eloRating = Math.floor(calculatedRating);
    saveStateItem(KEYS.RATING, UI_STATE.eloRating);
}

function updateStatsOnCrash() {
    UI_STATE.totalCrashes++;
    saveStateItem(KEYS.CRASHES, UI_STATE.totalCrashes);
    calculateAndSaveRating();
    renderProfileDetails();
    renderHeaderWidgets();
}

function updateStatsOnWin(level, isPerfect) {
    // Update progress percentage
    const currentBest = UI_STATE.unlockedLevels[level] || 0;
    if (currentBest < 100) {
        UI_STATE.unlockedLevels[level] = 100;
        // Unlock next level automatically
        if (level < 100 && UI_STATE.unlockedLevels[level + 1] === undefined) {
            UI_STATE.unlockedLevels[level + 1] = 0;
        }
        saveStateItem(KEYS.LEVELS, UI_STATE.unlockedLevels);

        // Reward completed level with +100 Speedy Coins
        UI_STATE.ploCoins += 100;
        saveStateItem(KEYS.COINS, UI_STATE.ploCoins);
    }

    if (isPerfect) {
        UI_STATE.totalPerfectRuns++;
        saveStateItem(KEYS.PERFECT_RUNS, UI_STATE.totalPerfectRuns);
        // Bonus gold for flawless victory
        UI_STATE.ploCoins += 50;
        saveStateItem(KEYS.COINS, UI_STATE.ploCoins);
    }

    calculateAndSaveRating();
    renderHeaderWidgets();
    renderLevelSelector();
    renderProfileDetails();
}

// --- RENDERING VIEWS & SUBPANELS ---
function renderHeaderWidgets() {
    // Update mini profile widget
    const miniName = document.getElementById('header-username');
    if (miniName) miniName.innerText = UI_STATE.username;
    const miniRating = document.getElementById('header-rating');
    if (miniRating) miniRating.innerText = `RATING: ${UI_STATE.eloRating}`;
    const miniUID = document.getElementById('header-uid');
    if (miniUID) miniUID.innerText = `UID: ${UI_STATE.uid || '--------'}`;

    // Update global coin balances
    const coinWidgets = document.querySelectorAll('.plo-coins-val');
    coinWidgets.forEach(w => w.innerText = UI_STATE.ploCoins);

    // Update streak indicators
    const streakWidgets = document.querySelectorAll('.streak-days-val');
    streakWidgets.forEach(w => w.innerText = UI_STATE.streakDays);
}

function renderProfileDetails() {
    const pUsername = document.getElementById('profile-username-val');
    if (pUsername) pUsername.value = UI_STATE.username;

    const pCountry = document.getElementById('profile-country-val');
    if (pCountry) pCountry.value = UI_STATE.country;

    const pRating = document.getElementById('profile-rating-display');
    if (pRating) pRating.innerText = UI_STATE.eloRating;

    const pCrashes = document.getElementById('profile-crashes-display');
    if (pCrashes) pCrashes.innerText = UI_STATE.totalCrashes;

    const pPerfect = document.getElementById('profile-perfects-display');
    if (pPerfect) pPerfect.innerText = UI_STATE.totalPerfectRuns;

    // Calculate completed levels
    let completed = 0;
    Object.keys(UI_STATE.unlockedLevels).forEach(lvl => {
        if (UI_STATE.unlockedLevels[lvl] >= 100) completed++;
    });

    const pCompleted = document.getElementById('profile-completed-display');
    if (pCompleted) pCompleted.innerText = `${completed} / 100`;

    // Large profile UID Display
    const pUidDisplay = document.getElementById('profile-uid-display');
    if (pUidDisplay) pUidDisplay.innerText = `UID: ${UI_STATE.uid || '--------'}`;

    // Social & Profile Enhancements Rendering
    const pBio = document.getElementById('profile-bio-val');
    if (pBio) pBio.value = UI_STATE.bio || '';

    const pFollowers = document.getElementById('profile-followers-count');
    if (pFollowers) pFollowers.innerText = UI_STATE.followersCount || 0;

    const pFollowing = document.getElementById('profile-following-count');
    if (pFollowing) pFollowing.innerText = UI_STATE.followingCount || 0;

    const pYt = document.getElementById('profile-social-yt');
    if (pYt) pYt.value = UI_STATE.youtube || '';

    const pIg = document.getElementById('profile-social-ig');
    if (pIg) pIg.value = UI_STATE.instagram || '';

    const pTw = document.getElementById('profile-social-tw');
    if (pTw) pTw.value = UI_STATE.twitter || '';

    const pTwitch = document.getElementById('profile-social-twitch');
    if (pTwitch) pTwitch.value = UI_STATE.twitch || '';
}

// Paged Levels Selection across 5 thematic biomes
function selectBiome(biomeName) {
    if (!BIOMES.includes(biomeName)) return;
    UI_STATE.activeBiome = biomeName;

    // Update navigation active tabs CSS
    const tabs = document.querySelectorAll('.biome-tab');
    tabs.forEach(t => {
        t.classList.remove('active');
        if (t.dataset.biome === biomeName) {
            t.classList.add('active');
        }
    });

    renderLevelSelector();
}

function renderLevelSelector() {
    const grid = document.getElementById('level-grid-v2');
    if (!grid) return;
    grid.innerHTML = '';

    // Active Biome index ranges:
    // Forest: 1-20
    // Haunted: 21-40
    // Space: 41-60
    // Water: 61-80
    // Ancient: 81-100
    const biomeIndex = BIOMES.indexOf(UI_STATE.activeBiome);
    const startLvl = (biomeIndex * BIOME_LEVELS_COUNT) + 1;
    const endLvl = startLvl + BIOME_LEVELS_COUNT - 1;

    for (let l = startLvl; l <= endLvl; l++) {
        const progress = UI_STATE.unlockedLevels[l];
        const isLocked = progress === undefined;

        const box = document.createElement('div');
        box.className = `level-box ${isLocked ? 'locked' : ''}`;

        if (!isLocked) {
            box.onclick = () => launchClassicLevel(l);

            const num = document.createElement('div');
            num.className = 'level-num';
            num.innerText = l;
            box.appendChild(num);

            const percent = document.createElement('div');
            percent.className = 'level-percent';
            percent.innerText = `${progress}%`;
            box.appendChild(percent);
        } else {
            // Locked level layout with early unlock buy fee
            const num = document.createElement('div');
            num.className = 'level-num';
            num.innerText = l;
            box.appendChild(num);

            // Cost calculation: 100 Coins to force unlock early
            const cost = 100;
            const priceTag = document.createElement('div');
            priceTag.className = 'unlock-price-tag';
            priceTag.innerHTML = `🪙 ${cost}`;
            priceTag.onclick = (e) => {
                e.stopPropagation(); // don't click the level box
                buyUnlockLevel(l, cost);
            };
            box.appendChild(priceTag);

            // Lock Icon
            box.innerHTML += `
                <svg class="lock-icon" viewBox="0 0 24 24">
                    <path d="M12 2c-2.76 0-5 2.24-5 5v3H6c-1.1 0-2 .9-2 2v8c0 1.1.9 2 2 2h12c1.1 0 2-.9 2-2v-8c0-1.1-.9-2-2-2h-1V7c0-2.76-2.24-5-5-5zm-3 5c0-1.66 1.34-3 3-3s3 1.34 3 3v3H9V7zm3 10c-.55 0-1-.45-1-1v-2c0-.55.45-1 1-1s1 .45 1 1v2c0 .55-.45 1-1 1z"/>
                </svg>
            `;
        }

        grid.appendChild(box);
    }
}

function buyUnlockLevel(level, cost) {
    if (UI_STATE.ploCoins >= cost) {
        UI_STATE.ploCoins -= cost;
        UI_STATE.unlockedLevels[level] = 0;

        saveStateItem(KEYS.COINS, UI_STATE.ploCoins);
        saveStateItem(KEYS.LEVELS, UI_STATE.unlockedLevels);

        renderHeaderWidgets();
        renderLevelSelector();
        playBuySound();
    } else {
        alert("Not enough Speedy Coins to unlock this level! Keep racing.");
    }
}

// Category toggle handler inside the shop
function switchShopTab(tabName) {
    if (!['skins', 'trails', 'colors'].includes(tabName)) return;
    UI_STATE.activeShopTab = tabName;

    const tabs = document.querySelectorAll('.shop-tab');
    tabs.forEach(t => {
        t.classList.remove('active');
        if (t.dataset.tab === tabName) {
            t.classList.add('active');
        }
    });

    renderShopSkins();
}
window.switchShopTab = switchShopTab;

// --- DUAL-PANEL VEHICLE SKIN SHOP SYSTEM ---
function renderShopSkins() {
    const grid = document.getElementById('shop-skins-grid');
    if (!grid) return;
    grid.innerHTML = '';

    // Filter skins based on selected category:
    // skins: basic and custom classic shapes (classic, neon_pink, cyber_cyan)
    // trails: premium custom trail types (deep_gold, dark_shadow, obsidian_glowing)
    // colors: colorful premium hues (neon_pink, cyber_cyan, cosmic_purple, obsidian_glowing)
    const filteredSkins = VEHICLE_SKINS.filter(skin => {
        if (UI_STATE.activeShopTab === 'skins') {
            return ['classic', 'neon_pink', 'cyber_cyan'].includes(skin.id);
        } else if (UI_STATE.activeShopTab === 'trails') {
            return ['deep_gold', 'dark_shadow', 'obsidian_glowing'].includes(skin.id);
        } else if (UI_STATE.activeShopTab === 'colors') {
            return ['neon_pink', 'cyber_cyan', 'cosmic_purple', 'obsidian_glowing'].includes(skin.id);
        }
        return true;
    });

    filteredSkins.forEach(skin => {
        const isOwned = UI_STATE.ownedSkins.includes(skin.id);
        const isEquipped = UI_STATE.equippedSkin === skin.id;

        const card = document.createElement('div');
        card.className = `skin-card ${isEquipped ? 'selected' : ''} ${isOwned ? 'unlocked' : 'locked'}`;
        card.onclick = () => selectSkin(skin.id);

        // Neon glowing preview canvas
        const previewHolder = document.createElement('div');
        previewHolder.className = 'skin-preview-canvas-holder';

        const pvCanvas = document.createElement('canvas');
        pvCanvas.width = 120;
        pvCanvas.height = 40;
        drawSkinPreview(pvCanvas, skin);
        previewHolder.appendChild(pvCanvas);
        card.appendChild(previewHolder);

        const name = document.createElement('div');
        name.className = 'skin-name';
        name.innerText = skin.name;
        card.appendChild(name);

        const status = document.createElement('div');
        if (isEquipped) {
            status.className = 'skin-status equipped';
            status.innerText = 'EQUIPPED';
        } else if (isOwned) {
            status.className = 'skin-status unlocked';
            status.innerText = 'EQUIP';
        } else {
            status.className = 'skin-status locked';
            status.innerText = `BUY: 🪙${skin.cost}`;
        }
        card.appendChild(status);

        // Include lock icon visually for locked card items
        if (!isOwned) {
            const lockIcon = document.createElement('div');
            lockIcon.className = 'card-lock-icon';
            lockIcon.innerHTML = '🔒';
            card.appendChild(lockIcon);
        }

        grid.appendChild(card);
    });
}

function drawSkinPreview(canvas, skin) {
    const ctx = canvas.getContext('2d');
    ctx.clearRect(0, 0, canvas.width, canvas.height);

    // Draw glowing back circle
    const gradient = ctx.createRadialGradient(40, 20, 2, 40, 20, 18);
    gradient.addColorStop(0, skin.color);
    gradient.addColorStop(1, 'transparent');
    ctx.fillStyle = gradient;
    ctx.beginPath();
    ctx.arc(40, 20, 18, 0, Math.PI * 2);
    ctx.fill();

    // Draw triangle
    ctx.save();
    ctx.translate(40, 20);
    ctx.strokeStyle = '#ffffff';
    ctx.lineWidth = 2;
    ctx.fillStyle = skin.color;
    ctx.beginPath();
    ctx.moveTo(10, 0);
    ctx.lineTo(-10, -8);
    ctx.lineTo(-5, 0);
    ctx.lineTo(-10, 8);
    ctx.closePath();
    ctx.fill();
    ctx.stroke();
    ctx.restore();

    // Draw sample wave trail line
    ctx.strokeStyle = skin.trailColor;
    ctx.lineWidth = 3;
    ctx.beginPath();
    ctx.moveTo(48, 20);
    for (let x = 48; x < 110; x += 4) {
        const y = 20 + Math.sin((x - 48) * 0.15) * 8;
        ctx.lineTo(x, y);
    }
    ctx.stroke();
}

function selectSkin(skinId) {
    const skin = VEHICLE_SKINS.find(s => s.id === skinId);
    if (!skin) return;

    const isOwned = UI_STATE.ownedSkins.includes(skinId);

    if (isOwned) {
        UI_STATE.equippedSkin = skinId;
        saveStateItem(KEYS.EQUIPPED_SKIN, skinId);
        playBuySound();
    } else {
        // Prompt purchase
        if (UI_STATE.ploCoins >= skin.cost) {
            UI_STATE.ploCoins -= skin.cost;
            UI_STATE.ownedSkins.push(skinId);
            UI_STATE.equippedSkin = skinId;

            saveStateItem(KEYS.COINS, UI_STATE.ploCoins);
            saveStateItem(KEYS.OWNED_SKINS, UI_STATE.ownedSkins);
            saveStateItem(KEYS.EQUIPPED_SKIN, skinId);

            playBuySound();
        } else {
            alert("Insufficient Speedy Coins! Keep playing to earn more.");
        }
    }

    renderHeaderWidgets();
    renderShopSkins();
}

// Helper to grab currently equipped skin profile info for the physics renderer
function getActiveSkinDetails() {
    return VEHICLE_SKINS.find(s => s.id === UI_STATE.equippedSkin) || VEHICLE_SKINS[0];
}

// --- PROFILE EDITORS ---
function updateProfileUsername(newName) {
    if (newName.trim() === '') return;
    UI_STATE.username = newName.trim();
    saveStateItem(KEYS.USERNAME, UI_STATE.username);
    renderHeaderWidgets();
}

function updateProfileCountry(newCountry) {
    if (newCountry.trim() === '') return;
    UI_STATE.country = newCountry.trim();
    saveStateItem(KEYS.COUNTRY, UI_STATE.country);
    renderHeaderWidgets();
}

// --- SOUND TRIGGER WRAPPERS FOR USER ACTIONS ---
function playBuySound() {
    if (typeof playCheckpointSound === 'function') {
        playCheckpointSound();
    }
}

// --- PWA & FULLSCREEN API ARCHITECTURE ---
let deferredPrompt = null;

window.addEventListener('beforeinstallprompt', (e) => {
    // Prevent the mini-infobar from appearing on mobile
    e.preventDefault();
    // Stash the event so it can be triggered later
    deferredPrompt = e;
    // Show the install button in the toolbar
    const installBtn = document.getElementById('pwa-install-btn');
    if (installBtn) {
        installBtn.style.display = 'inline-flex';
    }
});

document.addEventListener('DOMContentLoaded', () => {
    const installBtn = document.getElementById('pwa-install-btn');
    if (installBtn) {
        installBtn.addEventListener('click', async () => {
            if (!deferredPrompt) return;
            // Show the install prompt
            deferredPrompt.prompt();
            // Wait for the user to respond to the prompt
            const { outcome } = await deferredPrompt.userChoice;
            console.log(`User response to install prompt: ${outcome}`);
            // We've used the prompt, and can't use it again, discard it
            deferredPrompt = null;
            // Hide the install button
            installBtn.style.display = 'none';
        });
    }
});

function requestMandatoryFullscreen() {
    const docEl = document.documentElement;
    const requestFS = docEl.requestFullscreen || docEl.webkitRequestFullscreen || docEl.mozRequestFullScreen || docEl.msRequestFullscreen;
    if (requestFS) {
        requestFS.call(docEl)
            .catch((err) => {
                console.error(`Error attempting to enable fullscreen: ${err.message}`);
            });
    }
}

// Synchronize fullscreen state with the mandatory prompt overlay
document.addEventListener('fullscreenchange', handleFullscreenChange);
document.addEventListener('webkitfullscreenchange', handleFullscreenChange);
document.addEventListener('mozfullscreenchange', handleFullscreenChange);
document.addEventListener('MSFullscreenChange', handleFullscreenChange);

function handleFullscreenChange() {
    const isFullscreen = !!(document.fullscreenElement || document.webkitFullscreenElement || document.mozFullScreenElement || document.msFullscreenElement);
    const modal = document.getElementById('fullscreen-prompt-modal');
    if (modal) {
        if (isFullscreen) {
            modal.classList.remove('active');
            // Resume/Initialize sound context on success
            initAudioContext();
        } else {
            modal.classList.add('active');
            // If game is playing, pause it automatically
            if (typeof currentGameState !== 'undefined' && currentGameState === 'playing') {
                pauseGame();
            }
        }
    }
}

/**
 * Global Multi-Screen Navigation system SPA coordinator function.
 * Displays target screen while smoothly hiding any other views without page loads/tab opens.
 */
function showScreen(screenId) {
    // Hide all modal overlays just in case
    document.querySelectorAll('.modal-overlay').forEach(m => m.classList.remove('active'));

    const allScreens = document.querySelectorAll('.screen');
    allScreens.forEach(scr => {
        if (scr.id === screenId) {
            scr.classList.remove('hidden');
        } else {
            scr.classList.add('hidden');
        }
    });

    // Check if showing HUD
    const hud = document.getElementById('hud');
    if (screenId === 'hud-overlay') {
        if (hud) hud.classList.add('active');
    } else {
        if (hud) hud.classList.remove('active');
    }
}
window.showScreen = showScreen;

/**
 * Navigate to Profile full-screen SPA View
 */
function navigateToProfileScreen() {
    if (window.isLoggedIn) {
        showScreen('profile-screen');
    } else {
        const aModal = document.getElementById('auth-modal');
        if (aModal) aModal.classList.add('active');
    }
}
window.navigateToProfileScreen = navigateToProfileScreen;

/**
 * Navigate to Search full-screen SPA View
 */
function navigateToSearchScreen() {
    if (window.isLoggedIn) {
        // Reset previous search results and values for cleanliness
        const results = document.getElementById('social-search-results');
        if (results) {
            results.innerHTML = `<div style="color: #a4c4c1; font-size: 14px;">Enter an 8-digit Player ID above to search...</div>`;
        }
        const sInput = document.getElementById('social-search-input');
        if (sInput) sInput.value = '';

        showScreen('search-screen');
    } else {
        const aModal = document.getElementById('auth-modal');
        if (aModal) aModal.classList.add('active');
    }
}
window.navigateToSearchScreen = navigateToSearchScreen;

/**
 * Navigate to Shop full-screen SPA View
 */
function navigateToShopScreen() {
    showScreen('shop-screen');
}
window.navigateToShopScreen = navigateToShopScreen;
