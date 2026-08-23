// ============================================================================
// Speedy Arrow - Core Game Engine & Physics Architecture
// ============================================================================

const STATE_MENU = 'menu';
const STATE_LEVEL_SELECT = 'level_select';
const STATE_PLAYING = 'playing';
const STATE_PAUSED = 'paused';
const STATE_GAMEOVER = 'gameover';
const STATE_VICTORY = 'victory';

let currentGameState = STATE_MENU;
let currentGameMode = 'classic'; // 'classic', 'endless', 'race'
let currentLevel = 1;
let attemptCount = 1;
let isMuted = false;

// Virtual Gameplay Dimensions (16:9)
const width = 1200;
const height = 675;

let canvas = null;
let ctx = null;
let scale = 1;
let offsetX = 0;
let offsetY = 0;

// Timing & Physics Delta
let lastTime = 0;
let deltaTime = 0;

// Input system
const inputs = {
    active: false,
    space: false,
    up: false,
    pointer: false
};

// Parallax & Background
let bgScrollX = 0;
let bgScrollY = 0;
let hexPatternCanvas = null;
const hexPatternWidth = 256;
const hexPatternHeight = 256;

// Trackers
let levelProgress = 0; // 0 to 100
let levelCoinsCollected = 0;
let endlessDistance = 0;
let screenShake = 0;

// Ambient particles & Collectibles
let ambientParticles = [];
let obstacles = [];
let collectibles = []; // floating coins
let levelLength = 5000;
let currentPracticeCheckpoint = null;

// Bot competitors for Race Mode
let bots = [];

// Player object
const player = {
    x: 150,
    y: 337.5,
    width: 32,
    height: 24,
    vy: 0,
    targetVy: 0,
    angle: 0,
    baseSpeed: 420,
    speedMultiplier: 1,
    isDead: false,
    trail: [],
    particles: [],
    hasCrashedThisRun: false,
    gravityFlipped: false
};

// Camera tracking
const camera = {
    x: 0,
    y: 0,
    targetY: 0
};

// --- AUDIO SYNTHESIZER (WEB AUDIO API) ---
let audioCtx = null;
let synthIntervalId = null;
let synthStep = 0;

function initAudioContext() {
    if (!audioCtx) {
        const AudioClass = window.AudioContext || window.webkitAudioContext;
        if (AudioClass) {
            audioCtx = new AudioClass();
        }
    }
    if (audioCtx && audioCtx.state === 'suspended') {
        audioCtx.resume();
    }
}

// --- INITIALIZATION ON PAGE LOAD ---
window.addEventListener('load', () => {
    canvas = document.getElementById('gameCanvas');
    if (canvas) {
        ctx = canvas.getContext('2d');
        initCanvas();
        createHexagonPattern();
        initInputListeners();
    }

    if (typeof window.initUI === 'function') {
        window.initUI();
    }

    // Initialize audio on first user gesture
    const startAudioGesture = () => {
        initAudioContext();
        document.removeEventListener('click', startAudioGesture);
        document.removeEventListener('touchstart', startAudioGesture);
        document.removeEventListener('keydown', startAudioGesture);
    };
    document.addEventListener('click', startAudioGesture);
    document.addEventListener('touchstart', startAudioGesture);
    document.addEventListener('keydown', startAudioGesture);

    // Start main game animation loop
    requestAnimationFrame(gameLoop);
});

window.addEventListener('resize', () => {
    if (canvas) initCanvas();
});

function initCanvas() {
    const container = document.getElementById('game-container');
    if (!container || !canvas) return;

    const rect = container.getBoundingClientRect();
    const dpr = Math.min(window.devicePixelRatio || 1, 2);

    canvas.width = rect.width * dpr;
    canvas.height = rect.height * dpr;
    canvas.style.width = `${rect.width}px`;
    canvas.style.height = `${rect.height}px`;

    // Compute aspect scaling
    const targetAspect = width / height;
    const currentAspect = rect.width / rect.height;

    if (currentAspect > targetAspect) {
        scale = (rect.height / height) * dpr;
        offsetX = ((rect.width * dpr) - (width * scale)) / 2;
        offsetY = 0;
    } else {
        scale = (rect.width / width) * dpr;
        offsetX = 0;
        offsetY = ((rect.height * dpr) - (height * scale)) / 2;
    }
}

// --- PROCEDURAL BACKGROUND GRID ---
function createHexagonPattern() {
    hexPatternCanvas = document.createElement('canvas');
    hexPatternCanvas.width = hexPatternWidth;
    hexPatternCanvas.height = hexPatternHeight;
    const hCtx = hexPatternCanvas.getContext('2d');

    hCtx.fillStyle = '#020606';
    hCtx.fillRect(0, 0, hexPatternWidth, hexPatternHeight);

    const r = 24;
    const h = r * Math.sqrt(3);
    const w = r * 1.5;

    hCtx.strokeStyle = 'rgba(0, 243, 255, 0.07)';
    hCtx.lineWidth = 1.2;

    for (let x = -r; x < hexPatternWidth + r * 2; x += r * 3) {
        for (let y = -r; y < hexPatternHeight + r * 2; y += h) {
            drawHexPath(hCtx, x, y, r);
            hCtx.stroke();

            drawHexPath(hCtx, x + w, y + h / 2, r);
            hCtx.stroke();
        }
    }
}

function drawHexPath(context, x, y, radius) {
    context.beginPath();
    for (let i = 0; i < 6; i++) {
        const angle = (i * Math.PI) / 3;
        const px = x + radius * Math.cos(angle);
        const py = y + radius * Math.sin(angle);
        if (i === 0) context.moveTo(px, py);
        else context.lineTo(px, py);
    }
    context.closePath();
}

// --- INPUT LISTENERS ---
function initInputListeners() {
    window.addEventListener('keydown', (e) => {
        if (e.code === 'Space' || e.code === 'ArrowUp' || e.code === 'KeyW') {
            inputs.space = true;
            inputs.active = true;
            e.preventDefault();
        }
        if (e.code === 'Escape' || e.code === 'KeyP') {
            if (currentGameState === STATE_PLAYING) {
                pauseGame();
            } else if (currentGameState === STATE_PAUSED) {
                resumeGame();
            }
        }
        if (e.code === 'KeyR') {
            if (currentGameState === STATE_PLAYING || currentGameState === STATE_GAMEOVER) {
                restartLevel();
            }
        }
        if (e.code === 'KeyZ' || e.code === 'KeyC') {
            const chk = document.getElementById('practice-mode-chk');
            if (chk && chk.checked) {
                placeCheckpoint();
            }
        }
        if (e.code === 'KeyX') {
            const chk = document.getElementById('practice-mode-chk');
            if (chk && chk.checked) {
                clearCheckpoints();
            }
        }
    });

    window.addEventListener('keyup', (e) => {
        if (e.code === 'Space' || e.code === 'ArrowUp' || e.code === 'KeyW') {
            inputs.space = false;
            inputs.active = inputs.pointer;
        }
    });

    const overlay = document.getElementById('input-overlay');
    if (overlay) {
        const setPress = (val, e) => {
            if (e) e.preventDefault();
            inputs.pointer = val;
            inputs.active = inputs.space || inputs.pointer;
        };

        overlay.addEventListener('mousedown', (e) => setPress(true, e));
        window.addEventListener('mouseup', () => setPress(false));
        overlay.addEventListener('touchstart', (e) => setPress(true, e), { passive: false });
        overlay.addEventListener('touchend', (e) => setPress(false, e), { passive: false });
        overlay.addEventListener('touchcancel', (e) => setPress(false, e), { passive: false });
    }
}

// --- GAME STATE MANAGER ---
function setGameState(newState) {
    currentGameState = newState;

    const screens = {
        [STATE_MENU]: 'main-menu-screen',
        [STATE_LEVEL_SELECT]: 'level-select-screen'
    };

    document.querySelectorAll('.screen').forEach(s => s.classList.add('hidden'));
    const hud = document.getElementById('hud');
    if (hud) hud.classList.remove('active');
    hideAllModals();

    if (screens[newState]) {
        const scr = document.getElementById(screens[newState]);
        if (scr) scr.classList.remove('hidden');
    }

    const overlay = document.getElementById('input-overlay');

    if (newState === STATE_PLAYING) {
        if (hud) hud.classList.add('active');
        if (overlay) overlay.classList.remove('hidden');
        startSynthMusic();
    } else {
        stopSynthMusic();
        if (overlay) overlay.classList.add('hidden');
    }
}
window.setGameState = setGameState;

