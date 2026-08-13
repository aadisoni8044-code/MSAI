/**
 * Speedy Arrow - Core Gameplay Engine
 * Implements 60fps delta-time frame loops, interactive wave ship physics,
 * procedurally-arranged obstacles, particle trails, collectibles,
 * customizable AI ghosts, level criteria, screen shake, and result panels.
 */

class GameEngine {
  constructor() {
    this.canvas = document.getElementById("gameCanvas");
    this.ctx = this.canvas ? this.canvas.getContext("2d") : null;
    this.lastTime = 0;
    this.accumulatedTime = 0;

    // Core state
    this.active = false;
    this.paused = false;
    this.mode = "classic"; // classic, endless, race
    this.currentLevelIndex = 0;

    // Viewport
    this.width = 480;
    this.height = 800;

    // Ship definition
    this.player = {
      x: 80,
      y: 400,
      vy: 0,
      size: 16,
      angle: 0,
      thrust: false,
      color: "#00e5ff",
      trail: [] // {x, y, age}
    };

    // Bots (Race Mode)
    this.bots = [];

    // Obstacles
    this.obstacles = []; // { x, y, width, height, type: 'block' | 'spike' | 'gap' }
    this.collectibles = []; // { x, y, size, active }

    // Visuals & particles
    this.particles = []; // { x, y, vx, vy, color, size, life }
    this.scrollX = 0;
    this.gameSpeed = 220; // horizontal speed (px/sec)
    this.gravity = 750; // gravity (px/sec^2)
    this.riseForce = -700; // upward force (px/sec^2)

    this.screenShakeTime = 0;
    this.screenShakeIntensity = 0;

    this.distanceTraveled = 0;
    this.targetDistance = 1000; // default for race/classic finish line
    this.gemsCollected = 0;

    this.starsEarned = 0;
    this.isDead = false;
    this.isFinished = false;

    this.starsScoreCard = {
      noCrash: true,
      gemsPercent: 0,
      timeLimit: true
    };

    // Control setup
    this.bindControls();
  }

  resize() {
    if (!this.canvas) return;
    const parent = this.canvas.parentNode;
    const rect = parent.getBoundingClientRect();

    this.width = rect.width || 480;
    this.height = rect.height || 800;

    this.canvas.width = this.width;
    this.canvas.height = this.height;
  }

  bindControls() {
    const handleDown = (e) => {
      if (!this.active || this.paused || this.isDead || this.isFinished) return;
      this.player.thrust = true;
      e.preventDefault();
    };

    const handleUp = (e) => {
      if (!this.active) return;
      this.player.thrust = false;
    };

    // Mouse & Touch triggers
    window.addEventListener("mousedown", handleDown);
    window.addEventListener("mouseup", handleUp);

    window.addEventListener("touchstart", (e) => {
      // Don't trigger standard clicks inside UI screens
      if (e.target.closest("#screen-gameplay")) {
        handleDown(e);
      }
    }, { passive: false });

    window.addEventListener("touchend", handleUp);

    // Keyboard trigger (Spacebar)
    window.addEventListener("keydown", (e) => {
      if (e.code === "Space") {
        handleDown(e);
      }
    });

    window.addEventListener("keyup", (e) => {
      if (e.code === "Space") {
        handleUp(e);
      }
    });

    // Pause toggle
    const pauseBtn = document.getElementById("game-btn-pause");
    if (pauseBtn) {
      pauseBtn.addEventListener("click", (e) => {
        e.stopPropagation();
        window.audioSynth.playClick();
        this.togglePause();
      });
    }
  }

  togglePause() {
    this.paused = !this.paused;
    if (this.paused) {
      // Show simple paused notification in modal
      openModal(`
        <h2>PAUSED</h2>
        <p>Take a break! Game is paused.</p>
        <div style="display:flex; flex-direction:column; gap:10px; margin-top:15px;">
          <button id="modal-resume-btn" class="primary btn">RESUME</button>
          <button id="modal-restart-btn" class="btn">RESTART RUN</button>
          <button id="modal-exit-btn" class="danger btn">EXIT TO MENU</button>
        </div>
      `);

      document.getElementById("modal-resume-btn").addEventListener("click", () => {
        window.audioSynth.playClick();
        closeModal();
        this.paused = false;
      });

      document.getElementById("modal-restart-btn").addEventListener("click", () => {
        window.audioSynth.playClick();
        closeModal();
        this.paused = false;
        this.restartRun();
      });

      document.getElementById("modal-exit-btn").addEventListener("click", () => {
        window.audioSynth.playClick();
        closeModal();
        this.paused = false;
        this.stop();
      });
    } else {
      closeModal();
    }
  }

  start(mode, levelIdx = 0) {
    this.active = true;
    this.paused = false;
    this.mode = mode;
    this.currentLevelIndex = levelIdx;

    this.resize();
    this.restartRun();

    // Fade in gameplay
    showScreen("screen-gameplay");

    this.lastTime = performance.now();
    requestAnimationFrame((t) => this.loop(t));
  }

  stop() {
    this.active = false;
    showScreen("screen-menu");
  }

  restartRun() {
    const state = window.stateMgr.state;
    this.isDead = false;
    this.isFinished = false;
    this.distanceTraveled = 0;
    this.gemsCollected = 0;
    this.obstacles = [];
    this.collectibles = [];
    this.particles = [];
    this.scrollX = 0;

    // Reset player position
    this.player.x = 80;
    this.player.y = this.height / 2;
    this.player.vy = 0;
    this.player.thrust = false;
    this.player.trail = [];

    // Determine target goals - Scaled up for fun longer runs (15-60 seconds)
    if (this.mode === "classic") {
      this.targetDistance = 3000 + this.currentLevelIndex * 1500;
    } else if (this.mode === "race") {
      this.targetDistance = 5000;
    } else {
      this.targetDistance = 999999; // Endless
    }

    // Set map themes based on equipped ID
    const theme = window.THEMES[state.equippedTheme] || window.THEMES["purple"];
    this.player.color = theme.accent;

    // Build Obstacle track based on Mode/Difficulty
    this.generateTrack();

    // Build race AI ghosts if in race mode
    this.setupBots();

    // Setup HUD text display
    const modeIndicator = document.getElementById("hud-mode-indicator");
    if (modeIndicator) {
      if (this.mode === "classic") {
        modeIndicator.textContent = `LEVEL ${this.currentLevelIndex + 1}`;
      } else if (this.mode === "endless") {
        modeIndicator.textContent = "ENDLESS";
      } else {
        modeIndicator.textContent = "RACE";
      }
    }

    // Render leaderboard toggles
    const leaderboardEl = document.getElementById("hud-race-leaderboard");
    if (leaderboardEl) {
      leaderboardEl.style.display = this.mode === "race" ? "flex" : "none";
    }

    // Update target metrics text display
    const targetEl = document.getElementById("hud-target-value");
    if (targetEl) {
      targetEl.textContent = this.mode === "endless" ? "∞" : Math.floor(this.targetDistance);
    }

    this.updateHUDValues();
  }

