// Purge legacy data on page init
try {
    localStorage.clear();
    sessionStorage.clear();
    console.log("[Storage Purge] Absolute localStorage and sessionStorage purge complete on page init.");
} catch (e) {
    console.error("[Storage Purge] Error purging storage:", e);
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