function hideAllModals() {
    document.querySelectorAll('.modal-overlay').forEach(m => m.classList.remove('active'));
}

// --- LEVEL LAUNCHERS ---
function launchClassicLevel(levelNum) {
    currentGameMode = 'classic';
    currentLevel = Math.max(1, Math.min(100, levelNum));
    attemptCount = 1;
    player.hasCrashedThisRun = false;
    currentPracticeCheckpoint = null;

    initGameElements();
    setGameState(STATE_PLAYING);
}
window.launchClassicLevel = launchClassicLevel;

function launchEndlessMode() {
    currentGameMode = 'endless';
    attemptCount = 1;
    player.hasCrashedThisRun = false;
    currentPracticeCheckpoint = null;

    initGameElements();
    setGameState(STATE_PLAYING);
}
window.launchEndlessMode = launchEndlessMode;

function launchRaceMode() {
    currentGameMode = 'race';
    attemptCount = 1;
    player.hasCrashedThisRun = false;
    currentPracticeCheckpoint = null;

    initGameElements();
    setGameState(STATE_PLAYING);
}
window.launchRaceMode = launchRaceMode;

// --- INITIALIZE LEVEL ELEMENTS ---
function initGameElements() {
    player.x = 150;
    player.y = 337.5;
    player.vy = 0;
    player.targetVy = 0;
    player.angle = 0;
    player.isDead = false;
    player.trail = [];
    player.particles = [];
    player.speedMultiplier = 1.0;
    player.gravityFlipped = false;
    levelCoinsCollected = 0;

    // Progressive speed scaling per level
    player.baseSpeed = 400 + (currentLevel * 2.0);

    const biome = getBiomeForLevel(currentLevel);
    if (currentGameMode === 'classic' && biome === 'water') {
        player.baseSpeed *= 0.88; // water resistance
    }

    camera.x = 0;
    camera.y = 0;
    camera.targetY = 0;
    screenShake = 0;

    // Generate Obstacles & Coins
    generateLevelContent();

    // Race bots
    initRaceBots();

    // Ambient atmosphere
    initAmbientDecorations();

    // Practice mode checkpoint respawn
    const chk = document.getElementById('practice-mode-chk');
    if (chk && chk.checked && currentPracticeCheckpoint) {
        player.x = currentPracticeCheckpoint.x;
        player.y = currentPracticeCheckpoint.y;
        player.vy = currentPracticeCheckpoint.vy;
        camera.x = player.x - 220;
    }
}

function getBiomeForLevel(lvl) {
    if (currentGameMode !== 'classic') {
        return window.UI_STATE ? window.UI_STATE.activeBiome : 'forest';
    }
    if (lvl <= 20) return 'forest';
    if (lvl <= 40) return 'haunted';
    if (lvl <= 60) return 'space';
    if (lvl <= 80) return 'water';
    return 'ancient';
}

function generateLevelContent() {
    obstacles = [];
    collectibles = [];
    levelProgress = 0;

    const biome = getBiomeForLevel(currentLevel);
    const biomeColors = {
        forest: 'rgba(0, 255, 102, 0.9)',
        haunted: 'rgba(176, 38, 255, 0.9)',
        space: 'rgba(0, 243, 255, 0.9)',
        water: 'rgba(255, 0, 127, 0.9)',
        ancient: 'rgba(255, 170, 0, 0.9)'
    };
    const obsColor = biomeColors[biome] || 'rgba(0, 243, 255, 0.9)';

    if (currentGameMode === 'classic') {
        levelLength = 4800 + (currentLevel * 90);

        // Starting gate
        obstacles.push({
            type: 'gate',
            x: 350,
            y: 40,
            width: 16,
            height: height - 80,
            color: '#ffffff'
        });

        let cursorX = 650;
        const seed = currentLevel * 997 + 101;
        let randVal = Math.sin(seed) * 10000;
        const getRand = () => {
            randVal = Math.sin(randVal) * 10000;
            return randVal - Math.floor(randVal);
        };

        const difficulty = currentLevel / 100; // 0 to 1

        while (cursorX < levelLength - 700) {
            const roll = getRand();
            const gapSpacing = Math.max(160, 310 - (difficulty * 110));

            // Floating coin in gaps
            if (getRand() < 0.45) {
                collectibles.push({
                    x: cursorX + 80,
                    y: 180 + getRand() * 300,
                    radius: 12,
                    collected: false
                });
            }

            if (roll < 0.28) {
                // Spike Cluster (ceiling or floor)
                const isCeiling = getRand() < 0.5;
                const count = Math.floor(getRand() * 3) + 1 + Math.floor(difficulty * 2);
                const spikeSpacing = 42;

                for (let i = 0; i < count; i++) {
                    obstacles.push({
                        type: 'spike',
                        x: cursorX + i * spikeSpacing,
                        y: isCeiling ? 40 : height - 40,
                        width: 40,
                        height: 52,
                        dir: isCeiling ? 1 : -1,
                        color: obsColor
                    });
                }
                cursorX += (count * spikeSpacing) + gapSpacing;

            } else if (roll < 0.56) {
                // Double Gate / Column Corridors
                const gapY = 190 + getRand() * 200;
                const minGap = Math.max(140, 240 - (difficulty * 80));

                obstacles.push({
                    type: 'block',
                    x: cursorX,
                    y: 40,
                    width: 70 + getRand() * 60,
                    height: gapY - minGap / 2 - 40,
                    color: obsColor
                });

                obstacles.push({
                    type: 'block',
                    x: cursorX,
                    y: gapY + minGap / 2,
                    width: 70 + getRand() * 60,
                    height: (height - 40) - (gapY + minGap / 2),
                    color: obsColor
                });

                cursorX += 130 + gapSpacing;

            } else if (roll < 0.78) {
                // Rotating Neon Sawblade / Hazard Buzzsaw!
                const sawY = 180 + getRand() * 260;
                const sawRadius = 32 + getRand() * 16;
                obstacles.push({
                    type: 'saw',
                    x: cursorX + 40,
                    y: sawY,
                    radius: sawRadius,
                    angle: 0,
                    spinSpeed: (getRand() > 0.5 ? 1 : -1) * (3.5 + getRand() * 3),
                    color: biome === 'water' ? '#ff007f' : biome === 'ancient' ? '#ffaa00' : '#00f3ff'
                });
                cursorX += 140 + gapSpacing;

            } else {
                // Floating Diamond Block
                const blockY = 180 + getRand() * 200;
                const blockW = 80 + getRand() * 90;
                const blockH = 65 + getRand() * 70;

                obstacles.push({
                    type: 'block',
                    x: cursorX,
                    y: blockY,
                    width: blockW,
                    height: blockH,
                    color: obsColor
                });
                cursorX += blockW + gapSpacing;
            }
        }
    } else {
        // Endless Mode procedural initial buffer
        levelLength = 99999999;
        generateEndlessBuffer(0, 30000, biome, obsColor);
    }
}

function generateEndlessBuffer(startX, length, biome, obsColor) {
    let cursorX = Math.max(startX, 600);
    const endX = startX + length;

    while (cursorX < endX) {
        const roll = Math.random();
        const difficulty = Math.min(1.0, cursorX / 25000);
        const gapSpacing = Math.max(160, 290 - (difficulty * 100));

        if (Math.random() < 0.5) {
            collectibles.push({
                x: cursorX + 70,
                y: 160 + Math.random() * 320,
                radius: 12,
                collected: false
            });
        }

        if (roll < 0.3) {
            const isCeiling = Math.random() < 0.5;
            const count = Math.floor(Math.random() * 3) + 1 + Math.floor(difficulty * 2);
            const spikeSpacing = 42;

            for (let i = 0; i < count; i++) {
                obstacles.push({
                    type: 'spike',
                    x: cursorX + i * spikeSpacing,
                    y: isCeiling ? 40 : height - 40,
                    width: 40,
                    height: 52,
                    dir: isCeiling ? 1 : -1,
                    color: obsColor
                });
            }
            cursorX += (count * spikeSpacing) + gapSpacing;

        } else if (roll < 0.6) {
            const gapY = 180 + Math.random() * 220;
            const minGap = Math.max(140, 230 - (difficulty * 70));

            obstacles.push({
                type: 'block',
                x: cursorX,
                y: 40,
                width: 75 + Math.random() * 70,
                height: gapY - minGap / 2 - 40,
                color: obsColor
            });

            obstacles.push({
                type: 'block',
                x: cursorX,
                y: gapY + minGap / 2,
                width: 75 + Math.random() * 70,
                height: (height - 40) - (gapY + minGap / 2),
                color: obsColor
            });
            cursorX += 140 + gapSpacing;

        } else if (roll < 0.8) {
            const sawY = 180 + Math.random() * 260;
            obstacles.push({
                type: 'saw',
                x: cursorX + 40,
                y: sawY,
                radius: 34 + Math.random() * 14,
                angle: 0,
                spinSpeed: (Math.random() > 0.5 ? 1 : -1) * (4 + Math.random() * 3),
                color: '#ff007f'
            });
            cursorX += 130 + gapSpacing;
        } else {
            const blockY = 180 + Math.random() * 200;
            const blockW = 80 + Math.random() * 90;
            const blockH = 70 + Math.random() * 80;

            obstacles.push({
                type: 'block',
                x: cursorX,
                y: blockY,
                width: blockW,
                height: blockH,
                color: obsColor
            });
            cursorX += blockW + gapSpacing;
        }
    }
}

