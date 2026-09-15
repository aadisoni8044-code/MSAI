/**
 * NV ZIP — API Explorer & Simulated Playground
 * Manages the animated API lifecycle flow and provides an interactive playground
 * for configuring model parameters and viewing simulated JSON request/response structures.
 */

class ApiPlayground {
  constructor() {
    this.modelSelect = document.getElementById('api-model-select');
    this.promptInput = document.getElementById('api-prompt-input');
    this.tempSlider = document.getElementById('api-temp-slider');
    this.tempVal = document.getElementById('api-temp-val');
    this.tokensSlider = document.getElementById('api-tokens-slider');
    this.tokensVal = document.getElementById('api-tokens-val');
    this.sendBtn = document.getElementById('api-send-btn');
    this.jsonDisplay = document.getElementById('api-json-display');
    this.copyBtn = document.getElementById('api-copy-btn');

    this.init();
  }

  init() {
    if (!this.sendBtn || !this.jsonDisplay) return;

    // Temperature slider update
    if (this.tempSlider && this.tempVal) {
      this.tempSlider.addEventListener('input', () => {
        this.tempVal.textContent = this.tempSlider.value;
        this.updateJsonPreview();
      });
    }

    // Max tokens slider update
    if (this.tokensSlider && this.tokensVal) {
      this.tokensSlider.addEventListener('input', () => {
        this.tokensVal.textContent = this.tokensSlider.value;
        this.updateJsonPreview();
      });
    }

    // Input changes
    if (this.modelSelect) {
      this.modelSelect.addEventListener('change', () => this.updateJsonPreview());
    }
    if (this.promptInput) {
      this.promptInput.addEventListener('input', () => this.updateJsonPreview());
    }

    // Send request simulation
    this.sendBtn.addEventListener('click', () => this.executeRequestSimulation());

    // Copy button
    if (this.copyBtn) {
      this.copyBtn.addEventListener('click', () => {
        const text = this.jsonDisplay.textContent;
        navigator.clipboard.writeText(text).then(() => {
          this.copyBtn.textContent = 'Copied! ✓';
          setTimeout(() => { this.copyBtn.textContent = 'Copy JSON'; }, 2000);
        });
      });
    }

    this.updateJsonPreview();
  }

  updateJsonPreview() {
    const model = this.modelSelect ? this.modelSelect.value : 'nv-zip-pro';
    const prompt = this.promptInput ? this.promptInput.value : 'Explain how gravity works in simple terms.';
    const temp = this.tempSlider ? parseFloat(this.tempSlider.value) : 0.7;
    const maxTokens = this.tokensSlider ? parseInt(this.tokensSlider.value) : 256;

    const requestPayload = {
      model: model,
      messages: [
        {
          role: "system",
          content: "You are NV ZIP, an educational interactive AI assistant."
        },
        {
          role: "user",
          content: prompt
        }
      ],
      temperature: temp,
      max_tokens: maxTokens
    };

    if (this.jsonDisplay) {
      this.jsonDisplay.textContent = JSON.stringify(requestPayload, null, 2);
    }
  }

  executeRequestSimulation() {
    if (!this.sendBtn || !this.jsonDisplay) return;

    this.sendBtn.disabled = true;
    this.sendBtn.innerHTML = '<span>Sending Request... ⚡</span>';

    setTimeout(() => {
      const model = this.modelSelect ? this.modelSelect.value : 'nv-zip-pro';
      const prompt = this.promptInput ? this.promptInput.value : 'Explain gravity';
      const temp = this.tempSlider ? parseFloat(this.tempSlider.value) : 0.7;
      const maxTokens = this.tokensSlider ? parseInt(this.tokensSlider.value) : 256;

      const simulatedResponse = {
        status: "200 OK",
        time_ms: 142,
        response: {
          id: "chatcmpl-nvzip-" + Math.floor(Math.random() * 900000 + 100000),
          object: "chat.completion",
          created: Math.floor(Date.now() / 1000),
          model: model,
          choices: [
            {
              index: 0,
              message: {
                role: "assistant",
                content: `[SIMULATED RESPONSE for "${prompt}"] Gravity is a fundamental physical force that pulls objects with mass towards one another. In general relativity, mass curves spacetime, creating the effect we perceive as gravitational attraction.`
              },
              finish_reason: "stop"
            }
          ],
          usage: {
            prompt_tokens: prompt.length / 4,
            completion_tokens: 38,
            total_tokens: Math.ceil(prompt.length / 4) + 38
          }
        }
      };

      this.jsonDisplay.textContent = JSON.stringify(simulatedResponse, null, 2);
      this.sendBtn.disabled = false;
      this.sendBtn.innerHTML = '<span>Send Request ⚡</span>';
    }, 600);
  }
}

document.addEventListener('DOMContentLoaded', () => {
  window.apiPlayground = new ApiPlayground();
});
