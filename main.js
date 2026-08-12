// Purge legacy data and block all browser storage (No Local Saving)
try {
    window.localStorage.clear();
    window.sessionStorage.clear();
    console.log("[Storage Purge] Absolute localStorage and sessionStorage purge complete on page init.");
} catch (e) {
    console.warn("[Storage Purge] Storage clear failed: ", e);
}

const dummyStorage = {
    setItem: () => { console.log("[Storage Blocked] setItem called (no-op)"); },
    getItem: () => null,
    removeItem: () => {},
    clear: () => {},
    key: () => null,
    get length() { return 0; }
};

try {
    Object.defineProperty(window, 'localStorage', { value: dummyStorage, configurable: true, writable: true });
    Object.defineProperty(window, 'sessionStorage', { value: dummyStorage, configurable: true, writable: true });
} catch (e) {
    console.error("Failed to override storage with defineProperty, applying fallback:", e);
    window.localStorage = dummyStorage;
    window.sessionStorage = dummyStorage;
}

// Block cookies by redefining document.cookie
try {
    Object.defineProperty(document, 'cookie', {
        get: () => '',
        set: () => '',
        configurable: true
    });
} catch (e) {
    console.warn("Could not block cookies: ", e);
}

// Block IndexedDB access by overriding window.indexedDB
try {
    Object.defineProperty(window, 'indexedDB', {
        get: () => null,
        configurable: true
    });
} catch (e) {
    console.warn("Could not block IndexedDB: ", e);
}

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
