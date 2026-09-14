/**
 * WHISPERS OF THE ANCIENT GROVE - 2D Fantasy Adventure Game
 * Core Engine & Gameplay Script
 */

// ==========================================================================
// 1. GAME CONFIGURATION & GLOBALS
// ==========================================================================
const CONFIG = {
  CANVAS_WIDTH: 1280,
  CANVAS_HEIGHT: 720,
  GRAVITY: 1400, // px / s^2
  PLAYER: {
    WIDTH: 36,
    HEIGHT: 52,
    MOVE_SPEED: 320,
    JUMP_FORCE: -620,
    MAX_HEALTH: 5,
    INVULN_DURATION: 1.2, // seconds
    ATTACK_RANGE: 65,
    ATTACK_DURATION: 0.25, // seconds
  },
  WORLD: {
    WIDTH: 5200,
    HEIGHT: 1200,
    GROUND_Y: 580, // Set reachable ground Y relative to 720 canvas
  },
  KEYS: {
    LEFT: ['KeyA', 'ArrowLeft'],
    RIGHT: ['KeyD', 'ArrowRight'],
    JUMP: ['KeyW', 'ArrowUp', 'Space'],
    ATTACK: ['KeyJ', 'KeyX'],
    PAUSE: ['Escape', 'KeyP']
  }
};

// ==========================================================================
// 2. AUDIO SYSTEM (Web Audio API Synthesizer)
// ==========================================================================
class AudioEngine {
  constructor() {
    this.ctx = null;
    this.musicGain = null;
    this.sfxGain = null;
    this.musicVolume = 0.7;
    this.sfxVolume = 0.8;
    this.isBgmPlaying = false;
    this.bgmTimer = null;
  }

  init() {
    if (this.ctx) return;
    const AudioCtx = window.AudioContext || window.webkitAudioContext;
    if (!AudioCtx) return;
    this.ctx = new AudioCtx();

    this.musicGain = this.ctx.createGain();
    this.sfxGain = this.ctx.createGain();

    this.musicGain.gain.value = this.musicVolume;
    this.sfxGain.gain.value = this.sfxVolume;

    this.musicGain.connect(this.ctx.destination);
    this.sfxGain.connect(this.ctx.destination);
  }

  ensureContext() {
    if (!this.ctx) this.init();
    if (this.ctx && this.ctx.state === 'suspended') {
      this.ctx.resume();
    }
  }

  setMusicVolume(val) {
    this.musicVolume = Math.max(0, Math.min(1, val));
    if (this.musicGain) this.musicGain.gain.value = this.musicVolume;
  }

  setSfxVolume(val) {
    this.sfxVolume = Math.max(0, Math.min(1, val));
    if (this.sfxGain) this.sfxGain.gain.value = this.sfxVolume;
  }

  playTone(freq, type, duration, gainStart = 0.3, gainEnd = 0.001) {
    if (!this.ctx || this.sfxVolume <= 0) return;
    this.ensureContext();

    const osc = this.ctx.createOscillator();
    const gain = this.ctx.createGain();

    osc.type = type;
    osc.frequency.setValueAtTime(freq, this.ctx.currentTime);

    gain.gain.setValueAtTime(gainStart * this.sfxVolume, this.ctx.currentTime);
    gain.gain.exponentialRampToValueAtTime(Math.max(0.0001, gainEnd), this.ctx.currentTime + duration);

    osc.connect(gain);
    gain.connect(this.sfxGain);

    osc.start();
    osc.stop(this.ctx.currentTime + duration);
  }

  playJump() {
    if (!this.ctx) return;
    this.ensureContext();
    const osc = this.ctx.createOscillator();
    const gain = this.ctx.createGain();

    osc.type = 'sine';
    osc.frequency.setValueAtTime(220, this.ctx.currentTime);
    osc.frequency.exponentialRampToValueAtTime(600, this.ctx.currentTime + 0.15);

    gain.gain.setValueAtTime(0.25 * this.sfxVolume, this.ctx.currentTime);
    gain.gain.linearRampToValueAtTime(0.01, this.ctx.currentTime + 0.15);

    osc.connect(gain);
    gain.connect(this.sfxGain);

    osc.start();
    osc.stop(this.ctx.currentTime + 0.15);
  }

  playCollect() {
    if (!this.ctx) return;
    this.ensureContext();
    const now = this.ctx.currentTime;
    [523.25, 659.25, 783.99, 1046.50].forEach((freq, i) => {
      const osc = this.ctx.createOscillator();
      const gain = this.ctx.createGain();
      osc.type = 'triangle';
      osc.frequency.setValueAtTime(freq, now + i * 0.05);

      gain.gain.setValueAtTime(0.2 * this.sfxVolume, now + i * 0.05);
      gain.gain.exponentialRampToValueAtTime(0.001, now + i * 0.05 + 0.12);

      osc.connect(gain);
      gain.connect(this.sfxGain);

      osc.start(now + i * 0.05);
      osc.stop(now + i * 0.05 + 0.12);
    });
  }

  playAttack() {
    if (!this.ctx) return;
    this.ensureContext();
    // Noise buffer slash sound
    const bufferSize = this.ctx.sampleRate * 0.12;
    const buffer = this.ctx.createBuffer(1, bufferSize, this.ctx.sampleRate);
    const output = buffer.getChannelData(0);
    for (let i = 0; i < bufferSize; i++) {
      output[i] = Math.random() * 2 - 1;
    }

    const whiteNoise = this.ctx.createBufferSource();
    whiteNoise.buffer = buffer;

    const filter = this.ctx.createBiquadFilter();
    filter.type = 'bandpass';
    filter.frequency.setValueAtTime(800, this.ctx.currentTime);
    filter.frequency.exponentialRampToValueAtTime(3000, this.ctx.currentTime + 0.1);

    const gain = this.ctx.createGain();
    gain.gain.setValueAtTime(0.4 * this.sfxVolume, this.ctx.currentTime);
    gain.gain.exponentialRampToValueAtTime(0.01, this.ctx.currentTime + 0.12);

    whiteNoise.connect(filter);
    filter.connect(gain);
    gain.connect(this.sfxGain);

    whiteNoise.start();
  }

  playHurt() {
    if (!this.ctx) return;
    this.ensureContext();
    const osc = this.ctx.createOscillator();
    const gain = this.ctx.createGain();

    osc.type = 'sawtooth';
    osc.frequency.setValueAtTime(180, this.ctx.currentTime);
    osc.frequency.exponentialRampToValueAtTime(60, this.ctx.currentTime + 0.2);

    gain.gain.setValueAtTime(0.35 * this.sfxVolume, this.ctx.currentTime);
    gain.gain.exponentialRampToValueAtTime(0.01, this.ctx.currentTime + 0.2);

    osc.connect(gain);
    gain.connect(this.sfxGain);

    osc.start();
    osc.stop(this.ctx.currentTime + 0.2);
  }

  playEnemyDefeat() {
    if (!this.ctx) return;
    this.ensureContext();
    const osc = this.ctx.createOscillator();
    const gain = this.ctx.createGain();

    osc.type = 'square';
    osc.frequency.setValueAtTime(300, this.ctx.currentTime);
    osc.frequency.exponentialRampToValueAtTime(80, this.ctx.currentTime + 0.25);

    gain.gain.setValueAtTime(0.3 * this.sfxVolume, this.ctx.currentTime);
    gain.gain.exponentialRampToValueAtTime(0.01, this.ctx.currentTime + 0.25);

    osc.connect(gain);
    gain.connect(this.sfxGain);

    osc.start();
    osc.stop(this.ctx.currentTime + 0.25);
  }

