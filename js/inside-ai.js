/**
 * NV ZIP — Interactive Particle Network & "INSIDE AI" Immersive Mode
 * Renders dynamic ambient neural network canvas with floating nodes, connecting beam lines,
 * mouse field interactions, and controls the "INSIDE AI" HUD overlay mode.
 */

class InsideAiEngine {
  constructor() {
    this.canvas = document.getElementById('bg-canvas');
    this.ctx = this.canvas ? this.canvas.getContext('2d') : null;
    this.insideAiToggle = document.getElementById('inside-ai-toggle');
    this.exitHudBtn = document.getElementById('exit-inside-ai');
    this.hudOverlay = document.getElementById('inside-ai-hud');
    this.hudStreamLog = document.getElementById('hud-stream-log');

    this.particles = [];
    this.numParticles = 65;
    this.maxDistance = 140;
    this.mouse = { x: null, y: null, radius: 180 };
    this.isInsideAi = false;
    this.animationFrameId = null;

    this.init();
  }

  init() {
    if (!this.canvas || !this.ctx) return;

    this.resizeCanvas();
    window.addEventListener('resize', () => this.resizeCanvas());

    window.addEventListener('mousemove', (e) => {
      this.mouse.x = e.clientX;
      this.mouse.y = e.clientY;
    });

    window.addEventListener('mouseleave', () => {
      this.mouse.x = null;
      this.mouse.y = null;
    });

    this.createParticles();
    this.animate();

    // Toggle Inside AI Immersive Mode
    if (this.insideAiToggle) {
      this.insideAiToggle.addEventListener('click', () => this.enterInsideAi());
    }

    if (this.exitHudBtn) {
      this.exitHudBtn.addEventListener('click', () => this.exitInsideAi());
    }
  }

  resizeCanvas() {
    this.canvas.width = window.innerWidth;
    this.canvas.height = window.innerHeight;
  }

  createParticles() {
    this.particles = [];
    for (let i = 0; i < this.numParticles; i++) {
      this.particles.push({
        x: Math.random() * this.canvas.width,
        y: Math.random() * this.canvas.height,
        vx: (Math.random() - 0.5) * 0.8,
        vy: (Math.random() - 0.5) * 0.8,
        radius: Math.random() * 2.5 + 1,
        color: i % 3 === 0 ? '#38bdf8' : i % 3 === 1 ? '#a855f7' : '#6366f1'
      });
    }
  }

  animate() {
    this.ctx.clearRect(0, 0, this.canvas.width, this.canvas.height);

    for (let i = 0; i < this.particles.length; i++) {
      const p = this.particles[i];

      // Move particle
      p.x += p.vx * (this.isInsideAi ? 2.2 : 1);
      p.y += p.vy * (this.isInsideAi ? 2.2 : 1);

      // Bounce on edges
      if (p.x < 0 || p.x > this.canvas.width) p.vx *= -1;
      if (p.y < 0 || p.y > this.canvas.height) p.vy *= -1;

      // Mouse attraction
      if (this.mouse.x !== null && this.mouse.y !== null) {
        const dx = this.mouse.x - p.x;
        const dy = this.mouse.y - p.y;
        const dist = Math.sqrt(dx * dx + dy * dy);
        if (dist < this.mouse.radius) {
          const force = (this.mouse.radius - dist) / this.mouse.radius;
          p.x -= (dx / dist) * force * 1.5;
          p.y -= (dy / dist) * force * 1.5;
        }
      }

      // Draw particle node
      this.ctx.beginPath();
      this.ctx.arc(p.x, p.y, p.radius, 0, Math.PI * 2);
      this.ctx.fillStyle = p.color;
      this.ctx.fill();

      // Connect lines
      for (let j = i + 1; j < this.particles.length; j++) {
        const p2 = this.particles[j];
        const dx = p.x - p2.x;
        const dy = p.y - p2.y;
        const dist = Math.sqrt(dx * dx + dy * dy);

        const currentMaxDist = this.isInsideAi ? this.maxDistance * 1.6 : this.maxDistance;

        if (dist < currentMaxDist) {
          const alpha = (1 - dist / currentMaxDist) * (this.isInsideAi ? 0.6 : 0.25);
          this.ctx.beginPath();
          this.ctx.moveTo(p.x, p.y);
          this.ctx.lineTo(p2.x, p2.y);
          this.ctx.strokeStyle = this.isInsideAi ? `rgba(56, 189, 248, ${alpha})` : `rgba(99, 102, 241, ${alpha})`;
          this.ctx.lineWidth = this.isInsideAi ? 1.2 : 0.8;
          this.ctx.stroke();
        }
      }
    }

    this.animationFrameId = requestAnimationFrame(() => this.animate());
  }

  enterInsideAi() {
    this.isInsideAi = true;
    if (this.hudOverlay) {
      this.hudOverlay.classList.remove('hidden');
      this.hudOverlay.setAttribute('aria-hidden', 'false');
    }
    this.startHudStream();
  }

  exitInsideAi() {
    this.isInsideAi = false;
    if (this.hudOverlay) {
      this.hudOverlay.classList.add('hidden');
      this.hudOverlay.setAttribute('aria-hidden', 'true');
    }
    if (this.hudInterval) {
      clearInterval(this.hudInterval);
    }
  }

  startHudStream() {
    if (!this.hudStreamLog) return;
    this.hudStreamLog.innerHTML = '<div>[SYSTEM] INSIDE AI Neural Engine initialized...</div>';

    const sampleLogs = [
      '[TENSOR] Processing forward pass through Layer 48/96...',
      '[ATTENTION] Head 12 computed softmax query-key alignment score: 0.984',
      '[TOKEN] Decoded Subword ID 7834 ("Explain") -> Vector projection initialized',
      '[EMBEDDING] Normalizing dense output dimensions (4,096 floating points)',
      '[HARDWARE] GPU Tensor Core Utilization: 98.2% | VRAM: 38.4 GB',
      '[PREDICTION] Softmax probability distributions sampled (Temperature: 0.7)',
      '[KV-CACHE] Reusing key-value attention pairs for active session buffer'
    ];

    let idx = 0;
    if (this.hudInterval) clearInterval(this.hudInterval);

    this.hudInterval = setInterval(() => {
      const log = sampleLogs[idx % sampleLogs.length];
      const logEl = document.createElement('div');
      logEl.textContent = `[${new Date().toLocaleTimeString()}] ${log}`;
      this.hudStreamLog.appendChild(logEl);
      this.hudStreamLog.scrollTop = this.hudStreamLog.scrollHeight;
      idx++;
    }, 1200);
  }
}

document.addEventListener('DOMContentLoaded', () => {
  window.insideAiEngine = new InsideAiEngine();
});
