// --- CORE GAME STATE AND PHYSICS CONFIG ---
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

// Canvas scaling and dimensions (dynamic responsive canvas)
const canvas = document.getElementById('gameCanvas');
const ctx = canvas.getContext('2d');
let width = 1200;
let height = 675;
let scaleX = 1;
let scaleY = 1;
let scale = 1;
let offsetX = 0;
let offsetY = 0;
let targetHorizontalOffset = 180;
let currentHorizontalOffset = 180;

// Timing
let lastTime = 0;
let deltaTime = 0;

// Inputs
const inputs = {
    active: false,
    space: false,
    w: false,
    pointer: false,
    left: false,
    right: false
};

// Parallax background offsets
let bgScrollX = 0;
let bgScrollY = 0;

// Offscreen Hexagon Grid Canvas for high performance rendering
let hexPatternCanvas = null;
let hexPatternWidth = 256;
let hexPatternHeight = 256;

// LocalStorage keys for endless & race
const SAVE_ENDLESS_HI_SCORE = 'plo_io_endless_hiscore_v2';
const SAVE_RACE_WINS = 'plo_io_race_wins_v2';

// Game stats trackers
let levelProgress = 0; // 0 to 100
let endlessDistance = 0; // meters survived
let raceWinsCount = 0;

// Ambient biome decoration items
let biomeAmbientParticles = []; // e.g., floating leaves, spooky mist/fog, glowing starfields, bubbles, rune spikes

// --- AUDIO SYSTEM (WEB AUDIO API SYNTHESIZER) ---
let audioCtx = null;
let synthIntervalId = null;
let synthBeatsCount = 0;

// --- LEVEL OBSTACLES AND GENERATION ---
let obstacles = []; // array of obstacles
let levelLength = 6000;
let currentPracticeCheckpoint = null; // practice mode saved checkpoint

// --- RACE MODE AI BOT COMPETITORS ---
let bots = []; // competitors list

// --- MULTIPLAYER ROOM LISTENERS ---
let activeMutiplayerRoomId = null;
let multiplayerCompetitors = {}; // competitor uid -> state

// --- PLAYER OBJECT ---
let player = {
    x: 150,
    y: 337.5,
    width: 34,
    height: 26,
    vy: 0,
    targetVy: 0,
    angle: 0,
    baseSpeed: 380,
    speedMultiplier: 1,
    isDead: false,
    trail: [],
    particles: [],
    hasCrashedThisRun: false
};

// Camera
let camera = {
    x: 0,
    y: 0,
    targetY: 0,
};

// --- INITIALIZATION ---
window.addEventListener('load', () => {
    initCanvas();
    createHexagonPattern();
    initInputListeners();
    loadEngineSavedData();
    initUI(); // load profile widgets & shop skins from ui.js

    // Setup first interaction trigger to start audio context & auto fullscreen!
    setupInteractionListeners();

    // Start rendering main loop
    requestAnimationFrame(gameLoop);
});

window.addEventListener('resize', initCanvas);

function initCanvas() {
    // Dynamic Resize Canvas to full visual screens preserving the bounding coordinates
    const container = document.getElementById('game-container');
    const rect = container.getBoundingClientRect();

    canvas.width = rect.width;
    canvas.height = rect.height;

    // Calculate dynamic responsive scale factors maintaining 16:9 aspect ratio
    const targetAspect = width / height;
    const currentAspect = rect.width / rect.height;

    if (currentAspect > targetAspect) {
        // Screen is wider than 16:9
        scale = rect.height / height;
        offsetX = (rect.width - width * scale) / 2;
        offsetY = 0;
    } else {
        // Screen is taller than 16:9
        scale = rect.width / width;
        offsetX = 0;
        offsetY = (rect.height - height * scale) / 2;
    }

    // Fallbacks for coordinate transformations
    scaleX = scale;
    scaleY = scale;
}

// Hybrid Mobile Client Detection Helper
function isMobileDevice() {
    const checkTouch = ('ontouchstart' in window || navigator.maxTouchPoints > 0);
    const checkUA = /Android|webOS|iPhone|iPad|iPod|BlackBerry|IEMobile|Opera Mini/i.test(navigator.userAgent);
    return checkTouch && (checkUA || window.innerWidth < 1024);
}

// setup first interaction to start AudioContext
function setupInteractionListeners() {
    const startTrigger = () => {
        initAudioContext();

        document.removeEventListener('click', startTrigger);
        document.removeEventListener('touchstart', startTrigger);
    };

    document.addEventListener('click', startTrigger);
    document.addEventListener('touchstart', startTrigger);
}

