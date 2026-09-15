/**
 * NV ZIP — Interactive AI Journey ("From Words to Answer")
 * Coordinates the 7-stage step-by-step pipeline from prompt string to final answer streaming.
 */

class JourneyPipeline {
  constructor() {
    this.promptInput = document.getElementById('journey-input-text');
    this.runBtn = document.getElementById('journey-run-btn');
    this.presets = document.querySelectorAll('.preset-chip');
    this.tabs = document.querySelectorAll('.journey-tab');
    this.prevBtn = document.getElementById('journey-prev-btn');
    this.nextBtn = document.getElementById('journey-next-btn');
    this.playBtn = document.getElementById('journey-play-btn');

    this.currentStep = 1;
    this.maxStep = 7;
    this.isPlaying = false;
    this.playTimer = null;
    this.activePrompt = "Explain gravity";

    this.init();
  }

  init() {
    if (!this.promptInput || !this.runBtn) return;

    // Run journey on button click
    this.runBtn.addEventListener('click', () => {
      this.activePrompt = this.promptInput.value.trim() || "Explain gravity";
      this.renderCurrentStep();
    });

    // Preset prompt chips
    this.presets.forEach(chip => {
      chip.addEventListener('click', (e) => {
        const text = e.target.getAttribute('data-prompt');
        if (text) {
          this.promptInput.value = text;
          this.activePrompt = text;
          this.renderCurrentStep();
        }
      });
    });

    // Tab buttons
    this.tabs.forEach(tab => {
      tab.addEventListener('click', (e) => {
        const step = parseInt(e.currentTarget.getAttribute('data-step'));
        if (step) {
          this.goToStep(step);
        }
      });
    });

    // Step Navigation Controls
    if (this.prevBtn) {
      this.prevBtn.addEventListener('click', () => {
        if (this.currentStep > 1) this.goToStep(this.currentStep - 1);
      });
    }

    if (this.nextBtn) {
      this.nextBtn.addEventListener('click', () => {
        if (this.currentStep < this.maxStep) this.goToStep(this.currentStep + 1);
      });
    }

    if (this.playBtn) {
      this.playBtn.addEventListener('click', () => this.toggleAutoPlay());
    }

    this.renderCurrentStep();
  }

  goToStep(stepNum) {
    this.currentStep = stepNum;

    // Update active tab UI
    this.tabs.forEach(tab => {
      const s = parseInt(tab.getAttribute('data-step'));
      if (s === stepNum) {
        tab.classList.add('active');
      } else {
        tab.classList.remove('active');
      }
    });

    // Toggle step views
    for (let i = 1; i <= this.maxStep; i++) {
      const view = document.getElementById(`step-view-${i}`);
      if (view) {
        if (i === stepNum) {
          view.classList.add('active');
        } else {
          view.classList.remove('active');
        }
      }
    }

    this.renderCurrentStep();
  }

  toggleAutoPlay() {
    if (this.isPlaying) {
      this.isPlaying = false;
      if (this.playBtn) this.playBtn.textContent = "▶ Auto Play Journey";
      if (this.playTimer) clearInterval(this.playTimer);
    } else {
      this.isPlaying = true;
      if (this.playBtn) this.playBtn.textContent = "⏸ Pause Journey";
      this.playTimer = setInterval(() => {
        if (this.currentStep < this.maxStep) {
          this.goToStep(this.currentStep + 1);
        } else {
          this.goToStep(1);
        }
      }, 3000);
    }
  }