// --- AMBIENT PARTICLES ---
function initAmbientDecorations() {
    ambientParticles = [];
    const count = 30;
    const biome = getBiomeForLevel(currentLevel);

    for (let i = 0; i < count; i++) {
        ambientParticles.push(createAmbientParticle(Math.random() * width, biome));
    }
}

function createAmbientParticle(forceX = null, biome = 'forest') {
    const pX = forceX !== null ? forceX : camera.x + width + Math.random() * 100;
    const pY = 44 + Math.random() * (height - 88);

    const p = {
        x: pX,
        y: pY,
        vx: -80 - Math.random() * 40,
        vy: (Math.random() - 0.5) * 30,
        size: 3 + Math.random() * 4,
        color: '#00ff66',
        alpha: 0.15 + Math.random() * 0.35,
        type: biome,
        angle: Math.random() * Math.PI,
        spin: (Math.random() - 0.5) * 2
    };

    if (biome === 'forest') {
        p.color = Math.random() < 0.5 ? '#00ff66' : '#88ff00';
    } else if (biome === 'haunted') {
        p.color = '#b026ff';
        p.size = 6 + Math.random() * 12;
    } else if (biome === 'space') {
        p.color = Math.random() < 0.5 ? '#00f3ff' : '#ffffff';
        p.size = 2 + Math.random() * 2;
    } else if (biome === 'water') {
        p.color = '#00f3ff';
        p.vy = -30 - Math.random() * 30;
    } else if (biome === 'ancient') {
        p.color = '#ffaa00';
    }

    return p;
}

function updateAmbientParticles(dt) {
    const biome = getBiomeForLevel(currentLevel);
    for (let i = ambientParticles.length - 1; i >= 0; i--) {
        const p = ambientParticles[i];
        p.x += p.vx * dt;
        p.y += p.vy * dt;
        p.angle += p.spin * dt;

        if (p.x < camera.x - 100) {
            ambientParticles.splice(i, 1);
            ambientParticles.push(createAmbientParticle(null, biome));
        }
    }
}

// --- PLAYER PHYSICS & WAVE FLIGHT ---
function updatePlayerPhysics(dt) {
    if (player.isDead) {
        updatePlayerParticles(dt);
        return;
    }

    const biome = getBiomeForLevel(currentLevel);
    let speedY = 440;
    if (biome === 'water') speedY = 360;

    // Forward progression
    player.x += player.baseSpeed * player.speedMultiplier * dt;

    // Up/Down wave steering: 45 degree angle trajectory
    if (inputs.active) {
        player.targetVy = -speedY;
    } else {
        player.targetVy = speedY;
    }

    const lerpAcc = biome === 'water' ? 14 : 22;
    player.vy += (player.targetVy - player.vy) * lerpAcc * dt;
    player.y += player.vy * dt;

    // Boundary constraints (top / bottom rails)
    const topLimit = 40 + player.height / 2;
    const botLimit = height - 40 - player.height / 2;

    if (player.y <= topLimit) {
        player.y = topLimit;
        player.vy = 0;
        triggerCrashExplosion();
        return;
    }
    if (player.y >= botLimit) {
        player.y = botLimit;
        player.vy = 0;
        triggerCrashExplosion();
        return;
    }

    // Vehicle angle matches trajectory
    player.angle = Math.atan2(player.vy, player.baseSpeed) * 0.9;

    // Trailing history
    const skin = (typeof window.getActiveSkinDetails === 'function') ? window.getActiveSkinDetails() : VEHICLE_SKINS[0];
    const backAngle = player.angle + Math.PI;
    const backX = player.x + Math.cos(backAngle) * (player.width / 2);
    const backY = player.y + Math.sin(backAngle) * (player.width / 2);

    player.trail.push({
        x: backX,
        y: backY,
        time: Date.now()
    });

    const now = Date.now();
    player.trail = player.trail.filter(pt => now - pt.time < 700);

    // Engine micro sparks
    if (Math.random() < 0.45) {
        player.particles.push({
            x: backX,
            y: backY,
            vx: -player.baseSpeed * 0.3 + (Math.random() - 0.5) * 50,
            vy: -player.vy * 0.2 + (Math.random() - 0.5) * 50,
            size: Math.random() * 3 + 1,
            color: skin.particleColor,
            alpha: 1.0,
            life: 0.45
        });
    }

    updatePlayerParticles(dt);
}

function updatePlayerParticles(dt) {
    for (let i = player.particles.length - 1; i >= 0; i--) {
        const p = player.particles[i];
        p.x += p.vx * dt;
        p.y += p.vy * dt;
        p.life -= dt;
        p.alpha = Math.max(0, p.life / 0.5);

        if (p.life <= 0) {
            player.particles.splice(i, 1);
        }
    }
}

function triggerCrashExplosion() {
    if (player.isDead) return;

    // Practice mode instant respawn
    const chk = document.getElementById('practice-mode-chk');
    if (chk && chk.checked && currentPracticeCheckpoint) {
        playCrashSound();
        createExplosionParticles(player.x, player.y, 25);
        screenShake = 12;

        setTimeout(() => {
            player.x = currentPracticeCheckpoint.x;
            player.y = currentPracticeCheckpoint.y;
            player.vy = currentPracticeCheckpoint.vy;
            player.isDead = false;
            player.trail = [];
            camera.x = player.x - 220;
        }, 350);
        return;
    }

    player.isDead = true;
    player.vy = 0;
    player.hasCrashedThisRun = true;
    screenShake = 18;

    stopSynthMusic();
    playCrashSound();

    if (typeof window.updateStatsOnCrash === 'function') {
        window.updateStatsOnCrash();
    }

    createExplosionParticles(player.x, player.y, 45);

    setTimeout(() => {
        if (currentGameState === STATE_PLAYING) {
            triggerGameOverScreen();
        }
    }, 1000);
}

function createExplosionParticles(x, y, count) {
    const skin = (typeof window.getActiveSkinDetails === 'function') ? window.getActiveSkinDetails() : VEHICLE_SKINS[0];
    for (let i = 0; i < count; i++) {
        const angle = Math.random() * Math.PI * 2;
        const spd = Math.random() * 280 + 80;
        player.particles.push({
            x: x,
            y: y,
            vx: Math.cos(angle) * spd,
            vy: Math.sin(angle) * spd,
            size: Math.random() * 5 + 2,
            color: Math.random() < 0.5 ? skin.color : '#ffffff',
            alpha: 1.0,
            life: 0.8 + Math.random() * 0.5
        });
    }
}