  // --- Dynamic Track Placement Layouts ---
  generateTrack() {
    let cursorX = 400;
    const maxTrack = this.targetDistance + 200;

    // Build repeating procedural waves
    while (cursorX < maxTrack) {
      const typeChoice = Math.random();

      if (typeChoice < 0.35) {
        // Vertical blocks wall gate
        const gapHeight = 160 - Math.min(60, this.currentLevelIndex * 8);
        const gapY = 150 + Math.random() * (this.height - 350 - gapHeight);

        // Top block
        this.obstacles.push({
          x: cursorX,
          y: 0,
          width: 50,
          height: gapY,
          type: "block"
        });

        // Bottom block
        this.obstacles.push({
          x: cursorX,
          y: gapY + gapHeight,
          width: 50,
          height: this.height - (gapY + gapHeight),
          type: "block"
        });

        // Collectible gem centered in opening
        this.collectibles.push({
          x: cursorX + 25,
          y: gapY + gapHeight / 2,
          size: 8,
          active: true
        });

        cursorX += 350;
      } else if (typeChoice < 0.70) {
        // Spike triangles sequence
        const count = 2 + Math.floor(Math.random() * 3);
        const alignment = Math.random() < 0.5 ? "floor" : "ceiling";

        for (let i = 0; i < count; i++) {
          this.obstacles.push({
            x: cursorX + i * 80,
            y: alignment === "floor" ? this.height - 50 : 0,
            width: 40,
            height: 50,
            type: "spike",
            alignment: alignment
          });

          // Add float gem above/below spike
          this.collectibles.push({
            x: cursorX + i * 80 + 20,
            y: alignment === "floor" ? this.height - 120 : 120,
            size: 8,
            active: true
          });
        }
        cursorX += count * 80 + 300;
      } else {
        // Narrow slalom corridor blocks
        const topHeight = 100 + Math.random() * 150;
        const bottomHeight = 100 + Math.random() * 150;

        this.obstacles.push({
          x: cursorX,
          y: 0,
          width: 100,
          height: topHeight,
          type: "block"
        });

        this.obstacles.push({
          x: cursorX + 150,
          y: this.height - bottomHeight,
          width: 100,
          height: bottomHeight,
          type: "block"
        });

        this.collectibles.push({
          x: cursorX + 50,
          y: topHeight + 50,
          size: 8,
          active: true
        });

        this.collectibles.push({
          x: cursorX + 200,
          y: this.height - bottomHeight - 50,
          size: 8,
          active: true
        });

        cursorX += 450;
      }
    }
  }

  // --- AI Ghost opponents initialization ---
  setupBots() {
    if (this.mode !== "race") {
      this.bots = [];
      return;
    }

    const diff = window.stateMgr.state.raceDifficulty;
    let botCount = 2;
    this.bots = [];

    // Speed metrics according to selected difficulty
    let botBaseSpeed = this.gameSpeed;
    if (diff === "EASY") botBaseSpeed *= 0.88;
    else if (diff === "HARD") botBaseSpeed *= 1.08;

    for (let i = 0; i < botCount; i++) {
      this.bots.push({
        id: `bot_${i}`,
        name: i === 0 ? "Vector Bot" : "Aero Ghost",
        x: 80,
        y: this.height / 2 + (i - 0.5) * 60,
        vy: 0,
        speed: botBaseSpeed + (Math.random() - 0.5) * 15,
        color: i === 0 ? "#ff8a80" : "#ffd180",
        distance: 0,
        phase: Math.random() * Math.PI * 2, // variation wave starting phase
        isDead: false,
        size: 14,
        trail: []
      });
    }
  }

  // --- Animation loop ---
  loop(time) {
    if (!this.active) return;

    let dt = (time - this.lastTime) / 1000;
    this.lastTime = time;

    // Cap delta-time to avoid wild layout physics steps when frames drop
    if (dt > 0.1) dt = 0.1;

    if (!this.paused) {
      this.update(dt);
    }

    this.render();

    requestAnimationFrame((t) => this.loop(t));
  }

  // --- Physics updates ---
  update(dt) {
    if (this.isDead || this.isFinished) {
      // Keep updating particles and trail decay
      this.updateParticles(dt);
      this.decayTrails(dt);
      return;
    }

    // 1. Move Player wave position
    if (this.player.thrust) {
      this.player.vy += this.riseForce * dt;
      // Audio thrust sound feedback
      if (Math.random() < 0.4) {
        window.audioSynth.playThrust(0.08);
      }
    } else {
      this.player.vy += this.gravity * dt;
    }

    // Velocity clamps
    const maxVy = 550;
    if (this.player.vy > maxVy) this.player.vy = maxVy;
    if (this.player.vy < -maxVy) this.player.vy = -maxVy;

    this.player.y += this.player.vy * dt;

    // Angle tracking based on climb direction
    this.player.angle = Math.atan2(this.player.vy, this.gameSpeed);

    // Wall constraints and collisions
    if (this.player.y - this.player.size < 0) {
      this.player.y = this.player.size;
      this.player.vy = 0;
      this.triggerCrash();
    } else if (this.player.y + this.player.size > this.height) {
      this.player.y = this.height - this.player.size;
      this.player.vy = 0;
      this.triggerCrash();
    }

    // Track horizontal displacement
    const speedMultiplier = 1;
    this.distanceTraveled += this.gameSpeed * speedMultiplier * dt;
    this.scrollX = this.distanceTraveled;

    // Insert new trail coordinates
    this.player.trail.push({
      x: this.player.x,
      y: this.player.y,
      age: 1.0
    });

    this.decayTrails(dt);

    // 2. Move race bot players
    this.updateBots(dt);

    // 3. Collision evaluations
    this.checkCollisions();

    // 4. Update decorative particle positions
    this.updateParticles(dt);

    // 5. Update screen shake timers
    if (this.screenShakeTime > 0) {
      this.screenShakeTime -= dt;
    }

    // 6. Check Level completeness limit
    if (this.distanceTraveled >= this.targetDistance && this.mode !== "endless") {
      this.triggerComplete();
    }

    this.updateHUDValues();
  }