  playCheckpoint() {
    if (!this.ctx) return;
    this.ensureContext();
    const now = this.ctx.currentTime;
    [440, 554.37, 659.25, 880].forEach((freq, i) => {
      const osc = this.ctx.createOscillator();
      const gain = this.ctx.createGain();

      osc.type = 'sine';
      osc.frequency.setValueAtTime(freq, now + i * 0.08);

      gain.gain.setValueAtTime(0.25 * this.sfxVolume, now + i * 0.08);
      gain.gain.exponentialRampToValueAtTime(0.001, now + i * 0.08 + 0.3);

      osc.connect(gain);
      gain.connect(this.sfxGain);

      osc.start(now + i * 0.08);
      osc.stop(now + i * 0.08 + 0.3);
    });
  }

  playVictory() {
    if (!this.ctx) return;
    this.ensureContext();
    const notes = [523.25, 659.25, 783.99, 1046.50, 880, 1046.50];
    const times = [0, 0.15, 0.3, 0.45, 0.65, 0.85];
    const now = this.ctx.currentTime;

    notes.forEach((freq, i) => {
      const osc = this.ctx.createOscillator();
      const gain = this.ctx.createGain();

      osc.type = 'triangle';
      osc.frequency.setValueAtTime(freq, now + times[i]);

      gain.gain.setValueAtTime(0.3 * this.sfxVolume, now + times[i]);
      gain.gain.exponentialRampToValueAtTime(0.001, now + times[i] + 0.4);

      osc.connect(gain);
      gain.connect(this.sfxGain);

      osc.start(now + times[i]);
      osc.stop(now + times[i] + 0.4);
    });
  }

  startAmbientBgm() {
    if (this.isBgmPlaying) return;
    this.isBgmPlaying = true;
    this.loopAmbientNote();
  }

  stopAmbientBgm() {
    this.isBgmPlaying = false;
    if (this.bgmTimer) clearTimeout(this.bgmTimer);
  }

  loopAmbientNote() {
    if (!this.isBgmPlaying) return;
    this.ensureContext();
    if (this.ctx && this.musicVolume > 0) {
      const scale = [146.83, 164.81, 196.00, 220.00, 246.94, 293.66]; // D minor pentatonic
      const freq = scale[Math.floor(Math.random() * scale.length)];
      const now = this.ctx.currentTime;

      const osc = this.ctx.createOscillator();
      const gain = this.ctx.createGain();

      osc.type = 'sine';
      osc.frequency.setValueAtTime(freq, now);

      gain.gain.setValueAtTime(0.001, now);
      gain.gain.linearRampToValueAtTime(0.08 * this.musicVolume, now + 1.0);
      gain.gain.exponentialRampToValueAtTime(0.0001, now + 3.5);

      osc.connect(gain);
      gain.connect(this.musicGain);

      osc.start(now);
      osc.stop(now + 3.6);
    }
    this.bgmTimer = setTimeout(() => this.loopAmbientNote(), 2800 + Math.random() * 2000);
  }
}

// ==========================================================================
// 3. STORAGE & SAVE MANAGER
// ==========================================================================
class SaveSystem {
  static STORAGE_KEY = 'msai_grove_save_data';

  static getDefaultData() {
    return {
      highScore: 0,
      totalCoins: 0,
      checkpointX: 100,
      checkpointY: CONFIG.WORLD.GROUND_Y - CONFIG.PLAYER.HEIGHT,
      musicVolume: 70,
      sfxVolume: 80,
      graphicsQuality: 'high',
      mobileHudEnabled: true,
      hasSavedCheckpoint: false
    };
  }

  static load() {
    try {
      const data = localStorage.getItem(this.STORAGE_KEY);
      if (data) {
        return { ...this.getDefaultData(), ...JSON.parse(data) };
      }
    } catch (e) {
      console.warn('Failed to load save data from localStorage:', e);
    }
    return this.getDefaultData();
  }

  static save(data) {
    try {
      localStorage.setItem(this.STORAGE_KEY, JSON.stringify(data));
    } catch (e) {
      console.warn('Failed to save to localStorage:', e);
    }
  }
}

// ==========================================================================
// 4. INPUT CONTROLLER
// ==========================================================================
class InputHandler {
  constructor(game) {
    this.game = game;
    this.keys = {};
    this.touchState = {
      left: false,
      right: false,
      jump: false,
      attack: false
    };

    this.bindEvents();
  }

  bindEvents() {
    window.addEventListener('keydown', (e) => {
      this.game.audio.ensureContext();
      if (!this.keys[e.code]) {
        this.keys[e.code] = true;
        this.handleKeyPress(e.code);
      }
    });

    window.addEventListener('keyup', (e) => {
      this.keys[e.code] = false;
    });

    // Touch controls
    const bindTouch = (btnId, keyName) => {
      const btn = document.getElementById(btnId);
      if (!btn) return;

      const startAction = (e) => {
        e.preventDefault();
        this.game.audio.ensureContext();
        this.touchState[keyName] = true;
        btn.classList.add('active');

        if (keyName === 'jump') this.game.onJumpPressed();
        if (keyName === 'attack') this.game.onAttackPressed();
      };

      const endAction = (e) => {
        e.preventDefault();
        this.touchState[keyName] = false;
        btn.classList.remove('active');
      };

      btn.addEventListener('touchstart', startAction, { passive: false });
      btn.addEventListener('touchend', endAction, { passive: false });
      btn.addEventListener('touchcancel', endAction, { passive: false });
      btn.addEventListener('mousedown', startAction);
      btn.addEventListener('mouseup', endAction);
      btn.addEventListener('mouseleave', endAction);
    };

    bindTouch('btnTouchLeft', 'left');
    bindTouch('btnTouchRight', 'right');
    bindTouch('btnTouchJump', 'jump');
    bindTouch('btnTouchAttack', 'attack');
  }

  handleKeyPress(code) {
    if (CONFIG.KEYS.PAUSE.includes(code)) {
      if (this.game.state === 'PLAYING') {
        this.game.setState('PAUSED');
      } else if (this.game.state === 'PAUSED') {
        this.game.setState('PLAYING');
      }
    }

    if (this.game.state === 'PLAYING') {
      if (CONFIG.KEYS.JUMP.includes(code)) {
        this.game.onJumpPressed();
      }
      if (CONFIG.KEYS.ATTACK.includes(code)) {
        this.game.onAttackPressed();
      }
    }
  }

  isLeft() {
    return this.touchState.left || CONFIG.KEYS.LEFT.some(k => this.keys[k]);
  }

  isRight() {
    return this.touchState.right || CONFIG.KEYS.RIGHT.some(k => this.keys[k]);
  }
}

// ==========================================================================
// 5. CAMERA SYSTEM
// ==========================================================================
class Camera {
  constructor(viewportWidth, viewportHeight) {
    this.x = 0;
    this.y = 0;
    this.viewportWidth = viewportWidth;
    this.viewportHeight = viewportHeight;
    this.targetX = 0;
    this.targetY = 0;
    this.lerpSpeed = 0.08;
  }

  resize(w, h) {
    this.viewportWidth = w;
    this.viewportHeight = h;
  }

  update(target, worldWidth, worldHeight) {
    // Focus camera ahead of player facing direction
    const offset = target.facingRight ? 120 : -120;
    this.targetX = target.x + target.width / 2 - this.viewportWidth / 2 + offset;
    this.targetY = target.y + target.height / 2 - this.viewportHeight / 2 - 20;

    // Smooth Lerp
    this.x += (this.targetX - this.x) * this.lerpSpeed;
    this.y += (this.targetY - this.y) * this.lerpSpeed;

    // World Clamp
    this.x = Math.max(0, Math.min(worldWidth - this.viewportWidth, this.x));
    this.y = Math.max(0, Math.min(worldHeight - this.viewportHeight, this.y));
  }
}