// --- COLLISION LOGIC ---
function updateLevelAndCollisions(dt) {
    if (player.isDead) return;

    // Update rotating sawblades
    obstacles.forEach(obs => {
        if (obs.type === 'saw') {
            obs.angle += obs.spinSpeed * dt;
        }
    });

    if (currentGameMode === 'classic') {
        const startX = 150;
        const totalDist = levelLength - 700 - startX;
        const currentDist = player.x - startX;
        levelProgress = Math.max(0, Math.min(100, (currentDist / totalDist) * 100));

        const bar = document.getElementById('hud-progress-bar');
        if (bar) bar.style.width = `${levelProgress}%`;
        const txt = document.getElementById('hud-progress-text');
        if (txt) txt.innerText = `${Math.floor(levelProgress)}%`;
        const lvlTxt = document.getElementById('hud-level-text');
        if (lvlTxt) lvlTxt.innerText = `Level ${currentLevel} - ${getBiomeForLevel(currentLevel).toUpperCase()}`;

        if (player.x >= levelLength - 700) {
            triggerLevelCleared();
            return;
        }
    } else if (currentGameMode === 'endless') {
        const startX = 150;
        const mDist = Math.floor((player.x - startX) / 10);
        levelProgress = mDist;

        const bar = document.getElementById('hud-progress-bar');
        if (bar) bar.style.width = '100%';
        const txt = document.getElementById('hud-progress-text');
        if (txt) txt.innerText = `${mDist}m`;
        const lvlTxt = document.getElementById('hud-level-text');
        if (lvlTxt) lvlTxt.innerText = `Endless Survival`;

        // Garbage collect old obstacles
        if (obstacles.length > 0 && obstacles[0].x < player.x - 1200) {
            obstacles = obstacles.filter(o => o.x >= player.x - 1200);
        }
        if (collectibles.length > 0 && collectibles[0].x < player.x - 1200) {
            collectibles = collectibles.filter(c => c.x >= player.x - 1200);
        }

        // Continually generate forward buffer
        const lastObsX = obstacles.length > 0 ? obstacles[obstacles.length - 1].x : player.x;
        if (lastObsX < player.x + 3500) {
            const biome = getBiomeForLevel(currentLevel);
            generateEndlessBuffer(lastObsX + 250, 10000, biome, 'rgba(0, 243, 255, 0.9)');
        }

        // Coins for surviving in Endless
        if (mDist > 0 && mDist % 25 === 0 && (!player.lastCoinDistance || player.lastCoinDistance < mDist)) {
            player.lastCoinDistance = mDist;
            if (window.UI_STATE) {
                window.UI_STATE.ploCoins += 2;
                if (typeof window.saveStateItem === 'function') window.saveStateItem(window.KEYS.COINS, window.UI_STATE.ploCoins);
                if (typeof window.renderHeaderWidgets === 'function') window.renderHeaderWidgets();
            }
        }
    }

    // Collectibles (Speedy Coins) collision
    for (const c of collectibles) {
        if (!c.collected && Math.hypot(player.x - c.x, player.y - c.y) < player.width / 2 + c.radius) {
            c.collected = true;
            levelCoinsCollected += 5;
            if (window.UI_STATE) {
                window.UI_STATE.ploCoins += 5;
                if (typeof window.saveStateItem === 'function') window.saveStateItem(window.KEYS.COINS, window.UI_STATE.ploCoins);
                if (typeof window.renderHeaderWidgets === 'function') window.renderHeaderWidgets();
            }
            playCoinSound();
            // Coin particle sparks
            for (let i = 0; i < 8; i++) {
                const a = Math.random() * Math.PI * 2;
                player.particles.push({
                    x: c.x,
                    y: c.y,
                    vx: Math.cos(a) * 90,
                    vy: Math.sin(a) * 90,
                    size: 3,
                    color: '#ffaa00',
                    alpha: 1,
                    life: 0.4
                });
            }
        }
    }

    // Shape-Specific Obstacle Collisions
    const activeShape = (typeof window.getActiveShapeDetails === 'function') ? window.getActiveShapeDetails() : { id: 'arrow', collisionType: 'triangle' };

    for (const obs of obstacles) {
        if (obs.x < player.x - 120 || obs.x > player.x + 200) continue;

        if (checkShapeObstacleCollision(activeShape, obs)) {
            triggerCrashExplosion();
            break;
        }
    }
}

// Shape-specific Collision Algorithms
function checkShapeObstacleCollision(activeShape, obs) {
    const colType = activeShape.collisionType || 'triangle';
    const pr = player.width * 0.42;

    if (obs.type === 'block') {
        if (colType === 'circle' || colType === 'ring') {
            return circleRectIntersect(player.x, player.y, pr, obs.x, obs.y, obs.width, obs.height);
        } else if (colType === 'box') {
            const bw = player.width * 0.75;
            const bh = player.height * 0.75;
            return rectsIntersect(player.x - bw / 2, player.y - bh / 2, bw, bh, obs.x, obs.y, obs.width, obs.height);
        } else {
            // Triangular, Star, Polygon, Complex Shapes vertex/center checks
            const points = getPlayerShapeVertices(activeShape.id);
            for (const pt of points) {
                if (pt.x >= obs.x && pt.x <= obs.x + obs.width && pt.y >= obs.y && pt.y <= obs.y + obs.height) {
                    return true;
                }
            }
            return circleRectIntersect(player.x, player.y, pr * 0.6, obs.x, obs.y, obs.width, obs.height);
        }
    } else if (obs.type === 'spike') {
        const spikeY = obs.dir === 1 ? obs.y : obs.y - obs.height;
        const spikeBoundingIntersect = rectsIntersect(player.x - pr, player.y - pr, pr * 2, pr * 2, obs.x, spikeY, obs.width, obs.height);
        if (!spikeBoundingIntersect) return false;

        if (colType === 'circle' || colType === 'ring') {
            return circleTriangleIntersect(player.x, player.y, pr, obs);
        } else {
            return playerSpikeCollision(obs, activeShape);
        }
    } else if (obs.type === 'saw') {
        const dist = Math.hypot(player.x - obs.x, player.y - obs.y);
        const hitDist = (obs.radius * 0.82) + (pr * (colType === 'circle' ? 0.95 : 0.85));
        return dist < hitDist;
    }

    return false;
}

function getPlayerShapeVertices(shapeId) {
    const r = player.width / 2;
    const cos = Math.cos(player.angle);
    const sin = Math.sin(player.angle);

    const localPts = [
        { x: 0, y: 0 },
        { x: r, y: 0 },
        { x: -r, y: -r * 0.75 },
        { x: -r, y: r * 0.75 },
        { x: 0, y: -r * 0.8 },
        { x: 0, y: r * 0.8 }
    ];

    return localPts.map(pt => ({
        x: player.x + (pt.x * cos - pt.y * sin),
        y: player.y + (pt.x * sin + pt.y * cos)
    }));
}

function circleRectIntersect(cx, cy, radius, rx, ry, rw, rh) {
    const closestX = Math.max(rx, Math.min(cx, rx + rw));
    const closestY = Math.max(ry, Math.min(cy, ry + rh));
    const distX = cx - closestX;
    const distY = cy - closestY;
    return (distX * distX + distY * distY) < (radius * radius);
}

function circleTriangleIntersect(cx, cy, radius, spike) {
    const tipY = spike.dir === 1 ? spike.y + spike.height : spike.y - spike.height;
    const tipX = spike.x + spike.width / 2;
    const x1 = spike.x;
    const y1 = spike.y;
    const x2 = spike.x + spike.width;
    const y2 = spike.y;

    if (pointInTriangle(cx, cy, x1, y1, x2, y2, tipX, tipY)) return true;

    // Check distance to triangle edges
    return Math.hypot(cx - tipX, cy - tipY) < radius ||
           Math.hypot(cx - x1, cy - y1) < radius ||
           Math.hypot(cx - x2, cy - y2) < radius;
}

function rectsIntersect(x1, y1, w1, h1, x2, y2, w2, h2) {
    return x1 < x2 + w2 && x1 + w1 > x2 && y1 < y2 + h2 && y1 + h1 > y2;
}

function playerSpikeCollision(spike, activeShape) {
    const tipY = spike.dir === 1 ? spike.y + spike.height : spike.y - spike.height;
    const tipX = spike.x + spike.width / 2;
    const baseX1 = spike.x;
    const baseY1 = spike.y;
    const baseX2 = spike.x + spike.width;
    const baseY2 = spike.y;

    const corners = getPlayerShapeVertices(activeShape ? activeShape.id : 'arrow');

    for (const p of corners) {
        if (pointInTriangle(p.x, p.y, baseX1, baseY1, baseX2, baseY2, tipX, tipY)) {
            return true;
        }
    }
    return false;
}

function pointInTriangle(px, py, x1, y1, x2, y2, x3, y3) {
    const areaOrig = Math.abs((x1 * (y2 - y3) + x2 * (y3 - y1) + x3 * (y1 - y2)) / 2);
    const area1 = Math.abs((px * (y2 - y3) + x2 * (y3 - py) + x3 * (py - y2)) / 2);
    const area2 = Math.abs((x1 * (py - y3) + px * (y3 - y1) + x3 * (y1 - py)) / 2);
    const area3 = Math.abs((x1 * (y2 - py) + x2 * (py - y1) + px * (y1 - y2)) / 2);
    return Math.abs(areaOrig - (area1 + area2 + area3)) < 0.1;
}

