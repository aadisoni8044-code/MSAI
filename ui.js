// --- CONSTANTS AND CONFIGURATION ---
const BIOMES = ['forest', 'haunted', 'space', 'water', 'ancient'];
const BIOME_LEVELS_COUNT = 20; // 20 maps per biome = 100 maps total!

// Data-driven Playable Shape Collection
const SHAPES = [
    { id: 'arrow', name: 'Arrow', price: 0, rarity: 'Common', category: 'shapes', collisionType: 'triangle', unlocked: true, defaultSkin: 'classic', skins: ['classic', 'neon_pink', 'cyber_cyan', 'deep_gold', 'cosmic_purple'] },
    { id: 'triangle', name: 'Triangle', price: 250, rarity: 'Common', category: 'shapes', collisionType: 'triangle', unlocked: false, defaultSkin: 'classic', skins: ['classic', 'neon_pink', 'cyber_cyan'] },
    { id: 'circle', name: 'Circle', price: 500, rarity: 'Common', category: 'shapes', collisionType: 'circle', unlocked: false, defaultSkin: 'classic', skins: ['classic', 'neon_pink', 'cyber_cyan', 'deep_gold', 'plasma_blue'] },
    { id: 'square', name: 'Square', price: 650, rarity: 'Common', category: 'shapes', collisionType: 'box', unlocked: false, defaultSkin: 'classic', skins: ['classic', 'cyber_cyan', 'deep_gold'] },
    { id: 'rounded_square', name: 'Rounded Square', price: 800, rarity: 'Uncommon', category: 'shapes', collisionType: 'box', unlocked: false, defaultSkin: 'classic', skins: ['classic', 'neon_pink', 'plasma_blue'] },
    { id: 'rectangle', name: 'Rectangle', price: 850, rarity: 'Uncommon', category: 'shapes', collisionType: 'box', unlocked: false, defaultSkin: 'classic', skins: ['classic', 'emerald_flare'] },
    { id: 'diamond', name: 'Diamond', price: 1000, rarity: 'Uncommon', category: 'shapes', collisionType: 'polygon', unlocked: false, defaultSkin: 'classic', skins: ['classic', 'deep_gold', 'obsidian_glowing'] },
    { id: 'pentagon', name: 'Pentagon', price: 1200, rarity: 'Uncommon', category: 'shapes', collisionType: 'polygon', unlocked: false, defaultSkin: 'classic', skins: ['classic', 'cosmic_purple'] },
    { id: 'hexagon', name: 'Hexagon', price: 1500, rarity: 'Rare', category: 'rare', collisionType: 'polygon', unlocked: false, defaultSkin: 'classic', skins: ['classic', 'cyber_cyan', 'plasma_blue'] },
    { id: 'octagon', name: 'Octagon', price: 1800, rarity: 'Rare', category: 'rare', collisionType: 'polygon', unlocked: false, defaultSkin: 'classic', skins: ['classic', 'dark_shadow'] },
    { id: 'star', name: 'Star', price: 2000, rarity: 'Rare', category: 'rare', collisionType: 'star', unlocked: false, defaultSkin: 'classic', skins: ['classic', 'deep_gold', 'emerald_flare'] },
    { id: 'plus_cross', name: 'Plus / Cross', price: 2500, rarity: 'Rare', category: 'rare', collisionType: 'cross', unlocked: false, defaultSkin: 'classic', skins: ['classic', 'neon_pink'] },
    { id: 'ring', name: 'Ring', price: 3000, rarity: 'Epic', category: 'rare', collisionType: 'ring', unlocked: false, defaultSkin: 'classic', skins: ['classic', 'plasma_blue', 'obsidian_glowing'] },
    { id: 'heart', name: 'Heart', price: 3500, rarity: 'Epic', category: 'special', collisionType: 'heart', unlocked: false, defaultSkin: 'classic', skins: ['classic', 'neon_pink', 'cosmic_purple'] },
    { id: 'lightning', name: 'Lightning', price: 5000, rarity: 'Epic', category: 'special', collisionType: 'lightning', unlocked: false, defaultSkin: 'classic', skins: ['classic', 'deep_gold', 'emerald_flare'] },
    { id: 'cyber_blade', name: 'Cyber Blade', price: 7500, rarity: 'Legendary', category: 'legendary', collisionType: 'polygon', unlocked: false, defaultSkin: 'classic', skins: ['classic', 'cyber_cyan', 'obsidian_glowing'] },
    { id: 'plasma_orb', name: 'Plasma Orb', price: 10000, rarity: 'Legendary', category: 'legendary', collisionType: 'circle', unlocked: false, defaultSkin: 'classic', skins: ['classic', 'plasma_blue', 'dark_shadow'] },
    { id: 'quantum_star', name: 'Quantum Star', price: 15000, rarity: 'Mythic', category: 'legendary', collisionType: 'star', unlocked: false, defaultSkin: 'classic', skins: ['classic', 'obsidian_glowing', 'deep_gold'] }
];