  renderCurrentStep() {
    const prompt = this.activePrompt;
    const sampleData = window.NV_DATA && window.NV_DATA.samplePrompts[prompt]
      ? window.NV_DATA.samplePrompts[prompt]
      : this.generateDynamicSample(prompt);

    // Step 1: User Input
    const step1Display = document.getElementById('step1-prompt-display');
    const step1Char = document.getElementById('step1-char-count');
    const step1Byte = document.getElementById('step1-byte-size');
    if (step1Display) step1Display.textContent = `"${prompt}"`;
    if (step1Char) step1Char.textContent = prompt.length;
    if (step1Byte) step1Byte.textContent = `${prompt.length} bytes`;

    // Step 2: Tokens
    const step2Grid = document.getElementById('step2-tokens-grid');
    if (step2Grid) {
      step2Grid.innerHTML = '';
      sampleData.tokens.forEach(tok => {
        const item = document.createElement('div');
        item.className = 'token-chip-item';
        item.style.borderColor = tok.color || '#38bdf8';
        item.innerHTML = `
          <span>${tok.text}</span>
          <span class="token-id">ID: ${tok.id}</span>
        `;
        step2Grid.appendChild(item);
      });
    }

    // Step 3: Embeddings Vectors
    const step3Box = document.getElementById('step3-vectors-box');
    if (step3Box) {
      step3Box.innerHTML = '';
      sampleData.vectors.forEach(vec => {
        const row = document.createElement('div');
        row.className = 'vector-row';
        let cellsHtml = '';
        vec.values.forEach(val => {
          const bgOpacity = Math.abs(val);
          const bgColor = val >= 0 ? `rgba(56, 189, 248, ${bgOpacity})` : `rgba(168, 85, 247, ${bgOpacity})`;
          cellsHtml += `<div class="vector-cell" style="background:${bgColor}">${val}</div>`;
        });
        row.innerHTML = `
          <div class="vector-word">${vec.word}:</div>
          <div class="vector-cells">${cellsHtml}</div>
        `;
        step3Box.appendChild(row);
      });
    }

    // Step 4: Transformer Block View
    const step4View = document.getElementById('step4-transformer-view');
    if (step4View) {
      step4View.innerHTML = `
        <div class="glass-panel" style="padding: 16px; border-radius: 12px; display: flex; flex-direction: column; gap: 12px;">
          <div style="font-family: var(--font-code); font-size: 0.85rem; color: var(--accent-cyan);">TRANSFORMER LAYER STACK (96 BLOCKS)</div>
          <div style="display: flex; gap: 8px; flex-wrap: wrap;">
            <div style="background: rgba(56, 189, 248, 0.15); border: 1px solid var(--accent-cyan); padding: 8px 16px; border-radius: 8px; font-size: 0.85rem;">Multi-Head Self-Attention</div>
            <div style="color: var(--text-muted); align-self: center;">→</div>
            <div style="background: rgba(99, 102, 241, 0.15); border: 1px solid var(--accent-indigo); padding: 8px 16px; border-radius: 8px; font-size: 0.85rem;">Add & LayerNorm</div>
            <div style="color: var(--text-muted); align-self: center;">→</div>
            <div style="background: rgba(168, 85, 247, 0.15); border: 1px solid var(--accent-purple); padding: 8px 16px; border-radius: 8px; font-size: 0.85rem;">Feed-Forward Neural Net</div>
            <div style="color: var(--text-muted); align-self: center;">→</div>
            <div style="background: rgba(236, 72, 153, 0.15); border: 1px solid var(--accent-pink); padding: 8px 16px; border-radius: 8px; font-size: 0.85rem;">Output Projection</div>
          </div>
        </div>
      `;
    }

    // Step 5: Attention Matrix
    const step5Box = document.getElementById('step5-attention-box');
    if (step5Box) {
      step5Box.innerHTML = `
        <div class="glass-panel" style="padding: 16px; border-radius: 12px; display: flex; flex-direction: column; gap: 12px;">
          <div style="font-size: 0.85rem; color: var(--text-secondary);">Click a word token to highlight context connections:</div>
          <div style="display: flex; gap: 8px; flex-wrap: wrap;" id="step5-words-row">
            ${sampleData.tokens.map(t => `<button class="preset-chip word-att-btn" data-word="${t.text}">${t.text}</button>`).join('')}
          </div>
          <div id="step5-att-output" style="font-family: var(--font-code); font-size: 0.85rem; color: var(--accent-cyan); background: rgba(0,0,0,0.3); padding: 12px; border-radius: 8px;">
            Select a word above to measure cross-attention weights.
          </div>
        </div>
      `;

      const wordBtns = step5Box.querySelectorAll('.word-att-btn');
      wordBtns.forEach(btn => {
        btn.addEventListener('click', (e) => {
          const w = e.target.getAttribute('data-word');
          const attOut = document.getElementById('step5-att-output');
          if (attOut) {
            attOut.innerHTML = `Self-Attention focus from "<strong>${w}</strong>":<br>
            • Strong connection to key entities: <strong>0.92 weight</strong><br>
            • Context relationship to query verbs: <strong>0.78 weight</strong>`;
          }
        });
      });
    }

    // Step 6: Prediction Distribution
    const step6Box = document.getElementById('step6-prediction-box');
    if (step6Box) {
      step6Box.innerHTML = `
        <div class="glass-panel" style="padding: 16px; border-radius: 12px; display: flex; flex-direction: column; gap: 12px;">
          <div style="font-size: 0.85rem; color: var(--text-secondary);">Top Predicted Next Tokens:</div>
          <div style="display: flex; flex-direction: column; gap: 8px;">
            <div>
              <div style="display:flex; justify-between; font-size:0.8rem; font-family:var(--font-code);"><span>1. "is"</span><span>94.2%</span></div>
              <div style="height:8px; background:var(--accent-cyan); width:94.2%; border-radius:4px;"></div>
            </div>
            <div>
              <div style="display:flex; justify-between; font-size:0.8rem; font-family:var(--font-code);"><span>2. "refers"</span><span>3.5%</span></div>
              <div style="height:8px; background:var(--accent-indigo); width:3.5%; border-radius:4px;"></div>
            </div>
            <div>
              <div style="display:flex; justify-between; font-size:0.8rem; font-family:var(--font-code);"><span>3. "can"</span><span>1.8%</span></div>
              <div style="height:8px; background:var(--accent-purple); width:1.8%; border-radius:4px;"></div>
            </div>
          </div>
        </div>
      `;
    }

    // Step 7: Final Typewriter Stream
    if (this.currentStep === 7) {
      this.typewriteAnswer(sampleData.answer || "Gravity is a fundamental force...");
    }
  }

