// --- EPHEMERAL IN-MEMORY STATE MANAGER ---
const gameState = {
    coins: 1000,
    purchasedSkins: [],
    settings: {
        volume: 50,
        sensitivity: 5
    }
};
window.gameState = gameState;

// Sync game state to UI_STATE on startup
document.addEventListener('DOMContentLoaded', () => {
    if (window.UI_STATE) {
        window.UI_STATE.ploCoins = gameState.coins;
        window.UI_STATE.ownedSkins = ['classic', ...gameState.purchasedSkins];
        if (typeof window.renderHeaderWidgets === 'function') window.renderHeaderWidgets();
        if (typeof window.renderShopSkins === 'function') window.renderShopSkins();
    }

    // Add click event listeners to SKIN SHOP and SETTINGS buttons
    const shopBtn = document.getElementById('menu-shop-btn-main');
    if (shopBtn) {
        shopBtn.addEventListener('click', () => {
            window.navigateToShopScreen();
        });
    }

    const settingsBtn = document.getElementById('menu-settings-btn');
    if (settingsBtn) {
        settingsBtn.addEventListener('click', () => {
            window.openSettingsOverlay();
        });
    }
});

// Settings Slider Update Callbacks
window.updateVolumeSetting = (val) => {
    gameState.settings.volume = parseInt(val);
    const label = document.getElementById('settings-volume-val');
    if (label) label.innerText = val;
    console.log("[Settings] Volume updated in memory:", gameState.settings.volume);
};

window.updateSensitivitySetting = (val) => {
    gameState.settings.sensitivity = parseInt(val);
    const label = document.getElementById('settings-sensitivity-val');
    if (label) label.innerText = val;
    console.log("[Settings] Sensitivity updated in memory:", gameState.settings.sensitivity);
};

// Override selectSkin to strictly use and update the in-memory gameState
window.selectSkin = (skinId) => {
    if (typeof VEHICLE_SKINS === 'undefined') return;
    const skin = VEHICLE_SKINS.find(s => s.id === skinId);
    if (!skin) return;

    const isOwned = skinId === 'classic' || gameState.purchasedSkins.includes(skinId);

    if (isOwned) {
        if (window.UI_STATE) window.UI_STATE.equippedSkin = skinId;
        if (typeof window.playBuySound === 'function') window.playBuySound();
    } else {
        if (gameState.coins >= skin.cost) {
            gameState.coins -= skin.cost;
            gameState.purchasedSkins.push(skinId);
            if (window.UI_STATE) {
                window.UI_STATE.equippedSkin = skinId;
                window.UI_STATE.ploCoins = gameState.coins;
                window.UI_STATE.ownedSkins = ['classic', ...gameState.purchasedSkins];
            }
            if (typeof window.playBuySound === 'function') window.playBuySound();
            window.showToast(`Purchased ${skin.name} successfully!`, "success");
        } else {
            window.showToast("Insufficient Speedy Coins! Keep playing to earn more.", "error");
        }
    }

    if (typeof window.renderHeaderWidgets === 'function') window.renderHeaderWidgets();
    if (typeof window.renderShopSkins === 'function') window.renderShopSkins();
};

// --- SETTINGS OVERLAY CONTROLLER ---
function openSettingsOverlay() {
    const overlay = document.getElementById('settings-overlay');
    if (overlay) {
        overlay.classList.add('active');
        // Synchronize audio button label
        const isMuted = (typeof window.isMuted !== 'undefined') ? window.isMuted : false;
        const btn = document.getElementById('settings-audio-toggle');
        if (btn) {
            btn.innerHTML = isMuted ? '<span>🔇</span> AUDIO: OFF' : '<span>🔊</span> AUDIO: ON';
        }
        // Synchronize fullscreen button label
        const isFullscreen = !!(document.fullscreenElement || document.webkitFullscreenElement || document.mozFullScreenElement || document.msFullscreenElement);
        const fsBtn = document.getElementById('settings-fullscreen-toggle');
        if (fsBtn) {
            fsBtn.innerHTML = isFullscreen ? '<span>🖥️</span> EXIT FULLSCREEN' : '<span>🖥️</span> ENTER FULLSCREEN';
        }
    }
}
window.openSettingsOverlay = openSettingsOverlay;

function closeSettingsOverlay() {
    const overlay = document.getElementById('settings-overlay');
    if (overlay) {
        overlay.classList.remove('active');
    }
}
window.closeSettingsOverlay = closeSettingsOverlay;

function toggleAudioInSettings() {
    if (typeof window.toggleAudio === 'function') {
        window.toggleAudio();
    }
}
window.toggleAudioInSettings = toggleAudioInSettings;