// Expanded & Balanced Vehicle Skins definition
const VEHICLE_SKINS = [
    { id: 'classic', name: 'Classic Green', cost: 0, unlocked: true, color: '#00ff66', trailColor: '#00f3ff', particleColor: '#00ff66', trailType: 'wave', category: 'skins' },
    { id: 'neon_pink', name: 'Hot Pink', cost: 150, unlocked: false, color: '#ff007f', trailColor: '#ffaa00', particleColor: '#ff007f', trailType: 'wave', category: 'skins' },
    { id: 'cyber_cyan', name: 'Cyber Cyan', cost: 300, unlocked: false, color: '#00f3ff', trailColor: '#b026ff', particleColor: '#00f3ff', trailType: 'wave', category: 'skins' },
    { id: 'deep_gold', name: 'Royal Gold', cost: 500, unlocked: false, color: '#ffaa00', trailColor: '#ffffff', particleColor: '#ffaa00', trailType: 'particles', category: 'trails' },
    { id: 'cosmic_purple', name: 'Cosmo Purple', cost: 800, unlocked: false, color: '#b026ff', trailColor: '#ff007f', particleColor: '#b026ff', trailType: 'wave', category: 'colors' },
    { id: 'dark_shadow', name: 'Dark Shadow', cost: 1200, unlocked: false, color: '#666666', trailColor: '#ff2233', particleColor: '#333333', trailType: 'shadow', category: 'trails' },
    { id: 'obsidian_glowing', name: 'Nether Rune', cost: 2000, unlocked: false, color: '#ff5500', trailColor: '#ff007f', particleColor: '#ff5500', trailType: 'rainbow', category: 'trails' },
    { id: 'plasma_blue', name: 'Plasma Blue', cost: 600, unlocked: false, color: '#0088ff', trailColor: '#00f3ff', particleColor: '#00ddff', trailType: 'wave', category: 'colors' },
    { id: 'emerald_flare', name: 'Emerald Flare', cost: 950, unlocked: false, color: '#10ff99', trailColor: '#ffff00', particleColor: '#00ff66', trailType: 'particles', category: 'colors' }
];

// LocalStorage Keys
const KEYS = {
    COINS: 'speedy_arrow_coins_v3',
    STREAK: 'speedy_arrow_streak_v3',
    LAST_LOGIN: 'speedy_arrow_last_login_v3',
    USERNAME: 'speedy_arrow_username_v3',
    COUNTRY: 'speedy_arrow_country_v3',
    BIO: 'speedy_arrow_bio_v3',
    UID: 'speedy_arrow_uid_v3',
    PHOTO_URL: 'speedy_arrow_photo_url_v3',
    LEVELS: 'speedy_arrow_levels_v3',
    EQUIPPED_SHAPE: 'speedy_arrow_equipped_shape_v3',
    OWNED_SHAPES: 'speedy_arrow_owned_shapes_v3',
    EQUIPPED_SKIN: 'speedy_arrow_equipped_skin_v3',
    OWNED_SKINS: 'speedy_arrow_owned_skins_v3',
    RATING: 'speedy_arrow_rating_v3',
    CRASHES: 'speedy_arrow_crashes_v3',
    PERFECT_RUNS: 'speedy_arrow_perfects_v3',
    HIGH_SCORE: 'speedy_arrow_hiscore_v3',
    RACE_WINS: 'speedy_arrow_race_wins_v3',
    SOCIAL_YT: 'speedy_arrow_yt_v3',
    SOCIAL_IG: 'speedy_arrow_ig_v3',
    SOCIAL_TW: 'speedy_arrow_tw_v3',
    SOCIAL_TWITCH: 'speedy_arrow_twitch_v3'
};

// --- GLOBAL UI / GAME STATE ---
const UI_STATE = {
    activeBiome: 'forest',
    activeShopTab: 'all', // 'all', 'shapes', 'special', 'rare', 'legendary', 'skins'
    ploCoins: 100, // starting coins
    streakDays: 1,
    lastLoginDate: '',
    username: 'SpeedRider',
    country: 'USA',
    bio: 'Neon Wave Master & Geometry pilot.',
    uid: '84920155',
    photoURL: null,
    unlockedLevels: { 1: 0 }, // lvlNum: percentage (e.g. 100 = completed)
    equippedShape: 'arrow',
    ownedShapes: ['arrow'],
    equippedSkin: 'classic',
    ownedSkins: ['classic'],
    eloRating: 1000,
    totalCrashes: 0,
    totalPerfectRuns: 0,
    highScore: 0,
    raceWins: 0,
    followersCount: 12,
    followingCount: 5,
    youtube: '',
    instagram: '',
    twitter: '',
    twitch: ''
};

window.UI_STATE = UI_STATE;
window.KEYS = KEYS;
window.SHAPES = SHAPES;
window.VEHICLE_SKINS = VEHICLE_SKINS;

// --- INITIALIZATION ---
function initUI() {
    loadSavedState();
    checkDailyStreak();
    calculateAndSaveRating();
    renderHeaderWidgets();
    renderLevelSelector();
    renderShopSkins();
    renderProfileDetails();
    renderLeaderboardList();
}
window.initUI = initUI;

