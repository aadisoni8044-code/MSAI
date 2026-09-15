/**
 * NV ZIP — Interactive GPT Conceptual Simulator
 * Real-time conceptual simulator demonstrating prompt movement through context window,
 * tokenization, transformer attention, and probabilistic token generation.
 */

class GptSimulator {
  constructor() {
    this.inputEl = document.getElementById('gpt-sim-input');
    this.simBtn = document.getElementById('gpt-sim-btn');

    this.outPrompt = document.getElementById('gpt-out-prompt');
    this.outTokens = document.getElementById('gpt-out-tokens');
    this.outModel = document.getElementById('gpt-out-model');
    this.outPrediction = document.getElementById('gpt-out-prediction');
    this.outText = document.getElementById('gpt-out-text');

    this.init();
  }

  init() {
    if (!this.inputEl || !this.simBtn) return;

    this.simBtn.addEventListener('click', () => {
      this.runSimulation(this.inputEl.value.trim() || "What is the speed of light?");
    });
  }

  runSimulation(prompt) {
    // Stage 1: Prompt & Context
    if (this.outPrompt) {
      this.outPrompt.textContent = `"${prompt}"`;
    }

    // Stage 2: Tokens
    if (this.outTokens) {
      const words = prompt.split(' ');
      this.outTokens.innerHTML = words.map(w => `<span class="chip">${w}</span>`).join('');
    }

    // Stage 3: Transformer Model
    if (this.outModel) {
      this.outModel.innerHTML = `
        <span style="color: var(--accent-cyan);">96 Transformer Layers</span>
        <span class="pulse-text" style="color: var(--accent-purple);">Calculating Multi-Head Attention...</span>
      `;
    }

    // Stage 4: Token Prediction
    if (this.outPrediction) {
      this.outPrediction.innerHTML = `
        <div style="color: var(--accent-emerald);">Token 1: "The" (94.2%)</div>
        <div style="color: var(--text-secondary);">Token 2: "Light" (3.1%)</div>
        <div style="color: var(--text-muted);">Token 3: "Speed" (1.8%)</div>
      `;
    }

    // Stage 5: Generated Answer
    if (this.outText) {
      this.outText.textContent = "Simulating autoregressive generation...";
      setTimeout(() => {
        this.outText.textContent = `[Conceptual Simulation] For prompt "${prompt}": The GPT engine processes tokens sequentially to stream the generated answer.`;
      }, 600);
    }
  }
}

document.addEventListener('DOMContentLoaded', () => {
  window.gptSimulator = new GptSimulator();
});
