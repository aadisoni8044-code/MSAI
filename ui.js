/**
 * Speedy Arrow - UI State & Progression Manager
 * Fully handles local storage persistence, 100 levels across 5 biomes,
 * skin shop with live previews, ELO ratings, and screen routing.
 */

// Biome Definitions (20 levels per biome = 100 levels total)
const BIOMES = ['forest', 'haunted', 'space', 'water', 'ancient'];
const BIOME_LEVELS_COUNT = 20;

// Vehicle Skins Definition
const VEHICLE_SKINS = [
    { id: 'classic', name: 'Classic Green', cost: 0, unlocked: true, color: '#00ff66', trailColor: '#00f3ff', particleColor: '#00ff66', trailType: 'wave', category: 'skins' },
    { id: 'neon_pink', name: 'Cyber Pink', cost: 100, unlocked: false, color: '#ff007f', trailColor: '#ffaa00', particleColor: '#ff007f', trailType: 'wave', category: 'skins' },
    { id: 'cyber_cyan', name: 'Hyper Cyan', cost: 250, unlocked: false, color: '#00f3ff', trailColor: '#b026ff', particleColor: '#00f3ff', trailType: 'wave', category: 'skins' },
    { id: 'deep_gold', name: 'Royal Gold', cost: 450, unlocked: false, color: '#ffaa00', trailColor: '#ffffff', particleColor: '#ffaa00', trailType: 'particles', category: 'trails' },
    { id: 'cosmic_purple', name: 'Nebula Purple', cost: 700, unlocked: false, color: '#b026ff', trailColor: '#ff007f', particleColor: '#b026ff', trailType: 'wave', category: 'colors' },
    { id: 'dark_shadow', name: 'Stealth Phantom', cost: 1000, unlocked: false, color: '#555555', trailColor: '#ff2222', particleColor: '#333333', trailType: 'shadow', category: 'trails' },
    { id: 'obsidian_glowing', name: 'Solar Flare', cost: 1400, unlocked: false, color: '#ff5500', trailColor: '#ffdd00', particleColor: '#ff3300', trailType: 'rainbow', category: 'colors' },
    { id: 'aurora_borealis', name: 'Aurora Prism', cost: 2000, unlocked: false, color: '#00ffcc', trailColor: '#ff00cc', particleColor: '#00ffff', trailType: 'rainbow', category: 'trails' }
];

// LocalStorage Keys
const STORAGE_PREFIX = 'speedy_arrow_';
const KEYS = {
    COINS: STORAGE_PREFIX + 'coins',
    STREAK: STORAGE_PREFIX + 'streak',
    LAST_LOGIN: STORAGE_PREFIX + 'last_login',
    USERNAME: STORAGE_PREFIX + 'username',
    COUNTRY: STORAGE_PREFIX + 'country',
    LEVELS: STORAGE_PREFIX + 'levels_v2',
    EQUIPPED_SKIN: STORAGE_PREFIX + 'equipped_skin',
    OWNED_SKINS: STORAGE_PREFIX + 'owned_skins',
    RATING: STORAGE_PREFIX + 'elo_rating',
    CRASHES: STORAGE_PREFIX + 'total_crashes',
    PERFECT_RUNS: STORAGE_PREFIX + 'perfect_runs',
    HIGH_SCORE: STORAGE_PREFIX + 'high_score',
    RACE_WINS: STORAGE_PREFIX + 'race_wins',
    BIO: STORAGE_PREFIX + 'bio',
    PHOTO_URL: STORAGE_PREFIX + 'photo_url',
    UID: STORAGE_PREFIX + 'uid'
};

// UI State Object
const UI_STATE = {
    activeBiome: 'forest',
    activeShopTab: 'skins',
    ploCoins: 50,
    streakDays: 1,
    lastLoginDate: '',
    username: 'Rider_01',
    country: 'USA',
    uid: '',
    bio: 'Geometry wave speed runner.',
    photoURL: null,
    unlockedLevels: { 1: 0 },
    equippedSkin: 'classic',
    ownedSkins: ['classic'],
    eloRating: 1000,
    totalCrashes: 0,
    totalPerfectRuns: 0,
    highScore: 0,
    raceWins: 0,
    followersCount: 0,
    followingCount: 0,
    youtube: '',
    instagram: '',
    twitter: '',
    twitch: ''
};