  decayTrails(dt) {
    // Decrease trail segment ages
    this.player.trail.forEach(pt => {
      pt.age -= dt * 1.5; // decay duration mapping
    });
    this.player.trail = this.player.trail.filter(pt => pt.age > 0);

    this.bots.forEach(bot => {
      bot.trail.forEach(pt => pt.age -= dt * 1.8);
      bot.trail = bot.trail.filter(pt => pt.age > 0);
    });
  }

  updateBots(dt) {
    this.bots.forEach(bot => {
      if (bot.isDead) {
        bot.trail.push({ x: bot.x - (this.scrollX - bot.distance), y: bot.y, age: 0.6 });
        return;
      }

      // Sine pattern tracking mimicking a wave player
      bot.phase += dt * 3.5;
      const targetY = (this.height / 2) + Math.sin(bot.phase) * (this.height / 3);

      // Interpolate bot vertical movement
      bot.y += (targetY - bot.y) * 4 * dt;
      bot.distance += bot.speed * dt;

      // Translate virtual bot coordinates on viewport relative to player progression scroll
      const relativeX = bot.x + (bot.distance - this.distanceTraveled);

      bot.trail.push({
        x: relativeX,
        y: bot.y,
        age: 1.0
      });

      // Bot simple crash checks on scrolled obstacles
      this.obstacles.forEach(obs => {
        const relativeObsX = obs.x - this.scrollX;
        if (
          relativeX + bot.size > relativeObsX &&
          relativeX - bot.size < relativeObsX + obs.width
        ) {
          if (obs.type === "block") {
            if (bot.y + bot.size > obs.y && bot.y - bot.size < obs.y + obs.height) {
              bot.isDead = true;
              this.createExplosion(relativeX, bot.y, bot.color);
            }
          } else if (obs.type === "spike") {
            // Triangle boundary check approximation
            if (obs.alignment === "floor") {
              if (bot.y + bot.size > obs.y) bot.isDead = true;
            } else {
              if (bot.y - bot.size < obs.height) bot.isDead = true;
            }
            if (bot.isDead) this.createExplosion(relativeX, bot.y, bot.color);
          }
        }
      });
    });
  }

  updateParticles(dt) {
    this.particles.forEach(p => {
      p.x += p.vx * dt;
      p.y += p.vy * dt;
      p.life -= dt;
    });
    this.particles = this.particles.filter(p => p.life > 0);
  }

  // --- Dynamic HUD & Leaderboard updates ---
  updateHUDValues() {
    const dVal = document.getElementById("hud-distance-value");
    if (dVal) dVal.textContent = Math.floor(this.distanceTraveled);

    const gemsVal = document.getElementById("hud-run-gems");
    if (gemsVal) gemsVal.textContent = this.gemsCollected;

    const fill = document.getElementById("hud-progress-fill");
    if (fill) {
      const pct = Math.min(100, (this.distanceTraveled / this.targetDistance) * 100);
      fill.style.width = `${pct}%`;
    }

    // Race positioning
    if (this.mode === "race" && this.bots.length > 0) {
      // Build placements list
      const competitors = [
        { name: "You", distance: this.distanceTraveled, isDead: this.isDead, color: this.player.color },
        ...this.bots.map(b => ({ name: b.name, distance: b.distance, isDead: b.isDead, color: b.color }))
      ];

      // Sort by distance descending, dead players at bottom
      competitors.sort((a, b) => {
        if (a.isDead && !b.isDead) return 1;
        if (!a.isDead && b.isDead) return -1;
        return b.distance - a.distance;
      });

      for (let i = 0; i < 3; i++) {
        const el = document.getElementById(`hud-rank-${i + 1}`);
        if (el && competitors[i]) {
          const suffix = i === 0 ? "1st" : (i === 1 ? "2nd" : "3rd");
          el.textContent = `${suffix}: ${competitors[i].name} (${Math.floor(competitors[i].distance)}m)${competitors[i].isDead ? ' CRASH' : ''}`;

          if (competitors[i].name === "You") {
            el.classList.add("rank-highlight");
            el.style.color = competitors[i].color;
          } else {
            el.classList.remove("rank-highlight");
            el.style.color = "inherit";
          }
        }
      }
    }
  }

  // --- Grid boundary collision assessments ---
  checkCollisions() {
    const px = this.player.x;
    const py = this.player.y;
    const size = this.player.size;

    // Obstacles check
    this.obstacles.forEach(obs => {
      // Get screen offset coordinate
      const ox = obs.x - this.scrollX;

      // AABB overlap check
      if (
        px + size > ox &&
        px - size < ox + obs.width
      ) {
        if (obs.type === "block") {
          if (py + size > obs.y && py - size < obs.y + obs.height) {
            this.triggerCrash();
          }
        } else if (obs.type === "spike") {
          // Precise spike height boundaries representation
          if (obs.alignment === "floor") {
            if (py + size > obs.y) {
              this.triggerCrash();
            }
          } else {
            if (py - size < obs.height) {
              this.triggerCrash();
            }
          }
        }
      }
    });

    // Collectibles pick up
    this.collectibles.forEach(gem => {
      if (!gem.active) return;

      const gx = gem.x - this.scrollX;
      const dx = px - gx;
      const dy = py - gem.y;
      const dist = Math.sqrt(dx * dx + dy * dy);

      if (dist < size + gem.size) {
        gem.active = false;
        this.gemsCollected++;
        window.audioSynth.playCoin();

        // Green particle splash burst
        this.createExplosion(gx, gem.y, "#00e676", 10, 80);
      }
    });
  }

  // --- Visual explosion particles generator ---
  createExplosion(x, y, color, count = 25, speedRange = 160) {
    for (let i = 0; i < count; i++) {
      const angle = Math.random() * Math.PI * 2;
      const speed = Math.random() * speedRange + 20;
      this.particles.push({
        x: x,
        y: y,
        vx: Math.cos(angle) * speed,
        vy: Math.sin(angle) * speed,
        color: color,
        size: Math.random() * 4 + 2,
        life: Math.random() * 0.6 + 0.3
      });
    }
  }