  generateDynamicSample(prompt) {
    const words = prompt.split(' ');
    const tokens = words.map((w, idx) => ({
      text: w,
      id: 1000 + idx * 42,
      color: idx % 2 === 0 ? '#38bdf8' : '#a855f7'
    }));
    return {
      tokens: tokens,
      vectors: words.map(w => ({
        word: w,
        values: [
          (Math.random() - 0.5).toFixed(2),
          (Math.random() - 0.5).toFixed(2),
          (Math.random() - 0.5).toFixed(2),
          (Math.random() - 0.5).toFixed(2),
          (Math.random() - 0.5).toFixed(2)
        ]
      })),
      answer: `Conceptual AI output generated for "${prompt}": The transformer model processes tokens through stacked self-attention layers to produce coherent predictions.`
    };
  }

  typewriteAnswer(text) {
    const outputEl = document.getElementById('step7-typewriter-output');
    const tokenCountEl = document.getElementById('step7-token-count');
    if (!outputEl) return;

    outputEl.textContent = '';
    let i = 0;
    if (this.typewriterTimer) clearInterval(this.typewriterTimer);

    this.typewriterTimer = setInterval(() => {
      if (i < text.length) {
        outputEl.textContent += text.charAt(i);
        i++;
        if (tokenCountEl) tokenCountEl.textContent = Math.ceil(i / 4);
      } else {
        clearInterval(this.typewriterTimer);
      }
    }, 25);
  }
}

document.addEventListener('DOMContentLoaded', () => {
  window.journeyPipeline = new JourneyPipeline();
});