// --- RACE MODE AI BOTS ---
function initRaceBots() {
    bots = [];
    const lb = document.getElementById('race-leaderboard');
    if (currentGameMode !== 'race') {
        if (lb) lb.classList.remove('active');
        return;
    }
    if (lb) lb.classList.add('active');

    const botSpecs = [
        { name: "AeroBot", color: "#ff007f", speed: 410 },
        { name: "HexRunner", color: "#ffaa00", speed: 425 },
        { name: "NeonDash", color: "#b026ff", speed: 415 },
        { name: "GridCrasher", color: "#00f3ff", speed: 430 }
    ];

    botSpecs.forEach((spec, i) => {
        bots.push({
            name: spec.name,
            x: 150,
            y: 200 + i * 80,
            vy: 0,
            width: 28,
            height: 20,
            angle: 0,
            color: spec.color,
            baseSpeed: spec.speed,
            isDead: false,
            lastDecision: 0,
            targetVy: 400,
            trail: []
        });
    });
}

function updateBots(dt) {
    if (currentGameMode !== 'race') return;
    const now = Date.now();

    for (const bot of bots) {
        if (bot.isDead) continue;

        bot.x += bot.baseSpeed * dt;

        if (now - bot.lastDecision > 150) {
            bot.lastDecision = now;
            // Simple obstacle avoidance
            let obstacleAhead = false;
            for (const obs of obstacles) {
                if (obs.x > bot.x && obs.x < bot.x + 220) {
                    if (obs.type === 'spike' && obs.dir === 1 && bot.y < 220) {
                        bot.targetVy = 400; // dive down
                        obstacleAhead = true;
                    } else if (obs.type === 'spike' && obs.dir === -1 && bot.y > height - 220) {
                        bot.targetVy = -400; // climb up
                        obstacleAhead = true;
                    } else if (obs.type === 'block' && bot.y > obs.y - 30 && bot.y < obs.y + obs.height + 30) {
                        bot.targetVy = bot.y > height / 2 ? -400 : 400;
                        obstacleAhead = true;
                    }
                }
            }

            if (!obstacleAhead) {
                if (bot.y < 160) bot.targetVy = 400;
                else if (bot.y > height - 160) bot.targetVy = -400;
                else if (Math.random() < 0.2) bot.targetVy = -bot.targetVy;
            }
        }

        bot.vy += (bot.targetVy - bot.vy) * 16 * dt;
        bot.y += bot.vy * dt;

        if (bot.y < 50 || bot.y > height - 50) {
            bot.isDead = true;
        }

        bot.angle = Math.atan2(bot.vy, bot.baseSpeed) * 0.8;
        bot.trail.push({ x: bot.x, y: bot.y, time: now });
        bot.trail = bot.trail.filter(pt => now - pt.time < 400);
    }

    updateRaceLeaderboard();
}

function updateRaceLeaderboard() {
    const list = document.getElementById('leaderboard-list');
    if (!list) return;

    const racers = [
        { name: "YOU", x: player.x, isDead: player.isDead, color: 'var(--neon-green)' },
        ...bots.map(b => ({ name: b.name, x: b.x, isDead: b.isDead, color: b.color }))
    ];

    racers.sort((a, b) => b.x - a.x);
    list.innerHTML = '';

    racers.forEach((r, idx) => {
        const row = document.createElement('div');
        row.className = `leaderboard-row ${r.name === 'YOU' ? 'player' : ''}`;
        row.style.color = r.isDead ? '#556e6b' : r.color;
        row.innerHTML = `
            <span>${idx + 1}. ${r.name}</span>
            <span>${r.isDead ? 'CRASHED' : Math.floor(r.x / 10) + 'm'}</span>
        `;
        list.appendChild(row);
    });

    if (!player.isDead && player.x >= levelLength - 700) {
        const myRank = racers.findIndex(r => r.name === 'YOU');
        if (myRank === 0) {
            if (window.UI_STATE) {
                window.UI_STATE.raceWins = (window.UI_STATE.raceWins || 0) + 1;
                window.UI_STATE.ploCoins += 150;
                if (typeof window.saveStateItem === 'function') {
                    window.saveStateItem(window.KEYS.RACE_WINS, window.UI_STATE.raceWins);
                    window.saveStateItem(window.KEYS.COINS, window.UI_STATE.ploCoins);
                }
            }
            triggerLevelCleared();
        } else {
            setGameState(STATE_GAMEOVER);
            const failProg = document.getElementById('fail-progress-val');
            if (failProg) failProg.innerText = `Rank #${myRank + 1}`;
            const failSc = document.getElementById('fail-score-val');
            if (failSc) failSc.innerText = `Winner: ${racers[0].name}`;
            const modal = document.getElementById('gameover-modal');
            if (modal) modal.classList.add('active');
        }
    }
}

// --- WIN & GAMEOVER TRIGGERS ---
function triggerGameOverScreen() {
    setGameState(STATE_GAMEOVER);

    const failProg = document.getElementById('fail-progress-val');
    const failScore = document.getElementById('fail-score-val');

    if (currentGameMode === 'classic') {
        if (failProg) failProg.innerText = `${Math.floor(levelProgress)}%`;
        if (failScore) failScore.innerText = `Level ${currentLevel}`;
    } else if (currentGameMode === 'endless') {
        if (failProg) failProg.innerText = `${Math.floor(levelProgress)}m`;
        if (failScore) failScore.innerText = `Best: ${window.UI_STATE ? window.UI_STATE.highScore : 0}m`;

        if (window.UI_STATE && levelProgress > window.UI_STATE.highScore) {
            window.UI_STATE.highScore = Math.floor(levelProgress);
            if (typeof window.saveStateItem === 'function') {
                window.saveStateItem(window.KEYS.HIGH_SCORE, window.UI_STATE.highScore);
            }
            if (typeof window.renderHeaderWidgets === 'function') {
                window.renderHeaderWidgets();
            }
            window.showToast(`NEW HIGH SCORE: ${window.UI_STATE.highScore}m!`, 'success');
        }
    } else {
        if (failProg) failProg.innerText = `Crashed Out`;
        if (failScore) failScore.innerText = `Race Tournament`;
    }

    const modal = document.getElementById('gameover-modal');
    if (modal) modal.classList.add('active');
}

function triggerLevelCleared() {
    setGameState(STATE_VICTORY);
    stopSynthMusic();
    playClearedSound();

    const isPerfect = attemptCount === 1 && !player.hasCrashedThisRun;

    const winMode = document.getElementById('win-mode-val');
    if (winMode) winMode.innerText = currentGameMode === 'classic' ? `Level ${currentLevel} Cleared!` : `Tournament Victory!`;
    const winAttempts = document.getElementById('win-attempts-val');
    if (winAttempts) winAttempts.innerText = attemptCount;

    if (typeof window.updateStatsOnWin === 'function') {
        window.updateStatsOnWin(currentLevel, isPerfect);
    }

    const nextBtn = document.getElementById('win-next-btn');
    if (nextBtn) {
        nextBtn.style.display = (currentGameMode === 'classic' && currentLevel < 100) ? 'block' : 'none';
    }

    const modal = document.getElementById('win-modal');
    if (modal) modal.classList.add('active');
}

// --- PRACTICE MODE CHECKPOINTS ---
function togglePracticeMode(enabled) {
    const ctrls = document.getElementById('practice-controls');
    if (ctrls) ctrls.style.visibility = enabled ? 'visible' : 'hidden';
    if (!enabled) currentPracticeCheckpoint = null;
}
window.togglePracticeMode = togglePracticeMode;

function placeCheckpoint() {
    if (player.isDead) return;
    playCheckpointSound();

    currentPracticeCheckpoint = {
        x: player.x,
        y: player.y,
        vy: player.vy
    };

    window.showToast("Checkpoint Saved!", "info");

    for (let i = 0; i < 12; i++) {
        const a = (i / 12) * Math.PI * 2;
        player.particles.push({
            x: player.x,
            y: player.y,
            vx: Math.cos(a) * 110,
            vy: Math.sin(a) * 110,
            size: 3.5,
            color: '#00f3ff',
            alpha: 1,
            life: 0.5
        });
    }
}
window.placeCheckpoint = placeCheckpoint;