// --- LOAD PERSISTENT STATE FROM LOCALSTORAGE ---
function loadSavedState() {
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

        let savedUID = localStorage.getItem(KEYS.UID);
        if (!savedUID) {
            savedUID = Math.floor(10000000 + Math.random() * 90000000).toString();
            localStorage.setItem(KEYS.UID, savedUID);
        }
        UI_STATE.uid = savedUID;

        const savedPhoto = localStorage.getItem(KEYS.PHOTO_URL);
        if (savedPhoto) UI_STATE.photoURL = savedPhoto;

        const savedLevels = localStorage.getItem(KEYS.LEVELS);
        if (savedLevels) {
            try {
                UI_STATE.unlockedLevels = JSON.parse(savedLevels);
            } catch (err) {
                UI_STATE.unlockedLevels = { 1: 0 };
            }
        }
        if (!UI_STATE.unlockedLevels || Object.keys(UI_STATE.unlockedLevels).length === 0) {
            UI_STATE.unlockedLevels = { 1: 0 };
        }

        const savedEquippedShape = localStorage.getItem(KEYS.EQUIPPED_SHAPE);
        if (savedEquippedShape && SHAPES.some(s => s.id === savedEquippedShape)) {
            UI_STATE.equippedShape = savedEquippedShape;
        }

        const savedOwnedShapes = localStorage.getItem(KEYS.OWNED_SHAPES);
        if (savedOwnedShapes) {
            try {
                const parsed = JSON.parse(savedOwnedShapes);
                if (Array.isArray(parsed)) UI_STATE.ownedShapes = parsed;
            } catch (err) {
                UI_STATE.ownedShapes = ['arrow'];
            }
        }
        if (!UI_STATE.ownedShapes.includes('arrow')) {
            UI_STATE.ownedShapes.push('arrow');
        }

        const savedEquipped = localStorage.getItem(KEYS.EQUIPPED_SKIN);
        if (savedEquipped && VEHICLE_SKINS.some(s => s.id === savedEquipped)) {
            UI_STATE.equippedSkin = savedEquipped;
        }

        const savedOwned = localStorage.getItem(KEYS.OWNED_SKINS);
        if (savedOwned) {
            try {
                const parsed = JSON.parse(savedOwned);
                if (Array.isArray(parsed)) UI_STATE.ownedSkins = parsed;
            } catch (err) {
                UI_STATE.ownedSkins = ['classic'];
            }
        }
        if (!UI_STATE.ownedSkins.includes('classic')) {
            UI_STATE.ownedSkins.push('classic');
        }

        const savedCrashes = localStorage.getItem(KEYS.CRASHES);
        if (savedCrashes !== null) UI_STATE.totalCrashes = parseInt(savedCrashes, 10) || 0;

        const savedPerfects = localStorage.getItem(KEYS.PERFECT_RUNS);
        if (savedPerfects !== null) UI_STATE.totalPerfectRuns = parseInt(savedPerfects, 10) || 0;

        const savedHiScore = localStorage.getItem(KEYS.HIGH_SCORE);
        if (savedHiScore !== null) UI_STATE.highScore = parseInt(savedHiScore, 10) || 0;

        const savedRaceWins = localStorage.getItem(KEYS.RACE_WINS);
        if (savedRaceWins !== null) UI_STATE.raceWins = parseInt(savedRaceWins, 10) || 0;

        UI_STATE.youtube = localStorage.getItem(KEYS.SOCIAL_YT) || '';
        UI_STATE.instagram = localStorage.getItem(KEYS.SOCIAL_IG) || '';
        UI_STATE.twitter = localStorage.getItem(KEYS.SOCIAL_TW) || '';
        UI_STATE.twitch = localStorage.getItem(KEYS.SOCIAL_TWITCH) || '';

        console.log("[Speedy Arrow] Loaded user profile from storage successfully.");
    } catch (e) {
        console.error('Error loading game state from localStorage:', e);
    }
}

