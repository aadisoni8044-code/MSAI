/**
 * Speedy Arrow - High-Performance Canvas Game Engine
 * Features: High-DPI rendering, Geometry Dash Wave physics, 100 Biome levels,
 * Endless procedural generation, AI Drone Championship, Practice mode checkpoints,
 * Web Audio API synthesizer soundtrack & procedural sound effects.
 */

// Game States
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

// Virtual Canvas Dimensions (16:9)
const VIRTUAL_WIDTH = 1200;
const VIRTUAL_HEIGHT = 675;
let canvas, ctx;
let scale = 1;
let offsetX = 0;
let offsetY = 0;
let targetHorizontalOffset = 180;
let currentHorizontalOffset = 180;

// Timing
let lastTime = 0;
let deltaTime = 0;
let physicsAccumulator = 0;
let gameTime = 0;
const FIXED_TIMESTEP = 1 / 120; // 120Hz deterministic physics substeps (8.33ms)

// Inputs
const inputs = {
    active: false,
    space: false,
    w: false,
    up: false,
    pointer: false,
    left: false,
    right: false
};

// Parallax background offsets
let bgScrollX = 0;
let bgScrollY = 0;

// Offscreen Hexagon Grid Canvas for ultra-smooth background rendering
let hexPatternCanvas = null;
const hexPatternWidth = 256;
const hexPatternHeight = 256;

// Game stats trackers
let levelProgress = 0;
let endlessDistance = 0;
let raceWinsCount = 0;

// Ambient particles & weather
let biomeAmbientParticles = [];

// Audio Synthesizer
let audioCtx = null;
let synthIntervalId = null;
let synthBeatsCount = 0;

// Level Obstacles & Checkpoints
let obstacles = [];
let levelLength = 6000;
let currentPracticeCheckpoint = null;

// Race Mode AI Bots
let bots = [];

// Player Object
const player = {
    x: 150,
    y: 337.5,
    width: 32,
    height: 24,
    vy: 0,
    targetVy: 0,
    angle: 0,
    baseSpeed: 390,
    speedMultiplier: 1,
    isDead: false,
    trail: [],
    particles: [],
    hasCrashedThisRun: false,
    lastCoinPayout: 0
};

// Camera
const camera = {
    x: 0,
    y: 0,
    targetY: 0
};

// --- INITIALIZATION ---
window.addEventListener('DOMContentLoaded', () => {
    canvas = document.getElementById('gameCanvas');
    if (!canvas) return;
    ctx = canvas.getContext('2d');

    initCanvas();
    createHexagonPattern();
    initInputListeners();
    initAudioContextTrigger();

    if (typeof window.initUI === 'function') {
        window.initUI();
    }

    requestAnimationFrame(gameLoop);
});

window.addEventListener('resize', initCanvas);
window.addEventListener('orientationchange', () => {
    setTimeout(initCanvas, 100);
});
document.addEventListener('fullscreenchange', initCanvas);
if (window.visualViewport) {
    window.visualViewport.addEventListener('resize', initCanvas);
}

function initCanvas() {
    if (!canvas) return;
    const container = document.getElementById('game-container');
    if (!container) return;

    const rect = container.getBoundingClientRect();
    const dpr = Math.min(window.devicePixelRatio || 1, 2);

    canvas.width = rect.width * dpr;
    canvas.height = rect.height * dpr;
    canvas.style.width = `${rect.width}px`;
    canvas.style.height = `${rect.height}px`;

    const targetAspect = VIRTUAL_WIDTH / VIRTUAL_HEIGHT;
    const currentAspect = rect.width / rect.height;

    if (currentAspect > targetAspect) {
        scale = (rect.height * dpr) / VIRTUAL_HEIGHT;
        offsetX = ((rect.width * dpr) - (VIRTUAL_WIDTH * scale)) / 2;
        offsetY = 0;
    } else {
        scale = (rect.width * dpr) / VIRTUAL_WIDTH;
        offsetX = 0;
        offsetY = ((rect.height * dpr) - (VIRTUAL_HEIGHT * scale)) / 2;
    }
}

// Background Hexagon Honeycomb Generator
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

    hCtx.strokeStyle = 'rgba(0, 243, 255, 0.08)';
    hCtx.lineWidth = 1.2;

    for (let x = -r; x < hexPatternWidth + r * 2; x += r * 3) {
        for (let y = -r; y < hexPatternHeight + r * 2; y += h) {
            drawHexagonPath(hCtx, x, y, r);
            hCtx.stroke();

            drawHexagonPath(hCtx, x + w, y + h / 2, r);
            hCtx.stroke();
        }
    }
}