window.UI_STATE = UI_STATE;
window.KEYS = KEYS;
window.VEHICLE_SKINS = VEHICLE_SKINS;

// Initialize UI system on page load
function initUI() {
    loadLocalState();
    checkDailyStreak();
    calculateAndSaveRating();
    renderHeaderWidgets();
    renderLevelSelector();
    renderShopSkins();
    renderProfileDetails();
}
window.initUI = initUI;

// --- PERSISTENCE (LOCAL STORAGE & CLOUD SYNC) ---
function loadLocalState() {
    try {
        const savedCoins = localStorage.getItem(KEYS.COINS);
        if (savedCoins !== null) UI_STATE.ploCoins = parseInt(savedCoins, 10) || 0;

        const savedStreak = localStorage.getItem(KEYS.STREAK);
        if (savedStreak !== null) UI_STATE.streakDays = parseInt(savedStreak, 10) || 1;

        const savedLastLogin = localStorage.getItem(KEYS.LAST_LOGIN);
        if (savedLastLogin) UI_STATE.lastLoginDate = savedLastLogin;

        const savedUsername = localStorage.getItem(KEYS.USERNAME);
        if (savedUsername) UI_STATE.username = savedUsername;

        const savedCountry = localStorage.getItem(KEYS.COUNTRY);
        if (savedCountry) UI_STATE.country = savedCountry;

        const savedBio = localStorage.getItem(KEYS.BIO);
        if (savedBio) UI_STATE.bio = savedBio;

        const savedPhoto = localStorage.getItem(KEYS.PHOTO_URL);
        if (savedPhoto) UI_STATE.photoURL = savedPhoto;

        const savedUid = localStorage.getItem(KEYS.UID);
        if (savedUid) {
            UI_STATE.uid = savedUid;
        } else {
            UI_STATE.uid = Math.floor(10000000 + Math.random() * 90000000).toString();
            localStorage.setItem(KEYS.UID, UI_STATE.uid);
        }

        const savedLevels = localStorage.getItem(KEYS.LEVELS);
        if (savedLevels) {
            try {
                UI_STATE.unlockedLevels = JSON.parse(savedLevels);
            } catch (e) {
                UI_STATE.unlockedLevels = { 1: 0 };
            }
        } else {
            UI_STATE.unlockedLevels = { 1: 0 };
        }

        const savedEquipped = localStorage.getItem(KEYS.EQUIPPED_SKIN);
        if (savedEquipped && VEHICLE_SKINS.some(s => s.id === savedEquipped)) {
            UI_STATE.equippedSkin = savedEquipped;
        }

        const savedOwned = localStorage.getItem(KEYS.OWNED_SKINS);
        if (savedOwned) {
            try {
                UI_STATE.ownedSkins = JSON.parse(savedOwned);
                if (!UI_STATE.ownedSkins.includes('classic')) UI_STATE.ownedSkins.push('classic');
            } catch (e) {
                UI_STATE.ownedSkins = ['classic'];
            }
        }

        const savedCrashes = localStorage.getItem(KEYS.CRASHES);
        if (savedCrashes !== null) UI_STATE.totalCrashes = parseInt(savedCrashes, 10) || 0;

        const savedPerfect = localStorage.getItem(KEYS.PERFECT_RUNS);
        if (savedPerfect !== null) UI_STATE.totalPerfectRuns = parseInt(savedPerfect, 10) || 0;

        const savedHighScore = localStorage.getItem(KEYS.HIGH_SCORE);
        if (savedHighScore !== null) UI_STATE.highScore = parseInt(savedHighScore, 10) || 0;

        const savedRaceWins = localStorage.getItem(KEYS.RACE_WINS);
        if (savedRaceWins !== null) UI_STATE.raceWins = parseInt(savedRaceWins, 10) || 0;

    } catch (err) {
        console.warn('LocalStorage error on load:', err);
    }
}

function saveStateItem(key, val) {
    try {
        if (typeof val === 'object') {
            localStorage.setItem(key, JSON.stringify(val));
        } else {
            localStorage.setItem(key, String(val));
        }
    } catch (e) {
        console.warn('LocalStorage save error:', e);
    }

    if (window.isLoggedIn && typeof window.syncUIStateToCloud === 'function') {
        window.syncUIStateToCloud();
    }
}
window.saveStateItem = saveStateItem;