function saveStateItem(key, val) {
    try {
        if (typeof val === 'object') {
            localStorage.setItem(key, JSON.stringify(val));
        } else {
            localStorage.setItem(key, val.toString());
        }
    } catch (e) {
        console.error('Error saving state item:', e);
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
        // First login
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
            // Next consecutive day
            UI_STATE.streakDays += 1;
            const reward = Math.min(300, 50 * UI_STATE.streakDays);
            UI_STATE.ploCoins += reward;
            UI_STATE.lastLoginDate = todayStr;
            saveStateItem(KEYS.COINS, UI_STATE.ploCoins);
            saveStateItem(KEYS.STREAK, UI_STATE.streakDays);
            saveStateItem(KEYS.LAST_LOGIN, UI_STATE.lastLoginDate);
            triggerStreakPopup(UI_STATE.streakDays, reward);
        } else if (diffDays > 1) {
            // Streak broken
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
            if (streakEl) streakEl.innerText = days;
            const coinsEl = document.getElementById('reward-popup-coins');
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

// --- PLAYER PROFILE & SKILL RATING (ELO) ---
function calculateAndSaveRating() {
    let completedCount = 0;
    Object.keys(UI_STATE.unlockedLevels).forEach(lvl => {
        if (UI_STATE.unlockedLevels[lvl] >= 100) completedCount++;
    });

    const calculatedRating = Math.max(
        100,
        1000 + (completedCount * 35) + (UI_STATE.totalPerfectRuns * 60) + (UI_STATE.raceWins * 20) + Math.floor(UI_STATE.highScore / 20) - (UI_STATE.totalCrashes * 3)
    );
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
    renderLeaderboardList();
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

    const endTag = document.getElementById('endless-high-score-v2');
    if (endTag) endTag.innerText = `Best Survival: ${UI_STATE.highScore}m`;

    const raceTag = document.getElementById('race-wins-v2');
    if (raceTag) raceTag.innerText = `Championship Wins: ${UI_STATE.raceWins}`;

    updateUIAvatars(UI_STATE.photoURL);
}
window.renderHeaderWidgets = renderHeaderWidgets;

function updateUIAvatars(photoURL) {
    const avatars = document.querySelectorAll('.profile-avatar, .profile-avatar-large');
    avatars.forEach(av => {
        if (photoURL) {
            av.innerHTML = `<img src="${photoURL}" alt="Avatar">`;
        } else {
            av.innerHTML = '👤';
        }
    });
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

// --- LEVEL SELECTOR ACROSS 5 BIOMES (100 LEVELS) ---
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
            percent.innerText = `${Math.floor(progress)}%`;
            box.appendChild(percent);

            if (progress >= 100) {
                const stars = document.createElement('div');
                stars.className = 'level-stars';
                stars.innerText = '⭐⭐⭐';
                box.appendChild(stars);
            }
        } else {
            const num = document.createElement('div');
            num.className = 'level-num';
            num.innerText = l;
            box.appendChild(num);

            const cost = 100;
            const priceTag = document.createElement('div');
            priceTag.className = 'unlock-price-tag';
            priceTag.innerHTML = `🪙 ${cost}`;
            priceTag.title = 'Unlock level early with coins';
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
        window.showToast(`Level ${level} unlocked!`, 'success');
        if (typeof window.playCheckpointSound === 'function') window.playCheckpointSound();
    } else {
        window.showToast("Not enough Speedy Coins! Fly in Endless or beat earlier maps to earn coins.", "error");
    }
}
window.buyUnlockLevel = buyUnlockLevel;

// --- SHOP SYSTEM ---
function switchShopTab(tabName) {
    if (!['all', 'shapes', 'special', 'rare', 'legendary', 'skins'].includes(tabName)) return;
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

    const currentSkinDetails = getActiveSkinDetails();

    // Determine list items based on selected tab
    let itemsToDisplay = [];

    if (UI_STATE.activeShopTab === 'all') {
        itemsToDisplay = [
            ...SHAPES.map(s => ({ ...s, itemType: 'shape' })),
            ...VEHICLE_SKINS.map(sk => ({ ...sk, itemType: 'skin' }))
        ];
    } else if (UI_STATE.activeShopTab === 'shapes') {
        itemsToDisplay = SHAPES.map(s => ({ ...s, itemType: 'shape' }));
    } else if (UI_STATE.activeShopTab === 'special') {
        itemsToDisplay = SHAPES.filter(s => s.category === 'special').map(s => ({ ...s, itemType: 'shape' }));
    } else if (UI_STATE.activeShopTab === 'rare') {
        itemsToDisplay = SHAPES.filter(s => s.category === 'rare').map(s => ({ ...s, itemType: 'shape' }));
    } else if (UI_STATE.activeShopTab === 'legendary') {
        itemsToDisplay = SHAPES.filter(s => s.category === 'legendary').map(s => ({ ...s, itemType: 'shape' }));
    } else if (UI_STATE.activeShopTab === 'skins') {
        itemsToDisplay = VEHICLE_SKINS.map(sk => ({ ...sk, itemType: 'skin' }));
    }

    itemsToDisplay.forEach(item => {
        const isShape = item.itemType === 'shape';
        const isOwned = isShape ? UI_STATE.ownedShapes.includes(item.id) : UI_STATE.ownedSkins.includes(item.id);
        const isEquipped = isShape ? UI_STATE.equippedShape === item.id : UI_STATE.equippedSkin === item.id;
        const itemPrice = isShape ? item.price : item.cost;

        const card = document.createElement('div');
        card.className = `skin-card ${isEquipped ? 'selected' : ''} ${isOwned ? 'unlocked' : 'locked'}`;
        card.onclick = () => isShape ? selectShape(item.id) : selectSkin(item.id);

        // Rarity badge for shapes
        if (item.rarity) {
            const badge = document.createElement('div');
            badge.className = `rarity-badge rarity-${item.rarity}`;
            badge.innerText = item.rarity;
            card.appendChild(badge);
        }

        const previewHolder = document.createElement('div');
        previewHolder.className = 'skin-preview-canvas-holder';

        const pvCanvas = document.createElement('canvas');
        pvCanvas.width = 120;
        pvCanvas.height = 54;
        drawShapePreview(pvCanvas, item, isShape, currentSkinDetails);
        previewHolder.appendChild(pvCanvas);
        card.appendChild(previewHolder);

        const name = document.createElement('div');
        name.className = 'skin-name';
        name.innerText = item.name;
        card.appendChild(name);

        const status = document.createElement('button');
        status.type = 'button';
        if (isEquipped) {
            status.className = 'skin-status equipped';
            status.innerText = 'EQUIPPED';
        } else if (isOwned) {
            status.className = 'skin-status unlocked';
            status.innerText = 'EQUIP';
        } else {
            status.className = 'skin-status locked';
            status.innerText = `BUY: 🪙${itemPrice}`;
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

function drawShapePreview(canvas, item, isShape, skinDetails) {
    const ctx = canvas.getContext('2d');
    ctx.clearRect(0, 0, canvas.width, canvas.height);

    const mainColor = isShape ? skinDetails.color : item.color;
    const trailColor = isShape ? skinDetails.trailColor : item.trailColor;
    const shapeId = isShape ? item.id : UI_STATE.equippedShape;

    // Glowing halo behind preview shape
    const grad = ctx.createRadialGradient(36, 27, 2, 36, 27, 20);
    grad.addColorStop(0, mainColor);
    grad.addColorStop(1, 'transparent');
    ctx.fillStyle = grad;
    ctx.beginPath();
    ctx.arc(36, 27, 20, 0, Math.PI * 2);
    ctx.fill();

    // Render shape geometry
    ctx.save();
    ctx.translate(36, 27);
    ctx.strokeStyle = '#ffffff';
    ctx.lineWidth = 2;
    ctx.fillStyle = mainColor;
    ctx.shadowColor = mainColor;
    ctx.shadowBlur = 8;

    drawShapeGeometry(ctx, shapeId, 16);

    ctx.fill();
    ctx.stroke();
    ctx.restore();

    // Trailing wave ribbon
    ctx.strokeStyle = trailColor;
    ctx.lineWidth = 2.8;
    ctx.shadowColor = trailColor;
    ctx.shadowBlur = 6;
    ctx.beginPath();
    ctx.moveTo(48, 27);
    for (let x = 48; x < 112; x += 4) {
        const y = 27 + Math.sin((x - 48) * 0.16) * 7;
        ctx.lineTo(x, y);
    }
    ctx.stroke();
}

// Utility drawing helper for shapes preview and engine
function drawShapeGeometry(ctx, shapeId, size = 16) {
    ctx.beginPath();
    const r = size;

    switch (shapeId) {
        case 'arrow':
            ctx.moveTo(r, 0);
            ctx.lineTo(-r, -r * 0.75);
            ctx.lineTo(-r * 0.4, 0);
            ctx.lineTo(-r, r * 0.75);
            break;

        case 'triangle':
            ctx.moveTo(r, 0);
            ctx.lineTo(-r, -r * 0.866);
            ctx.lineTo(-r, r * 0.866);
            break;

        case 'circle':
        case 'plasma_orb':
            ctx.arc(0, 0, r * 0.85, 0, Math.PI * 2);
            break;

        case 'ring':
            ctx.arc(0, 0, r * 0.85, 0, Math.PI * 2);
            break;

        case 'square':
            ctx.rect(-r * 0.75, -r * 0.75, r * 1.5, r * 1.5);
            break;

        case 'rounded_square':
            const w = r * 1.4;
            const h = r * 1.4;
            const rx = 4;
            ctx.roundRect(-w / 2, -h / 2, w, h, rx);
            break;

        case 'rectangle':
            ctx.rect(-r, -r * 0.6, r * 2, r * 1.2);
            break;

        case 'diamond':
            ctx.moveTo(r, 0);
            ctx.lineTo(0, -r);
            ctx.lineTo(-r, 0);
            ctx.lineTo(0, r);
            break;

        case 'pentagon':
            drawRegularPolygon(ctx, 5, r * 0.9);
            break;

        case 'hexagon':
            drawRegularPolygon(ctx, 6, r * 0.9);
            break;

        case 'octagon':
            drawRegularPolygon(ctx, 8, r * 0.9);
            break;

        case 'star':
        case 'quantum_star':
            drawStarPoints(ctx, 5, r, r * 0.45);
            break;

        case 'plus_cross':
            const arm = r * 0.35;
            const len = r * 0.9;
            ctx.moveTo(-arm, -len);
            ctx.lineTo(arm, -len);
            ctx.lineTo(arm, -arm);
            ctx.lineTo(len, -arm);
            ctx.lineTo(len, arm);
            ctx.lineTo(arm, arm);
            ctx.lineTo(arm, len);
            ctx.lineTo(-arm, len);
            ctx.lineTo(-arm, arm);
            ctx.lineTo(-len, arm);
            ctx.lineTo(-len, -arm);
            ctx.lineTo(-arm, -arm);
            break;

        case 'heart':
            const scale = r / 16;
            ctx.moveTo(0, scale * 6);
            ctx.bezierCurveTo(-scale * 12, -scale * 6, -scale * 14, -scale * 14, 0, -scale * 14);
            ctx.bezierCurveTo(scale * 14, -scale * 14, scale * 12, -scale * 6, 0, scale * 6);
            break;

        case 'lightning':
            const lr = r * 0.9;
            ctx.moveTo(lr * 0.4, -lr);
            ctx.lineTo(-lr * 0.6, 0);
            ctx.lineTo(-lr * 0.1, 0);
            ctx.lineTo(-lr * 0.4, lr);
            ctx.lineTo(lr * 0.6, 0);
            ctx.lineTo(lr * 0.1, 0);
            break;

        case 'cyber_blade':
            ctx.moveTo(r * 1.2, 0);
            ctx.lineTo(-r * 0.8, -r * 0.9);
            ctx.lineTo(-r * 0.3, 0);
            ctx.lineTo(-r * 0.8, r * 0.9);
            break;

        default:
            ctx.moveTo(r, 0);
            ctx.lineTo(-r, -r * 0.75);
            ctx.lineTo(-r * 0.4, 0);
            ctx.lineTo(-r, r * 0.75);
            break;
    }
    ctx.closePath();
}
window.drawShapeGeometry = drawShapeGeometry;

function drawRegularPolygon(ctx, sides, radius) {
    for (let i = 0; i < sides; i++) {
        const angle = (i * 2 * Math.PI) / sides;
        const x = Math.cos(angle) * radius;
        const y = Math.sin(angle) * radius;
        if (i === 0) ctx.moveTo(x, y);
        else ctx.lineTo(x, y);
    }
}

function drawStarPoints(ctx, points, outerRadius, innerRadius) {
    for (let i = 0; i < points * 2; i++) {
        const r = i % 2 === 0 ? outerRadius : innerRadius;
        const angle = (i * Math.PI) / points;
        const x = Math.cos(angle) * r;
        const y = Math.sin(angle) * r;
        if (i === 0) ctx.moveTo(x, y);
        else ctx.lineTo(x, y);
    }
}

function selectShape(shapeId) {
    const shape = SHAPES.find(s => s.id === shapeId);
    if (!shape) return;

    const isOwned = UI_STATE.ownedShapes.includes(shapeId);

    if (isOwned) {
        UI_STATE.equippedShape = shapeId;
        saveStateItem(KEYS.EQUIPPED_SHAPE, shapeId);
        window.showToast(`Equipped ${shape.name}!`, 'success');
        if (typeof window.playCheckpointSound === 'function') window.playCheckpointSound();
    } else {
        if (UI_STATE.ploCoins >= shape.price) {
            UI_STATE.ploCoins -= shape.price;
            UI_STATE.ownedShapes.push(shapeId);
            UI_STATE.equippedShape = shapeId;

            saveStateItem(KEYS.COINS, UI_STATE.ploCoins);
            saveStateItem(KEYS.OWNED_SHAPES, UI_STATE.ownedShapes);
            saveStateItem(KEYS.EQUIPPED_SHAPE, shapeId);

            window.showToast(`Unlocked & equipped ${shape.name}!`, 'success');
            if (typeof window.playCheckpointSound === 'function') window.playCheckpointSound();
        } else {
            window.showToast(`Not enough coins! Need 🪙${shape.price - UI_STATE.ploCoins} more.`, "error");
        }
    }

    renderHeaderWidgets();
    renderShopSkins();
}
window.selectShape = selectShape;

function selectSkin(skinId) {
    const skin = VEHICLE_SKINS.find(s => s.id === skinId);
    if (!skin) return;

    const isOwned = UI_STATE.ownedSkins.includes(skinId);

    if (isOwned) {
        UI_STATE.equippedSkin = skinId;
        saveStateItem(KEYS.EQUIPPED_SKIN, skinId);
        window.showToast(`Equipped skin ${skin.name}!`, 'success');
        if (typeof window.playCheckpointSound === 'function') window.playCheckpointSound();
    } else {
        if (UI_STATE.ploCoins >= skin.cost) {
            UI_STATE.ploCoins -= skin.cost;
            UI_STATE.ownedSkins.push(skinId);
            UI_STATE.equippedSkin = skinId;

            saveStateItem(KEYS.COINS, UI_STATE.ploCoins);
            saveStateItem(KEYS.OWNED_SKINS, UI_STATE.ownedSkins);
            saveStateItem(KEYS.EQUIPPED_SKIN, skinId);

            window.showToast(`Unlocked & equipped skin ${skin.name}!`, 'success');
            if (typeof window.playCheckpointSound === 'function') window.playCheckpointSound();
        } else {
            window.showToast(`Not enough coins! Need 🪙${skin.cost - UI_STATE.ploCoins} more.`, "error");
        }
    }

    renderHeaderWidgets();
    renderShopSkins();
}
window.selectSkin = selectSkin;

function getActiveShapeDetails() {
    return SHAPES.find(s => s.id === UI_STATE.equippedShape) || SHAPES[0];
}
window.getActiveShapeDetails = getActiveShapeDetails;

function getActiveSkinDetails() {
    return VEHICLE_SKINS.find(s => s.id === UI_STATE.equippedSkin) || VEHICLE_SKINS[0];
}
window.getActiveSkinDetails = getActiveSkinDetails;

// --- LEADERBOARDS & PUBLIC PLAYERS SYSTEM ---
const MOCK_LEADERBOARD = [
    { rank: 1, name: 'HexVortex', rating: 2450, country: '🇯🇵 JPN', endless: 3420, wins: 48, uid: '78291044', bio: 'Champion speedrunner' },
    { rank: 2, name: 'NeonPulse', rating: 2280, country: '🇺🇸 USA', endless: 2980, wins: 39, uid: '91823741', bio: 'Wave rider 24/7' },
    { rank: 3, name: 'QuantumGlider', rating: 2110, country: '🇩🇪 DEU', endless: 2650, wins: 31, uid: '44910283', bio: 'Flawless runner' },
    { rank: 4, name: 'CyberPhantom', rating: 1950, country: '🇮🇳 IND', endless: 2210, wins: 26, uid: '33019284', bio: 'Geometry legend' },
    { rank: 5, name: 'AeroStrike', rating: 1820, country: '🇬🇧 GBR', endless: 1940, wins: 19, uid: '55829102', bio: 'Fast and furious' },
    { rank: 6, name: 'Solaris', rating: 1690, country: '🇨🇦 CAN', endless: 1750, wins: 14, uid: '66718293', bio: 'Aiming for top 3' },
    { rank: 7, name: 'ApexRider', rating: 1540, country: '🇫🇷 FRA', endless: 1480, wins: 11, uid: '88291047', bio: 'Practice makes perfect' }
];

function renderLeaderboardList() {
    const list = document.getElementById('leaderboard-screen-list');
    if (!list) return;
    list.innerHTML = '';

    // Insert user into mock leaderboard sorted by rating
    const all = [...MOCK_LEADERBOARD, {
        rank: 0,
        name: UI_STATE.username + ' (YOU)',
        rating: UI_STATE.eloRating,
        country: '🇺🇸 ' + UI_STATE.country,
        endless: UI_STATE.highScore,
        wins: UI_STATE.raceWins,
        uid: UI_STATE.uid,
        isUser: true
    }];

    all.sort((a, b) => b.rating - a.rating);

    all.forEach((item, idx) => {
        const row = document.createElement('div');
        row.className = `glass-panel leaderboard-item ${item.isUser ? 'user-row' : ''}`;
        row.style.cssText = `
            display: flex;
            align-items: center;
            justify-content: space-between;
            padding: 10px 16px;
            margin-bottom: 8px;
            border-radius: 10px;
            border-color: ${item.isUser ? 'var(--neon-green)' : 'rgba(0, 243, 255, 0.2)'};
            background: ${item.isUser ? 'rgba(0, 255, 102, 0.08)' : 'rgba(255,255,255,0.02)'};
        `;

        row.innerHTML = `
            <div style="display: flex; align-items: center; gap: 12px;">
                <span style="font-family: 'Orbitron'; font-weight: 900; font-size: 16px; color: ${idx === 0 ? 'var(--neon-gold)' : idx === 1 ? 'var(--neon-cyan)' : idx === 2 ? 'var(--neon-pink)' : '#a4c4c1'}; width: 28px;">#${idx + 1}</span>
                <div style="text-align: left;">
                    <div style="font-family: 'Orbitron'; font-weight: 700; color: ${item.isUser ? 'var(--neon-green)' : '#fff'}; font-size: 14px;">${item.name}</div>
                    <div style="font-size: 11px; color: #a4c4c1;">UID: ${item.uid} | Best: ${item.endless}m | Wins: ${item.wins}</div>
                </div>
            </div>
            <div style="text-align: right;">
                <div style="font-family: 'Orbitron'; font-weight: 900; font-size: 15px; color: var(--neon-cyan);">${item.rating}</div>
                <div style="font-size: 10px; color: #a4c4c1; letter-spacing: 0.5px;">ELO RATING</div>
            </div>
        `;
        list.appendChild(row);
    });
}
window.renderLeaderboardList = renderLeaderboardList;

// --- PROFILE ACTIONS ---
function updateProfileUsername(newName) {
    if (!newName || newName.trim() === '') return;
    UI_STATE.username = newName.trim();
    saveStateItem(KEYS.USERNAME, UI_STATE.username);
    renderHeaderWidgets();
    renderLeaderboardList();
    window.showToast("Username updated!", "success");
}
window.updateProfileUsername = updateProfileUsername;

function updateProfileCountry(newCountry) {
    if (!newCountry || newCountry.trim() === '') return;
    UI_STATE.country = newCountry.trim();
    saveStateItem(KEYS.COUNTRY, UI_STATE.country);
    renderHeaderWidgets();
}
window.updateProfileCountry = updateProfileCountry;

function updateProfileBio(newBio) {
    UI_STATE.bio = newBio || '';
    saveStateItem(KEYS.BIO, UI_STATE.bio);
    window.showToast("Bio saved!", "success");
}
window.updateProfileBio = updateProfileBio;

function updateSocialLink(network, url) {
    if (network === 'youtube') { UI_STATE.youtube = url; saveStateItem(KEYS.SOCIAL_YT, url); }
    if (network === 'instagram') { UI_STATE.instagram = url; saveStateItem(KEYS.SOCIAL_IG, url); }
    if (network === 'twitter') { UI_STATE.twitter = url; saveStateItem(KEYS.SOCIAL_TW, url); }
    if (network === 'twitch') { UI_STATE.twitch = url; saveStateItem(KEYS.SOCIAL_TWITCH, url); }
    window.showToast(`${network.toUpperCase()} link updated!`, "success");
}
window.updateSocialLink = updateSocialLink;

function uploadProfilePicture(fileInput) {
    const file = fileInput.files[0];
    if (!file) return;

    const reader = new FileReader();
    reader.onload = (e) => {
        const dataUrl = e.target.result;
        UI_STATE.photoURL = dataUrl;
        saveStateItem(KEYS.PHOTO_URL, dataUrl);
        updateUIAvatars(dataUrl);
        window.showToast("Avatar image updated!", "success");
    };
    reader.readAsDataURL(file);
}
window.uploadProfilePicture = uploadProfilePicture;

// --- SPA SCREEN ROUTING ---
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
    if (screenId === 'hud-overlay') {
        if (hud) hud.classList.add('active');
    } else {
        if (hud) hud.classList.remove('active');
    }
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

function openLevelSelect() {
    if (typeof window.setGameState === 'function') {
        window.setGameState('level_select');
    } else {
        showScreen('level-select-screen');
    }
    renderLevelSelector();
}
window.openLevelSelect = openLevelSelect;

function navigateToProfileScreen() {
    showScreen('profile-screen');
    renderProfileDetails();
}
window.navigateToProfileScreen = navigateToProfileScreen;

function navigateToShopScreen() {
    showScreen('shop-screen');
    renderShopSkins();
}
window.navigateToShopScreen = navigateToShopScreen;

function navigateToSearchScreen() {
    showScreen('search-screen');
}
window.navigateToSearchScreen = navigateToSearchScreen;

function navigateToLeaderboardScreen() {
    renderLeaderboardList();
    showScreen('leaderboard-screen');
}
window.navigateToLeaderboardScreen = navigateToLeaderboardScreen;

// Search riders by 8-Digit UID
function searchPlayersByUID(queryUID) {
    const term = (queryUID || '').toString().trim();
    const containers = [
        document.getElementById('social-search-results'),
        document.getElementById('settings-search-results')
    ].filter(el => el !== null);

    if (!term) {
        containers.forEach(c => c.innerHTML = `<div style="color: #a4c4c1; font-size: 13px;">Enter an 8-digit Player ID above to search...</div>`);
        return;
    }

    containers.forEach(c => c.innerHTML = `<div style="color: var(--neon-cyan); font-size: 13px;">Searching Rider database...</div>`);

    setTimeout(() => {
        // Check mock riders or user
        const all = [...MOCK_LEADERBOARD, {
            name: UI_STATE.username,
            rating: UI_STATE.eloRating,
            country: UI_STATE.country,
            endless: UI_STATE.highScore,
            wins: UI_STATE.raceWins,
            uid: UI_STATE.uid,
            bio: UI_STATE.bio
        }];

        const match = all.find(r => r.uid === term || r.uid.includes(term) || r.name.toLowerCase().includes(term.toLowerCase()));

        if (match) {
            const html = `
                <div style="display: flex; align-items: center; justify-content: space-between; padding: 12px; background: rgba(0,243,255,0.06); border: 1.5px solid var(--neon-cyan); border-radius: 10px; width: 100%;">
                    <div style="display: flex; align-items: center; gap: 12px;">
                        <div style="font-size: 24px;">👤</div>
                        <div style="text-align: left;">
                            <div style="font-weight: bold; color: #fff; font-family: 'Orbitron'; font-size: 15px;">${match.name}</div>
                            <div style="font-size: 11px; color: var(--neon-gold); font-family: 'Orbitron';">UID: ${match.uid} | Rating: ${match.rating}</div>
                        </div>
                    </div>
                    <button class="settings-btn" style="padding: 6px 12px; font-size: 12px; border-color: var(--neon-pink);" onclick="window.viewPublicProfile('${match.uid}')">View Bio</button>
                </div>
            `;
            containers.forEach(c => c.innerHTML = html);
        } else {
            containers.forEach(c => c.innerHTML = `<div style="color: var(--neon-pink); font-size: 13px; font-weight: bold;">RIDER NOT FOUND (Check 8-digit UID)</div>`);
        }
    }, 200);
}
window.searchPlayersByUID = searchPlayersByUID;

function viewPublicProfile(uid) {
    const all = [...MOCK_LEADERBOARD, {
        name: UI_STATE.username,
        rating: UI_STATE.eloRating,
        country: UI_STATE.country,
        endless: UI_STATE.highScore,
        wins: UI_STATE.raceWins,
        uid: UI_STATE.uid,
        bio: UI_STATE.bio,
        followersCount: UI_STATE.followersCount,
        followingCount: UI_STATE.followingCount
    }];

    const player = all.find(r => r.uid === uid) || all[0];

    const unEl = document.getElementById('public-profile-username');
    if (unEl) unEl.innerText = player.name;
    const uidEl = document.getElementById('public-profile-uid-display');
    if (uidEl) uidEl.innerText = `UID: ${player.uid}`;
    const bioEl = document.getElementById('public-profile-bio');
    if (bioEl) bioEl.innerText = player.bio || 'Neon Geometry Wave Runner pilot.';
    const ratEl = document.getElementById('public-profile-rating');
    if (ratEl) ratEl.innerText = player.rating;
    const hsEl = document.getElementById('public-profile-highscore');
    if (hsEl) hsEl.innerText = `${player.endless || 0}m`;
    const fEl = document.getElementById('public-profile-followers');
    if (fEl) fEl.innerText = player.followersCount || 15;
    const fgEl = document.getElementById('public-profile-following');
    if (fgEl) fgEl.innerText = player.followingCount || 8;

    showScreen('public-profile-screen');
}
window.viewPublicProfile = viewPublicProfile;

function toggleFollowPublicUser() {
    const btn = document.getElementById('public-follow-btn');
    if (!btn) return;
    const isFollow = btn.innerText === 'FOLLOW';
    btn.innerText = isFollow ? 'UNFOLLOW' : 'FOLLOW';
    const folEl = document.getElementById('public-profile-followers');
    if (folEl) {
        let count = parseInt(folEl.innerText, 10) || 0;
        folEl.innerText = isFollow ? count + 1 : Math.max(0, count - 1);
    }
    window.showToast(isFollow ? 'You followed this rider!' : 'Unfollowed rider', 'info');
}
window.toggleFollowPublicUser = toggleFollowPublicUser;

function challengePublicUser() {
    window.showToast("Starting challenge race tournament!", "success");
    if (typeof window.launchRaceMode === 'function') {
        window.launchRaceMode();
    }
}
window.challengePublicUser = challengePublicUser;