  // --- Game Over Crash sequence ---
  triggerCrash() {
    if (this.isDead || this.isFinished) return;

    this.isDead = true;
    window.audioSynth.playCrash();

    // Trigger visual screen shake & flash if motion accessibility allows
    const reduceMotion = window.stateMgr.state.reduceMotionEnabled;
    if (!reduceMotion) {
      this.screenShakeTime = 0.3;
      this.screenShakeIntensity = 12;

      const flash = document.getElementById("flash-overlay");
      if (flash) {
        flash.classList.add("flash-active");
        setTimeout(() => flash.classList.remove("flash-active"), 400);
      }
    }

    // Explosion particles
    this.createExplosion(this.player.x, this.player.y, this.player.color, 35, 220);

    // Save progression on highscores
    if (this.mode === "endless") {
      const oldHighScore = window.stateMgr.state.endlessHighscore;
      const roundedDistance = Math.floor(this.distanceTraveled);
      if (roundedDistance > oldHighScore) {
        window.stateMgr.state.endlessHighscore = roundedDistance;
      }
      // Progressive rewards: 1 gem for every 10 meters flown
      const runGemsReward = Math.floor(roundedDistance / 10) + this.gemsCollected;
      window.stateMgr.state.gems += runGemsReward;
      window.stateMgr.save();

      setTimeout(() => this.showGameOverScreen(roundedDistance, runGemsReward, roundedDistance > oldHighScore), 900);
    } else {
      // Classic/Race level crashed logic
      // Give partial gems accumulated during trial runs
      window.stateMgr.state.gems += this.gemsCollected;
      window.stateMgr.save();

      setTimeout(() => this.showGameOverScreen(Math.floor(this.distanceTraveled), this.gemsCollected, false), 900);
    }
  }

  // --- Run Success Finished sequence ---
  triggerComplete() {
    if (this.isFinished || this.isDead) return;

    this.isFinished = true;
    window.audioSynth.playComplete();

    // Celebrate with colorful fireworks
    for (let i = 0; i < 5; i++) {
      setTimeout(() => {
        this.createExplosion(
          this.player.x + (Math.random() - 0.5) * 200,
          this.height / 2 + (Math.random() - 0.5) * 300,
          `hsl(${Math.random() * 360}, 100%, 65%)`,
          30,
          180
        );
      }, i * 150);
    }

    if (this.mode === "classic") {
      // Calculate star awards:
      // 1 Star: Just complete
      // 2 Stars: Complete with at least 50% collectibles
      // 3 Stars: Gather all gems!
      let stars = 1;
      const totalGemsInLevel = this.collectibles.length;
      const collectedRatio = totalGemsInLevel > 0 ? (this.gemsCollected / totalGemsInLevel) : 1;

      if (collectedRatio >= 1.0) stars = 3;
      else if (collectedRatio >= 0.5) stars = 2;

      const previousStars = window.stateMgr.state.levelProgress[this.currentLevelIndex] || 0;
      if (stars > previousStars) {
        window.stateMgr.state.levelProgress[this.currentLevelIndex] = stars;
      }

      // Completion gems prize: 100 gems * stars won
      const rewardGems = stars * 100 + this.gemsCollected;
      window.stateMgr.state.gems += rewardGems;
      window.stateMgr.save();

      setTimeout(() => this.showLevelCompleteScreen(stars, rewardGems), 1200);
    } else if (this.mode === "race") {
      // Determine bot relative finishes
      const playerRankIdx = this.getRacePlacementIndex();

      let rewardGems = this.gemsCollected;
      let title = "RACE COMING SOON";
      let description = "You crashed!";

      if (!this.isDead) {
        if (playerRankIdx === 0) {
          title = "1st PLACE WINNER!";
          rewardGems += 500; // Big jackpot
          description = "Incredible speed! You dominated the race tracks.";
        } else if (playerRankIdx === 1) {
          title = "2nd PLACE RUNNER";
          rewardGems += 200;
          description = "Very close! Try again to snatch the champion title.";
        } else {
          title = "3rd PLACE FINISH";
          rewardGems += 50;
          description = "Keep practicing. Precision beats timing.";
        }
      }

      window.stateMgr.state.gems += rewardGems;
      window.stateMgr.save();

      setTimeout(() => this.showRaceResultScreen(playerRankIdx + 1, rewardGems, description), 1200);
    }
  }

  getRacePlacementIndex() {
    const competitors = [
      { name: "You", distance: this.distanceTraveled, isDead: this.isDead },
      ...this.bots.map(b => ({ name: b.name, distance: b.distance, isDead: b.isDead }))
    ];

    competitors.sort((a, b) => {
      if (a.isDead && !b.isDead) return 1;
      if (!a.isDead && b.isDead) return -1;
      return b.distance - a.distance;
    });

    return competitors.findIndex(c => c.name === "You");
  }

  // --- Dynamic Results Overlays creation ---
  showGameOverScreen(distance, gemReward, isNewHighscore) {
    const content = `
      <h1 style="color: #ff1744;">CRASHED!</h1>
      <div class="stat-group">
        <div class="stat-item">Distance Flown: <strong>${distance}m</strong></div>
        ${isNewHighscore ? '<div style="color:#ffeb3b; font-weight:700; margin:4px 0;">🎉 NEW PERSONAL BEST!</div>' : ''}
        <div class="stat-item" style="display:flex; align-items:center; gap:4px; margin-top:8px;">
          Gems Earned:
          <span style="color:var(--accent-color); font-weight:700; display:flex; align-items:center; gap:2px;">
            <svg viewBox="0 0 24 24" width="14" height="14" fill="var(--accent-color)"><polygon points="12,2 22,9 17,22 7,22 2,9"></polygon></svg>
            ${gemReward}
          </span>
        </div>
      </div>
      <div class="end-panel-buttons" style="margin-top:15px; width:100%;">
        <button id="btn-over-retry" class="primary btn" style="width:100%;">TRY AGAIN ▶</button>
        <button id="btn-over-menu" class="btn" style="width:100%; margin-top:8px;">EXIT TO MENU</button>
      </div>
    `;

    openModal(content);

    document.getElementById("btn-over-retry").addEventListener("click", () => {
      window.audioSynth.playClick();
      closeModal();
      this.restartRun();
    });

    document.getElementById("btn-over-menu").addEventListener("click", () => {
      window.audioSynth.playClick();
      closeModal();
      this.stop();
    });
  }