function toggleFullscreenInSettings() {
    const isFullscreen = !!(document.fullscreenElement || document.webkitFullscreenElement || document.mozFullScreenElement || document.msFullscreenElement);
    if (!isFullscreen) {
        const docEl = document.documentElement;
        const requestFS = docEl.requestFullscreen || docEl.webkitRequestFullscreen || docEl.mozRequestFullScreen || docEl.msRequestFullscreen;
        if (requestFS) {
            requestFS.call(docEl).catch(err => {
                console.error("Error entering fullscreen: ", err);
            });
        }
    } else {
        const exitFS = document.exitFullscreen || document.webkitExitFullscreen || document.mozCancelFullScreen || document.msExitFullscreen;
        if (exitFS) {
            exitFS.call(document).catch(err => {
                console.error("Error exiting fullscreen: ", err);
            });
        }
    }
}
window.toggleFullscreenInSettings = toggleFullscreenInSettings;

function openGameModes() {
    if (typeof window.showScreen === 'function') {
        window.showScreen('game-modes-screen');
    }
}
window.openGameModes = openGameModes;

// --- CUSTOM UI TOAST SYSTEM ---
function showToast(message, type = 'info') {
    const container = document.getElementById('toast-container');
    if (!container) return;

    const toast = document.createElement('div');
    toast.className = `toast-notification ${type}`;

    let icon = 'ℹ️';
    if (type === 'success') icon = '✅';
    if (type === 'error') icon = '❌';
    if (type === 'warning') icon = '⚠️';

    toast.innerHTML = `<span class="toast-icon">${icon}</span><span style="flex-grow: 1;">${message}</span>`;
    container.appendChild(toast);

    // Force reflow and add class for CSS fade-in
    setTimeout(() => {
        toast.classList.add('active');
    }, 50);

    // Auto-dismiss after 3 seconds
    setTimeout(() => {
        toast.classList.remove('active');
        setTimeout(() => {
            toast.remove();
        }, 300);
    }, 3000);
}
window.showToast = showToast;

// Override window.alert for legacy/compatibility safety
window.alert = function(msg) {
    let type = 'info';
    const lower = msg.toLowerCase();
    if (lower.includes('success') || lower.includes('welcome')) {
        type = 'success';
    } else if (lower.includes('fail') || lower.includes('error') || lower.includes('not enough') || lower.includes('insufficient')) {
        type = 'error';
    } else if (lower.includes('login') || lower.includes('sign in')) {
        type = 'warning';
    }
    window.showToast(msg, type);
};

// --- DUMMY LOCAL STATE & FIREBASE STUBS (OFFLINE EPHEMERAL MODE) ---
const currentUser = { isLoggedIn: false, name: "Player", highScore: 0, coins: 0 };
window.currentUser = currentUser;

window.isLoggedIn = false; // Runs in safe guest/offline mode ephemerally
window.firebaseUser = null;

window.firebase = {
    auth: () => ({
        get currentUser() {
            return null;
        }
    })
};

// Override all google.js actions with safe local stubs
window.loginWithGoogle = () => {
    window.showToast("Google Login is disabled. Running in pure offline mode.", "info");
};
window.logoutUser = () => {
    window.showToast("Google Logout is disabled. Running in pure offline mode.", "info");
};
window.uploadProfilePicture = (fileInput) => {
    window.showToast("Profile photo uploads are disabled in offline mode.", "warning");
};
window.updateProfileBio = (bio) => {
    if (window.UI_STATE) window.UI_STATE.bio = bio;
    console.log("[Offline] Bio updated locally in memory:", bio);
};
window.updateSocialLink = (network, url) => {
    if (window.UI_STATE) window.UI_STATE[network] = url;
    console.log(`[Offline] Social ${network} updated locally in memory:`, url);
};
window.searchPlayersByUID = (query) => {
    window.showToast("Rider Search is disabled in offline mode.", "warning");
};
window.viewPublicProfile = () => {};
window.toggleFollowPublicUser = () => {};
window.challengePublicUser = () => {};
window.createMultiplayerRoom = () => {};
window.startMultiplayerMatch = () => {};
window.leaveMultiplayerLobby = () => {};
window.syncUIStateToCloud = () => {
    // No-op for offline mode
};

// Override auth UI state update safely
window.updateAuthUI = () => {
    // Retain clean guest features, showing no-login experience
    const loginIndicator = document.getElementById("login-save-progress-indicator");
    if (loginIndicator) loginIndicator.style.display = "none";
};

// Direct UI screen navigation overrides (offline access)
window.navigateToProfileScreen = () => {
    window.showToast("Please login with Google to access the Profile and save your progress! Running in ephemeral local mode.", "warning");
    if (typeof window.showScreen === 'function') {
        window.showScreen('profile-screen');
    }
};
window.navigateToSearchScreen = () => {
    if (typeof window.showScreen === 'function') {
        window.showScreen('search-screen');
    }
};
window.navigateToShopScreen = () => {
    window.showToast("Please login with Google to access the Shop and save your progress! Running in ephemeral local mode.", "warning");
    if (typeof window.showScreen === 'function') {
        window.showScreen('shop-screen');
    }
};
window.navigateToLeaderboardScreen = () => {
    window.showToast("Leaderboard features are disabled in offline mode. Play Race mode locally!", "info");
};
