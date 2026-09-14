/* SYLVAN WHISPERS - MAIN ENTRY POINT & DOM INTERACTION HANDLER */
window.addEventListener('load', () => {
    if (window.GameEngine) {
        window.GameEngine.init();
    }

    // MAIN MENU UI BUTTON BINDINGS
    const btnPlay = document.getElementById('btn-play');
    const btnContinue = document.getElementById('btn-continue');
    const btnNewGame = document.getElementById('btn-new-game');
    const btnHowToPlay = document.getElementById('btn-how-to-play');
    const btnSettings = document.getElementById('btn-settings');

    // MODAL BUTTONS
    const pauseBtnResume = document.getElementById('pause-btn-resume');
    const pauseBtnCheckpoint = document.getElementById('pause-btn-checkpoint');
    const pauseBtnSettings = document.getElementById('pause-btn-settings');
    const pauseBtnMenu = document.getElementById('pause-btn-menu');

    const gameoverBtnRespawn = document.getElementById('gameover-btn-respawn');
    const gameoverBtnMenu = document.getElementById('gameover-btn-menu');
    const victoryBtnMenu = document.getElementById('victory-btn-menu');

    const settingsBtnSave = document.getElementById('settings-btn-save');
    const howtoBtnClose = document.getElementById('howto-btn-close');

    // SETTINGS INPUT ELEMENTS
    const sliderMusic = document.getElementById('slider-music');
    const sliderSfx = document.getElementById('slider-sfx');
    const valMusic = document.getElementById('val-music');
    const valSfx = document.getElementById('val-sfx');
    const toggleTouch = document.getElementById('toggle-touch');
    const selectGraphics = document.getElementById('select-graphics');
    const btnFullscreen = document.getElementById('btn-fullscreen');

    // Check saved state for Continue button enable
    if (btnContinue && window.SaveManager) {
        if (window.SaveManager.hasSave()) {
            btnContinue.disabled = false;
        } else {
            btnContinue.disabled = true;
        }
    }

    // Sync UI with stored settings
    if (window.SettingsManager) {
        const s = window.SettingsManager.load();
        if (sliderMusic) { sliderMusic.value = s.musicVolume; if (valMusic) valMusic.textContent = s.musicVolume + '%'; }
        if (sliderSfx) { sliderSfx.value = s.sfxVolume; if (valSfx) valSfx.textContent = s.sfxVolume + '%'; }
        if (toggleTouch) toggleTouch.checked = s.touchControls;
        if (selectGraphics) selectGraphics.value = s.graphicsQuality;
    }

    // EVENT LISTENERS
    btnPlay?.addEventListener('click', () => {
        if (window.AudioManager) window.AudioManager.playClick();
        window.UIManager.showScreen('game-screen');
        if (window.SaveManager && window.SaveManager.hasSave()) {
            window.GameEngine.continueGame();
        } else {
            window.GameEngine.startNewGame();
        }
    });

    btnContinue?.addEventListener('click', () => {
        if (window.AudioManager) window.AudioManager.playClick();
        window.UIManager.showScreen('game-screen');
        window.GameEngine.continueGame();
    });

    btnNewGame?.addEventListener('click', () => {
        if (window.AudioManager) window.AudioManager.playClick();
        window.UIManager.showScreen('game-screen');
        window.GameEngine.startNewGame();
    });

    btnHowToPlay?.addEventListener('click', () => {
        if (window.AudioManager) window.AudioManager.playClick();
        window.UIManager.showModal('howto-modal');
    });

    btnSettings?.addEventListener('click', () => {
        if (window.AudioManager) window.AudioManager.playClick();
        window.UIManager.showModal('settings-modal');
    });

    pauseBtnResume?.addEventListener('click', () => {
        if (window.AudioManager) window.AudioManager.playClick();
        window.GameEngine.togglePause();
    });

    pauseBtnCheckpoint?.addEventListener('click', () => {
        if (window.AudioManager) window.AudioManager.playClick();
        window.UIManager.hideModal('pause-modal');
        window.GameEngine.respawnAtCheckpoint();
    });

    pauseBtnSettings?.addEventListener('click', () => {
        if (window.AudioManager) window.AudioManager.playClick();
        window.UIManager.showModal('settings-modal');
    });

    pauseBtnMenu?.addEventListener('click', () => {
        if (window.AudioManager) window.AudioManager.playClick();
        window.UIManager.hideModal('pause-modal');
        window.UIManager.showScreen('menu-screen');
        if (window.AudioManager) window.AudioManager.stopMusic();
    });

    gameoverBtnRespawn?.addEventListener('click', () => {
        if (window.AudioManager) window.AudioManager.playClick();
        window.GameEngine.respawnAtCheckpoint();
    });

    gameoverBtnMenu?.addEventListener('click', () => {
        if (window.AudioManager) window.AudioManager.playClick();
        window.UIManager.hideModal('gameover-modal');
        window.UIManager.showScreen('menu-screen');
        if (window.AudioManager) window.AudioManager.stopMusic();
    });

    victoryBtnMenu?.addEventListener('click', () => {
        if (window.AudioManager) window.AudioManager.playClick();
        window.UIManager.hideModal('victory-modal');
        window.UIManager.showScreen('menu-screen');
        if (window.AudioManager) window.AudioManager.stopMusic();
    });

    howtoBtnClose?.addEventListener('click', () => {
        if (window.AudioManager) window.AudioManager.playClick();
        window.UIManager.hideModal('howto-modal');
    });

    // SETTINGS LIVE EVENT HANDLERS
    sliderMusic?.addEventListener('input', (e) => {
        const val = e.target.value;
        if (valMusic) valMusic.textContent = val + '%';
        if (window.AudioManager) window.AudioManager.setMusicVolume(val / 100);
    });

    sliderSfx?.addEventListener('input', (e) => {
        const val = e.target.value;
        if (valSfx) valSfx.textContent = val + '%';
        if (window.AudioManager) window.AudioManager.setSfxVolume(val / 100);
    });

    settingsBtnSave?.addEventListener('click', () => {
        if (window.AudioManager) window.AudioManager.playClick();

        const newSettings = {
            musicVolume: parseInt(sliderMusic.value, 10),
            sfxVolume: parseInt(sliderSfx.value, 10),
            touchControls: toggleTouch.checked,
            graphicsQuality: selectGraphics.value
        };

        window.SettingsManager.save(newSettings);
        if (window.ParticleSystem) window.ParticleSystem.setQuality(newSettings.graphicsQuality);
        if (window.InputController) window.InputController.setTouchEnabled(newSettings.touchControls);

        window.UIManager.hideModal('settings-modal');
    });

    // FULLSCREEN TOGGLE
    btnFullscreen?.addEventListener('click', () => {
        if (!document.fullscreenElement) {
            document.documentElement.requestFullscreen().catch(err => {
                console.warn('Fullscreen request denied:', err);
            });
        } else {
            if (document.exitFullscreen) {
                document.exitFullscreen();
            }
        }
    });
});
