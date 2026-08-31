/**
 * Speedy Arrow - Main Script & System Controls
 * Handles Settings, Fullscreen, Toast Notifications, Player Search, and Global Utilities.
 */

// --- SETTINGS OVERLAY CONTROLLER ---
function openSettingsOverlay() {
    const overlay = document.getElementById('settings-overlay');
    if (overlay) {
        overlay.classList.add('active');

        const isMuted = (typeof window.isMuted !== 'undefined') ? window.isMuted : false;
        const btn = document.getElementById('settings-audio-toggle');
        if (btn) {
            btn.innerHTML = isMuted ? '<span>🔇</span> AUDIO: OFF' : '<span>🔊</span> AUDIO: ON';
        }

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
                console.warn("Fullscreen request blocked or unsupported:", err);
                showToast("Fullscreen mode not supported in this view.", "info");
            });
        }
    } else {
        const exitFS = document.exitFullscreen || document.webkitExitFullscreen || document.mozCancelFullScreen || document.msExitFullscreen;
        if (exitFS) {
            exitFS.call(document).catch(err => {
                console.warn("Error exiting fullscreen:", err);
            });
        }
    }
}
window.toggleFullscreenInSettings = toggleFullscreenInSettings;

// --- TOAST NOTIFICATIONS SYSTEM ---
function showToast(message, type = 'info') {
    let container = document.getElementById('toast-container');
    if (!container) {
        container = document.createElement('div');
        container.id = 'toast-container';
        document.body.appendChild(container);
    }

    const toast = document.createElement('div');
    toast.className = `toast-notification ${type}`;

    let icon = 'ℹ️';
    if (type === 'success') icon = '✅';
    if (type === 'error') icon = '❌';
    if (type === 'warning') icon = '⚠️';

    toast.innerHTML = `<span class="toast-icon">${icon}</span><span>${message}</span>`;
    container.appendChild(toast);

    setTimeout(() => {
        toast.classList.add('active');
    }, 20);

    setTimeout(() => {
        toast.classList.remove('active');
        setTimeout(() => {
            toast.remove();
        }, 300);
    }, 2800);
}
window.showToast = showToast;

// --- SEARCH PLAYERS BY UID ---
function searchPlayersByUID(searchQuery) {
    if (!searchQuery || searchQuery.trim() === '') {
        showToast('Please enter an 8-digit Player ID to search.', 'warning');
        return;
    }

    const queryStr = searchQuery.trim();
    const containers = [
        document.getElementById('social-search-results'),
        document.getElementById('settings-search-results')
    ].filter(el => el !== null);

    containers.forEach(c => {
        c.innerHTML = `<div style="color: var(--neon-cyan); font-family: 'Orbitron', sans-serif;">Searching Player ID ${queryStr}...</div>`;
    });

    setTimeout(() => {
        const currentUid = window.UI_STATE ? window.UI_STATE.uid : '';
        const currentName = window.UI_STATE ? window.UI_STATE.username : 'Rider_01';
        const currentRating = window.UI_STATE ? window.UI_STATE.eloRating : 1000;

        let resultHTML = '';

        if (queryStr === currentUid) {
            resultHTML = `
                <div style="display: flex; align-items: center; justify-content: space-between; padding: 12px; background: rgba(0,243,255,0.06); border: 1.5px solid var(--neon-cyan); border-radius: 10px; width: 100%;">
                    <div style="display: flex; align-items: center; gap: 12px;">
                        <div class="profile-avatar" style="width: 36px; height: 36px;">👤</div>
                        <div style="text-align: left;">
                            <div style="font-weight: bold; color: #fff; font-size: 15px; font-family: 'Orbitron', sans-serif;">${currentName} (You)</div>
                            <div style="font-size: 11px; color: var(--neon-gold); font-weight: bold; font-family: 'Orbitron', sans-serif;">UID: ${currentUid}</div>
                        </div>
                    </div>
                    <span style="color: var(--neon-green); font-size: 12px; font-weight: bold; font-family: 'Orbitron', sans-serif;">Rating: ${currentRating}</span>
                </div>
            `;
        } else {
            const mockBots = [
                { name: "HexRunner", uid: "84729103", rating: 1150, region: "🇺🇸 USA" },
                { name: "AeroBot", uid: "59201482", rating: 1280, region: "🇯🇵 JPN" },
                { name: "NeonDash", uid: "91823746", rating: 1340, region: "🇩🇪 DEU" },
                { name: "GridCrasher", uid: "38471920", rating: 1420, region: "🇮🇳 IND" }
            ];

            const foundBot = mockBots.find(b => b.uid === queryStr) || {
                name: `Rider_${queryStr.slice(0, 4)}`,
                uid: queryStr,
                rating: 1000 + (parseInt(queryStr.slice(-2), 10) || 10) * 5,
                region: "🌍 Global"
            };

            resultHTML = `
                <div style="display: flex; align-items: center; justify-content: space-between; padding: 12px; background: rgba(0,243,255,0.04); border: 1.5px solid var(--neon-cyan); border-radius: 10px; width: 100%; box-shadow: 0 0 10px rgba(0, 243, 255, 0.1);">
                    <div style="display: flex; align-items: center; gap: 12px;">
                        <div class="profile-avatar" style="width: 36px; height: 36px;">👤</div>
                        <div style="text-align: left;">
                            <div style="font-weight: bold; color: #fff; font-size: 15px; font-family: 'Orbitron', sans-serif;">${foundBot.name}</div>
                            <div style="font-size: 11px; color: var(--neon-gold); font-weight: bold; font-family: 'Orbitron', sans-serif;">UID: ${foundBot.uid} • ${foundBot.region}</div>
                        </div>
                    </div>
                    <button class="settings-btn" style="padding: 6px 12px; font-size: 12px; border-color: var(--neon-pink);" onclick="window.showToast('Challenge sent to ${foundBot.name}!', 'success')">Challenge</button>
                </div>
            `;
        }

        containers.forEach(c => {
            c.innerHTML = resultHTML;
        });
    }, 400);
}
window.searchPlayersByUID = searchPlayersByUID;

