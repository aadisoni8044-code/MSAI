/* SYLVAN WHISPERS - CORE GAME ENGINE ORCHESTRATOR */
window.GameEngine = (function() {
    let canvas = null;
    let ctx = null;

    let currentState = 'MENU'; // 'MENU', 'PLAYING', 'PAUSED', 'GAME_OVER', 'VICTORY'
    let currentSectionIndex = 0;
    let currentSection = null;

    let player = null;
    let enemies = [];
    let collectiblesCount = 0;
    let totalOrbsSection = 25;

    let isRunning = false;
    let lastTime = 0;

    function init() {
        canvas = document.getElementById('game-canvas');
        if (!canvas) return;
        ctx = canvas.getContext('2d');

        window.InputController.init();
        window.UIManager.init();
        window.AudioManager.init();

        resizeCanvas();
        window.addEventListener('resize', resizeCanvas);

        // Load saved settings
        const settings = window.SettingsManager.load();
        window.ParticleSystem.setQuality(settings.graphicsQuality);
        window.InputController.setTouchEnabled(settings.touchControls);
        window.AudioManager.setMusicVolume(settings.musicVolume / 100);
        window.AudioManager.setSfxVolume(settings.sfxVolume / 100);

        // Initialize Camera
        window.Camera.init(canvas.width, canvas.height, 3200, 800);
    }

    function resizeCanvas() {
        if (!canvas) return;
        canvas.width = window.innerWidth;
        canvas.height = window.innerHeight;
        if (window.Camera) {
            window.Camera.setViewportSize(canvas.width, canvas.height);
        }
    }

    function loadSection(sectionIdx, customSpawnX = null, customSpawnY = null) {
        currentSectionIndex = sectionIdx;
        currentSection = window.LevelManager.getSection(sectionIdx);

        window.Camera.setWorldSize(currentSection.width, currentSection.height);

        const spawnX = customSpawnX !== null ? customSpawnX : currentSection.spawnX;
        const spawnY = customSpawnY !== null ? customSpawnY : currentSection.spawnY;

        if (!player) {
            player = new window.Player(spawnX, spawnY);
        } else {
            player.x = spawnX;
            player.y = spawnY;
            player.vx = 0;
            player.vy = 0;
        }

        // Spawn Enemies
        enemies = currentSection.enemies.map(e => new window.Enemy(e.type, e.x, e.y, e));

        // Spawn Section Fireflies & Leaves
        window.ParticleSystem.clear();
        window.ParticleSystem.spawnFireflies(currentSection.width, currentSection.height, 40);
        window.ParticleSystem.spawnFallingLeaves(currentSection.width, currentSection.height, 25);

        // Show Section announcement banner
        window.UIManager.showSectionBanner(currentSection.title, currentSection.subtitle);
    }

    function startNewGame() {
        window.SaveManager.reset();
        collectiblesCount = 0;
        player = null;
        loadSection(0);
        changeState('PLAYING');
        window.AudioManager.startMusic();
    }

    function continueGame() {
        const save = window.SaveManager.load();
        collectiblesCount = save.collectibles || 0;

        // Restore collected orbs status in level definitions
        if (save.collectedOrbs && Array.isArray(save.collectedOrbs)) {
            window.LevelManager.sections.forEach(sec => {
                sec.orbs.forEach(orb => {
                    if (save.collectedOrbs.includes(orb.id)) {
                        orb.collected = true;
                    }
                });
            });
        }

        player = null;
        loadSection(save.checkpointSection || 0, save.checkpointX, save.checkpointY);
        changeState('PLAYING');
        window.AudioManager.startMusic();
    }

    function startDirectGame() {
        if (window.SaveManager.hasSave()) {
            continueGame();
        } else {
            startNewGame();
        }
    }

    function togglePause() {
        if (currentState === 'PLAYING') {
            changeState('PAUSED');
            window.UIManager.showModal('pause-modal');
        } else if (currentState === 'PAUSED') {
            window.UIManager.hideModal('pause-modal');
            changeState('PLAYING');
        }
    }

    function changeState(newState) {
        currentState = newState;
        if (currentState === 'PLAYING' && !isRunning) {
            isRunning = true;
            lastTime = performance.now();
            requestAnimationFrame(gameLoop);
        }
    }

    // MAIN GAME LOOP
    function gameLoop(now) {
        if (currentState !== 'PLAYING' && currentState !== 'PAUSED') {
            isRunning = false;
            return;
        }

        const deltaTime = Math.min((now - lastTime) / 1000, 0.1);
        lastTime = now;

        if (currentState === 'PLAYING') {
            update(deltaTime);
        }

        render();

        requestAnimationFrame(gameLoop);
    }

    function update(dt) {
        if (!player || !currentSection) return;

        // Player update
        player.update(window.InputController, window.LevelManager);

        // Platform Collisions
        window.CollisionSystem.resolvePlayerPlatforms(player, currentSection.platforms);

        // Camera Update
        window.Camera.follow(player, dt);

        // Checkpoint Triggers
        currentSection.checkpoints.forEach(cp => {
            if (window.CollisionSystem.checkAABB(player, { x: cp.x, y: cp.y, width: 32, height: 48 })) {
                if (!cp.active) {
                    cp.active = true;
                    if (window.AudioManager) window.AudioManager.playCheckpoint();
                    if (window.ParticleSystem) window.ParticleSystem.spawnSparks(cp.x + 16, cp.y + 24, 20, '#4efce4');

                    // Save Progress at Checkpoint
                    window.SaveManager.save({
                        checkpointSection: currentSectionIndex,
                        checkpointX: cp.x,
                        checkpointY: cp.y,
                        collectibles: collectiblesCount,
                        collectedOrbs: getCollectedOrbsList()
                    });
                }
            }
        });

        // Collectibles (Lumina Orbs)
        currentSection.orbs.forEach(orb => {
            if (!orb.collected && window.CollisionSystem.checkAABB(player, { x: orb.x - 12, y: orb.y - 12, width: 24, height: 24 })) {
                orb.collected = true;
                collectiblesCount++;
                if (window.AudioManager) window.AudioManager.playCoin();
                if (window.ParticleSystem) window.ParticleSystem.spawnSparks(orb.x, orb.y, 12, '#4efce4');
                window.SaveManager.save({ collectibles: collectiblesCount, collectedOrbs: getCollectedOrbsList() });
            }
        });

        // Tablet Interactions
        let nearTablet = false;
        currentSection.tablets.forEach(tab => {
            if (Math.hypot(player.x - tab.x, player.y - tab.y) < 60) {
                nearTablet = true;
                window.UIManager.showInteraction('Read Ancient Tablet');
            }
        });
        if (!nearTablet) window.UIManager.hideInteraction();

        // Portal / Next Section Transition
        if (currentSection.nextPortal) {
            const portal = currentSection.nextPortal;
            if (window.CollisionSystem.checkAABB(player, { x: portal.x, y: portal.y - 40, width: 60, height: 100 })) {
                if (portal.isFinalVictory) {
                    changeState('VICTORY');
                    document.getElementById('final-orbs').textContent = collectiblesCount;
                    window.UIManager.showModal('victory-modal');
                } else {
                    loadSection(portal.targetSection);
                }
            }
        }

        // Hazard Collisions (Abyss / Spikes)
        currentSection.hazards.forEach(haz => {
            if (window.CollisionSystem.checkAABB(player, haz)) {
                if (haz.type === 'abyss') {
                    player.health = 0;
                } else {
                    player.takeDamage(20);
                }
            }
        });

        // Player Death Check
        if (player.health <= 0) {
            changeState('GAME_OVER');
            window.UIManager.showModal('gameover-modal');
            return;
        }

        // Enemies Update & Combat Collision
        enemies.forEach(enemy => {
            enemy.update(player, window.CollisionSystem, currentSection.platforms);

            // Player Attack hits Enemy
            if (player.attackHitbox && !enemy.isDead) {
                if (window.CollisionSystem.checkAABB(player.attackHitbox, enemy)) {
                    enemy.takeDamage(35);
                }
            }

            // Enemy hits Player
            if (!enemy.isDead && window.CollisionSystem.checkAABB(player, enemy)) {
                player.takeDamage(enemy.damage);
            }
        });

        // Particle System update
        window.ParticleSystem.update();

        // HUD update
        window.UIManager.updateHUD(player.health, player.maxHealth, player.stamina, player.maxStamina, collectiblesCount, totalOrbsSection);
    }

    function getCollectedOrbsList() {
        const list = [];
        window.LevelManager.sections.forEach(sec => {
            sec.orbs.forEach(orb => {
                if (orb.collected) list.push(orb.id);
            });
        });
        return list;
    }

    // SCENIC PARALLAX RENDER PIPELINE (5 LAYERS)
    function render() {
        if (!ctx || !currentSection) return;

        const camX = window.Camera.getRenderX();
        const camY = window.Camera.getRenderY();
        const theme = currentSection.theme;

        // LAYER 1: Deep Sky & Far Parallax Gradient
        const skyGrad = ctx.createLinearGradient(0, 0, 0, canvas.height);
        skyGrad.addColorStop(0, theme.skyTop);
        skyGrad.addColorStop(1, theme.skyBottom);
        ctx.fillStyle = skyGrad;
        ctx.fillRect(0, 0, canvas.width, canvas.height);

        // LAYER 2: Distant Forest Silhouette Trees (0.2x speed)
        ctx.save();
        ctx.fillStyle = 'rgba(8, 23, 29, 0.7)';
        const distOffX = camX * 0.2;
        for (let i = -100; i < currentSection.width; i += 180) {
            const screenX = i - distOffX;
            ctx.beginPath();
            ctx.moveTo(screenX, canvas.height);
            ctx.lineTo(screenX + 40, canvas.height - 350);
            ctx.lineTo(screenX + 80, canvas.height);
            ctx.fill();
        }
        ctx.restore();

        // LAYER 3: Middle Canopy & Giant Ancient Trees (0.5x speed)
        ctx.save();
        ctx.fillStyle = theme.treeBark;
        const midOffX = camX * 0.5;
        for (let i = -50; i < currentSection.width; i += 380) {
            const screenX = i - midOffX;
            // Giant Trunk inspired by uploaded reference art
            ctx.beginPath();
            ctx.moveTo(screenX, canvas.height);
            ctx.bezierCurveTo(screenX + 20, canvas.height - 300, screenX - 40, canvas.height - 500, screenX + 30, 0);
            ctx.lineTo(screenX + 110, 0);
            ctx.bezierCurveTo(screenX + 60, canvas.height - 500, screenX + 130, canvas.height - 300, screenX + 140, canvas.height);
            ctx.fill();
        }
        ctx.restore();

        // Atmospheric Light Rays (Inspired by reference screenshot)
        ctx.save();
        ctx.fillStyle = theme.fogColor;
        ctx.beginPath();
        ctx.moveTo(canvas.width * 0.3 - camX * 0.1, 0);
        ctx.lineTo(canvas.width * 0.6 - camX * 0.1, canvas.height);
        ctx.lineTo(canvas.width * 0.45 - camX * 0.1, canvas.height);
        ctx.lineTo(canvas.width * 0.15 - camX * 0.1, 0);
        ctx.fill();
        ctx.restore();

        // LAYER 4: Playable Environment (1.0x speed)
        // Draw Platforms
        currentSection.platforms.forEach(plat => {
            const px = plat.x - camX;
            const py = plat.y - camY;

            if (px < -300 || px > canvas.width + 300) return;

            if (plat.type === 'ground') {
                // Dark Teal Ground Fill
                ctx.fillStyle = '#0f2930';
                ctx.fillRect(px, py, plat.width, plat.height);

                // Top Moss Grass Layer (Visual match to reference green moss edge)
                ctx.fillStyle = '#22c55e';
                ctx.fillRect(px, py, plat.width, 8);
                ctx.fillStyle = '#14b8a6';
                ctx.fillRect(px, py + 8, plat.width, 6);
            } else {
                // Wooden / Stone Platform
                ctx.fillStyle = '#1b3a42';
                ctx.fillRect(px, py, plat.width, plat.height);
                ctx.fillStyle = theme.accentLight;
                ctx.fillRect(px, py, plat.width, 4);
            }
        });

        // Draw Checkpoints
        currentSection.checkpoints.forEach(cp => {
            const cx = cp.x - camX;
            const cy = cp.y - camY;
            ctx.save();
            ctx.fillStyle = cp.active ? '#4efce4' : '#64748b';
            ctx.shadowColor = cp.active ? '#4efce4' : 'transparent';
            ctx.shadowBlur = cp.active ? 15 : 0;
            ctx.fillRect(cx + 12, cy, 8, 48);
            ctx.beginPath();
            ctx.arc(cx + 16, cy, 12, 0, Math.PI * 2);
            ctx.fill();
            ctx.restore();
        });

        // Draw Collectibles (Lumina Orbs)
        currentSection.orbs.forEach(orb => {
            if (orb.collected) return;
            const ox = orb.x - camX;
            const oy = orb.y - camY;

            ctx.save();
            ctx.fillStyle = '#4efce4';
            ctx.shadowColor = '#4efce4';
            ctx.shadowBlur = 12;
            ctx.beginPath();
            ctx.arc(ox, oy, 8, 0, Math.PI * 2);
            ctx.fill();
            ctx.restore();
        });

        // Draw Ancient Tablets
        currentSection.tablets.forEach(tab => {
            const tx = tab.x - camX;
            const ty = tab.y - camY;
            ctx.fillStyle = '#334155';
            ctx.fillRect(tx, ty - 30, 24, 30);
            ctx.fillStyle = '#94a3b8';
            ctx.fillRect(tx + 4, ty - 24, 16, 4);
        });

        // Draw Portal (Section Exit)
        if (currentSection.nextPortal) {
            const p = currentSection.nextPortal;
            const px = p.x - camX;
            const py = p.y - camY;

            ctx.save();
            ctx.fillStyle = 'rgba(78, 252, 228, 0.2)';
            ctx.strokeStyle = '#4efce4';
            ctx.lineWidth = 3;
            ctx.shadowColor = '#4efce4';
            ctx.shadowBlur = 20;
            ctx.beginPath();
            ctx.ellipse(px + 30, py - 30, 24, 45, 0, 0, Math.PI * 2);
            ctx.fill();
            ctx.stroke();
            ctx.restore();
        }

        // Draw Enemies
        enemies.forEach(enemy => enemy.draw(ctx, window.Camera));

        // Draw Player
        if (player) player.draw(ctx, window.Camera);

        // Draw Particles (Fireflies, Dust, Sparks, Leaves)
        window.ParticleSystem.draw(ctx, window.Camera);

        // LAYER 5: Dark Foreground Plant Silhouettes (1.3x speed parallax)
        ctx.save();
        ctx.fillStyle = '#030a0d';
        const foreOffX = camX * 1.3;
        for (let i = -100; i < currentSection.width; i += 220) {
            const screenX = i - foreOffX;
            if (screenX > -100 && screenX < canvas.width + 100) {
                // Foreground hanging vines & dark grass bushes
                ctx.beginPath();
                ctx.arc(screenX, canvas.height + 20, 45, 0, Math.PI, true);
                ctx.fill();
            }
        }
        ctx.restore();
    }

    function respawnAtCheckpoint() {
        const save = window.SaveManager.load();
        loadSection(save.checkpointSection || currentSectionIndex, save.checkpointX, save.checkpointY);
        if (player) {
            player.health = player.maxHealth;
            player.stamina = player.maxStamina;
        }
        window.UIManager.hideModal('gameover-modal');
        changeState('PLAYING');
    }

    return {
        init,
        startNewGame,
        continueGame,
        startDirectGame,
        togglePause,
        loadSection,
        respawnAtCheckpoint
    };
})();