  showLevelCompleteScreen(stars, gemReward) {
    let starsHtml = "";
    for (let s = 1; s <= 3; s++) {
      starsHtml += `<span style="font-size: 2.2rem; margin: 0 4px; color:${s <= stars ? '#ffeb3b' : 'rgba(255,255,255,0.15)'}">★</span>`;
    }

    const nextLevelAvailable = this.currentLevelIndex < 9;

    const content = `
      <h1 style="color: var(--accent-color);">LEVEL COMPLETE!</h1>
      <div class="stars-reward">
        ${starsHtml}
      </div>
      <div class="stat-group">
        <div class="stat-item" style="display:flex; align-items:center; gap:4px;">
          Reward Prize:
          <span style="color:var(--accent-color); font-weight:700; display:flex; align-items:center; gap:2px;">
            <svg viewBox="0 0 24 24" width="14" height="14" fill="var(--accent-color)"><polygon points="12,2 22,9 17,22 7,22 2,9"></polygon></svg>
            ${gemReward}
          </span>
        </div>
      </div>
      <div class="end-panel-buttons" style="margin-top:20px; width:100%;">
        ${nextLevelAvailable ? '<button id="btn-comp-next" class="primary btn" style="width:100%;">NEXT LEVEL ▶</button>' : ''}
        <button id="btn-comp-retry" class="btn" style="width:100%; margin-top:8px;">REPLAY LEVEL</button>
        <button id="btn-comp-menu" class="btn" style="width:100%; margin-top:8px;">BACK TO MAPS</button>
      </div>
    `;

    openModal(content);

    if (nextLevelAvailable) {
      document.getElementById("btn-comp-next").addEventListener("click", () => {
        window.audioSynth.playClick();
        closeModal();
        this.currentLevelIndex++;
        this.restartRun();
      });
    }

    document.getElementById("btn-comp-retry").addEventListener("click", () => {
      window.audioSynth.playClick();
      closeModal();
      this.restartRun();
    });

    document.getElementById("btn-comp-menu").addEventListener("click", () => {
      window.audioSynth.playClick();
      closeModal();
      // Route back to Level grid view
      this.active = false;
      showScreen("screen-levels");
    });
  }

  showRaceResultScreen(rank, gemReward, description) {
    let placementText = "3rd Place Finish";
    let placementColor = "#ff8a80";
    if (rank === 1) {
      placementText = "🏆 CHAMPION! 1st PLACE";
      placementColor = "#ffd700";
    } else if (rank === 2) {
      placementText = "🥈 RUNNER UP! 2nd PLACE";
      placementColor = "#e0e0e0";
    }

    const content = `
      <h1 style="color: ${placementColor};">${placementText}</h1>
      <p style="font-size:0.9rem; opacity:0.8; margin-bottom:10px;">${description}</p>
      <div class="stat-group">
        <div class="stat-item" style="display:flex; align-items:center; gap:4px;">
          Jackpot payout:
          <span style="color:var(--accent-color); font-weight:700; display:flex; align-items:center; gap:2px;">
            <svg viewBox="0 0 24 24" width="14" height="14" fill="var(--accent-color)"><polygon points="12,2 22,9 17,22 7,22 2,9"></polygon></svg>
            ${gemReward}
          </span>
        </div>
      </div>
      <div class="end-panel-buttons" style="margin-top:20px; width:100%;">
        <button id="btn-race-retry" class="primary btn" style="width:100%;">RACE AGAIN ▶</button>
        <button id="btn-race-menu" class="btn" style="width:100%; margin-top:8px;">EXIT TO MENU</button>
      </div>
    `;

    openModal(content);

    document.getElementById("btn-race-retry").addEventListener("click", () => {
      window.audioSynth.playClick();
      closeModal();
      this.restartRun();
    });

    document.getElementById("btn-race-menu").addEventListener("click", () => {
      window.audioSynth.playClick();
      closeModal();
      this.stop();
    });
  }

  // --- Dynamic Canvas Renderers ---
  render() {
    if (!this.ctx) return;

    this.ctx.save();

    // 1. Screen Shake Matrix manipulation
    if (this.screenShakeTime > 0) {
      const dx = (Math.random() - 0.5) * this.screenShakeIntensity;
      const dy = (Math.random() - 0.5) * this.screenShakeIntensity;
      this.ctx.translate(dx, dy);
    }

    // Clear Canvas with starfield space styling
    this.ctx.fillStyle = "#0c0117";
    this.ctx.fillRect(0, 0, this.width, this.height);

    // Draw parallax background stars
    this.renderStars();

    // Draw custom background grid pattern matching classic look
    this.renderBackgrid();

    // Draw active obstacles
    this.renderObstacles();

    // Draw collectibles
    this.renderCollectibles();

    // Draw AI opponent paths & ships
    this.renderBots();

    // Draw trailing glow behind player
    this.renderTrail(this.player.trail, this.player.color);

    // Draw player ship skin
    if (!this.isDead) {
      this.renderPlayerShip();
    }

    // Draw finish line checkerboard block in non-endless modes
    if (this.mode !== "endless") {
      this.renderFinishLine();
    }

    // Draw bursts/explosion particles
    this.renderParticles();

    this.ctx.restore();
  }

  renderStars() {
    // Semi-persistent static dot placement
    this.ctx.fillStyle = "rgba(255,255,255,0.4)";
    const seed = 42;
    for (let i = 0; i < 40; i++) {
      const sx = (Math.sin(i * 123 + seed) * 10000) % this.width;
      const sy = (Math.cos(i * 543 + seed) * 10000) % this.height;

      // Horizontal slower parallax drift relative to progression
      const driftX = (sx - this.scrollX * 0.15) % this.width;
      const finalX = driftX < 0 ? driftX + this.width : driftX;

      this.ctx.beginPath();
      this.ctx.arc(finalX, sy, 1.5, 0, Math.PI * 2);
      this.ctx.fill();
    }
  }

  renderBackgrid() {
    this.ctx.strokeStyle = "rgba(255, 255, 255, 0.02)";
    this.ctx.lineWidth = 1;

    const gridSize = 60;
    const offsetX = -(this.scrollX % gridSize);

    // Vertical lines
    for (let x = offsetX; x < this.width; x += gridSize) {
      this.ctx.beginPath();
      this.ctx.moveTo(x, 0);
      this.ctx.lineTo(x, this.height);
      this.ctx.stroke();
    }

    // Horizontal lines
    for (let y = 0; y < this.height; y += gridSize) {
      this.ctx.beginPath();
      this.ctx.moveTo(0, y);
      this.ctx.lineTo(this.width, y);
      this.ctx.stroke();
    }
  }