// --- RESET PROGRESS UTILITY ---
function resetGameProgress() {
    if (confirm("Are you sure you want to reset all game data (coins, levels, records)?")) {
        try {
            Object.values(window.KEYS || {}).forEach(k => localStorage.removeItem(k));
        } catch (e) {}
        showToast("Game data reset successfully!", "info");
        setTimeout(() => {
            window.location.reload();
        }, 600);
    }
}
window.resetGameProgress = resetGameProgress;

// --- ANDROID & WEB SCREEN ORIENTATION / FULLSCREEN INITIALIZATION ---
async function initAndroidMobileMode() {
    try {
        if (window.Capacitor && window.Capacitor.Plugins && window.Capacitor.Plugins.ScreenOrientation) {
            await window.Capacitor.Plugins.ScreenOrientation.lock({ orientation: 'landscape' });
        } else if (screen.orientation && typeof screen.orientation.lock === 'function') {
            await screen.orientation.lock('landscape').catch(() => {});
        }
    } catch (e) {
        console.warn("Screen orientation lock notice:", e);
    }

    try {
        if (window.Capacitor && window.Capacitor.Plugins && window.Capacitor.Plugins.StatusBar) {
            await window.Capacitor.Plugins.StatusBar.hide();
            await window.Capacitor.Plugins.StatusBar.setOverlaysWebView({ overlay: true });
        }
    } catch (e) {
        console.warn("StatusBar hide notice:", e);
    }
}
window.initAndroidMobileMode = initAndroidMobileMode;

window.addEventListener('DOMContentLoaded', () => {
    initAndroidMobileMode();
});

document.addEventListener('touchstart', () => {
    if (screen.orientation && typeof screen.orientation.lock === 'function') {
        screen.orientation.lock('landscape').catch(() => {});
    }
}, { passive: true });

// --- ANDROID NATIVE BACK BUTTON HANDLER ---
function handleAndroidBackButton() {
    // 1. Check if any modal is active
    const activeModals = Array.from(document.querySelectorAll('.modal-overlay.active'));
    if (activeModals.length > 0) {
        const pauseModal = document.getElementById('pause-modal');
        if (pauseModal && pauseModal.classList.contains('active')) {
            if (typeof window.resumeGame === 'function') {
                window.resumeGame();
            } else {
                pauseModal.classList.remove('active');
            }
            return;
        }

        const settingsOverlay = document.getElementById('settings-overlay');
        if (settingsOverlay && settingsOverlay.classList.contains('active')) {
            if (typeof window.closeSettingsOverlay === 'function') {
                window.closeSettingsOverlay();
            } else {
                settingsOverlay.classList.remove('active');
            }
            return;
        }

        activeModals.forEach(m => m.classList.remove('active'));
        if (typeof window.openMainMenu === 'function') {
            window.openMainMenu();
        }
        return;
    }

    // 2. Check game state
    const state = typeof window.currentGameState !== 'undefined' ? window.currentGameState : null;

    if (state === 'playing') {
        if (typeof window.pauseGame === 'function') {
            window.pauseGame();
        }
        return;
    }

    if (state === 'paused') {
        if (typeof window.resumeGame === 'function') {
            window.resumeGame();
        }
        return;
    }

    // 3. Check active screen
    const mainMenuScreen = document.getElementById('main-menu-screen');
    const isMainMenuVisible = mainMenuScreen && !mainMenuScreen.classList.contains('hidden');

    if (!isMainMenuVisible) {
        if (typeof window.openMainMenu === 'function') {
            window.openMainMenu();
        }
    } else {
        if (window.Capacitor && window.Capacitor.Plugins && window.Capacitor.Plugins.App) {
            window.Capacitor.Plugins.App.exitApp();
        }
    }
}
window.handleAndroidBackButton = handleAndroidBackButton;

// Attach listeners for native Capacitor backButton & browser popstate / keydown events
window.addEventListener('DOMContentLoaded', () => {
    if (window.Capacitor && window.Capacitor.Plugins && window.Capacitor.Plugins.App) {
        window.Capacitor.Plugins.App.addListener('backButton', () => {
            handleAndroidBackButton();
        });
    }
});

window.addEventListener('popstate', (e) => {
    e.preventDefault();
    handleAndroidBackButton();
});