// ==========================================================================
// 6. PARTICLES SYSTEM
// ==========================================================================
class ParticleSystem {
  constructor() {
    this.particles = [];
  }

  spawnGlowParticles(bounds, count = 20) {
    for (let i = 0; i < count; i++) {
      this.particles.push({
        type: 'ambient',
        x: bounds.x + Math.random() * bounds.width,
        y: bounds.y + Math.random() * bounds.height,
        vx: (Math.random() - 0.5) * 15,
        vy: -10 - Math.random() * 20,
        radius: 1.5 + Math.random() * 2.5,
        alpha: 0.2 + Math.random() * 0.6,
        life: 3 + Math.random() * 4,
        maxLife: 7,
        color: Math.random() > 0.4 ? '#95D5B2' : '#E9C46A'
      });
    }
  }

  addHitSparks(x, y, count = 10, color = '#E9C46A') {
    for (let i = 0; i < count; i++) {
      const angle = Math.random() * Math.PI * 2;
      const speed = 80 + Math.random() * 180;
      this.particles.push({
        type: 'spark',
        x: x,
        y: y,
        vx: Math.cos(angle) * speed,
        vy: Math.sin(angle) * speed,
        radius: 2 + Math.random() * 2,
        alpha: 1.0,
        life: 0,
        maxLife: 0.3 + Math.random() * 0.2,
        color: color
      });
    }
  }

  update(dt) {
    for (let i = this.particles.length - 1; i >= 0; i--) {
      const p = this.particles[i];
      p.life += dt;
      p.x += p.vx * dt;
      p.y += p.vy * dt;

      if (p.type === 'ambient') {
        p.alpha = Math.sin((p.life / p.maxLife) * Math.PI) * 0.7;
      } else if (p.type === 'spark') {
        p.alpha = 1 - (p.life / p.maxLife);
        p.vy += 300 * dt; // gravity
      }

      if (p.life >= p.maxLife) {
        this.particles.splice(i, 1);
      }
    }
  }

  draw(ctx, camera) {
    ctx.save();
    for (const p of this.particles) {
      const px = p.x - camera.x;
      const py = p.y - camera.y;

      ctx.beginPath();
      ctx.arc(px, py, p.radius, 0, Math.PI * 2);
      ctx.fillStyle = p.color;
      ctx.globalAlpha = Math.max(0, p.alpha);
      ctx.shadowColor = p.color;
      ctx.shadowBlur = 8;
      ctx.fill();
    }
    ctx.restore();
  }
}

// ==========================================================================
// 7. ENTITIES (Player, Enemies, Collectibles, Checkpoint, Boss)
// ==========================================================================

class Player {
  constructor(x, y) {
    this.x = x;
    this.y = y;
    this.width = CONFIG.PLAYER.WIDTH;
    this.height = CONFIG.PLAYER.HEIGHT;

    this.vx = 0;
    this.vy = 0;
    this.isGrounded = false;
    this.facingRight = true;

    this.health = CONFIG.PLAYER.MAX_HEALTH;
    this.invulnTimer = 0;
    this.jumpsLeft = 2;

    this.isAttacking = false;
    this.attackTimer = 0;

    this.animTimer = 0;
    this.state = 'idle'; // idle, walk, jump, fall, attack
  }

  reset(x, y) {
    this.x = x;
    this.y = y;
    this.vx = 0;
    this.vy = 0;
    this.health = CONFIG.PLAYER.MAX_HEALTH;
    this.invulnTimer = 0;
    this.isAttacking = false;
    this.jumpsLeft = 2;
  }

  update(dt, input, platforms) {
    this.animTimer += dt;
    if (this.invulnTimer > 0) this.invulnTimer -= dt;

    // Movement Logic
    if (input.isLeft()) {
      this.vx = -CONFIG.PLAYER.MOVE_SPEED;
      this.facingRight = false;
    } else if (input.isRight()) {
      this.vx = CONFIG.PLAYER.MOVE_SPEED;
      this.facingRight = true;
    } else {
      this.vx = 0;
    }

    // Gravity
    this.vy += CONFIG.GRAVITY * dt;

    // Attack timer
    if (this.isAttacking) {
      this.attackTimer -= dt;
      if (this.attackTimer <= 0) {
        this.isAttacking = false;
      }
    }

    // Horizontal Movement & Collision
    this.x += this.vx * dt;
    this.handleHorizontalCollisions(platforms);

    // Vertical Movement & Collision
    this.y += this.vy * dt;
    this.isGrounded = false;
    this.handleVerticalCollisions(platforms);

    // Update Animation State
    if (this.isAttacking) {
      this.state = 'attack';
    } else if (!this.isGrounded) {
      this.state = this.vy < 0 ? 'jump' : 'fall';
    } else if (Math.abs(this.vx) > 10) {
      this.state = 'walk';
    } else {
      this.state = 'idle';
    }

    // Reset jumps on ground
    if (this.isGrounded) {
      this.jumpsLeft = 2;
    }
  }

  jump() {
    if (this.jumpsLeft > 0) {
      this.vy = CONFIG.PLAYER.JUMP_FORCE;
      this.jumpsLeft--;
      this.isGrounded = false;
      return true;
    }
    return false;
  }

  attack() {
    if (!this.isAttacking) {
      this.isAttacking = true;
      this.attackTimer = CONFIG.PLAYER.ATTACK_DURATION;
      return true;
    }
    return false;
  }

  takeDamage(amount, knockbackDirection = 0) {
    if (this.invulnTimer > 0) return false;
    this.health = Math.max(0, this.health - amount);
    this.invulnTimer = CONFIG.PLAYER.INVULN_DURATION;
    this.vy = -300;
    this.vx = knockbackDirection * 250;
    return true;
  }

  getAttackBox() {
    const range = CONFIG.PLAYER.ATTACK_RANGE;
    return {
      x: this.facingRight ? this.x + this.width : this.x - range,
      y: this.y + 10,
      width: range,
      height: this.height - 10
    };
  }

  handleHorizontalCollisions(platforms) {
    for (const p of platforms) {
      if (p.isPassThrough) continue;
      if (this.checkAABB(this, p)) {
        if (this.vx > 0) {
          this.x = p.x - this.width;
        } else if (this.vx < 0) {
          this.x = p.x + p.width;
        }
      }
    }
  }

  handleVerticalCollisions(platforms) {
    for (const p of platforms) {
      if (this.checkAABB(this, p)) {
        if (this.vy > 0 && (this.y + this.height - this.vy * 0.08) <= p.y + 16) {
          this.y = p.y - this.height;
          this.vy = 0;
          this.isGrounded = true;
        } else if (this.vy < 0 && !p.isPassThrough) {
          this.y = p.y + p.height;
          this.vy = 0;
        }
      }
    }
  }

  checkAABB(rect1, rect2) {
    return (
      rect1.x < rect2.x + rect2.width &&
      rect1.x + rect1.width > rect2.x &&
      rect1.y < rect2.y + rect2.height &&
      rect1.y + rect1.height > rect2.y
    );
  }