function clearCheckpoints() {
    currentPracticeCheckpoint = null;
    window.showToast("Checkpoints Cleared", "info");
}
window.clearCheckpoints = clearCheckpoints;

// --- PAUSE & MODAL ACTIONS ---
function pauseGame() {
    if (currentGameState !== STATE_PLAYING) return;
    currentGameState = STATE_PAUSED;
    stopSynthMusic();

    const pProg = document.getElementById('pause-progress-val');
    if (pProg) {
        pProg.innerText = currentGameMode === 'classic' ? `${Math.floor(levelProgress)}%` : `${Math.floor(levelProgress)}m`;
    }
    const pMode = document.getElementById('pause-mode-val');
    if (pMode) pMode.innerText = currentGameMode.toUpperCase();

    const modal = document.getElementById('pause-modal');
    if (modal) modal.classList.add('active');
}
window.pauseGame = pauseGame;

function resumeGame() {
    if (currentGameState !== STATE_PAUSED) return;
    hideAllModals();
    currentGameState = STATE_PLAYING;
    startSynthMusic();
}
window.resumeGame = resumeGame;

function restartLevel() {
    hideAllModals();
    attemptCount++;
    initGameElements();
    setGameState(STATE_PLAYING);
}
window.restartLevel = restartLevel;

function quitToMenu() {
    hideAllModals();
    if (typeof window.openMainMenu === 'function') {
        window.openMainMenu();
    }
}
window.quitToMenu = quitToMenu;

function nextLevel() {
    hideAllModals();
    if (currentLevel < 100) {
        launchClassicLevel(currentLevel + 1);
    } else {
        if (typeof window.openLevelSelect === 'function') {
            window.openLevelSelect();
        }
    }
}
window.nextLevel = nextLevel;

function toggleAudio() {
    isMuted = !isMuted;
    if (isMuted) {
        stopSynthMusic();
    } else if (currentGameState === STATE_PLAYING) {
        startSynthMusic();
    }
    window.showToast(isMuted ? "Audio Muted" : "Audio Enabled", "info");
}
window.toggleAudio = toggleAudio;

// --- RENDERING MODULES ---
function gameLoop(time) {
    if (!lastTime) lastTime = time;
    deltaTime = (time - lastTime) / 1000;
    lastTime = time;

    if (deltaTime > 0.08) deltaTime = 0.08;

    update(deltaTime);
    render();

    requestAnimationFrame(gameLoop);
}

function update(dt) {
    if (currentGameState !== STATE_PLAYING) return;

    updatePlayerPhysics(dt);
    updateBots(dt);
    updateLevelAndCollisions(dt);
    updateAmbientParticles(dt);

    // Smooth camera tracking
    camera.x = player.x - 220;
    camera.targetY = player.y - height / 2;
    const limit = 80;
    camera.targetY = Math.max(-limit, Math.min(limit, camera.targetY));
    camera.y += (camera.targetY - camera.y) * 8 * dt;

    if (screenShake > 0) {
        screenShake -= dt * 25;
        if (screenShake < 0) screenShake = 0;
    }

    bgScrollX = camera.x;
    bgScrollY = camera.y;
}

function render() {
    if (!ctx || !canvas) return;

    ctx.clearRect(0, 0, canvas.width, canvas.height);

    // Parallax background grid
    if (hexPatternCanvas) {
        ctx.save();
        const left = -(bgScrollX * 0.3) % hexPatternWidth;
        const top = -(bgScrollY * 0.3) % hexPatternHeight;

        ctx.fillStyle = ctx.createPattern(hexPatternCanvas, 'repeat');
        ctx.translate(left, top);
        ctx.fillRect(-left, -top, canvas.width, canvas.height);
        ctx.restore();
    }

    // Centered Virtual 16:9 Viewport
    ctx.save();
    ctx.translate(offsetX, offsetY);
    ctx.scale(scale, scale);

    // Screen shake
    if (screenShake > 0) {
        const shakeX = (Math.random() - 0.5) * screenShake;
        const shakeY = (Math.random() - 0.5) * screenShake;
        ctx.translate(shakeX, shakeY);
    }

    // Arena Clip
    ctx.save();
    ctx.beginPath();
    ctx.rect(0, 0, width, height);
    ctx.clip();

    // Biome atmosphere tint
    drawBiomeWeather(ctx);

    // Ambient floating particles
    drawAmbientParticles(ctx);

    // World Space Translations
    ctx.save();
    ctx.translate(-camera.x, -camera.y);

    // Top & Bottom boundary rails
    drawBoundaries(ctx);

    // Obstacles & Collectibles
    drawObstacles(ctx);
    drawCollectibles(ctx);

    // Practice Checkpoint Diamond
    if (currentPracticeCheckpoint) {
        ctx.save();
        ctx.fillStyle = '#00f3ff';
        ctx.shadowColor = '#00f3ff';
        ctx.shadowBlur = 12;
        ctx.beginPath();
        ctx.arc(currentPracticeCheckpoint.x, currentPracticeCheckpoint.y, 8, 0, Math.PI * 2);
        ctx.fill();
        ctx.restore();
    }

    // AI Bots
    drawBots(ctx);

    // Player Arrow & Waves
    drawPlayer(ctx);

    ctx.restore(); // restore camera

    ctx.restore(); // restore clip
    ctx.restore(); // restore virtual scale
}

function drawBiomeWeather(ctx) {
    const biome = getBiomeForLevel(currentLevel);
    ctx.save();
    if (biome === 'forest') {
        const grad = ctx.createLinearGradient(0, 0, 0, height);
        grad.addColorStop(0, 'rgba(0, 255, 102, 0.05)');
        grad.addColorStop(1, 'transparent');
        ctx.fillStyle = grad;
        ctx.fillRect(0, 0, width, height);
    } else if (biome === 'haunted') {
        const grad = ctx.createRadialGradient(width / 2, height / 2, 100, width / 2, height / 2, width / 2 + 150);
        grad.addColorStop(0, 'transparent');
        grad.addColorStop(1, 'rgba(176, 38, 255, 0.12)');
        ctx.fillStyle = grad;
        ctx.fillRect(0, 0, width, height);
    } else if (biome === 'space') {
        ctx.fillStyle = 'rgba(0, 243, 255, 0.03)';
        ctx.fillRect(0, 0, width, height);
    } else if (biome === 'water') {
        const grad = ctx.createLinearGradient(0, 0, 0, height);
        grad.addColorStop(0, 'rgba(0, 85, 255, 0.12)');
        grad.addColorStop(1, 'rgba(0, 243, 255, 0.1)');
        ctx.fillStyle = grad;
        ctx.fillRect(0, 0, width, height);
    } else if (biome === 'ancient') {
        ctx.fillStyle = 'rgba(255, 170, 0, 0.04)';
        ctx.fillRect(0, 0, width, height);
    }
    ctx.restore();
}

function drawAmbientParticles(ctx) {
    ctx.save();
    ambientParticles.forEach(p => {
        ctx.globalAlpha = p.alpha;
        ctx.fillStyle = p.color;
        ctx.beginPath();
        ctx.arc(p.x, p.y, p.size, 0, Math.PI * 2);
        ctx.fill();
    });
    ctx.restore();
}

function drawBoundaries(ctx) {
    ctx.save();
    const biome = getBiomeForLevel(currentLevel);
    const borderColors = {
        forest: 'rgba(0, 255, 102, 0.7)',
        haunted: 'rgba(176, 38, 255, 0.7)',
        space: 'rgba(0, 243, 255, 0.7)',
        water: 'rgba(255, 0, 127, 0.7)',
        ancient: 'rgba(255, 170, 0, 0.7)'
    };
    const col = borderColors[biome] || 'rgba(0, 243, 255, 0.7)';

    ctx.strokeStyle = col;
    ctx.lineWidth = 4;
    ctx.shadowBlur = 10;
    ctx.shadowColor = col;

    // Top rail
    ctx.beginPath();
    ctx.moveTo(camera.x - 200, 40);
    ctx.lineTo(camera.x + width + 200, 40);
    ctx.stroke();

    // Bottom rail
    ctx.beginPath();
    ctx.moveTo(camera.x - 200, height - 40);
    ctx.lineTo(camera.x + width + 200, height - 40);
    ctx.stroke();

    ctx.restore();
}