// --- DAILY LOGIN STREAK SYSTEM ---
function checkDailyStreak() {
    const todayStr = new Date().toDateString();

    if (!UI_STATE.lastLoginDate) {
        UI_STATE.streakDays = 1;
        UI_STATE.ploCoins += 50;
        UI_STATE.lastLoginDate = todayStr;
        saveStateItem(KEYS.COINS, UI_STATE.ploCoins);
        saveStateItem(KEYS.STREAK, UI_STATE.streakDays);
        saveStateItem(KEYS.LAST_LOGIN, UI_STATE.lastLoginDate);
        triggerStreakPopup(1, 50);
    } else {
        const lastDate = new Date(UI_STATE.lastLoginDate);
        const todayDate = new Date(todayStr);
        const diffTime = todayDate.getTime() - lastDate.getTime();
        const diffDays = Math.floor(diffTime / (1000 * 60 * 60 * 24));

        if (diffDays === 1) {
            UI_STATE.streakDays += 1;
            const reward = Math.min(500, 50 * UI_STATE.streakDays);
            UI_STATE.ploCoins += reward;
            UI_STATE.lastLoginDate = todayStr;
            saveStateItem(KEYS.COINS, UI_STATE.ploCoins);
            saveStateItem(KEYS.STREAK, UI_STATE.streakDays);
            saveStateItem(KEYS.LAST_LOGIN, UI_STATE.lastLoginDate);
            triggerStreakPopup(UI_STATE.streakDays, reward);
        } else if (diffDays > 1) {
            UI_STATE.streakDays = 1;
            UI_STATE.ploCoins += 50;
            UI_STATE.lastLoginDate = todayStr;
            saveStateItem(KEYS.COINS, UI_STATE.ploCoins);
            saveStateItem(KEYS.STREAK, UI_STATE.streakDays);
            saveStateItem(KEYS.LAST_LOGIN, UI_STATE.lastLoginDate);
            triggerStreakPopup(1, 50);
        }
    }
}