  draw(ctx, camera) {
    const px = this.x - camera.x;
    const py = this.y - camera.y;

    ctx.save();

    // Damage Invulnerability Flashing
    if (this.invulnTimer > 0 && Math.floor(this.animTimer * 20) % 2 === 0) {
      ctx.globalAlpha = 0.4;
    }

    // Direction Flipping
    ctx.translate(px + this.width / 2, py + this.height / 2);
    if (!this.facingRight) ctx.scale(-1, 1);

    // Character Procedural Art (Cute Fantasy Explorer Cape & Mask)
    const w = this.width;
    const h = this.height;

    // Cape
    ctx.fillStyle = '#215A6D';
    ctx.beginPath();
    ctx.moveTo(-w/4, -h/4);
    const capeSwing = Math.sin(this.animTimer * 12) * (this.state === 'walk' ? 12 : 3);
    ctx.quadraticCurveTo(-w/2 - capeSwing, 0, -w/3 - capeSwing, h/2);
    ctx.lineTo(0, h/3);
    ctx.closePath();
    ctx.fill();

    // Body / Tunic
    ctx.fillStyle = '#52B788';
    ctx.fillRect(-w/3, -h/4, (w*2)/3, (h*2)/3);

    // Belt
    ctx.fillStyle = '#E9C46A';
    ctx.fillRect(-w/3, h/8, (w*2)/3, 5);

    // Legs / Boots
    ctx.fillStyle = '#102B3F';
    const legOffset = this.state === 'walk' ? Math.sin(this.animTimer * 14) * 8 : 0;
    ctx.fillRect(-w/4, h/4, 7, h/4 + legOffset);
    ctx.fillRect(w/12, h/4, 7, h/4 - legOffset);

    // Head / Explorer Mask
    ctx.fillStyle = '#EDF2F4';
    ctx.beginPath();
    ctx.arc(0, -h/3, 14, 0, Math.PI * 2);
    ctx.fill();

    // Mask Beak / Horn
    ctx.fillStyle = '#E9C46A';
    ctx.beginPath();
    ctx.moveTo(8, -h/3 - 2);
    ctx.lineTo(20, -h/3 + 2);
    ctx.lineTo(6, -h/3 + 6);
    ctx.closePath();
    ctx.fill();

    // Glowing Eyes
    ctx.fillStyle = '#34A0A4';
    ctx.shadowColor = '#34A0A4';
    ctx.shadowBlur = 6;
    ctx.fillRect(2, -h/3 - 3, 5, 5);

    // Sword & Attack Arc
    ctx.shadowBlur = 0;
    if (this.isAttacking) {
      // Attack Arc Burst
      ctx.strokeStyle = '#E9C46A';
      ctx.lineWidth = 4;
      ctx.shadowColor = '#E9C46A';
      ctx.shadowBlur = 12;

      ctx.beginPath();
      ctx.arc(10, 0, 42, -Math.PI / 3, Math.PI / 3);
      ctx.stroke();

      // Sword
      ctx.fillStyle = '#EDF2F4';
      ctx.fillRect(10, -5, 35, 6);
    } else {
      // Idle Sword Sheath
      ctx.fillStyle = '#8D99AE';
      ctx.fillRect(4, -2, 18, 4);
    }

    ctx.restore();
  }
}

class Enemy {
  constructor(x, y, type = 'slime', range = 180) {
    this.x = x;
    this.y = y;
    this.type = type;
    this.width = type === 'flying' ? 32 : 42;
    this.height = type === 'flying' ? 32 : 36;

    this.startX = x;
    this.range = range;
    this.speed = type === 'flying' ? 90 : 70;
    this.direction = 1;

    this.health = type === 'flying' ? 1 : 2;
    this.maxHealth = this.health;

    this.animTimer = Math.random() * 10;
    this.isAlive = true;
  }

  update(dt) {
    if (!this.isAlive) return;
    this.animTimer += dt;

    if (this.type === 'slime') {
      this.x += this.speed * this.direction * dt;
      if (Math.abs(this.x - this.startX) > this.range) {
        this.direction *= -1;
      }
    } else if (this.type === 'flying') {
      this.x += this.speed * this.direction * dt;
      this.y += Math.sin(this.animTimer * 4) * 40 * dt;
      if (Math.abs(this.x - this.startX) > this.range) {
        this.direction *= -1;
      }
    }
  }

  takeDamage(amount) {
    this.health -= amount;
    if (this.health <= 0) {
      this.isAlive = false;
    }
  }

  draw(ctx, camera) {
    if (!this.isAlive) return;
    const px = this.x - camera.x;
    const py = this.y - camera.y;

    ctx.save();
    if (this.type === 'slime') {
      // Shadow Blob Enemy
      const stretch = Math.sin(this.animTimer * 8) * 4;
      ctx.fillStyle = '#9B1C1C';
      ctx.beginPath();
      ctx.ellipse(px + this.width/2, py + this.height - 12 + stretch/2, this.width/2, this.height/2 - stretch, 0, 0, Math.PI * 2);
      ctx.fill();

      // Glowing Red Eye
      ctx.fillStyle = '#FF4D4D';
      ctx.shadowColor = '#FF4D4D';
      ctx.shadowBlur = 8;
      ctx.beginPath();
      ctx.arc(px + this.width/2 + (this.direction * 6), py + 14, 5, 0, Math.PI * 2);
      ctx.fill();

    } else if (this.type === 'flying') {
      // Dark Wisp
      ctx.fillStyle = '#215A6D';
      ctx.shadowColor = '#34A0A4';
      ctx.shadowBlur = 10;
      ctx.beginPath();
      ctx.arc(px + this.width/2, py + this.height/2, 14 + Math.sin(this.animTimer * 10) * 2, 0, Math.PI * 2);
      ctx.fill();

      // Wings
      ctx.fillStyle = 'rgba(149, 213, 178, 0.6)';
      ctx.beginPath();
      ctx.ellipse(px + 4, py + 8, 12, 5, Math.sin(this.animTimer * 15) * 0.5, 0, Math.PI * 2);
      ctx.ellipse(px + this.width - 4, py + 8, 12, 5, -Math.sin(this.animTimer * 15) * 0.5, 0, Math.PI * 2);
      ctx.fill();
    }
    ctx.restore();
  }
}

class BossGuardian {
  constructor(x, y) {
    this.x = x;
    this.y = y;
    this.width = 90;
    this.height = 120;

    this.maxHealth = 10;
    this.health = this.maxHealth;
    this.isAlive = true;
    this.active = false;

    this.animTimer = 0;
    this.attackTimer = 0;
    this.state = 'idle'; // idle, charging, slam
    this.vx = 0;
  }

  update(dt, player, particleSystem) {
    if (!this.isAlive) return;
    this.animTimer += dt;

    // Wake up when player approaches boss zone
    if (!this.active && Math.abs(player.x - this.x) < 500) {
      this.active = true;
    }

    if (!this.active) return;

    this.attackTimer += dt;
    if (this.attackTimer > 3.0) {
      this.attackTimer = 0;
      // Boss Charge / Slam Attack
      const dir = player.x < this.x ? -1 : 1;
      this.vx = dir * 260;
      particleSystem.addHitSparks(this.x + this.width/2, this.y + this.height, 15, '#E63946');
    }

    this.x += this.vx * dt;
    this.vx *= 0.92; // Friction

    // Clamp boss inside arena
    this.x = Math.max(4200, Math.min(5050, this.x));
  }

  takeDamage(amount) {
    if (!this.active || !this.isAlive) return;
    this.health -= amount;
    if (this.health <= 0) {
      this.health = 0;
      this.isAlive = false;
    }
  }

