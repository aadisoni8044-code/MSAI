// --- MAIN RUNTIME INITIALIZER & CONTROLLER FOR SPEEDY ARROW ---

// Ensure data persistence is active and safe
console.log("[Speedy Arrow] Initializing Game Runtime...");

// --- SETTINGS CONTROLLER ---
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
        const isMuted = (typeof window.isMuted !== 'undefined') ? window.isMuted : false;
        const btn = document.getElementById('settings-audio-toggle');
        if (btn) {
            btn.innerHTML = isMuted ? '<span>🔇</span> AUDIO: OFF' : '<span>🔊</span> AUDIO: ON';
        }
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
                console.log("Fullscreen request info: ", err);
            });
        }
    } else {
        const exitFS = document.exitFullscreen || document.webkitExitFullscreen || document.mozCancelFullScreen || document.msExitFullscreen;
        if (exitFS) {
            exitFS.call(document).catch(err => {
                console.log("Exit fullscreen info: ", err);
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

// Reset All Saved Data (with safety confirmation)
function resetAllGameData() {
    if (confirm("Are you sure you want to reset all game progress, coins, and unlocks? This cannot be undone.")) {
        try {
            localStorage.clear();
            sessionStorage.clear();
            window.showToast("All progress reset! Reloading...", "info");
            setTimeout(() => {
                window.location.reload();
            }, 800);
        } catch (e) {
            console.error("Error clearing storage:", e);
        }
    }
}
window.resetAllGameData = resetAllGameData;

// --- CUSTOM UI TOAST NOTIFICATION SYSTEM ---
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

    setTimeout(() => {
        toast.classList.add('active');
    }, 20);

    setTimeout(() => {
        toast.classList.remove('active');
        setTimeout(() => {
            toast.remove();
        }, 250);
    }, 3200);
}
window.showToast = showToast;

// Safe alert override so native blocking alert dialogs never freeze canvas game loop
window.alert = function(msg) {
    let type = 'info';
    const lower = (msg || '').toString().toLowerCase();
    if (lower.includes('success') || lower.includes('welcome') || lower.includes('unlocked') || lower.includes('cleared')) {
        type = 'success';
    } else if (lower.includes('fail') || lower.includes('error') || lower.includes('not enough') || lower.includes('insufficient')) {
        type = 'error';
    } else if (lower.includes('login') || lower.includes('sign in') || lower.includes('warning') || lower.includes('please')) {
        type = 'warning';
    }
    window.showToast(msg, type);
};