  renderObstacles() {
    const state = window.stateMgr.state;
    const theme = window.THEMES[state.equippedTheme] || window.THEMES["purple"];

    this.obstacles.forEach(obs => {
      const ox = obs.x - this.scrollX;
      // Skip drawing off-screen elements
      if (ox + obs.width < 0 || ox > this.width) return;

      this.ctx.save();

      if (obs.type === "block") {
        // Outline layout blocks
        this.ctx.fillStyle = theme.primary;
        this.ctx.strokeStyle = theme.secondary;
        this.ctx.lineWidth = 2.5;

        // Round rect draw standard
        this.ctx.beginPath();
        this.ctx.roundRect(ox, obs.y, obs.width, obs.height, 6);
        this.ctx.fill();
        this.ctx.stroke();

        // Internal cross patterns
        this.ctx.strokeStyle = "rgba(255, 255, 255, 0.08)";
        this.ctx.beginPath();
        this.ctx.moveTo(ox + 4, obs.y + 4);
        this.ctx.lineTo(ox + obs.width - 4, obs.y + obs.height - 4);
        this.ctx.moveTo(ox + obs.width - 4, obs.y + 4);
        this.ctx.lineTo(ox + 4, obs.y + obs.height - 4);
        this.ctx.stroke();

      } else if (obs.type === "spike") {
        // Angled Spike Triangles
        this.ctx.fillStyle = "#ff1744";
        this.ctx.strokeStyle = "#ff8a80";
        this.ctx.lineWidth = 2;

        this.ctx.beginPath();
        if (obs.alignment === "floor") {
          this.ctx.moveTo(ox, this.height);
          this.ctx.lineTo(ox + obs.width / 2, obs.y);
          this.ctx.lineTo(ox + obs.width, this.height);
        } else {
          this.ctx.moveTo(ox, 0);
          this.ctx.lineTo(ox + obs.width / 2, obs.height);
          this.ctx.lineTo(ox + obs.width, 0);
        }
        this.ctx.closePath();
        this.ctx.fill();
        this.ctx.stroke();
      }

      this.ctx.restore();
    });
  }

  renderCollectibles() {
    this.collectibles.forEach(gem => {
      if (!gem.active) return;

      const gx = gem.x - this.scrollX;
      if (gx + gem.size < 0 || gx - gem.size > this.width) return;

      this.ctx.save();

      // Shiny spinning Diamond shape representation
      const spinAngle = (performance.now() / 250) % (Math.PI * 2);
      this.ctx.translate(gx, gem.y);
      this.ctx.rotate(spinAngle);

      this.ctx.fillStyle = "rgba(0, 229, 255, 0.8)";
      this.ctx.strokeStyle = "#fff";
      this.ctx.lineWidth = 1.5;

      this.ctx.beginPath();
      this.ctx.moveTo(0, -gem.size);
      this.ctx.lineTo(gem.size * 0.7, 0);
      this.ctx.lineTo(0, gem.size);
      this.ctx.lineTo(-gem.size * 0.7, 0);
      this.ctx.closePath();
      this.ctx.fill();
      this.ctx.stroke();

      this.ctx.restore();
    });
  }

  renderBots() {
    this.bots.forEach(bot => {
      if (bot.isDead) return;

      const rx = bot.x + (bot.distance - this.distanceTraveled);
      if (rx + bot.size < 0 || rx - bot.size > this.width) return;

      // Bot trailing streak
      this.renderTrail(bot.trail, bot.color);

      // Bot outline ship body
      this.ctx.save();
      this.ctx.translate(rx, bot.y);

      this.ctx.fillStyle = bot.color;
      this.ctx.strokeStyle = "#fff";
      this.ctx.lineWidth = 1.5;

      // Small generic ghost spaceship representation
      this.ctx.beginPath();
      this.ctx.moveTo(-bot.size, -bot.size * 0.7);
      this.ctx.lineTo(bot.size * 1.2, 0);
      this.ctx.lineTo(-bot.size, bot.size * 0.7);
      this.ctx.lineTo(-bot.size * 0.4, 0);
      this.ctx.closePath();
      this.ctx.fill();
      this.ctx.stroke();

      // Label indicator tag
      this.ctx.fillStyle = "rgba(255,255,255,0.7)";
      this.ctx.font = "bold 9px sans-serif";
      this.ctx.textAlign = "center";
      this.ctx.fillText(bot.name, 0, -bot.size - 4);

      this.ctx.restore();
    });
  }

  renderTrail(trailPoints, defaultColor) {
    if (trailPoints.length < 2) return;

    this.ctx.save();

    const state = window.stateMgr.state;
    const trailData = window.TRAILS.find(t => t.id === state.equippedTrail) || window.TRAILS[0];

    // Build connected canvas line segment string
    this.ctx.lineWidth = 6;
    this.ctx.lineCap = "round";
    this.ctx.lineJoin = "round";

    for (let i = 1; i < trailPoints.length; i++) {
      const p1 = trailPoints[i - 1];
      const p2 = trailPoints[i];

      let ptColor = defaultColor;
      if (trailData.color === "rainbow") {
        ptColor = `hsla(${(i * 5 + performance.now() / 10) % 360}, 100%, 65%, ${p2.age})`;
      } else if (trailData.color === "fire") {
        ptColor = `rgba(255, ${Math.floor(p2.age * 200)}, 0, ${p2.age})`;
      } else {
        // Fallback or custom single color
        const base = trailData.color === "#ffffff" ? defaultColor : trailData.color;
        ptColor = hexToRgbA(base, p2.age);
      }

      this.ctx.strokeStyle = ptColor;
      this.ctx.beginPath();
      this.ctx.moveTo(p1.x, p1.y);
      this.ctx.lineTo(p2.x, p2.y);
      this.ctx.stroke();
    }

    this.ctx.restore();
  }