function drawHexagonPath(context, x, y, radius) {
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

// --- INPUT SYSTEM ---
function initInputListeners() {
    window.addEventListener('keydown', (e) => {
        if (e.code === 'Space') {
            inputs.space = true;
            e.preventDefault();
        }
        if (e.code === 'KeyW' || e.code === 'ArrowUp') {
            inputs.w = true;
            inputs.up = true;
            e.preventDefault();
        }
        if (e.code === 'KeyA' || e.code === 'ArrowLeft') {
            inputs.left = true;
        }
        if (e.code === 'KeyD' || e.code === 'ArrowRight') {
            inputs.right = true;
        }
        if (e.code === 'Escape') {
            if (currentGameState === STATE_PLAYING) {
                pauseGame();
            } else if (currentGameState === STATE_PAUSED) {
                resumeGame();
            }
        }
        updateInputActiveState();
    });

    window.addEventListener('keyup', (e) => {
        if (e.code === 'Space') {
            inputs.space = false;
        }
        if (e.code === 'KeyW' || e.code === 'ArrowUp') {
            inputs.w = false;
            inputs.up = false;
        }
        if (e.code === 'KeyA' || e.code === 'ArrowLeft') {
            inputs.left = false;
        }
        if (e.code === 'KeyD' || e.code === 'ArrowRight') {
            inputs.right = false;
        }
        updateInputActiveState();
    });

    const overlay = document.getElementById('input-overlay');
    if (overlay) {
        const handlePointer = (e) => {
            let isPressed = false;
            let goLeft = false;
            let goRight = false;

            const rect = overlay.getBoundingClientRect();
            const widthPx = rect.width;

            if (e.touches && e.touches.length > 0) {
                isPressed = true;
                for (let i = 0; i < e.touches.length; i++) {
                    const touch = e.touches[i];
                    const px = touch.clientX - rect.left;
                    if (px < widthPx * 0.25) goLeft = true;
                    else if (px > widthPx * 0.75) goRight = true;
                }
            } else if (!e.touches && (e.buttons & 1)) {
                isPressed = true;
                const px = e.clientX - rect.left;
                if (px < widthPx * 0.25) goLeft = true;
                else if (px > widthPx * 0.75) goRight = true;
            }

            inputs.pointer = isPressed;
            inputs.left = goLeft;
            inputs.right = goRight;
            updateInputActiveState();
        };

        ['touchstart', 'touchmove', 'touchend', 'touchcancel'].forEach(evt => {
            overlay.addEventListener(evt, (e) => {
                e.preventDefault();
                handlePointer(e);
            }, { passive: false });
        });

        ['mousedown', 'mousemove', 'mouseup', 'mouseleave'].forEach(evt => {
            overlay.addEventListener(evt, (e) => {
                if (e.pointerType === 'touch') return;
                e.preventDefault();
                handlePointer(e);
            });
        });
    }
}

function updateInputActiveState() {
    inputs.active = inputs.space || inputs.w || inputs.up || inputs.pointer;
}

// --- AUDIO CONTEXT & INITIALIZATION TRIGGER ---
function initAudioContextTrigger() {
    const trigger = () => {
        initAudioContext();
        document.removeEventListener('click', trigger);
        document.removeEventListener('keydown', trigger);
        document.removeEventListener('touchstart', trigger);
    };
    document.addEventListener('click', trigger);
    document.addEventListener('keydown', trigger);
    document.addEventListener('touchstart', trigger);
}

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

// --- LEVEL THEME & PROGRESSION SYSTEM (100 LEVELS) ---
function getLevelTheme(lvl) {
    if (currentGameMode !== 'classic') {
        return {
            name: 'ENDLESS SURVIVAL',
            color: '#a855f7',
            bgGlow: 'rgba(168, 85, 247, 0.08)',
            boundColor: 'rgba(168, 85, 247, 0.65)',
            particleColor: '#c084fc'
        };
    }

    const level = Math.max(1, Math.min(100, lvl));

    if (level <= 10) {
        return {
            name: `COSMIC PURPLE (${level}/100)`,
            color: '#a855f7',
            bgGlow: 'rgba(168, 85, 247, 0.10)',
            boundColor: 'rgba(168, 85, 247, 0.65)',
            particleColor: '#c084fc'
        };
    } else if (level <= 25) {
        return {
            name: `AMETHYST VIOLET (${level}/100)`,
            color: '#c084fc',
            bgGlow: 'rgba(192, 132, 252, 0.10)',
            boundColor: 'rgba(192, 132, 252, 0.65)',
            particleColor: '#a855f7'
        };
    } else if (level <= 50) {
        return {
            name: `ROYAL INDIGO (${level}/100)`,
            color: '#818cf8',
            bgGlow: 'rgba(129, 140, 248, 0.10)',
            boundColor: 'rgba(129, 140, 248, 0.65)',
            particleColor: '#a855f7'
        };
    } else if (level <= 75) {
        return {
            name: `ELECTRIC NEON (${level}/100)`,
            color: '#d946ef',
            bgGlow: 'rgba(217, 70, 239, 0.10)',
            boundColor: 'rgba(217, 70, 239, 0.65)',
            particleColor: '#c084fc'
        };
    } else if (level <= 99) {
        return {
            name: `CYBER VIOLET (${level}/100)`,
            color: '#38bdf8',
            bgGlow: 'rgba(56, 189, 248, 0.10)',
            boundColor: 'rgba(168, 85, 247, 0.70)',
            particleColor: '#a855f7'
        };
    } else {
        return {
            name: `ENDGAME MAXIMUM (100/100)`,
            color: '#fbbf24',
            bgGlow: 'rgba(251, 191, 36, 0.14)',
            boundColor: 'rgba(251, 191, 36, 0.85)',
            particleColor: '#fbbf24'
        };
    }
}
window.getLevelTheme = getLevelTheme;

// --- STATE COORDINATOR ---
function setGameState(newState) {
    currentGameState = newState;
    window.currentGameState = currentGameState;

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
        lastTime = performance.now();
        physicsAccumulator = 0;
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

    initGameElements();
    setGameState(STATE_PLAYING);
}
window.launchClassicLevel = launchClassicLevel;

function launchEndlessMode() {
    currentGameMode = 'endless';
    attemptCount = 1;
    player.hasCrashedThisRun = false;
    player.lastCoinPayout = 0;

    initGameElements();
    setGameState(STATE_PLAYING);
}
window.launchEndlessMode = launchEndlessMode;

function launchRaceMode() {
    currentGameMode = 'race';
    attemptCount = 1;
    player.hasCrashedThisRun = false;

    initGameElements();
    setGameState(STATE_PLAYING);
}
window.launchRaceMode = launchRaceMode;

// --- GAMEPLAY INITIALIZATION & COURSE GENERATOR ---
function initGameElements() {
    gameTime = 0;
    targetHorizontalOffset = 180;
    currentHorizontalOffset = 180;

    player.x = 150;
    player.y = VIRTUAL_HEIGHT / 2;
    player.vy = 0;
    player.targetVy = 0;
    player.angle = 0;
    player.isDead = false;
    player.trail = [];
    player.particles = [];
    player.speedMultiplier = 1.0;

    player.baseSpeed = 380 + ((currentLevel - 1) * 2.2);

    camera.x = 0;
    camera.y = 0;
    camera.targetY = 0;

    const theme = getLevelTheme(currentLevel);
    const lvlText = document.getElementById('hud-level-text');
    if (lvlText) {
        lvlText.innerText = `LEVEL ${currentLevel} - ${theme.name}`;
    }

    generateCourseObstacles();
    initRaceCompetitors();
    initAmbientDecorations();

    const practiceChk = document.getElementById('practice-mode-chk');
    if (practiceChk && practiceChk.checked && currentPracticeCheckpoint) {
        player.x = currentPracticeCheckpoint.x;
        player.y = currentPracticeCheckpoint.y;
        player.vy = currentPracticeCheckpoint.vy;
        attemptCount = currentPracticeCheckpoint.attempt;
        camera.x = player.x - 180;
        camera.y = player.y - VIRTUAL_HEIGHT / 2;
    }
}

function generateCourseObstacles() {
    obstacles = [];
    levelProgress = 0;

    const theme = getLevelTheme(currentLevel);
    const obsColor = theme.color;

    if (currentGameMode === 'classic' || currentGameMode === 'race') {
        levelLength = 4200 + ((currentLevel - 1) * 85);

        obstacles.push({
            type: 'gate',
            x: 400,
            y: 40,
            width: 16,
            height: VIRTUAL_HEIGHT - 80,
            color: '#ffffff'
        });

        let cursorX = 650;
        const seed = currentLevel * 997 + 389;
        let randVal = Math.sin(seed) * 10000;
        const pseudoRand = () => {
            randVal = Math.sin(randVal) * 10000;
            return randVal - Math.floor(randVal);
        };

        const difficulty = (currentLevel - 1) / 99;
        const gapSpacing = Math.max(150, 340 - (difficulty * 170));
        const minGap = Math.max(130, 240 - (difficulty * 95));

        while (cursorX < levelLength - 700) {
            const roll = pseudoRand();

            if (roll < 0.32) {
                const isCeiling = pseudoRand() < 0.5;
                const spikeCount = currentLevel === 1 ? 1 : Math.floor(pseudoRand() * 3) + 1 + Math.floor(difficulty * 2);
                const spacing = 42;

                for (let i = 0; i < spikeCount; i++) {
                    obstacles.push({
                        type: 'spike',
                        x: cursorX + (i * spacing),
                        y: isCeiling ? 40 : VIRTUAL_HEIGHT - 40,
                        width: 38,
                        height: 48,
                        dir: isCeiling ? 1 : -1,
                        color: obsColor
                    });
                }
                cursorX += (spikeCount * spacing) + gapSpacing;

            } else if (roll < 0.68) {
                const gapY = 190 + pseudoRand() * 200;

                obstacles.push({
                    type: 'block',
                    x: cursorX,
                    y: 40,
                    width: 70 + pseudoRand() * 60,
                    height: gapY - (minGap / 2) - 40,
                    color: obsColor
                });

                obstacles.push({
                    type: 'block',
                    x: cursorX,
                    y: gapY + (minGap / 2),
                    width: 70 + pseudoRand() * 60,
                    height: (VIRTUAL_HEIGHT - 40) - (gapY + (minGap / 2)),
                    color: obsColor
                });

                cursorX += 140 + gapSpacing;

            } else if (roll < 0.88) {
                const blockY = 190 + pseudoRand() * 180;
                const blockW = 80 + pseudoRand() * 90;
                const blockH = 60 + pseudoRand() * 70;

                obstacles.push({
                    type: 'block',
                    x: cursorX,
                    y: blockY,
                    width: blockW,
                    height: blockH,
                    color: obsColor
                });

                if (difficulty > 0.25) {
                    const topSpike = pseudoRand() < 0.5;
                    obstacles.push({
                        type: 'spike',
                        x: cursorX + (blockW / 2) - 18,
                        y: topSpike ? blockY : blockY + blockH,
                        width: 36,
                        height: 36,
                        dir: topSpike ? 1 : -1,
                        color: '#ffffff'
                    });
                }
                cursorX += blockW + gapSpacing;

            } else {
                const centerGapY = 220 + pseudoRand() * 130;
                obstacles.push({
                    type: 'block',
                    x: cursorX,
                    y: 40,
                    width: 140,
                    height: centerGapY - 95,
                    color: obsColor
                });
                obstacles.push({
                    type: 'block',
                    x: cursorX + 210,
                    y: centerGapY + 95,
                    width: 140,
                    height: (VIRTUAL_HEIGHT - 40) - (centerGapY + 95),
                    color: obsColor
                });
                cursorX += 420 + gapSpacing;
            }
        }
    } else {
        levelLength = 99999999;
        generateEndlessBuffer(0, 35000, theme);
    }
}

function generateEndlessBuffer(startX, length, theme) {
    let cursorX = Math.max(startX, 600);
    const endX = startX + length;
    const obsColor = theme ? theme.color : '#a855f7';

    while (cursorX < endX) {
        const roll = Math.random();
        const distScale = Math.min(1.0, cursorX / 30000);
        const gapSpacing = Math.max(150, 290 - (distScale * 110));

        if (roll < 0.3) {
            const isCeiling = Math.random() < 0.5;
            const spikeCount = Math.floor(Math.random() * 3) + 1;
            const spacing = 42;

            for (let i = 0; i < spikeCount; i++) {
                obstacles.push({
                    type: 'spike',
                    x: cursorX + (i * spacing),
                    y: isCeiling ? 40 : VIRTUAL_HEIGHT - 40,
                    width: 38,
                    height: 48,
                    dir: isCeiling ? 1 : -1,
                    color: obsColor
                });
            }
            cursorX += (spikeCount * spacing) + gapSpacing;

        } else if (roll < 0.65) {
            const gapY = 190 + Math.random() * 200;
            const minGap = Math.max(135, 220 - (distScale * 80));

            obstacles.push({
                type: 'block',
                x: cursorX,
                y: 40,
                width: 80 + Math.random() * 70,
                height: gapY - (minGap / 2) - 40,
                color: obsColor
            });

            obstacles.push({
                type: 'block',
                x: cursorX,
                y: gapY + (minGap / 2),
                width: 80 + Math.random() * 70,
                height: (VIRTUAL_HEIGHT - 40) - (gapY + (minGap / 2)),
                color: obsColor
            });
            cursorX += 150 + gapSpacing;

        } else {
            const blockY = 190 + Math.random() * 180;
            const blockW = 80 + Math.random() * 90;
            const blockH = 65 + Math.random() * 70;

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

// --- AMBIENT DECORATIONS ---
function initAmbientDecorations() {
    biomeAmbientParticles = [];
    const count = 35;
    const theme = getLevelTheme(currentLevel);

    for (let i = 0; i < count; i++) {
        biomeAmbientParticles.push(createAmbientParticle(Math.random() * VIRTUAL_WIDTH, theme));
    }
}

function createAmbientParticle(forceX = null, theme = null) {
    if (!theme) theme = getLevelTheme(currentLevel);
    const pX = forceX !== null ? forceX : camera.x + VIRTUAL_WIDTH + Math.random() * 100;
    const pY = 40 + Math.random() * (VIRTUAL_HEIGHT - 80);

    return {
        x: pX,
        y: pY,
        vx: -80 - Math.random() * 40,
        vy: (Math.random() - 0.5) * 30,
        size: 2.5 + Math.random() * 4.5,
        color: theme.particleColor || '#c084fc',
        alpha: 0.15 + Math.random() * 0.35,
        angle: Math.random() * Math.PI,
        spinSpeed: (Math.random() - 0.5) * 1.5
    };
}

function updateAmbientParticles(dt) {
    const theme = getLevelTheme(currentLevel);

    for (let i = biomeAmbientParticles.length - 1; i >= 0; i--) {
        const p = biomeAmbientParticles[i];
        p.x += p.vx * dt;
        p.y += p.vy * dt;
        p.angle += p.spinSpeed * dt;

        if (p.x < camera.x - 100) {
            biomeAmbientParticles.splice(i, 1);
            biomeAmbientParticles.push(createAmbientParticle(null, theme));
        }
    }
}

// --- PLAYER PHYSICS ENGINE ---
function updatePlayerPhysics(dt) {
    if (player.isDead) {
        updatePlayerParticles(dt);
        return;
    }

    const activeBiome = getBiomeForLevel(currentLevel);
    let fallSpeed = 390;
    let floatSpeed = -390;

    if (activeBiome === 'water') {
        fallSpeed = 260;
        floatSpeed = -320;
    } else if (activeBiome === 'space') {
        fallSpeed = 340;
        floatSpeed = -340;
    }

    player.x += player.baseSpeed * player.speedMultiplier * dt;

    if (inputs.left) {
        targetHorizontalOffset = 110;
    } else if (inputs.right) {
        targetHorizontalOffset = 360;
    } else {
        targetHorizontalOffset = 180;
    }

    if (inputs.active) {
        player.targetVy = floatSpeed;
    } else {
        player.targetVy = fallSpeed;
    }

    const lerpAcc = activeBiome === 'water' ? 10.0 : 16.0;
    player.vy = player.targetVy + (player.vy - player.targetVy) * Math.exp(-lerpAcc * dt);
    player.y += player.vy * dt;

    const borderTop = 40;
    const borderBottom = VIRTUAL_HEIGHT - 40;
    if (player.y < borderTop + player.height / 2) {
        player.y = borderTop + player.height / 2;
        player.vy = 0;
    }
    if (player.y > borderBottom - player.height / 2) {
        player.y = borderBottom - player.height / 2;
        player.vy = 0;
    }

    player.angle = Math.atan2(player.vy, player.baseSpeed) * 0.8;

    const skin = typeof window.getActiveSkinDetails === 'function' ? window.getActiveSkinDetails() : VEHICLE_SKINS[0];
    const backAngle = player.angle + Math.PI;
    const backX = player.x + Math.cos(backAngle) * (player.width / 2);
    const backY = player.y + Math.sin(backAngle) * (player.width / 2);

    player.trail.push({ x: backX, y: backY, time: gameTime });

    player.trail = player.trail.filter(pt => gameTime - pt.time < 0.8);

    if (Math.random() < 0.45) {
        createSpark(backX, backY, -player.vy * 0.25, skin);
    }

    updatePlayerParticles(dt);
}

function createSpark(x, y, vyOffset, skin) {
    player.particles.push({
        x: x,
        y: y,
        vx: -player.baseSpeed * 0.35 + (Math.random() - 0.5) * 60,
        vy: vyOffset + (Math.random() - 0.5) * 80,
        size: Math.random() * 3 + 1.2,
        color: skin.particleColor || skin.color,
        alpha: 1.0,
        life: 0.45 + Math.random() * 0.3
    });
}

function updatePlayerParticles(dt) {
    for (let i = player.particles.length - 1; i >= 0; i--) {
        const p = player.particles[i];
        p.x += p.vx * dt;
        p.y += p.vy * dt;
        p.life -= dt;
        p.alpha = Math.max(0, p.life);

        if (p.life <= 0) {
            player.particles.splice(i, 1);
        }
    }
}

function triggerCrashExplosion() {
    if (player.isDead) return;

    player.isDead = true;
    player.vy = 0;
    player.hasCrashedThisRun = true;

    stopSynthMusic();
    playCrashSound();

    if (typeof window.updateStatsOnCrash === 'function') {
        window.updateStatsOnCrash();
    }

    const skin = typeof window.getActiveSkinDetails === 'function' ? window.getActiveSkinDetails() : VEHICLE_SKINS[0];
    const burstCount = 40;
    for (let i = 0; i < burstCount; i++) {
        const angle = Math.random() * Math.PI * 2;
        const spd = Math.random() * 260 + 80;
        player.particles.push({
            x: player.x,
            y: player.y,
            vx: Math.cos(angle) * spd,
            vy: Math.sin(angle) * spd,
            size: Math.random() * 5 + 2,
            color: skin.color,
            alpha: 1.0,
            life: 0.8 + Math.random() * 0.6
        });
    }

    const practiceChk = document.getElementById('practice-mode-chk');
    if (practiceChk && practiceChk.checked && currentPracticeCheckpoint) {
        setTimeout(() => {
            if (currentGameState === STATE_PLAYING) {
                respawnAtPracticeCheckpoint();
            }
        }, 600);
        return;
    }

    setTimeout(() => {
        if (currentGameState === STATE_PLAYING) {
            triggerGameOverScreen();
        }
    }, 1000);
}

function respawnAtPracticeCheckpoint() {
    if (!currentPracticeCheckpoint) return;
    player.x = currentPracticeCheckpoint.x;
    player.y = currentPracticeCheckpoint.y;
    player.vy = 0;
    player.targetVy = 0;
    player.isDead = false;
    player.particles = [];
    player.trail = [];
    camera.x = player.x - 180;
    camera.y = player.y - VIRTUAL_HEIGHT / 2;
    startSynthMusic();
}

function updateCamera(dt) {
    currentHorizontalOffset = targetHorizontalOffset + (currentHorizontalOffset - targetHorizontalOffset) * Math.exp(-6 * dt);
    camera.x = player.x - currentHorizontalOffset;

    camera.targetY = player.y - VIRTUAL_HEIGHT / 2;
    const limit = 100;
    if (camera.targetY < -limit) camera.targetY = -limit;
    if (camera.targetY > limit) camera.targetY = limit;

    camera.y = camera.targetY + (camera.y - camera.targetY) * Math.exp(-8 * dt);
}

// --- COLLISIONS ---
function updateLevelAndCollisions() {
    if (player.isDead) return;

    if (currentGameMode === 'classic') {
        const startX = 150;
        const totalDist = levelLength - 700 - startX;
        const currentDist = player.x - startX;
        levelProgress = Math.max(0, Math.min(100, (currentDist / totalDist) * 100));

        const theme = getLevelTheme(currentLevel);
        const bar = document.getElementById('hud-progress-bar');
        const text = document.getElementById('hud-progress-text');
        const lvl = document.getElementById('hud-level-text');
        if (bar) bar.style.width = `${levelProgress}%`;
        if (text) text.innerText = `${Math.floor(levelProgress)}%`;
        if (lvl) lvl.innerText = `LEVEL ${currentLevel} - ${theme.name}`;

        if (player.x >= levelLength - 700) {
            triggerLevelCleared();
        }
    } else if (currentGameMode === 'endless') {
        const startX = 150;
        const mDist = Math.floor((player.x - startX) / 10);
        levelProgress = mDist;

        const bar = document.getElementById('hud-progress-bar');
        const text = document.getElementById('hud-progress-text');
        const lvl = document.getElementById('hud-level-text');
        if (bar) bar.style.width = '100%';
        if (text) text.innerText = `${mDist}m`;
        if (lvl) lvl.innerText = `Endless Survival`;

        if (obstacles.length > 0 && obstacles[0].x < player.x - 1200) {
            obstacles = obstacles.filter(o => o.x >= player.x - 1200);
        }

        const lastObsX = obstacles.length > 0 ? obstacles[obstacles.length - 1].x : player.x;
        if (lastObsX < player.x + 3000) {
            generateEndlessBuffer(lastObsX + 250, 10000, getLevelTheme(currentLevel));
        }

        if (mDist > 0 && mDist % 20 === 0) {
            if (!player.lastCoinPayout || player.lastCoinPayout < mDist) {
                player.lastCoinPayout = mDist;
                if (window.UI_STATE) {
                    window.UI_STATE.ploCoins += 1;
                    if (typeof window.saveStateItem === 'function') {
                        window.saveStateItem(window.KEYS.COINS, window.UI_STATE.ploCoins);
                    }
                    if (typeof window.renderHeaderWidgets === 'function') {
                        window.renderHeaderWidgets();
                    }
                }
            }
        }
    }

    const pW = player.width * 0.55;
    const pH = player.height * 0.55;
    const pX = player.x - pW / 2;
    const pY = player.y - pH / 2;

    for (const obs of obstacles) {
        if (obs.x < player.x - 80) continue;
        if (obs.x > player.x + 220) continue;

        if (obs.type === 'spike') {
            if (rectsIntersect(pX, pY, pW, pH, obs.x, obs.dir === 1 ? obs.y : obs.y - obs.height, obs.width, obs.height)) {
                if (playerSpikeCollision(obs)) {
                    triggerCrashExplosion();
                    break;
                }
            }
        } else if (obs.type === 'block') {
            if (rectsIntersect(pX, pY, pW, pH, obs.x, obs.y, obs.width, obs.height)) {
                triggerCrashExplosion();
                break;
            }
        }
    }

    const crashTop = player.y - pH / 2 <= 42;
    const crashBot = player.y + pH / 2 >= VIRTUAL_HEIGHT - 42;
    if (crashTop || crashBot) {
        triggerCrashExplosion();
    }
}

function rectsIntersect(x1, y1, w1, h1, x2, y2, w2, h2) {
    return x1 < x2 + w2 && x1 + w1 > x2 && y1 < y2 + h2 && y1 + h1 > y2;
}

function playerSpikeCollision(spike) {
    const tipY = spike.dir === 1 ? spike.y + spike.height : spike.y - spike.height;
    const tipX = spike.x + spike.width / 2;
    const baseX1 = spike.x;
    const baseY1 = spike.y;
    const baseX2 = spike.x + spike.width;
    const baseY2 = spike.y;

    const corners = [
        { x: player.x, y: player.y },
        { x: player.x + player.width * 0.2, y: player.y },
        { x: player.x - player.width * 0.2, y: player.y }
    ];

    for (const p of corners) {
        if (pointInTriangle(p.x, p.y, baseX1, baseY1, baseX2, baseY2, tipX, tipY)) {
            return true;
        }
    }
    return false;
}

function pointInTriangle(px, py, x1, y1, x2, y2, x3, y3) {
    const areaOrig = Math.abs((x1 * (y2 - y3) + x2 * (y3 - y1) + x3 * (y1 - y2)) / 2);
    const a1 = Math.abs((px * (y2 - y3) + x2 * (y3 - py) + x3 * (py - y2)) / 2);
    const a2 = Math.abs((x1 * (py - y3) + px * (y3 - y1) + x3 * (y1 - py)) / 2);
    const a3 = Math.abs((x1 * (y2 - py) + x2 * (py - y1) + px * (y1 - y2)) / 2);
    return Math.abs(areaOrig - (a1 + a2 + a3)) < 0.1;
}

// --- WIN & GAMEOVER TRIGGERS ---
function triggerGameOverScreen() {
    setGameState(STATE_GAMEOVER);

    const progEl = document.getElementById('fail-progress-val');
    const scoreEl = document.getElementById('fail-score-val');

    if (currentGameMode === 'classic') {
        if (progEl) progEl.innerText = `${Math.floor(levelProgress)}%`;
        if (scoreEl) scoreEl.innerText = `Level ${currentLevel}`;
    } else if (currentGameMode === 'endless') {
        if (progEl) progEl.innerText = `${Math.floor(levelProgress)}m`;
        if (scoreEl) scoreEl.innerText = `Best: ${window.UI_STATE ? window.UI_STATE.highScore : 0}m`;

        if (window.UI_STATE && levelProgress > window.UI_STATE.highScore) {
            window.UI_STATE.highScore = levelProgress;
            if (typeof window.saveStateItem === 'function') {
                window.saveStateItem(window.KEYS.HIGH_SCORE, window.UI_STATE.highScore);
            }
            if (scoreEl) scoreEl.innerText = `New Best: ${levelProgress}m!`;
        }
    } else {
        if (progEl) progEl.innerText = `Tournament Crash`;
        if (scoreEl) scoreEl.innerText = `Bot Race`;
    }

    const modal = document.getElementById('gameover-modal');
    if (modal) modal.classList.add('active');
}

function triggerLevelCleared() {
    setGameState(STATE_VICTORY);
    stopSynthMusic();
    playClearedSound();

    if (currentGameMode === 'classic') {
        const modeEl = document.getElementById('win-mode-val');
        const attEl = document.getElementById('win-attempts-val');
        if (modeEl) modeEl.innerText = `Level ${currentLevel} Cleared!`;
        if (attEl) attEl.innerText = attemptCount;

        const isPerfect = attemptCount === 1 && !player.hasCrashedThisRun;
        if (typeof window.updateStatsOnWin === 'function') {
            window.updateStatsOnWin(currentLevel, isPerfect);
        }

        const nextBtn = document.getElementById('win-next-btn');
        if (nextBtn) nextBtn.style.display = currentLevel < 100 ? 'block' : 'none';
    }

    const modal = document.getElementById('win-modal');
    if (modal) modal.classList.add('active');
}

// --- PRACTICE MODE ---
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
        vy: player.vy,
        attempt: attemptCount
    };

    if (typeof window.showToast === 'function') {
        window.showToast('Checkpoint placed!', 'info');
    }

    for (let i = 0; i < 12; i++) {
        const angle = (i / 12) * Math.PI * 2;
        player.particles.push({
            x: player.x,
            y: player.y,
            vx: Math.cos(angle) * 110,
            vy: Math.sin(angle) * 110,
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
    if (typeof window.showToast === 'function') {
        window.showToast('Checkpoints cleared', 'info');
    }
}
window.clearCheckpoints = clearCheckpoints;

// --- RACE MODE BOT AI ---
function initRaceCompetitors() {
    bots = [];
    const lb = document.getElementById('race-leaderboard');
    if (currentGameMode !== 'race') {
        if (lb) lb.classList.remove('active');
        return;
    }

    if (lb) lb.classList.add('active');

    const names = ["AeroBot", "HexRunner", "NeonDash", "GridCrasher"];
    const colors = ["#ff007f", "#ffaa00", "#b026ff", "#00f3ff"];

    for (let i = 0; i < 4; i++) {
        bots.push({
            name: names[i],
            x: 150,
            y: 200 + i * 80,
            vy: 0,
            width: 28,
            height: 20,
            angle: 0,
            color: colors[i],
            baseSpeed: 380 + Math.random() * 25,
            isDead: false,
            lastDecisionTime: gameTime,
            decisionInterval: 0.12 + Math.random() * 0.1,
            trail: [],
            targetVy: 390
        });
    }
}

function updateBots(dt) {
    if (currentGameMode !== 'race') return;

    for (const bot of bots) {
        if (bot.isDead) continue;

        bot.x += bot.baseSpeed * dt;

        if (gameTime - bot.lastDecisionTime > bot.decisionInterval) {
            bot.lastDecisionTime = gameTime;
            makeAIBotDecision(bot);
        }

        bot.vy = bot.targetVy + (bot.vy - bot.targetVy) * Math.exp(-14 * dt);
        bot.y += bot.vy * dt;

        const borderTop = 40;
        const borderBottom = VIRTUAL_HEIGHT - 40;
        if (bot.y < borderTop + bot.height / 2) {
            bot.y = borderTop + bot.height / 2;
            bot.vy = 0;
        }
        if (bot.y > borderBottom - bot.height / 2) {
            bot.y = borderBottom - bot.height / 2;
            bot.vy = 0;
        }

        bot.angle = Math.atan2(bot.vy, bot.baseSpeed) * 0.8;
        bot.trail.push({ x: bot.x, y: bot.y, time: gameTime });
        bot.trail = bot.trail.filter(pt => gameTime - pt.time < 0.5);

        checkBotCollisions(bot);
    }

    updateRaceLeaderboardRows();
}

function makeAIBotDecision(bot) {
    const lookahead = 240;
    let obstacleInPath = null;

    for (const obs of obstacles) {
        if (obs.x > bot.x && obs.x < bot.x + lookahead) {
            if (obs.type === 'block') {
                if (bot.y > obs.y - 40 && bot.y < obs.y + obs.height + 40) {
                    obstacleInPath = obs;
                    break;
                }
            } else if (obs.type === 'spike') {
                const isCeiling = obs.dir === 1;
                if (isCeiling && bot.y < 180) {
                    obstacleInPath = obs;
                    break;
                }
                if (!isCeiling && bot.y > VIRTUAL_HEIGHT - 180) {
                    obstacleInPath = obs;
                    break;
                }
            }
        }
    }

    if (obstacleInPath) {
        if (obstacleInPath.type === 'block') {
            const ceilingDist = obstacleInPath.y - 40;
            const floorDist = (VIRTUAL_HEIGHT - 40) - (obstacleInPath.y + obstacleInPath.height);
            bot.targetVy = ceilingDist > floorDist ? -390 : 390;
        } else {
            bot.targetVy = obstacleInPath.dir === 1 ? 390 : -390;
        }
    } else {
        if (bot.y < 160) bot.targetVy = 390;
        else if (bot.y > VIRTUAL_HEIGHT - 160) bot.targetVy = -390;
        else if (Math.random() < 0.15) bot.targetVy = -bot.targetVy;
    }
}

function checkBotCollisions(bot) {
    const bW = bot.width * 0.6;
    const bH = bot.height * 0.6;
    const bX = bot.x - bW / 2;
    const bY = bot.y - bH / 2;

    for (const obs of obstacles) {
        if (obs.x < bot.x - 50) continue;
        if (obs.x > bot.x + 150) continue;

        if (obs.type === 'block') {
            if (rectsIntersect(bX, bY, bW, bH, obs.x, obs.y, obs.width, obs.height)) {
                bot.isDead = true;
                break;
            }
        } else if (obs.type === 'spike') {
            if (rectsIntersect(bX, bY, bW, bH, obs.x, obs.dir === 1 ? obs.y : obs.y - obs.height, obs.width, obs.height)) {
                bot.isDead = true;
                break;
            }
        }
    }
}

function updateRaceLeaderboardRows() {
    if (currentGameMode !== 'race') return;

    const racers = [];
    racers.push({ name: "YOU", x: player.x, isDead: player.isDead, color: 'var(--neon-green)' });

    bots.forEach(b => {
        racers.push({ name: b.name, x: b.x, isDead: b.isDead, color: b.color });
    });

    racers.sort((a, b) => b.x - a.x);

    const list = document.getElementById('leaderboard-list');
    if (!list) return;
    list.innerHTML = '';

    racers.forEach((runner, i) => {
        const rRow = document.createElement('div');
        rRow.className = `leaderboard-row ${runner.name === 'YOU' ? 'player' : ''}`;
        rRow.style.color = runner.isDead ? '#556c6a' : runner.color;

        rRow.innerHTML = `
            <span>${i + 1}. ${runner.name}</span>
            <span>${runner.isDead ? 'CRASHED' : Math.floor(runner.x / 10) + 'm'}</span>
        `;
        list.appendChild(rRow);
    });

    if (!player.isDead && player.x >= levelLength - 700) {
        const index = racers.findIndex(r => r.name === 'YOU');
        if (index === 0) {
            raceWinsCount++;
            if (window.UI_STATE) {
                window.UI_STATE.raceWins = (window.UI_STATE.raceWins || 0) + 1;
                window.UI_STATE.ploCoins += 200;
                if (typeof window.saveStateItem === 'function') {
                    window.saveStateItem(window.KEYS.RACE_WINS, window.UI_STATE.raceWins);
                    window.saveStateItem(window.KEYS.COINS, window.UI_STATE.ploCoins);
                }
            }
            triggerLevelCleared();
        } else {
            setGameState(STATE_GAMEOVER);
            const failProg = document.getElementById('fail-progress-val');
            const failScore = document.getElementById('fail-score-val');
            if (failProg) failProg.innerText = `Finished #${index + 1}`;
            if (failScore) failScore.innerText = `Winner: ${racers[0].name}`;
            const gModal = document.getElementById('gameover-modal');
            if (gModal) gModal.classList.add('active');
        }
    }
}

// --- SYNTHESIZED WEB AUDIO API SOUNDTRACK ---
function startSynthMusic() {
    if (isMuted) return;
    initAudioContext();
    stopSynthMusic();

    synthBeatsCount = 0;
    synthIntervalId = setInterval(() => {
        if (currentGameState !== STATE_PLAYING || isMuted) return;
        playSynthStep();
    }, 200);
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
        const step = synthBeatsCount % 16;
        synthBeatsCount++;

        if (step % 4 === 0) playKick();
        if (step % 4 === 2) playHiHat();

        const melody = [55, 55, 65, 55, 58, 55, 62, 58, 55, 55, 65, 55, 58, 65, 70, 65];
        playBass(melody[step]);

        if (step === 7 || step === 15) {
            if (Math.random() < 0.5) playLaser(melody[step] * 3.5);
        }
    } catch (e) {}
}

function playKick() {
    if (!audioCtx || isMuted) return;
    const osc = audioCtx.createOscillator();
    const gain = audioCtx.createGain();

    osc.connect(gain);
    gain.connect(audioCtx.destination);

    osc.frequency.setValueAtTime(140, audioCtx.currentTime);
    osc.frequency.exponentialRampToValueAtTime(0.01, audioCtx.currentTime + 0.12);

    gain.gain.setValueAtTime(0.25, audioCtx.currentTime);
    gain.gain.exponentialRampToValueAtTime(0.001, audioCtx.currentTime + 0.13);

    osc.start(audioCtx.currentTime);
    osc.stop(audioCtx.currentTime + 0.14);
}

function playHiHat() {
    if (!audioCtx || isMuted) return;
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

function playBass(freq) {
    if (!audioCtx || isMuted) return;
    const osc = audioCtx.createOscillator();
    const gain = audioCtx.createGain();

    osc.type = 'sawtooth';
    osc.frequency.setValueAtTime(freq, audioCtx.currentTime);
    osc.frequency.exponentialRampToValueAtTime(freq * 0.98, audioCtx.currentTime + 0.16);

    const filter = audioCtx.createBiquadFilter();
    filter.type = 'lowpass';
    filter.frequency.value = 600;

    osc.connect(filter);
    filter.connect(gain);
    gain.connect(audioCtx.destination);

    gain.gain.setValueAtTime(0.09, audioCtx.currentTime);
    gain.gain.exponentialRampToValueAtTime(0.001, audioCtx.currentTime + 0.17);

    osc.start(audioCtx.currentTime);
    osc.stop(audioCtx.currentTime + 0.18);
}

function playLaser(freq) {
    if (!audioCtx || isMuted) return;
    const osc = audioCtx.createOscillator();
    const gain = audioCtx.createGain();

    osc.type = 'square';
    osc.frequency.setValueAtTime(freq, audioCtx.currentTime);
    osc.frequency.exponentialRampToValueAtTime(freq * 0.2, audioCtx.currentTime + 0.12);

    const filter = audioCtx.createBiquadFilter();
    filter.type = 'bandpass';
    filter.frequency.value = 1200;

    osc.connect(filter);
    filter.connect(gain);
    gain.connect(audioCtx.destination);

    gain.gain.setValueAtTime(0.03, audioCtx.currentTime);
    gain.gain.exponentialRampToValueAtTime(0.001, audioCtx.currentTime + 0.13);

    osc.start(audioCtx.currentTime);
    osc.stop(audioCtx.currentTime + 0.14);
}

function playCrashSound() {
    if (!audioCtx || isMuted) return;
    try {
        const osc = audioCtx.createOscillator();
        const gain = audioCtx.createGain();

        osc.type = 'triangle';
        osc.frequency.setValueAtTime(140, audioCtx.currentTime);
        osc.frequency.exponentialRampToValueAtTime(10, audioCtx.currentTime + 0.7);

        gain.gain.setValueAtTime(0.35, audioCtx.currentTime);
        gain.gain.exponentialRampToValueAtTime(0.001, audioCtx.currentTime + 0.75);

        osc.connect(gain);
        gain.connect(audioCtx.destination);

        osc.start(audioCtx.currentTime);
        osc.stop(audioCtx.currentTime + 0.8);
    } catch (e) {}
}

function playClearedSound() {
    if (!audioCtx || isMuted) return;
    try {
        const chord = [329.63, 392.00, 523.25, 659.25];
        const now = audioCtx.currentTime;

        chord.forEach((note, idx) => {
            const osc = audioCtx.createOscillator();
            const gain = audioCtx.createGain();

            osc.type = 'sine';
            osc.frequency.setValueAtTime(note, now + idx * 0.08);
            osc.frequency.exponentialRampToValueAtTime(note * 1.5, now + idx * 0.08 + 0.35);

            gain.gain.setValueAtTime(0.1, now + idx * 0.08);
            gain.gain.exponentialRampToValueAtTime(0.001, now + idx * 0.08 + 0.45);

            osc.connect(gain);
            gain.connect(audioCtx.destination);

            osc.start(now + idx * 0.08);
            osc.stop(now + idx * 0.08 + 0.5);
        });
    } catch (e) {}
}

function playCheckpointSound() {
    if (!audioCtx || isMuted) return;
    try {
        const osc = audioCtx.createOscillator();
        const gain = audioCtx.createGain();

        osc.type = 'sine';
        osc.frequency.setValueAtTime(523.25, audioCtx.currentTime);
        osc.frequency.setValueAtTime(783.99, audioCtx.currentTime + 0.05);

        gain.gain.setValueAtTime(0.12, audioCtx.currentTime);
        gain.gain.exponentialRampToValueAtTime(0.001, audioCtx.currentTime + 0.2);

        osc.connect(gain);
        gain.connect(audioCtx.destination);

        osc.start(audioCtx.currentTime);
        osc.stop(audioCtx.currentTime + 0.22);
    } catch (e) {}
}
window.playCheckpointSound = playCheckpointSound;

function toggleAudio() {
    isMuted = !isMuted;
    const label = isMuted ? '<span>🔇</span> AUDIO: OFF' : '<span>🔊</span> AUDIO: ON';
    const settingsBtn = document.getElementById('settings-audio-toggle');
    if (settingsBtn) settingsBtn.innerHTML = label;
    if (isMuted) stopSynthMusic();
    else if (currentGameState === STATE_PLAYING) startSynthMusic();
}
window.toggleAudio = toggleAudio;

// --- MODAL ACTIONS ---
function pauseGame() {
    if (currentGameState !== STATE_PLAYING) return;
    currentGameState = STATE_PAUSED;
    stopSynthMusic();

    const prog = document.getElementById('pause-progress-val');
    const mode = document.getElementById('pause-mode-val');
    if (prog) prog.innerText = `${Math.floor(levelProgress)}%`;
    if (mode) mode.innerText = currentGameMode.toUpperCase();

    const modal = document.getElementById('pause-modal');
    if (modal) modal.classList.add('active');
}
window.pauseGame = pauseGame;

function resumeGame() {
    if (currentGameState !== STATE_PAUSED) return;
    hideAllModals();
    currentGameState = STATE_PLAYING;
    lastTime = performance.now();
    physicsAccumulator = 0;
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
    openMainMenu();
}
window.quitToMenu = quitToMenu;

function nextLevel() {
    hideAllModals();
    if (currentLevel < 100) {
        launchClassicLevel(currentLevel + 1);
    } else {
        openLevelSelect();
    }
}
window.nextLevel = nextLevel;

// --- MAIN LOOP ---
function gameLoop(time) {
    if (!lastTime) lastTime = time;
    let frameTime = (time - lastTime) / 1000;
    lastTime = time;

    if (frameTime > 0.1) frameTime = 0.1;

    if (currentGameState === STATE_PLAYING) {
        physicsAccumulator += frameTime;
        while (physicsAccumulator >= FIXED_TIMESTEP) {
            update(FIXED_TIMESTEP);
            physicsAccumulator -= FIXED_TIMESTEP;
        }
    } else {
        physicsAccumulator = 0;
    }

    render();

    requestAnimationFrame(gameLoop);
}

function update(dt) {
    if (currentGameState !== STATE_PLAYING) return;

    gameTime += dt;
    updatePlayerPhysics(dt);
    updateBots(dt);
    updateLevelAndCollisions();
    updateCamera(dt);
    updateAmbientParticles(dt);

    bgScrollX = camera.x;
    bgScrollY = camera.y;
}

function render() {
    if (!ctx || !canvas) return;

    ctx.clearRect(0, 0, canvas.width, canvas.height);

    if (hexPatternCanvas) {
        ctx.save();
        const left = -(bgScrollX * 0.3) % hexPatternWidth;
        const top = -(bgScrollY * 0.3) % hexPatternHeight;

        ctx.fillStyle = ctx.createPattern(hexPatternCanvas, 'repeat');
        ctx.translate(left, top);
        ctx.fillRect(-left, -top, canvas.width, canvas.height);
        ctx.restore();
    }

    ctx.save();
    ctx.translate(offsetX, offsetY);
    ctx.scale(scale, scale);

    ctx.save();
    ctx.beginPath();
    ctx.rect(0, 0, VIRTUAL_WIDTH, VIRTUAL_HEIGHT);
    ctx.clip();

    drawBiomeWeatherGlow(ctx);
    drawAmbientDecorations(ctx);

    ctx.save();
    ctx.translate(-camera.x, -camera.y);

    const theme = getLevelTheme(currentLevel);
    const boundCol = theme.boundColor || 'rgba(168, 85, 247, 0.65)';

    ctx.strokeStyle = boundCol;
    ctx.lineWidth = 4;
    ctx.shadowBlur = 12;
    ctx.shadowColor = boundCol;

    ctx.beginPath();
    ctx.moveTo(camera.x - 200, 40);
    ctx.lineTo(camera.x + VIRTUAL_WIDTH + 200, 40);
    ctx.stroke();

    ctx.beginPath();
    ctx.moveTo(camera.x - 200, VIRTUAL_HEIGHT - 40);
    ctx.lineTo(camera.x + VIRTUAL_WIDTH + 200, VIRTUAL_HEIGHT - 40);
    ctx.stroke();

    drawObstacles(ctx);
    drawBots(ctx);
    drawPlayer(ctx);

    ctx.restore();
    ctx.restore();
    ctx.restore();
}

function drawObstacles(ctx) {
    ctx.save();

    for (const obs of obstacles) {
        if (obs.x < camera.x - 100 || obs.x > camera.x + VIRTUAL_WIDTH + 100) continue;

        ctx.shadowBlur = 10;
        ctx.shadowColor = obs.color;

        if (obs.type === 'spike') {
            ctx.strokeStyle = '#ffffff';
            ctx.lineWidth = 2.2;
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
            ctx.lineWidth = 2.2;
            ctx.fillStyle = 'rgba(2, 6, 6, 0.95)';

            ctx.fillRect(obs.x, obs.y, obs.width, obs.height);
            ctx.strokeRect(obs.x, obs.y, obs.width, obs.height);

            ctx.strokeStyle = obs.color;
            ctx.lineWidth = 1.4;
            ctx.strokeRect(obs.x + 3, obs.y + 3, obs.width - 6, obs.height - 6);

        } else if (obs.type === 'gate') {
            ctx.strokeStyle = '#ffffff';
            ctx.lineWidth = 4;
            ctx.fillStyle = 'rgba(0, 243, 255, 0.35)';
            ctx.fillRect(obs.x, obs.y, obs.width, obs.height);
            ctx.strokeRect(obs.x, obs.y, obs.width, obs.height);
        }
    }

    ctx.restore();
}

function drawPlayer(ctx) {
    if (player.isDead) {
        drawPlayerParticles(ctx);
        return;
    }

    const skin = typeof window.getActiveSkinDetails === 'function' ? window.getActiveSkinDetails() : VEHICLE_SKINS[0];

    drawPlayerTrail(ctx, skin);

    ctx.save();
    ctx.translate(player.x, player.y);
    ctx.rotate(player.angle);

    const glowGrad = ctx.createRadialGradient(0, 0, 2, 0, 0, player.width);
    glowGrad.addColorStop(0, skin.color);
    glowGrad.addColorStop(1, 'transparent');
    ctx.fillStyle = glowGrad;
    ctx.beginPath();
    ctx.arc(0, 0, player.width, 0, Math.PI * 2);
    ctx.fill();

    ctx.strokeStyle = '#ffffff';
    ctx.lineWidth = 2.4;
    ctx.fillStyle = 'rgba(2, 6, 6, 0.9)';
    ctx.shadowColor = skin.color;
    ctx.shadowBlur = 12;

    ctx.beginPath();
    ctx.moveTo(player.width / 2, 0);
    ctx.lineTo(-player.width / 2, -player.height / 2);
    ctx.lineTo(-player.width / 4, 0);
    ctx.lineTo(-player.width / 2, player.height / 2);
    ctx.closePath();
    ctx.fill();
    ctx.stroke();

    ctx.strokeStyle = skin.trailColor;
    ctx.lineWidth = 1.4;
    ctx.beginPath();
    ctx.moveTo(player.width / 4, 0);
    ctx.lineTo(-player.width / 4, -player.height / 4);
    ctx.lineTo(-player.width / 6, 0);
    ctx.lineTo(-player.width / 4, player.height / 4);
    ctx.closePath();
    ctx.stroke();

    ctx.restore();
    drawPlayerParticles(ctx);
}

function drawPlayerTrail(ctx, skin) {
    if (player.trail.length < 2) return;

    ctx.save();
    ctx.shadowBlur = 10;
    ctx.shadowColor = skin.trailColor;

    if (skin.trailType === 'rainbow') {
        ctx.lineWidth = 3.5;
        for (let i = 1; i < player.trail.length; i++) {
            const pt1 = player.trail[i - 1];
            const pt2 = player.trail[i];
            const age = gameTime - pt2.time;
            const opacity = Math.max(0, 1 - age / 0.8);
            const hue = (i * 14) % 360;
            ctx.strokeStyle = `hsla(${hue}, 100%, 55%, ${opacity * 0.85})`;
            ctx.beginPath();
            ctx.moveTo(pt1.x, pt1.y);
            ctx.lineTo(pt2.x, pt2.y);
            ctx.stroke();
        }
    } else {
        ctx.lineWidth = 3.2;
        for (let i = 1; i < player.trail.length; i++) {
            const pt1 = player.trail[i - 1];
            const pt2 = player.trail[i];
            const age = gameTime - pt2.time;
            const opacity = Math.max(0, 1 - age / 0.8);
            ctx.strokeStyle = skin.trailColor;
            ctx.globalAlpha = opacity * 0.85;
            ctx.beginPath();
            ctx.moveTo(pt1.x, pt1.y);
            ctx.lineTo(pt2.x, pt2.y);
            ctx.stroke();
        }
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

        if (bot.trail.length >= 2) {
            ctx.save();
            ctx.shadowBlur = 8;
            ctx.shadowColor = bot.color;
            ctx.lineWidth = 2.2;
            for (let i = 1; i < bot.trail.length; i++) {
                const pt1 = bot.trail[i - 1];
                const pt2 = bot.trail[i];
                const age = gameTime - pt2.time;
                const opacity = Math.max(0, 1 - age / 0.5);
                ctx.strokeStyle = bot.color;
                ctx.globalAlpha = opacity * 0.75;
                ctx.beginPath();
                ctx.moveTo(pt1.x, pt1.y);
                ctx.lineTo(pt2.x, pt2.y);
                ctx.stroke();
            }
            ctx.restore();
        }

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

function drawAmbientDecorations(ctx) {
    ctx.save();
    biomeAmbientParticles.forEach(p => {
        ctx.globalAlpha = p.alpha;
        ctx.fillStyle = p.color;
        ctx.beginPath();
        ctx.arc(p.x, p.y, p.size, 0, Math.PI * 2);
        ctx.fill();
    });
    ctx.restore();
}

function drawBiomeWeatherGlow(ctx) {
    const theme = getLevelTheme(currentLevel);
    ctx.save();
    ctx.fillStyle = theme.bgGlow;
    ctx.fillRect(0, 0, VIRTUAL_WIDTH, VIRTUAL_HEIGHT);
    ctx.restore();
}