function triggerStreakPopup(days, coinsWon) {
    setTimeout(() => {
        const modal = document.getElementById('daily-rewards-modal');
        if (modal) {
            const streakEl = document.getElementById('reward-popup-streak');
            const coinsEl = document.getElementById('reward-popup-coins');
            if (streakEl) streakEl.innerText = days;
            if (coinsEl) coinsEl.innerText = coinsWon;

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
    }, 600);
}

// --- ELO SKILL RATING SYSTEM ---
function calculateAndSaveRating() {
    let completedCount = 0;
    Object.keys(UI_STATE.unlockedLevels).forEach(lvl => {
        if (UI_STATE.unlockedLevels[lvl] >= 100) completedCount++;
    });

    const calculatedRating = Math.max(
        200,
        1000 + (completedCount * 25) + (UI_STATE.totalPerfectRuns * 40) + (UI_STATE.raceWins * 30) - (UI_STATE.totalCrashes * 3)
    );
    UI_STATE.eloRating = Math.floor(calculatedRating);
    saveStateItem(KEYS.RATING, UI_STATE.eloRating);
}
window.calculateAndSaveRating = calculateAndSaveRating;

function updateStatsOnCrash() {
    UI_STATE.totalCrashes++;
    saveStateItem(KEYS.CRASHES, UI_STATE.totalCrashes);
    calculateAndSaveRating();
    renderProfileDetails();
    renderHeaderWidgets();
}
window.updateStatsOnCrash = updateStatsOnCrash;

function updateStatsOnWin(level, isPerfect) {
    const currentBest = UI_STATE.unlockedLevels[level] || 0;
    if (currentBest < 100) {
        UI_STATE.unlockedLevels[level] = 100;
        if (level < 100 && UI_STATE.unlockedLevels[level + 1] === undefined) {
            UI_STATE.unlockedLevels[level + 1] = 0;
        }
        saveStateItem(KEYS.LEVELS, UI_STATE.unlockedLevels);
        UI_STATE.ploCoins += 100;
        saveStateItem(KEYS.COINS, UI_STATE.ploCoins);
    }

    if (isPerfect) {
        UI_STATE.totalPerfectRuns++;
        saveStateItem(KEYS.PERFECT_RUNS, UI_STATE.totalPerfectRuns);
        UI_STATE.ploCoins += 50;
        saveStateItem(KEYS.COINS, UI_STATE.ploCoins);
    }

    calculateAndSaveRating();
    renderHeaderWidgets();
    renderLevelSelector();
    renderProfileDetails();
}
window.updateStatsOnWin = updateStatsOnWin;

// --- HEADER & PROFILE RENDERING ---
function renderHeaderWidgets() {
    const miniName = document.getElementById('header-username');
    if (miniName) miniName.innerText = UI_STATE.username;

    const miniRating = document.getElementById('header-rating');
    if (miniRating) miniRating.innerText = `RATING: ${UI_STATE.eloRating}`;

    const miniUID = document.getElementById('header-uid');
    if (miniUID) miniUID.innerText = `UID: ${UI_STATE.uid || '--------'}`;

    const coinWidgets = document.querySelectorAll('.plo-coins-val');
    coinWidgets.forEach(w => w.innerText = UI_STATE.ploCoins);

    const streakWidgets = document.querySelectorAll('.streak-days-val');
    streakWidgets.forEach(w => w.innerText = UI_STATE.streakDays);

    updateUIAvatars(UI_STATE.photoURL);
}
window.renderHeaderWidgets = renderHeaderWidgets;

function updateUIAvatars(photoURL) {
    const avatarMini = document.querySelector('.profile-avatar');
    if (avatarMini) {
        if (photoURL) {
            avatarMini.innerHTML = `<img src="${photoURL}" style="width: 100%; height: 100%; border-radius: 50%; object-fit: cover;" alt="Avatar">`;
        } else {
            avatarMini.innerHTML = '👤';
        }
    }
    const avatarLarge = document.querySelector('.profile-avatar-large');
    if (avatarLarge) {
        if (photoURL) {
            avatarLarge.innerHTML = `<img src="${photoURL}" style="width: 100%; height: 100%; border-radius: 50%; object-fit: cover;" alt="Avatar">`;
        } else {
            avatarLarge.innerHTML = '👤';
        }
    }
}
window.updateUIAvatars = updateUIAvatars;

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

    let completed = 0;
    Object.keys(UI_STATE.unlockedLevels).forEach(lvl => {
        if (UI_STATE.unlockedLevels[lvl] >= 100) completed++;
    });

    const pCompleted = document.getElementById('profile-completed-display');
    if (pCompleted) pCompleted.innerText = `${completed} / 100`;

    const pUidDisplay = document.getElementById('profile-uid-display');
    if (pUidDisplay) pUidDisplay.innerText = `UID: ${UI_STATE.uid || '--------'}`;

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
window.renderProfileDetails = renderProfileDetails;

// --- BIOME & LEVEL SELECTOR ---
function selectBiome(biomeName) {
    if (!BIOMES.includes(biomeName)) return;
    UI_STATE.activeBiome = biomeName;

    const tabs = document.querySelectorAll('.biome-tab');
    tabs.forEach(t => {
        t.classList.remove('active');
        if (t.dataset.biome === biomeName) {
            t.classList.add('active');
        }
    });

    renderLevelSelector();
}
window.selectBiome = selectBiome;

function renderLevelSelector() {
    const grid = document.getElementById('level-grid-v2');
    if (!grid) return;
    grid.innerHTML = '';

    const biomeIndex = BIOMES.indexOf(UI_STATE.activeBiome);
    const startLvl = (biomeIndex * BIOME_LEVELS_COUNT) + 1;
    const endLvl = startLvl + BIOME_LEVELS_COUNT - 1;

    for (let l = startLvl; l <= endLvl; l++) {
        const progress = UI_STATE.unlockedLevels[l];
        const isLocked = progress === undefined;

        const box = document.createElement('div');
        box.className = `level-box ${isLocked ? 'locked' : ''}`;

        if (!isLocked) {
            box.onclick = () => {
                if (typeof window.launchClassicLevel === 'function') {
                    window.launchClassicLevel(l);
                }
            };

            const num = document.createElement('div');
            num.className = 'level-num';
            num.innerText = l;
            box.appendChild(num);

            const percent = document.createElement('div');
            percent.className = 'level-percent';
            percent.innerText = `${progress}%`;
            box.appendChild(percent);
        } else {
            const num = document.createElement('div');
            num.className = 'level-num';
            num.innerText = l;
            box.appendChild(num);

            const cost = 100;
            const priceTag = document.createElement('div');
            priceTag.className = 'unlock-price-tag';
            priceTag.innerHTML = `🪙 ${cost}`;
            priceTag.onclick = (e) => {
                e.stopPropagation();
                buyUnlockLevel(l, cost);
            };
            box.appendChild(priceTag);

            box.innerHTML += `
                <svg class="lock-icon" viewBox="0 0 24 24">
                    <path d="M12 2c-2.76 0-5 2.24-5 5v3H6c-1.1 0-2 .9-2 2v8c0 1.1.9 2 2 2h12c1.1 0 2-.9 2-2v-8c0-1.1-.9-2-2-2h-1V7c0-2.76-2.24-5-5-5zm-3 5c0-1.66 1.34-3 3-3s3 1.34 3 3v3H9V7zm3 10c-.55 0-1-.45-1-1v-2c0-.55.45-1 1-1s1 .45 1 1v2c0 .55-.45 1-1 1z"/>
                </svg>
            `;
        }

        grid.appendChild(box);
    }
}
window.renderLevelSelector = renderLevelSelector;

function buyUnlockLevel(level, cost) {
    if (UI_STATE.ploCoins >= cost) {
        UI_STATE.ploCoins -= cost;
        UI_STATE.unlockedLevels[level] = 0;

        saveStateItem(KEYS.COINS, UI_STATE.ploCoins);
        saveStateItem(KEYS.LEVELS, UI_STATE.unlockedLevels);

        renderHeaderWidgets();
        renderLevelSelector();
        if (typeof window.showToast === 'function') {
            window.showToast(`Level ${level} unlocked!`, 'success');
        }
        if (typeof window.playCheckpointSound === 'function') {
            window.playCheckpointSound();
        }
    } else {
        if (typeof window.showToast === 'function') {
            window.showToast('Not enough Speedy Coins! Keep racing to earn more.', 'error');
        }
    }
}
window.buyUnlockLevel = buyUnlockLevel;

// --- SKIN SHOP SYSTEM ---
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

function renderShopSkins() {
    const grid = document.getElementById('shop-skins-grid');
    if (!grid) return;
    grid.innerHTML = '';

    const filteredSkins = VEHICLE_SKINS.filter(skin => {
        if (UI_STATE.activeShopTab === 'skins') {
            return skin.category === 'skins' || skin.id === 'classic';
        } else if (UI_STATE.activeShopTab === 'trails') {
            return skin.category === 'trails' || skin.trailType !== 'wave';
        } else if (UI_STATE.activeShopTab === 'colors') {
            return skin.category === 'colors' || ['neon_pink', 'cyber_cyan', 'cosmic_purple', 'obsidian_glowing'].includes(skin.id);
        }
        return true;
    });

    filteredSkins.forEach(skin => {
        const isOwned = UI_STATE.ownedSkins.includes(skin.id);
        const isEquipped = UI_STATE.equippedSkin === skin.id;

        const card = document.createElement('div');
        card.className = `skin-card ${isEquipped ? 'selected' : ''} ${isOwned ? 'unlocked' : 'locked'}`;
        card.onclick = () => selectSkin(skin.id);

        const previewHolder = document.createElement('div');
        previewHolder.className = 'skin-preview-canvas-holder';

        const pvCanvas = document.createElement('canvas');
        pvCanvas.width = 120;
        pvCanvas.height = 44;
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

        if (!isOwned) {
            const lockIcon = document.createElement('div');
            lockIcon.className = 'card-lock-icon';
            lockIcon.innerHTML = '🔒';
            card.appendChild(lockIcon);
        }

        grid.appendChild(card);
    });
}
window.renderShopSkins = renderShopSkins;

function drawSkinPreview(canvas, skin) {
    const ctx = canvas.getContext('2d');
    ctx.clearRect(0, 0, canvas.width, canvas.height);

    const gradient = ctx.createRadialGradient(36, 22, 2, 36, 22, 16);
    gradient.addColorStop(0, skin.color);
    gradient.addColorStop(1, 'transparent');
    ctx.fillStyle = gradient;
    ctx.beginPath();
    ctx.arc(36, 22, 16, 0, Math.PI * 2);
    ctx.fill();

    ctx.save();
    ctx.translate(36, 22);
    ctx.strokeStyle = '#ffffff';
    ctx.lineWidth = 1.8;
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

    ctx.strokeStyle = skin.trailColor;
    ctx.lineWidth = 2.5;
    ctx.beginPath();
    ctx.moveTo(48, 22);
    for (let x = 48; x < 110; x += 4) {
        const y = 22 + Math.sin((x - 48) * 0.18) * 7;
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
        if (typeof window.showToast === 'function') {
            window.showToast(`${skin.name} equipped!`, 'success');
        }
        if (typeof window.playCheckpointSound === 'function') {
            window.playCheckpointSound();
        }
    } else {
        if (UI_STATE.ploCoins >= skin.cost) {
            UI_STATE.ploCoins -= skin.cost;
            UI_STATE.ownedSkins.push(skinId);
            UI_STATE.equippedSkin = skinId;

            saveStateItem(KEYS.COINS, UI_STATE.ploCoins);
            saveStateItem(KEYS.OWNED_SKINS, UI_STATE.ownedSkins);
            saveStateItem(KEYS.EQUIPPED_SKIN, skinId);

            if (typeof window.showToast === 'function') {
                window.showToast(`${skin.name} purchased & equipped!`, 'success');
            }
            if (typeof window.playCheckpointSound === 'function') {
                window.playCheckpointSound();
            }
        } else {
            if (typeof window.showToast === 'function') {
                window.showToast('Insufficient Speedy Coins! Keep racing to earn more.', 'error');
            }
        }
    }

    renderHeaderWidgets();
    renderShopSkins();
}
window.selectSkin = selectSkin;

function getActiveSkinDetails() {
    return VEHICLE_SKINS.find(s => s.id === UI_STATE.equippedSkin) || VEHICLE_SKINS[0];
}
window.getActiveSkinDetails = getActiveSkinDetails;

// --- PROFILE EDITORS ---
function updateProfileUsername(newName) {
    if (!newName || newName.trim() === '') return;
    UI_STATE.username = newName.trim().slice(0, 16);
    saveStateItem(KEYS.USERNAME, UI_STATE.username);
    renderHeaderWidgets();
    if (typeof window.showToast === 'function') {
        window.showToast('Username updated!', 'success');
    }
}
window.updateProfileUsername = updateProfileUsername;

function updateProfileCountry(newCountry) {
    if (!newCountry || newCountry.trim() === '') return;
    UI_STATE.country = newCountry.trim();
    saveStateItem(KEYS.COUNTRY, UI_STATE.country);
    renderHeaderWidgets();
}
window.updateProfileCountry = updateProfileCountry;

// --- SPA SCREEN NAVIGATION ---
function showScreen(screenId) {
    document.querySelectorAll('.modal-overlay').forEach(m => m.classList.remove('active'));

    const allScreens = document.querySelectorAll('.screen');
    allScreens.forEach(scr => {
        if (scr.id === screenId) {
            scr.classList.remove('hidden');
        } else {
            scr.classList.add('hidden');
        }
    });

    const hud = document.getElementById('hud');
    if (hud) hud.classList.remove('active');
}
window.showScreen = showScreen;

function openMainMenu() {
    if (typeof window.setGameState === 'function') {
        window.setGameState('menu');
    } else {
        showScreen('main-menu-screen');
    }
}
window.openMainMenu = openMainMenu;

function openGameModes() {
    showScreen('game-modes-screen');
}
window.openGameModes = openGameModes;

function openLevelSelect() {
    if (typeof window.setGameState === 'function') {
        window.setGameState('level_select');
    } else {
        showScreen('level-select-screen');
    }
}
window.openLevelSelect = openLevelSelect;

function navigateToProfileScreen() {
    showScreen('profile-screen');
}
window.navigateToProfileScreen = navigateToProfileScreen;

function navigateToShopScreen() {
    showScreen('shop-screen');
}
window.navigateToShopScreen = navigateToShopScreen;

function navigateToSearchScreen() {
    showScreen('search-screen');
}
window.navigateToSearchScreen = navigateToSearchScreen;

function navigateToLeaderboardScreen() {
    showScreen('search-screen');
}
window.navigateToLeaderboardScreen = navigateToLeaderboardScreen;