  renderPlayerShip() {
    this.ctx.save();
    this.ctx.translate(this.player.x, this.player.y);
    this.ctx.rotate(this.player.angle);

    // Apply color skin
    this.ctx.fillStyle = this.player.color;
    this.ctx.strokeStyle = "#ffffff";
    this.ctx.lineWidth = 2.5;

    const state = window.stateMgr.state;
    const ship = window.SHIPS.find(s => s.id === state.equippedShip) || window.SHIPS[0];

    // Map SVG shapes to canvas rendering commands to accurately render all 20 skins!
    if (ship.id === "classic") {
      this.ctx.beginPath();
      this.ctx.moveTo(-this.player.size * 1.2, -this.player.size);
      this.ctx.lineTo(this.player.size * 1.5, 0);
      this.ctx.lineTo(-this.player.size * 1.2, this.player.size);
      this.ctx.lineTo(-this.player.size * 0.4, 0);
      this.ctx.closePath();
      this.ctx.fill();
      this.ctx.stroke();
    } else if (ship.id === "teardrop") {
      this.ctx.beginPath();
      this.ctx.arc(0, 0, this.player.size, 0, Math.PI * 2);
      this.ctx.fill();
      this.ctx.stroke();
      this.ctx.beginPath();
      this.ctx.moveTo(0, -this.player.size);
      this.ctx.lineTo(this.player.size * 1.5, 0);
      this.ctx.lineTo(0, this.player.size);
      this.ctx.fill();
    } else if (ship.id === "paper_airplane") {
      this.ctx.beginPath();
      this.ctx.moveTo(-this.player.size * 1.2, -this.player.size * 1.2);
      this.ctx.lineTo(this.player.size * 1.5, 0);
      this.ctx.lineTo(-this.player.size * 0.4, this.player.size * 0.35);
      this.ctx.lineTo(-this.player.size * 1.2, this.player.size * 1.2);
      this.ctx.lineTo(0, this.player.size * 0.2);
      this.ctx.closePath();
      this.ctx.fill();
      this.ctx.stroke();
    } else if (ship.id === "rocket") {
      this.ctx.beginPath();
      this.ctx.moveTo(-this.player.size * 1.2, -this.player.size * 0.6);
      this.ctx.lineTo(-this.player.size * 0.4, -this.player.size * 0.6);
      this.ctx.lineTo(this.player.size * 1.5, 0);
      this.ctx.lineTo(-this.player.size * 0.4, this.player.size * 0.6);
      this.ctx.lineTo(-this.player.size * 1.2, this.player.size * 0.6);
      this.ctx.lineTo(-this.player.size * 0.8, 0);
      this.ctx.closePath();
      this.ctx.fill();
      this.ctx.stroke();
    } else if (ship.id === "shuriken") {
      this.ctx.beginPath();
      for (let i = 0; i < 8; i++) {
        const r = i % 2 === 0 ? this.player.size * 1.4 : this.player.size * 0.5;
        const angle = (i * Math.PI) / 4;
        this.ctx.lineTo(Math.cos(angle) * r, Math.sin(angle) * r);
      }
      this.ctx.closePath();
      this.ctx.fill();
      this.ctx.stroke();
    } else if (ship.id === "falcon") {
      this.ctx.beginPath();
      this.ctx.moveTo(-this.player.size * 1.2, -this.player.size * 0.8);
      this.ctx.lineTo(-this.player.size * 0.6, -this.player.size * 0.4);
      this.ctx.lineTo(this.player.size * 1.5, 0);
      this.ctx.lineTo(-this.player.size * 0.6, this.player.size * 0.4);
      this.ctx.lineTo(-this.player.size * 1.2, this.player.size * 0.8);
      this.ctx.lineTo(-this.player.size * 0.8, 0);
      this.ctx.closePath();
      this.ctx.fill();
      this.ctx.stroke();
    } else if (ship.id === "diamond_tail") {
      this.ctx.beginPath();
      this.ctx.moveTo(-this.player.size * 1.2, 0);
      this.ctx.lineTo(0, -this.player.size);
      this.ctx.lineTo(this.player.size * 1.5, 0);
      this.ctx.lineTo(0, this.player.size);
      this.ctx.closePath();
      this.ctx.fill();
      this.ctx.stroke();
    } else if (ship.id === "eye_ship") {
      this.ctx.beginPath();
      this.ctx.arc(0, 0, this.player.size, 0, Math.PI * 2);
      this.ctx.fill();
      this.ctx.stroke();
      this.ctx.fillStyle = "#ffffff";
      this.ctx.beginPath();
      this.ctx.arc(this.player.size * 0.3, 0, this.player.size * 0.4, 0, Math.PI * 2);
      this.ctx.fill();
      this.ctx.fillStyle = "#000000";
      this.ctx.beginPath();
      this.ctx.arc(this.player.size * 0.4, 0, this.player.size * 0.18, 0, Math.PI * 2);
      this.ctx.fill();
    } else if (ship.id === "batwing") {
      this.ctx.beginPath();
      this.ctx.moveTo(-this.player.size * 1.2, -this.player.size);
      this.ctx.lineTo(-this.player.size * 0.4, -this.player.size * 0.4);
      this.ctx.lineTo(0, -this.player.size);
      this.ctx.lineTo(this.player.size * 1.5, 0);
      this.ctx.lineTo(0, this.player.size);
      this.ctx.lineTo(-this.player.size * 0.4, this.player.size * 0.4);
      this.ctx.lineTo(-this.player.size * 1.2, this.player.size);
      this.ctx.lineTo(-this.player.size * 0.8, 0);
      this.ctx.closePath();
      this.ctx.fill();
      this.ctx.stroke();
    } else if (ship.id === "ufo") {
      this.ctx.beginPath();
      this.ctx.ellipse(0, 0, this.player.size * 1.5, this.player.size * 0.6, 0, 0, Math.PI * 2);
      this.ctx.fill();
      this.ctx.stroke();
      this.ctx.beginPath();
      this.ctx.arc(0, -this.player.size * 0.2, this.player.size * 0.6, Math.PI, 0);
      this.ctx.fill();
      this.ctx.stroke();
    } else if (ship.id === "cyber_dart") {
      this.ctx.beginPath();
      this.ctx.moveTo(-this.player.size * 1.4, -this.player.size * 0.4);
      this.ctx.lineTo(this.player.size * 1.6, 0);
      this.ctx.lineTo(-this.player.size * 1.4, this.player.size * 0.4);
      this.ctx.lineTo(-this.player.size * 0.8, 0);
      this.ctx.closePath();
      this.ctx.fill();
      this.ctx.stroke();
    } else if (ship.id === "phoenix") {
      this.ctx.beginPath();
      this.ctx.moveTo(-this.player.size * 1.2, -this.player.size * 0.2);
      this.ctx.quadraticCurveTo(-this.player.size * 0.4, -this.player.size * 1.4, this.player.size * 0.6, -this.player.size * 0.6);
      this.ctx.lineTo(this.player.size * 1.5, 0);
      this.ctx.lineTo(this.player.size * 0.6, this.player.size * 0.6);
      this.ctx.quadraticCurveTo(-this.player.size * 0.4, this.player.size * 1.4, -this.player.size * 1.2, this.player.size * 0.2);
      this.ctx.lineTo(-this.player.size * 0.6, 0);
      this.ctx.closePath();
      this.ctx.fill();
      this.ctx.stroke();
    } else if (ship.id === "nautilus") {
      this.ctx.beginPath();
      this.ctx.arc(0, 0, this.player.size * 1.1, 0, Math.PI * 2);
      this.ctx.stroke();
      this.ctx.beginPath();
      this.ctx.arc(0, 0, this.player.size * 0.7, 0, Math.PI * 2);
      this.ctx.fill();
      this.ctx.stroke();
    } else if (ship.id === "phantom") {
      this.ctx.beginPath();
      this.ctx.moveTo(-this.player.size * 1.4, -this.player.size * 1.4);
      this.ctx.lineTo(this.player.size * 1.5, 0);
      this.ctx.lineTo(-this.player.size * 1.4, this.player.size * 1.4);
      this.ctx.lineTo(-this.player.size * 0.8, 0);
      this.ctx.closePath();
      this.ctx.fill();
      this.ctx.stroke();
    } else if (ship.id === "hammerhead") {
      this.ctx.beginPath();
      this.ctx.moveTo(-this.player.size * 1.2, -this.player.size * 0.8);
      this.ctx.lineTo(-this.player.size * 1.2, this.player.size * 0.8);
      this.ctx.lineTo(-this.player.size * 0.6, this.player.size * 0.4);
      this.ctx.lineTo(this.player.size * 1.5, 0);
      this.ctx.lineTo(-this.player.size * 0.6, -this.player.size * 0.4);
      this.ctx.closePath();
      this.ctx.fill();
      this.ctx.stroke();
    } else if (ship.id === "waverider") {
      this.ctx.beginPath();
      this.ctx.ellipse(0, 0, this.player.size * 1.4, this.player.size * 0.8, 0, 0, Math.PI * 2);
      this.ctx.fill();
      this.ctx.stroke();
      this.ctx.beginPath();
      this.ctx.arc(0, 0, this.player.size * 0.4, 0, Math.PI * 2);
      this.ctx.stroke();
    } else if (ship.id === "spearhead") {
      this.ctx.beginPath();
      this.ctx.moveTo(-this.player.size * 1.2, -this.player.size * 0.8);
      this.ctx.lineTo(-this.player.size * 0.2, -this.player.size * 0.4);
      this.ctx.lineTo(this.player.size * 1.6, 0);
      this.ctx.lineTo(-this.player.size * 0.2, this.player.size * 0.4);
      this.ctx.lineTo(-this.player.size * 1.2, this.player.size * 0.8);
      this.ctx.lineTo(-this.player.size * 0.6, 0);
      this.ctx.closePath();
      this.ctx.fill();
      this.ctx.stroke();
    } else if (ship.id === "vortex") {
      this.ctx.beginPath();
      this.ctx.arc(0, 0, this.player.size * 1.3, 0, Math.PI * 2);
      this.ctx.fill();
      this.ctx.stroke();
      this.ctx.beginPath();
      this.ctx.arc(this.player.size * 0.3, 0, this.player.size * 0.5, 0, Math.PI * 2);
      this.ctx.fill();
      this.ctx.stroke();
    } else if (ship.id === "orion") {
      this.ctx.beginPath();
      this.ctx.moveTo(-this.player.size * 1.2, 0);
      this.ctx.lineTo(-this.player.size * 0.2, -this.player.size * 0.8);
      this.ctx.lineTo(this.player.size * 1.5, 0);
      this.ctx.lineTo(-this.player.size * 0.2, this.player.size * 0.8);
      this.ctx.closePath();
      this.ctx.fill();
      this.ctx.stroke();
      this.ctx.beginPath();
      this.ctx.moveTo(-this.player.size * 0.2, -this.player.size * 0.8);
      this.ctx.lineTo(-this.player.size * 0.2, -this.player.size * 1.5);
      this.ctx.lineTo(this.player.size * 0.4, -this.player.size * 0.8);
      this.ctx.closePath();
      this.ctx.fill();
      this.ctx.stroke();
    } else if (ship.id === "dragonfly") {
      this.ctx.beginPath();
      this.ctx.ellipse(0, 0, this.player.size * 1.5, this.player.size * 0.3, 0, 0, Math.PI * 2);
      this.ctx.fill();
      this.ctx.stroke();
      this.ctx.beginPath();
      this.ctx.ellipse(-this.player.size * 0.3, 0, this.player.size * 0.4, this.player.size * 1.4, 0, 0, Math.PI * 2);
      this.ctx.fill();
      this.ctx.stroke();
    } else {
      // General dynamic generic polygon representation for foreign elements
      this.ctx.beginPath();
      this.ctx.moveTo(-this.player.size, -this.player.size * 0.8);
      this.ctx.lineTo(this.player.size * 1.4, 0);
      this.ctx.lineTo(-this.player.size, this.player.size * 0.8);
      this.ctx.lineTo(-this.player.size * 0.3, 0);
      this.ctx.closePath();
      this.ctx.fill();
      this.ctx.stroke();
    }

    this.ctx.restore();
  }