function drawObstacles(ctx) {
    ctx.save();
    for (const obs of obstacles) {
        if (obs.x < camera.x - 100 || obs.x > camera.x + width + 100) continue;

        ctx.shadowBlur = 12;
        ctx.shadowColor = obs.color;

        if (obs.type === 'spike') {
            ctx.strokeStyle = '#ffffff';
            ctx.lineWidth = 2.4;
            ctx.fillStyle = obs.color;

            ctx.beginPath();
            if (obs.dir === 1) {
                ctx.moveTo(obs.x, obs.y);
                ctx.lineTo(obs.x + obs.width, obs.y);
                ctx.lineTo(obs.x + obs.width / 2, obs.y + obs.height);
            } else {
                ctx.moveTo(obs.x, obs.y);
                ctx.lineTo(obs.x + obs.width, obs.y);
                ctx.lineTo(obs.x + obs.width / 2, obs.y - obs.height);
            }
            ctx.closePath();
            ctx.fill();
            ctx.stroke();

        } else if (obs.type === 'block') {
            ctx.strokeStyle = '#ffffff';
            ctx.lineWidth = 2;
            ctx.fillStyle = 'rgba(2, 6, 6, 0.95)';

            ctx.fillRect(obs.x, obs.y, obs.width, obs.height);
            ctx.strokeRect(obs.x, obs.y, obs.width, obs.height);

            ctx.strokeStyle = obs.color;
            ctx.lineWidth = 1.4;
            ctx.strokeRect(obs.x + 4, obs.y + 4, obs.width - 8, obs.height - 8);

        } else if (obs.type === 'saw') {
            // Glowing rotating sawblade
            ctx.save();
            ctx.translate(obs.x, obs.y);
            ctx.rotate(obs.angle);

            // Saw center core
            ctx.fillStyle = 'rgba(2, 6, 6, 0.9)';
            ctx.strokeStyle = obs.color;
            ctx.lineWidth = 2.5;
            ctx.beginPath();
            ctx.arc(0, 0, obs.radius * 0.45, 0, Math.PI * 2);
            ctx.fill();
            ctx.stroke();

            // Saw teeth
            const teeth = 8;
            ctx.fillStyle = obs.color;
            ctx.beginPath();
            for (let i = 0; i < teeth; i++) {
                const a = (i / teeth) * Math.PI * 2;
                const aNext = ((i + 0.5) / teeth) * Math.PI * 2;
                const rOut = obs.radius;
                const rIn = obs.radius * 0.65;

                ctx.lineTo(Math.cos(a) * rOut, Math.sin(a) * rOut);
                ctx.lineTo(Math.cos(aNext) * rIn, Math.sin(aNext) * rIn);
            }
            ctx.closePath();
            ctx.fill();
            ctx.stroke();

            ctx.restore();

        } else if (obs.type === 'gate') {
            ctx.strokeStyle = '#ffffff';
            ctx.lineWidth = 3;
            ctx.fillStyle = 'rgba(0, 243, 255, 0.25)';
            ctx.fillRect(obs.x, obs.y, obs.width, obs.height);
            ctx.strokeRect(obs.x, obs.y, obs.width, obs.height);
        }
    }
    ctx.restore();
}

function drawCollectibles(ctx) {
    ctx.save();
    for (const c of collectibles) {
        if (c.collected) continue;
        if (c.x < camera.x - 50 || c.x > camera.x + width + 50) continue;

        ctx.shadowColor = '#ffaa00';
        ctx.shadowBlur = 10;
        ctx.fillStyle = '#ffaa00';
        ctx.strokeStyle = '#ffffff';
        ctx.lineWidth = 1.5;

        ctx.beginPath();
        ctx.arc(c.x, c.y, c.radius, 0, Math.PI * 2);
        ctx.fill();
        ctx.stroke();

        ctx.fillStyle = '#020606';
        ctx.font = 'bold 10px Orbitron';
        ctx.textAlign = 'center';
        ctx.textBaseline = 'middle';
        ctx.fillText('$', c.x, c.y);
    }
    ctx.restore();
}

function drawPlayer(ctx) {
    if (player.isDead) {
        drawPlayerParticles(ctx);
        return;
    }

    const skin = (typeof window.getActiveSkinDetails === 'function') ? window.getActiveSkinDetails() : VEHICLE_SKINS[0];
    const activeShape = (typeof window.getActiveShapeDetails === 'function') ? window.getActiveShapeDetails() : { id: 'arrow' };

    // Trailing wave ribbon
    drawPlayerTrail(ctx, skin);

    // Active Player Shape Rendering
    ctx.save();
    ctx.translate(player.x, player.y);
    ctx.rotate(player.angle);

    // Glow halo
    const glow = ctx.createRadialGradient(0, 0, 2, 0, 0, player.width * 1.25);
    glow.addColorStop(0, skin.color);
    glow.addColorStop(1, 'transparent');
    ctx.fillStyle = glow;
    ctx.beginPath();
    ctx.arc(0, 0, player.width * 1.25, 0, Math.PI * 2);
    ctx.fill();

    // Player Shape
    ctx.strokeStyle = '#ffffff';
    ctx.lineWidth = 2.4;
    ctx.fillStyle = 'rgba(2, 6, 6, 0.92)';
    ctx.shadowColor = skin.color;
    ctx.shadowBlur = 14;

    if (typeof window.drawShapeGeometry === 'function') {
        window.drawShapeGeometry(ctx, activeShape.id, player.width / 2);
    } else {
        ctx.beginPath();
        ctx.moveTo(player.width / 2, 0);
        ctx.lineTo(-player.width / 2, -player.height / 2);
        ctx.lineTo(-player.width / 4, 0);
        ctx.lineTo(-player.width / 2, player.height / 2);
        ctx.closePath();
    }
    ctx.fill();
    ctx.stroke();

    // Inner Neon Core Accent
    ctx.strokeStyle = skin.trailColor;
    ctx.lineWidth = 1.4;
    ctx.shadowColor = skin.trailColor;
    ctx.shadowBlur = 6;
    if (typeof window.drawShapeGeometry === 'function') {
        window.drawShapeGeometry(ctx, activeShape.id, player.width / 3.5);
        ctx.stroke();
    }

    ctx.restore();

    drawPlayerParticles(ctx);
}

function drawPlayerTrail(ctx, skin) {
    if (player.trail.length < 2) return;

    ctx.save();
    ctx.shadowBlur = 10;
    ctx.shadowColor = skin.trailColor;

    if (skin.trailType === 'particles') {
        player.trail.forEach(pt => {
            const age = Date.now() - pt.time;
            const op = Math.max(0, 1 - age / 700);
            ctx.fillStyle = skin.trailColor;
            ctx.globalAlpha = op * 0.8;
            ctx.beginPath();
            ctx.arc(pt.x, pt.y, 4, 0, Math.PI * 2);
            ctx.fill();
        });
    } else if (skin.trailType === 'rainbow') {
        ctx.lineWidth = 3.5;
        for (let i = 1; i < player.trail.length; i++) {
            const p1 = player.trail[i - 1];
            const p2 = player.trail[i];
            const age = Date.now() - p2.time;
            const op = Math.max(0, 1 - age / 700);
            const hue = (i * 18) % 360;
            ctx.strokeStyle = `hsla(${hue}, 100%, 55%, ${op * 0.9})`;
            ctx.beginPath();
            ctx.moveTo(p1.x, p1.y);
            ctx.lineTo(p2.x, p2.y);
            ctx.stroke();
        }
    } else {
        ctx.lineWidth = 3.5;
        ctx.beginPath();
        for (let i = 1; i < player.trail.length; i++) {
            const p1 = player.trail[i - 1];
            const p2 = player.trail[i];
            const age = Date.now() - p2.time;
            const op = Math.max(0, 1 - age / 700);
            ctx.strokeStyle = skin.trailColor;
            ctx.globalAlpha = op * 0.85;
            if (i === 1) ctx.moveTo(p1.x, p1.y);
            ctx.lineTo(p2.x, p2.y);
        }
        ctx.stroke();
    }
    ctx.restore();
}

function drawPlayerParticles(ctx) {
    ctx.save();
    for (const p of player.particles) {
        ctx.fillStyle = p.color;
        ctx.globalAlpha = p.alpha;
        ctx.shadowColor = p.color;
        ctx.shadowBlur = 6;
        ctx.beginPath();
        ctx.arc(p.x, p.y, p.size, 0, Math.PI * 2);
        ctx.fill();
    }
    ctx.restore();
}