  draw(ctx, camera) {
    if (!this.isAlive) return;
    const px = this.x - camera.x;
    const py = this.y - camera.y;

    ctx.save();

    // Giant Ancient Guardian Silhouette
    ctx.fillStyle = '#081420';
    ctx.strokeStyle = '#52B788';
    ctx.lineWidth = 3;
    ctx.shadowColor = '#52B788';
    ctx.shadowBlur = 15;

    // Body Frame
    ctx.beginPath();
    ctx.moveTo(px + 20, py + this.height);
    ctx.lineTo(px + 10, py + 40);
    ctx.lineTo(px + this.width / 2, py);
    ctx.lineTo(px + this.width - 10, py + 40);
    ctx.lineTo(px + this.width - 20, py + this.height);
    ctx.closePath();
    ctx.fill();
    ctx.stroke();

    // Horns / Crown
    ctx.fillStyle = '#E9C46A';
    ctx.beginPath();
    ctx.moveTo(px + 15, py + 30);
    ctx.lineTo(px - 10, py - 20);
    ctx.lineTo(px + 30, py + 10);
    ctx.moveTo(px + this.width - 15, py + 30);
    ctx.lineTo(px + this.width + 10, py - 20);
    ctx.lineTo(px + this.width - 30, py + 10);
    ctx.fill();

    // Core Gem
    ctx.fillStyle = '#E63946';
    ctx.shadowColor = '#E63946';
    ctx.shadowBlur = 20;
    ctx.beginPath();
    ctx.arc(px + this.width/2, py + 50, 14 + Math.sin(this.animTimer * 6) * 3, 0, Math.PI * 2);
    ctx.fill();

    ctx.restore();
  }
}

class Collectible {
  constructor(x, y, type = 'rune') {
    this.x = x;
    this.y = y;
    this.width = 24;
    this.height = 24;
    this.type = type;
    this.collected = false;
    this.animTimer = Math.random() * 5;
  }

  update(dt) {
    this.animTimer += dt;
  }

  draw(ctx, camera) {
    if (this.collected) return;
    const px = this.x - camera.x;
    const py = this.y - camera.y + Math.sin(this.animTimer * 5) * 6;

    ctx.save();
    ctx.fillStyle = '#E9C46A';
    ctx.shadowColor = '#E9C46A';
    ctx.shadowBlur = 12;

    ctx.beginPath();
    ctx.moveTo(px + 12, py);
    ctx.lineTo(px + 22, py + 12);
    ctx.lineTo(px + 12, py + 24);
    ctx.lineTo(px + 2, py + 12);
    ctx.closePath();
    ctx.fill();

    ctx.fillStyle = '#FFFFFF';
    ctx.fillRect(px + 10, py + 8, 4, 8);

    ctx.restore();
  }
}

class Checkpoint {
  constructor(x, y) {
    this.x = x;
    this.y = y;
    this.width = 40;
    this.height = 70;
    this.active = false;
  }

  draw(ctx, camera) {
    const px = this.x - camera.x;
    const py = this.y - camera.y;

    ctx.save();
    // Ancient Rune Obelisk
    ctx.fillStyle = '#102B3F';
    ctx.strokeStyle = this.active ? '#95D5B2' : '#215A6D';
    ctx.lineWidth = 3;

    ctx.beginPath();
    ctx.moveTo(px + 10, py + this.height);
    ctx.lineTo(px + 5, py + 20);
    ctx.lineTo(px + 20, py);
    ctx.lineTo(px + 35, py + 20);
    ctx.lineTo(px + 30, py + this.height);
    ctx.closePath();
    ctx.fill();
    ctx.stroke();

    // Active Glow Crystal
    ctx.fillStyle = this.active ? '#52B788' : '#34A0A4';
    ctx.shadowColor = this.active ? '#52B788' : 'transparent';
    ctx.shadowBlur = this.active ? 18 : 0;
    ctx.beginPath();
    ctx.arc(px + 20, py + 30, 8, 0, Math.PI * 2);
    ctx.fill();

    ctx.restore();
  }
}

class VictoryPortal {
  constructor(x, y) {
    this.x = x;
    this.y = y;
    this.width = 60;
    this.height = 90;
    this.animTimer = 0;
  }

  update(dt) {
    this.animTimer += dt;
  }

  draw(ctx, camera) {
    const px = this.x - camera.x;
    const py = this.y - camera.y;

    ctx.save();
    ctx.fillStyle = 'rgba(82, 183, 136, 0.2)';
    ctx.strokeStyle = '#E9C46A';
    ctx.lineWidth = 4;
    ctx.shadowColor = '#E9C46A';
    ctx.shadowBlur = 25;

    ctx.beginPath();
    ctx.ellipse(px + this.width/2, py + this.height/2, this.width/2, this.height/2, 0, 0, Math.PI * 2);
    ctx.fill();
    ctx.stroke();

    // Swirling Portal Core
    ctx.fillStyle = '#95D5B2';
    ctx.beginPath();
    ctx.ellipse(px + this.width/2, py + this.height/2, Math.sin(this.animTimer * 4) * 12 + 15, Math.cos(this.animTimer * 4) * 20 + 25, 0, 0, Math.PI * 2);
    ctx.fill();

    ctx.restore();
  }
}

// ==========================================================================
// 8. PARALLAX BACKGROUND & ENVIRONMENT RENDERER
// ==========================================================================
class EnvironmentRenderer {
  constructor() {
    this.lightShafts = [
      { x: 300, width: 140 },
      { x: 1200, width: 180 },
      { x: 2200, width: 160 },
      { x: 3400, width: 200 },
      { x: 4400, width: 150 }
    ];
  }

  draw(ctx, camera, width, height, graphicsQuality) {
    // 1. Sky & Gradient Fog
    const skyGradient = ctx.createLinearGradient(0, 0, 0, height);
    skyGradient.addColorStop(0, '#030811');
    skyGradient.addColorStop(0.4, '#081a28');
    skyGradient.addColorStop(1, '#0e2e38');
    ctx.fillStyle = skyGradient;
    ctx.fillRect(0, 0, width, height);

    // 2. Far Distant Mountain Silhouettes (Parallax factor 0.1)
    ctx.save();
    ctx.fillStyle = '#0a1d2c';
    ctx.beginPath();
    ctx.moveTo(0, height);
    for (let x = 0; x <= width + 100; x += 100) {
      const worldX = x + camera.x * 0.1;
      const mountainY = height - 280 - Math.sin(worldX * 0.002) * 120 - Math.cos(worldX * 0.005) * 60;
      ctx.lineTo(x, mountainY);
    }
    ctx.lineTo(width, height);
    ctx.closePath();
    ctx.fill();
    ctx.restore();

    // 3. Distant Ancient Forest Trees (Parallax factor 0.25)
    ctx.save();
    ctx.fillStyle = '#102B3F';
    for (let i = 0; i < 15; i++) {
      const treeWorldX = i * 400 + 50;
      const treeScreenX = treeWorldX - camera.x * 0.25;
      if (treeScreenX > -200 && treeScreenX < width + 200) {
        // Tree Trunk
        ctx.fillRect(treeScreenX, height - 520, 60, 520);
        // Canopy
        ctx.beginPath();
        ctx.arc(treeScreenX + 30, height - 520, 110, 0, Math.PI * 2);
        ctx.fill();
      }
    }
    ctx.restore();

    // 4. Atmospheric Light Shafts
    ctx.save();
    for (const shaft of this.lightShafts) {
      const sx = shaft.x - camera.x * 0.5;
      if (sx > -200 && sx < width + 200) {
        const rayGrad = ctx.createLinearGradient(sx, 0, sx + shaft.width * 0.5, height);
        rayGrad.addColorStop(0, 'rgba(149, 213, 178, 0.15)');
        rayGrad.addColorStop(1, 'rgba(149, 213, 178, 0.0)');
        ctx.fillStyle = rayGrad;

        ctx.beginPath();
        ctx.moveTo(sx, 0);
        ctx.lineTo(sx + shaft.width, 0);
        ctx.lineTo(sx + shaft.width + 120, height);
        ctx.lineTo(sx + 60, height);
        ctx.closePath();
        ctx.fill();
      }
    }
    ctx.restore();

    // 5. Midground Giant Trees & Hanging Vines (Parallax factor 0.6)
    if (graphicsQuality !== 'low') {
      ctx.save();
      ctx.fillStyle = '#081726';
      for (let i = 0; i < 10; i++) {
        const tx = i * 600 + 120 - camera.x * 0.6;
        if (tx > -200 && tx < width + 200) {
          // Gnarled Tree Trunk
          ctx.beginPath();
          ctx.moveTo(tx, height);
          ctx.quadraticCurveTo(tx + 40, height - 300, tx - 20, 0);
          ctx.lineTo(tx + 70, 0);
          ctx.quadraticCurveTo(tx + 110, height - 250, tx + 130, height);
          ctx.closePath();
          ctx.fill();

          // Hanging Vines
          ctx.strokeStyle = '#215A6D';
          ctx.lineWidth = 3;
          ctx.beginPath();
          ctx.moveTo(tx + 20, 0);
          ctx.quadraticCurveTo(tx + 40, 150, tx + 10, 300);
          ctx.moveTo(tx + 80, 0);
          ctx.quadraticCurveTo(tx + 60, 180, tx + 90, 340);
          ctx.stroke();
        }
      }
      ctx.restore();
    }
  }