  renderFinishLine() {
    const fx = this.targetDistance - this.scrollX;
    if (fx + 40 < 0 || fx > this.width) return;

    this.ctx.save();

    // Checkered vertical banner blocks
    const boxSize = 20;
    this.ctx.fillStyle = "#fff";
    for (let y = 0; y < this.height; y += boxSize * 2) {
      this.ctx.fillRect(fx, y, boxSize, boxSize);
      this.ctx.fillRect(fx + boxSize, y + boxSize, boxSize, boxSize);
    }

    this.ctx.fillStyle = "#000";
    for (let y = 0; y < this.height; y += boxSize * 2) {
      this.ctx.fillRect(fx + boxSize, y, boxSize, boxSize);
      this.ctx.fillRect(fx, y + boxSize, boxSize, boxSize);
    }

    // Green glow overlay
    this.ctx.strokeStyle = "rgba(0, 230, 118, 0.4)";
    this.ctx.lineWidth = 4;
    this.ctx.beginPath();
    this.ctx.moveTo(fx, 0);
    this.ctx.lineTo(fx, this.height);
    this.ctx.stroke();

    this.ctx.restore();
  }

  renderParticles() {
    this.particles.forEach(p => {
      this.ctx.save();
      this.ctx.fillStyle = p.color;
      this.ctx.globalAlpha = Math.max(0, p.life);
      this.ctx.beginPath();
      this.ctx.arc(p.x, p.y, p.size, 0, Math.PI * 2);
      this.ctx.fill();
      this.ctx.restore();
    });
  }
}

// Global active wrapper interface functions
window.gameEngine = new GameEngine();

function startGameRun(mode, levelIdx = 0) {
  window.gameEngine.start(mode, levelIdx);
}

// Utility hex alpha converter
function hexToRgbA(hex, alpha = 1.0){
  let c;
  if(/^#([A-Fa-f0-9]{3}){1,2}$/.test(hex)){
    c= hex.substring(1).split('');
    if(c.length === 3){
      c= [c[0], c[0], c[1], c[1], c[2], c[2]];
    }
    c= '0x' + c.join('');
    return 'rgba('+[(c>>16)&255, (c>>8)&255, c&255].join(',')+','+alpha+')';
  }
  return hex;
}
