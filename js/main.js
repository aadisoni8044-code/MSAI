/* Game Application Entry Point */
window.addEventListener('DOMContentLoaded', () => {
    // Instantiate Main Engine Game Instance
    window.game = new window.Game();

    // Initialize Save Settings UI State
    const settings = window.saveSystem.data.settings;

    const musicSlider = document.getElementById('setting-music');
    const sfxSlider = document.getElementById('setting-sfx');
    const forceMobileCheck = document.getElementById('setting-mobile-controls');

    if (musicSlider) {
        musicSlider.value = settings.musicVolume;
        document.getElementById('music-val').textContent = `${settings.musicVolume}%`;
        window.audioManager.setMusicVolume(settings.musicVolume / 100);

        musicSlider.addEventListener('input', (e) => {
            const val = parseInt(e.target.value, 10);
            document.getElementById('music-val').textContent = `${val}%`;
            window.audioManager.setMusicVolume(val / 100);
            window.saveSystem.updateSettings({ musicVolume: val });
        });
    }

    if (sfxSlider) {
        sfxSlider.value = settings.sfxVolume;
        document.getElementById('sfx-val').textContent = `${settings.sfxVolume}%`;
        window.audioManager.setSfxVolume(settings.sfxVolume / 100);

        sfxSlider.addEventListener('input', (e) => {
            const val = parseInt(e.target.value, 10);
            document.getElementById('sfx-val').textContent = `${val}%`;
            window.audioManager.setSfxVolume(val / 100);
            window.saveSystem.updateSettings({ sfxVolume: val });
        });
    }

    if (forceMobileCheck) {
        forceMobileCheck.checked = settings.forceMobileControls;
        forceMobileCheck.addEventListener('change', (e) => {
            const isChecked = e.target.checked;
            window.saveSystem.updateSettings({ forceMobileControls: isChecked });
            window.mobileControls.updateVisibility();
        });
    }

    // Fullscreen Toggle
    document.getElementById('btn-toggle-fullscreen')?.addEventListener('click', () => {
        if (!document.fullscreenElement) {
            document.documentElement.requestFullscreen().catch((err) => {
                console.warn(`Error attempting to enable fullscreen: ${err.message}`);
            });
        } else {
            if (document.exitFullscreen) {
                document.exitFullscreen();
            }
        }
    });

    // Reset Progress Button
    document.getElementById('btn-reset-progress')?.addEventListener('click', () => {
        if (confirm('Are you sure you want to reset all saved game progress?')) {
            window.saveSystem.resetProgress();
            window.menuManager.showMainMenu();
            window.hudManager.showToast('PROGRESS RESET TO DEFAULT');
        }
    });

    // First user gesture to enable Web Audio Context
    const resumeAudioOnGesture = () => {
        window.audioManager.ensureContext();
        window.removeEventListener('click', resumeAudioOnGesture);
        window.removeEventListener('keydown', resumeAudioOnGesture);
        window.removeEventListener('touchstart', resumeAudioOnGesture);
    };

    window.addEventListener('click', resumeAudioOnGesture);
    window.addEventListener('keydown', resumeAudioOnGesture);
    window.addEventListener('touchstart', resumeAudioOnGesture);

    // Initial Menu Render
    window.menuManager.showMainMenu();

    // Start Main Render & Fixed Loop
    window.game.start();
});