function drawBots(ctx) {
    if (currentGameMode !== 'race') return;

    for (const bot of bots) {
        if (bot.isDead) continue;

        // Bot trail
        if (bot.trail.length >= 2) {
            ctx.save();
            ctx.shadowBlur = 8;
            ctx.shadowColor = bot.color;
            ctx.lineWidth = 2.4;
            for (let i = 1; i < bot.trail.length; i++) {
                const pt1 = bot.trail[i - 1];
                const pt2 = bot.trail[i];
                const age = Date.now() - pt2.time;
                const op = Math.max(0, 1 - age / 400);
                ctx.strokeStyle = bot.color;
                ctx.globalAlpha = op * 0.7;
                if (i === 1) ctx.moveTo(pt1.x, pt1.y);
                ctx.lineTo(pt2.x, pt2.y);
            }
            ctx.stroke();
            ctx.restore();
        }

        // Bot triangle
        ctx.save();
        ctx.translate(bot.x, bot.y);
        ctx.rotate(bot.angle);

        ctx.strokeStyle = '#ffffff';
        ctx.lineWidth = 2;
        ctx.fillStyle = bot.color;
        ctx.shadowColor = bot.color;
        ctx.shadowBlur = 8;

        ctx.beginPath();
        ctx.moveTo(bot.width / 2, 0);
        ctx.lineTo(-bot.width / 2, -bot.height / 2);
        ctx.lineTo(-bot.width / 4, 0);
        ctx.lineTo(-bot.width / 2, bot.height / 2);
        ctx.closePath();
        ctx.fill();
        ctx.stroke();

        ctx.restore();
    }
}

// --- SYNTHESIZED PROCEDURAL SOUNDTRACK & SFX ---
function startSynthMusic() {
    if (isMuted) return;
    initAudioContext();
    stopSynthMusic();

    synthStep = 0;
    synthIntervalId = setInterval(() => {
        if (currentGameState !== STATE_PLAYING || isMuted) return;
        playSynthStep();
    }, 190);
}

function stopSynthMusic() {
    if (synthIntervalId) {
        clearInterval(synthIntervalId);
        synthIntervalId = null;
    }
}

function playSynthStep() {
    if (!audioCtx) return;
    try {
        const step = synthStep % 16;
        synthStep++;

        // Kick drum on quarter notes
        if (step % 4 === 0) {
            playKickDrum();
        }

        // Crisp Hi-Hat on offbeats
        if (step % 2 === 1) {
            playHiHat();
        }

        // Cyberpunk minor melody
        const melody = [55, 55, 65, 55, 58, 55, 62, 58, 55, 55, 65, 55, 58, 65, 73, 65];
        const freq = melody[step] * 2.2;
        playSynthBass(freq);
    } catch (e) {
        console.error("Synth step err:", e);
    }
}

function playKickDrum() {
    if (!audioCtx) return;
    const osc = audioCtx.createOscillator();
    const gain = audioCtx.createGain();

    osc.connect(gain);
    gain.connect(audioCtx.destination);

    osc.frequency.setValueAtTime(140, audioCtx.currentTime);
    osc.frequency.exponentialRampToValueAtTime(0.01, audioCtx.currentTime + 0.12);

    gain.gain.setValueAtTime(0.3, audioCtx.currentTime);
    gain.gain.exponentialRampToValueAtTime(0.001, audioCtx.currentTime + 0.13);

    osc.start(audioCtx.currentTime);
    osc.stop(audioCtx.currentTime + 0.14);
}

function playHiHat() {
    if (!audioCtx) return;
    const bufferSize = audioCtx.sampleRate * 0.04;
    const buffer = audioCtx.createBuffer(1, bufferSize, audioCtx.sampleRate);
    const data = buffer.getChannelData(0);
    for (let i = 0; i < bufferSize; i++) {
        data[i] = Math.random() * 2 - 1;
    }

    const source = audioCtx.createBufferSource();
    source.buffer = buffer;

    const filter = audioCtx.createBiquadFilter();
    filter.type = 'highpass';
    filter.frequency.value = 7500;

    const gain = audioCtx.createGain();
    gain.gain.setValueAtTime(0.06, audioCtx.currentTime);
    gain.gain.exponentialRampToValueAtTime(0.001, audioCtx.currentTime + 0.035);

    source.connect(filter);
    filter.connect(gain);
    gain.connect(audioCtx.destination);

    source.start(audioCtx.currentTime);
    source.stop(audioCtx.currentTime + 0.04);
}

function playSynthBass(freq) {
    if (!audioCtx) return;
    const osc = audioCtx.createOscillator();
    const gain = audioCtx.createGain();
    const filter = audioCtx.createBiquadFilter();

    osc.type = 'sawtooth';
    osc.frequency.setValueAtTime(freq, audioCtx.currentTime);
    osc.frequency.exponentialRampToValueAtTime(freq * 0.98, audioCtx.currentTime + 0.16);

    filter.type = 'lowpass';
    filter.frequency.value = 700;

    gain.gain.setValueAtTime(0.1, audioCtx.currentTime);
    gain.gain.exponentialRampToValueAtTime(0.001, audioCtx.currentTime + 0.17);

    osc.connect(filter);
    filter.connect(gain);
    gain.connect(audioCtx.destination);

    osc.start(audioCtx.currentTime);
    osc.stop(audioCtx.currentTime + 0.18);
}

function playCrashSound() {
    if (isMuted || !audioCtx) return;
    try {
        const osc = audioCtx.createOscillator();
        const gain = audioCtx.createGain();

        osc.type = 'triangle';
        osc.frequency.setValueAtTime(160, audioCtx.currentTime);
        osc.frequency.exponentialRampToValueAtTime(10, audioCtx.currentTime + 0.6);

        gain.gain.setValueAtTime(0.35, audioCtx.currentTime);
        gain.gain.exponentialRampToValueAtTime(0.001, audioCtx.currentTime + 0.65);

        osc.connect(gain);
        gain.connect(audioCtx.destination);

        osc.start(audioCtx.currentTime);
        osc.stop(audioCtx.currentTime + 0.7);
    } catch (e) {}
}

function playClearedSound() {
    if (isMuted || !audioCtx) return;
    try {
        const notes = [329.63, 440, 554.37, 659.25];
        const now = audioCtx.currentTime;

        notes.forEach((freq, i) => {
            const osc = audioCtx.createOscillator();
            const gain = audioCtx.createGain();

            osc.type = 'sine';
            osc.frequency.setValueAtTime(freq, now + i * 0.07);
            osc.frequency.exponentialRampToValueAtTime(freq * 1.2, now + i * 0.07 + 0.35);

            gain.gain.setValueAtTime(0.12, now + i * 0.07);
            gain.gain.exponentialRampToValueAtTime(0.001, now + i * 0.07 + 0.4);

            osc.connect(gain);
            gain.connect(audioCtx.destination);

            osc.start(now + i * 0.07);
            osc.stop(now + i * 0.07 + 0.45);
        });
    } catch (e) {}
}

function playCheckpointSound() {
    if (isMuted || !audioCtx) return;
    try {
        const osc = audioCtx.createOscillator();
        const gain = audioCtx.createGain();

        osc.type = 'sine';
        osc.frequency.setValueAtTime(523.25, audioCtx.currentTime);
        osc.frequency.setValueAtTime(783.99, audioCtx.currentTime + 0.06);

        gain.gain.setValueAtTime(0.12, audioCtx.currentTime);
        gain.gain.exponentialRampToValueAtTime(0.001, audioCtx.currentTime + 0.2);

        osc.connect(gain);
        gain.connect(audioCtx.destination);

        osc.start(audioCtx.currentTime);
        osc.stop(audioCtx.currentTime + 0.22);
    } catch (e) {}
}
window.playCheckpointSound = playCheckpointSound;

function playCoinSound() {
    if (isMuted || !audioCtx) return;
    try {
        const osc = audioCtx.createOscillator();
        const gain = audioCtx.createGain();

        osc.type = 'sine';
        osc.frequency.setValueAtTime(880, audioCtx.currentTime);
        osc.frequency.setValueAtTime(1320, audioCtx.currentTime + 0.05);

        gain.gain.setValueAtTime(0.15, audioCtx.currentTime);
        gain.gain.exponentialRampToValueAtTime(0.001, audioCtx.currentTime + 0.18);

        osc.connect(gain);
        gain.connect(audioCtx.destination);

        osc.start(audioCtx.currentTime);
        osc.stop(audioCtx.currentTime + 0.2);
    } catch (e) {}
}
