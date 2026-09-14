/* Main Game Loop Engine & State Manager */
class Game {
    constructor() {
        this.canvas = document.getElementById('game-canvas');
        this.ctx = this.canvas.getContext('2d');

        this.state = 'MENU'; // MENU, PLAYING, PAUSED, GAME_OVER, VICTORY
        this.lastTime = 0;
        this.accumulator = 0;
        this.fixedStep = 1 / 60;

        this.viewportWidth = window.innerWidth;
        this.viewportHeight = window.innerHeight;

        this.camera = new Camera(this.viewportWidth, this.viewportHeight);
        this.particles = new ParticleSystem(500);

        this.player = null;
        this.level = null;
        this.currentLevelIndex = 1;

        this.initViewport();
        this.initEvents();
    }

    initViewport() {
        const resize = () => {
            this.viewportWidth = window.innerWidth;
            this.viewportHeight = window.innerHeight;
            this.canvas.width = this.viewportWidth;
            this.canvas.height = this.viewportHeight;
            this.camera.resize(this.viewportWidth, this.viewportHeight);
        };

        window.addEventListener('resize', resize);
        resize();
    }

    initEvents() {
        // Keyboard Pause
        window.addEventListener('keydown', (e) => {
            if (e.code === 'Escape') {
                if (this.state === 'PLAYING') {
                    this.pauseGame();
                } else if (this.state === 'PAUSED') {
                    this.resumeGame();
                }
            }
        });
    }

    startLevel(levelIndex = 1) {
        this.currentLevelIndex = levelIndex;
        window.saveSystem.setCurrentLevel(levelIndex);

        // Fetch level constructor
        const LevelClass = window[`Level${String(levelIndex).padStart(2, '0')}`];
        if (!LevelClass) {
            console.error(`Level ${levelIndex} not found! Loading default Forest01.`);
            this.level = new window.Level01();
        } else {
            this.level = new LevelClass();
        }

        this.camera.setLevelBounds(this.level.width, this.level.height);

        // Instantiate Player
        this.player = new window.Player(this.level.spawnX, this.level.spawnY);

        // Connect level & entities
        this.level.initLevel(this.player, this.particles);

        // Update HUD
        window.hudManager.updateObjective(this.level.objective || 'Explore the area');
        window.hudManager.hideBossHealth();

        // Audio
        window.audioManager.startBgm(this.level.isBossLevel ? 'boss' : 'forest');

        this.state = 'PLAYING';
        window.menuManager.showScreen(null); // Hide menu overlays
        window.hudManager.showHUD();
    }

    pauseGame() {
        if (this.state === 'PLAYING') {
            this.state = 'PAUSED';
            window.menuManager.showPauseMenu();
        }
    }

    resumeGame() {
        if (this.state === 'PAUSED') {
            this.state = 'PLAYING';
            window.menuManager.hideModal();
        }
    }

    triggerGameOver() {
        this.state = 'GAME_OVER';
        window.audioManager.stopBgm();
        window.audioManager.playHit();
        window.menuManager.showGameOver();
    }

    triggerVictory() {
        this.state = 'VICTORY';
        window.audioManager.stopBgm();
        window.audioManager.playVictory();

        // Unlock next level
        window.saveSystem.unlockLevel(this.currentLevelIndex + 1);

        window.menuManager.showVictory({
            crystals: this.level.collectedCrystals || 0,
            maxCrystals: this.level.totalCrystals || 0,
            coins: this.level.collectedCoins || 0
        });
    }

    start() {
        this.lastTime = performance.now();
        requestAnimationFrame((time) => this.loop(time));
    }

    loop(currentTime) {
        const dt = Math.min((currentTime - this.lastTime) / 1000, 0.1);
        this.lastTime = currentTime;

        if (this.state === 'PLAYING') {
            this.accumulator += dt;
            while (this.accumulator >= this.fixedStep) {
                this.update(this.fixedStep);
                this.accumulator -= this.fixedStep;
            }
        }

        this.render();
        requestAnimationFrame((time) => this.loop(time));
    }

    update(dt) {
        window.inputHandler.update();

        if (this.player) {
            this.player.update(dt, this.level);
            this.camera.follow(this.player, dt);
        }

        if (this.level) {
            this.level.update(dt, this.player);
        }

        this.particles.update(dt);
        window.hudManager.update(this.player);
    }

    render() {
        // Clear canvas
        this.ctx.clearRect(0, 0, this.viewportWidth, this.viewportHeight);

        const cameraOffset = this.camera.getRenderOffset();

        if (this.level) {
            // Render parallax background
            this.level.renderBackground(this.ctx, cameraOffset, this.viewportWidth, this.viewportHeight);

            // Render tilemap & world objects
            this.level.renderWorld(this.ctx, cameraOffset);
        }

        // Render Particles
        this.particles.render(this.ctx, cameraOffset);

        if (this.player) {
            this.player.render(this.ctx, cameraOffset);
        }

        if (this.level) {
            // Foreground decoration & fog layer
            this.level.renderForeground(this.ctx, cameraOffset, this.viewportWidth, this.viewportHeight);
        }
    }
}

window.Game = Game;
