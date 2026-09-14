/* Menu Screens & Modal UI Manager */
class MenuManager {
    constructor() {
        // Screens & Modals
        this.mainMenu = document.getElementById('main-menu');
        this.levelModal = document.getElementById('level-select-modal');
        this.pauseMenu = document.getElementById('pause-menu');
        this.gameOverScreen = document.getElementById('game-over-screen');
        this.victoryScreen = document.getElementById('victory-screen');
        this.settingsModal = document.getElementById('settings-modal');
        this.controlsModal = document.getElementById('controls-modal');
        this.creditsModal = document.getElementById('credits-modal');

        // Buttons
        this.btnContinue = document.getElementById('btn-continue');
        this.btnPlay = document.getElementById('btn-play');
        this.btnLevelSelect = document.getElementById('btn-level-select');
        this.btnSettings = document.getElementById('btn-settings');
        this.btnControls = document.getElementById('btn-controls');
        this.btnCredits = document.getElementById('btn-credits');

        this.initListeners();
    }

    initListeners() {
        // Main Menu Button Binds
        if (this.btnPlay) {
            this.btnPlay.addEventListener('click', () => {
                window.game.startLevel(1);
            });
        }

        if (this.btnContinue) {
            this.btnContinue.addEventListener('click', () => {
                const saveLvl = window.saveSystem.data.currentLevel || 1;
                window.game.startLevel(saveLvl);
            });
        }

        if (this.btnLevelSelect) {
            this.btnLevelSelect.addEventListener('click', () => {
                this.renderLevelGrid();
                this.showScreen(this.levelModal);
            });
        }

        if (this.btnSettings) {
            this.btnSettings.addEventListener('click', () => {
                this.showScreen(this.settingsModal);
            });
        }

        if (this.btnControls) {
            this.btnControls.addEventListener('click', () => {
                this.showScreen(this.controlsModal);
            });
        }

        if (this.btnCredits) {
            this.btnCredits.addEventListener('click', () => {
                this.showScreen(this.creditsModal);
            });
        }

        // Close Buttons for Modals
        document.getElementById('btn-close-levels')?.addEventListener('click', () => this.hideModal());
        document.getElementById('btn-close-settings')?.addEventListener('click', () => this.hideModal());
        document.getElementById('btn-close-controls')?.addEventListener('click', () => this.hideModal());
        document.getElementById('btn-close-credits')?.addEventListener('click', () => this.hideModal());

        // Pause Menu Binds
        document.getElementById('btn-resume')?.addEventListener('click', () => window.game.resumeGame());
        document.getElementById('btn-restart-checkpoint')?.addEventListener('click', () => {
            window.game.startLevel(window.game.currentLevelIndex);
        });
        document.getElementById('btn-pause-settings')?.addEventListener('click', () => this.showScreen(this.settingsModal));
        document.getElementById('btn-pause-controls')?.addEventListener('click', () => this.showScreen(this.controlsModal));
        document.getElementById('btn-quit-main')?.addEventListener('click', () => this.showMainMenu());

        // Game Over & Victory Screen Binds
        document.getElementById('btn-restart-dead')?.addEventListener('click', () => {
            window.game.startLevel(window.game.currentLevelIndex);
        });
        document.getElementById('btn-dead-main')?.addEventListener('click', () => this.showMainMenu());

        document.getElementById('btn-next-level')?.addEventListener('click', () => {
            const nextLvl = window.game.currentLevelIndex + 1;
            window.game.startLevel(nextLvl <= 8 ? nextLvl : 1);
        });
        document.getElementById('btn-victory-main')?.addEventListener('click', () => this.showMainMenu());
    }

    updateContinueButton() {
        const unlocked = window.saveSystem.data.unlockedLevel || 1;
        if (this.btnContinue) {
            if (unlocked > 1 || window.saveSystem.data.currentLevel > 1) {
                this.btnContinue.removeAttribute('disabled');
                this.btnContinue.classList.remove('disabled');
            } else {
                this.btnContinue.setAttribute('disabled', 'true');
                this.btnContinue.classList.add('disabled');
            }
        }
    }

    showScreen(screen) {
        // Hide all screens
        const screens = [
            this.mainMenu, this.levelModal, this.pauseMenu,
            this.gameOverScreen, this.victoryScreen,
            this.settingsModal, this.controlsModal, this.creditsModal
        ];

        screens.forEach(s => s && s.classList.add('hidden'));

        if (screen) {
            screen.classList.remove('hidden');
        }
    }

    hideModal() {
        if (window.game && window.game.state === 'PLAYING') {
            this.showScreen(null);
        } else if (window.game && window.game.state === 'PAUSED') {
            this.showScreen(this.pauseMenu);
        } else {
            this.showMainMenu();
        }
    }

    showMainMenu() {
        if (window.game) window.game.state = 'MENU';
        window.hudManager.hideHUD();
        window.audioManager.startBgm('forest');
        this.updateContinueButton();
        this.showScreen(this.mainMenu);
    }

    showPauseMenu() {
        this.showScreen(this.pauseMenu);
    }

    showGameOver() {
        this.showScreen(this.gameOverScreen);
    }

    showVictory(stats) {
        document.getElementById('victory-crystals').textContent = `${stats.crystals} / ${stats.maxCrystals}`;
        document.getElementById('victory-coins').textContent = stats.coins;
        this.showScreen(this.victoryScreen);
    }

    renderLevelGrid() {
        const grid = document.getElementById('level-grid');
        if (!grid) return;

        grid.innerHTML = '';
        const levelNames = [
            'Ancient Forest', 'Misty Forest', 'Forgotten Ruins', 'Underground Cave',
            'Giant Tree', 'Dark Swamp', 'Forest Temple', 'Final Boss Area'
        ];

        const unlocked = window.saveSystem.data.unlockedLevel || 1;

        levelNames.forEach((name, idx) => {
            const lvlNum = idx + 1;
            const isUnlocked = lvlNum <= unlocked;

            const card = document.createElement('div');
            card.className = `level-card ${isUnlocked ? '' : 'locked'}`;
            card.innerHTML = `
                <div class="level-num">AREA 0${lvlNum}</div>
                <div class="level-name">${name}</div>
                <div class="level-status">${isUnlocked ? '🔓 UNLOCKED' : '🔒 LOCKED'}</div>
            `;

            if (isUnlocked) {
                card.addEventListener('click', () => {
                    window.game.startLevel(lvlNum);
                });
            }

            grid.appendChild(card);
        });
    }
}

window.menuManager = new MenuManager();