  drawPlatformsAndGround(ctx, camera, platforms, worldWidth, groundY) {
    ctx.save();

    // Ground Platform Visuals are rendered from the platforms array for complete consistency
    for (const p of platforms) {
      const px = p.x - camera.x;
      const py = p.y - camera.y;

      if (px + p.width > -100 && px < ctx.canvas.width + 100) {
        // Platform Body
        ctx.fillStyle = '#0d2233';
        ctx.fillRect(px, py, p.width, p.height);

        // Moss Cap
        ctx.fillStyle = '#52B788';
        ctx.fillRect(px, py, p.width, 8);

        // Grass Tufts along platform top
        ctx.fillStyle = '#95D5B2';
        for (let rx = 10; rx < p.width - 10; rx += 35) {
          ctx.beginPath();
          ctx.moveTo(px + rx, py);
          ctx.lineTo(px + rx + 5, py - 8);
          ctx.lineTo(px + rx + 10, py);
          ctx.fill();
        }

        // Hanging Roots underneath
        if (p.height > 30) {
          ctx.fillStyle = '#215A6D';
          for (let rx = 20; rx < p.width - 20; rx += 50) {
            ctx.beginPath();
            ctx.moveTo(px + rx, py + 30);
            ctx.lineTo(px + rx + 5, py + 50);
            ctx.lineTo(px + rx + 10, py + 30);
            ctx.fill();
          }
        }
      }
    }

    ctx.restore();
  }

  drawForeground(ctx, camera, width, height) {
    // Foreground Vines Overlay (Parallax factor 1.2 for cinematic depth)
    ctx.save();
    ctx.fillStyle = '#030811';
    for (let i = 0; i < 6; i++) {
      const fx = i * 900 - camera.x * 1.2;
      if (fx > -300 && fx < width + 300) {
        ctx.beginPath();
        ctx.moveTo(fx, 0);
        ctx.quadraticCurveTo(fx + 60, height * 0.4, fx - 40, height * 0.8);
        ctx.lineTo(fx - 90, height * 0.8);
        ctx.quadraticCurveTo(fx, height * 0.3, fx - 40, 0);
        ctx.closePath();
        ctx.fill();
      }
    }
    ctx.restore();
  }
}

// ==========================================================================
// 9. LEVEL CREATOR
// ==========================================================================
class LevelManager {
  static createLevel() {
    const gy = CONFIG.WORLD.GROUND_Y;

    const platforms = [
      // Main Playable Ground Sections (with gaps for platforming)
      { x: 0, y: gy, width: 1200, height: 400 },
      { x: 1350, y: gy, width: 1000, height: 400 },
      { x: 2500, y: gy, width: 1500, height: 400 },
      { x: 4150, y: gy, width: 1050, height: 400 },

      // Floating Platforms & Vertical Canopy Section
      { x: 300, y: gy - 120, width: 200, height: 24 },
      { x: 600, y: gy - 220, width: 180, height: 24 },
      { x: 900, y: gy - 140, width: 220, height: 24 },

      // Gap Crossing & Secret High Platform
      { x: 1210, y: gy - 100, width: 120, height: 24 }, // Gap bridge
      { x: 1550, y: gy - 260, width: 160, height: 24 },
      { x: 1800, y: gy - 380, width: 200, height: 24 },
      { x: 1850, y: gy - 520, width: 180, height: 24 }, // Secret area
      { x: 2100, y: gy - 240, width: 200, height: 24 },

      // Mid-Level Canopy
      { x: 2750, y: gy - 220, width: 220, height: 24 },
      { x: 3100, y: gy - 160, width: 240, height: 24 },

      // Pre-Boss Elevated Arena Staircase
      { x: 3500, y: gy - 180, width: 180, height: 24 },
      { x: 3800, y: gy - 280, width: 200, height: 24 }
    ];

    const enemies = [
      new Enemy(500, gy - 36, 'slime', 120),
      new Enemy(950, gy - 140 - 36, 'slime', 80),
      new Enemy(1450, gy - 320, 'flying', 160),
      new Enemy(2150, gy - 240 - 36, 'slime', 80),
      new Enemy(2850, gy - 36, 'slime', 120),
      new Enemy(3200, gy - 280, 'flying', 180),
      new Enemy(3600, gy - 36, 'slime', 140)
    ];

    const collectibles = [
      new Collectible(350, gy - 160),
      new Collectible(680, gy - 260),
      new Collectible(980, gy - 180),
      new Collectible(1250, gy - 140),
      new Collectible(1600, gy - 300),
      new Collectible(1850, gy - 420),
      new Collectible(1900, gy - 560), // Secret area rune
      new Collectible(1940, gy - 560), // Secret area rune
      new Collectible(2180, gy - 280),
      new Collectible(2500, gy - 180),
      new Collectible(2800, gy - 260),
      new Collectible(3150, gy - 200),
      new Collectible(3550, gy - 220),
      new Collectible(3850, gy - 320),
      new Collectible(4250, gy - 180)
    ];

    const checkpoint = new Checkpoint(2400, gy - 70);
    const boss = new BossGuardian(4650, gy - 120);
    const portal = new VictoryPortal(5050, gy - 90);

    return { platforms, enemies, collectibles, checkpoint, boss, portal };
  }
}

// ==========================================================================
// 10. MAIN GAME ENGINE & STATE MACHINE
// ==========================================================================
class GameEngine {
  constructor() {
    this.canvas = document.getElementById('gameCanvas');
    this.ctx = this.canvas.getContext('2d');

    this.audio = new AudioEngine();
    this.saveData = SaveSystem.load();

    this.input = new InputHandler(this);
    this.camera = new Camera(CONFIG.CANVAS_WIDTH, CONFIG.CANVAS_HEIGHT);
    this.particles = new ParticleSystem();
    this.environment = new EnvironmentRenderer();

    this.state = 'MENU'; // MENU, PLAYING, PAUSED, GAME_OVER, VICTORY
    this.score = 0;
    this.collectedCoins = 0;
    this.totalRunesInLevel = 15;

    this.player = new Player(100, CONFIG.WORLD.GROUND_Y - CONFIG.PLAYER.HEIGHT);
    this.level = LevelManager.createLevel();

    this.lastTime = 0;
    this.toastTimer = null;

    this.initCanvasSize();
    this.bindUI();
    this.syncSettingsUI();

    window.addEventListener('resize', () => this.initCanvasSize());
    requestAnimationFrame((ts) => this.loop(ts));
  }

  initCanvasSize() {
    this.canvas.width = CONFIG.CANVAS_WIDTH;
    this.canvas.height = CONFIG.CANVAS_HEIGHT;
    this.camera.resize(CONFIG.CANVAS_WIDTH, CONFIG.CANVAS_HEIGHT);
  }