// --- PROCEDURAL BACKGROUND HONEYCOMB ---
function createHexagonPattern() {
    hexPatternCanvas = document.createElement('canvas');
    hexPatternCanvas.width = hexPatternWidth;
    hexPatternCanvas.height = hexPatternHeight;
    const hCtx = hexPatternCanvas.getContext('2d');

    // Draw solid dark background
    hCtx.fillStyle = '#020505';
    hCtx.fillRect(0, 0, hexPatternWidth, hexPatternHeight);

    const r = 24; // hexagon size
    const h = r * Math.sqrt(3);
    const w = r * 1.5;

    hCtx.strokeStyle = 'rgba(0, 243, 255, 0.08)';
    hCtx.lineWidth = 1.2;

    // Drawing hexagons
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

// --- INPUT HANDLERS ---
function initInputListeners() {
    window.addEventListener('keydown', (e) => {
        if (e.code === 'Space') {
            inputs.space = true;
            e.preventDefault();
        }
        if (e.code === 'KeyW' || e.code === 'ArrowUp') {
            inputs.w = true;
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
        }
        if (e.code === 'KeyA' || e.code === 'ArrowLeft') {
            inputs.left = false;
        }
        if (e.code === 'KeyD' || e.code === 'ArrowRight') {
            inputs.right = false;
        }
        updateInputActiveState();
    });

    // Custom touch overlay handler for unified steering + jump controls
    const overlay = document.getElementById('input-overlay');
    if (overlay) {
        const handlePointerInput = (e) => {
            let isPressed = false;
            let goLeft = false;
            let goRight = false;

            const rect = overlay.getBoundingClientRect();
            const widthPixels = rect.width;

            if (e.touches && e.touches.length > 0) {
                isPressed = true;
                for (let i = 0; i < e.touches.length; i++) {
                    const touch = e.touches[i];
                    // clientX relative to the overlay rect
                    const px = touch.clientX - rect.left;
                    if (px < widthPixels * 0.3) {
                        goLeft = true;
                    } else if (px > widthPixels * 0.7) {
                        goRight = true;
                    }
                }
            } else if (!e.touches && (e.buttons & 1)) {
                // Mouse left click held down
                isPressed = true;
                const px = e.clientX - rect.left;
                if (px < widthPixels * 0.3) {
                    goLeft = true;
                } else if (px > widthPixels * 0.7) {
                    goRight = true;
                }
            }

            inputs.pointer = isPressed;
            inputs.left = goLeft;
            inputs.right = goRight;
            updateInputActiveState();
        };

        const events = ['mousedown', 'mousemove', 'mouseup', 'mouseleave', 'touchstart', 'touchmove', 'touchend', 'touchcancel'];
        events.forEach(evt => {
            overlay.addEventListener(evt, (e) => {
                e.preventDefault();
                handlePointerInput(e);
            }, { passive: false });
        });
    }
}

function updateInputActiveState() {
    inputs.active = inputs.space || inputs.w || inputs.pointer;
}

// --- ENGINE RECOVERY DATA ---
function loadEngineSavedData() {
    try {
        const savedHiScore = localStorage.getItem(SAVE_ENDLESS_HI_SCORE);
        if (savedHiScore) {
            endlessDistance = parseInt(savedHiScore, 10);
        }

        const savedRaceWins = localStorage.getItem(SAVE_RACE_WINS);
        if (savedRaceWins) {
            raceWinsCount = parseInt(savedRaceWins, 10);
        }

        updateEngineMenuTags();
    } catch (e) {
        console.error('Error recovery: ', e);
    }
}

function updateEngineMenuTags() {
    const endTag = document.getElementById('endless-high-score-v2');
    if (endTag) endTag.innerText = `Best Survival: ${endlessDistance}m`;

    const raceTag = document.getElementById('race-wins-v2');
    if (raceTag) raceTag.innerText = `Championship Wins: ${raceWinsCount}`;
}

// --- BIOME LEVEL LAUNCHERS ---
function launchClassicLevel(levelNum) {
    currentGameMode = 'classic';
    currentLevel = levelNum;
    attemptCount = 1;
    player.hasCrashedThisRun = false;

    // Reset coordinates and generate course obstacles
    initGameElements();
    setGameState(STATE_PLAYING);
}

/**
 * Launches the multiplayer race mode.
 */
function launchMultiplayerMatch(roomId) {
    currentGameMode = 'multiplayer';
    activeMutiplayerRoomId = roomId;
    attemptCount = 1;
    player.hasCrashedThisRun = false;
    multiplayerCompetitors = {};

    initGameElements();
    setGameState(STATE_PLAYING);

    // Bind real-time RTDB listener for opponent coordinate updates
    import('./google.js').then(({ rtdb }) => {
        import('https://www.gstatic.com/firebasejs/10.7.1/firebase-database.js').then(({ ref, onValue }) => {
            const roomRef = ref(rtdb, `rooms/${roomId}/players`);
            onValue(roomRef, (snapshot) => {
                const playersData = snapshot.val();
                if (!playersData) return;

                import('./google.js').then(({ currentUser }) => {
                    const currentUid = currentUser ? currentUser.uid : null;
                    Object.keys(playersData).forEach(pId => {
                        if (pId !== currentUid) {
                            multiplayerCompetitors[pId] = playersData[pId];
                        }
                    });
                });
            });
        });
    });
}
window.launchMultiplayerMatch = launchMultiplayerMatch;

function launchEndlessMode() {
    currentGameMode = 'endless';
    attemptCount = 1;
    player.hasCrashedThisRun = false;

    initGameElements();
    setGameState(STATE_PLAYING);
}

function launchRaceMode() {
    currentGameMode = 'race';
    attemptCount = 1;
    player.hasCrashedThisRun = false;

    initGameElements();
    setGameState(STATE_PLAYING);
}

// --- STATE COORDINATOR ---
function setGameState(newState) {
    currentGameState = newState;

    const screens = {
        [STATE_MENU]: 'main-menu-screen',
        [STATE_LEVEL_SELECT]: 'level-select-screen',
    };

    // Hide all menu screens
    document.querySelectorAll('.screen').forEach(s => s.classList.add('hidden'));
    document.getElementById('hud').classList.remove('active');
    hideAllModals();

    if (screens[newState]) {
        document.getElementById(screens[newState]).classList.remove('hidden');
    }

    const overlay = document.getElementById('input-overlay');

    if (newState === STATE_PLAYING) {
        document.getElementById('hud').classList.add('active');
        if (overlay) overlay.classList.remove('hidden');
        // Start Synthesizer soundtracks
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

function openMainMenu() {
    setGameState(STATE_MENU);
}

function openLevelSelect() {
    setGameState(STATE_LEVEL_SELECT);
}

// --- GAMEPLAY INITIALIZATION & PROCEDURAL GENERATORS ---
function initGameElements() {
    targetHorizontalOffset = 180;
    currentHorizontalOffset = 180;
    // 2. Initialize Player Parameters
    player.x = 150;
    player.y = 337.5;
    player.vy = 0;
    player.targetVy = 0;
    player.angle = 0;
    player.isDead = false;
    player.trail = [];
    player.particles = [];
    player.speedMultiplier = 1.0;

    // Scale forward speeds with level
    // Up to level 100, speed starts at 380 and scales up to 600 max
    player.baseSpeed = 380 + (currentLevel * 2.2);

    // Apply special Water Biome Physics adjustment
    const activeBiome = getBiomeForLevel(currentLevel);
    if (currentGameMode === 'classic' && activeBiome === 'water') {
        player.baseSpeed *= 0.85; // drag/resistance feel
    }

    camera.x = 0;
    camera.y = 0;
    camera.targetY = 0;

    // 3. Generate Course obstacles based on the Biome theme
    generateThemeLevel();

    // 4. Initialize Race Bots if needed
    initRaceCompetitors();

    // 5. Build ambient weather visual particles
    initAmbientDecorations();

    // Checkpoint recovery in practice mode
    if (document.getElementById('practice-mode-chk').checked && currentPracticeCheckpoint) {
        player.x = currentPracticeCheckpoint.x;
        player.y = currentPracticeCheckpoint.y;
        player.vy = currentPracticeCheckpoint.vy;
        attemptCount = currentPracticeCheckpoint.attempt;
        camera.x = player.x - 180;
        camera.y = player.y - height / 2;
    }
}

function getBiomeForLevel(lvl) {
    if (currentGameMode !== 'classic') {
        // Endless or Race default to active select biome
        return UI_STATE.activeBiome;
    }
    // Map index boundary matching 20 levels per Biome
    if (lvl <= 20) return 'forest';
    if (lvl <= 40) return 'haunted';
    if (lvl <= 60) return 'space';
    if (lvl <= 80) return 'water';
    return 'ancient';
}

function generateThemeLevel() {
    obstacles = [];
    levelProgress = 0;

    const biome = getBiomeForLevel(currentLevel);

    if (currentGameMode === 'classic') {
        // Course length scales up to 15,000 pixels on Level 100!
        levelLength = 5000 + (currentLevel * 100);

        // Place starting block
        obstacles.push({
            type: 'gate',
            x: 400,
            y: 40,
            width: 15,
            height: height - 80,
            color: '#ffffff'
        });

        let cursorX = 700;
        const seed = currentLevel * 888 + 123;
        let randomVal = Math.sin(seed) * 10000;
        const getRand = () => {
            randomVal = Math.sin(randomVal) * 10000;
            return randomVal - Math.floor(randomVal);
        };

        // Biome theme colors
        const colors = {
            forest: 'rgba(0, 255, 102, 0.85)',
            haunted: 'rgba(176, 38, 255, 0.85)',
            space: 'rgba(0, 243, 255, 0.85)',
            water: 'rgba(255, 0, 127, 0.85)',
            ancient: 'rgba(255, 170, 0, 0.85)'
        };
        const obsColor = colors[biome];

        while (cursorX < levelLength - 800) {
            const roll = getRand();
            const difficultyScale = currentLevel / 100; // 0 to 1

            // Adaptive spacing: obstacle layouts compress at higher levels
            const gapSpacing = Math.max(160, 320 - (difficultyScale * 120));

            if (roll < 0.3) {
                // Spikes clusters (ceiling or floor)
                const isCeiling = getRand() < 0.5;
                const spikeCount = Math.floor(getRand() * 3) + 1 + Math.floor(difficultyScale * 2);
                const itemSpacing = 44;

                for (let i = 0; i < spikeCount; i++) {
                    obstacles.push({
                        type: 'spike',
                        x: cursorX + i * itemSpacing,
                        y: isCeiling ? 40 : height - 40,
                        width: 40,
                        height: 50,
                        dir: isCeiling ? 1 : -1,
                        color: obsColor
                    });
                }
                cursorX += (spikeCount * itemSpacing) + gapSpacing;

            } else if (roll < 0.65) {
                // Triple-Blockade gates or columns (gaps gets smaller as level goes up)
                const gapY = 180 + getRand() * 220;
                const minGap = Math.max(130, 240 - (difficultyScale * 90)); // minimum vertical clearance to pass

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

                // Spooky / Mythic floating surprise spikes in high corridors
                if (getRand() < 0.4 && currentLevel > 15) {
                    obstacles.push({
                        type: 'spike',
                        x: cursorX + 15,
                        y: gapY + minGap / 2 - 2,
                        width: 32,
                        height: 34,
                        dir: -1,
                        color: biome === 'haunted' ? '#ff007f' : obsColor
                    });
                }

                cursorX += 150 + gapSpacing;

            } else if (roll < 0.85) {
                // Floating blocks / solid diamonds
                const blockY = 180 + getRand() * 200;
                const blockW = 80 + getRand() * 100;
                const blockH = 60 + getRand() * 80;

                obstacles.push({
                    type: 'block',
                    x: cursorX,
                    y: blockY,
                    width: blockW,
                    height: blockH,
                    color: obsColor
                });

                if (difficultyScale > 0.3) {
                    // Double spikes mounted on floating blocks
                    const topSpike = getRand() < 0.5;
                    obstacles.push({
                        type: 'spike',
                        x: cursorX + blockW / 2 - 18,
                        y: topSpike ? blockY : blockY + blockH,
                        width: 36,
                        height: 36,
                        dir: topSpike ? 1 : -1,
                        color: '#ffffff'
                    });
                }
                cursorX += blockW + gapSpacing;

            } else {
                // Giant diagonal passage slalom
                const centerGapY = 220 + getRand() * 140;
                obstacles.push({
                    type: 'block',
                    x: cursorX,
                    y: 40,
                    width: 150,
                    height: centerGapY - 95,
                    color: obsColor
                });
                obstacles.push({
                    type: 'block',
                    x: cursorX + 220,
                    y: centerGapY + 95,
                    width: 150,
                    height: (height - 40) - (centerGapY + 95),
                    color: obsColor
                });
                cursorX += 450 + gapSpacing;
            }
        }
    } else {
        // Endless Mode: Generate procedural buffers
        levelLength = 99999999;
        generateEndlessThemeBuffer(0, 40000, biome);
    }
}

function generateEndlessThemeBuffer(startX, length, biome) {
    let cursorX = Math.max(startX, 600);
    const endX = startX + length;

    const colors = {
        forest: 'rgba(0, 255, 102, 0.85)',
        haunted: 'rgba(176, 38, 255, 0.85)',
        space: 'rgba(0, 243, 255, 0.85)',
        water: 'rgba(255, 0, 127, 0.85)',
        ancient: 'rgba(255, 170, 0, 0.85)'
    };
    const obsColor = colors[biome];

    while (cursorX < endX) {
        const roll = Math.random();
        // Progressively scale difficulty on endless distance
        const distanceScale = Math.min(1.0, cursorX / 30000);
        const gapSpacing = Math.max(160, 300 - (distanceScale * 110));

        if (roll < 0.25) {
            const isCeiling = Math.random() < 0.5;
            const spikeCount = Math.floor(Math.random() * 3) + 1 + Math.floor(distanceScale * 2);
            const itemSpacing = 44;

            for (let i = 0; i < spikeCount; i++) {
                obstacles.push({
                    type: 'spike',
                    x: cursorX + i * itemSpacing,
                    y: isCeiling ? 40 : height - 40,
                    width: 40,
                    height: 50,
                    dir: isCeiling ? 1 : -1,
                    color: obsColor
                });
            }
            cursorX += (spikeCount * itemSpacing) + gapSpacing;

        } else if (roll < 0.6) {
            const gapY = 180 + Math.random() * 220;
            const minGap = Math.max(140, 220 - (distanceScale * 80));

            obstacles.push({
                type: 'block',
                x: cursorX,
                y: 40,
                width: 80 + Math.random() * 80,
                height: gapY - minGap / 2 - 40,
                color: obsColor
            });

            obstacles.push({
                type: 'block',
                x: cursorX,
                y: gapY + minGap / 2,
                width: 80 + Math.random() * 80,
                height: (height - 40) - (gapY + minGap / 2),
                color: obsColor
            });
            cursorX += 160 + gapSpacing;

        } else if (roll < 0.8) {
            const blockY = 180 + Math.random() * 200;
            const blockW = 80 + Math.random() * 100;
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
        } else {
            const centerGapY = 220 + Math.random() * 140;
            obstacles.push({
                type: 'block',
                x: cursorX,
                y: 40,
                width: 150,
                height: centerGapY - 100,
                color: obsColor
            });
            obstacles.push({
                type: 'block',
                x: cursorX + 220,
                y: centerGapY + 100,
                width: 150,
                height: (height - 40) - (centerGapY + 100),
                color: obsColor
            });
            cursorX += 450 + gapSpacing;
        }
    }
}

// --- WEATHER & AMBIENT DECORATIONS DECORATORS ---
function initAmbientDecorations() {
    biomeAmbientParticles = [];
    // Scale down ambient particle density on mobile to preserve battery life and graphics throughput
    const count = isMobileDevice() ? 12 : 35;
    const biome = getBiomeForLevel(currentLevel);

    for (let i = 0; i < count; i++) {
        biomeAmbientParticles.push(createAmbientParticle(Math.random() * width, biome));
    }
}

function createAmbientParticle(forceX = null, biome = 'forest') {
    const pX = forceX !== null ? forceX : camera.x + width + Math.random() * 100;
    const pY = 40 + Math.random() * (height - 80);

    let p = {
        x: pX,
        y: pY,
        vx: 0,
        vy: 0,
        size: 0,
        color: '',
        alpha: 0.1 + Math.random() * 0.35,
        type: biome,
        angle: Math.random() * Math.PI,
        spinSpeed: (Math.random() - 0.5) * 1.5
    };

    if (biome === 'forest') {
        // Floating green leaves drifting left/down
        p.vx = -120 - Math.random() * 40;
        p.vy = 20 + Math.random() * 30;
        p.size = 6 + Math.random() * 6;
        p.color = Math.random() < 0.5 ? '#00ff66' : '#88ff00';
    } else if (biome === 'haunted') {
        // Drifting spooky mist/fog puffs
        p.vx = -40 - Math.random() * 30;
        p.vy = (Math.random() - 0.5) * 15;
        p.size = 25 + Math.random() * 30;
        p.color = 'rgba(176, 38, 255, 0.15)';
    } else if (biome === 'space') {
        // Glowing starfield particles (shimmering)
        p.vx = -15 - Math.random() * 15;
        p.vy = 0;
        p.size = 1.5 + Math.random() * 2.5;
        p.color = Math.random() < 0.5 ? '#00f3ff' : '#ffffff';
    } else if (biome === 'water') {
        // Bubbles drifting upwards
        p.vx = -80 - Math.random() * 30;
        p.vy = -35 - Math.random() * 30;
        p.size = 3 + Math.random() * 5;
        p.color = 'rgba(255, 255, 255, 0.45)';
    } else if (biome === 'ancient') {
        // Floating golden rune dust sparks
        p.vx = -60 - Math.random() * 40;
        p.vy = (Math.random() - 0.5) * 40;
        p.size = 4 + Math.random() * 4;
        p.color = '#ffaa00';
    }

    return p;
}

function updateAmbientParticles(dt) {
    const biome = getBiomeForLevel(currentLevel);

    for (let i = biomeAmbientParticles.length - 1; i >= 0; i--) {
        const p = biomeAmbientParticles[i];
        p.x += p.vx * dt;
        p.y += p.vy * dt;
        p.angle += p.spinSpeed * dt;

        // If particle scrolls past visual margins left, recycle or wrap
        if (p.x < camera.x - 100) {
            biomeAmbientParticles.splice(i, 1);
            biomeAmbientParticles.push(createAmbientParticle(null, biome));
        }
    }
}

function drawAmbientDecorations(ctx) {
    ctx.save();

    biomeAmbientParticles.forEach(p => {
        ctx.globalAlpha = p.alpha;
        ctx.fillStyle = p.color;

        if (p.type === 'forest') {
            // Draw a leaf shape
            ctx.save();
            ctx.translate(p.x, p.y);
            ctx.rotate(p.angle);
            ctx.beginPath();
            ctx.ellipse(0, 0, p.size, p.size * 0.5, 0, 0, Math.PI * 2);
            ctx.fill();
            ctx.restore();
        } else if (p.type === 'water') {
            // Hollow circular bubble
            ctx.strokeStyle = p.color;
            ctx.lineWidth = 1.2;
            ctx.beginPath();
            ctx.arc(p.x, p.y, p.size, 0, Math.PI * 2);
            ctx.stroke();
        } else {
            // Default spark/glowing circle
            ctx.beginPath();
            ctx.arc(p.x, p.y, p.size, 0, Math.PI * 2);
            ctx.fill();
        }
    });

    ctx.restore();
}

// --- PLAYER PHYSICS ENGINE & PROCEDURAL VEHICLE TRAILS ---
function updatePlayerPhysics(dt) {
    if (player.isDead) {
        updatePlayerParticles(dt);
        return;
    }

    const activeBiome = getBiomeForLevel(currentLevel);

    // If multiplayer mode, periodically sync current coordinates to Firebase RTDB
    if (currentGameMode === 'multiplayer' && activeMutiplayerRoomId) {
        import('./google.js').then(({ rtdb, currentUser }) => {
            if (currentUser) {
                import('https://www.gstatic.com/firebasejs/10.7.1/firebase-database.js').then(({ ref, set }) => {
                    const myPlayerRef = ref(rtdb, `rooms/${activeMutiplayerRoomId}/players/${currentUser.uid}`);
                    set(myPlayerRef, {
                        name: window.UI_STATE.username || "Rider_01",
                        pfp: window.UI_STATE.photoURL || currentUser.photoURL || "",
                        rating: window.UI_STATE.eloRating || 1000,
                        x: player.x,
                        y: player.y,
                        vy: player.vy,
                        angle: player.angle,
                        skin: window.UI_STATE.equippedSkin || "classic",
                        isDead: player.isDead
                    });
                });
            }
        });
    }

    // Apply fluid buoyant water biome drag vertical scaling
    let fallSpeed = 390;
    let floatSpeed = -390;

    if (activeBiome === 'water') {
        // Water has high resistance, giving a buoyant floaty movement feel
        fallSpeed = 240;
        floatSpeed = -310;
    }

    // 1. Horizontal Progression
    player.x += player.baseSpeed * player.speedMultiplier * dt;

    // 1.5 Unified steering: update target horizontal offset based on active inputs
    if (inputs.left) {
        targetHorizontalOffset = 100;
    } else if (inputs.right) {
        targetHorizontalOffset = 380;
    } else {
        targetHorizontalOffset = 180;
    }

    // 2. Direct Diagonal Controls
    if (inputs.active) {
        player.targetVy = floatSpeed;
    } else {
        player.targetVy = fallSpeed;
    }

    // Smooth lerp vertical acceleration feel
    const lerpAcc = activeBiome === 'water' ? 9.0 : 16.0;
    player.vy += (player.targetVy - player.vy) * lerpAcc * dt;
    player.y += player.vy * dt;

    // Boundary containment
    const borderTop = 40;
    const borderBottom = height - 40;
    if (player.y < borderTop + player.height / 2) {
        player.y = borderTop + player.height / 2;
        player.vy = 0;
    }
    if (player.y > borderBottom - player.height / 2) {
        player.y = borderBottom - player.height / 2;
        player.vy = 0;
    }

    // Visual Rotation Angle
    player.angle = Math.atan2(player.vy, player.baseSpeed) * 0.8;

    // 3. Emit custom particle trail based on Shop selections
    const skin = getActiveSkinDetails();

    // Trail offsets
    const backAngle = player.angle + Math.PI;
    const backX = player.x + Math.cos(backAngle) * (player.width / 2);
    const backY = player.y + Math.sin(backAngle) * (player.width / 2);

    player.trail.push({
        x: backX,
        y: backY,
        time: Date.now()
    });

    // Trail cleanup (limit trail lifetime / length on mobile to save rendering throughput)
    const now = Date.now();
    const trailLifetime = isMobileDevice() ? 450 : 900;
    player.trail = player.trail.filter(pt => now - pt.time < trailLifetime);

    // Generate drift micro-sparks from engines
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
        color: skin.particleColor,
        alpha: 1.0,
        life: 0.5 + Math.random() * 0.3
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
    player.isDead = true;
    player.vy = 0;
    player.hasCrashedThisRun = true;

    stopSynthMusic();
    playCrashSound();

    // Deduct rating penalty on UI thread and update local storage balance
    updateStatsOnCrash();

    // Splash burst of skin-themed neon bits (reduced count on mobile)
    const skin = getActiveSkinDetails();
    const burstCount = isMobileDevice() ? 18 : 45;
    for (let i = 0; i < burstCount; i++) {
        const angle = Math.random() * Math.PI * 2;
        const spd = Math.random() * 260 + 80;
        player.particles.push({
            x: player.x,
            y: player.y,
            vx: Math.cos(angle) * spd,
            vy: Math.sin(angle) * spd,
            size: Math.random() * 6 + 2,
            color: skin.color,
            alpha: 1.0,
            life: 1.0 + Math.random() * 0.8
        });
    }

    // Wait and trigger GameOver
    setTimeout(() => {
        if (currentGameState === STATE_PLAYING) {
            triggerGameOverScreen();
        }
    }, 1200);
}

// --- RENDER VEHICLE SKINS & TRAILS ---
function drawPlayer(ctx) {
    if (player.isDead) {
        drawPlayerParticles(ctx);
        return;
    }

    const skin = getActiveSkinDetails();

    // 1. Draw Customized Waves / Trails
    drawPlayerTrail(ctx, skin);

    // 2. Draw vehicle triangle
    ctx.save();
    ctx.translate(player.x, player.y);
    ctx.rotate(player.angle);

    // Back glow
    const glowGrad = ctx.createRadialGradient(0, 0, 2, 0, 0, player.width);
    glowGrad.addColorStop(0, skin.color);
    glowGrad.addColorStop(1, 'transparent');
    ctx.fillStyle = glowGrad;
    ctx.beginPath();
    ctx.arc(0, 0, player.width, 0, Math.PI * 2);
    ctx.fill();

    // Main sharp outer border
    ctx.strokeStyle = '#ffffff';
    ctx.lineWidth = 2.6;
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

    // Draw customizable pattern overlay based on equipped item
    ctx.strokeStyle = skin.trailColor;
    ctx.shadowColor = skin.trailColor;
    ctx.lineWidth = 1.4;
    ctx.beginPath();
    ctx.moveTo(player.width / 4, 0);
    ctx.lineTo(-player.width / 4, -player.height / 4);
    ctx.lineTo(-player.width / 6, 0);
    ctx.lineTo(-player.width / 4, player.height / 4);
    ctx.closePath();
    ctx.stroke();

    ctx.restore();

    // Render combustion sparks
    drawPlayerParticles(ctx);
}

function drawPlayerTrail(ctx, skin) {
    if (player.trail.length < 2) return;

    ctx.save();
    ctx.shadowBlur = 12;
    ctx.shadowColor = skin.trailColor;

    if (skin.trailType === 'particles') {
        // Draw starry spark dust along the trail history
        player.trail.forEach(pt => {
            const age = Date.now() - pt.time;
            const opacity = Math.max(0, 1 - age / 900);
            ctx.fillStyle = skin.trailColor;
            ctx.globalAlpha = opacity * 0.8;
            ctx.beginPath();
            ctx.arc(pt.x, pt.y, 4, 0, Math.PI * 2);
            ctx.fill();
        });
    } else if (skin.trailType === 'shadow') {
        // Triple ghost trail lines
        ctx.lineWidth = 2.0;
        for (let offset = -6; offset <= 6; offset += 6) {
            ctx.beginPath();
            for (let i = 1; i < player.trail.length; i++) {
                const pt1 = player.trail[i - 1];
                const pt2 = player.trail[i];
                const age = Date.now() - pt2.time;
                const opacity = Math.max(0, 1 - age / 900);
                ctx.strokeStyle = skin.trailColor;
                ctx.globalAlpha = opacity * 0.4;
                if (i === 1) ctx.moveTo(pt1.x, pt1.y + offset);
                ctx.lineTo(pt2.x, pt2.y + offset);
            }
            ctx.stroke();
        }
    } else if (skin.trailType === 'rainbow') {
        // Multi-color ribbon
        ctx.lineWidth = 4.0;
        for (let i = 1; i < player.trail.length; i++) {
            const pt1 = player.trail[i - 1];
            const pt2 = player.trail[i];
            const age = Date.now() - pt2.time;
            const opacity = Math.max(0, 1 - age / 900);
            const hue = (i * 12) % 360;
            ctx.strokeStyle = `hsla(${hue}, 100%, 50%, ${opacity * 0.85})`;
            ctx.beginPath();
            ctx.moveTo(pt1.x, pt1.y);
            ctx.lineTo(pt2.x, pt2.y);
            ctx.stroke();
        }
    } else {
        // Standard Classic Wave ribbon
        ctx.lineWidth = 3.5;
        for (let i = 1; i < player.trail.length; i++) {
            const pt1 = player.trail[i - 1];
            const pt2 = player.trail[i];
            const age = Date.now() - pt2.time;
            const opacity = Math.max(0, 1 - age / 900);
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

// Camera dynamics tracking
function updateCamera(dt) {
    // Smoothly interpolate current horizontal offset to avoid camera jerks
    currentHorizontalOffset += (targetHorizontalOffset - currentHorizontalOffset) * 6 * dt;
    camera.x = player.x - currentHorizontalOffset;

    camera.targetY = player.y - height / 2;
    // Bounds limit checking
    const limit = 110;
    if (camera.targetY < -limit) camera.targetY = -limit;
    if (camera.targetY > limit) camera.targetY = limit;

    camera.y += (camera.targetY - camera.y) * 8 * dt;
}

// --- PHYSICS COLLISION LOGIC ---
function updateLevelAndCollisions() {
    if (player.isDead) return;

    if (currentGameMode === 'classic') {
        const startX = 150;
        const totalDist = levelLength - 800 - startX;
        const currentDist = player.x - startX;
        levelProgress = Math.max(0, Math.min(100, (currentDist / totalDist) * 100));

        // Update UI Progress Displays
        document.getElementById('hud-progress-bar').style.width = `${levelProgress}%`;
        document.getElementById('hud-progress-text').innerText = `${Math.floor(levelProgress)}%`;
        document.getElementById('hud-level-text').innerText = `Level ${currentLevel} - ${getBiomeForLevel(currentLevel).toUpperCase()}`;

        // Check level cleared
        if (player.x >= levelLength - 800) {
            triggerLevelCleared();
        }
    } else if (currentGameMode === 'endless') {
        const startX = 150;
        const mDist = Math.floor((player.x - startX) / 10);
        levelProgress = mDist; // raw distance

        document.getElementById('hud-progress-bar').style.width = '100%';
        document.getElementById('hud-progress-text').innerText = `${mDist}m`;
        document.getElementById('hud-level-text').innerText = `Endless Survival`;

        // Garbage collect old off-screen blocks
        if (obstacles.length > 0 && obstacles[0].x < player.x - 1200) {
            obstacles = obstacles.filter(o => o.x >= player.x - 1200);
        }

        // Continually seed forward tracks
        const lastObsX = obstacles.length > 0 ? obstacles[obstacles.length - 1].x : player.x;
        if (lastObsX < player.x + 3500) {
            generateEndlessThemeBuffer(lastObsX + 300, 10000, UI_STATE.activeBiome);
        }

        // Give player money (+1 Coin per 20 meters survived)
        if (mDist > 0 && mDist % 20 === 0) {
            // Check to avoid continuous duplicate rewards
            if (!player.lastCoinPayout || player.lastCoinPayout < mDist) {
                player.lastCoinPayout = mDist;
                UI_STATE.ploCoins += 1;
                saveStateItem(KEYS.COINS, UI_STATE.ploCoins);
                renderHeaderWidgets();
            }
        }
    }

    // Evaluate collision intersection metrics
    const pW = player.width * 0.55;
    const pH = player.height * 0.55;
    const pX = player.x - pW / 2;
    const pY = player.y - pH / 2;

    for (const obs of obstacles) {
        if (obs.x < player.x - 100) continue;
        if (obs.x > player.x + 250) continue;

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

    // Ceiling and floor crashing limits
    const crashTop = player.y - pH / 2 <= 42;
    const crashBot = player.y + pH / 2 >= height - 42;
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
        { x: player.x + player.width * 0.22, y: player.y },
        { x: player.x - player.width * 0.22, y: player.y }
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
    const area1 = Math.abs((px * (y2 - y3) + x2 * (y3 - py) + x3 * (py - y2)) / 2);
    const area2 = Math.abs((x1 * (py - y3) + px * (y3 - y1) + x3 * (y1 - py)) / 2);
    const area3 = Math.abs((x1 * (y2 - py) + x2 * (py - y1) + px * (y1 - y2)) / 2);
    return Math.abs(areaOrig - (area1 + area2 + area3)) < 0.1;
}

// --- RENDERING MODULES ---
function drawObstacles(ctx) {
    ctx.save();

    for (const obs of obstacles) {
        if (obs.x < camera.x - 120 || obs.x > camera.x + width + 120) continue;

        ctx.shadowBlur = 10;
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

            // Core inner triangle
            ctx.strokeStyle = '#ffffff';
            ctx.lineWidth = 1.0;
            ctx.beginPath();
            if (obs.dir === 1) {
                ctx.moveTo(obs.x + obs.width / 4, obs.y + 4);
                ctx.lineTo(obs.x + 3 * obs.width / 4, obs.y + 4);
                ctx.lineTo(obs.x + obs.width / 2, obs.y + obs.height * 0.7);
            } else {
                ctx.moveTo(obs.x + obs.width / 4, obs.y - 4);
                ctx.lineTo(obs.x + 3 * obs.width / 4, obs.y - 4);
                ctx.lineTo(obs.x + obs.width / 2, obs.y - obs.height * 0.7);
            }
            ctx.closePath();
            ctx.stroke();

        } else if (obs.type === 'block') {
            ctx.strokeStyle = '#ffffff';
            ctx.lineWidth = 2.4;
            ctx.fillStyle = 'rgba(2, 6, 6, 0.95)';

            ctx.fillRect(obs.x, obs.y, obs.width, obs.height);
            ctx.strokeRect(obs.x, obs.y, obs.width, obs.height);

            // Glowing boundary lines
            ctx.strokeStyle = obs.color;
            ctx.lineWidth = 1.4;
            ctx.strokeRect(obs.x + 4, obs.y + 4, obs.width - 8, obs.height - 8);

            // Draw golden runic details on block faces inside Ancient Biome
            const activeBiome = getBiomeForLevel(currentLevel);
            if (activeBiome === 'ancient') {
                ctx.strokeStyle = 'rgba(255, 170, 0, 0.4)';
                ctx.beginPath();
                ctx.moveTo(obs.x + 10, obs.y + 10);
                ctx.lineTo(obs.x + obs.width - 10, obs.y + obs.height - 10);
                ctx.moveTo(obs.x + obs.width - 10, obs.y + 10);
                ctx.lineTo(obs.x + 10, obs.y + obs.height - 10);
                ctx.stroke();
            }
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

// --- OVERLAYS TRIGGER CONTROLLERS ---
function triggerGameOverScreen() {
    setGameState(STATE_GAMEOVER);

    if (currentGameMode === 'classic') {
        document.getElementById('fail-progress-val').innerText = `${Math.floor(levelProgress)}%`;
        document.getElementById('fail-score-val').innerText = `Level ${currentLevel}`;
    } else if (currentGameMode === 'endless') {
        document.getElementById('fail-progress-val').innerText = `${Math.floor(levelProgress)}m`;
        document.getElementById('fail-score-val').innerText = `Best: ${endlessDistance}m`;

        if (levelProgress > endlessDistance) {
            endlessDistance = levelProgress;
            localStorage.setItem(SAVE_ENDLESS_HI_SCORE, endlessDistance.toString());
            updateEngineMenuTags();
        }
    } else {
        document.getElementById('fail-progress-val').innerText = `Crash Out`;
        document.getElementById('fail-score-val').innerText = `Bot Tournament`;
    }

    document.getElementById('gameover-modal').classList.add('active');
}

function triggerLevelCleared() {
    setGameState(STATE_VICTORY);

    stopSynthMusic();
    playClearedSound();

    if (currentGameMode === 'classic') {
        document.getElementById('win-mode-val').innerText = `Level ${currentLevel} Cleared!`;
        document.getElementById('win-attempts-val').innerText = attemptCount;

        // Is perfect (completed on first attempt and without crashes)
        const isPerfect = attemptCount === 1 && !player.hasCrashedThisRun;

        // Save progress to local storage and update ratings
        updateStatsOnWin(currentLevel, isPerfect);

        document.getElementById('win-next-btn').style.display = currentLevel < 100 ? 'block' : 'none';
    }

    document.getElementById('win-modal').classList.add('active');
}

// Practice checkpoint management
function togglePracticeMode(enabled) {
    const ctrls = document.getElementById('practice-controls');
    if (ctrls) ctrls.style.visibility = enabled ? 'visible' : 'hidden';

    if (!enabled) {
        currentPracticeCheckpoint = null;
    }
}

function placeCheckpoint() {
    if (player.isDead) return;

    playCheckpointSound();

    currentPracticeCheckpoint = {
        x: player.x,
        y: player.y,
        vy: player.vy,
        bgScrollX: bgScrollX,
        bgScrollY: bgScrollY,
        attempt: attemptCount
    };

    // Emission stars burst
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

function clearCheckpoints() {
    currentPracticeCheckpoint = null;
}

// --- RACE MODE BOT AI ALGORITHMS ---
function initRaceCompetitors() {
    bots = [];
    if (currentGameMode !== 'race') {
        document.getElementById('race-leaderboard').classList.remove('active');
        return;
    }

    document.getElementById('race-leaderboard').classList.add('active');

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
            lastDecisionTime: 0,
            decisionInterval: 0.12 + Math.random() * 0.1,
            trail: [],
            targetVy: 390
        });
    }
}

function updateBots(dt) {
    if (currentGameMode !== 'race') return;

    const now = Date.now();

    for (const bot of bots) {
        if (bot.isDead) continue;

        bot.x += bot.baseSpeed * dt;

        // Periodical decision checks
        if (now - bot.lastDecisionTime > bot.decisionInterval * 1000) {
            bot.lastDecisionTime = now;
            makeAIBotDecision(bot);
        }

        bot.vy += (bot.targetVy - bot.vy) * 14 * dt;
        bot.y += bot.vy * dt;

        // Container clamps
        const borderTop = 40;
        const borderBottom = height - 40;
        if (bot.y < borderTop + bot.height / 2) {
            bot.y = borderTop + bot.height / 2;
            bot.vy = 0;
        }
        if (bot.y > borderBottom - bot.height / 2) {
            bot.y = borderBottom - bot.height / 2;
            bot.vy = 0;
        }

        bot.angle = Math.atan2(bot.vy, bot.baseSpeed) * 0.8;

        bot.trail.push({ x: bot.x, y: bot.y, time: now });
        bot.trail = bot.trail.filter(pt => now - pt.time < 500);

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
                if (!isCeiling && bot.y > height - 180) {
                    obstacleInPath = obs;
                    break;
                }
            }
        }
    }

    if (obstacleInPath) {
        if (obstacleInPath.type === 'block') {
            const ceilingDist = obstacleInPath.y - 40;
            const floorDist = (height - 40) - (obstacleInPath.y + obstacleInPath.height);

            if (ceilingDist > floorDist) {
                bot.targetVy = -390;
            } else {
                bot.targetVy = 390;
            }
        } else {
            if (obstacleInPath.dir === 1) {
                bot.targetVy = 390;
            } else {
                bot.targetVy = -390;
            }
        }
    } else {
        if (bot.y < 160) {
            bot.targetVy = 390;
        } else if (bot.y > height - 160) {
            bot.targetVy = -390;
        } else {
            if (Math.random() < 0.15) {
                bot.targetVy = -bot.targetVy;
            }
        }
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
                destroyBot(bot);
                break;
            }
        } else if (obs.type === 'spike') {
            if (rectsIntersect(bX, bY, bW, bH, obs.x, obs.dir === 1 ? obs.y : obs.y - obs.height, obs.width, obs.height)) {
                destroyBot(bot);
                break;
            }
        }
    }

    if (bot.y - bH / 2 <= 42 || bot.y + bH / 2 >= height - 42) {
        destroyBot(bot);
    }
}

function destroyBot(bot) {
    bot.isDead = true;
    bot.vy = 0;

    for (let i = 0; i < 15; i++) {
        const angle = Math.random() * Math.PI * 2;
        player.particles.push({
            x: bot.x,
            y: bot.y,
            vx: Math.cos(angle) * 140,
            vy: Math.sin(angle) * 140,
            size: 2.5,
            color: bot.color,
            alpha: 1.0,
            life: 0.6
        });
    }
}

function updateRaceLeaderboardRows() {
    if (currentGameMode !== 'race') return;

    const racers = [];
    racers.push({ name: "YOU", x: player.x, isDead: player.isDead, color: 'var(--neon-green)' });

    bots.forEach(b => {
        racers.push({ name: b.name, x: b.x, isDead: b.isDead, color: b.color });
    });

    // Sort descending by position x
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

    // Race finishes checking
    if (!player.isDead && player.x >= levelLength - 800) {
        const index = racers.findIndex(r => r.name === 'YOU');
        if (index === 0) {
            // First place victory
            raceWinsCount++;
            localStorage.setItem(SAVE_RACE_WINS, raceWinsCount.toString());
            updateEngineMenuTags();
            triggerLevelCleared();
        } else {
            // Lost match
            setGameState(STATE_GAMEOVER);
            document.getElementById('fail-progress-val').innerText = `Finished #${index + 1}`;
            document.getElementById('fail-score-val').innerText = `Winner: ${racers[0].name}`;
            document.getElementById('gameover-modal').classList.add('active');
        }
    }
}

function drawBots(ctx) {
    // Render Real-time Multiplayer Competitor Arrows if playing in multiplayer
    if (currentGameMode === 'multiplayer') {
        Object.keys(multiplayerCompetitors).forEach(pId => {
            const bot = multiplayerCompetitors[pId];
            if (bot.isDead) return;

            ctx.save();
            ctx.translate(bot.x, bot.y);
            ctx.rotate(bot.angle);

            // Determine custom skin color
            const skinMatch = VEHICLE_SKINS.find(s => s.id === bot.skin) || VEHICLE_SKINS[0];

            ctx.strokeStyle = '#ffffff';
            ctx.lineWidth = 2;
            ctx.fillStyle = skinMatch.color;
            ctx.shadowColor = skinMatch.color;
            ctx.shadowBlur = 8;

            ctx.beginPath();
            ctx.moveTo(17, 0);
            ctx.lineTo(-17, -13);
            ctx.lineTo(-8, 0);
            ctx.lineTo(-17, 13);
            ctx.closePath();
            ctx.fill();
            ctx.stroke();

            // Hovering Username text
            ctx.restore();
            ctx.save();
            ctx.fillStyle = '#fff';
            ctx.font = '10px Orbitron';
            ctx.textAlign = 'center';
            ctx.fillText(bot.name, bot.x, bot.y - 20);
            ctx.restore();
        });
    }

    if (currentGameMode !== 'race') return;

    for (const bot of bots) {
        if (bot.isDead) continue;

        // Draw individual bot trail
        if (bot.trail.length >= 2) {
            ctx.save();
            ctx.shadowBlur = 8;
            ctx.shadowColor = bot.color;
            ctx.lineWidth = 2.4;
            for (let i = 1; i < bot.trail.length; i++) {
                const pt1 = bot.trail[i - 1];
                const pt2 = bot.trail[i];
                const age = Date.now() - pt2.time;
                const opacity = Math.max(0, 1 - age / 500);
                ctx.strokeStyle = bot.color;
                ctx.globalAlpha = opacity * 0.75;
                ctx.beginPath();
                ctx.moveTo(pt1.x, pt1.y);
                ctx.lineTo(pt2.x, pt2.y);
                ctx.stroke();
            }
            ctx.restore();
        }

        // Draw triangle
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

// --- SYNTHESIZED WEB AUDIO API LOOPS ---
function initAudioContext() {
    if (!audioCtx) {
        audioCtx = new (window.AudioContext || window.webkitAudioContext)();
    }
    if (audioCtx.state === 'suspended') {
        audioCtx.resume();
    }
}

function startSynthMusic() {
    if (isMuted) return;
    initAudioContext();
    stopSynthMusic();

    synthBeatsCount = 0;

    // Fast, driving cyberpunk electronic beat at 150 BPM (roughly every 200ms per step)
    synthIntervalId = setInterval(() => {
        if (currentGameState !== STATE_PLAYING || isMuted) return;
        playSynthSequencerStep();
    }, 200);
}

function stopSynthMusic() {
    if (synthIntervalId) {
        clearInterval(synthIntervalId);
        synthIntervalId = null;
    }
}

function playSynthSequencerStep() {
    try {
        const step = synthBeatsCount % 16;
        synthBeatsCount++;

        // Kicks on quarter beats
        if (step % 4 === 0) {
            playSynthKickDrum();
        }

        // Snappy HighHats on offbeats
        if (step % 4 === 2) {
            playSynthHiHat();
        }

        // Fast arpeggiated industrial minor-pentatonic bassline melody
        const melody = [55, 55, 65, 55, 58, 55, 62, 58, 55, 55, 65, 55, 58, 65, 70, 65];
        const freq = melody[step];
        playSynthBassLine(freq);

        if (step === 7 || step === 15) {
            if (Math.random() < 0.55) {
                playSynthLaserSweep(freq * 3.5);
            }
        }
    } catch (e) {
        console.error('Audio sequencer failed: ', e);
    }
}

function playSynthKickDrum() {
    const osc = audioCtx.createOscillator();
    const gain = audioCtx.createGain();

    osc.connect(gain);
    gain.connect(audioCtx.destination);

    osc.frequency.setValueAtTime(150, audioCtx.currentTime);
    osc.frequency.exponentialRampToValueAtTime(0.01, audioCtx.currentTime + 0.14);

    gain.gain.setValueAtTime(0.35, audioCtx.currentTime);
    gain.gain.exponentialRampToValueAtTime(0.001, audioCtx.currentTime + 0.15);

    osc.start(audioCtx.currentTime);
    osc.stop(audioCtx.currentTime + 0.16);
}

function playSynthHiHat() {
    const bufferSize = audioCtx.sampleRate * 0.05;
    const buffer = audioCtx.createBuffer(1, bufferSize, audioCtx.sampleRate);
    const data = buffer.getChannelData(0);
    for (let i = 0; i < bufferSize; i++) {
        data[i] = Math.random() * 2 - 1;
    }

    const source = audioCtx.createBufferSource();
    source.buffer = buffer;

    const filter = audioCtx.createBiquadFilter();
    filter.type = 'highpass';
    filter.frequency.value = 8000;

    const gain = audioCtx.createGain();
    gain.gain.setValueAtTime(0.08, audioCtx.currentTime);
    gain.gain.exponentialRampToValueAtTime(0.001, audioCtx.currentTime + 0.04);

    source.connect(filter);
    filter.connect(gain);
    gain.connect(audioCtx.destination);

    source.start(audioCtx.currentTime);
    source.stop(audioCtx.currentTime + 0.05);
}

function playSynthBassLine(freq) {
    const osc = audioCtx.createOscillator();
    const gain = audioCtx.createGain();

    osc.type = 'sawtooth';
    osc.frequency.setValueAtTime(freq, audioCtx.currentTime);
    osc.frequency.exponentialRampToValueAtTime(freq * 0.98, audioCtx.currentTime + 0.18);

    const filter = audioCtx.createBiquadFilter();
    filter.type = 'lowpass';
    filter.frequency.value = 650;

    osc.connect(filter);
    filter.connect(gain);
    gain.connect(audioCtx.destination);

    gain.gain.setValueAtTime(0.12, audioCtx.currentTime);
    gain.gain.exponentialRampToValueAtTime(0.001, audioCtx.currentTime + 0.19);

    osc.start(audioCtx.currentTime);
    osc.stop(audioCtx.currentTime + 0.2);
}

function playSynthLaserSweep(freq) {
    const osc = audioCtx.createOscillator();
    const gain = audioCtx.createGain();

    osc.type = 'square';
    osc.frequency.setValueAtTime(freq, audioCtx.currentTime);
    osc.frequency.exponentialRampToValueAtTime(freq * 0.22, audioCtx.currentTime + 0.14);

    const filter = audioCtx.createBiquadFilter();
    filter.type = 'bandpass';
    filter.frequency.value = 1300;

    osc.connect(filter);
    filter.connect(gain);
    gain.connect(audioCtx.destination);

    gain.gain.setValueAtTime(0.04, audioCtx.currentTime);
    gain.gain.exponentialRampToValueAtTime(0.001, audioCtx.currentTime + 0.15);

    osc.start(audioCtx.currentTime);
    osc.stop(audioCtx.currentTime + 0.16);
}

function playCrashSound() {
    if (isMuted) return;
    initAudioContext();

    const osc = audioCtx.createOscillator();
    const gain = audioCtx.createGain();

    osc.type = 'triangle';
    osc.frequency.setValueAtTime(140, audioCtx.currentTime);
    osc.frequency.exponentialRampToValueAtTime(10, audioCtx.currentTime + 0.85);

    gain.gain.setValueAtTime(0.4, audioCtx.currentTime);
    gain.gain.exponentialRampToValueAtTime(0.001, audioCtx.currentTime + 0.88);

    osc.connect(gain);
    gain.connect(audioCtx.destination);

    osc.start(audioCtx.currentTime);
    osc.stop(audioCtx.currentTime + 0.9);
}

function playClearedSound() {
    if (isMuted) return;
    initAudioContext();

    const chord = [329.63, 392.00, 523.25, 659.25];
    const now = audioCtx.currentTime;

    chord.forEach((note, idx) => {
        const osc = audioCtx.createOscillator();
        const gain = audioCtx.createGain();

        osc.type = 'sine';
        osc.frequency.setValueAtTime(note, now + idx * 0.08);
        osc.frequency.exponentialRampToValueAtTime(note * 1.5, now + idx * 0.08 + 0.4);

        gain.gain.setValueAtTime(0.12, now + idx * 0.08);
        gain.gain.exponentialRampToValueAtTime(0.001, now + idx * 0.08 + 0.5);

        osc.connect(gain);
        gain.connect(audioCtx.destination);

        osc.start(now + idx * 0.08);
        osc.stop(now + idx * 0.08 + 0.55);
    });
}

function playCheckpointSound() {
    if (isMuted) return;
    initAudioContext();

    const osc = audioCtx.createOscillator();
    const gain = audioCtx.createGain();

    osc.type = 'sine';
    osc.frequency.setValueAtTime(523.25, audioCtx.currentTime);
    osc.frequency.setValueAtTime(783.99, audioCtx.currentTime + 0.06);

    gain.gain.setValueAtTime(0.15, audioCtx.currentTime);
    gain.gain.exponentialRampToValueAtTime(0.001, audioCtx.currentTime + 0.22);

    osc.connect(gain);
    gain.connect(audioCtx.destination);

    osc.start(audioCtx.currentTime);
    osc.stop(audioCtx.currentTime + 0.25);
}

// --- MODALS AND GAMEPLAY WRAPPERS ---
function pauseGame() {
    if (currentGameState !== STATE_PLAYING) return;
    currentGameState = STATE_PAUSED;
    stopSynthMusic();

    if (currentGameMode === 'classic') {
        document.getElementById('pause-progress-val').innerText = `${Math.floor(levelProgress)}%`;
    } else if (currentGameMode === 'endless') {
        document.getElementById('pause-progress-val').innerText = `${Math.floor(levelProgress)}m`;
    } else {
        document.getElementById('pause-progress-val').innerText = `Tournament Match`;
    }
    document.getElementById('pause-mode-val').innerText = currentGameMode.toUpperCase();
    document.getElementById('pause-modal').classList.add('active');
}

function resumeGame() {
    if (currentGameState !== STATE_PAUSED) return;
    hideAllModals();
    currentGameState = STATE_PLAYING;
    startSynthMusic();
}

function restartLevel() {
    hideAllModals();
    attemptCount++;
    initGameElements();
    setGameState(STATE_PLAYING);
}

function quitToMenu() {
    hideAllModals();
    openMainMenu();
}

function nextLevel() {
    hideAllModals();
    if (currentLevel < 100) {
        launchClassicLevel(currentLevel + 1);
    } else {
        openLevelSelect();
    }
}

function toggleAudio() {
    isMuted = !isMuted;
    document.getElementById('audio-toggle').innerHTML = isMuted ? '<span>🔇</span> AUDIO: OFF' : '<span>🔊</span> AUDIO: ON';
}

// --- MAIN LOOP ---
function gameLoop(time) {
    if (!lastTime) lastTime = time;
    deltaTime = (time - lastTime) / 1000;
    lastTime = time;

    if (deltaTime > 0.1) deltaTime = 0.1;

    update(deltaTime);
    render();

    requestAnimationFrame(gameLoop);
}

function update(dt) {
    if (currentGameState !== STATE_PLAYING) return;

    updatePlayerPhysics(dt);
    updateBots(dt);
    updateLevelAndCollisions();
    updateCamera(dt);
    updateAmbientParticles(dt);

    bgScrollX = camera.x;
    bgScrollY = camera.y;
}

function render() {
    ctx.clearRect(0, 0, canvas.width, canvas.height);

    // 1. Draw background grid across full canvas (unscaled & untranslated)
    if (hexPatternCanvas) {
        ctx.save();
        const left = -(bgScrollX * 0.3) % hexPatternWidth;
        const top = -(bgScrollY * 0.3) % hexPatternHeight;

        ctx.fillStyle = ctx.createPattern(hexPatternCanvas, 'repeat');
        ctx.translate(left, top);
        // Cover entire canvas width and height
        ctx.fillRect(-left, -top, canvas.width, canvas.height);
        ctx.restore();
    }

    // 2. Center and scale the 1200x675 gameplay arena
    ctx.save();
    ctx.translate(offsetX, offsetY);
    ctx.scale(scale, scale);

    // Clip gameplay within 1200x675 boundary to ensure clean aspect ratio borders
    ctx.save();
    ctx.beginPath();
    ctx.rect(0, 0, width, height);
    ctx.clip();

    // Biome Specific Overlay Shading Effects
    drawBiomeWeatherGlow(ctx);

    // Draw ambient decoration weather particles
    drawAmbientDecorations(ctx);

    // 1. Draw level boundary lanes
    ctx.save();
    ctx.translate(-camera.x, -camera.y);

    const biome = getBiomeForLevel(currentLevel);
    const borderColors = {
        forest: 'rgba(0, 255, 102, 0.4)',
        haunted: 'rgba(176, 38, 255, 0.4)',
        space: 'rgba(0, 243, 255, 0.4)',
        water: 'rgba(255, 0, 127, 0.4)',
        ancient: 'rgba(255, 170, 0, 0.4)'
    };
    const boundCol = borderColors[biome];

    ctx.strokeStyle = boundCol;
    ctx.lineWidth = 4;
    ctx.shadowBlur = 12;
    ctx.shadowColor = boundCol;

    ctx.beginPath();
    ctx.moveTo(camera.x - 200, 40);
    ctx.lineTo(camera.x + width + 200, 40);
    ctx.stroke();

    ctx.beginPath();
    ctx.moveTo(camera.x - 200, height - 40);
    ctx.lineTo(camera.x + width + 200, height - 40);
    ctx.stroke();

    ctx.restore();

    // 2. Render internal elements inside viewport coordinates
    ctx.save();
    ctx.translate(-camera.x, -camera.y);

    // Draw obstacles
    drawObstacles(ctx);

    // Draw bots
    drawBots(ctx);

    // Draw player
    drawPlayer(ctx);

    ctx.restore();

    ctx.restore(); // Restore clip

    ctx.restore(); // Restore scale & translate
}

function drawBiomeWeatherGlow(ctx) {
    const biome = getBiomeForLevel(currentLevel);
    ctx.save();

    if (biome === 'forest') {
        // Soft green sunlight gradient
        const grad = ctx.createLinearGradient(0, 0, 0, height);
        grad.addColorStop(0, 'rgba(0, 255, 102, 0.04)');
        grad.addColorStop(1, 'transparent');
        ctx.fillStyle = grad;
        ctx.fillRect(0, 0, width, height);
    } else if (biome === 'haunted') {
        // Deep gloomy mist vignette
        const grad = ctx.createRadialGradient(width/2, height/2, 200, width/2, height/2, width/2 + 200);
        grad.addColorStop(0, 'transparent');
        grad.addColorStop(1, 'rgba(176, 38, 255, 0.12)');
        ctx.fillStyle = grad;
        ctx.fillRect(0, 0, width, height);
    } else if (biome === 'space') {
        // Cosmic blue overlay shading
        ctx.fillStyle = 'rgba(0, 243, 255, 0.015)';
        ctx.fillRect(0, 0, width, height);
    } else if (biome === 'water') {
        // Buoyant deep ocean blue overlay
        const grad = ctx.createLinearGradient(0, 0, 0, height);
        grad.addColorStop(0, 'rgba(0, 59, 255, 0.1)');
        grad.addColorStop(1, 'rgba(0, 243, 255, 0.15)');
        ctx.fillStyle = grad;
        ctx.fillRect(0, 0, width, height);
    } else if (biome === 'ancient') {
        // Dust golden glow
        ctx.fillStyle = 'rgba(255, 170, 0, 0.03)';
        ctx.fillRect(0, 0, width, height);
    }

    ctx.restore();
}