  setState(newState) {
    this.state = newState;
    this.updateScreenVisibility();

    if (newState === 'PLAYING') {
      this.audio.startAmbientBgm();
    } else if (newState === 'MENU' || newState === 'GAME_OVER' || newState === 'VICTORY') {
      this.audio.stopAmbientBgm();
    }
  }

  updateScreenVisibility() {
    document.querySelectorAll('.ui-screen').forEach(s => s.classList.add('hidden'));
    document.getElementById('hudOverlay').classList.add('hidden');

    switch (this.state) {
      case 'MENU':
        document.getElementById('menuScreen').classList.remove('hidden');
        document.getElementById('menuHighScore').textContent = this.saveData.highScore;
        document.getElementById('menuTotalRunes').textContent = this.saveData.totalCoins;
        document.getElementById('btnContinue').disabled = !this.saveData.hasSavedCheckpoint;
        break;

      case 'PLAYING':
        document.getElementById('hudOverlay').classList.remove('hidden');
        this.updateHUD();
        break;

      case 'PAUSED':
        document.getElementById('hudOverlay').classList.remove('hidden');
        document.getElementById('pauseScreen').classList.remove('hidden');
        break;

      case 'SETTINGS':
        document.getElementById('settingsScreen').classList.remove('hidden');
        break;

      case 'HOW_TO_PLAY':
        document.getElementById('howToPlayScreen').classList.remove('hidden');
        break;

      case 'ABOUT':
        document.getElementById('aboutScreen').classList.remove('hidden');
        break;

      case 'GAME_OVER':
        document.getElementById('gameOverScreen').classList.remove('hidden');
        document.getElementById('goScore').textContent = this.score;
        document.getElementById('goCoins').textContent = this.collectedCoins;
        break;

      case 'VICTORY':
        document.getElementById('victoryScreen').classList.remove('hidden');
        document.getElementById('vicScore').textContent = this.score;
        document.getElementById('vicCoins').textContent = `${this.collectedCoins} / ${this.totalRunesInLevel}`;
        break;
    }
  }

  bindUI() {
    // Menu Buttons
    document.getElementById('btnPlay').onclick = () => {
      this.startNewGame();
    };
    document.getElementById('btnContinue').onclick = () => {
      if (this.saveData.hasSavedCheckpoint) {
        this.continueFromCheckpoint();
      }
    };
    document.getElementById('btnSettings').onclick = () => this.setState('SETTINGS');
    document.getElementById('btnHowToPlay').onclick = () => this.setState('HOW_TO_PLAY');
    document.getElementById('btnAbout').onclick = () => this.setState('ABOUT');

    // Navigation Back Buttons
    document.getElementById('btnSettingsBack').onclick = () => {
      this.setState(this.previousState === 'PAUSED' ? 'PAUSED' : 'MENU');
    };
    document.getElementById('btnHowToPlayBack').onclick = () => this.setState('MENU');
    document.getElementById('btnAboutBack').onclick = () => this.setState('MENU');

    // Pause Screen Buttons
    document.getElementById('btnPause').onclick = () => this.setState('PAUSED');
    document.getElementById('btnResume').onclick = () => this.setState('PLAYING');
    document.getElementById('btnRestartCheckpoint').onclick = () => {
      this.continueFromCheckpoint();
      this.setState('PLAYING');
    };
    document.getElementById('btnPauseSettings').onclick = () => {
      this.previousState = 'PAUSED';
      this.setState('SETTINGS');
    };
    document.getElementById('btnPauseMainMenu').onclick = () => this.setState('MENU');

    // Game Over & Victory Buttons
    document.getElementById('btnGoRetry').onclick = () => {
      this.continueFromCheckpoint();
      this.setState('PLAYING');
    };
    document.getElementById('btnGoRestart').onclick = () => this.startNewGame();
    document.getElementById('btnGoMenu').onclick = () => this.setState('MENU');

    document.getElementById('btnVicPlayAgain').onclick = () => this.startNewGame();
    document.getElementById('btnVicMenu').onclick = () => this.setState('MENU');

    // Settings Controls
    const sliderMusic = document.getElementById('sliderMusic');
    const sliderSfx = document.getElementById('sliderSfx');
    const selectGraphics = document.getElementById('selectGraphics');
    const toggleMobile = document.getElementById('toggleMobileControls');
    const btnFullscreen = document.getElementById('btnFullscreen');
    const btnReset = document.getElementById('btnResetProgress');

    sliderMusic.oninput = (e) => {
      const val = parseInt(e.target.value, 10);
      document.getElementById('valMusic').textContent = `${val}%`;
      this.audio.setMusicVolume(val / 100);
      this.saveData.musicVolume = val;
      SaveSystem.save(this.saveData);
    };

    sliderSfx.oninput = (e) => {
      const val = parseInt(e.target.value, 10);
      document.getElementById('valSfx').textContent = `${val}%`;
      this.audio.setSfxVolume(val / 100);
      this.saveData.sfxVolume = val;
      SaveSystem.save(this.saveData);
    };

    selectGraphics.onchange = (e) => {
      this.saveData.graphicsQuality = e.target.value;
      SaveSystem.save(this.saveData);
    };

    toggleMobile.onchange = (e) => {
      this.saveData.mobileHudEnabled = e.target.checked;
      document.getElementById('mobileControls').style.display = e.target.checked ? 'flex' : 'none';
      SaveSystem.save(this.saveData);
    };

    btnFullscreen.onclick = () => {
      if (!document.fullscreenElement) {
        document.documentElement.requestFullscreen().catch(() => {});
      } else {
        document.exitFullscreen().catch(() => {});
      }
    };

    btnReset.onclick = () => {
      if (confirm('Are you sure you want to reset high score and saved progress?')) {
        this.saveData = SaveSystem.getDefaultData();
        SaveSystem.save(this.saveData);
        this.syncSettingsUI();
        this.showToast('Progress Reset Successfully');
      }
    };
  }

  syncSettingsUI() {
    document.getElementById('sliderMusic').value = this.saveData.musicVolume;
    document.getElementById('valMusic').textContent = `${this.saveData.musicVolume}%`;
    this.audio.setMusicVolume(this.saveData.musicVolume / 100);

    document.getElementById('sliderSfx').value = this.saveData.sfxVolume;
    document.getElementById('valSfx').textContent = `${this.saveData.sfxVolume}%`;
    this.audio.setSfxVolume(this.saveData.sfxVolume / 100);

    document.getElementById('selectGraphics').value = this.saveData.graphicsQuality;
    document.getElementById('toggleMobileControls').checked = this.saveData.mobileHudEnabled;
    document.getElementById('mobileControls').style.display = this.saveData.mobileHudEnabled ? 'flex' : 'none';
  }

  showToast(msg) {
    const toast = document.getElementById('gameToast');
    toast.textContent = msg;
    toast.classList.remove('hidden');
    if (this.toastTimer) clearTimeout(this.toastTimer);
    this.toastTimer = setTimeout(() => toast.classList.add('hidden'), 2600);
  }

  startNewGame() {
    this.score = 0;
    this.collectedCoins = 0;
    this.level = LevelManager.createLevel();
    this.player.reset(100, CONFIG.WORLD.GROUND_Y - CONFIG.PLAYER.HEIGHT);
    this.saveData.hasSavedCheckpoint = false;
    this.setState('PLAYING');
    this.showToast('Entered The Ancient Grove');
  }

  continueFromCheckpoint() {
    this.level = LevelManager.createLevel();
    if (this.saveData.hasSavedCheckpoint) {
      this.player.reset(this.saveData.checkpointX, this.saveData.checkpointY);
      this.level.checkpoint.active = true;
    } else {
      this.player.reset(100, CONFIG.WORLD.GROUND_Y - CONFIG.PLAYER.HEIGHT);
    }
    this.setState('PLAYING');
    this.showToast('Restored From Checkpoint');
  }

  onJumpPressed() {
    if (this.player.jump()) {
      this.audio.playJump();
      this.particles.addHitSparks(this.player.x + this.player.width/2, this.player.y + this.player.height, 6, '#95D5B2');
    }
  }

  onAttackPressed() {
    if (this.player.attack()) {
      this.audio.playAttack();

      // Check melee hit against enemies
      const attackBox = this.player.getAttackBox();

      for (const enemy of this.level.enemies) {
        if (enemy.isAlive && this.checkAABB(attackBox, enemy)) {
          enemy.takeDamage(1);
          this.particles.addHitSparks(enemy.x + enemy.width/2, enemy.y + enemy.height/2, 12, '#FF4D4D');
          if (!enemy.isAlive) {
            this.score += 150;
            this.audio.playEnemyDefeat();
          }
        }
      }

      // Check hit against Boss
      if (this.level.boss.isAlive && this.level.boss.active && this.checkAABB(attackBox, this.level.boss)) {
        this.level.boss.takeDamage(1);
        this.score += 300;
        this.audio.playEnemyDefeat();
        this.particles.addHitSparks(this.level.boss.x + this.level.boss.width/2, this.level.boss.y + 50, 18, '#E63946');

        if (!this.level.boss.isAlive) {
          this.score += 2000;
          this.showToast('Ancient Guardian Defeated!');
        }
      }
    }
  }

  updateHUD() {
    // Health Hearts
    const container = document.getElementById('healthHearts');
    container.innerHTML = '';
    for (let i = 0; i < CONFIG.PLAYER.MAX_HEALTH; i++) {
      const heart = document.createElement('span');
      heart.className = `heart-icon ${i < this.player.health ? '' : 'hurt'}`;
      heart.textContent = '❤️';
      container.appendChild(heart);
    }

    // Score and Coins
    document.getElementById('hudScore').textContent = String(this.score).padStart(4, '0');
    document.getElementById('hudCoins').textContent = `${this.collectedCoins} / ${this.totalRunesInLevel}`;

    // Boss Health Bar UI
    const bossHpContainer = document.getElementById('bossHealthContainer');
    if (this.level.boss.active && this.level.boss.isAlive) {
      bossHpContainer.classList.remove('hidden');
      const pct = (this.level.boss.health / this.level.boss.maxHealth) * 100;
      document.getElementById('bossHpFill').style.width = `${pct}%`;
      document.getElementById('bossHpText').textContent = `${this.level.boss.health} / ${this.level.boss.maxHealth}`;
    } else {
      bossHpContainer.classList.add('hidden');
    }
  }

  checkAABB(r1, r2) {
    return (
      r1.x < r2.x + r2.width &&
      r1.x + r1.width > r2.x &&
      r1.y < r2.y + r2.height &&
      r1.y + r1.height > r2.y
    );
  }

  update(dt) {
    // Ambient Particle Spawning
    if (Math.random() < 0.3) {
      this.particles.spawnGlowParticles({
        x: this.camera.x,
        y: this.camera.y,
        width: CONFIG.CANVAS_WIDTH,
        height: CONFIG.CANVAS_HEIGHT
      }, 1);
    }
    this.particles.update(dt);

    if (this.state !== 'PLAYING') return;

    // Update Player & Camera
    this.player.update(dt, this.input, this.level.platforms);
    this.camera.update(this.player, CONFIG.WORLD.WIDTH, CONFIG.WORLD.HEIGHT);

    // Update Enemies & Collisions
    for (const enemy of this.level.enemies) {
      if (enemy.isAlive) {
        enemy.update(dt);
        if (this.checkAABB(this.player, enemy)) {
          const dir = this.player.x < enemy.x ? -1 : 1;
          if (this.player.takeDamage(1, dir)) {
            this.audio.playHurt();
            this.updateHUD();
          }
        }
      }
    }

    // Update Boss Guardian
    if (this.level.boss.isAlive) {
      this.level.boss.update(dt, this.player, this.particles);
      if (this.level.boss.active && this.checkAABB(this.player, this.level.boss)) {
        const dir = this.player.x < this.level.boss.x ? -1 : 1;
        if (this.player.takeDamage(1, dir)) {
          this.audio.playHurt();
          this.updateHUD();
        }
      }
    }

    // Update Collectibles
    for (const c of this.level.collectibles) {
      if (!c.collected) {
        c.update(dt);
        if (this.checkAABB(this.player, c)) {
          c.collected = true;
          this.collectedCoins++;
          this.score += 100;
          this.audio.playCollect();
          this.particles.addHitSparks(c.x + 12, c.y + 12, 10, '#E9C46A');
          this.updateHUD();
        }
      }
    }

    // Checkpoint Collision
    const cp = this.level.checkpoint;
    if (!cp.active && this.checkAABB(this.player, cp)) {
      cp.active = true;
      this.saveData.hasSavedCheckpoint = true;
      this.saveData.checkpointX = cp.x;
      this.saveData.checkpointY = cp.y - 10;
      SaveSystem.save(this.saveData);
      this.audio.playCheckpoint();
      this.showToast('Checkpoint Activated! Progress Saved.');
      this.particles.addHitSparks(cp.x + 20, cp.y + 30, 20, '#52B788');
    }

    // Victory Portal Collision
    if (this.checkAABB(this.player, this.level.portal)) {
      this.audio.playVictory();
      if (this.score > this.saveData.highScore) {
        this.saveData.highScore = this.score;
      }
      this.saveData.totalCoins += this.collectedCoins;
      SaveSystem.save(this.saveData);
      this.setState('VICTORY');
    }

    // Player Fall Death or Zero HP
    if (this.player.y > CONFIG.WORLD.HEIGHT + 100 || this.player.health <= 0) {
      this.setState('GAME_OVER');
    }
  }

  render() {
    this.ctx.clearRect(0, 0, this.canvas.width, this.canvas.height);

    // 1. Parallax Environment Background
    this.environment.draw(this.ctx, this.camera, this.canvas.width, this.canvas.height, this.saveData.graphicsQuality);

    // 2. Platforms & Ground
    this.environment.drawPlatformsAndGround(this.ctx, this.camera, this.level.platforms, CONFIG.WORLD.WIDTH, CONFIG.WORLD.GROUND_Y);

    // 3. Interactive Objects
    this.level.checkpoint.draw(this.ctx, this.camera);
    this.level.portal.draw(this.ctx, this.camera);
    for (const c of this.level.collectibles) c.draw(this.ctx, this.camera);

    // 4. Entities (Enemies, Boss, Player)
    for (const e of this.level.enemies) e.draw(this.ctx, this.camera);
    this.level.boss.draw(this.ctx, this.camera);
    this.player.draw(this.ctx, this.camera);

    // 5. Particles
    this.particles.draw(this.ctx, this.camera);

    // 6. Foreground Parallax Leaves/Vines
    if (this.saveData.graphicsQuality === 'high') {
      this.environment.drawForeground(this.ctx, this.camera, this.canvas.width, this.canvas.height);
    }
  }

  loop(timestamp) {
    if (!this.lastTime) this.lastTime = timestamp;
    const dt = Math.min(0.05, (timestamp - this.lastTime) / 1000); // Clamp dt to prevent tunneling
    this.lastTime = timestamp;

    this.update(dt);
    this.render();

    requestAnimationFrame((ts) => this.loop(ts));
  }
}

// ==========================================================================
// 11. BOOTSTRAP GAME ENGINE
// ==========================================================================
window.addEventListener('DOMContentLoaded', () => {
  window.game = new GameEngine();
});
